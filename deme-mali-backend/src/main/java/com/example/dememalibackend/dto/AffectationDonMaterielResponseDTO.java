
package com.example.dememalibackend.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class AffectationDonMaterielResponseDTO {

    private Integer id;

    private Integer donMaterielId;
    private String designation;

    private Integer quantiteAffectee;
    private String unite;

    private LocalDate dateAffectation;

    private Integer demandeAideId;
    private Integer beneficiaireId;

    private Integer organisationPartenaireId;
}
