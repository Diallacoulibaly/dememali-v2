package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.BeneficiaireParticulierRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireParticulierResponseDTO;

import java.util.List;

public interface BeneficiaireParticulierService {

    BeneficiaireParticulierResponseDTO creer(
            BeneficiaireParticulierRequestDTO dto
    );

    BeneficiaireParticulierResponseDTO getById(
            Integer id
    );

    List<BeneficiaireParticulierResponseDTO> getAll();

    BeneficiaireParticulierResponseDTO modifier(
            Integer id,
            BeneficiaireParticulierRequestDTO dto
    );
}