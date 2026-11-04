package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.CategorieDemandeRequestDTO;
import com.example.dememalibackend.dto.CategorieDemandeResponseDTO;
import com.example.dememalibackend.entity.CategorieDemande;
import com.example.dememalibackend.exceptions.BadRequestException;
import com.example.dememalibackend.exceptions.ResourceNotFoundException;
import com.example.dememalibackend.mappers.CategorieDemandeMapper;
import com.example.dememalibackend.repository.CategorieDemandeRepository;
import com.example.dememalibackend.service.CategorieDemandeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class CategorieDemandeServiceImpl implements CategorieDemandeService {

    private final CategorieDemandeRepository categorieDemandeRepository;
    private final CategorieDemandeMapper categorieDemandeMapper;

    @Override
    public CategorieDemandeResponseDTO creer(CategorieDemandeRequestDTO dto) {

        if (categorieDemandeRepository.existsByNom(dto.getNom())) {
            throw new BadRequestException("Cette catégorie existe déjà");
        }

        CategorieDemande categorie = categorieDemandeMapper.toEntity(dto);
        categorie = categorieDemandeRepository.save(categorie);

        return categorieDemandeMapper.toDTO(categorie);
    }

    @Override
    @Transactional(readOnly = true)
    public CategorieDemandeResponseDTO getById(Integer id) {

        CategorieDemande categorie = getEntity(id);

        return categorieDemandeMapper.toDTO(categorie);
    }

    @Override
    @Transactional(readOnly = true)
    public List<CategorieDemandeResponseDTO> getAll() {

        return categorieDemandeRepository.findAll()
                .stream()
                .map(categorieDemandeMapper::toDTO)
                .toList();
    }

    @Override
    public CategorieDemandeResponseDTO modifier(Integer id, CategorieDemandeRequestDTO dto) {

        CategorieDemande categorie = getEntity(id);

        if (!categorie.getNom().equals(dto.getNom())
                && categorieDemandeRepository.existsByNom(dto.getNom())) {
            throw new BadRequestException("Cette catégorie existe déjà");
        }

        categorie.setNom(dto.getNom());
        categorie = categorieDemandeRepository.save(categorie);

        return categorieDemandeMapper.toDTO(categorie);
    }

    @Override
    public void supprimer(Integer id) {

        CategorieDemande categorie = getEntity(id);

        if (categorie.getDemandesAide() != null
                && !categorie.getDemandesAide().isEmpty()) {
            throw new BadRequestException(
                    "Impossible de supprimer cette catégorie car elle est utilisée par des demandes d'aide"
            );
        }

        categorieDemandeRepository.delete(categorie);
    }

    private CategorieDemande getEntity(Integer id) {

        return categorieDemandeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException(
                        "Catégorie de demande introuvable"
                ));
    }
}