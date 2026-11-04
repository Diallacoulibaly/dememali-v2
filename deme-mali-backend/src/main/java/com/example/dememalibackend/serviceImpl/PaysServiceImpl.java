package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.PaysRequestDto;
import com.example.dememalibackend.dto.PaysResponseDto;
import com.example.dememalibackend.entity.Pays;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.PaysMapper;
import com.example.dememalibackend.repository.PaysRepository;
import com.example.dememalibackend.service.PaysService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PaysServiceImpl implements PaysService {

    private final PaysRepository paysRepository;
    private final PaysMapper paysMapper;
    private final CustomUserDetailsService customUserDetailsService;

    @Override
    public PaysResponseDto creer(PaysRequestDto dto) {

        // Vérifier que l'utilisateur connecté est ADMIN
        verifierRoleAdmin();

        if (paysRepository.existsByNom(dto.getNom())) {
            throw new RuntimeException(
                    "Ce pays existe déjà"
            );
        }

        Pays pays = paysMapper.toEntity(dto);

        Pays saved = paysRepository.save(pays);

        return paysMapper.toResponseDTO(saved);
    }

    @Override
    public PaysResponseDto getById(Integer id) {

        // Vérifier que l'utilisateur possède un rôle autorisé
        verifierRoleConsultation();

        Pays pays = paysRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Pays introuvable avec l'id : " + id
                        )
                );

        return paysMapper.toResponseDTO(pays);
    }

    @Override
    public List<PaysResponseDto> getAll() {

        // Vérifier que l'utilisateur possède un rôle autorisé
        verifierRoleConsultation();

        return paysRepository.findAll()
                .stream()
                .map(paysMapper::toResponseDTO)
                .toList();
    }

    @Override
    public PaysResponseDto modifier(
            Integer id,
            PaysRequestDto dto
    ) {

        // Vérifier que l'utilisateur connecté est ADMIN
        verifierRoleAdmin();

        Pays pays = paysRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Pays introuvable avec l'id : " + id
                        )
                );

        pays.setNom(dto.getNom());

        Pays updated = paysRepository.save(pays);

        return paysMapper.toResponseDTO(updated);
    }

    // Vérifier le rôle ADMIN
    private void verifierRoleAdmin() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ADMIN) {
            throw new AccessDeniedException(
                    "Seul un administrateur peut effectuer cette opération."
            );
        }
    }

    // Vérifier les rôles autorisés à consulter les pays
    private void verifierRoleConsultation() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        RoleEnum role = utilisateur.getRole();

        if (role != RoleEnum.ADMIN
                && role != RoleEnum.DONATEUR
                && role != RoleEnum.BENEFICIARE
                && role != RoleEnum.ORGANISATIONPARTENAIRE) {

            throw new AccessDeniedException(
                    "Vous n'avez pas l'autorisation de consulter les pays."
            );
        }
    }
}