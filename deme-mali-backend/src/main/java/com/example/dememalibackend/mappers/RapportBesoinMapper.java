package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.RapportBesoinRequestDTO;
import com.example.dememalibackend.dto.RapportBesoinResponseDTO;
import com.example.dememalibackend.entity.EtudeTerrain;
import com.example.dememalibackend.entity.RapportBesoin;
import org.springframework.stereotype.Component;

@Component
public class RapportBesoinMapper {

    public RapportBesoin toEntity(
            RapportBesoinRequestDTO dto,
            EtudeTerrain etudeTerrain) {

        if (dto == null) {
            return null;
        }

        RapportBesoin rapportBesoin = new RapportBesoin();

        rapportBesoin.setTitre(dto.getTitre());

        rapportBesoin.setBesoinIdentifie(
                dto.getBesoinIdentifie()
        );

        rapportBesoin.setDescriptionSituation(
                dto.getDescriptionSituation()
        );

        rapportBesoin.setSolutionProposee(
                dto.getSolutionProposee()
        );

        rapportBesoin.setMontantEstime(
                dto.getMontantEstime()
        );

        rapportBesoin.setEtudeTerrain(
                etudeTerrain
        );

        return rapportBesoin;
    }


    public RapportBesoinResponseDTO toDTO(
            RapportBesoin rapportBesoin) {

        if (rapportBesoin == null) {
            return null;
        }

        RapportBesoinResponseDTO dto =
                new RapportBesoinResponseDTO();

        dto.setId(rapportBesoin.getId());

        dto.setTitre(
                rapportBesoin.getTitre()
        );

        dto.setBesoinIdentifie(
                rapportBesoin.getBesoinIdentifie()
        );

        dto.setDescriptionSituation(
                rapportBesoin.getDescriptionSituation()
        );

        dto.setSolutionProposee(
                rapportBesoin.getSolutionProposee()
        );

        dto.setMontantEstime(
                rapportBesoin.getMontantEstime()
        );

        dto.setDateCreation(
                rapportBesoin.getDateCreation()
        );

        if (rapportBesoin.getEtudeTerrain() != null) {

            dto.setEtudeTerrainId(
                    rapportBesoin
                            .getEtudeTerrain()
                            .getId()
            );
        }

        if (rapportBesoin.getRapportTechnique() != null) {

            dto.setRapportTechniqueId(
                    rapportBesoin
                            .getRapportTechnique()
                            .getId()
            );
        }
        if (rapportBesoin.getEtudeTerrain() != null
                && rapportBesoin.getEtudeTerrain().getDemandeAide() != null) {

            dto.setStatutDemande(
                    rapportBesoin.getEtudeTerrain()
                            .getDemandeAide()
                            .getStatut()
            );
        }

        return dto;
    }
}