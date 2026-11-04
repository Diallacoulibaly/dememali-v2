package com.example.dememalibackend.repository;

import com.example.dememalibackend.Enum.StatutCollecte;
import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.TypeDemande;
import com.example.dememalibackend.Enum.TypeUrgence;
import com.example.dememalibackend.dto.DemandeAideResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DemandeAideRepository
        extends JpaRepository<DemandeAide, Integer> {
    List<DemandeAide>
    findByOrganisationPartenaireIdAndStatutAndStatutCollecteNot(
            Integer organisationPartenaireId,
            StatutDemande statut,
            StatutCollecte statutCollecte
    );
    List<DemandeAide> findByOrganisationPartenaireIdAndStatutAndStatutCollecte(
            Integer organisationPartenaireId,
            StatutDemande statut,
            StatutCollecte statutCollecte
    );

    List<DemandeAide> findByStatut(StatutDemande statut);

    List<DemandeAide> findByBeneficiaireId(Integer beneficiaireId);

    List<DemandeAide> findByCategorieDemandeId(
            Integer categorieDemandeId);

    List<DemandeAide> findByOrganisationPartenaireId(
            Integer organisationPartenaireId);

    List<DemandeAide> findByTypeDemande(TypeDemande typeDemande);

    List<DemandeAide> findByNiveauUrgence(TypeUrgence niveauUrgence);
    List<DemandeAide> findByStatutAndStatutCollecteNot(
            StatutDemande statut,
            StatutCollecte statutCollecte
    );
    // demande non distribuee
    @Query("""
    SELECT d
    FROM DemandeAide d
    WHERE d.organisationPartenaire.id = :organisationId
      AND d.statut = :statut
      AND d.statutCollecte = :statutCollecte
      AND NOT EXISTS (
          SELECT a.id
          FROM AideDistribuee a
          WHERE a.demandeAide.id = d.id
      )
    """)
    List<DemandeAide> findDemandesNonDistribuees(
            @Param("organisationId") Integer organisationId,
            @Param("statut") StatutDemande statut,
            @Param("statutCollecte") StatutCollecte statutCollecte
    );
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT d FROM DemandeAide d WHERE d.id = :id")
    Optional<DemandeAide> findByIdForUpdate(
            @Param("id") Integer id);

    List<DemandeAide>
    findByOrganisationPartenaireIdAndStatutNotAndStatutCollecteNot(
            Integer organisationPartenaireId,
            StatutDemande statut,
            StatutCollecte statutCollecte
    );

    long countByStatut(StatutDemande statut);

    long countByOrganisationPartenaireId(Integer organisationPartenaireId);

    long countByOrganisationPartenaireIdAndStatut(Integer organisationPartenaireId, StatutDemande statut);

    @Query("SELECT COALESCE(SUM(d.montantCollecte), 0.0) FROM DemandeAide d")
    Double calculerTotalMontantCollecte();

    @Query("SELECT COALESCE(SUM(d.montantCollecte), 0.0) FROM DemandeAide d WHERE d.organisationPartenaire.id = :organisationId")
    Double calculerTotalMontantCollecteOrganisation(@Param("organisationId") Integer organisationId);
}