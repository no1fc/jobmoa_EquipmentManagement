package com.jobmoa.equipment.repository;

import com.jobmoa.equipment.domain.category.AssetCategory;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface CategoryRepository extends JpaRepository<AssetCategory, Long> {

    List<AssetCategory> findByCategoryLevel(Integer level);

    List<AssetCategory> findByParentCategoryId(Long parentId);

    @Query("SELECT c FROM AssetCategory c LEFT JOIN FETCH c.children WHERE c.parent IS NULL ORDER BY c.categoryId")
    List<AssetCategory> findAllRootCategories();

    @Query("SELECT COUNT(a) FROM Asset a WHERE a.category.categoryId = :categoryId")
    long countAssetsByCategoryId(@Param("categoryId") Long categoryId);
}
