package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.JustificatifRequestDTO;
import com.example.dememalibackend.dto.JustificatifResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.Justificatif;
import com.example.dememalibackend.entity.TypeJustificatif;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class JustificatifMapper {

    public Justificatif toEntity(
            JustificatifRequestDTO dto,
            TypeJustificatif typeJustificatif,
            DemandeAide demandeAide) {

        if (dto == null) {
            return null;
        }

        return Justificatif.builder()
                .nomFichier(dto.getNomFichier())
                .cheminFichier(dto.getCheminFichier())
                .dateAjout(LocalDate.now())
                .typeJustificatif(typeJustificatif)
                .demandeAide(demandeAide)
                .build();
    }

    public JustificatifResponseDTO toResponseDTO(
            Justificatif entity) {

        if (entity == null) {
            return null;
        }

        return JustificatifResponseDTO.builder()
                .id(entity.getId())
                .nomFichier(entity.getNomFichier())
                .cheminFichier(entity.getCheminFichier())
                .dateAjout(entity.getDateAjout())
                .typeJustificatifId(
                        entity.getTypeJustificatif() != null
                                ? entity.getTypeJustificatif().getId()
                                : null)
                .demandeAideId(
                        entity.getDemandeAide() != null
                                ? entity.getDemandeAide().getId()
                                : null)
                .build();
    }
}
