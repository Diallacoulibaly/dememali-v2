package com.example.dememalibackend.mappers;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.Enum.TypeBeneficiaire;
import com.example.dememalibackend.dto.BeneficiaireParticulierRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireParticulierResponseDTO;
import com.example.dememalibackend.entity.BeneficiaireParticulier;
import org.springframework.stereotype.Component;

@Component
public class BeneficiaireParticulierMapper {

    public BeneficiaireParticulier toEntity(
            BeneficiaireParticulierRequestDTO dto
    ) {

        BeneficiaireParticulier beneficiaire =
                new BeneficiaireParticulier();

        beneficiaire.setNom(dto.getNom());
        beneficiaire.setPrenom(dto.getPrenom());
        beneficiaire.setTelephone(dto.getTelephone());

        beneficiaire.setVille(dto.getVille());
        beneficiaire.setAdresse(dto.getAdresse());

        beneficiaire.setTypeBeneficiaire(
                TypeBeneficiaire.PARTICULIER
        );

        beneficiaire.setRole(
                RoleEnum.BENEFICIARE
        );

        beneficiaire.setStatut(
                StatutBeneficiaire.EN_ATTENTE
        );

        beneficiaire.setSituationMatrimonial(
                dto.getSituationMatrimonial()
        );

        beneficiaire.setTypeHandicap(
                dto.getTypeHandicap()
        );

        beneficiaire.setNombreEnfants(
                dto.getNombreEnfants()
        );

        beneficiaire.setDateNaissance(
                dto.getDateNaissance()
        );

        beneficiaire.setSexe(
                dto.getSexe()
        );

        beneficiaire.setTypeBeneficiaireParticulier(
                dto.getTypeBeneficiaireParticulier()
        );

        beneficiaire.setDescriptionSituation(
                dto.getDescriptionSituation()
        );

        return beneficiaire;
    }

    public BeneficiaireParticulierResponseDTO toDTO(
            BeneficiaireParticulier beneficiaire
    ) {

        return BeneficiaireParticulierResponseDTO.builder()
                .id(beneficiaire.getId())
                .nom(beneficiaire.getNom())
                .prenom(beneficiaire.getPrenom())
                .telephone(beneficiaire.getTelephone())
                .ville(beneficiaire.getVille())
                .adresse(beneficiaire.getAdresse())
                .typeBeneficiaire(
                        beneficiaire.getTypeBeneficiaire()
                )
                .statut(
                        beneficiaire.getStatut()
                )
                .dateValidation(
                        beneficiaire.getDateValidation()
                )
                .situationMatrimonial(
                        beneficiaire.getSituationMatrimonial()
                )
                .typeHandicap(
                        beneficiaire.getTypeHandicap()
                )
                .nombreEnfants(
                        beneficiaire.getNombreEnfants()
                )
                .dateNaissance(
                        beneficiaire.getDateNaissance()
                )
                .sexe(
                        beneficiaire.getSexe()
                )
                .typeBeneficiaireParticulier(
                        beneficiaire.getTypeBeneficiaireParticulier()
                )
                .descriptionSituation(
                        beneficiaire.getDescriptionSituation()
                )
                .organisationPartenaireId(
                        beneficiaire.getOrganisationPartenaire() != null
                                ? beneficiaire.getOrganisationPartenaire().getId()
                                : null
                )
                .photo(beneficiaire.getPhoto())
                .build();
    }
}