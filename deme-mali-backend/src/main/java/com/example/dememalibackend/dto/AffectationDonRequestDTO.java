
package com.example.dememalibackend.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AffectationDonRequestDTO {

    @NotNull
    private Integer donFinancierId;

    private Integer demandeAideId;

    private Integer beneficiaireId;

    @NotNull
    @Positive
    private Double montantAffecte;

    @NotNull
    private Integer organisationPartenaireId;
}
