
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.Enum.StatutDistribution;
import com.example.dememalibackend.dto.AideDistribueeRequestDTO;
import com.example.dememalibackend.dto.AideDistribueeResponseDTO;
import com.example.dememalibackend.entity.*;
import com.example.dememalibackend.mappers.AideDistribueeMapper;
import com.example.dememalibackend.repository.*;
import com.example.dememalibackend.service.AideDistribueeService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class AideDistribueeServiceImpl implements AideDistribueeService {

    private final AideDistribueeRepository aideDistribueeRepository;
    private final DemandeAideRepository demandeAideRepository;
    private final BeneficiaireRepository beneficiaireRepository;
    private final AffectationDonRepository affectationDonRepository;
    private final AffectationDonMaterielRepository affectationDonMaterielRepository;
    private final AideDistribueeMapper aideDistribueeMapper;
    private final CustomUserDetailsService customUserDetailsService;
    private final DemandeAideVisibilite demandeAideVisibilite;

    private Utilisateur getUtilisateurConnecte() {
        return customUserDetailsService.getUtilisateurConnecte();
    }

    private Beneficiaire getBeneficiaire(AideDistribuee aide) {
        if (aide.getBeneficiaire() != null) return aide.getBeneficiaire();
        if (aide.getDemandeAide() != null) return aide.getDemandeAide().getBeneficiaire();
        return null;
    }

    private boolean appartientOrganisation(AideDistribuee aide, Integer organisationId) {
        if (aide.getDemandeAide() != null
                && aide.getDemandeAide().getOrganisationPartenaire() != null
                && organisationId.equals(aide.getDemandeAide().getOrganisationPartenaire().getId())) return true;
        Beneficiaire beneficiaire = getBeneficiaire(aide);
        return beneficiaire != null
                && beneficiaire.getOrganisationPartenaire() != null
                && organisationId.equals(beneficiaire.getOrganisationPartenaire().getId());
    }

    private boolean estDonateurConcerne(AideDistribuee aide, Integer donateurId) {
        List<AffectationDon> affectationsFinancieres = aide.getDemandeAide() != null
                ? affectationDonRepository.findByDemandeAideId(aide.getDemandeAide().getId())
                : List.of();

        List<AffectationDonMateriel> affectationsMaterielles = aide.getDemandeAide() != null
                ? affectationDonMaterielRepository.findByDemandeAideId(aide.getDemandeAide().getId())
                : List.of();

        Beneficiaire beneficiaire = getBeneficiaire(aide);

        if (beneficiaire != null) {
            affectationsFinancieres.addAll(affectationDonRepository.findByBeneficiaireId(beneficiaire.getId()));
            affectationsMaterielles.addAll(affectationDonMaterielRepository.findByBeneficiaireId(beneficiaire.getId()));
        }

        return affectationsFinancieres.stream().anyMatch(a ->
                a.getDonFinancier() != null
                        && a.getDonFinancier().getDonateur() != null
                        && donateurId.equals(a.getDonFinancier().getDonateur().getId()))
                || affectationsMaterielles.stream().anyMatch(a ->
                a.getDonMateriel() != null
                        && a.getDonMateriel().getDonateur() != null
                        && donateurId.equals(a.getDonMateriel().getDonateur().getId()));
    }

    private void verifierAcces(AideDistribuee aide, Utilisateur utilisateur) {
        if (utilisateur.getRole() == RoleEnum.ADMIN) return;

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE) {
            if (appartientOrganisation(aide, utilisateur.getId())) return;
            throw new AccessDeniedException("Vous ne pouvez pas accéder à cette distribution.");
        }

        if (utilisateur.getRole() == RoleEnum.BENEFICIARE) {
            Beneficiaire beneficiaire = getBeneficiaire(aide);
            if (beneficiaire != null && beneficiaire.getId().equals(utilisateur.getId())) return;
            if (demandeAideVisibilite.estValideeAvecEtudeTerminee(aide.getDemandeAide())) return;
            throw new AccessDeniedException("Vous ne pouvez pas accéder à cette distribution.");
        }

        if (utilisateur.getRole() == RoleEnum.DONATEUR) {
            if (estDonateurConcerne(aide, utilisateur.getId())) return;
            throw new AccessDeniedException("Vous ne pouvez pas accéder à cette distribution.");
        }

        throw new AccessDeniedException("Accès refusé.");
    }

    private OrganisationPartenaire getOrganisationConnectee() {
        Utilisateur utilisateur = getUtilisateurConnecte();
        if (utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE
                || !(utilisateur instanceof OrganisationPartenaire)) {
            throw new AccessDeniedException("Cette opération est réservée aux organisations partenaires.");
        }
        return (OrganisationPartenaire) utilisateur;
    }

    @Override
    public AideDistribueeResponseDTO creer(AideDistribueeRequestDTO dto) {
        if (dto == null) throw new IllegalArgumentException("Les données de distribution sont obligatoires");
        if (dto.getDemandeAideId() == null && dto.getBeneficiaireId() == null)
            throw new IllegalArgumentException("Une demande ou un bénéficiaire est obligatoire");

        OrganisationPartenaire organisation = getOrganisationConnectee();
        DemandeAide demande = null;
        Beneficiaire beneficiaire = null;

        if (dto.getDemandeAideId() != null) {
            demande = demandeAideRepository.findById(dto.getDemandeAideId())
                    .orElseThrow(() -> new IllegalArgumentException("Demande d'aide introuvable"));
            if (demande.getOrganisationPartenaire() == null
                    || !organisation.getId().equals(demande.getOrganisationPartenaire().getId()))
                throw new AccessDeniedException("Cette demande ne dépend pas de votre organisation.");
        }

        if (dto.getBeneficiaireId() != null) {
            beneficiaire = beneficiaireRepository.findById(dto.getBeneficiaireId())
                    .orElseThrow(() -> new IllegalArgumentException("Bénéficiaire introuvable"));
            if (beneficiaire.getOrganisationPartenaire() == null
                    || !organisation.getId().equals(beneficiaire.getOrganisationPartenaire().getId()))
                throw new AccessDeniedException("Ce bénéficiaire ne dépend pas de votre organisation.");
        }

        if (beneficiaire == null && demande != null) beneficiaire = demande.getBeneficiaire();

        if (demande != null && dto.getBeneficiaireId() != null
                && demande.getBeneficiaire() != null
                && !dto.getBeneficiaireId().equals(demande.getBeneficiaire().getId())) {
            throw new IllegalArgumentException("Le bénéficiaire ne correspond pas à la demande");
        }

        AideDistribuee aide = aideDistribueeMapper.toEntity(dto, demande, beneficiaire);
        aide.setStatut(StatutDistribution.DISTRIBUEE);
        AideDistribuee aideEnregistree = aideDistribueeRepository.save(aide);
        return aideDistribueeMapper.toResponseDTO(aideEnregistree);
    }

    @Override
    @Transactional(readOnly = true)
    public AideDistribueeResponseDTO getById(Integer id) {
        AideDistribuee aide = aideDistribueeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Distribution introuvable"));
        verifierAcces(aide, getUtilisateurConnecte());
        return aideDistribueeMapper.toResponseDTO(aide);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AideDistribueeResponseDTO> getAll() {
        Utilisateur utilisateur = getUtilisateurConnecte();
        if (utilisateur.getRole() == RoleEnum.ADMIN)
            return aideDistribueeRepository.findAll().stream().map(aideDistribueeMapper::toResponseDTO).toList();

        if (utilisateur.getRole() == RoleEnum.DONATEUR)
            return aideDistribueeRepository.findAll().stream()
                    .filter(a -> estDonateurConcerne(a, utilisateur.getId()))
                    .map(aideDistribueeMapper::toResponseDTO).toList();

        throw new AccessDeniedException("Accès réservé aux administrateurs et aux donateurs.");
    }

    @Override
    @Transactional(readOnly = true)
    public List<AideDistribueeResponseDTO> getByDemandeAide(Integer demandeAideId) {
        DemandeAide demande = demandeAideRepository.findById(demandeAideId)
                .orElseThrow(() -> new IllegalArgumentException("Demande d'aide introuvable"));

        List<AideDistribuee> aides = aideDistribueeRepository.findByDemandeAideId(demandeAideId);
        Utilisateur utilisateur = getUtilisateurConnecte();

        if (utilisateur.getRole() == RoleEnum.ADMIN) return aides.stream().map(aideDistribueeMapper::toResponseDTO).toList();

        return aides.stream().filter(a -> {
            try {
                verifierAcces(a, utilisateur);
                return true;
            } catch (AccessDeniedException e) {
                return false;
            }
        }).map(aideDistribueeMapper::toResponseDTO).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<AideDistribueeResponseDTO> getByBeneficiaire(Integer beneficiaireId) {
        Beneficiaire beneficiaire = beneficiaireRepository.findById(beneficiaireId)
                .orElseThrow(() -> new IllegalArgumentException("Bénéficiaire introuvable"));

        List<AideDistribuee> aides = aideDistribueeRepository.findByBeneficiaireId(beneficiaireId);
        Utilisateur utilisateur = getUtilisateurConnecte();

        if (utilisateur.getRole() == RoleEnum.ADMIN) return aides.stream().map(aideDistribueeMapper::toResponseDTO).toList();

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && !beneficiaire.getOrganisationPartenaire().getId().equals(utilisateur.getId()))
            throw new AccessDeniedException("Ce bénéficiaire ne dépend pas de votre organisation.");

        if (utilisateur.getRole() == RoleEnum.BENEFICIARE
                && !beneficiaireId.equals(utilisateur.getId()))
            throw new AccessDeniedException("Vous ne pouvez consulter que vos propres distributions.");

        return aides.stream().filter(a -> {
            try {
                verifierAcces(a, utilisateur);
                return true;
            } catch (AccessDeniedException e) {
                return false;
            }
        }).map(aideDistribueeMapper::toResponseDTO).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<AideDistribueeResponseDTO> getDistribueesByDemandeAide(Integer demandeAideId) {
        demandeAideRepository.findById(demandeAideId)
                .orElseThrow(() -> new IllegalArgumentException("Demande d'aide introuvable"));
        List<AideDistribuee> aides = aideDistribueeRepository.findByDemandeAideIdAndStatut(
                demandeAideId, StatutDistribution.DISTRIBUEE);
        Utilisateur utilisateur = getUtilisateurConnecte();

        return aides.stream().filter(a -> {
            try {
                verifierAcces(a, utilisateur);
                return true;
            } catch (AccessDeniedException e) {
                return false;
            }
        }).map(aideDistribueeMapper::toResponseDTO).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public List<AideDistribueeResponseDTO> getDistribueesByBeneficiaire(Integer beneficiaireId) {
        beneficiaireRepository.findById(beneficiaireId)
                .orElseThrow(() -> new IllegalArgumentException("Bénéficiaire introuvable"));
        List<AideDistribuee> aides = aideDistribueeRepository.findByBeneficiaireIdAndStatut(
                beneficiaireId, StatutDistribution.DISTRIBUEE);
        Utilisateur utilisateur = getUtilisateurConnecte();

        return aides.stream().filter(a -> {
            try {
                verifierAcces(a, utilisateur);
                return true;
            } catch (AccessDeniedException e) {
                return false;
            }
        }).map(aideDistribueeMapper::toResponseDTO).toList();
    }

    @Override
    @Transactional(readOnly = true)
    public AideDistribueeResponseDTO getAvecAffectationsFinancieres(Integer id) {
        AideDistribuee aide = aideDistribueeRepository.findDistributionAvecAffectationsFinancieres(id);
        if (aide == null) throw new IllegalArgumentException("Distribution introuvable");
        verifierAcces(aide, getUtilisateurConnecte());
        return aideDistribueeMapper.toResponseDTO(aide);
    }

    @Override
    @Transactional(readOnly = true)
    public AideDistribueeResponseDTO getAvecAffectationsMaterielles(Integer id) {
        AideDistribuee aide = aideDistribueeRepository.findDistributionAvecAffectationsMaterielles(id);
        if (aide == null) throw new IllegalArgumentException("Distribution introuvable");
        verifierAcces(aide, getUtilisateurConnecte());
        return aideDistribueeMapper.toResponseDTO(aide);
    }

    @Override
    public AideDistribueeResponseDTO marquerCommeDistribuee(Integer id) {
        OrganisationPartenaire organisation = getOrganisationConnectee();
        AideDistribuee aide = aideDistribueeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Distribution introuvable"));

        if (!appartientOrganisation(aide, organisation.getId()))
            throw new AccessDeniedException("Cette distribution ne dépend pas de votre organisation.");

        if (aide.getStatut() == StatutDistribution.DISTRIBUEE)
            throw new IllegalStateException("Cette aide est déjà marquée comme distribuée");

        aide.setStatut(StatutDistribution.DISTRIBUEE);
        AideDistribuee aideEnregistree = aideDistribueeRepository.save(aide);
        return aideDistribueeMapper.toResponseDTO(aideEnregistree);
    }

    @Override
    public void supprimer(Integer id) {
        Utilisateur utilisateur = getUtilisateurConnecte();
        if (utilisateur.getRole() != RoleEnum.ADMIN)
            throw new AccessDeniedException("Seul un administrateur peut supprimer une distribution.");

        AideDistribuee aide = aideDistribueeRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Distribution introuvable"));
        aideDistribueeRepository.delete(aide);
    }

    @Override
    @Transactional(readOnly = true)
    public List<AideDistribueeResponseDTO> getByOrganisation(Integer organisationId) {
        Utilisateur utilisateur = getUtilisateurConnecte();

        if (utilisateur.getRole() == RoleEnum.ORGANISATIONPARTENAIRE
                && !organisationId.equals(utilisateur.getId()))
            throw new AccessDeniedException("Vous ne pouvez consulter que les distributions de votre organisation.");

        if (utilisateur.getRole() != RoleEnum.ADMIN
                && utilisateur.getRole() != RoleEnum.DONATEUR
                && utilisateur.getRole() != RoleEnum.ORGANISATIONPARTENAIRE)
            throw new AccessDeniedException("Accès refusé.");

        List<AideDistribuee> aides = aideDistribueeRepository.findByOrganisationPartenaireId(organisationId);

        return aides.stream().filter(a -> {
            try {
                verifierAcces(a, utilisateur);
                return true;
            } catch (AccessDeniedException e) {
                return false;
            }
        }).map(aideDistribueeMapper::toResponseDTO).toList();
    }
}
