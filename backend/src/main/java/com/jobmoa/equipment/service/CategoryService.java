package com.jobmoa.equipment.service;

import com.jobmoa.equipment.domain.category.AssetCategory;
import com.jobmoa.equipment.dto.request.CategoryCreateRequest;
import com.jobmoa.equipment.dto.request.CategoryUpdateRequest;
import com.jobmoa.equipment.dto.response.CategoryResponse;
import com.jobmoa.equipment.dto.response.CategoryTreeResponse;
import com.jobmoa.equipment.exception.BusinessException;
import com.jobmoa.equipment.exception.ErrorCode;
import com.jobmoa.equipment.exception.NotFoundException;
import com.jobmoa.equipment.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class CategoryService {

    private final CategoryRepository categoryRepository;

    public List<CategoryResponse> getCategories(Integer level) {
        List<AssetCategory> categories = (level != null)
            ? categoryRepository.findByCategoryLevel(level)
            : categoryRepository.findAll();

        return categories.stream()
            .map(CategoryResponse::from)
            .toList();
    }

    public List<CategoryTreeResponse> getCategoryTree() {
        List<AssetCategory> rootCategories = categoryRepository.findAllRootCategories();
        return rootCategories.stream()
            .map(CategoryTreeResponse::from)
            .toList();
    }

    public CategoryResponse getCategory(Long categoryId) {
        AssetCategory category = findCategoryById(categoryId);
        return CategoryResponse.from(category);
    }

    public List<CategoryResponse> getChildren(Long categoryId) {
        findCategoryById(categoryId);
        return categoryRepository.findByParentCategoryId(categoryId).stream()
            .map(CategoryResponse::from)
            .toList();
    }

    @Transactional
    public CategoryResponse createCategory(CategoryCreateRequest request) {
        AssetCategory parent = null;
        if (request.parentId() != null) {
            parent = findCategoryById(request.parentId());
        }

        AssetCategory category = AssetCategory.builder()
            .parent(parent)
            .categoryName(request.categoryName())
            .categoryLevel(request.categoryLevel())
            .description(request.description())
            .build();

        AssetCategory saved = categoryRepository.save(category);
        return CategoryResponse.from(saved);
    }

    @Transactional
    public CategoryResponse updateCategory(Long categoryId, CategoryUpdateRequest request) {
        AssetCategory category = findCategoryById(categoryId);
        category.update(request.categoryName(), request.description());
        return CategoryResponse.from(category);
    }

    @Transactional
    public void deleteCategory(Long categoryId) {
        AssetCategory category = findCategoryById(categoryId);

        if (!category.getChildren().isEmpty()) {
            throw new BusinessException(ErrorCode.CATEGORY_HAS_CHILDREN);
        }

        long assetCount = categoryRepository.countAssetsByCategoryId(categoryId);
        if (assetCount > 0) {
            throw new BusinessException(ErrorCode.CATEGORY_HAS_ASSETS);
        }

        categoryRepository.delete(category);
    }

    private AssetCategory findCategoryById(Long categoryId) {
        return categoryRepository.findById(categoryId)
            .orElseThrow(() -> new NotFoundException(ErrorCode.CATEGORY_NOT_FOUND));
    }
}
