package com.example.dememalibackend.serviceImpl;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import lombok.RequiredArgsConstructor;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import io.jsonwebtoken.JwtException;

import java.io.IOException;

@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final CustomUserDetailsService customUserDetailsService;

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getServletPath();

        return path.startsWith("/api/auth/");
    }

    @Override
    protected void doFilterInternal(
            HttpServletRequest request,
            HttpServletResponse response,
            FilterChain filterChain
    ) throws ServletException, IOException {

        String authHeader = request.getHeader("Authorization");

        // Aucun token : laisser SecurityConfig décider de l'accès
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7).trim();

        try {
            if (token.isEmpty()) {
                response.sendError(
                        HttpServletResponse.SC_UNAUTHORIZED,
                        "Token JWT manquant."
                );
                return;
            }

            // Extraire le numéro de téléphone
            String telephone = jwtService.extractUsername(token);

            if (telephone == null || telephone.isBlank()) {
                response.sendError(
                        HttpServletResponse.SC_UNAUTHORIZED,
                        "Token JWT invalide."
                );
                return;
            }

            if (SecurityContextHolder.getContext().getAuthentication() == null) {

                // Charger l'utilisateur
                UserDetails userDetails =
                        customUserDetailsService.loadUserByUsername(telephone);

                // Vérifier le token
                if (!jwtService.isTokenValid(token, userDetails)) {
                    SecurityContextHolder.clearContext();

                    response.sendError(
                            HttpServletResponse.SC_UNAUTHORIZED,
                            "Token JWT invalide ou expiré."
                    );
                    return;
                }

                // Créer l'authentification
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userDetails,
                                null,
                                userDetails.getAuthorities()
                        );

                authentication.setDetails(
                        new WebAuthenticationDetailsSource()
                                .buildDetails(request)
                );

                // Enregistrer l'utilisateur connecté
                SecurityContextHolder.getContext()
                        .setAuthentication(authentication);
            }

        } catch (JwtException | IllegalArgumentException | UsernameNotFoundException e) {

            // Token expiré, malformé ou utilisateur introuvable
            SecurityContextHolder.clearContext();

            response.sendError(
                    HttpServletResponse.SC_UNAUTHORIZED,
                    "Token JWT invalide ou expiré."
            );
            return;
        }

        // Continuer uniquement si le token est valide
        filterChain.doFilter(request, response);
    }
}