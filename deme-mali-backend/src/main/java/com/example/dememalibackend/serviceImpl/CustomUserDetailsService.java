package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.entity.Utilisateur;
import com.example.dememalibackend.repository.UtilisateurRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.AnonymousAuthenticationToken;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UtilisateurRepository utilisateurRepository;

    @Override
    public UserDetails loadUserByUsername(String telephone)
            throws UsernameNotFoundException {

        Utilisateur utilisateur =
                utilisateurRepository
                        .findByTelephone(telephone)
                        .orElseThrow(() ->
                                new UsernameNotFoundException(
                                        "Utilisateur introuvable"
                                )
                        );

        return User.builder()
                .username(utilisateur.getTelephone())
                .password(utilisateur.getMotDePasse())
                .roles(utilisateur.getRole().name())
                .build();
    }

    public Utilisateur getUtilisateur(String telephone) {

        return utilisateurRepository
                .findByTelephone(telephone)
                .orElseThrow(() ->
                        new UsernameNotFoundException(
                                "Utilisateur introuvable"
                        )
                );
    }
    public Utilisateur getUtilisateurConnecte() {

        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        if (authentication == null
                || !authentication.isAuthenticated()
                || authentication instanceof AnonymousAuthenticationToken) {

            throw new AccessDeniedException(
                    "Vous devez être connecté."
            );
        }

        String telephone = authentication.getName();

        return getUtilisateur(telephone);
    }
}