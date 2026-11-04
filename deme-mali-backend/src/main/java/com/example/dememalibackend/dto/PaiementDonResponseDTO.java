
package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.StatutPaiement;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class PaiementDonResponseDTO {

    private Integer id;
    private Integer donFinancierId;
    private Double montant;
    private String referenceTransaction;
    private LocalDateTime datePaiement;
    private LocalDateTime dateConfirmation;
    private StatutPaiement statut;
}
