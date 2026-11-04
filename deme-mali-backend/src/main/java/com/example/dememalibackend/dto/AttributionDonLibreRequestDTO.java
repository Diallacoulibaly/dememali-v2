
package com.example.dememalibackend.dto;

import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AttributionDonLibreRequestDTO {

    private Integer donFinancierId;

    private Integer donMaterielId;

    @Positive
    private Double montantAttribue;

    @Positive
    private Integer quantiteAttribuee;

    @NotNull
    private Integer organisationPartenaireId;

    @AssertTrue(message =
            "Il faut choisir un seul type de don : financier ou matériel")
    public boolean isUnSeulDonSelectionne() {
        return (donFinancierId != null && donMaterielId == null)
                || (donFinancierId == null && donMaterielId != null);
    }
}
