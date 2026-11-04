
package com.example.dememalibackend.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AffectationDonMaterielRequestDTO {

    @NotNull
    private Integer donMaterielId;

    private Integer demandeAideId;

    private Integer beneficiaireId;

    @NotNull
    @Positive
    private Integer quantiteAffectee;
    @NotNull
    private Integer uninte;

    @NotNull
    private Integer organisationPartenaireId;
}
