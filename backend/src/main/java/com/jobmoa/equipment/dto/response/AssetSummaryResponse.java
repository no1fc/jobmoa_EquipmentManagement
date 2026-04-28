package com.jobmoa.equipment.dto.response;

public record AssetSummaryResponse(
    long total,
    long inUse,
    long rented,
    long broken,
    long inStorage,
    long disposed
) {}
