
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.AffectationDonResponseDTO;
import com.example.dememalibackend.entity.AffectationDon;

import org.springframework.stereotype.Component;

@Component
public class AffectationDonMapper {

    /**
     * Convertit une affectation financière en DTO de réponse.
     */
    public AffectationDonResponseDTO toDTO(AffectationDon affectation) {

        if (affectation == null) {
            return null;
        }

        AffectationDonResponseDTO dto =
                new AffectationDonResponseDTO();

        dto.setId(affectation.getId());

        // Don financier
        dto.setDonFinancierId(
                affectation.getDonFinancier() != null
                        ? affectation.getDonFinancier().getId()
                        : null
        );

        // Montant affecté
        dto.setMontantAffecte(
                affectation.getMontantAffecte()
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
