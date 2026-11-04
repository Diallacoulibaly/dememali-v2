package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.ModePaiement;
import com.example.dememalibackend.Enum.StatutDon;
import com.example.dememalibackend.Enum.TypeDon;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DonFinancierResponseDTO {
    private Integer id;
    private ModePaiement modePaiement;
    private Double montant;
    private LocalDate dateDon;
    private boolean anonyme;
    private TypeDon typeDon;
    private StatutDon statut;
  private Integer donateurId;
    private Integer demandeAideId;
    private String titreDemandeAide;
    private Integer organisationPartenaireId;


}
