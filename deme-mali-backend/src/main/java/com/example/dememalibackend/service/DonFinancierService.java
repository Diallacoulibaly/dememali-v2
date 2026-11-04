package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.ComptabiliteDonsResponseDTO;
import com.example.dememalibackend.dto.DonFinancierRequestDTO;
import com.example.dememalibackend.dto.DonFinancierResponseDTO;

import java.util.List;

public interface DonFinancierService {

    DonFinancierResponseDTO creer(
            DonFinancierRequestDTO dto
    );

    DonFinancierResponseDTO getById(
            Integer id
    );

    List<DonFinancierResponseDTO> getAll();

    List<DonFinancierResponseDTO> getByDonateur(
            Integer donateurId
    );

    List<DonFinancierResponseDTO> getByDemande(
            Integer demandeAideId
    );

    Double getTotalDons();

    Double getTotalDonsAffectes();

    Double getTotalDonsGeneraux();

    Double getTotalDonsOrganisation(
            Integer organisationId
    );

    ComptabiliteDonsResponseDTO getComptabiliteOrganisation(
            Integer organisationId
    );

    List<DonFinancierResponseDTO> getDonsOrganisation(
            Integer organisationId
    );
    //verifier le montant saisi par le donateur pour voir si c'est egal ou pas au montant restant pour  la collecte
    boolean verifierMontant(Integer demandeAideId, Double montant);
    List<DonFinancierResponseDTO> getDonsAffectablesParOrganisation(
            Integer organisationId
    );

}