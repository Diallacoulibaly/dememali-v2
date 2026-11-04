
package com.example.dememalibackend.repository;

import com.example.dememalibackend.Enum.StatutPaiement;
import com.example.dememalibackend.entity.DonFinancier;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface DonFinancierRepository
        extends JpaRepository<DonFinancier, Integer> {

    List<DonFinancier> findByDonateurId(Integer donateurId);

    List<DonFinancier> findByDemandeAideId(Integer demandeAideId);

    @Query("""
        SELECT COALESCE(SUM(d.montant), 0)
        FROM DonFinancier d
        WHERE EXISTS (
            SELECT p.id
            FROM PaiementDon p
            WHERE p.donFinancier = d
            AND p.statut = :statut
        )
        """)
    Double calculerTotalDons(
            @Param("statut") StatutPaiement statut);

    @Query("""
        SELECT COALESCE(SUM(d.montant), 0)
        FROM DonFinancier d
        WHERE d.demandeAide IS NOT NULL
        AND EXISTS (
            SELECT p.id
            FROM PaiementDon p
            WHERE p.donFinancier = d
            AND p.statut = :statut
        )
        """)
    Double calculerTotalDonsAffectes(
            @Param("statut") StatutPaiement statut);

    @Query("""
        SELECT COALESCE(SUM(d.montant), 0)
        FROM DonFinancier d
        WHERE d.demandeAide IS NULL
        AND EXISTS (
            SELECT p.id
            FROM PaiementDon p
            WHERE p.donFinancier = d
            AND p.statut = :statut
        )
        """)
    Double calculerTotalDonsGeneraux(
            @Param("statut") StatutPaiement statut);
//don lier a une demande de l'organisation ou a organisation elle meme

    @Query("""
    SELECT d
    FROM DonFinancier d
    LEFT JOIN d.demandeAide da
    WHERE d.organisationPartenaire.id = :organisationId
       OR da.organisationPartenaire.id = :organisationId
    """)
    List<DonFinancier> findByOrganisationId(@Param("organisationId") Integer organisationId);

    @Query("""
    SELECT COALESCE(SUM(d.montant), 0)
    FROM DonFinancier d
    LEFT JOIN d.demandeAide da
    WHERE (d.organisationPartenaire.id = :organisationId
           OR da.organisationPartenaire.id = :organisationId)
    AND EXISTS (
        SELECT p.id FROM PaiementDon p
        WHERE p.donFinancier = d AND p.statut = :statut
    )
    """)
    Double calculerTotalDonsOrganisation(
            @Param("organisationId") Integer organisationId,
            @Param("statut") StatutPaiement statut);
    @Query("""
        SELECT COALESCE(SUM(d.montant), 0)
        FROM DonFinancier d
        WHERE d.donateur.id = :donateurId
        AND d.dateDon BETWEEN :debut AND :fin
        """)
    Double calculerTotalDonsParPeriode(
            @Param("donateurId") Integer donateurId,
            @Param("debut") LocalDate debut,
            @Param("fin") LocalDate fin);

    @Query("""
        SELECT COALESCE(SUM(d.montant), 0)
        FROM DonFinancier d
        WHERE d.donateur.id = :donateurId
        AND d.dateDon BETWEEN :debut AND :fin
        AND EXISTS (
            SELECT p.id
            FROM PaiementDon p
            WHERE p.donFinancier = d
            AND p.statut = :statut
        )
        """)
    Double calculerTotalDonsConfirmesParPeriode(
            @Param("donateurId") Integer donateurId,
            @Param("debut") LocalDate debut,
            @Param("fin") LocalDate fin,
            @Param("statut") StatutPaiement statut);


    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT d FROM DonFinancier d WHERE d.id = :id")
    Optional<DonFinancier> findByIdForUpdate(
            @Param("id") Integer id);

//affectation de don lier à organisation
    @Query("""
    SELECT d
    FROM DonFinancier d
    WHERE d.organisationPartenaire.id = :organisationId
      AND d.demandeAide IS NULL
      AND EXISTS (
          SELECT p.id
          FROM PaiementDon p
          WHERE p.donFinancier = d
          AND p.statut = :statut
      )
    """)
    List<DonFinancier> findDonsDirectsConfirmes(
            @Param("organisationId") Integer organisationId,
            @Param("statut") StatutPaiement statut);

}
