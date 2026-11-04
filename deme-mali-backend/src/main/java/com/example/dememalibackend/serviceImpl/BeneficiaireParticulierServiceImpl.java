package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.BeneficiaireParticulierRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireParticulierResponseDTO;
import com.example.dememalibackend.entity.Admin;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.BeneficiaireParticulier;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.BeneficiaireParticulierMapper;
import com.example.dememalibackend.repository.BeneficiairePartenaireRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.service.BeneficiaireParticulierService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional
public class BeneficiaireParticulierServiceImpl implements BeneficiaireParticulierService {

    private final BeneficiairePartenaireRepository repository;
    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final BeneficiaireParticulierMapper mapper;
    private final PasswordEncoder passwordEncoder;
    private final CustomUserDetailsService customUserDetailsService;

    private Utilisateur getUtilisateurConnecteSiAuthentifie() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated() ||
                authentication instanceof AnonymousAuthenticationToken) return null;
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

    private void verifierAccesLecture(BeneficiaireParticulier beneficiaire) {
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

    private void verifierModificationParBeneficiaire(BeneficiaireParticulier beneficiaire) {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (!(utilisateur instanceof Beneficiaire) ||
                !Objects.equals(utilisateur.getId(), beneficiaire.getId())) {
            throw new AccessDeniedException("Vous ne pouvez modifier que vos propres informations.");
        }
    }

    @Override
    public BeneficiaireParticulierResponseDTO creer(BeneficiaireParticulierRequestDTO dto) {
        if (dto.getMotDePasse() == null || dto.getMotDePasse().isBlank()) {
            throw new RuntimeException("Le mot de passe est obligatoire");
        }

        verifierCreation(dto.getOrganisationPartenaireId());

        OrganisationPartenaire organisation = organisationPartenaireRepository.findById(dto.getOrganisationPartenaireId())
                .orElseThrow(() -> new RuntimeException("Organisation partenaire introuvable"));

        BeneficiaireParticulier beneficiaire = mapper.toEntity(dto);
        beneficiaire.setRole(RoleEnum.BENEFICIARE);
        beneficiaire.setOrganisationPartenaire(organisation);
        beneficiaire.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));

        BeneficiaireParticulier sauvegarde = repository.save(beneficiaire);
        return mapper.toDTO(sauvegarde);
    }

    @Override
    @Transactional(readOnly = true)
    public BeneficiaireParticulierResponseDTO getById(Integer id) {
        BeneficiaireParticulier beneficiaire = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Bénéficiaire particulier introuvable"));

        verifierAccesLecture(beneficiaire);
        return mapper.toDTO(beneficiaire);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BeneficiaireParticulierResponseDTO> getAll() {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur instanceof Admin) {
            return repository.findAll().stream().map(mapper::toDTO).toList();
        }

        if (utilisateur instanceof OrganisationPartenaire organisation) {
            return repository.findAll().stream()
                    .filter(b -> b.getOrganisationPartenaire() != null &&
                            Objects.equals(b.getOrganisationPartenaire().getId(), organisation.getId()))
                    .map(mapper::toDTO).toList();
        }

        if (utilisateur instanceof Beneficiaire) {
            return repository.findById(utilisateur.getId())
                    .map(b -> List.of(mapper.toDTO(b)))
                    .orElseGet(List::of);
        }

        throw new AccessDeniedException("Vous n'avez pas l'autorisation de consulter les bénéficiaires.");
    }

    @Override
    public BeneficiaireParticulierResponseDTO modifier(Integer id, BeneficiaireParticulierRequestDTO dto) {
        BeneficiaireParticulier beneficiaire = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Bénéficiaire particulier introuvable"));

        verifierModificationParBeneficiaire(beneficiaire);

        beneficiaire.setNom(dto.getNom());
        beneficiaire.setPrenom(dto.getPrenom());
        beneficiaire.setTelephone(dto.getTelephone());
        beneficiaire.setVille(dto.getVille());
        beneficiaire.setAdresse(dto.getAdresse());
        beneficiaire.setSituationMatrimonial(dto.getSituationMatrimonial());
        beneficiaire.setTypeHandicap(dto.getTypeHandicap());
        beneficiaire.setNombreEnfants(dto.getNombreEnfants());
        beneficiaire.setDateNaissance(dto.getDateNaissance());
        beneficiaire.setSexe(dto.getSexe());
        beneficiaire.setTypeBeneficiaireParticulier(dto.getTypeBeneficiaireParticulier());
        beneficiaire.setDescriptionSituation(dto.getDescriptionSituation());

        if (dto.getMotDePasse() != null && !dto.getMotDePasse().isBlank()) {
            beneficiaire.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));
        }

        return mapper.toDTO(repository.save(beneficiaire));
    }
}