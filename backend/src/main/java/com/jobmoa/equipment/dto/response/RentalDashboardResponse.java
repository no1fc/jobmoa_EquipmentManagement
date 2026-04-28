package com.jobmoa.equipment.dto.response;

public record RentalDashboardResponse(
    long totalActive,
    long overdueCount,
    long dueSoon,
    long returnedToday
) {}
