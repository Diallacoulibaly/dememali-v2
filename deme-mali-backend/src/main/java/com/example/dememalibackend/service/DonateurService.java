package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.DonateurRequestDTO;
import com.example.dememalibackend.dto.DonateurResponseDTO;

import java.util.List;

public interface DonateurService {

    DonateurResponseDTO creer(
            DonateurRequestDTO dto
    );

    DonateurResponseDTO getById(
            Integer id
    );

    List<DonateurResponseDTO> getAll();

    DonateurResponseDTO modifierPays(
            Integer id,
            Integer paysId
    );

    List<DonateurResponseDTO> getByPays(
            Integer paysId
    );
}