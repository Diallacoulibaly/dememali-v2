package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.DashboardResponseDTO;
import com.example.dememalibackend.service.DashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final DashboardService dashboardService;

    // ADMIN uniquement
    @GetMapping("/admin")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DashboardResponseDTO> getAdminStats() {
        return ResponseEntity.ok(dashboardService.getAdminDashboardStats());
    }

    // ADMIN : toutes les organisations
    // ORGANISATIONPARTENAIRE : uniquement sa propre organisation
    @GetMapping("/organisation/{organisationId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'ORGANISATIONPARTENAIRE')")
    public ResponseEntity<DashboardResponseDTO> getOrganisationStats(
            @PathVariable Integer organisationId) {
        return ResponseEntity.ok(
                dashboardService.getOrganisationDashboardStats(organisationId)
        );
    }
}