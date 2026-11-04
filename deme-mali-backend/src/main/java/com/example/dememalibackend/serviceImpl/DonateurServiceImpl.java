
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.DonateurRequestDTO;
import com.example.dememalibackend.dto.DonateurResponseDTO;
import com.example.dememalibackend.entity.Don;
import com.example.dememalibackend.entity.Donateur;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.Pays;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.mappers.DonateurMapper;
import com.example.dememalibackend.repository.DonateurRepository;
import com.example.dememalibackend.repository.PaysRepository;
import com.example.dememalibackend.repository.DonRepository;
import com.example.dememalibackend.repository.DemandeAideRepository;
import com.example.dememalibackend.service.DonateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DonateurServiceImpl implements DonateurService {

    private final DonateurRepository donateurRepository;
    private final PaysRepository paysRepository;
    private final DonateurMapper donateurMapper;
    private final PasswordEncoder passwordEncoder;

    private final CustomUserDetailsService customUserDetailsService;
    private final DonRepository donRepository;
    private final DemandeAideRepository demandeAideRepository;

    @Override
    public DonateurResponseDTO creer(DonateurRequestDTO dto) {

        if (dto.getMotDePasse() == null
                || dto.getMotDePasse().isBlank()) {

            throw new RuntimeException(
                    "Le mot de passe est obligatoire"
            );
        }

        Donateur donateur =
                donateurMapper.toEntity(dto);

        String motDePasseHash =
                passwordEncoder.encode(dto.getMotDePasse());

        donateur.setMotDePasse(motDePasseHash);

        if (dto.getPaysId() != null) {

            Pays pays =
                    paysRepository.findById(dto.getPaysId())
                            .orElseThrow(() ->
                                    new RuntimeException(
                                            "Pays introuvable avec l'id : "
                                                    + dto.getPaysId()
                                    )
                            );

            donateur.setPays(pays);
        }

        Donateur saved =
                donateurRepository.save(donateur);

        return donateurMapper.toResponseDTO(saved);
    }

    @Override
    public DonateurResponseDTO getById(Integer id) {

        Utilisateur utilisateurConnecte =
                customUserDetailsService.getUtilisateurConnecte();

        String role = utilisateurConnecte.getRole().name();

        if (!role.equals("ADMIN")
                && !role.equals("DONATEUR")
                && !role.equals("ORGANISATIONPARTENAIRE")
                && !role.equals("BENEFICIARE")) {

            throw new AccessDeniedException(
                    "Vous n'avez pas l'autorisation de consulter ce profil."
            );
        }

        if (role.equals("DONATEUR")
                && !utilisateurConnecte.getId().equals(id)) {

            throw new AccessDeniedException(
                    "Vous pouvez uniquement consulter votre propre profil."
            );
        }

        Donateur donateur =
                donateurRepository.findById(id)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Donateur introuvable avec l'id : "
                                                + id
                                )
                        );

        return donateurMapper.toResponseDTO(donateur);
    }

    @Override
    public List<DonateurResponseDTO> getAll() {

        Utilisateur utilisateurConnecte =
                customUserDetailsService.getUtilisateurConnecte();

        String role = utilisateurConnecte.getRole().name();

        if (!role.equals("ADMIN")
                && !role.equals("ORGANISATIONPARTENAIRE")) {

            throw new AccessDeniedException(
                    "Vous n'avez pas l'autorisation de consulter la liste des donateurs."
            );
        }

        return donateurRepository.findAll()
                .stream()
                .map(donateurMapper::toResponseDTO)
                .toList();
    }

    @Override
    public DonateurResponseDTO modifierPays(
            Integer id,
            Integer paysId) {

        Utilisateur utilisateurConnecte =
                customUserDetailsService.getUtilisateurConnecte();

        String role = utilisateurConnecte.getRole().name();

        if (!role.equals("ADMIN")
                && !role.equals("DONATEUR")) {

            throw new AccessDeniedException(
                    "Vous n'avez pas l'autorisation de modifier ce pays."
            );
        }

        if (role.equals("DONATEUR")
                && !utilisateurConnecte.getId().equals(id)) {

            throw new AccessDeniedException(
                    "Vous pouvez uniquement modifier votre propre pays."
            );
        }

        Donateur donateur =
                donateurRepository.findById(id)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Donateur introuvable avec l'id : "
                                                + id
                                )
                        );

        Pays pays =
                paysRepository.findById(paysId)
                        .orElseThrow(() ->
                                new RuntimeException(
                                        "Pays introuvable avec l'id : "
                                                + paysId
                                )
                        );

        donateur.setPays(pays);

        Donateur saved =
                donateurRepository.save(donateur);

        return donateurMapper.toResponseDTO(saved);
    }

    @Override
    public List<DonateurResponseDTO> getByPays(Integer paysId) {

        Utilisateur utilisateurConnecte =
                customUserDetailsService.getUtilisateurConnecte();

        String role = utilisateurConnecte.getRole().name();

        if (!role.equals("ADMIN")
                && !role.equals("DONATEUR")
                && !role.equals("ORGANISATIONPARTENAIRE")
                && !role.equals("BENEFICIARE")) {

            throw new AccessDeniedException(
                    "Vous n'avez pas l'autorisation de consulter ces donateurs."
            );
        }

        List<Donateur> donateurs =
                donateurRepository.findByPaysId(paysId);

        // ADMIN, DONATEUR et ORGANISATIONPARTENAIRE :
        // tous les donateurs du pays.
        if (!role.equals("BENEFICIARE")) {

            return donateurs.stream()
                    .map(donateurMapper::toResponseDTO)
                    .toList();
        }

        // BENEFICIAIRE : uniquement les donateurs
        // ayant effectué un don pour ses propres demandes.

        List<DemandeAide> demandes =
                demandeAideRepository.findByBeneficiaireId(
                        utilisateurConnecte.getId()
                );

        Set<Integer> idsDonateurs =
                demandes.stream()
                        .flatMap(demande ->
                                donRepository.findByDemandeAideId(
                                        demande.getId()
                                ).stream()
                        )
                        .map(Don::getDonateur)
                        .map(Donateur::getId)
                        .collect(Collectors.toSet());

        return donateurs.stream()
                .filter(donateur ->
                        idsDonateurs.contains(donateur.getId())
                )
                .map(donateurMapper::toResponseDTO)
                .toList();
    }
}
