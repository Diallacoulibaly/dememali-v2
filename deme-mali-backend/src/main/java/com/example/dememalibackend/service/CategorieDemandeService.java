package com.example.dememalibackend.service;




import com.example.dememalibackend.dto.CategorieDemandeRequestDTO;
import com.example.dememalibackend.dto.CategorieDemandeResponseDTO;

import java.util.List;

public interface CategorieDemandeService {

    CategorieDemandeResponseDTO creer(
            CategorieDemandeRequestDTO dto
    );

    CategorieDemandeResponseDTO getById(
            Integer id
    );

    List<CategorieDemandeResponseDTO> getAll();

    CategorieDemandeResponseDTO modifier(
            Integer id,
            CategorieDemandeRequestDTO dto
    );

    void supprimer(Integer id);
}