
        package com.example.dememalibackend.mappers;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.OrganisationPartenaireRequestDTO;
import com.example.dememalibackend.dto.OrganisationPartenaireResponseDTO;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import org.springframework.stereotype.Component;

@Component
public class OrganisationPartenaireMapper {

    public OrganisationPartenaire toEntity(
            OrganisationPartenaireRequestDTO dto) {

        if (dto == null) {
            return null;
        }

        OrganisationPartenaire organisation =
                new OrganisationPartenaire();

        organisation.setNom(dto.getNom());
        organisation.setPrenom(dto.getPrenom());
        organisation.setTelephone(dto.getTelephone());

        organisation.setRole(
                RoleEnum.ORGANISATIONPARTENAIRE
        );

        organisation.setNomOrganisation(
                dto.getNomOrganisation()
        );

        organisation.setTypeOrganisation(
                dto.getTypeOrganisation()
        );

        organisation.setNif(dto.getNif());
        organisation.setAdresse(dto.getAdresse());
        organisation.setVille(dto.getVille());

        organisation.setDocumentJustificatif(
                dto.getDocumentJustificatif()
        );

        organisation.setEmail(dto.getEmail());

        organisation.setTelephoneOrganisation(
                dto.getTelephoneOrganisation()
        );

        organisation.setDescription(dto.getDescription());

        return organisation;
    }


    public OrganisationPartenaireResponseDTO toResponseDTO(
            OrganisationPartenaire organisation) {

        if (organisation == null) {
            return null;
        }

        return OrganisationPartenaireResponseDTO.builder()
                .id(organisation.getId())
                .nom(organisation.getNom())
                .prenom(organisation.getPrenom())
                .telephone(organisation.getTelephone())
                .role(organisation.getRole())
                .nomOrganisation(organisation.getNomOrganisation())
                .typeOrganisation(organisation.getTypeOrganisation())

                //.photo(organisation.getPhoto())
                .description(organisation.getDescription())
                .nomOrganisation(
                        organisation.getNomOrganisation()
                )
                .typeOrganisation(
                        organisation.getTypeOrganisation()
                )

                .nif(organisation.getNif())
                .adresse(organisation.getAdresse())
                .ville(organisation.getVille())
                .documentJustificatif(organisation.getDocumentJustificatif())
                .dateInscription(organisation.getDateInscription())
                .statutValidation(organisation.getStatutValidation())
                .dateValidation(organisation.getDateValidation())
                .email(organisation.getEmail())
                .telephoneOrganisation(organisation.getTelephoneOrganisation())
                .nombreLikes(0)
                .aimeParMoi(false)
                .build();
    }

}
