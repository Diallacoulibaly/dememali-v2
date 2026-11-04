package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.UtilisateurRequest;
import com.example.dememalibackend.entity.Utilisateur;

import java.util.List;

public interface UtilisateurService {

    List<Utilisateur> getAllUtilisateurs();

    Utilisateur getUtilisateurById(int id);

    Utilisateur getUtilisateurByTelephone(String telephone);

    Utilisateur saveUtilisateur(UtilisateurRequest request);

    Utilisateur modifierProfil(int id, Utilisateur utilisateur);

    boolean existsByTelephoneAndIdNot(String telephone, Integer id);

    void deleteUtilisateur(int id);

    String enregistrerPhoto(int id, org.springframework.web.multipart.MultipartFile photo);

    void supprimerPhoto(int id);
}