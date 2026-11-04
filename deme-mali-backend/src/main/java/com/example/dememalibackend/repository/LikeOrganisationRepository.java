
package com.example.dememalibackend.repository;

import com.example.dememalibackend.entity.LikeOrganisation;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LikeOrganisationRepository
        extends JpaRepository<LikeOrganisation, Integer> {

    Optional<LikeOrganisation> findByDonateur_IdAndOrganisation_Id(
            Integer donateurId,
            Integer organisationId
    );

    boolean existsByDonateur_IdAndOrganisation_Id(
            Integer donateurId,
            Integer organisationId
    );

    List<LikeOrganisation> findByDonateur_Id(Integer donateurId);

    long countByOrganisation_Id(Integer organisationId);
}
