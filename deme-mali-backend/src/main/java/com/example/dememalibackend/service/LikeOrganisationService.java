
package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.OrganisationPartenaireResponseDTO;

import java.util.List;

public interface LikeOrganisationService {

    // Aimer une organisation
    void aimerOrganisation(
            Integer donateurId,
            Integer organisationId
    );

    // Retirer un like
    void retirerLike(
            Integer donateurId,
            Integer organisationId
    );

    // Récupérer les organisations aimées par un donateur
    List<OrganisationPartenaireResponseDTO> getOrganisationsAimees(
            Integer donateurId
    );
}
