package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.DashboardResponseDTO;

public interface DashboardService {
    DashboardResponseDTO getAdminDashboardStats();
    DashboardResponseDTO getOrganisationDashboardStats(Integer organisationId);
}
