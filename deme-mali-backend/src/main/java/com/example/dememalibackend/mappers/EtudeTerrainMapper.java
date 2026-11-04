package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.EtudeTerrainResponseDTO;
import com.example.dememalibackend.entity.EtudeTerrain;
import org.springframework.stereotype.Component;

@Component
public class EtudeTerrainMapper {

    public EtudeTerrainResponseDTO toDTO(
            EtudeTerrain etude) {

        return EtudeTerrainResponseDTO.builder()
                .id(etude.getId())
                .dateRealisation(etude.getDateRealisation())
                .datePlanification(etude.getDatePlanification())
                .lieu(etude.getLieu())
                .objectif(etude.getObjectif())
                .observation(etude.getObservation())
                .resultat(etude.getResultat())
                .heure(etude.getHeure())
                .status(etude.getStatus())
                .demandeAideId(
                        etude.getDemandeAide().getId()
                )
                .organisationPartenaireId(
                        etude.getOrganisationPartenaire().getId()
                )
                .build();
    }
}
