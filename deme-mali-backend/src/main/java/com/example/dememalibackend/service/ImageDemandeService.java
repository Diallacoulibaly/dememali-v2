
package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.ImageDemandeResponseDTO;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

public interface ImageDemandeService {

    ImageDemandeResponseDTO creer(
            Integer demandeAideId,
            MultipartFile fichier
    );

    ImageDemandeResponseDTO getById(Integer id);

    List<ImageDemandeResponseDTO> getAll();

    List<ImageDemandeResponseDTO> getByDemande(
            Integer demandeAideId
    );

    ImageDemandeResponseDTO modifierImage(
            Integer id,
            MultipartFile fichier
    );

    void supprimer(Integer id);
}
