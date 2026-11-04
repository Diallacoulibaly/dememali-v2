package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.Justificatif;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface JustificatifRepository
        extends JpaRepository<Justificatif, Integer> {

    List<Justificatif> findByDemandeAideId(Integer demandeAideId);

    List<Justificatif> findByTypeJustificatifId(
            Integer typeJustificatifId);
}
