package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.StatutBeneficiaire;
import com.example.dememalibackend.dto.BeneficiaireRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireResponseDTO;
import com.example.dememalibackend.entity.Admin;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.BeneficiaireMapper;
import com.example.dememalibackend.repository.BeneficiaireRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.service.BeneficiaireService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class BeneficiaireServiceImpl implements BeneficiaireService {

    private final BeneficiaireRepository beneficiaireRepository;
    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final PasswordEncoder passwordEncoder;
    private final CustomUserDetailsService customUserDetailsService;

    private Utilisateur getUtilisateurConnecteSiAuthentifie() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() || authentication instanceof AnonymousAuthenticationToken) {
            return null;
        }
        return customUserDetailsService.getUtilisateurConnecte();
    }

    private void verifierCreation(Integer organisationId) {
        Utilisateur utilisateur = getUtilisateurConnecteSiAuthentifie();
        if (utilisateur == null) return;

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            if (Objects.equals(organisation.getId(), organisationId)) return;
            throw new AccessDeniedException("Vous ne pouvez créer un bénéficiaire que pour votre organisation.");
        }

        throw new AccessDeniedException("Vous n'avez pas l'autorisation de créer un bénéficiaire.");
    }

    private void verifierAccesLecture(Beneficiaire beneficiaire) {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) return;

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            if (beneficiaire.getOrganisationPartenaire() != null &&
                    Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), organisation.getId())) return;
            throw new AccessDeniedException("Vous ne pouvez consulter que les bénéficiaires de votre organisation.");
        }

        if (utilisateur instanceof Beneficiaire) {
            if (Objects.equals(utilisateur.getId(), beneficiaire.getId())) return;
            throw new AccessDeniedException("Vous ne pouvez consulter que vos propres informations.");
        }

        throw new AccessDeniedException("Vous n'avez pas l'autorisation de consulter ce bénéficiaire.");
    }

    private void verifierAccesGestion(Beneficiaire beneficiaire) {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) return;

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            if (beneficiaire.getOrganisationPartenaire() != null &&
                    Objects.equals(beneficiaire.getOrganisationPartenaire().getId(), organisation.getId())) return;
            throw new AccessDeniedException("Vous ne pouvez gérer que les bénéficiaires de votre organisation.");
        }

        throw new AccessDeniedException("Vous n'avez pas l'autorisation de gérer ce bénéficiaire.");
    }

    private void verifierAccesOrganisation(Integer organisationId) {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) return;

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            if (Objects.equals(organisation.getId(), organisationId)) return;
            throw new AccessDeniedException("Vous ne pouvez consulter que les bénéficiaires de votre organisation.");
        }

        throw new AccessDeniedException("Vous n'avez pas l'autorisation de consulter ces bénéficiaires.");
    }

    @Override
    public BeneficiaireResponseDTO creer(BeneficiaireRequestDTO dto) {
        if (dto.getMotDePasse() == null || dto.getMotDePasse().isBlank()) {
            throw new RuntimeException("Le mot de passe est obligatoire");
        }

        verifierCreation(dto.getOrganisationPartenaireId());

        OrganisationPartenaire organisation = organisationPartenaireRepository.findById(dto.getOrganisationPartenaireId())
                .orElseThrow(() -> new RuntimeException("Organisation partenaire introuvable"));

        Beneficiaire beneficiaire = BeneficiaireMapper.toEntity(dto, organisation);
        beneficiaire.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));

        Beneficiaire sauvegarde = beneficiaireRepository.save(beneficiaire);
        return BeneficiaireMapper.toDTO(sauvegarde);
    }

    @Override
    @Transactional(readOnly = true)
    public BeneficiaireResponseDTO trouverParId(Integer id) {
        Beneficiaire beneficiaire = beneficiaireRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Bénéficiaire introuvable"));

        verifierAccesLecture(beneficiaire);
        return BeneficiaireMapper.toDTO(beneficiaire);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BeneficiaireResponseDTO> trouverAcceptesParOrganisation(Integer organisationId) {
        verifierAccesOrganisation(organisationId);

        return beneficiaireRepository.findByOrganisationPartenaireIdAndStatut(
                        organisationId, StatutBeneficiaire.ACCEPTE)
                .stream()
                .map(BeneficiaireMapper::toDTO)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<BeneficiaireResponseDTO> trouverTous() {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) {
            return beneficiaireRepository.findAll().stream().map(BeneficiaireMapper::toDTO).toList();
        }

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            return beneficiaireRepository.findByOrganisationPartenaireId(organisation.getId())
                    .stream().map(BeneficiaireMapper::toDTO).toList();
        }

        if (utilisateur instanceof Beneficiaire) {
            return beneficiaireRepository.findById(utilisateur.getId())
                    .map(b -> List.of(BeneficiaireMapper.toDTO(b)))
                    .orElseGet(List::of);
        }

        throw new AccessDeniedException("Vous n'avez pas l'autorisation de consulter les bénéficiaires.");
    }

    @Override
    @Transactional(readOnly = true)
    public List<BeneficiaireResponseDTO> trouverEnAttente() {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) {
            return beneficiaireRepository.findByStatut(StatutBeneficiaire.EN_ATTENTE)
                    .stream().map(BeneficiaireMapper::toDTO).toList();
        }

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            return beneficiaireRepository.findByOrganisationPartenaireIdAndStatut(
                            organisation.getId(), StatutBeneficiaire.EN_ATTENTE)
                    .stream().map(BeneficiaireMapper::toDTO).toList();
        }

        throw new AccessDeniedException("Vous n'avez pas l'autorisation de consulter les bénéficiaires en attente.");
    }

    @Override
    @Transactional(readOnly = true)
    public List<BeneficiaireResponseDTO> trouverParOrganisation(Integer organisationId) {
        verifierAccesOrganisation(organisationId);

        return beneficiaireRepository.findByOrganisationPartenaireId(organisationId)
                .stream().map(BeneficiaireMapper::toDTO).toList();
    }

    @Override
    public BeneficiaireResponseDTO accepter(Integer beneficiaireId) {
        Beneficiaire beneficiaire = beneficiaireRepository.findById(beneficiaireId)
                .orElseThrow(() -> new RuntimeException("Bénéficiaire introuvable"));

        verifierAccesGestion(beneficiaire);

        beneficiaire.setStatut(StatutBeneficiaire.ACCEPTE);
        beneficiaire.setDateValidation(LocalDate.now());
        beneficiaire.setMotifRefus(null);

        Beneficiaire sauvegarde = beneficiaireRepository.save(beneficiaire);
        return BeneficiaireMapper.toDTO(sauvegarde);
    }

    @Override
    public BeneficiaireResponseDTO refuser(Integer beneficiaireId, String motif) {
        Beneficiaire beneficiaire = beneficiaireRepository.findById(beneficiaireId)
                .orElseThrow(() -> new RuntimeException("Bénéficiaire introuvable"));

        verifierAccesGestion(beneficiaire);

        if (motif == null || motif.isBlank()) {
            throw new RuntimeException("Le motif du refus est obligatoire");
        }

        beneficiaire.setStatut(StatutBeneficiaire.REFUSE);
        beneficiaire.setDateValidation(LocalDate.now());
        beneficiaire.setMotifRefus(motif.trim());

        Beneficiaire sauvegarde = beneficiaireRepository.save(beneficiaire);
        return BeneficiaireMapper.toDTO(sauvegarde);
    }
}