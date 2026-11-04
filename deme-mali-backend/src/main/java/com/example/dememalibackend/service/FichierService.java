package com.example.dememalibackend.service;

import org.springframework.web.multipart.MultipartFile;

public interface FichierService {

    String enregistrerFichier(MultipartFile fichier);
}