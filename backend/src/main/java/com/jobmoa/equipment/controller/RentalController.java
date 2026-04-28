package com.jobmoa.equipment.controller;

import com.jobmoa.equipment.domain.rental.RentalStatus;
import com.jobmoa.equipment.dto.request.RentalCreateRequest;
import com.jobmoa.equipment.dto.request.RentalExtendRequest;
import com.jobmoa.equipment.dto.request.RentalReturnRequest;
import com.jobmoa.equipment.dto.response.*;
import com.jobmoa.equipment.security.CustomUserDetails;
import com.jobmoa.equipment.service.RentalService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Rental", description = "대여 관리 API")
@RestController
@RequestMapping("/api/v1/rentals")
@RequiredArgsConstructor
public class RentalController {

    private final RentalService rentalService;

    @Operation(summary = "대여 목록 조회")
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<RentalResponse>>> getRentals(
        @RequestParam(required = false) RentalStatus status,
        @RequestParam(required = false) Long borrowerId,
        @RequestParam(required = false) Long assetId,
        @PageableDefault(size = 20, sort = "dueDate", direction = Sort.Direction.ASC) Pageable pageable
    ) {
        return ResponseEntity.ok(ApiResponse.ok(
            PageResponse.from(rentalService.getRentals(status, borrowerId, assetId, pageable))));
    }

    @Operation(summary = "대여 상세 조회")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<RentalResponse>> getRental(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(rentalService.getRental(id)));
    }

    @Operation(summary = "대여 생성")
    @PostMapping
    public ResponseEntity<ApiResponse<RentalResponse>> createRental(
        @Valid @RequestBody RentalCreateRequest request,
        @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        RentalResponse response = rentalService.createRental(request, userDetails.getUserId());
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(response));
    }

    @Operation(summary = "반납")
    @PutMapping("/{id}/return")
    public ResponseEntity<ApiResponse<RentalResponse>> returnRental(
        @PathVariable Long id,
        @RequestBody(required = false) RentalReturnRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok(rentalService.returnRental(id, request)));
    }

    @Operation(summary = "연장 (최대 1회, +14일)")
    @PutMapping("/{id}/extend")
    public ResponseEntity<ApiResponse<RentalResponse>> extendRental(
        @PathVariable Long id,
        @Valid @RequestBody RentalExtendRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok(rentalService.extendRental(id, request)));
    }

    @Operation(summary = "대여 취소")
    @PutMapping("/{id}/cancel")
    public ResponseEntity<ApiResponse<RentalResponse>> cancelRental(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(rentalService.cancelRental(id)));
    }

    @Operation(summary = "대여 대시보드 요약")
    @GetMapping("/dashboard")
    public ResponseEntity<ApiResponse<RentalDashboardResponse>> getDashboard() {
        return ResponseEntity.ok(ApiResponse.ok(rentalService.getDashboard()));
    }

    @Operation(summary = "연체 목록")
    @GetMapping("/overdue")
    public ResponseEntity<ApiResponse<List<RentalResponse>>> getOverdueRentals() {
        return ResponseEntity.ok(ApiResponse.ok(rentalService.getOverdueRentals()));
    }

    @Operation(summary = "자산별 대여 이력")
    @GetMapping("/asset/{assetId}/history")
    public ResponseEntity<ApiResponse<List<RentalResponse>>> getAssetRentalHistory(
        @PathVariable Long assetId
    ) {
        return ResponseEntity.ok(ApiResponse.ok(rentalService.getAssetRentalHistory(assetId)));
    }
}
