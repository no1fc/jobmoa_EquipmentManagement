package com.jobmoa.equipment.repository;

import com.jobmoa.equipment.domain.asset.Asset;
import com.jobmoa.equipment.domain.asset.AssetStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface AssetRepository extends JpaRepository<Asset, Long> {

    @Query("""
        SELECT a FROM Asset a
        JOIN FETCH a.category
        JOIN FETCH a.registeredBy
        WHERE (:status IS NULL OR a.status = :status)
        AND (:categoryId IS NULL OR a.category.categoryId = :categoryId)
        AND (:location IS NULL OR a.location LIKE %:location%)
        AND (:search IS NULL OR a.assetName LIKE %:search% OR a.assetCode LIKE %:search%
             OR a.serialNumber LIKE %:search%)
        """)
    Page<Asset> findAllWithFilters(
        @Param("status") AssetStatus status,
        @Param("categoryId") Long categoryId,
        @Param("location") String location,
        @Param("search") String search,
        Pageable pageable
    );

    @Query("SELECT COUNT(a) FROM Asset a WHERE a.status = :status")
    long countByStatus(@Param("status") AssetStatus status);

    @Query("""
        SELECT a.assetCode FROM Asset a
        WHERE a.assetCode LIKE :prefix%
        ORDER BY a.assetCode DESC
        LIMIT 1
        """)
    String findLastAssetCodeByPrefix(@Param("prefix") String prefix);
}
