
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.Enum.StatutValidation;
import com.example.dememalibackend.Enum.TypeBeneficiaire;

import com.example.dememalibackend.dto.BeneficiaireParticulierRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireParticulierResponseDTO;
import com.example.dememalibackend.dto.OrganisationPartenaireRequestDTO;
import com.example.dememalibackend.dto.OrganisationPartenaireResponseDTO;

import com.example.dememalibackend.entity.BeneficiaireParticulier;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;

import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;

import com.example.dememalibackend.mappers.BeneficiaireParticulierMapper;
import com.example.dememalibackend.mappers.OrganisationPartenaireMapper;

import com.example.dememalibackend.repository.BeneficiairePartenaireRepository;
import com.example.dememalibackend.repository.LikeOrganisationRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.repository.UtilisateurRepository;

import com.example.dememalibackend.service.OrganisationPartenaireService;
import com.example.dememalibackend.service.UtilisateurService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class OrganisationPartenaireServiceImpl
        implements OrganisationPartenaireService {

    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final OrganisationPartenaireMapper organisationPartenaireMapper;
    private final BeneficiairePartenaireRepository beneficiaireParticulierRepository;
    private final BeneficiaireParticulierMapper beneficiaireParticulierMapper;
    private final UtilisateurService utilisateurService;
    private final PasswordEncoder passwordEncoder;
    private final LikeOrganisationRepository likeOrganisationRepository;
    private final CustomUserDetailsService customUserDetailsService;
    private final UtilisateurRepository utilisateurRepository;

    // Créer une organisation partenaire
    @Override
    public OrganisationPartenaireResponseDTO creer(
            OrganisationPartenaireRequestDTO dto,
            org.springframework.web.multipart.MultipartFile file) {

      

        if (dto.getMotDePasse() == null
                || dto.getMotDePasse().isBlank()) {

            throw new BadRequestException(
                    "Le mot de passe est obligatoire"
            );
        }

        if (dto.getTelephone() == null || dto.getTelephone().isBlank()) {
            throw new BadRequestException("Le numéro de téléphone est obligatoire");
        }
        dto.setTelephone(dto.getTelephone().trim());
        if (utilisateurRepository.existsByTelephone(dto.getTelephone())) {
            throw new BadRequestException("Ce numéro de téléphone est déjà utilisé.");
        }

        if (dto.getNif() != null
                && organisationPartenaireRepository.existsByNif(dto.getNif())) {

            throw new BadRequestException(
                    "Une organisation avec ce NIF existe déjà"
            );
        }

        if (dto.getEmail() != null
                && organisationPartenaireRepository.existsByEmail(dto.getEmail())) {

            throw new BadRequestException(
                    "Une organisation avec cet email existe déjà"
            );
        }

        if (file != null && !file.isEmpty()) {
            try {
                String uploadDir = "uploads/justificatifs-organisations/";
                java.nio.file.Path uploadPath =
                        java.nio.file.Paths.get(uploadDir);

                if (!java.nio.file.Files.exists(uploadPath)) {
                    java.nio.file.Files.createDirectories(uploadPath);
                }

                String originalFilename = file.getOriginalFilename();
                String extension = "";

                if (originalFilename != null
                        && originalFilename.contains(".")) {

                    extension = originalFilename.substring(
                            originalFilename.lastIndexOf(".")
                    );
                }

                String nomOrgaSafe =
                        dto.getNomOrganisation() != null
                                ? dto.getNomOrganisation()
                                    .replaceAll("[^a-zA-Z0-9_-]", "_")
                                : "orga";

                String fileName = nomOrgaSafe
                        + "_"
                        + System.currentTimeMillis()
                        + extension;

                java.nio.file.Path filePath =
                        uploadPath.resolve(fileName);

                java.nio.file.Files.copy(
                        file.getInputStream(),
                        filePath,
                        java.nio.file.StandardCopyOption.REPLACE_EXISTING
                );

                dto.setDocumentJustificatif(filePath.toString());

            } catch (java.io.IOException e) {
                throw new BadRequestException(
                        "Erreur lors de l'enregistrement du fichier justificatif"
                );
            }
        }

        OrganisationPartenaire organisation =
                organisationPartenaireMapper.toEntity(dto);

        organisation.setRole(
                RoleEnum.ORGANISATIONPARTENAIRE
        );

        organisation.setMotDePasse(
                passwordEncoder.encode(dto.getMotDePasse())
        );

        organisation.setDateInscription(
                LocalDate.now()
        );

        organisation.setStatutValidation(
                StatutValidation.EN_ATTENTE
        );

        OrganisationPartenaire saved =
                organisationPartenaireRepository.save(organisation);

        return organisationPartenaireMapper.toResponseDTO(saved);
    }

    // Consulter une organisation par son identifiant
    @Override
    @Transactional(readOnly = true)
    public OrganisationPartenaireResponseDTO getById(Integer id) {

        OrganisationPartenaire organisation = getEntity(id);

        return organisationPartenaireMapper.toResponseDTO(organisation);
    }

    // Consulter toutes les organisations
    @Override
    @Transactional(readOnly = true)
    public List<OrganisationPartenaireResponseDTO> getAll() {

        return organisationPartenaireRepository
                .findAll()
                .stream()
                .map(organisationPartenaireMapper::toResponseDTO)
                .toList();
    }

    // Consulter les organisations validées avec leurs likes
    @Override
    @Transactional(readOnly = true)
    public List<OrganisationPartenaireResponseDTO> getAllAvecLikes(
            Integer donateurId) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() == RoleEnum.DONATEUR) {

            if (donateurId != null
                    && !Objects.equals(utilisateur.getId(), donateurId)) {

                throw new AccessDeniedException(
                        "Vous ne pouvez consulter les likes qu'avec votre propre compte donateur."
                );
            }

            // Utiliser automatiquement l'identifiant du donateur connecté
            donateurId = utilisateur.getId();

        } else if (utilisateur.getRole() != RoleEnum.ADMIN) {

            throw new AccessDeniedException(
                    "Vous n'avez pas accès à cette ressource."
            );
        }

        final Integer idDonateur = donateurId;

        return organisationPartenaireRepository.findAll()
                .stream()
                .filter(org -> org.getStatutValidation()
                        == StatutValidation.VALIDEE)
                .map(org -> enrichirAvecLikes(org, idDonateur))
                .toList();
    }

    // Ajouter le nombre de likes et l'état du like du donateur
    private OrganisationPartenaireResponseDTO enrichirAvecLikes(
            OrganisationPartenaire organisation,
            Integer donateurId) {

        OrganisationPartenaireResponseDTO dto =
                organisationPartenaireMapper.toResponseDTO(organisation);

        dto.setNombreLikes(
                likeOrganisationRepository.countByOrganisation_Id(
                        organisation.getId()
                )
        );

        dto.setAimeParMoi(
                donateurId != null
                        && likeOrganisationRepository
                        .existsByDonateur_IdAndOrganisation_Id(
                                donateurId,
                                organisation.getId()
                        )
        );

        return dto;
    }

    // Modifier une organisation
    @Override
    public OrganisationPartenaireResponseDTO modifier(
            Integer id,
            OrganisationPartenaireRequestDTO dto) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        verifierOrganisationConnectee(utilisateur, id);

        OrganisationPartenaire organisation = getEntity(id);

        // Vérifier le numéro de téléphone
        if (dto.getTelephone() == null
                || dto.getTelephone().isBlank()) {

            throw new BadRequestException(
                    "Le numéro de téléphone est obligatoire."
            );
        }

        if (!dto.getTelephone().equals(organisation.getTelephone())
                && utilisateurService.existsByTelephoneAndIdNot(
                        dto.getTelephone(), id)) {

            throw new BadRequestException(
                    "Ce numéro de téléphone est déjà utilisé."
            );
        }

        // Vérifier l'email
        if (dto.getEmail() != null
                && !dto.getEmail().equals(organisation.getEmail())
                && organisationPartenaireRepository.existsByEmail(
                        dto.getEmail())) {

            throw new BadRequestException(
                    "Cet email est déjà utilisé par une autre organisation."
            );
        }

        // Modifier les informations personnelles
        organisation.setNom(dto.getNom());
        organisation.setPrenom(dto.getPrenom());
        organisation.setTelephone(dto.getTelephone());

        // Modifier les informations de l'organisation
        organisation.setNomOrganisation(dto.getNomOrganisation());
        organisation.setAdresse(dto.getAdresse());
        organisation.setVille(dto.getVille());
        organisation.setDocumentJustificatif(
                dto.getDocumentJustificatif()
        );
        organisation.setEmail(dto.getEmail());
        organisation.setTelephoneOrganisation(
                dto.getTelephoneOrganisation()
        );

        if (dto.getDescription() != null) {
            organisation.setDescription(dto.getDescription());
        }

        // Modifier le mot de passe uniquement s'il est renseigné
        if (dto.getMotDePasse() != null
                && !dto.getMotDePasse().isBlank()) {

            organisation.setMotDePasse(
                    passwordEncoder.encode(dto.getMotDePasse())
            );
        }

        // Enregistrer les modifications
        OrganisationPartenaire updated =
                organisationPartenaireRepository.save(organisation);

        return organisationPartenaireMapper.toResponseDTO(updated);
    }

    // Changer le statut d'une organisation
    @Override
    public OrganisationPartenaireResponseDTO changerStatut(
            Integer id,
            StatutValidation statut) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        verifierRole(utilisateur, RoleEnum.ADMIN);

        OrganisationPartenaire organisation = getEntity(id);

        organisation.setStatutValidation(statut);

        if (statut == StatutValidation.VALIDEE) {
            organisation.setDateValidation(
                    LocalDate.now()
            );
        }

        OrganisationPartenaire updated =
                organisationPartenaireRepository.save(organisation);

        return organisationPartenaireMapper.toResponseDTO(updated);
    }

    // Enregistrer un bénéficiaire particulier
    @Override
    public BeneficiaireParticulierResponseDTO
    enregistrerBeneficiaireParticulier(
            Integer organisationId,
            BeneficiaireParticulierRequestDTO dto) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        verifierOrganisationConnectee(utilisateur, organisationId);

        OrganisationPartenaire organisation =
                getEntity(organisationId);

        if (organisation.getStatutValidation()
                != StatutValidation.VALIDEE) {

            throw new BadRequestException(
                    "Cette organisation n'est pas encore validée"
            );
        }

        if (dto.getMotDePasse() == null
                || dto.getMotDePasse().isBlank()) {

            throw new BadRequestException(
                    "Le mot de passe est obligatoire"
            );
        }

        BeneficiaireParticulier beneficiaire =
                beneficiaireParticulierMapper.toEntity(dto);

        beneficiaire.setRole(
                RoleEnum.BENEFICIARE
        );

        beneficiaire.setTypeBeneficiaire(
                TypeBeneficiaire.PARTICULIER
        );

        beneficiaire.setOrganisationPartenaire(
                organisation
        );

        beneficiaire.setMotDePasse(
                passwordEncoder.encode(dto.getMotDePasse())
        );

        beneficiaire.setStatut(
                StatutBeneficiaire.ACCEPTE
        );

        beneficiaire.setDateValidation(
                LocalDate.now()
        );

        BeneficiaireParticulier saved =
                beneficiaireParticulierRepository.save(beneficiaire);

        return beneficiaireParticulierMapper.toDTO(saved);
    }

    // Vérifier qu'une organisation correspond à l'utilisateur connecté
    private void verifierOrganisationConnectee(
            Utilisateur utilisateur,
            Integer organisationId) {

        if (utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE
                || !Objects.equals(utilisateur.getId(), organisationId)) {

            throw new AccessDeniedException(
                    "Vous ne pouvez effectuer cette action qu'avec votre propre organisation."
            );
        }
    }

    // Vérifier le rôle de l'utilisateur connecté
    private void verifierRole(
            Utilisateur utilisateur,
            RoleEnum roleAttendu) {

        if (utilisateur.getRole() != roleAttendu) {
            throw new AccessDeniedException(
                    "Vous n'avez pas les droits nécessaires pour effectuer cette action."
            );
        }
    }

    // Récupérer une organisation
    private OrganisationPartenaire getEntity(Integer id) {

        return organisationPartenaireRepository
                .findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Organisation partenaire introuvable"
                        )
                );
    }
}
