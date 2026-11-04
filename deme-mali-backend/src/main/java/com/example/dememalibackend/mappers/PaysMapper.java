package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.PaysRequestDto;
import com.example.dememalibackend.dto.PaysResponseDto;
import com.example.dememalibackend.entity.Pays;
import org.springframework.stereotype.Component;

@Component
public class PaysMapper {

    public Pays toEntity(PaysRequestDto dto) {

        if (dto == null) {
            return null;
        }

        Pays pays = new Pays();

        pays.setNom(dto.getNom());

        return pays;
    }

    public PaysResponseDto toResponseDTO(Pays entity) {

        if (entity == null) {
            return null;
        }

        PaysResponseDto dto = new PaysResponseDto();

        dto.setId(entity.getId());
        dto.setNom(entity.getNom());

        return dto;
    }
}