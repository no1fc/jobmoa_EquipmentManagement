package com.jobmoa.equipment.domain.category;

import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "asset_categories")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class AssetCategory {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "category_id")
    private Long categoryId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "parent_id")
    private AssetCategory parent;

    @OneToMany(mappedBy = "parent")
    private List<AssetCategory> children = new ArrayList<>();

    @Column(name = "category_name", nullable = false, length = 100)
    private String categoryName;

    @Column(name = "category_level", nullable = false)
    private Integer categoryLevel;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = LocalDateTime.now();
    }

    @Builder
    private AssetCategory(AssetCategory parent, String categoryName,
                          Integer categoryLevel, String description) {
        this.parent = parent;
        this.categoryName = categoryName;
        this.categoryLevel = categoryLevel;
        this.description = description;
    }

    public void update(String categoryName, String description) {
        this.categoryName = categoryName;
        this.description = description;
    }
}
