package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.Donateur;
import com.example.dememalibackend.mappers.ImageDemandeMapper;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.ImageDemandeRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.access.AccessDeniedException;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ImageDemandeServiceImplAccesTest {

    @Mock private DemandeAideRepository demandes;
    @Mock private ImageDemandeRepository images;
    @Mock private ImageDemandeMapper mapper;
    @Mock private CustomUserDetailsService utilisateurs;
    @Mock private DemandeAideVisibilite visibilite;
    @InjectMocks private ImageDemandeServiceImpl service;

    private Beneficiaire connecte;

    @BeforeEach
    void preparer() {
        connecte = new Beneficiaire();
        connecte.setId(10);
        connecte.setRole(RoleEnum.BENEFICIARE);
    }

    @Test
    void beneficiairePeutLireLesImagesDeSaPropreDemande() {
        when(utilisateurs.getUtilisateurConnecte()).thenReturn(connecte);
        DemandeAide demande = DemandeAide.builder().id(2).beneficiaire(connecte).build();
        when(demandes.findById(2)).thenReturn(Optional.of(demande));
        when(images.findByDemandeAideId(2)).thenReturn(List.of());

        assertEquals(List.of(), service.getByDemande(2));
    }

    @Test
    void beneficiairePeutLireLesImagesDuneDemandePubliee() {
        when(utilisateurs.getUtilisateurConnecte()).thenReturn(connecte);
        DemandeAide demande = DemandeAide.builder().id(2).build();
        when(demandes.findById(2)).thenReturn(Optional.of(demande));
        when(visibilite.estValideeAvecEtudeTerminee(demande)).thenReturn(true);
        when(images.findByDemandeAideId(2)).thenReturn(List.of());

        assertEquals(List.of(), service.getByDemande(2));
    }

    @Test
    void beneficiaireNePeutPasLireLesImagesDuneAutreDemande() {
        when(utilisateurs.getUtilisateurConnecte()).thenReturn(connecte);
        DemandeAide demande = DemandeAide.builder().id(2).build();
        when(demandes.findById(2)).thenReturn(Optional.of(demande));

        assertThrows(AccessDeniedException.class, () -> service.getByDemande(2));
    }

    @Test
    void donateurSansDonPeutLireLesImagesDuneDemandeOuverte() {
        Donateur donateur = new Donateur();
        donateur.setId(10);
        donateur.setRole(RoleEnum.DONATEUR);
        when(utilisateurs.getUtilisateurConnecte()).thenReturn(donateur);
        DemandeAide demande = DemandeAide.builder().id(2).build();
        when(demandes.findById(2)).thenReturn(Optional.of(demande));
        when(visibilite.estOuverteAuxDons(demande)).thenReturn(true);
        when(images.findByDemandeAideId(2)).thenReturn(List.of());

        assertEquals(List.of(), service.getByDemande(2));
    }

    @Test
    void donateurSansDonNePeutPasLireLesImagesDuneDemandeFermee() {
        Donateur donateur = new Donateur();
        donateur.setId(10);
        donateur.setRole(RoleEnum.DONATEUR);
        when(utilisateurs.getUtilisateurConnecte()).thenReturn(donateur);
        DemandeAide demande = DemandeAide.builder().id(2).build();
        when(demandes.findById(2)).thenReturn(Optional.of(demande));

        assertThrows(AccessDeniedException.class, () -> service.getByDemande(2));
    }
}
