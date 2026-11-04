package com.example.dememalibackend.dto;

import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AffectationDonResponseDTO {

    private Integer id;

    private Double montantAffecte;

    private LocalDate dateAffectation;

    private Integer donFinancierId;

    private Integer demandeAideId;

    private Integer aideDistribueeId;
    private Integer beneficiaireId;
    private Integer organisationPartenaireId;

}