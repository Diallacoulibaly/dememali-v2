package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.TypeJustificatifRequestDTO;
import com.example.dememalibackend.dto.TypeJustificatifResponseDTO;
import com.example.dememalibackend.entity.TypeJustificatif;
import org.springframework.stereotype.Component;

@Component
public class TypeJustificatifMapper {

    public TypeJustificatif toEntity(TypeJustificatifRequestDTO dto) {
        if (dto == null) {
            return null;
        }

        return TypeJustificatif.builder()
                .nom(dto.getNom())
                .build();
    }

    public TypeJustificatifResponseDTO toResponseDTO(TypeJustificatif entity) {
        if (entity == null) {
            return null;
        }

        return TypeJustificatifResponseDTO.builder()
                .id(entity.getId())
                .nom(entity.getNom())
                .build();
    }
}
