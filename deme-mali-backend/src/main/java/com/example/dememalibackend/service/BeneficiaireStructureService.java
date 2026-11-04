package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.BeneficiaireStructureRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireStructureResponseDTO;

import java.util.List;

public interface BeneficiaireStructureService {

    BeneficiaireStructureResponseDTO creer(
            BeneficiaireStructureRequestDTO dto
    );

    BeneficiaireStructureResponseDTO getById(
            Integer id
    );

    List<BeneficiaireStructureResponseDTO> getAll();

    BeneficiaireStructureResponseDTO modifier(
            Integer id,
            BeneficiaireStructureRequestDTO dto
    );
}