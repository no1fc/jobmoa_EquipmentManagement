package com.jobmoa.equipment.domain.asset;

import com.jobmoa.equipment.domain.BaseTimeEntity;
import com.jobmoa.equipment.domain.category.AssetCategory;
import com.jobmoa.equipment.domain.user.User;
import jakarta.persistence.*;
import lombok.AccessLevel;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Entity
@Table(name = "assets")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Asset extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "asset_id")
    private Long assetId;

    @Column(name = "asset_code", nullable = false, unique = true, length = 64)
    private String assetCode;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = false)
    private AssetCategory category;

    @Column(name = "asset_name", nullable = false, length = 200)
    private String assetName;

    @Column(name = "serial_number", length = 128)
    private String serialNumber;

    @Column(name = "manufacturer", length = 100)
    private String manufacturer;

    @Column(name = "model_number", length = 128)
    private String modelNumber;

    @Column(name = "purchase_date")
    private LocalDate purchaseDate;

    @Column(name = "location", length = 200)
    private String location;

    @Column(name = "managing_department", length = 100)
    private String managingDepartment;

    @Column(name = "using_department", length = 100)
    private String usingDepartment;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false, length = 20)
    private AssetStatus status;

    @Column(name = "condition_rating")
    private Integer conditionRating;

    @Column(name = "technical_specs", columnDefinition = "NVARCHAR(MAX)")
    private String technicalSpecs;

    @Column(name = "image_path", length = 500)
    private String imagePath;

    @Column(name = "ai_classified")
    private Boolean aiClassified;

    @Column(name = "notes", columnDefinition = "NVARCHAR(MAX)")
    private String notes;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "registered_by", nullable = false)
    private User registeredBy;

    @Builder
    private Asset(String assetCode, AssetCategory category, String assetName,
                  String serialNumber, String manufacturer, String modelNumber,
                  LocalDate purchaseDate, String location,
                  String managingDepartment, String usingDepartment,
                  Integer conditionRating,
                  String technicalSpecs, String imagePath, Boolean aiClassified,
                  String notes, User registeredBy) {
        this.assetCode = assetCode;
        this.category = category;
        this.assetName = assetName;
        this.serialNumber = serialNumber;
        this.manufacturer = manufacturer;
        this.modelNumber = modelNumber;
        this.purchaseDate = purchaseDate;
        this.location = location;
        this.managingDepartment = managingDepartment;
        this.usingDepartment = usingDepartment;
        this.status = AssetStatus.IN_USE;
        this.conditionRating = conditionRating != null ? conditionRating : 5;
        this.technicalSpecs = technicalSpecs;
        this.imagePath = imagePath;
        this.aiClassified = aiClassified != null ? aiClassified : false;
        this.notes = notes;
        this.registeredBy = registeredBy;
    }

    public void update(String assetName, String serialNumber, String manufacturer,
                       String modelNumber, LocalDate purchaseDate, String location,
                       String managingDepartment, String usingDepartment,
                       Integer conditionRating, String technicalSpecs, String notes,
                       AssetCategory category) {
        this.assetName = assetName;
        this.serialNumber = serialNumber;
        this.manufacturer = manufacturer;
        this.modelNumber = modelNumber;
        this.purchaseDate = purchaseDate;
        this.location = location;
        this.managingDepartment = managingDepartment;
        this.usingDepartment = usingDepartment;
        this.conditionRating = conditionRating;
        this.technicalSpecs = technicalSpecs;
        this.notes = notes;
        this.category = category;
    }

    public void changeStatus(AssetStatus newStatus) {
        this.status = newStatus;
    }

    public void updateImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public boolean isRented() {
        return this.status == AssetStatus.RENTED;
    }

    public boolean isAvailableForRental() {
        return this.status == AssetStatus.IN_USE || this.status == AssetStatus.IN_STORAGE;
    }
}
