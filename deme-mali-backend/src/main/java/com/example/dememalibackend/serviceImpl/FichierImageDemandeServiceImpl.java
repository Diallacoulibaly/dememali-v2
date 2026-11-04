package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.service.FichierImageDemandeService;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Set;
import java.util.UUID;

@Service
public class FichierImageDemandeServiceImpl
        implements FichierImageDemandeService {

    private final Path dossier =
            Paths.get("uploads/images-demandes").toAbsolutePath();

    private static final Set<String> EXTENSIONS_AUTORISEES =
            Set.of("jpg", "jpeg", "png", "webp");

    @Override
    public String enregistrer(MultipartFile fichier) {
        if (fichier == null || fichier.isEmpty()) {
            throw new IllegalArgumentException("Veuillez sélectionner une image.");
        }

        if (fichier.getSize() > 100L * 1024 * 1024) {
            throw new IllegalArgumentException(
                    "L'image ne doit pas dépasser 100 Mo."
            );
        }
        String type = fichier.getContentType();

        if (type == null || !Set.of(
                "image/jpeg", "image/png", "image/webp"
        ).contains(type.toLowerCase())) {
            throw new IllegalArgumentException(
                    "Formats autorisés : JPG, JPEG, PNG et WEBP.");
        }

        String original = fichier.getOriginalFilename();

        if (original == null || !original.contains(".")) {
            throw new IllegalArgumentException(
                    "Nom de fichier invalide.");
        }

        String extension = original.substring(
                original.lastIndexOf('.') + 1
        ).toLowerCase();

        if (!EXTENSIONS_AUTORISEES.contains(extension)) {
            throw new IllegalArgumentException(
                    "Extension d'image non autorisée.");
        }

        String nomUnique = UUID.randomUUID() + "." + extension;

        try {
            Files.createDirectories(dossier);
            Files.copy(fichier.getInputStream(), dossier.resolve(nomUnique));
            return nomUnique;
        } catch (IOException e) {
            throw new RuntimeException(
                    "Erreur lors de l'enregistrement de l'image.", e);
        }
    }

    @Override
    public void supprimer(String nomFichier) {
        if (nomFichier == null || nomFichier.isBlank()) {
            return;
        }

        try {
            Files.deleteIfExists(dossier.resolve(nomFichier).normalize());
        } catch (IOException e) {
            throw new RuntimeException(
                    "Erreur lors de la suppression de l'image.", e);
        }
    }
}