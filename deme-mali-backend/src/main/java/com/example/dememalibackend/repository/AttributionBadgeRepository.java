package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.AttributionBadge;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AttributionBadgeRepository
        extends JpaRepository<AttributionBadge, Integer> {

    // Vérifier si le badge a déjà été attribué au donateur
    // pendant ce semestre et cette année
    boolean existsByDonateur_IdAndBadge_IdAndSemestreAndAnnee(
            Integer donateurId,
            Integer badgeId,
            String semestre,
            Integer annee
    );

    // Récupérer les badges obtenus pendant un semestre précis
    List<AttributionBadge> findByDonateur_IdAndSemestreAndAnnee(
            Integer donateurId,
            String semestre,
            Integer annee
    );

    // Récupérer l'historique des badges du donateur
    List<AttributionBadge>
    findByDonateur_IdOrderByAnneeDescSemestreDesc(
            Integer donateurId
    );
}