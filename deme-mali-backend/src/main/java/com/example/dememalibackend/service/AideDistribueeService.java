
package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.AideDistribueeRequestDTO;
import com.example.dememalibackend.dto.AideDistribueeResponseDTO;

import java.util.List;

public interface AideDistribueeService {

    AideDistribueeResponseDTO creer(AideDistribueeRequestDTO dto);

    AideDistribueeResponseDTO getById(Integer id);

    List<AideDistribueeResponseDTO> getAll();

    List<AideDistribueeResponseDTO> getByDemandeAide(Integer demandeAideId);

    List<AideDistribueeResponseDTO> getByBeneficiaire(Integer beneficiaireId);

    List<AideDistribueeResponseDTO> getDistribueesByDemandeAide(
            Integer demandeAideId);

    List<AideDistribueeResponseDTO> getDistribueesByBeneficiaire(
            Integer beneficiaireId);

    AideDistribueeResponseDTO getAvecAffectationsFinancieres(Integer id);

    AideDistribueeResponseDTO getAvecAffectationsMaterielles(Integer id);

    AideDistribueeResponseDTO marquerCommeDistribuee(Integer id);

    void supprimer(Integer id);
    List<AideDistribueeResponseDTO> getByOrganisation(
            Integer organisationId
    );
}
