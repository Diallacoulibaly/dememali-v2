
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.dto.AideDistribueeRequestDTO;
import com.example.dememalibackend.dto.AideDistribueeResponseDTO;
import com.example.dememalibackend.dto.AffectationDonResponseDTO;
import com.example.dememalibackend.dto.AffectationDonMaterielResponseDTO;
import com.example.dememalibackend.dto.PreuveDistributionResponseDTO;

import com.example.dememalibackend.entity.AideDistribuee;
import com.example.dememalibackend.entity.AffectationDon;
import com.example.dememalibackend.entity.AffectationDonMateriel;
import com.example.dememalibackend.entity.Beneficiaire;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.PreuveDistribution;

import com.example.dememalibackend.repository.AffectationDonRepository;
import com.example.dememalibackend.repository.AffectationDonMaterielRepository;

import org.springframework.stereotype.Component;

import java.util.Collections;
import java.util.List;

@Component
public class AideDistribueeMapper {

    private final AffectationDonMapper affectationDonMapper;
    private final AffectationDonMaterielMapper affectationDonMaterielMapper;

    private final AffectationDonRepository affectationDonRepository;
    private final AffectationDonMaterielRepository affectationDonMaterielRepository;

    public AideDistribueeMapper(
            AffectationDonMapper affectationDonMapper,
            AffectationDonMaterielMapper affectationDonMaterielMapper,
            AffectationDonRepository affectationDonRepository,
            AffectationDonMaterielRepository affectationDonMaterielRepository) {

        this.affectationDonMapper = affectationDonMapper;
        this.affectationDonMaterielMapper = affectationDonMaterielMapper;
        this.affectationDonRepository = affectationDonRepository;
        this.affectationDonMaterielRepository = affectationDonMaterielRepository;
    }

    /**
     * Convertit le DTO de création en entité AideDistribuee.
     */
    public AideDistribuee toEntity(
            AideDistribueeRequestDTO dto,
            DemandeAide demandeAide,
            Beneficiaire beneficiaire) {

        AideDistribuee aide = new AideDistribuee();

        aide.setDemandeAide(demandeAide);
        aide.setBeneficiaire(beneficiaire);
        aide.setDateDistribution(dto.getDateDistribution());
        aide.setLieuDistribution(dto.getLieuDistribution());

        if (dto.getPreuves() != null) {
            dto.getPreuves().forEach(preuveDTO -> {
                PreuveDistribution preuve =
                        PreuveDistributionMapper.toEntity(preuveDTO, aide);

                aide.getPreuves().add(preuve);
            });
        }

        return aide;
    }

    /**
     * Convertit une entité AideDistribuee en DTO de réponse.
     */
    public AideDistribueeResponseDTO toResponseDTO(AideDistribuee aide) {

        if (aide == null) {
            return null;
        }

        AideDistribueeResponseDTO dto = new AideDistribueeResponseDTO();

        dto.setId(aide.getId());

        dto.setDemandeAideId(
                aide.getDemandeAide() != null
                        ? aide.getDemandeAide().getId()
                        : null
        );

        dto.setBeneficiaireId(
                aide.getBeneficiaire() != null
                        ? aide.getBeneficiaire().getId()
                        : null
        );

        dto.setDateDistribution(aide.getDateDistribution());
        dto.setLieuDistribution(aide.getLieuDistribution());
        dto.setStatut(aide.getStatut());

        // 1. Récupérer les preuves.
        List<PreuveDistributionResponseDTO> preuves =
                aide.getPreuves() == null
                        ? Collections.emptyList()
                        : aide.getPreuves()
                          .stream()
                          .map(PreuveDistributionMapper::toResponseDTO)
                          .toList();

        dto.setPreuves(preuves);

        // 2. Récupérer les affectations financières.
        List<AffectationDonResponseDTO> affectationsFinancieres =
                Collections.emptyList();

        if (aide.getDemandeAide() != null) {

            Integer demandeId = aide.getDemandeAide().getId();

            List<AffectationDon> affectations =
                    affectationDonRepository
                            .findByDemandeAideId(demandeId);

            affectationsFinancieres = affectations.stream()
                    .map(affectationDonMapper::toDTO)
                    .toList();

        } else if (aide.getBeneficiaire() != null) {

            Integer beneficiaireId = aide.getBeneficiaire().getId();

            List<AffectationDon> affectations =
                    affectationDonRepository
                            .findByBeneficiaireId(beneficiaireId);

            affectationsFinancieres = affectations.stream()
                    .map(affectationDonMapper::toDTO)
                    .toList();
        }

        dto.setAffectationsFinancieres(affectationsFinancieres);

        // 3. Récupérer les affectations matérielles.
        List<AffectationDonMaterielResponseDTO> affectationsMaterielles =
                Collections.emptyList();

        if (aide.getDemandeAide() != null) {

            Integer demandeId = aide.getDemandeAide().getId();

            List<AffectationDonMateriel> affectations =
                    affectationDonMaterielRepository
                            .findPourDistribution(demandeId, null);

            affectationsMaterielles = affectations.stream()
                    .map(affectationDonMaterielMapper::toDTO)
                    .toList();

        } else if (aide.getBeneficiaire() != null) {

            Integer beneficiaireId = aide.getBeneficiaire().getId();

            List<AffectationDonMateriel> affectations =
                    affectationDonMaterielRepository
                            .findByBeneficiaireId(beneficiaireId);

            affectationsMaterielles = affectations.stream()
                    .map(affectationDonMaterielMapper::toDTO)
                    .toList();
        }

        dto.setAffectationsMaterielles(affectationsMaterielles);

        return dto;
    }
}
