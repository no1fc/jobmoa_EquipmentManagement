package com.jobmoa.equipment.controller;

import com.jobmoa.equipment.dto.request.CategoryCreateRequest;
import com.jobmoa.equipment.dto.request.CategoryUpdateRequest;
import com.jobmoa.equipment.dto.response.ApiResponse;
import com.jobmoa.equipment.dto.response.CategoryResponse;
import com.jobmoa.equipment.dto.response.CategoryTreeResponse;
import com.jobmoa.equipment.service.CategoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Category", description = "카테고리 관리 API")
@RestController
@RequestMapping("/api/v1/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CategoryService categoryService;

    @Operation(summary = "카테고리 전체 목록")
    @GetMapping
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getCategories(
        @RequestParam(required = false) Integer level
    ) {
        return ResponseEntity.ok(ApiResponse.ok(categoryService.getCategories(level)));
    }

    @Operation(summary = "카테고리 트리 구조")
    @GetMapping("/tree")
    public ResponseEntity<ApiResponse<List<CategoryTreeResponse>>> getCategoryTree() {
        return ResponseEntity.ok(ApiResponse.ok(categoryService.getCategoryTree()));
    }

    @Operation(summary = "카테고리 단건 조회")
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoryResponse>> getCategory(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(categoryService.getCategory(id)));
    }

    @Operation(summary = "하위 카테고리 조회")
    @GetMapping("/{id}/children")
    public ResponseEntity<ApiResponse<List<CategoryResponse>>> getChildren(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(categoryService.getChildren(id)));
    }

    @Operation(summary = "카테고리 생성")
    @PreAuthorize("hasRole('MANAGER')")
    @PostMapping
    public ResponseEntity<ApiResponse<CategoryResponse>> createCategory(
        @Valid @RequestBody CategoryCreateRequest request
    ) {
        CategoryResponse response = categoryService.createCategory(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok(response));
    }

    @Operation(summary = "카테고리 수정")
    @PreAuthorize("hasRole('MANAGER')")
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<CategoryResponse>> updateCategory(
        @PathVariable Long id,
        @Valid @RequestBody CategoryUpdateRequest request
    ) {
        return ResponseEntity.ok(ApiResponse.ok(categoryService.updateCategory(id, request)));
    }

    @Operation(summary = "카테고리 삭제")
    @PreAuthorize("hasRole('MANAGER')")
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteCategory(@PathVariable Long id) {
        categoryService.deleteCategory(id);
        return ResponseEntity.ok(ApiResponse.ok(null, "카테고리가 삭제되었습니다."));
    }
}
