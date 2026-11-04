package com.example.dememalibackend.controller;


import com.example.dememalibackend.dto.UtilisateurRequest;
import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.service.UtilisateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/utilisateurs")
@RequiredArgsConstructor
public class UtilisateurController {

    private final UtilisateurService utilisateurService;

    @GetMapping
    public ResponseEntity<List<Utilisateur>> getAllUtilisateurs() {
        return ResponseEntity.ok(
                utilisateurService.getAllUtilisateurs()
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<Utilisateur> getUtilisateurById(
            @PathVariable int id
    ) {
        return ResponseEntity.ok(
                utilisateurService.getUtilisateurById(id)
        );
    }

    @GetMapping("/telephone/{telephone}")
    public ResponseEntity<Utilisateur> getUtilisateurByTelephone(
            @PathVariable String telephone
    ) {
        return ResponseEntity.ok(
                utilisateurService.getUtilisateurByTelephone(telephone)
        );
    }

    @PostMapping
    public ResponseEntity<Utilisateur> ajouterUtilisateur(
            @RequestBody UtilisateurRequest request
    ) {
        return ResponseEntity.ok(
                utilisateurService.saveUtilisateur(request)
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<Utilisateur> modifierProfil(
            @PathVariable int id,
            @RequestBody Utilisateur utilisateur
    ) {
        return ResponseEntity.ok(
                utilisateurService.modifierProfil(
                        id,
                        utilisateur
                )
        );
    }


    @DeleteMapping("/{id}")
    public ResponseEntity<String> supprimerUtilisateur(
            @PathVariable int id
    ) {
        utilisateurService.deleteUtilisateur(id);

        return ResponseEntity.ok(
                "Utilisateur supprimé avec succès"
        );
    }

    @PostMapping(value = "/{id}/photo", consumes = org.springframework.http.MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<java.util.Map<String, String>> televerserPhoto(
            @PathVariable int id,
            @RequestParam("photo") org.springframework.web.multipart.MultipartFile photo
    ) {
        String nomFichier = utilisateurService.enregistrerPhoto(id, photo);
        return ResponseEntity.ok(java.util.Map.of(
                "nomFichier", nomFichier,
                "photo", nomFichier,
                "url", "/uploads/photos/" + nomFichier
        ));
    }

    @DeleteMapping("/{id}/photo")
    public ResponseEntity<Void> supprimerPhoto(
            @PathVariable int id
    ) {
        utilisateurService.supprimerPhoto(id);
        return ResponseEntity.noContent().build();
    }
}




