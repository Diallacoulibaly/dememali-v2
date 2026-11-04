package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.ImageDemandeRequestDTO;
import com.example.dememalibackend.dto.ImageDemandeResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.ImageDemande;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class ImageDemandeMapper {

    public ImageDemande toEntity(
            ImageDemandeRequestDTO dto,
            DemandeAide demandeAide) {

        if (dto == null) {
            return null;
        }

        return ImageDemande.builder()
                .nomFichier(dto.getNomFichier())
                .cheminFichier(dto.getCheminFichier())
                .dateAjout(LocalDate.now())
                .demandeAide(demandeAide)
                .build();
    }

    public ImageDemandeResponseDTO toResponseDTO(
            ImageDemande entity) {

        if (entity == null) {
            return null;
        }

        return ImageDemandeResponseDTO.builder()
                .id(entity.getId())
                .nomFichier(entity.getNomFichier())
                .cheminFichier(entity.getCheminFichier())
                .dateAjout(entity.getDateAjout())
                .demandeAideId(
                        entity.getDemandeAide() != null
                                ? entity.getDemandeAide().getId()
                                : null)
                .build();
    }
}
