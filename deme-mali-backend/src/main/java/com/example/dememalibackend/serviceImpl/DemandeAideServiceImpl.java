package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutCollecte;
import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import com.example.dememalibackend.Enum.TypeDemandeAide;
import com.example.dememalibackend.dto.ArticleDemandeRequestDTO;
import com.example.dememalibackend.dto.DemandeAideRequestDTO;
import com.example.dememalibackend.dto.DemandeAideResponseDTO;
import com.example.dememalibackend.entity.ArticleDemande;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.CategorieDemande;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.EtudeTerrain;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.RapportBesoin;
import com.example.dememalibackend.entity.RapportTechnique;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.DemandeAideMapper;
import com.example.dememalibackend.repository.BeneficiaireRepository;
import com.example.dememalibackend.repository.CategorieDemandeRepository;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.DonRepository;
import com.example.dememalibackend.repository.EtudeTerrainRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.repository.RapportBesoinRepository;
import com.example.dememalibackend.repository.RapportTechniqueRepository;
import com.example.dememalibackend.service.DemandeAideService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class DemandeAideServiceImpl implements DemandeAideService {

    private final DemandeAideRepository demandeAideRepository;
    private final BeneficiaireRepository beneficiaireRepository;
    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final CategorieDemandeRepository categorieDemandeRepository;
    private final DemandeAideMapper demandeAideMapper;
    private final EtudeTerrainRepository etudeTerrainRepository;
    private final RapportBesoinRepository rapportBesoinRepository;
    private final RapportTechniqueRepository rapportTechniqueRepository;
    private final DonRepository donRepository;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    // 1. Créer une demande d'aide.
    @Override
    public DemandeAideResponseDTO creer(DemandeAideRequestDTO dto) {

        validerDonnees(dto);

        Beneficiaire beneficiaire = beneficiaireRepository.findById(dto.getBeneficiaireId())
                .orElseThrow(() -> new ResourceNotFoundException("Bénéficiaire introuvable."));

        OrganisationPartenaire organisation = organisationPartenaireRepository.findById(dto.getOrganisationPartenaireId())
                .orElseThrow(() -> new ResourceNotFoundException("Organisation partenaire introuvable."));

        CategorieDemande categorie = categorieDemandeRepository.findById(dto.getCategorieDemandeId())
                .orElseThrow(() -> new ResourceNotFoundException("Catégorie de demande introuvable."));

        String role = roleConnecte();
        Integer utilisateurId = utilisateurConnecte().getId();

        if (role.equals("ORGANISATIONPARTENAIRE")) {
            if (!Objects.equals(organisation.getId(), utilisateurId)) {
                throw new AccessDeniedException("Vous ne pouvez créer une demande que pour votre organisation.");
            }
            if (beneficiaire.getOrganisationPartenaire() == null || !Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), utilisateurId)) {
                throw new AccessDeniedException("Ce bénéficiaire n'appartient pas à votre organisation.");
            }
        } else if (role.equals("BENEFICIARE")) {
            if (!Objects.equals(beneficiaire.getId(), utilisateurId)) {
                throw new AccessDeniedException("Vous ne pouvez créer une demande que pour vous-même.");
            }
            if (beneficiaire.getOrganisationPartenaire() == null || !Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), organisation.getId())) {
                throw new AccessDeniedException("Vous devez être lié à cette organisation pour créer une demande.");
            }
        } else {
            throw new AccessDeniedException("Vous n'êtes pas autorisé à créer une demande.");
        }

        DemandeAide demande = new DemandeAide();
        demande.setTitre(dto.getTitre().trim());
        demande.setDescriptionSituation(dto.getDescriptionSituation().trim());
        demande.setNiveauUrgence(dto.getNiveauUrgence());
        demande.setMotif(normaliserMotif(dto.getMotif()));
        demande.setNombrePersonne(dto.getNombrePersonne());
        demande.setTypeDemande(dto.getTypeDemande());
        demande.setTypeDemandeAide(dto.getTypeDemandeAide());
        demande.setBeneficiaire(beneficiaire);
        demande.setOrganisationPartenaire(organisation);
        demande.setCategorieDemande(categorie);

        if (dto.getTypeDemandeAide() == TypeDemandeAide.FINANCIERE) {
            demande.setMontantNecessaire(dto.getMontantNecessaire());
        } else {
            demande.setMontantNecessaire(null);
        }

        demande.setStatut(StatutDemande.EN_ATTENTE);
        demande.setDateCreation(LocalDate.now());
        demande.setDateValidation(null);
        demande.setMontantCollecte(0.0);
        demande.setStatutCollecte(StatutCollecte.NON_COMMENCEE);
        demande.setArticles(new ArrayList<>());

        if (dto.getTypeDemandeAide() == TypeDemandeAide.MATERIELLE) {
            for (ArticleDemandeRequestDTO articleDTO : dto.getArticles()) {
                ArticleDemande article = new ArticleDemande();
                article.setDesignation(articleDTO.getDesignation().trim());
                article.setQuantiteDemandee(articleDTO.getQuantiteDemandee());
                article.setUnite(articleDTO.getUnite().trim());
                article.setPrixUnitaireEstime(articleDTO.getPrixUnitaireEstime());
                article.setDemandeAide(demande);
                demande.getArticles().add(article);
            }
        }

        DemandeAide demandeSauvegardee = demandeAideRepository.save(demande);
        return convertirAvecNombreDonateurs(demandeSauvegardee);
    }

    // 2. Récupérer une demande à partir de son identifiant.
    @Override
    @Transactional(readOnly = true)
    public DemandeAideResponseDTO getById(Integer id) {
        DemandeAide demande = trouverDemande(id);
        verifierAccesConsultationDemande(demande);
        return convertirAvecNombreDonateurs(demande);
    }

    // 3. Récupérer toutes les demandes avec leur nombre de donateurs.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getAll() {
        return filtrerDemandesVisibles(demandeAideRepository.findAll())
                .stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 4. Modifier une demande qui est encore en attente.
    @Override
    public DemandeAideResponseDTO modifier(Integer id, DemandeAideRequestDTO dto) {

        DemandeAide demande = trouverDemande(id);
        verifierAccesDemande(demande);

        String role = roleConnecte();
        Integer utilisateurId = utilisateurConnecte().getId();

        if (role.equals("DONATEUR") || role.equals("ADMIN")) {
            throw new AccessDeniedException("Vous n'êtes pas autorisé à modifier cette demande.");
        }

        if (demande.getStatut() != StatutDemande.EN_ATTENTE) {
            throw new BadRequestException("Seule une demande en attente peut être modifiée.");
        }

        validerDonnees(dto);

        Beneficiaire beneficiaire = beneficiaireRepository.findById(dto.getBeneficiaireId())
                .orElseThrow(() -> new ResourceNotFoundException("Bénéficiaire introuvable."));

        OrganisationPartenaire organisation = organisationPartenaireRepository.findById(dto.getOrganisationPartenaireId())
                .orElseThrow(() -> new ResourceNotFoundException("Organisation partenaire introuvable."));

        CategorieDemande categorie = categorieDemandeRepository.findById(dto.getCategorieDemandeId())
                .orElseThrow(() -> new ResourceNotFoundException("Catégorie de demande introuvable."));

        if (role.equals("ORGANISATIONPARTENAIRE")) {
            if (!Objects.equals(organisation.getId(), utilisateurId)) {
                throw new AccessDeniedException("Vous ne pouvez pas transférer une demande vers une autre organisation.");
            }
            if (beneficiaire.getOrganisationPartenaire() == null || !Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), utilisateurId)) {
                throw new AccessDeniedException("Ce bénéficiaire n'appartient pas à votre organisation.");
            }
        } else if (role.equals("BENEFICIARE")) {
            if (!Objects.equals(beneficiaire.getId(), utilisateurId)) {
                throw new AccessDeniedException("Vous ne pouvez pas modifier une demande pour un autre bénéficiaire.");
            }
            if (beneficiaire.getOrganisationPartenaire() == null || !Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), organisation.getId())) {
                throw new AccessDeniedException("Vous devez être lié à cette organisation pour modifier la demande.");
            }
        }

        demande.setTitre(dto.getTitre().trim());
        demande.setDescriptionSituation(dto.getDescriptionSituation().trim());
        demande.setNiveauUrgence(dto.getNiveauUrgence());
        demande.setMotif(normaliserMotif(dto.getMotif()));
        demande.setNombrePersonne(dto.getNombrePersonne());
        demande.setTypeDemande(dto.getTypeDemande());
        demande.setTypeDemandeAide(dto.getTypeDemandeAide());
        demande.setBeneficiaire(beneficiaire);
        demande.setOrganisationPartenaire(organisation);
        demande.setCategorieDemande(categorie);

        if (dto.getTypeDemandeAide() == TypeDemandeAide.FINANCIERE) {
            demande.setMontantNecessaire(dto.getMontantNecessaire());
            demande.getArticles().clear();
        } else {
            demande.setMontantNecessaire(null);
            demande.getArticles().clear();

            for (ArticleDemandeRequestDTO articleDTO : dto.getArticles()) {
                ArticleDemande article = new ArticleDemande();
                article.setDesignation(articleDTO.getDesignation().trim());
                article.setQuantiteDemandee(articleDTO.getQuantiteDemandee());
                article.setUnite(articleDTO.getUnite().trim());
                article.setPrixUnitaireEstime(articleDTO.getPrixUnitaireEstime());
                article.setDemandeAide(demande);
                demande.getArticles().add(article);
            }
        }

        return convertirAvecNombreDonateurs(demandeAideRepository.save(demande));
    }

    // 5. Supprimer une demande qui est encore en attente.
    @Override
    public void supprimer(Integer id) {
        DemandeAide demande = trouverDemande(id);
        if (demande.getStatut() != StatutDemande.EN_ATTENTE) {
            throw new BadRequestException("Seule une demande en attente peut être supprimée.");
        }
        demandeAideRepository.delete(demande);
    }

    // 6. Valider une demande après vérification des études et des rapports.
    @Override
    public DemandeAideResponseDTO valider(Integer id) {

        DemandeAide demande = trouverDemande(id);

        if (!roleConnecte().equals("ORGANISATIONPARTENAIRE")) {
            throw new AccessDeniedException("Seule l'organisation partenaire peut effectuer cette opération.");
        }
        verifierAccesDemande(demande);

        if (demande.getStatut() != StatutDemande.EN_ATTENTE) {
            throw new BadRequestException("Seule une demande en attente peut être validée.");
        }

        if (demande.getTypeDemandeAide() == null) {
            throw new BadRequestException("Le type de demande d'aide est obligatoire.");
        }

        EtudeTerrain etude = verifierEtudeTerrain(demande.getId());

        RapportBesoin rapportBesoin = rapportBesoinRepository.findByEtudeTerrainId(etude.getId())
                .orElseThrow(() -> new BadRequestException("Le rapport de besoin est obligatoire avant la validation."));

        RapportTechnique rapportTechnique = rapportTechniqueRepository.findByRapportBesoinId(rapportBesoin.getId())
                .orElseThrow(() -> new BadRequestException("Le rapport technique est obligatoire avant la validation."));

        Double montantFinal = rapportTechnique.getMontantFinal();

        if (rapportTechnique.getDetails() == null || rapportTechnique.getDetails().isEmpty() || montantFinal == null || !Double.isFinite(montantFinal) || montantFinal <= 0) {
            throw new BadRequestException("Le rapport technique doit contenir des détails et un montant final positif.");
        }

        if (demande.getTypeDemandeAide() == TypeDemandeAide.FINANCIERE) {
            Double montantNecessaire = demande.getMontantNecessaire();
            if (montantNecessaire == null || !Double.isFinite(montantNecessaire) || montantNecessaire <= 0) {
                throw new BadRequestException("Le montant nécessaire doit être positif.");
            }
        } else if (demande.getTypeDemandeAide() == TypeDemandeAide.MATERIELLE) {
            if (demande.getArticles() == null || demande.getArticles().isEmpty()) {
                throw new BadRequestException("La demande matérielle doit contenir au moins un article.");
            }

            boolean articleInvalide = demande.getArticles().stream().anyMatch(article -> {
                if (article == null || article.getDesignation() == null || article.getDesignation().isBlank() || article.getQuantiteDemandee() == null || article.getQuantiteDemandee() <= 0 || article.getUnite() == null || article.getUnite().isBlank()) {
                    return true;
                }
                Double prix = article.getPrixUnitaireEstime();
                return prix != null && (!Double.isFinite(prix) || prix < 0);
            });

            if (articleInvalide) {
                throw new BadRequestException("Chaque article doit avoir une désignation, une quantité positive et une unité. Le prix estimé ne peut pas être négatif.");
            }
        } else {
            throw new BadRequestException("Le type de demande d'aide est invalide.");
        }

        demande.setStatut(StatutDemande.VALIDEE);
        demande.setDateValidation(LocalDate.now());
        demande.setStatutCollecte(StatutCollecte.NON_COMMENCEE);

        return convertirAvecNombreDonateurs(demandeAideRepository.save(demande));
    }

    // 7. Rejeter une demande en exigeant un motif.
    @Override
    public DemandeAideResponseDTO rejeter(Integer id, String motif) {

        DemandeAide demande = trouverDemande(id);

        if (!roleConnecte().equals("ORGANISATIONPARTENAIRE")) {
            throw new AccessDeniedException("Seule l'organisation partenaire peut effectuer cette opération.");
        }
        verifierAccesDemande(demande);

        if (demande.getStatut() != StatutDemande.EN_ATTENTE) {
            throw new BadRequestException("Seule une demande en attente peut être refusée.");
        }

        if (motif == null || motif.isBlank()) {
            throw new BadRequestException("Le motif du refus est obligatoire.");
        }

        verifierEtudeTerrain(demande.getId());

        demande.setStatut(StatutDemande.REJETEE);
        demande.setMotif(motif.trim());
        demande.setDateValidation(LocalDate.now());

        return convertirAvecNombreDonateurs(demandeAideRepository.save(demande));
    }

    // 8. Récupérer les demandes ayant le statut demandé.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getByStatut(StatutDemande statut) {

        if (statut == null) {
            throw new BadRequestException("Le statut est obligatoire.");
        }

        return filtrerDemandesVisibles(demandeAideRepository.findByStatut(statut))
                .stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 9. Récupérer les demandes d'un bénéficiaire.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getByBeneficiaire(Integer beneficiaireId) {

        if (beneficiaireId == null) {
            throw new BadRequestException("L'identifiant du bénéficiaire est obligatoire.");
        }

        String role = roleConnecte();
        Integer utilisateurId = utilisateurConnecte().getId();

        if (role.equals("ORGANISATIONPARTENAIRE")) {
            Beneficiaire beneficiaire = beneficiaireRepository.findById(beneficiaireId)
                    .orElseThrow(() -> new ResourceNotFoundException("Bénéficiaire introuvable."));
            if (beneficiaire.getOrganisationPartenaire() == null || !Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), utilisateurId)) {
                throw new AccessDeniedException("Ce bénéficiaire n'appartient pas à votre organisation.");
            }
        }

        return filtrerDemandesVisibles(demandeAideRepository.findByBeneficiaireId(beneficiaireId))
                .stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 10. Récupérer les demandes d'une organisation partenaire.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getByOrganisation(Integer organisationPartenaireId) {

        if (organisationPartenaireId == null) {
            throw new BadRequestException("L'identifiant de l'organisation est obligatoire.");
        }

        verifierAccesOrganisation(organisationPartenaireId);

        return filtrerDemandesVisibles(demandeAideRepository.findByOrganisationPartenaireId(organisationPartenaireId))
                .stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 11. Récupérer les demandes d'une catégorie.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getByCategorie(Integer categorieDemandeId) {

        if (categorieDemandeId == null) {
            throw new BadRequestException("L'identifiant de la catégorie est obligatoire.");
        }

        return filtrerDemandesVisibles(demandeAideRepository.findByCategorieDemandeId(categorieDemandeId))
                .stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 12. Récupérer les demandes validées encore ouvertes aux dons.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getDemandesDisponiblesPourDon() {

        return filtrerDemandesVisibles(demandeAideRepository.findByStatutAndStatutCollecteNot(
                StatutDemande.VALIDEE,
                StatutCollecte.TERMINEE))
                .stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 13. Récupérer les demandes ouvertes aux dons pour une organisation.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getDemandesDisponiblesPourDon(Integer organisationId) {

        if (organisationId == null) {
            throw new BadRequestException("L'identifiant de l'organisation est obligatoire.");
        }

        verifierAccesOrganisation(organisationId);

        return filtrerDemandesVisibles(demandeAideRepository.findByOrganisationPartenaireIdAndStatutAndStatutCollecteNot(
                organisationId,
                StatutDemande.VALIDEE,
                StatutCollecte.TERMINEE))
                .stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 14. Récupérer les demandes terminées qui attendent une distribution.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getDemandesTermineesPourAideDistribuee(Integer organisationId) {

        if (organisationId == null) {
            throw new BadRequestException("L'identifiant de l'organisation est obligatoire.");
        }

        verifierAccesOrganisation(organisationId);

        List<DemandeAide> demandes = demandeAideRepository.findDemandesNonDistribuees(
                organisationId,
                StatutDemande.VALIDEE,
                StatutCollecte.TERMINEE);

        String role = roleConnecte();

        if (role.equals("DONATEUR")) {
            List<Integer> demandesDonnees = donRepository.findByDonateurId(donateurConnecteId())
                    .stream()
                    .filter(d -> d.getDemandeAide() != null)
                    .map(d -> d.getDemandeAide().getId())
                    .distinct()
                    .toList();

            demandes = demandes.stream()
                    .filter(d -> demandesDonnees.contains(d.getId()))
                    .toList();
        } else if (role.equals("BENEFICIARE")) {
            Integer beneficiaireId = beneficiaireConnecteId();
            demandes = demandes.stream()
                    .filter(d -> Objects.equals(d.getBeneficiaire().getId(), beneficiaireId)
                            || demandeAideVisibilite.estValideeAvecEtudeTerminee(d))
                    .toList();
        }

        return demandes.stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 15. Trouver une demande à partir de son identifiant.
    private DemandeAide trouverDemande(Integer id) {

        if (id == null) {
            throw new BadRequestException("L'identifiant de la demande est obligatoire.");
        }

        return demandeAideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Demande d'aide introuvable avec l'id : " + id));
    }

    // 16. Trouver une étude de terrain terminée pour une demande.
    private EtudeTerrain verifierEtudeTerrain(Integer demandeId) {

        return etudeTerrainRepository.findByDemandeAideId(demandeId)
                .stream()
                .filter(etude -> etude.getStatus() == StatutEtudeTerrain.TERMINEE)
                .findFirst()
                .orElseThrow(() -> new BadRequestException("Une étude de terrain terminée est obligatoire."));
    }

    // 17. Nettoyer le motif facultatif.
    private String normaliserMotif(String motif) {
        if (motif == null || motif.isBlank()) {
            return null;
        }
        return motif.trim();
    }

    // 18. Vérifier les données avant la création ou la modification.
    private void validerDonnees(DemandeAideRequestDTO dto) {

        if (dto == null) {
            throw new BadRequestException("Les données de la demande sont obligatoires.");
        }

        if (dto.getTitre() == null || dto.getTitre().isBlank()) {
            throw new BadRequestException("Le titre de la demande est obligatoire.");
        }

        if (dto.getDescriptionSituation() == null || dto.getDescriptionSituation().isBlank()) {
            throw new BadRequestException("La description de la situation est obligatoire.");
        }

        if (dto.getBeneficiaireId() == null || dto.getOrganisationPartenaireId() == null || dto.getCategorieDemandeId() == null) {
            throw new BadRequestException("Le bénéficiaire, l'organisation et la catégorie sont obligatoires.");
        }

        if (dto.getNiveauUrgence() == null) {
            throw new BadRequestException("Le niveau d'urgence est obligatoire.");
        }

        if (dto.getTypeDemande() == null) {
            throw new BadRequestException("Le type de demande est obligatoire.");
        }

        if (dto.getTypeDemandeAide() == null) {
            throw new BadRequestException("Le type de demande d'aide est obligatoire.");
        }

        if (dto.getNombrePersonne() == null || dto.getNombrePersonne() <= 0) {
            throw new BadRequestException("Le nombre de personnes doit être supérieur à zéro.");
        }

        if (dto.getTypeDemandeAide() == TypeDemandeAide.FINANCIERE) {
            Double montant = dto.getMontantNecessaire();
            if (montant == null || !Double.isFinite(montant) || montant <= 0) {
                throw new BadRequestException("Le montant nécessaire doit être un nombre positif valide.");
            }
        } else if (dto.getTypeDemandeAide() == TypeDemandeAide.MATERIELLE) {
            if (dto.getArticles() == null || dto.getArticles().isEmpty()) {
                throw new BadRequestException("Une demande matérielle doit contenir au moins un article.");
            }

            for (ArticleDemandeRequestDTO article : dto.getArticles()) {
                if (article == null) {
                    throw new BadRequestException("Un article de la demande est invalide.");
                }
                if (article.getDesignation() == null || article.getDesignation().isBlank()) {
                    throw new BadRequestException("La désignation de chaque article est obligatoire.");
                }
                if (article.getQuantiteDemandee() == null || article.getQuantiteDemandee() <= 0) {
                    throw new BadRequestException("La quantité demandée doit être supérieure à zéro.");
                }
                if (article.getUnite() == null || article.getUnite().isBlank()) {
                    throw new BadRequestException("L'unité de chaque article est obligatoire.");
                }

                Double prix = article.getPrixUnitaireEstime();
                if (prix != null && (!Double.isFinite(prix) || prix < 0)) {
                    throw new BadRequestException("Le prix unitaire estimé doit être positif ou nul.");
                }
            }
        } else {
            throw new BadRequestException("Le type de demande d'aide est invalide.");
        }
    }

    // 19. Récupérer les demandes à prendre en compte pour la planification.
    @Override
    @Transactional(readOnly = true)
    public List<DemandeAideResponseDTO> getDemandesPourPlanification(Integer organisationId) {

        if (organisationId == null) {
            throw new BadRequestException("L'identifiant de l'organisation est obligatoire.");
        }

        verifierAccesOrganisation(organisationId);

        List<DemandeAide> demandes = demandeAideRepository.findByOrganisationPartenaireIdAndStatutNotAndStatutCollecteNot(
                organisationId,
                StatutDemande.VALIDEE,
                StatutCollecte.TERMINEE);

        String role = roleConnecte();

        if (role.equals("BENEFICIARE")) {
            Integer beneficiaireId = beneficiaireConnecteId();
            demandes = demandes.stream()
                    .filter(d -> Objects.equals(d.getBeneficiaire().getId(), beneficiaireId))
                    .toList();
        } else if (role.equals("DONATEUR")) {
            demandes = List.of();
        }

        return demandes.stream()
                .map(this::convertirAvecNombreDonateurs)
                .toList();
    }

    // 20. Récupérer l'utilisateur connecté.
    private Utilisateur utilisateurConnecte() {
        return customUserDetailsService.getUtilisateurConnecte();
    }

    // 21. Récupérer le rôle de l'utilisateur connecté.
    private String roleConnecte() {
        return utilisateurConnecte().getRole().name();
    }

    // 22. Récupérer l'identifiant du donateur connecté.
    private Integer donateurConnecteId() {
        if (!roleConnecte().equals("DONATEUR")) {
            throw new AccessDeniedException("Accès réservé au donateur.");
        }
        return utilisateurConnecte().getId();
    }

    // 23. Récupérer l'identifiant du bénéficiaire connecté.
    private Integer beneficiaireConnecteId() {
        if (!roleConnecte().equals("BENEFICIARE")) {
            throw new AccessDeniedException("Accès réservé au bénéficiaire.");
        }
        return utilisateurConnecte().getId();
    }

    // 24. Récupérer l'identifiant de l'organisation connectée.
    private Integer organisationConnecteeId() {
        if (!roleConnecte().equals("ORGANISATIONPARTENAIRE")) {
            throw new AccessDeniedException("Accès réservé à une organisation partenaire.");
        }
        return utilisateurConnecte().getId();
    }

    private void verifierAccesConsultationDemande(DemandeAide demande) {
        if (roleConnecte().equals("BENEFICIARE")
                && demandeAideVisibilite.estValideeAvecEtudeTerminee(demande)) {
            return;
        }
        verifierAccesDemande(demande);
    }

    // 25. Vérifier l'accès à une demande précise.
    private void verifierAccesDemande(DemandeAide demande) {

        String role = roleConnecte();
        Integer utilisateurId = utilisateurConnecte().getId();

        switch (role) {
            case "ADMIN":
                return;
            case "ORGANISATIONPARTENAIRE":
                if (demande.getOrganisationPartenaire() == null || !Objects.equals(demande.getOrganisationPartenaire().getId(), utilisateurId)) {
                    throw new AccessDeniedException("Cette demande n'appartient pas à votre organisation.");
                }
                return;
            case "BENEFICIARE":
                if (demande.getBeneficiaire() == null || !Objects.equals(demande.getBeneficiaire().getId(), utilisateurId)) {
                    throw new AccessDeniedException("Vous ne pouvez accéder qu'à vos propres demandes.");
                }
                return;
            case "DONATEUR":
                if (!demandeAideVisibilite.estOuverteAuxDons(demande)) {
                    throw new AccessDeniedException("Cette demande n'est pas accessible aux donateurs.");
                }
                return;
            default:
                throw new AccessDeniedException("Accès non autorisé.");
        }
    }

    // 26. Filtrer les demandes selon le rôle de l'utilisateur connecté.
    private List<DemandeAide> filtrerDemandesVisibles(List<DemandeAide> demandes) {

        String role = roleConnecte();
        Integer utilisateurId = utilisateurConnecte().getId();

        return demandes.stream().filter(demande -> {
            switch (role) {
                case "ADMIN":
                    return true;
                case "ORGANISATIONPARTENAIRE":
                    return demande.getOrganisationPartenaire() != null && Objects.equals(demande.getOrganisationPartenaire().getId(), utilisateurId);
                case "BENEFICIARE":
                    return (demande.getBeneficiaire() != null && Objects.equals(demande.getBeneficiaire().getId(), utilisateurId))
                            || demandeAideVisibilite.estValideeAvecEtudeTerminee(demande);
                case "DONATEUR":
                    return demandeAideVisibilite.estOuverteAuxDons(demande);
                default:
                    return false;
            }
        }).toList();
    }

    // 27. Vérifier l'accès à une organisation.
    private void verifierAccesOrganisation(Integer organisationId) {
        if (roleConnecte().equals("ORGANISATIONPARTENAIRE") && !Objects.equals(organisationConnecteeId(), organisationId)) {
            throw new AccessDeniedException("Vous ne pouvez accéder qu'aux demandes de votre organisation.");
        }
    }

    // 28. Convertir une demande en DTO et calculer le nombre de donateurs distincts.
    private DemandeAideResponseDTO convertirAvecNombreDonateurs(DemandeAide demande) {
        DemandeAideResponseDTO dto = demandeAideMapper.toDTO(demande);
        dto.setNombreDonateurs(donRepository.compterDonateursDistinctsParDemande(demande.getId()));
        return dto;
    }
}
