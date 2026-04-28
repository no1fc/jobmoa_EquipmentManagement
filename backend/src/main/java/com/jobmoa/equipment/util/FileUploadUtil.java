package com.jobmoa.equipment.util;

import com.jobmoa.equipment.exception.BusinessException;
import com.jobmoa.equipment.exception.ErrorCode;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Set;
import java.util.UUID;

@Slf4j
@Component
public class FileUploadUtil {

    private final Path uploadPath;
    private final Set<String> allowedExtensions;
    private final long maxSize;

    public FileUploadUtil(
        @Value("${file.upload-dir:./uploads}") String uploadDir,
        @Value("${file.allowed-extensions:jpg,jpeg,png,webp}") String extensions,
        @Value("${file.max-size:10485760}") long maxSize
    ) {
        this.uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
        this.allowedExtensions = Set.of(extensions.split(","));
        this.maxSize = maxSize;

        try {
            Files.createDirectories(this.uploadPath);
        } catch (IOException e) {
            log.error("Failed to create upload directory: {}", uploadDir, e);
        }
    }

    public String saveFile(MultipartFile file, String subDirectory) {
        validateFile(file);

        String originalFilename = file.getOriginalFilename();
        String extension = getExtension(originalFilename);
        String storedFilename = UUID.randomUUID() + "." + extension;

        try {
            Path targetDir = uploadPath.resolve(subDirectory);
            Files.createDirectories(targetDir);

            Path targetPath = targetDir.resolve(storedFilename);
            Files.copy(file.getInputStream(), targetPath, StandardCopyOption.REPLACE_EXISTING);

            return subDirectory + "/" + storedFilename;
        } catch (IOException e) {
            log.error("Failed to save file: {}", originalFilename, e);
            throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED);
        }
    }

    public void deleteFile(String filePath) {
        if (filePath == null || filePath.isBlank()) {
            return;
        }
        try {
            Path path = uploadPath.resolve(filePath).normalize();
            Files.deleteIfExists(path);
        } catch (IOException e) {
            log.warn("Failed to delete file: {}", filePath, e);
        }
    }

    private void validateFile(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.FILE_UPLOAD_FAILED, "파일이 비어있습니다.");
        }
        if (file.getSize() > maxSize) {
            throw new BusinessException(ErrorCode.FILE_SIZE_EXCEEDED);
        }
        String extension = getExtension(file.getOriginalFilename());
        if (!allowedExtensions.contains(extension.toLowerCase())) {
            throw new BusinessException(ErrorCode.FILE_INVALID_EXTENSION);
        }
    }

    private String getExtension(String filename) {
        if (filename == null || !filename.contains(".")) {
            return "";
        }
        return filename.substring(filename.lastIndexOf(".") + 1);
    }
}
