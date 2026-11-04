
package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.ArticleDemandeRequestDTO;
import com.example.dememalibackend.dto.ArticleDemandeResponseDTO;
import java.util.List;

public interface ArticleDemandeService {

    // Ajoute un article à une demande d'aide matérielle.
    ArticleDemandeResponseDTO ajouter(Integer demandeId, ArticleDemandeRequestDTO dto);

    // Recherche un article par son identifiant.
    ArticleDemandeResponseDTO getById(Integer id);

    // Récupère tous les articles d'une demande.
    List<ArticleDemandeResponseDTO> getByDemande(Integer demandeId);

    // Modifie un article d'une demande encore en attente.
    ArticleDemandeResponseDTO modifier(Integer id, ArticleDemandeRequestDTO dto);

    // Supprime un article d'une demande encore en attente.
    void supprimer(Integer id);
}
