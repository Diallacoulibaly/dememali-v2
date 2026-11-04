package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.ModePaiement;
import com.example.dememalibackend.Enum.TypeDon;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DonFinancierRequestDTO {

    private Double montant;

    private ModePaiement modePaiement;


    private boolean anonyme;

    private Integer donateurId;

    private Integer demandeAideId;
    private Integer organisationPartenaireId;
}