package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.AffectationDonRequestDTO;
import com.example.dememalibackend.dto.AffectationDonResponseDTO;

import java.util.List;

public interface AffectationDonService {

    AffectationDonResponseDTO creer(
            AffectationDonRequestDTO dto,
            Integer organisationPartenaireId
    );

    AffectationDonResponseDTO getById(Integer id);

    List<AffectationDonResponseDTO> getAll();

    List<AffectationDonResponseDTO> getByDon(
            Integer donFinancierId
    );

    List<AffectationDonResponseDTO> getByDemande(
            Integer demandeAideId
    );
    List<AffectationDonResponseDTO> getMesAffectations();

}
