
package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.ArticleDemande;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ArticleDemandeRepository extends JpaRepository<ArticleDemande, Integer> {

    // Récupère les articles appartenant à une demande précise.
    List<ArticleDemande> findByDemandeAideId(Integer demandeId);
}
