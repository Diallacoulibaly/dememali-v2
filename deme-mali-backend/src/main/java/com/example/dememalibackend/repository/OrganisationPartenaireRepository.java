package com.example.dememalibackend.repository;



import com.example.dememalibackend.Enum.StatutValidation;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface OrganisationPartenaireRepository
        extends JpaRepository<OrganisationPartenaire, Integer> {

    Optional<OrganisationPartenaire> findByEmail(String email);

    boolean existsByEmail(String email);

    Optional<OrganisationPartenaire> findByNif(String nif);

    boolean existsByNif(String nif);
    List<OrganisationPartenaire> findByStatutValidation(
            StatutValidation statutValidation
    );



}