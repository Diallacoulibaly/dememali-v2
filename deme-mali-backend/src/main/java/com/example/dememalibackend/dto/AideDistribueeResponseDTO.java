
package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.StatutDistribution;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
public class AideDistribueeResponseDTO {

    private Integer id;

    private Integer demandeAideId;

    private Integer beneficiaireId;

    private LocalDate dateDistribution;

    private String lieuDistribution;

    private StatutDistribution statut;

    private List<PreuveDistributionResponseDTO> preuves;

    private List<AffectationDonResponseDTO> affectationsFinancieres;

    private List<AffectationDonMaterielResponseDTO> affectationsMaterielles;
}
