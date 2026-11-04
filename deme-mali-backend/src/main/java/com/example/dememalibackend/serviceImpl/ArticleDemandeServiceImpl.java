package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.TypeDemandeAide;
import com.example.dememalibackend.dto.ArticleDemandeRequestDTO;
import com.example.dememalibackend.dto.ArticleDemandeResponseDTO;
import com.example.dememalibackend.entity.ArticleDemande;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.ArticleDemandeMapper;
import com.example.dememalibackend.repository.ArticleDemandeRepository;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.service.ArticleDemandeService;

import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ArticleDemandeServiceImpl implements ArticleDemandeService {

    private final ArticleDemandeRepository articleDemandeRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final ArticleDemandeMapper articleDemandeMapper;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    // 1. Ajouter un article à une demande
    @Override
    public ArticleDemandeResponseDTO ajouter(Integer demandeId, ArticleDemandeRequestDTO dto) {

        validerArticle(dto);

        DemandeAide demande = trouverDemande(demandeId);
        verifierAccesModification(demande);
        verifierDemandeModifiable(demande);

        String designation = dto.getDesignation().trim();
        String unite = dto.getUnite().trim();

        List<ArticleDemande> articles = articleDemandeRepository.findByDemandeAideId(demandeId);

        for (ArticleDemande existant : articles) {

            if (existant.getDesignation().equals(designation)
                    && existant.getUnite().equals(unite)
                    && memePrix(existant.getPrixUnitaireEstime(), dto.getPrixUnitaireEstime())) {

                int quantiteTotale = existant.getQuantiteDemandee() + dto.getQuantiteDemandee();
                existant.setQuantiteDemandee(quantiteTotale);

                return articleDemandeMapper.toDTO(articleDemandeRepository.save(existant));
            }

            if (existant.getDesignation().equals(designation)
                    && existant.getUnite().equals(unite)
                    && !memePrix(existant.getPrixUnitaireEstime(), dto.getPrixUnitaireEstime())) {

                throw new BadRequestException(
                        "Cet article existe déjà avec un prix unitaire différent."
                );
            }
        }

        ArticleDemande article = new ArticleDemande();
        article.setDesignation(designation);
        article.setQuantiteDemandee(dto.getQuantiteDemandee());
        article.setUnite(unite);
        article.setPrixUnitaireEstime(dto.getPrixUnitaireEstime());
        article.setDemandeAide(demande);

        return articleDemandeMapper.toDTO(articleDemandeRepository.save(article));
    }

    // 2. Récupérer un article par son identifiant
    @Override
    @Transactional(readOnly = true)
    public ArticleDemandeResponseDTO getById(Integer id) {

        ArticleDemande article = trouverArticle(id);
        verifierAccesLecture(article.getDemandeAide());

        return articleDemandeMapper.toDTO(article);
    }

    // 3. Récupérer les articles d'une demande
    @Override
    @Transactional(readOnly = true)
    public List<ArticleDemandeResponseDTO> getByDemande(Integer demandeId) {

        DemandeAide demande = trouverDemande(demandeId);
        verifierAccesLecture(demande);

        return articleDemandeRepository.findByDemandeAideId(demandeId)
                .stream()
                .map(articleDemandeMapper::toDTO)
                .toList();
    }

    // 4. Modifier un article
    @Override
    public ArticleDemandeResponseDTO modifier(Integer id, ArticleDemandeRequestDTO dto) {

        validerArticle(dto);

        ArticleDemande article = trouverArticle(id);
        DemandeAide demande = article.getDemandeAide();

        verifierAccesModification(demande);
        verifierDemandeModifiable(demande);

        String designation = dto.getDesignation().trim();
        String unite = dto.getUnite().trim();

        List<ArticleDemande> articles = articleDemandeRepository.findByDemandeAideId(demande.getId());

        for (ArticleDemande autre : articles) {

            if (autre.getId().equals(article.getId())) {
                continue;
            }

            if (autre.getDesignation().equals(designation)
                    && autre.getUnite().equals(unite)) {

                if (!memePrix(autre.getPrixUnitaireEstime(), dto.getPrixUnitaireEstime())) {
                    throw new BadRequestException(
                            "Un autre article possède la même désignation "
                                    + "et la même unité, mais un prix différent."
                    );
                }

                int quantiteTotale = autre.getQuantiteDemandee() + dto.getQuantiteDemandee();
                autre.setQuantiteDemandee(quantiteTotale);

                ArticleDemande articleEnregistre = articleDemandeRepository.save(autre);
                articleDemandeRepository.delete(article);

                return articleDemandeMapper.toDTO(articleEnregistre);
            }
        }

        article.setDesignation(designation);
        article.setQuantiteDemandee(dto.getQuantiteDemandee());
        article.setUnite(unite);
        article.setPrixUnitaireEstime(dto.getPrixUnitaireEstime());

        return articleDemandeMapper.toDTO(articleDemandeRepository.save(article));
    }

    // 5. Supprimer un article
    @Override
    public void supprimer(Integer id) {

        ArticleDemande article = trouverArticle(id);
        DemandeAide demande = article.getDemandeAide();

        verifierAccesModification(demande);
        verifierDemandeModifiable(demande);

        articleDemandeRepository.delete(article);
    }

    // Vérifier les droits de consultation
    private void verifierAccesLecture(DemandeAide demande) {

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();
        String role = utilisateur.getRole().name();

        // ADMIN et DONATEUR peuvent consulter tous les articles
        if (role.equals("ADMIN") || role.equals("DONATEUR")) {
            return;
        }

        // Une organisation consulte uniquement ses propres demandes
        if (utilisateur instanceof OrganisationPartenaire organisation) {

            if (demande.getOrganisationPartenaire() != null
                    && demande.getOrganisationPartenaire().getId().equals(organisation.getId())) {
                return;
            }
        }

        // Un bénéficiaire consulte ses demandes et les demandes validées avec étude terminée
        if (utilisateur instanceof Beneficiaire beneficiaire) {

            if (demande.getBeneficiaire() != null
                    && demande.getBeneficiaire().getId().equals(beneficiaire.getId())) {
                return;
            }
            if (demandeAideVisibilite.estValideeAvecEtudeTerminee(demande)) {
                return;
            }
        }

        throw new AccessDeniedException(
                "Vous n'avez pas accès aux articles de cette demande."
        );
    }

    // Vérifier les droits d'ajout et de modification
    private void verifierAccesModification(DemandeAide demande) {

        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        // Organisation partenaire : uniquement ses propres demandes
        if (utilisateur instanceof OrganisationPartenaire organisation) {

            if (demande.getOrganisationPartenaire() != null
                    && demande.getOrganisationPartenaire().getId().equals(organisation.getId())) {
                return;
            }
        }

        // Bénéficiaire : uniquement ses propres demandes
        if (utilisateur instanceof Beneficiaire beneficiaire) {

            if (demande.getBeneficiaire() != null
                    && demande.getBeneficiaire().getId().equals(beneficiaire.getId())) {
                return;
            }
        }

        throw new AccessDeniedException(
                "Vous n'êtes pas autorisé à ajouter ou modifier les articles de cette demande."
        );
    }

    // Rechercher une demande
    private DemandeAide trouverDemande(Integer id) {

        return demandeAideRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Demande d'aide introuvable avec l'id : " + id
                ));
    }

    // Rechercher un article
    private ArticleDemande trouverArticle(Integer id) {

        return articleDemandeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Article introuvable avec l'id : " + id
                ));
    }

    // Vérifier que la demande peut encore être modifiée
    private void verifierDemandeModifiable(DemandeAide demande) {

        if (demande == null) {
            throw new BadRequestException(
                    "L'article doit être associé à une demande."
            );
        }

        if (demande.getTypeDemandeAide() != TypeDemandeAide.MATERIELLE) {
            throw new BadRequestException(
                    "Les articles sont réservés aux demandes d'aide matérielle."
            );
        }

        if (demande.getStatut() != StatutDemande.EN_ATTENTE) {
            throw new BadRequestException(
                    "Les articles ne peuvent être modifiés que si "
                            + "la demande est en attente."
            );
        }
    }

    // Comparer les prix
    private boolean memePrix(Double prix1, Double prix2) {

        if (prix1 == null && prix2 == null) {
            return true;
        }

        if (prix1 == null || prix2 == null) {
            return false;
        }

        return Double.compare(prix1, prix2) == 0;
    }

    // Vérifier les données de l'article
    private void validerArticle(ArticleDemandeRequestDTO dto) {

        if (dto == null) {
            throw new BadRequestException(
                    "Les données de l'article sont obligatoires."
            );
        }

        if (dto.getDesignation() == null || dto.getDesignation().trim().isEmpty()) {
            throw new BadRequestException(
                    "La désignation de l'article est obligatoire."
            );
        }

        if (dto.getQuantiteDemandee() == null || dto.getQuantiteDemandee() <= 0) {
            throw new BadRequestException(
                    "La quantité demandée doit être supérieure à zéro."
            );
        }

        if (dto.getUnite() == null || dto.getUnite().trim().isEmpty()) {
            throw new BadRequestException(
                    "L'unité de l'article est obligatoire."
            );
        }

        if (dto.getPrixUnitaireEstime() != null && dto.getPrixUnitaireEstime() < 0) {
            throw new BadRequestException(
                    "Le prix unitaire estimé ne peut pas être négatif."
            );
        }
    }
}
