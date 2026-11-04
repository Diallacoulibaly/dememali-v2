package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.DetailRapportTechniqueResponseDTO;
import com.example.dememalibackend.dto.RapportTechniqueRequestDTO;
import com.example.dememalibackend.dto.RapportTechniqueResponseDTO;
import com.example.dememalibackend.entity.RapportBesoin;
import com.example.dememalibackend.entity.RapportTechnique;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
public class RapportTechniqueMapper {

    /**
     * Transformer le DTO de création en entité.
     */
    public RapportTechnique toEntity(
            RapportTechniqueRequestDTO dto,
            RapportBesoin rapportBesoin) {

        if (dto == null) {
            return null;
        }

        RapportTechnique rapportTechnique = new RapportTechnique();

        rapportTechnique.setDescriptionTechnique(
                dto.getDescriptionTechnique()
        );

        rapportTechnique.setMontantFinal(
                dto.getMontantFinal()
        );

        rapportTechnique.setRapportBesoin(
                rapportBesoin
        );

        return rapportTechnique;
    }

    /**
     * Transformer l'entité en DTO de réponse.
     */
    public RapportTechniqueResponseDTO toDTO(
            RapportTechnique entity) {

        if (entity == null) {
            return null;
        }

        RapportTechniqueResponseDTO dto =
                new RapportTechniqueResponseDTO();

        dto.setId(entity.getId());

        dto.setDescriptionTechnique(
                entity.getDescriptionTechnique()
        );

        dto.setDateCreation(
                entity.getDateCreation()
        );

        dto.setMontantFinal(
                entity.getMontantFinal()
        );

        // Rapport de besoin associé
        if (entity.getRapportBesoin() != null) {

            RapportBesoin rapportBesoin =
                    entity.getRapportBesoin();

            dto.setRapportBesoinId(
                    rapportBesoin.getId()
            );

            // Récupérer le statut de la demande d'aide
            // RapportTechnique -> RapportBesoin
            // -> EtudeTerrain -> DemandeAide
            if (rapportBesoin.getEtudeTerrain() != null
                    && rapportBesoin.getEtudeTerrain()
                    .getDemandeAide() != null) {

                dto.setStatutDemande(
                        rapportBesoin.getEtudeTerrain()
                                .getDemandeAide()
                                .getStatut()
                );
            }
        }

        // Détails du rapport technique
        if (entity.getDetails() != null) {

            dto.setDetails(
                    entity.getDetails()
                            .stream()
                            .map(this::detailToDTO)
                            .collect(Collectors.toList())
            );
        }

        return dto;
    }

    /**
     * Transformer un détail en DTO.
     */
    private DetailRapportTechniqueResponseDTO detailToDTO(
            com.example.dememalibackend.entity.DetailRapportTechnique detail) {

        return DetailRapportTechniqueResponseDTO.builder()
                .id(detail.getId())
                .designation(detail.getDesignation())
                .quantite(detail.getQuantite())
                .unite(detail.getUnite())
                .prixUnitaire(detail.getPrixUnitaire())
                .montant(detail.getMontant())
                .rapportTechniqueId(
                        detail.getRapportTechnique() != null
                                ? detail.getRapportTechnique().getId()
                                : null
                )
                .build();
    }
}
