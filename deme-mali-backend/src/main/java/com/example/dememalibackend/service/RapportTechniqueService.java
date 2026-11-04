package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.EtudeTerrainResponseDTO;
import com.example.dememalibackend.dto.RapportTechniqueRequestDTO;
import com.example.dememalibackend.dto.RapportTechniqueResponseDTO;

import java.util.List;

public interface RapportTechniqueService {

    RapportTechniqueResponseDTO creer(
            RapportTechniqueRequestDTO dto
    );

    RapportTechniqueResponseDTO getById(
            Integer id
    );

    List<RapportTechniqueResponseDTO> getAll();

    RapportTechniqueResponseDTO modifier(
            Integer id,
            RapportTechniqueRequestDTO dto
    );

    void supprimer(
            Integer id
    );
    RapportTechniqueResponseDTO getByRapportBesoin(
            Integer rapportBesoinId
    );

}