package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.service.FichierService;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
public class FichierServiceImpl implements FichierService {

    private final Path dossier =
            Paths.get("uploads/justificatifs");

    @Override
    public String enregistrerFichier(MultipartFile fichier) {

        try {

            if (!Files.exists(dossier)) {
                Files.createDirectories(dossier);
            }

            String nomOriginal =
                    fichier.getOriginalFilename();

            String extension = "";

            if (nomOriginal != null &&
                    nomOriginal.contains(".")) {

                extension = nomOriginal.substring(
                        nomOriginal.lastIndexOf(".")
                );
            }

            String nomUnique =
                    UUID.randomUUID() + extension;

            Path chemin =
                    dossier.resolve(nomUnique);

            Files.copy(
                    fichier.getInputStream(),
                    chemin
            );

            return nomUnique;

        } catch (IOException e) {

            throw new RuntimeException(
                    "Erreur lors de l'enregistrement du fichier"
            );
        }
    }
}