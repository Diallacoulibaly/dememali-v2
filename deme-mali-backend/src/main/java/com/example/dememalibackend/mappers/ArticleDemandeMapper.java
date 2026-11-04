
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.ArticleDemandeResponseDTO;
import com.example.dememalibackend.entity.ArticleDemande;
import org.springframework.stereotype.Component;

@Component
public class ArticleDemandeMapper {

    public ArticleDemandeResponseDTO toDTO(ArticleDemande article) {
        if (article == null) {
            return null;
        }

        ArticleDemandeResponseDTO dto = new ArticleDemandeResponseDTO();
        dto.setId(article.getId());
        dto.setDesignation(article.getDesignation());
        dto.setQuantiteDemandee(article.getQuantiteDemandee());
        dto.setUnite(article.getUnite());
        dto.setPrixUnitaireEstime(article.getPrixUnitaireEstime());

        return dto;
    }
}
