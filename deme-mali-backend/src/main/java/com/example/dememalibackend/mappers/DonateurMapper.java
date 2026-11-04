package com.example.dememalibackend.mappers;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.DonateurRequestDTO;
import com.example.dememalibackend.dto.DonateurResponseDTO;
import com.example.dememalibackend.entity.Donateur;
import org.springframework.stereotype.Component;

@Component
public class DonateurMapper {

    public Donateur toEntity(DonateurRequestDTO dto) {

        if (dto == null) {
            return null;
        }

        Donateur donateur = new Donateur();

        donateur.setNom(dto.getNom());
        donateur.setPrenom(dto.getPrenom());
        donateur.setTelephone(dto.getTelephone());
        donateur.setMotDePasse(dto.getMotDePasse());
        donateur.setSexe(dto.getSexe());
        donateur.setRole(RoleEnum.DONATEUR);

        return donateur;
    }

    public DonateurResponseDTO toResponseDTO(Donateur entity) {

        if (entity == null) {
            return null;
        }

        return DonateurResponseDTO.builder()
                .id(entity.getId())
                .nom(entity.getNom())
                .prenom(entity.getPrenom())
                .telephone(entity.getTelephone())
                .sexe(entity.getSexe())
                .paysId(
                        entity.getPays() != null
                                ? entity.getPays().getId()
                                : null
                )
                .paysNom(
                        entity.getPays() != null
                                ? entity.getPays().getNom()
                                : null
                )
                .photo(entity.getPhoto())
                .build();
    }
}