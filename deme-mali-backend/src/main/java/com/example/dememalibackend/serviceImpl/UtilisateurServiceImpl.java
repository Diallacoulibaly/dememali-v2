package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.UtilisateurRequest;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.repository.UtilisateurRepository;
import com.example.dememalibackend.service.UtilisateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDate;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class UtilisateurServiceImpl implements UtilisateurService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;
    private final Path dossierPhotos = Paths.get("uploads/photos");
    private static final long TAILLE_MAX_FICHIER = 5 * 1024 * 1024; // 5 Mo
    private static final Set<String> EXTENSIONS_AUTORISEES = Set.of(".jpg", ".jpeg", ".png", ".webp");

    @Override
    @Transactional(readOnly = true)
    public List<Utilisateur> getAllUtilisateurs() {
        return utilisateurRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Utilisateur getUtilisateurById(int id) {
        return utilisateurRepository.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Utilisateur introuvable"));
    }

    @Override
    @Transactional(readOnly = true)
    public Utilisateur getUtilisateurByTelephone(String telephone) {
        return utilisateurRepository.findByTelephone(telephone)
                .orElseThrow(() ->
                        new RuntimeException("Utilisateur introuvable"));
    }

    @Override
    public Utilisateur saveUtilisateur(UtilisateurRequest request) {

        if (request.getTelephone() == null
                || request.getTelephone().isBlank()) {
            throw new RuntimeException(
                    "Le numéro de téléphone est obligatoire."
            );
        }

        if (utilisateurRepository.existsByTelephone(
                request.getTelephone())) {
            throw new RuntimeException(
                    "Ce numéro de téléphone est déjà utilisé."
            );
        }

        Utilisateur utilisateur = new Utilisateur();

        utilisateur.setNom(request.getNom());
        utilisateur.setPrenom(request.getPrenom());
        utilisateur.setTelephone(request.getTelephone());

        utilisateur.setMotDePasse(
                passwordEncoder.encode(request.getMotDePasse())
        );

        utilisateur.setRole(request.getRole());
        utilisateur.setDateCreation(LocalDate.now());

        return utilisateurRepository.save(utilisateur);
    }

    @Override
    public Utilisateur modifierProfil(
            int id,
            Utilisateur nouvellesInformations
    ) {

        Utilisateur utilisateur = getUtilisateurById(id);

        String nouveauTelephone =
                nouvellesInformations.getTelephone();

        if (nouveauTelephone == null || nouveauTelephone.isBlank()) {
            throw new RuntimeException(
                    "Le numéro de téléphone est obligatoire."
            );
        }

        if (!nouveauTelephone.equals(utilisateur.getTelephone())
                && utilisateurRepository.existsByTelephoneAndIdNot(
                nouveauTelephone, id)) {
            throw new RuntimeException(
                    "Ce numéro de téléphone est déjà utilisé."
            );
        }

        utilisateur.setNom(nouvellesInformations.getNom());
        utilisateur.setPrenom(nouvellesInformations.getPrenom());
        utilisateur.setTelephone(nouveauTelephone);

        return utilisateurRepository.save(utilisateur);
    }
    @Override
    @Transactional(readOnly = true)
    public boolean existsByTelephoneAndIdNot(
            String telephone,
            Integer id
    ) {
        return utilisateurRepository
                .existsByTelephoneAndIdNot(telephone, id);
    }

    @Override
    public void deleteUtilisateur(int id) {
        if (!utilisateurRepository.existsById(id)) {
            throw new RuntimeException("Utilisateur introuvable.");
        }

        utilisateurRepository.deleteById(id);
    }

    @Override
    public String enregistrerPhoto(int id, MultipartFile photo) {
        if (photo == null || photo.isEmpty()) {
            throw new IllegalArgumentException("Veuillez sélectionner un fichier valide.");
        }

        if (photo.getSize() > TAILLE_MAX_FICHIER) {
            throw new IllegalArgumentException("La taille de la photo ne doit pas dépasser 5 Mo.");
        }

        String nomOriginal = photo.getOriginalFilename();
        String extension = "";
        if (nomOriginal != null && nomOriginal.contains(".")) {
            extension = nomOriginal.substring(nomOriginal.lastIndexOf(".")).toLowerCase();
        }

        if (!EXTENSIONS_AUTORISEES.contains(extension)) {
            throw new IllegalArgumentException(
                    "Format de fichier non supporté. Formats acceptés : JPEG, PNG, WebP."
            );
        }

        Utilisateur utilisateur = getUtilisateurById(id);

        try {
            if (!Files.exists(dossierPhotos)) {
                Files.createDirectories(dossierPhotos);
            }

            // Supprimer l'ancienne photo si elle existe
            if (utilisateur.getPhoto() != null && !utilisateur.getPhoto().isBlank()) {
                try {
                    Files.deleteIfExists(dossierPhotos.resolve(utilisateur.getPhoto()));
                } catch (IOException ignored) {}
            }

            // Générer un nom unique
            String nomUnique = UUID.randomUUID() + extension;
            Path cheminDestination = dossierPhotos.resolve(nomUnique);

            Files.copy(
                    photo.getInputStream(),
                    cheminDestination,
                    StandardCopyOption.REPLACE_EXISTING
            );

            // Mettre à jour l'utilisateur en base
            utilisateur.setPhoto(nomUnique);
            utilisateurRepository.save(utilisateur);

            return nomUnique;

        } catch (IOException e) {
            throw new RuntimeException("Erreur lors de l'enregistrement de la photo : " + e.getMessage());
        }
    }

    @Override
    public void supprimerPhoto(int id) {
        Utilisateur utilisateur = getUtilisateurById(id);

        if (utilisateur.getPhoto() != null && !utilisateur.getPhoto().isBlank()) {
            try {
                Files.deleteIfExists(dossierPhotos.resolve(utilisateur.getPhoto()));
            } catch (IOException ignored) {}

            utilisateur.setPhoto(null);
            utilisateurRepository.save(utilisateur);
        }
    }
}
