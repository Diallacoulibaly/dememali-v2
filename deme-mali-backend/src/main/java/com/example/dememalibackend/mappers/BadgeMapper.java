package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.BadgeResponseDTO;
import com.example.dememalibackend.entity.Badge;
import org.springframework.stereotype.Component;

@Component
public class BadgeMapper {

    // Convertir un badge en DTO pour l'affichage
    public BadgeResponseDTO toResponseDTO(Badge badge) {

        if (badge == null) {
            return null;
        }

        BadgeResponseDTO dto = new BadgeResponseDTO();

        dto.setId(badge.getId());
        dto.setCode(badge.getCode());
        dto.setNom(badge.getNom());
        dto.setImageUrl(badge.getImageUrl());
        dto.setMontantMinimum(badge.getMontantMinimum());
        dto.setActif(badge.isActif());

        return dto;
    }
}