
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.PreuveDistributionRequestDTO;
import com.example.dememalibackend.dto.PreuveDistributionResponseDTO;
import com.example.dememalibackend.entity.AideDistribuee;
import com.example.dememalibackend.entity.PreuveDistribution;

public final class PreuveDistributionMapper {

    private PreuveDistributionMapper() {
    }

    public static PreuveDistribution toEntity(
            PreuveDistributionRequestDTO dto,
            AideDistribuee aideDistribuee) {

        PreuveDistribution preuve = new PreuveDistribution();
        preuve.setAideDistribuee(aideDistribuee);
        preuve.setNomFichier(dto.getNomFichier());
        preuve.setUrlFichier(dto.getUrlFichier());
        preuve.setTypeMedia(dto.getTypeMedia());

        return preuve;
    }

    public static PreuveDistributionResponseDTO toResponseDTO(
            PreuveDistribution preuve) {

        PreuveDistributionResponseDTO dto =
                new PreuveDistributionResponseDTO();

        dto.setId(preuve.getId());
        dto.setNomFichier(preuve.getNomFichier());
        dto.setUrlFichier(preuve.getUrlFichier());
        dto.setTypeMedia(preuve.getTypeMedia());

        return dto;
    }
}
