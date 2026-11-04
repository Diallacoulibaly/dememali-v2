
package com.example.dememalibackend.repository;

import com.example.dememalibackend.Enum.StatutPaiement;
import com.example.dememalibackend.entity.PaiementDon;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface PaiementDonRepository
        extends JpaRepository<PaiementDon, Integer> {

    Optional<PaiementDon> findByReferenceTransaction(
            String referenceTransaction);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("""
        SELECT p FROM PaiementDon p
        WHERE p.referenceTransaction = :reference
        """)
    Optional<PaiementDon> findByReferenceTransactionForUpdate(
            @Param("reference") String reference);

    boolean existsByDonFinancier_IdAndStatut(
            Integer donFinancierId,
            StatutPaiement statut);


}
