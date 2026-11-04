
package com.example.dememalibackend.dto;

import lombok.Getter;
import lombok.Setter;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OrganisationPrioritaireResponseDTO {

    private Integer organisationPartenaireId;

    private String nomOrganisation;

    private double scorePriorite;
}
