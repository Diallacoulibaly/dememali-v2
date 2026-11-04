package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.BeneficiaireStructureRequestDTO;
import com.example.dememalibackend.dto.BeneficiaireStructureResponseDTO;
import com.example.dememalibackend.entity.Admin;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.BeneficiaireStructure;
import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.BeneficiaireStructureMapper;
import com.example.dememalibackend.repository.BeneficiaireStructureRepository;
import com.example.dememalibackend.repository.OrganisationPartenaireRepository;
import com.example.dememalibackend.service.BeneficiaireStructureService;
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
public class BeneficiaireStructureServiceImpl implements BeneficiaireStructureService {

    private final BeneficiaireStructureRepository repository;
    private final OrganisationPartenaireRepository organisationPartenaireRepository;
    private final BeneficiaireStructureMapper mapper;
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

    private void verifierAccesLecture(BeneficiaireStructure beneficiaire) {
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

    private void verifierModificationParBeneficiaire(BeneficiaireStructure beneficiaire) {
        Utilisateur utilisateur = customUserDetailsService.getUtilisateurConnecte();

        if (!(utilisateur instanceof Beneficiaire) ||
                !Objects.equals(utilisateur.getId(), beneficiaire.getId())) {
            throw new AccessDeniedException("Vous ne pouvez modifier que vos propres informations.");
        }
    }

    @Override
    public BeneficiaireStructureResponseDTO creer(BeneficiaireStructureRequestDTO dto) {
        if (dto.getMotDePasse() == null || dto.getMotDePasse().isBlank()) {
            throw new IllegalArgumentException("Le mot de passe est obligatoire");
        }

        verifierCreation(dto.getOrganisationPartenaireId());

        OrganisationPartenaire organisation = organisationPartenaireRepository.findById(dto.getOrganisationPartenaireId())
                .orElseThrow(() -> new ResourceNotFoundException("Organisation partenaire introuvable"));

        BeneficiaireStructure beneficiaire = mapper.toEntity(dto);
        beneficiaire.setOrganisationPartenaire(organisation);
        beneficiaire.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));

        BeneficiaireStructure saved = repository.save(beneficiaire);
        return mapper.toDTO(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public BeneficiaireStructureResponseDTO getById(Integer id) {
        BeneficiaireStructure beneficiaire = getEntity(id);
        verifierAccesLecture(beneficiaire);
        return mapper.toDTO(beneficiaire);
    }

    @Override
    @Transactional(readOnly = true)
    public List<BeneficiaireStructureResponseDTO> getAll() {
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
    public BeneficiaireStructureResponseDTO modifier(Integer id, BeneficiaireStructureRequestDTO dto) {
        BeneficiaireStructure beneficiaire = getEntity(id);
        verifierModificationParBeneficiaire(beneficiaire);

        beneficiaire.setNom(dto.getNom());
        beneficiaire.setPrenom(dto.getPrenom());
        beneficiaire.setTelephone(dto.getTelephone());
        beneficiaire.setVille(dto.getVille());
        beneficiaire.setAdresse(dto.getAdresse());
        beneficiaire.setNina(dto.getNina());
        beneficiaire.setNif(dto.getNif());
        beneficiaire.setEmail(dto.getEmail());
        beneficiaire.setNomStructure(dto.getNomStructure());
        beneficiaire.setDocumentJustificatif(dto.getDocumentJustificatif());

        if (dto.getMotDePasse() != null && !dto.getMotDePasse().isBlank()) {
            beneficiaire.setMotDePasse(passwordEncoder.encode(dto.getMotDePasse()));
        }

        return mapper.toDTO(repository.save(beneficiaire));
    }

    private BeneficiaireStructure getEntity(Integer id) {
        return repository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Bénéficiaire structure introuvable"));
    }
}