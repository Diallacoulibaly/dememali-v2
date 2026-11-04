package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.DonRequestDTO;
import com.example.dememalibackend.dto.DonResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.Don;
import com.example.dememalibackend.entity.Donateur;
import com.example.dememalibackend.mappers.DonMapper;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.repository.DonRepository;
import com.example.dememalibackend.repository.DonateurRepository;
import com.example.dememalibackend.service.DonService;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DonServiceImpl implements DonService {

    private final DonRepository donRepository;
    private final DonateurRepository donateurRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final DonMapper donMapper;

    @Override
    public DonResponseDTO creer(DonRequestDTO dto) {

        Donateur donateur = donateurRepository.findById(dto.getDonateurId())
                .orElseThrow(() ->
                        new RuntimeException(
                                "Donateur introuvable avec l'id : "
                                        + dto.getDonateurId()
                        )
                );

        DemandeAide demandeAide = null;

        if (dto.getDemandeAideId() != null) {

            demandeAide = demandeAideRepository.findById(
                    dto.getDemandeAideId()
            ).orElseThrow(() ->
                    new RuntimeException(
                            "Demande d'aide introuvable avec l'id : "
                                    + dto.getDemandeAideId()
                    )
            );
        }

        Don don = donMapper.toEntity(
                dto,
                donateur,
                demandeAide
        );

        Don saved = donRepository.save(don);

        return donMapper.toResponseDTO(saved);
    }

    @Override
    public DonResponseDTO getById(Integer id) {

        Don don = donRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException(
                                "Don introuvable avec l'id : " + id
                        )
                );

        return donMapper.toResponseDTO(don);
    }

    @Override
    public List<DonResponseDTO> getAll() {

        return donRepository.findAll()
                .stream()
                .map(donMapper::toResponseDTO)
                .toList();
    }

    @Override
    public List<DonResponseDTO> getByDonateur(Integer donateurId) {

        return donRepository.findByDonateurId(donateurId)
                .stream()
                .map(donMapper::toResponseDTO)
                .toList();
    }

    @Override
    public List<DonResponseDTO> getByDemande(Integer demandeAideId) {

        return donRepository.findByDemandeAideId(demandeAideId)
                .stream()
                .map(donMapper::toResponseDTO)
                .toList();
    }
}