package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.DonMaterielRequestDTO;
import com.example.dememalibackend.dto.DonMaterielResponseDTO;

import java.time.LocalDate;
import java.util.List;

public interface DonMaterielService {

    DonMaterielResponseDTO creer(DonMaterielRequestDTO dto);

    List<DonMaterielResponseDTO> getByDonateur(Integer donateurId);

    List<DonMaterielResponseDTO> getByDemande(Integer demandeAideId);

    DonMaterielResponseDTO confirmerReception(
            Integer donId,
            Integer quantiteRecue
    );

    DonMaterielResponseDTO refuser(
            Integer donId,
            String motifRefus
    );
    List<DonMaterielResponseDTO> getByOrganisation(
            Integer organisationId);
    // recupere les valeur en prix du don materiel (quantite recu dans le don materiel * par le prix unitaire dans detail rapport technique")
    Double calculerValeurMaterielleRecueParPeriode(
            Integer donateurId,
            LocalDate debut,
            LocalDate fin
    );

    List<DonMaterielResponseDTO> getDonsAffectablesParOrganisation(
            Integer organisationId
    );
}
