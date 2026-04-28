package com.jobmoa.equipment.controller;

import com.jobmoa.equipment.domain.asset.AssetStatus;
import com.jobmoa.equipment.dto.request.AssetCreateRequest;
import com.jobmoa.equipment.dto.request.AssetStatusRequest;
import com.jobmoa.equipment.dto.request.AssetUpdateRequest;
import com.jobmoa.equipment.dto.response.*;
import com.jobmoa.equipment.security.CustomUserDetails;
import com.jobmoa.equipment.service.AssetService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Asset", description = "장비 관리 API")
@RestController
@RequestMapping("/api/v1/assets")
@RequiredArgsConstructor
public class AssetController {

    private final AssetService assetService;

    @Operation(summary = "장비 목록 조회")
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<AssetResponse>>> getAssets(
        @RequestParam(required = false) AssetStatus status,
        @RequestParam(required = false) Long categoryId,
        @RequestParam(required = false) String location,
        @RequestParam(required = false) String search,
        @PageableDefault(size = 20, sort = "createdAt", direction = Sort.Direction.DESC) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            PageResponse.from(assetService.getAssets(status, categoryId, location, search, pageable))));
    }

    @Operation(summary = "장비 상세 조회")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<AssetDetailResponse>> getAsset(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(assetService.getAsset(id)));
    }

    @Operation(summary = "장비 등록")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<AssetResponse>> createAsset(
        @Valid @RequestPart("data") AssetCreateRequest request,
        @RequestPart(value = "image", required = false) MultipartFile image,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        AssetResponse response = assetService.createAsset(request, image, userDetails.getUserId());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(response));
    }

    @Operation(summary = "장비 수정")
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse<AssetResponse>> updateAsset(
        @PathVariable Long id,
        @Valid @RequestPart("data") AssetUpdateRequest request,
        @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        return ResponseEntity.ok(ApiResponse.ok(assetService.updateAsset(id, request, image)));
    }

    @Operation(summary = "장비 삭제")
    @PreAuthorize("hasRole('MANAGER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteAsset(@PathVariable Long id) {
        assetService.deleteAsset(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "장비가 삭제되었습니다."));
    }

    @Operation(summary = "장비 상태 변경")
    @PatchMapping("/{id}/status")
    public ResponseEntity<ApiResponse<AssetResponse>> changeStatus(
        @PathVariable Long id,
        @Valid @RequestBody AssetStatusRequest request
    ) {
        AssetStatus status = AssetStatus.valueOf(request.status());
        return ResponseEntity.ok(ApiResponse.ok(assetService.changeStatus(id, status)));
    }

    @Operation(summary = "장비 현황 요약 (대시보드)")
    @GetMapping("/summary")
    public ResponseEntity<ApiResponse<AssetSummaryResponse>> getSummary() {
        return ResponseEntity.ok(ApiResponse.ok(assetService.getSummary()));
    }
}
