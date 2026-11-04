package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.AttributionBadgeResponseDTO;
import com.example.dememalibackend.entity.AttributionBadge;
import com.example.dememalibackend.entity.Badge;
import org.springframework.stereotype.Component;

@Component
public class AttributionBadgeMapper {

    // Convertir une attribution en DTO pour afficher l'historique
    public AttributionBadgeResponseDTO toResponseDTO(
            AttributionBadge attribution) {

        if (attribution == null) {
            return null;
        }

        AttributionBadgeResponseDTO dto =
                new AttributionBadgeResponseDTO();

        dto.setId(attribution.getId());

        if (attribution.getDonateur() != null) {
            dto.setDonateurId(attribution.getDonateur().getId());
        }

        Badge badge = attribution.getBadge();

        if (badge != null) {
            dto.setBadgeId(badge.getId());
            dto.setCodeBadge(badge.getCode());
            dto.setNomBadge(badge.getNom());
            dto.setImageUrl(badge.getImageUrl());
        }

        dto.setSemestre(attribution.getSemestre());
        dto.setAnnee(attribution.getAnnee());
        dto.setMontantAtteint(attribution.getMontantAtteint());

        return dto;
    }
}