package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.DonRequestDTO;
import com.example.dememalibackend.dto.DonResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.Don;
import com.example.dememalibackend.entity.Donateur;
import org.springframework.stereotype.Component;

@Component
public class DonMapper {

    public Don toEntity(
            DonRequestDTO dto,
            Donateur donateur,
            DemandeAide demandeAide
    ) {

        if (dto == null) {
            return null;
        }

        Don don = new Don();

        don.setDateDon(dto.getDateDon());
        don.setTypeDon(dto.getTypeDon());
        don.setAnonyme(dto.isAnonyme());

        don.setDonateur(donateur);
        don.setDemandeAide(demandeAide);

        return don;
    }

    public DonResponseDTO toResponseDTO(Don don) {

        if (don == null) {
            return null;
        }

        DonResponseDTO dto = new DonResponseDTO();

        dto.setId(don.getId());
        dto.setDateDon(don.getDateDon());
        dto.setTypeDon(don.getTypeDon());
        dto.setAnonyme(don.isAnonyme());

        if (don.getDonateur() != null) {
            dto.setDonateurId(
                    don.getDonateur().getId()
            );
        }

        if (don.getDemandeAide() != null) {
            dto.setDemandeAideId(
                    don.getDemandeAide().getId()
            );
        }

        return dto;
    }
}