
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.PaiementDonResponseDTO;
import com.example.dememalibackend.entity.PaiementDon;
import org.springframework.stereotype.Component;

@Component
public class PaiementDonMapper {

    public PaiementDonResponseDTO toDTO(PaiementDon paiement) {

        return PaiementDonResponseDTO.builder()
                .id(paiement.getId())

                .donFinancierId(
                        paiement.getDonFinancier() != null
                                ? paiement.getDonFinancier().getId()
                                : null
                )

                .montant(paiement.getMontant())

                .referenceTransaction(
                        paiement.getReferenceTransaction()
                )

                .datePaiement(paiement.getDatePaiement())

                .dateConfirmation(
                        paiement.getDateConfirmation()
                )

                .statut(paiement.getStatut())

                .build();
    }
}
