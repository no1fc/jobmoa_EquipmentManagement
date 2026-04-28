package com.jobmoa.equipment.service;

import com.jobmoa.equipment.domain.asset.Asset;
import com.jobmoa.equipment.domain.asset.AssetStatus;
import com.jobmoa.equipment.domain.category.AssetCategory;
import com.jobmoa.equipment.domain.user.User;
import com.jobmoa.equipment.dto.request.AssetCreateRequest;
import com.jobmoa.equipment.dto.request.AssetUpdateRequest;
import com.jobmoa.equipment.dto.response.AssetDetailResponse;
import com.jobmoa.equipment.dto.response.AssetResponse;
import com.jobmoa.equipment.dto.response.AssetSummaryResponse;
import com.jobmoa.equipment.exception.BusinessException;
import com.jobmoa.equipment.exception.ErrorCode;
import com.jobmoa.equipment.exception.NotFoundException;
import com.jobmoa.equipment.repository.AssetRepository;
import com.jobmoa.equipment.repository.CategoryRepository;
import com.jobmoa.equipment.repository.UserRepository;
import com.jobmoa.equipment.util.AssetCodeGenerator;
import com.jobmoa.equipment.util.FileUploadUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AssetService {

    private final AssetRepository assetRepository;
    private final CategoryRepository categoryRepository;
    private final UserRepository userRepository;
    private final AssetCodeGenerator assetCodeGenerator;
    private final FileUploadUtil fileUploadUtil;

    public Page<AssetResponse> getAssets(AssetStatus status, Long categoryId,
                                          String location, String search, Pageable pageable) {
        return assetRepository.findAllWithFilters(status, categoryId, location, search, pageable)
            .map(AssetResponse::from);
    }

    public AssetDetailResponse getAsset(Long assetId) {
        Asset asset = findAssetById(assetId);
        return AssetDetailResponse.from(asset);
    }

    @Transactional
    public AssetResponse createAsset(AssetCreateRequest request, MultipartFile image, Long userId) {
        AssetCategory category = categoryRepository.findById(request.categoryId())
            .orElseThrow(() -> new NotFoundException(ErrorCode.CATEGORY_NOT_FOUND));

        User user = userRepository.findById(userId)
            .orElseThrow(() -> new NotFoundException(ErrorCode.USER_NOT_FOUND));

        String assetCode = assetCodeGenerator.generate();

        Asset asset = Asset.builder()
            .assetCode(assetCode)
            .category(category)
            .assetName(request.assetName())
            .serialNumber(request.serialNumber())
            .manufacturer(request.manufacturer())
            .modelNumber(request.modelNumber())
            .purchaseDate(request.purchaseDate())
            .location(request.location())
            .managingDepartment(request.managingDepartment())
            .usingDepartment(request.usingDepartment())
            .conditionRating(request.conditionRating())
            .technicalSpecs(request.technicalSpecs())
            .aiClassified(request.aiClassified())
            .notes(request.notes())
            .registeredBy(user)
            .build();

        Asset saved = assetRepository.save(asset);

        if (image != null && !image.isEmpty()) {
            String imagePath = fileUploadUtil.saveFile(image, "assets");
            saved.updateImagePath(imagePath);
        }

        return AssetResponse.from(saved);
    }

    @Transactional
    public AssetResponse updateAsset(Long assetId, AssetUpdateRequest request, MultipartFile image) {
        Asset asset = findAssetById(assetId);

        AssetCategory category = categoryRepository.findById(request.categoryId())
            .orElseThrow(() -> new NotFoundException(ErrorCode.CATEGORY_NOT_FOUND));

        asset.update(
            request.assetName(), request.serialNumber(), request.manufacturer(),
            request.modelNumber(), request.purchaseDate(), request.location(),
            request.managingDepartment(), request.usingDepartment(),
            request.conditionRating(), request.technicalSpecs(), request.notes(),
            category
        );

        if (image != null && !image.isEmpty()) {
            if (asset.getImagePath() != null) {
                fileUploadUtil.deleteFile(asset.getImagePath());
            }
            String imagePath = fileUploadUtil.saveFile(image, "assets");
            asset.updateImagePath(imagePath);
        }

        return AssetResponse.from(asset);
    }

    @Transactional
    public void deleteAsset(Long assetId) {
        Asset asset = findAssetById(assetId);

        if (asset.isRented()) {
            throw new BusinessException(ErrorCode.ASSET_RENTED);
        }

        if (asset.getImagePath() != null) {
            fileUploadUtil.deleteFile(asset.getImagePath());
        }

        assetRepository.delete(asset);
    }

    @Transactional
    public AssetResponse changeStatus(Long assetId, AssetStatus newStatus) {
        Asset asset = findAssetById(assetId);

        if (asset.isRented() && newStatus != AssetStatus.IN_USE) {
            throw new BusinessException(ErrorCode.ASSET_RENTED,
                "대여 중인 장비는 반납 후에만 상태를 변경할 수 있습니다.");
        }

        asset.changeStatus(newStatus);
        return AssetResponse.from(asset);
    }

    public AssetSummaryResponse getSummary() {
        long total = assetRepository.count();
        long inUse = assetRepository.countByStatus(AssetStatus.IN_USE);
        long rented = assetRepository.countByStatus(AssetStatus.RENTED);
        long broken = assetRepository.countByStatus(AssetStatus.BROKEN);
        long inStorage = assetRepository.countByStatus(AssetStatus.IN_STORAGE);
        long disposed = assetRepository.countByStatus(AssetStatus.DISPOSED);

        return new AssetSummaryResponse(total, inUse, rented, broken, inStorage, disposed);
    }

    private Asset findAssetById(Long assetId) {
        return assetRepository.findById(assetId)
            .orElseThrow(() -> new NotFoundException(ErrorCode.ASSET_NOT_FOUND));
    }
}
