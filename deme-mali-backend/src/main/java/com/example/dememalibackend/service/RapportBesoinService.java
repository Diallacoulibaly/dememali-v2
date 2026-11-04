package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.EtudeTerrainResponseDTO;
import com.example.dememalibackend.dto.RapportBesoinRequestDTO;
import com.example.dememalibackend.dto.RapportBesoinResponseDTO;

import java.util.List;

public interface RapportBesoinService {

    RapportBesoinResponseDTO creer(
            RapportBesoinRequestDTO dto
    );

    RapportBesoinResponseDTO getById(
            Integer id
    );

    List<RapportBesoinResponseDTO> getAll();

    RapportBesoinResponseDTO modifier(
            Integer id,
            RapportBesoinRequestDTO dto
    );

    void supprimer(
            Integer id
    );
    RapportBesoinResponseDTO getByEtudeTerrain(
            Integer EtudeTerrainId
    );

}