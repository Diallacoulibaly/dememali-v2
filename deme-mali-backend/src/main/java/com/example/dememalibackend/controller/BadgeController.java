package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.BadgeDonateurDTO;
import com.example.dememalibackend.service.BadgeService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/badges")
@RequiredArgsConstructor
public class BadgeController {

    private final BadgeService badgeService;

    // Badges du semestre actuel
    @GetMapping("/donateur/{donateurId}/actuel")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR')")
    public List<BadgeDonateurDTO> getBadgesActuels(
            @PathVariable Integer donateurId) {
        return badgeService.getBadgesSemestreActuel(donateurId);
    }

    // Badges d'un semestre précis
    @GetMapping("/donateur/{donateurId}")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR')")
    public List<BadgeDonateurDTO> getBadgesSemestre(
            @PathVariable Integer donateurId,
            @RequestParam Integer annee,
            @RequestParam String semestre) {
        return badgeService.getBadgesSemestre(
                donateurId, annee, semestre);
    }

    // Historique des badges obtenus
    @GetMapping("/donateur/{donateurId}/historique")
    @PreAuthorize("hasAnyRole('ADMIN', 'DONATEUR')")
    public List<BadgeDonateurDTO> getHistorique(
            @PathVariable Integer donateurId) {
        return badgeService.getHistorique(donateurId);
    }
}