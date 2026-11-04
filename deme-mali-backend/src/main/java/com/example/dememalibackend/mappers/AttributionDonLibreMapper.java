
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.AttributionDonLibreResponseDTO;
import com.example.dememalibackend.entity.AttributionDonLibre;
import org.springframework.stereotype.Component;

@Component
public class AttributionDonLibreMapper {

    public AttributionDonLibreResponseDTO toDTO(
            AttributionDonLibre attribution) {

        AttributionDonLibreResponseDTO dto =
                new AttributionDonLibreResponseDTO();

        dto.setId(attribution.getId());
        dto.setDateAttribution(attribution.getDateAttribution());
        dto.setMontantAttribue(attribution.getMontantAttribue());
        dto.setQuantiteAttribuee(attribution.getQuantiteAttribuee());
        dto.setScorePriorite(attribution.getScorePriorite());

        if (attribution.getDonFinancier() != null) {
            dto.setDonFinancierId(
                    attribution.getDonFinancier().getId());
            dto.setDesignation("Don financier");
        }

        if (attribution.getDonMateriel() != null) {
            dto.setDonMaterielId(
                    attribution.getDonMateriel().getId());
            dto.setDesignation(
                    attribution.getDonMateriel().getDesignation());
            dto.setUnite(
                    attribution.getDonMateriel().getUnite());
        }

        if (attribution.getOrganisationPartenaire() != null) {
            dto.setOrganisationPartenaireId(
                    attribution.getOrganisationPartenaire().getId());
            dto.setNomOrganisation(
                    attribution.getOrganisationPartenaire()
                            .getNomOrganisation());
        }

        if (attribution.getAdministrateur() != null) {
            dto.setAdministrateurId(
                    attribution.getAdministrateur().getId());
        }

        return dto;
    }
}
