package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.ArticleDemandeResponseDTO;
import com.example.dememalibackend.dto.DemandeAideResponseDTO;
import com.example.dememalibackend.entity.ArticleDemande;
import com.example.dememalibackend.entity.DemandeAide;
import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.stream.Collectors;

@Component
public class DemandeAideMapper {

    public DemandeAideResponseDTO toDTO(DemandeAide entity) {

        if (entity == null) {
            return null;
        }

        return DemandeAideResponseDTO.builder()
                .id(entity.getId())
                .titre(entity.getTitre())
                .descriptionSituation(entity.getDescriptionSituation())
                .niveauUrgence(entity.getNiveauUrgence())
                .statut(entity.getStatut())
                .dateCreation(entity.getDateCreation())
                .motif(entity.getMotif())
                .nombrePersonne(entity.getNombrePersonne())
                .montantNecessaire(entity.getMontantNecessaire())
                .dateValidation(entity.getDateValidation())
                .statutCollecte(entity.getStatutCollecte())
                .montantCollecte(entity.getMontantCollecte())
                .typeDemande(entity.getTypeDemande())
                .typeDemandeAide(entity.getTypeDemandeAide())
                .nombrePersonne(entity.getNombrePersonne())

                .beneficiaireId(
                        entity.getBeneficiaire() != null
                                ? entity.getBeneficiaire().getId()
                                : null
                )
                .beneficiaireNom(
                        entity.getBeneficiaire() != null
                                ? entity.getBeneficiaire().getNom()
                                : null
                )
                .beneficiairePrenom(
                        entity.getBeneficiaire() != null
                                ? entity.getBeneficiaire().getPrenom()
                                : null
                )
                .categorieDemandeId(
                        entity.getCategorieDemande() != null
                                ? entity.getCategorieDemande().getId()
                                : null
                )
                .categorieDemandeNom(
                        entity.getCategorieDemande() != null
                                ? entity.getCategorieDemande().getNom()
                                : null
                )
                .organisationPartenaireId(
                        entity.getOrganisationPartenaire() != null
                                ? entity.getOrganisationPartenaire().getId()
                                : null
                )
                .articles(
                        entity.getArticles() != null
                                ? entity.getArticles().stream()
                                  .map(this::articleToDTO)
                                  .collect(Collectors.toList())
                                : Collections.emptyList()
                )
                .build();
    }

    private ArticleDemandeResponseDTO articleToDTO(
            ArticleDemande article) {

        if (article == null) {
            return null;
        }

        return ArticleDemandeResponseDTO.builder()
                .id(article.getId())
                .designation(article.getDesignation())
                .quantiteDemandee(article.getQuantiteDemandee())
                .unite(article.getUnite())
                .prixUnitaireEstime(article.getPrixUnitaireEstime())
                .build();
    }
}