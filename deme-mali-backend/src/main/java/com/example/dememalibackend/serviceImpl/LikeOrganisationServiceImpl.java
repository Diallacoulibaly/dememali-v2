
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutValidation;
import com.example.dememalibackend.dto.OrganisationPartenaireResponseDTO;
import com.example.dememalibackend.entity.Donateur;
import com.example.dememalibackend.entity.LikeOrganisation;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.OrganisationPartenaireMapper;
import com.example.dememalibackend.repository.DonateurRepository;
import com.example.dememalibackend.repository.LikeOrganisationRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.service.LikeOrganisationService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class LikeOrganisationServiceImpl
        implements LikeOrganisationService {

    private final LikeOrganisationRepository likeOrganisationRepository;
    private final DonateurRepository donateurRepository;
    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final OrganisationPartenaireMapper organisationPartenaireMapper;
    private final CustomUserDetailsService customUserDetailsService;

    // Ajouter un like
    @Override
    public void aimerOrganisation(
            Integer donateurId,
            Integer organisationId) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        verifierDonateurConnecte(utilisateur, donateurId);

        Donateur donateur = donateurRepository.findById(donateurId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Donateur introuvable"
                        )
                );

        OrganisationPartenaire organisation =
                organisationPartenaireRepository.findById(organisationId)
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Organisation partenaire introuvable"
                                )
                        );

        if (organisation.getStatutValidation()
                != StatutValidation.VALIDEE) {

            throw new BadRequestException(
                    "Vous ne pouvez aimer qu'une organisation validée"
            );
        }

        // Éviter les likes en double
        boolean dejaAime = likeOrganisationRepository
                .existsByDonateur_IdAndOrganisation_Id(
                        donateurId,
                        organisationId
                );

        if (dejaAime) {
            return;
        }

        LikeOrganisation like = new LikeOrganisation();
        like.setDonateur(donateur);
        like.setOrganisation(organisation);

        likeOrganisationRepository.save(like);
    }

    // Retirer un like
    @Override
    public void retirerLike(
            Integer donateurId,
            Integer organisationId) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        verifierDonateurConnecte(utilisateur, donateurId);

        LikeOrganisation like = likeOrganisationRepository
                .findByDonateur_IdAndOrganisation_Id(
                        donateurId,
                        organisationId
                )
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Ce like n'existe pas"
                        )
                );

        likeOrganisationRepository.delete(like);
    }

    // Récupérer les organisations aimées par un donateur
    @Override
    @Transactional(readOnly = true)
    public List<OrganisationPartenaireResponseDTO>
    getOrganisationsAimees(Integer donateurId) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        // Le donateur consulte uniquement ses propres likes
        if ("DONATEUR".equals(utilisateur.getRole().name())) {

            if (!Objects.equals(utilisateur.getId(), donateurId)) {
                throw new AccessDeniedException(
                        "Vous ne pouvez consulter que vos propres organisations aimées."
                );
            }

        } else if (!"ADMIN".equals(utilisateur.getRole().name())) {

            throw new AccessDeniedException(
                    "Vous n'avez pas accès à cette ressource."
            );
        }

        if (!donateurRepository.existsById(donateurId)) {
            throw new ResourceNotFoundException(
                    "Donateur introuvable"
            );
        }

        return likeOrganisationRepository
                .findByDonateur_Id(donateurId)
                .stream()
                .map(LikeOrganisation::getOrganisation)
                .filter(org -> org.getStatutValidation()
                        == StatutValidation.VALIDEE)
                .map(org -> {
                    OrganisationPartenaireResponseDTO dto =
                            organisationPartenaireMapper
                                    .toResponseDTO(org);

                    dto.setNombreLikes(
                            likeOrganisationRepository
                                    .countByOrganisation_Id(org.getId())
                    );

                    dto.setAimeParMoi(true);

                    return dto;
                })
                .toList();
    }

    // Vérifier que le donateur correspond à l'utilisateur connecté
    private void verifierDonateurConnecte(
            Utilisateur utilisateur,
            Integer donateurId) {

        if (!"DONATEUR".equals(utilisateur.getRole().name())
                || !Objects.equals(utilisateur.getId(), donateurId)) {

            throw new AccessDeniedException(
                    "Vous ne pouvez effectuer cette action qu'avec votre propre compte donateur."
            );
        }
    }
}
