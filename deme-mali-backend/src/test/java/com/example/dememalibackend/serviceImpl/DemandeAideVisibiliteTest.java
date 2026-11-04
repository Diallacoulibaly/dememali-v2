package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.Enum.StatutEtudeTerrain;
import com.example.dememalibackend.Enum.StatutCollecte;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.repository.EtudeTerrainRepository;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class DemandeAideVisibiliteTest {

    private final EtudeTerrainRepository etudes = mock(EtudeTerrainRepository.class);
    private final DemandeAideVisibilite visibilite = new DemandeAideVisibilite(etudes);

    @Test
    void rendVisibleUneDemandeValideeAvecEtudeTerminee() {
        DemandeAide demande = demande(StatutDemande.VALIDEE);
        when(etudes.existsByDemandeAideIdAndStatus(2, StatutEtudeTerrain.TERMINEE))
                .thenReturn(true);

        assertTrue(visibilite.estValideeAvecEtudeTerminee(demande));
    }

    @Test
    void cacheUneDemandeNonValideeMemeSiSonEtudeEstTerminee() {
        assertFalse(visibilite.estValideeAvecEtudeTerminee(demande(StatutDemande.EN_ATTENTE)));
        verifyNoInteractions(etudes);
    }

    @Test
    void cacheUneDemandeValideeSansEtudeTerminee() {
        assertFalse(visibilite.estValideeAvecEtudeTerminee(demande(StatutDemande.VALIDEE)));
    }

    @Test
    void demandeValideeAvecCollecteEnCoursEstOuverteAuxDonateurs() {
        DemandeAide demande = demande(StatutDemande.VALIDEE);
        demande.setStatutCollecte(StatutCollecte.EN_COURS);

        assertTrue(visibilite.estOuverteAuxDons(demande));
        verifyNoInteractions(etudes);
    }

    @Test
    void demandeNonValideeOuCollecteTermineeEstFermeeAuxDonateurs() {
        DemandeAide nonValidee = demande(StatutDemande.EN_ATTENTE);
        nonValidee.setStatutCollecte(StatutCollecte.EN_COURS);
        DemandeAide terminee = demande(StatutDemande.VALIDEE);
        terminee.setStatutCollecte(StatutCollecte.TERMINEE);

        assertFalse(visibilite.estOuverteAuxDons(nonValidee));
        assertFalse(visibilite.estOuverteAuxDons(terminee));
    }

    private DemandeAide demande(StatutDemande statut) {
        OrganisationPartenaire organisation = new OrganisationPartenaire();
        return DemandeAide.builder()
                .id(2)
                .organisationPartenaire(organisation)
                .statut(statut)
                .build();
    }
}
