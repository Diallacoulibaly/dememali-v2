package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.OrganisationPartenaireRequestDTO;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.mappers.BeneficiaireParticulierMapper;
import com.example.dememalibackend.mappers.OrganisationPartenaireMapper;
import com.example.dememalibackend.repository.BeneficiairePartenaireRepository;
import com.example.dememalibackend.repository.LikeOrganisationRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.repository.UtilisateurRepository;
import com.example.dememalibackend.service.UtilisateurService;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;

class OrganisationPartenaireServiceImplInscriptionTest {

    private final OrganisationPartenaireRepository organisations =
            mock(OrganisationPartenaireRepository.class);
    private final UtilisateurRepository utilisateurs = mock(UtilisateurRepository.class);
    private final OrganisationPartenaireServiceImpl service = new OrganisationPartenaireServiceImpl(
            organisations,
            mock(OrganisationPartenaireMapper.class),
            mock(BeneficiairePartenaireRepository.class),
            mock(BeneficiaireParticulierMapper.class),
            mock(UtilisateurService.class),
            mock(PasswordEncoder.class),
            mock(LikeOrganisationRepository.class),
            mock(CustomUserDetailsService.class),
            utilisateurs
    );

    @Test
    void refuseUnTelephoneDejaUtiliseAvantLaSauvegarde() {
        OrganisationPartenaireRequestDTO dto = OrganisationPartenaireRequestDTO.builder()
                .telephone(" 70000000 ")
                .motDePasse("secret123")
                .build();
        when(utilisateurs.existsByTelephone("70000000")).thenReturn(true);

        BadRequestException erreur = assertThrows(BadRequestException.class,
                () -> service.creer(dto, null));

        assertEquals("Ce numéro de téléphone est déjà utilisé.", erreur.getMessage());
        verify(utilisateurs).existsByTelephone("70000000");
        verifyNoInteractions(organisations);
    }
}
