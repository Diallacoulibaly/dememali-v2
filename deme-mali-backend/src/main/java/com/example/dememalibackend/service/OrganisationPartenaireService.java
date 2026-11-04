package com.example.dememalibackend.service;



import com.example.dememalibackend.Enum.StatutValidation;
import com.example.dememalibackend.dto.BeneficiaireParticulierRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireParticulierResponseDTO;
import com.example.dememalibackend.dto.OrganisationPartenaireRequestDTO;
import com.example.dememalibackend.dto.OrganisationPartenaireResponseDTO;

import java.util.List;

public interface OrganisationPartenaireService {

    OrganisationPartenaireResponseDTO creer(
            OrganisationPartenaireRequestDTO dto,
            org.springframework.web.multipart.MultipartFile file
    );

    OrganisationPartenaireResponseDTO getById(
            Integer id
    );

    List<OrganisationPartenaireResponseDTO> getAll();

    OrganisationPartenaireResponseDTO modifier(
            Integer id,
            OrganisationPartenaireRequestDTO dto
    );

    OrganisationPartenaireResponseDTO changerStatut(
            Integer id,
            StatutValidation statut);



    BeneficiaireParticulierResponseDTO enregistrerBeneficiaireParticulier(
            Integer organisationId,
            BeneficiaireParticulierRequestDTO dto
    );
    //les likes des donateurs pour l'organisation
    List<OrganisationPartenaireResponseDTO> getAllAvecLikes(
            Integer donateurId
    );

}
