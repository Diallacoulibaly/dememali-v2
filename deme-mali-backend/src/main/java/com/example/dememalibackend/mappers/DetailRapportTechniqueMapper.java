package com.example.dememalibackend.mappers;


import com.example.dememalibackend.dto.DetailRapportTechniqueResponseDTO;
import com.example.dememalibackend.entity.DetailRapportTechnique;
import org.springframework.stereotype.Component;

@Component
public class DetailRapportTechniqueMapper {

    public DetailRapportTechniqueResponseDTO toDTO(
            DetailRapportTechnique detail) {

        return DetailRapportTechniqueResponseDTO.builder()
                .id(detail.getId())
                .designation(detail.getDesignation())
                .quantite(detail.getQuantite())
                .unite(detail.getUnite())
                .prixUnitaire(detail.getPrixUnitaire())
                .montant(detail.getMontant())
                .rapportTechniqueId(
                        detail.getRapportTechnique().getId()
                )
                .build();
    }
}
