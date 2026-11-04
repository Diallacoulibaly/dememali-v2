
package com.example.dememalibackend.repository;

import com.example.dememalibackend.Enum.StatutReception;
import com.example.dememalibackend.entity.DonMateriel;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface DonMaterielRepository
        extends JpaRepository<DonMateriel, Integer> {

    List<DonMateriel> findByDonateurId(Integer donateurId);

    List<DonMateriel> findByDemandeAideId(Integer demandeAideId);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT d FROM DonMateriel d WHERE d.id = :id")
    Optional<DonMateriel> findByIdForUpdate(

            @Param("id") Integer id);
   //don lier a une demande lier a une organisation ou directement lier a l'organisation
    @Query("""
    SELECT d
    FROM DonMateriel d
    LEFT JOIN d.demandeAide da
    WHERE d.organisationPartenaire.id = :organisationId
       OR da.organisationPartenaire.id = :organisationId
    """)
    List<DonMateriel> findByOrganisation(@Param("organisationId") Integer organisationId);
    // Récupérer les dons matériels d'un donateur réceptionnés pendant une période donnée,
// en filtrant selon la date de réception et le statut de réception.
// Cette méthode permet de sélectionner uniquement les dons partiellement reçus
// ou entièrement reçus, afin de calculer leur valeur pour les badges semestriels.
    List<DonMateriel> findByDonateur_IdAndDateReceptionBetweenAndStatutReceptionIn(
            Integer donateurId,
            LocalDate debut,
            LocalDate fin,
            Collection<StatutReception> statuts
    );

//don lier a une organisation
    @Query("""
    SELECT d
    FROM DonMateriel d
    WHERE d.organisationPartenaire.id = :organisationId
      AND d.demandeAide IS NULL
      AND d.statutReception IN :statuts
      AND d.quantiteRecue > 0
    """)
    List<DonMateriel> findDonsDirectsReceptionnes(
            @Param("organisationId") Integer organisationId,
            @Param("statuts") Collection<StatutReception> statuts);
}
