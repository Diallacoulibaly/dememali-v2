package com.example.dememalibackend.service;


import com.example.dememalibackend.dto.BeneficiaireRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireResponseDTO;

import java.util.List;

public interface BeneficiaireService {

    BeneficiaireResponseDTO creer(
            BeneficiaireRequestDTO dto
    );

    BeneficiaireResponseDTO trouverParId(
            Integer id
    );

    List<BeneficiaireResponseDTO> trouverTous();

    List<BeneficiaireResponseDTO> trouverEnAttente();

    List<BeneficiaireResponseDTO> trouverParOrganisation(
            Integer organisationId
    );

    BeneficiaireResponseDTO accepter(
            Integer beneficiaireId
    );

    BeneficiaireResponseDTO refuser(
            Integer beneficiaireId,
            String motif
    );
    List<BeneficiaireResponseDTO> trouverAcceptesParOrganisation(
            Integer organisationId
    );
}