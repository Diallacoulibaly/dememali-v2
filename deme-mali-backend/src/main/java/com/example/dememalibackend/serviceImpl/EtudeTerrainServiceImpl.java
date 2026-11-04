
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.EtudeTerrainRequestDTO;
import com.example.dememalibackend.dto.EtudeTerrainResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.EtudeTerrain;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.Don;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.EtudeTerrainMapper;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.EtudeTerrainRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.service.EtudeTerrainService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class EtudeTerrainServiceImpl implements EtudeTerrainService {

    private final EtudeTerrainRepository repository;
    private final EtudeTerrainMapper mapper;
    private final DemandeAideRepository demandeAideRepository;
    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    // 1. Créer une étude de terrain
    @Override
    public EtudeTerrainResponseDTO creer(EtudeTerrainRequestDTO dto) {

        validerCreation(dto);

        DemandeAide demande = demandeAideRepository
                .findById(dto.getDemandeAideId())
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Demande d'aide introuvable."));

        OrganisationPartenaire organisation =
                organisationPartenaireRepository
                        .findById(dto.getOrganisationPartenaireId())
                        .orElseThrow(() ->
                                new ResourceNotFoundException(
                                        "Organisation partenaire introuvable."));

        verifierOrganisationConnectee(organisation.getId());

        if (!Objects.equals(
                demande.getOrganisationPartenaire().getId(),
                organisation.getId())) {
            throw new AccessDeniedException(
                    "Cette demande n'appartient pas à votre organisation.");
        }

        if (demande.getStatut() == StatutDemande.REJETEE) {
            throw new BadRequestException(
                    "Impossible de créer une étude pour une demande rejetée.");
        }

        // Une demande ne peut avoir qu'une seule étude.
        if (repository.findByDemandeAideId(demande.getId()).isPresent()) {
            throw new BadRequestException(
                    "Une étude de terrain existe déjà pour cette demande.");
        }

        EtudeTerrain etude = EtudeTerrain.builder()
                .demandeAide(demande)
                .organisationPartenaire(organisation)
                .datePlanification(dto.getDatePlanification())
                .heure(dto.getHeure())
                .lieu(dto.getLieu().trim())
                .objectif(dto.getObjectif().trim())
                .dateRealisation(null)
                .observation(null)
                .resultat(null)
                .status(StatutEtudeTerrain.PLANIFIEE)
                .build();

        return mapper.toDTO(repository.save(etude));
    }

    // 2. Modifier la planification d'une étude
    @Override
    public EtudeTerrainResponseDTO planifier(
            Integer id,
            EtudeTerrainRequestDTO dto) {

        if (dto == null) {
            throw new BadRequestException(
                    "Les informations de planification sont obligatoires.");
        }

        EtudeTerrain etude = getEntity(id);
        verifierProprietaireEtude(etude);

        if (etude.getStatus() != StatutEtudeTerrain.EN_ATTENTE
                && etude.getStatus() != StatutEtudeTerrain.PLANIFIEE) {
            throw new BadRequestException(
                    "Cette étude ne peut pas être planifiée.");
        }

        validerPlanification(
                dto.getDatePlanification(),
                dto.getHeure(),
                dto.getLieu(),
                dto.getObjectif()
        );

        etude.setDatePlanification(dto.getDatePlanification());
        etude.setHeure(dto.getHeure());
        etude.setLieu(dto.getLieu().trim());
        etude.setObjectif(dto.getObjectif().trim());
        etude.setStatus(StatutEtudeTerrain.PLANIFIEE);

        return mapper.toDTO(repository.save(etude));
    }

    // 3. Terminer une étude
    @Override
    public EtudeTerrainResponseDTO terminer(
            Integer id,
            EtudeTerrainRequestDTO dto) {

        if (dto == null) {
            throw new BadRequestException(
                    "Les informations de réalisation sont obligatoires.");
        }

        EtudeTerrain etude = getEntity(id);
        verifierProprietaireEtude(etude);

        if (etude.getStatus() != StatutEtudeTerrain.PLANIFIEE) {
            throw new BadRequestException(
                    "L'étude doit être planifiée avant d'être terminée.");
        }

        if (dto.getDateRealisation() == null) {
            throw new BadRequestException(
                    "La date de réalisation est obligatoire.");
        }

        if (dto.getDateRealisation().isAfter(LocalDate.now())) {
            throw new BadRequestException(
                    "La date de réalisation ne peut pas être dans le futur.");
        }

        if (dto.getObservation() == null
                || dto.getObservation().isBlank()) {
            throw new BadRequestException(
                    "Les observations de la visite sont obligatoires.");
        }

        if (dto.getResultat() == null
                || dto.getResultat().isBlank()) {
            throw new BadRequestException(
                    "Le résultat de l'étude est obligatoire.");
        }

        etude.setDateRealisation(dto.getDateRealisation());
        etude.setObservation(dto.getObservation().trim());
        etude.setResultat(dto.getResultat().trim());
        etude.setStatus(StatutEtudeTerrain.TERMINEE);

        return mapper.toDTO(repository.save(etude));
    }

    // 4. Récupérer une étude par son identifiant
    @Override
    @Transactional(readOnly = true)
    public EtudeTerrainResponseDTO getById(Integer id) {

        EtudeTerrain etude = getEntity(id);
        verifierAccesEtude(etude);

        return mapper.toDTO(etude);
    }

    // 5. Récupérer toutes les études
    @Override
    @Transactional(readOnly = true)
    public List<EtudeTerrainResponseDTO> getAll() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        return repository.findAll()
                .stream()
                .filter(etude -> peutConsulterEtude(etude, utilisateur))
                .map(mapper::toDTO)
                .toList();
    }

    // 6. Modifier une étude de terrain
    @Override
    public EtudeTerrainResponseDTO modifier(
            Integer id,
            EtudeTerrainRequestDTO dto) {

        if (dto == null) {
            throw new BadRequestException(
                    "Les données de modification sont obligatoires.");
        }

        EtudeTerrain etude = getEntity(id);
        verifierProprietaireEtude(etude);

        DemandeAide demande = etude.getDemandeAide();

        if (demande != null
                && demande.getStatut() == StatutDemande.VALIDEE) {
            throw new BadRequestException(
                    "Impossible de modifier l'étude de terrain : "
                            + "la demande d'aide est déjà validée.");
        }

        if (dto.getObjectif() != null
                && !dto.getObjectif().isBlank()) {
            etude.setObjectif(dto.getObjectif().trim());
        }

        if (dto.getDatePlanification() != null) {
            if (dto.getDatePlanification().isBefore(LocalDate.now())) {
                throw new BadRequestException(
                        "La date de planification ne peut pas être passée.");
            }

            etude.setDatePlanification(dto.getDatePlanification());
        }

        if (dto.getHeure() != null) {
            etude.setHeure(dto.getHeure());
        }

        if (dto.getLieu() != null && !dto.getLieu().isBlank()) {
            etude.setLieu(dto.getLieu().trim());
        }

        if (dto.getDateRealisation() != null) {
            if (dto.getDateRealisation().isAfter(LocalDate.now())) {
                throw new BadRequestException(
                        "La date de réalisation ne peut pas être dans le futur.");
            }

            etude.setDateRealisation(dto.getDateRealisation());
        }

        if (dto.getObservation() != null) {
            etude.setObservation(dto.getObservation().trim());
        }

        if (dto.getResultat() != null) {
            etude.setResultat(dto.getResultat().trim());
        }

        EtudeTerrain etudeModifiee = repository.save(etude);

        return mapper.toDTO(etudeModifiee);
    }

    // 7. Récupérer une seule étude par demande
    @Override
    @Transactional(readOnly = true)
    public EtudeTerrainResponseDTO getByDemande(Integer demandeAideId) {

        if (demandeAideId == null) {
            throw new BadRequestException(
                    "L'identifiant de la demande est obligatoire.");
        }

        DemandeAide demande = demandeAideRepository
                .findById(demandeAideId)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Demande d'aide introuvable."));

        verifierAccesDemande(demande);

        EtudeTerrain etude = repository
                .findByDemandeAideId(demandeAideId)
                .orElse(null);

        if (etude == null) {
            return null;
        }

        return mapper.toDTO(etude);
    }

    // 8. Récupérer les études d'une organisation
    @Override
    @Transactional(readOnly = true)
    public List<EtudeTerrainResponseDTO> getByOrganisation(
            Integer organisationPartenaireId) {

        if (organisationPartenaireId == null) {
            throw new BadRequestException(
                    "L'identifiant de l'organisation est obligatoire.");
        }

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        return repository
                .findByOrganisationPartenaireId(organisationPartenaireId)
                .stream()
                .filter(etude -> peutConsulterEtude(etude, utilisateur))
                .map(mapper::toDTO)
                .toList();
    }

    // Vérifier si l'utilisateur connecté peut consulter une étude
    private void verifierAccesEtude(EtudeTerrain etude) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!peutConsulterEtude(etude, utilisateur)) {
            throw new AccessDeniedException(
                    "Vous n'avez pas accès à cette étude de terrain.");
        }
    }

    // Vérifier les droits de consultation selon le rôle
    private boolean peutConsulterEtude(
            EtudeTerrain etude,
            Utilisateur utilisateur) {

        if (estAdmin(utilisateur)) {
            return true;
        }

        DemandeAide demande = etude.getDemandeAide();

        if (demande == null) {
            return false;
        }

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            return Objects.equals(
                    demande.getOrganisationPartenaire().getId(),
                    organisation.getId());
        }

        if (utilisateur instanceof Beneficiaire beneficiaire) {
            return Objects.equals(
                    demande.getBeneficiaire().getId(),
                    beneficiaire.getId())
                    || demandeAideVisibilite.estValideeAvecEtudeTerminee(demande);
        }

        if (utilisateur.getRole() == RoleEnum.DONATEUR) {
            return demandeAideVisibilite.estOuverteAuxDons(demande)
                    || (demande.getDons() != null
                    && demande.getDons().stream()
                    .anyMatch(don ->
                            don.getDonateur() != null
                                    && Objects.equals(
                                    don.getDonateur().getId(),
                                    utilisateur.getId())));
        }

        return false;
    }

    // Vérifier les droits sur une demande
    private void verifierAccesDemande(DemandeAide demande) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (estAdmin(utilisateur)) {
            return;
        }

        if (utilisateur instanceof OrganisationPartenaire organisation
                && Objects.equals(
                demande.getOrganisationPartenaire().getId(),
                organisation.getId())) {
            return;
        }

        if (utilisateur instanceof Beneficiaire beneficiaire
                && (Objects.equals(
                demande.getBeneficiaire().getId(),
                beneficiaire.getId())
                || demandeAideVisibilite.estValideeAvecEtudeTerminee(demande))) {
            return;
        }

        if (utilisateur.getRole() == RoleEnum.DONATEUR) {
            if (demandeAideVisibilite.estOuverteAuxDons(demande)
                    || (demande.getDons() != null
                    && demande.getDons().stream()
                    .anyMatch(don ->
                            don.getDonateur() != null
                                    && Objects.equals(
                                    don.getDonateur().getId(),
                                    utilisateur.getId())))) {
                return;
            }
        }

        throw new AccessDeniedException(
                "Vous n'avez pas accès à cette demande d'aide.");
    }

    // Vérifier que l'organisation connectée est propriétaire de l'étude
    private void verifierProprietaireEtude(EtudeTerrain etude) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (estAdmin(utilisateur)) {
            return;
        }

        if (!(utilisateur instanceof OrganisationPartenaire organisation)) {
            throw new AccessDeniedException(
                    "Seule l'organisation partenaire peut effectuer cette opération.");
        }

        Integer organisationEtudeId = etude.getOrganisationPartenaire() != null
                ? etude.getOrganisationPartenaire().getId()
                : etude.getDemandeAide().getOrganisationPartenaire().getId();

        if (!Objects.equals(organisationEtudeId, organisation.getId())) {
            throw new AccessDeniedException(
                    "Cette étude n'appartient pas à votre organisation.");
        }
    }

    // Vérifier que l'organisation connectée correspond à l'identifiant fourni
    private void verifierOrganisationConnectee(Integer organisationId) {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (!(utilisateur instanceof OrganisationPartenaire organisation)
                || !Objects.equals(organisation.getId(), organisationId)) {
            throw new AccessDeniedException(
                    "Vous ne pouvez pas créer une étude pour une autre organisation.");
        }
    }

    // Vérifier si l'utilisateur connecté est administrateur
    private boolean estAdmin(Utilisateur utilisateur) {
        return utilisateur.getRole() != null
                && "ADMIN".equals(utilisateur.getRole().name());
    }

    // Rechercher une étude par son identifiant
    private EtudeTerrain getEntity(Integer id) {

        if (id == null) {
            throw new BadRequestException(
                    "L'identifiant de l'étude est obligatoire.");
        }

        return repository.findById(id)
                .orElseThrow(() ->
                        new ResourceNotFoundException(
                                "Étude de terrain introuvable."));
    }

    // Vérifier les informations du formulaire de création
    private void validerCreation(EtudeTerrainRequestDTO dto) {

        if (dto == null) {
            throw new BadRequestException(
                    "Les données de l'étude sont obligatoires.");
        }

        if (dto.getDemandeAideId() == null) {
            throw new BadRequestException(
                    "La demande d'aide est obligatoire.");
        }

        if (dto.getOrganisationPartenaireId() == null) {
            throw new BadRequestException(
                    "L'organisation partenaire est obligatoire.");
        }

        validerPlanification(
                dto.getDatePlanification(),
                dto.getHeure(),
                dto.getLieu(),
                dto.getObjectif()
        );
    }

    // Vérifier les champs nécessaires à la planification
    private void validerPlanification(
            LocalDate datePlanification,
            LocalTime heure,
            String lieu,
            String objectif) {

        if (datePlanification == null) {
            throw new BadRequestException(
                    "La date de planification est obligatoire.");
        }

        if (datePlanification.isBefore(LocalDate.now())) {
            throw new BadRequestException(
                    "La date de planification ne peut pas être passée.");
        }

        if (heure == null) {
            throw new BadRequestException(
                    "L'heure de la visite est obligatoire.");
        }

        if (lieu == null || lieu.isBlank()) {
            throw new BadRequestException(
                    "Le lieu de la visite est obligatoire.");
        }

        if (objectif == null || objectif.isBlank()) {
            throw new BadRequestException(
                    "L'objectif de l'étude est obligatoire.");
        }
    }
}
