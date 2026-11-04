package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.BadgeDonateurDTO;

import java.util.List;

public interface BadgeService {

    // Afficher les badges et la progression du semestre actuel
    List<BadgeDonateurDTO> getBadgesSemestreActuel(Integer donateurId);

    // Afficher les badges et la progression d'un semestre précis
    List<BadgeDonateurDTO> getBadgesSemestre(
            Integer donateurId,
            Integer annee,
            String semestre
    );

    // Consulter l'historique des badges déjà obtenus
    List<BadgeDonateurDTO> getHistorique(Integer donateurId);
}