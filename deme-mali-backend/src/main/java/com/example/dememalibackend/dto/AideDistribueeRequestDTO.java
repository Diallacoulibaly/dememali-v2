
package com.example.dememalibackend.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class AideDistribueeRequestDTO {

    private Integer demandeAideId;

    private Integer beneficiaireId;

    private LocalDate dateDistribution;

    @NotBlank
    private String lieuDistribution;

    @Valid
    private List<PreuveDistributionRequestDTO> preuves =
            new ArrayList<>();
}
