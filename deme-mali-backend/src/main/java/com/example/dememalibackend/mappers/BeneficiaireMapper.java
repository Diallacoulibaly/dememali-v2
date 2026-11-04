
        package com.example.dememalibackend.mappers;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.dto.BeneficiaireRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireResponseDTO;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.OrganisationPartenaire;

public class BeneficiaireMapper {

    public static Beneficiaire toEntity(
            BeneficiaireRequestDTO dto,
            OrganisationPartenaire organisation) {

        Beneficiaire beneficiaire = new Beneficiaire();

        beneficiaire.setNom(
                dto.getNom()
        );

        beneficiaire.setPrenom(
                dto.getPrenom()
        );

        beneficiaire.setTelephone(
                dto.getTelephone()
        );

        beneficiaire.setRole(
                RoleEnum.BENEFICIARE
        );

        beneficiaire.setTypeBeneficiaire(
                dto.getTypeBeneficiaire()
        );

        beneficiaire.setVille(
                dto.getVille()
        );

        beneficiaire.setAdresse(
                dto.getAdresse()
        );

        beneficiaire.setOrganisationPartenaire(
                organisation
        );

        beneficiaire.setStatut(
                StatutBeneficiaire.EN_ATTENTE
        );

        beneficiaire.setDateValidation(null);

        return beneficiaire;
    }

    public static BeneficiaireResponseDTO toDTO(
            Beneficiaire beneficiaire) {

        BeneficiaireResponseDTO dto =
                new BeneficiaireResponseDTO();

        dto.setId(
                beneficiaire.getId()
        );

        dto.setNom(
                beneficiaire.getNom()
        );

        dto.setPrenom(
                beneficiaire.getPrenom()
        );

        dto.setTypeBeneficiaire(
                beneficiaire.getTypeBeneficiaire()
        );

        dto.setVille(
                beneficiaire.getVille()
        );

        dto.setAdresse(
                beneficiaire.getAdresse()
        );

        dto.setStatut(
                beneficiaire.getStatut()
        );

        dto.setDateValidation(
                beneficiaire.getDateValidation()
        );

        if (beneficiaire.getOrganisationPartenaire() != null) {

            dto.setOrganisationPartenaireId(
                    beneficiaire
                            .getOrganisationPartenaire()
                            .getId()
            );
        }

        dto.setPhoto(beneficiaire.getPhoto());

        return dto;
    }
}
