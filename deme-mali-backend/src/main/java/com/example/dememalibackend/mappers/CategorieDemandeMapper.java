package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.CategorieDemandeRequestDTO;
import com.example.dememalibackend.dto.CategorieDemandeResponseDTO;
import com.example.dememalibackend.entity.CategorieDemande;
import org.springframework.stereotype.Component;

@Component
public class CategorieDemandeMapper {

    public CategorieDemande toEntity(CategorieDemandeRequestDTO dto) {

        return CategorieDemande.builder()
                .nom(dto.getNom())
                .build();
    }

    public CategorieDemandeResponseDTO toDTO(CategorieDemande categorieDemande) {

        return CategorieDemandeResponseDTO.builder()
                .id(categorieDemande.getId())
                .nom(categorieDemande.getNom())
                .build();
    }
}
