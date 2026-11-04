package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.dto.DemandeAideResponseDTO;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.mappers.DemandeAideMapper;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.DonRepository;
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
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DemandeAideServiceImplAccesTest {

    @Mock private DemandeAideRepository demandes;
    @Mock private DemandeAideMapper mapper;
    @Mock private DonRepository dons;
    @Mock private CustomUserDetailsService utilisateurs;
    @Mock private DemandeAideVisibilite visibilite;
    @InjectMocks private DemandeAideServiceImpl service;

    private DemandeAide demandeAutrui;

    @BeforeEach
    void preparer() {
        Beneficiaire connecte = new Beneficiaire();
        connecte.setId(10);
        connecte.setRole(RoleEnum.BENEFICIARE);
        when(utilisateurs.getUtilisateurConnecte()).thenReturn(connecte);

        Beneficiaire autre = new Beneficiaire();
        autre.setId(20);
        demandeAutrui = DemandeAide.builder()
                .id(2)
                .statut(StatutDemande.VALIDEE)
                .beneficiaire(autre)
                .build();
    }

    @Test
    void listeEtDetailSontLisiblesQuandLaDemandeEstPubliee() {
        when(visibilite.estValideeAvecEtudeTerminee(demandeAutrui)).thenReturn(true);
        when(demandes.findAll()).thenReturn(List.of(demandeAutrui));
        when(demandes.findById(2)).thenReturn(Optional.of(demandeAutrui));
        when(mapper.toDTO(demandeAutrui)).thenReturn(new DemandeAideResponseDTO());

        assertEquals(1, service.getAll().size());
        service.getById(2);
    }

    @Test
    void detailEstRefuseQuandLaDemandeNeRemplitPasLeCritere() {
        when(demandes.findById(2)).thenReturn(Optional.of(demandeAutrui));

        assertThrows(AccessDeniedException.class, () -> service.getById(2));
    }

    @Test
    void droitDeLectureNePermetPasDeModifierLaDemandeAutrui() {
        when(demandes.findById(2)).thenReturn(Optional.of(demandeAutrui));

        assertThrows(AccessDeniedException.class, () -> service.modifier(2, null));
        verify(demandes, never()).save(any());
    }
}
