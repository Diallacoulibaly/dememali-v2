
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.AffectationDonMaterielResponseDTO;
import com.example.dememalibackend.entity.AffectationDonMateriel;

import org.springframework.stereotype.Component;

@Component
public class AffectationDonMaterielMapper {

    /**
     * Convertit une affectation matérielle en DTO de réponse.
     */
    public AffectationDonMaterielResponseDTO toDTO(
            AffectationDonMateriel affectation) {

        if (affectation == null) {
            return null;
        }

        AffectationDonMaterielResponseDTO dto =
                new AffectationDonMaterielResponseDTO();

        // Identifiant de l'affectation
        dto.setId(affectation.getId());

        // Don matériel
        if (affectation.getDonMateriel() != null) {
            dto.setDonMaterielId(
                    affectation.getDonMateriel().getId()
            );

            dto.setDesignation(
                    affectation.getDonMateriel().getDesignation()
            );
        }

        // Quantité et unité affectées
        dto.setQuantiteAffectee(
                affectation.getQuantiteAffectee()
        );

        dto.setUnite(
                affectation.getUnite()
        );

        // Date d'affectation
        dto.setDateAffectation(
                affectation.getDateAffectation()
        );

        // Demande d'aide
        dto.setDemandeAideId(
                affectation.getDemandeAide() != null
                        ? affectation.getDemandeAide().getId()
                        : null
        );

        // Bénéficiaire
        dto.setBeneficiaireId(
                affectation.getBeneficiaire() != null
                        ? affectation.getBeneficiaire().getId()
                        : null
        );

        // Organisation partenaire
        dto.setOrganisationPartenaireId(
                affectation.getOrganisationPartenaire() != null
                        ? affectation.getOrganisationPartenaire().getId()
                        : null
        );

        return dto;
    }
}
