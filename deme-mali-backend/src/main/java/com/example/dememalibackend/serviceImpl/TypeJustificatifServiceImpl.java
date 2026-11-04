
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.TypeJustificatifRequestDTO;
import com.example.dememalibackend.dto.TypeJustificatifResponseDTO;
import com.example.dememalibackend.entity.TypeJustificatif;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.TypeJustificatifMapper;
import com.example.dememalibackend.repository.TypeJustificatifRepository;
import com.example.dememalibackend.service.TypeJustificatifService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TypeJustificatifServiceImpl
        implements TypeJustificatifService {

    private final TypeJustificatifRepository repository;
    private final TypeJustificatifMapper mapper;
    private final CustomUserDetailsService customUserDetailsService;

    // Vérifier que l'utilisateur connecté est ADMIN
    private void verifierAdmin() {

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateurConnecte();

        if (utilisateur.getRole() != RoleEnum.ADMIN) {
            throw new AccessDeniedException(
                    "Accès réservé à l'administrateur");
        }
    }

    // Création d'un type de justificatif : ADMIN uniquement
    @Override
    public TypeJustificatifResponseDTO creer(
            TypeJustificatifRequestDTO dto) {

        verifierAdmin();

        if (repository.existsByNom(dto.getNom())) {
            throw new RuntimeException(
                    "Ce type de justificatif existe déjà");
        }

        TypeJustificatif type = mapper.toEntity(dto);

        TypeJustificatif saved = repository.save(type);

        return mapper.toResponseDTO(saved);
    }

    // Consultation par ID : tous les rôles
    @Override
    public TypeJustificatifResponseDTO getById(Integer id) {

        TypeJustificatif type = repository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                        "Type de justificatif introuvable"));

        return mapper.toResponseDTO(type);
    }

    // Consultation de tous les types : tous les rôles
    @Override
    public List<TypeJustificatifResponseDTO> getAll() {

        return repository.findAll()
                .stream()
                .map(mapper::toResponseDTO)
                .toList();
    }

    // Modification d'un type : ADMIN uniquement
    @Override
    public TypeJustificatifResponseDTO modifier(
            Integer id,
            TypeJustificatifRequestDTO dto) {

        verifierAdmin();

        TypeJustificatif type = repository.findById(id)
                .orElseThrow(() -> new RuntimeException(
                        "Type de justificatif introuvable"));

        type.setNom(dto.getNom());

        TypeJustificatif updated = repository.save(type);

        return mapper.toResponseDTO(updated);
    }
}
