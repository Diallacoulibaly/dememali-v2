package com.example.dememalibackend.mappers;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.Enum.TypeBeneficiaire;
import com.example.dememalibackend.dto.BeneficiaireStructureRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireStructureResponseDTO;
import com.example.dememalibackend.entity.BeneficiaireStructure;
import org.springframework.stereotype.Component;

@Component
public class BeneficiaireStructureMapper {

    public BeneficiaireStructure toEntity(
            BeneficiaireStructureRequestDTO dto
    ) {

        BeneficiaireStructure beneficiaire =
                new BeneficiaireStructure();

        beneficiaire.setNom(dto.getNom());
        beneficiaire.setPrenom(dto.getPrenom());
        beneficiaire.setTelephone(dto.getTelephone());

        beneficiaire.setVille(dto.getVille());
        beneficiaire.setAdresse(dto.getAdresse());

        beneficiaire.setRole(
                RoleEnum.BENEFICIARE
        );

        beneficiaire.setTypeBeneficiaire(
                TypeBeneficiaire.STRUCTURE
        );

        beneficiaire.setStatut(
                StatutBeneficiaire.EN_ATTENTE
        );

        beneficiaire.setDateValidation(null);
        beneficiaire.setMotifRefus(null);

        beneficiaire.setNina(dto.getNina());
        beneficiaire.setNif(dto.getNif());
        beneficiaire.setEmail(dto.getEmail());
        beneficiaire.setNomStructure(dto.getNomStructure());
        beneficiaire.setDocumentJustificatif(
                dto.getDocumentJustificatif()
        );

        return beneficiaire;
    }

    public BeneficiaireStructureResponseDTO toDTO(
            BeneficiaireStructure beneficiaire
    ) {

        return BeneficiaireStructureResponseDTO.builder()
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
                .nina(
                        beneficiaire.getNina()
                )
                .nif(
                        beneficiaire.getNif()
                )
                .email(
                        beneficiaire.getEmail()
                )
                .nomStructure(
                        beneficiaire.getNomStructure()
                )
                .documentJustificatif(
                        beneficiaire.getDocumentJustificatif()
                )
                .organisationPartenaireId(
                        beneficiaire.getOrganisationPartenaire() != null
                                ? beneficiaire
                                  .getOrganisationPartenaire()
                                  .getId()
                                : null
                )
                .photo(beneficiaire.getPhoto())
                .build();
    }
}