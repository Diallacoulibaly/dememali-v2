
package com.example.dememalibackend.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class AttributionDonLibreResponseDTO {

    private Integer id;

    private Integer donFinancierId;
    private Integer donMaterielId;

    private String designation;
    private Double montantAttribue;
    private Integer quantiteAttribuee;
    private String unite;

    private Integer organisationPartenaireId;
    private String nomOrganisation;

    private Integer administrateurId;

    private Double scorePriorite;

    private LocalDate dateAttribution;
}
