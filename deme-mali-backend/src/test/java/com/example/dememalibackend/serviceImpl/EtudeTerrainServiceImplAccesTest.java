package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.EtudeTerrainRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertNull;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class EtudeTerrainServiceImplAccesTest {

    @Mock private DemandeAideRepository demandes;
    @Mock private EtudeTerrainRepository etudes;
    @Mock private CustomUserDetailsService utilisateurs;
    @Mock private DemandeAideVisibilite visibilite;
    @InjectMocks private EtudeTerrainServiceImpl service;

    @Test
    void donateurSansDonPeutConsulterEtudeDuneDemandeOuverte() {
        DemandeAide demande = preparerDemandeEtDonateur();
        when(visibilite.estOuverteAuxDons(demande)).thenReturn(true);
        when(etudes.findByDemandeAideId(2)).thenReturn(Optional.empty());

        assertNull(service.getByDemande(2));
    }

    @Test
    void donateurSansDonNePeutPasConsulterEtudeDuneDemandeFermee() {
        preparerDemandeEtDonateur();

        assertThrows(AccessDeniedException.class, () -> service.getByDemande(2));
    }

    private DemandeAide preparerDemandeEtDonateur() {
        Utilisateur donateur = new Utilisateur();
        donateur.setId(10);
        donateur.setRole(RoleEnum.DONATEUR);
        when(utilisateurs.getUtilisateurConnecte()).thenReturn(donateur);

        DemandeAide demande = DemandeAide.builder().id(2).build();
        when(demandes.findById(2)).thenReturn(Optional.of(demande));
        return demande;
    }
}
