
package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.AttributionDonLibreRequestDTO;
import com.example.dememalibackend.dto.AttributionDonLibreResponseDTO;
import com.example.dememalibackend.dto.OrganisationPrioritaireResponseDTO;

import java.util.List;

public interface AttributionDonLibreService {

    AttributionDonLibreResponseDTO attribuer(
            AttributionDonLibreRequestDTO dto,
            Integer administrateurId
    );

    AttributionDonLibreResponseDTO getById(Integer id);

    List<AttributionDonLibreResponseDTO> getAll();

    List<AttributionDonLibreResponseDTO> getByOrganisation(
            Integer organisationPartenaireId
    );
    OrganisationPrioritaireResponseDTO trouverOrganisationPrioritaire(
            Integer donFinancierId,
            Integer donMaterielId
    );
}
