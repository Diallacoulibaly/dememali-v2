package com.example.dememalibackend.service;

import org.springframework.web.multipart.MultipartFile;

public interface FichierImageDemandeService {

    String enregistrer(MultipartFile fichier);

    void supprimer(String nomFichier);
}