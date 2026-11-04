package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import com.example.dememalibackend.Enum.StatutCollecte;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.repository.EtudeTerrainRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class DemandeAideVisibilite {

    private final EtudeTerrainRepository etudeTerrainRepository;

    public boolean estValideeAvecEtudeTerminee(DemandeAide demande) {
        return demande != null
                && demande.getId() != null
                && demande.getOrganisationPartenaire() != null
                && demande.getStatut() == StatutDemande.VALIDEE
                && etudeTerrainRepository.existsByDemandeAideIdAndStatus(
                        demande.getId(), StatutEtudeTerrain.TERMINEE);
    }

    public boolean estOuverteAuxDons(DemandeAide demande) {
        return demande != null
                && demande.getStatut() == StatutDemande.VALIDEE
                && demande.getStatutCollecte() != StatutCollecte.TERMINEE;
    }
}
