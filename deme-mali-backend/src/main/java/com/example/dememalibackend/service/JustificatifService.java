package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.JustificatifRequestDTO;
import com.example.dememalibackend.dto.JustificatifResponseDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface JustificatifService {

    List<JustificatifResponseDTO> creer(
            JustificatifRequestDTO dto,
            List<MultipartFile> fichiers);
    JustificatifResponseDTO getById(Integer id);

    List<JustificatifResponseDTO> getAll();

    List<JustificatifResponseDTO> getByDemande(
            Integer demandeAideId);

    JustificatifResponseDTO modifier(
            Integer id,
            JustificatifRequestDTO dto);

    void supprimer(Integer id);

}