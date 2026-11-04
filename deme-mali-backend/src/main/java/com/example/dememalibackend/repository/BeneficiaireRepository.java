package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.Enum.StatutBeneficiaire;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface BeneficiaireRepository
        extends JpaRepository<Beneficiaire, Integer> {

    List<Beneficiaire> findByStatut(
            StatutBeneficiaire statut
    );

    List<Beneficiaire> findByOrganisationPartenaireId(
            Integer organisationId
    );

    List<Beneficiaire> findByOrganisationPartenaireIdAndStatut(
            Integer organisationId,
            StatutBeneficiaire statut
    );

    long countByOrganisationPartenaireId(Integer organisationId);
}