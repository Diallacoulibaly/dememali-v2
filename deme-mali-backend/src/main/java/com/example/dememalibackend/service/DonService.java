package com.example.dememalibackend.service;


import com.example.dememalibackend.Enum.StatutDon;
import com.example.dememalibackend.dto.DonRequestDTO;
import com.example.dememalibackend.dto.DonResponseDTO;

import java.util.List;

public interface DonService {

    DonResponseDTO creer(DonRequestDTO dto);

    DonResponseDTO getById(Integer id);

    List<DonResponseDTO> getAll();

    List<DonResponseDTO> getByDonateur(Integer donateurId);

    List<DonResponseDTO> getByDemande(Integer demandeAideId);

}
