package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.LoginRequest;
import com.example.dememalibackend.dto.LoginResponse;
import com.example.dememalibackend.dto.UtilisateurResponse;

import com.example.dememalibackend.entity.OrganisationPartenaire;
import com.example.dememalibackend.entity.Utilisateur;

import com.example.dememalibackend.service.AuthService;

import lombok.RequiredArgsConstructor;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final AuthenticationManager authenticationManager;

    private final JwtService jwtService;

    private final CustomUserDetailsService customUserDetailsService;

    // Connexion de l'utilisateur
    @Override
    public LoginResponse login(LoginRequest request) {

        // Vérifier le téléphone et le mot de passe
        Authentication authentication =
                authenticationManager.authenticate(
                        new UsernamePasswordAuthenticationToken(
                                request.getTelephone(),
                                request.getMotDePasse()
                        )
                );

        // Récupérer les informations de l'utilisateur connecté
        UserDetails userDetails =
                (UserDetails) authentication.getPrincipal();

        Utilisateur utilisateur =
                customUserDetailsService.getUtilisateur(
                        request.getTelephone()
                );

        // Générer uniquement l'access token
        String accessToken =
                jwtService.generateAccessToken(userDetails);

        // Préparer les informations de l'utilisateur
        UtilisateurResponse user =
                convertirUtilisateur(utilisateur);

        // Retourner le token et le profil utilisateur
        return new LoginResponse(
                accessToken,
                user
        );
    }

    // Convertir l'utilisateur en DTO
    private UtilisateurResponse convertirUtilisateur(
            Utilisateur utilisateur) {

        UtilisateurResponse response =
                new UtilisateurResponse();

        response.setId(utilisateur.getId());
        response.setNom(utilisateur.getNom());
        response.setPrenom(utilisateur.getPrenom());
        response.setTelephone(utilisateur.getTelephone());
        response.setRole(utilisateur.getRole());

        // Ajouter le type si l'utilisateur est une organisation
        if (utilisateur instanceof OrganisationPartenaire) {

            OrganisationPartenaire organisation =
                    (OrganisationPartenaire) utilisateur;

            response.setTypeOrganisation(
                    organisation.getTypeOrganisation()
            );
        }

        return response;
    }
    @Override
    public void logout() {
    }
}
