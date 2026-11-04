package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.TypeJustificatifRequestDTO;
import com.example.dememalibackend.dto.TypeJustificatifResponseDTO;

import java.util.List;

public interface TypeJustificatifService {

    TypeJustificatifResponseDTO creer(TypeJustificatifRequestDTO dto);

    TypeJustificatifResponseDTO getById(Integer id);

    List<TypeJustificatifResponseDTO> getAll();

    TypeJustificatifResponseDTO modifier(
            Integer id,
            TypeJustificatifRequestDTO dto);
}
