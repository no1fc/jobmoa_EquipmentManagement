package com.jobmoa.equipment.util;

import com.jobmoa.equipment.repository.AssetRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

@Component
@RequiredArgsConstructor
public class AssetCodeGenerator {

    private static final String PREFIX = "AST-";
    private static final DateTimeFormatter MONTH_FORMAT = DateTimeFormatter.ofPattern("yyyyMM");

    private final AssetRepository assetRepository;

    public String generate() {
        String monthPrefix = PREFIX + LocalDate.now().format(MONTH_FORMAT) + "-";
        String lastCode = assetRepository.findLastAssetCodeByPrefix(monthPrefix);

        int nextSequence = 1;
        if (lastCode != null) {
            String sequencePart = lastCode.substring(lastCode.lastIndexOf("-") + 1);
            nextSequence = Integer.parseInt(sequencePart) + 1;
        }

        return monthPrefix + String.format("%04d", nextSequence);
    }
}
