
package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.EtudeTerrainRequestDTO;
import com.example.dememalibackend.dto.EtudeTerrainResponseDTO;

import java.util.List;

public interface EtudeTerrainService {

    EtudeTerrainResponseDTO creer(EtudeTerrainRequestDTO dto);

    EtudeTerrainResponseDTO getById(Integer id);

    List<EtudeTerrainResponseDTO> getAll();

    EtudeTerrainResponseDTO modifier(
            Integer id,
            EtudeTerrainRequestDTO dto);

    EtudeTerrainResponseDTO planifier(
            Integer id,
            EtudeTerrainRequestDTO dto);

    EtudeTerrainResponseDTO terminer(
            Integer id,
            EtudeTerrainRequestDTO dto);

    EtudeTerrainResponseDTO getByDemande(Integer demandeAideId);
    List<EtudeTerrainResponseDTO> getByOrganisation(
            Integer organisationPartenaireId);
}
