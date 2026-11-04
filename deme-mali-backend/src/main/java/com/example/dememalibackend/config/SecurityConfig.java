package com.example.dememalibackend.config;

import com.example.dememalibackend.serviceImpl.CustomUserDetailsService;
import com.example.dememalibackend.serviceImpl.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableMethodSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final CustomUserDetailsService customUserDetailsService;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    // Encodage des mots de passe
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // Configuration du fournisseur d'authentification
    @Bean
    public AuthenticationProvider authenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider(customUserDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    // Gestionnaire d'authentification
    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration configuration) throws Exception {
        return configuration.getAuthenticationManager();
    }

    // Configuration CORS
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOriginPatterns(List.of("http://localhost:*", "http://127.0.0.1:*"));
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        configuration.setAllowedHeaders(List.of("*"));
        configuration.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

    // Configuration principale de Spring Security
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
                .cors(cors -> {})
                .csrf(csrf -> csrf.disable())
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                .authorizeHttpRequests(auth -> auth

                        // Autoriser les requêtes de pré-vérification CORS
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                        // Routes publiques
                        .requestMatchers(
                                "/api/login",
                                "/api/auth/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/v3/api-docs/**"
                        ).permitAll()

                        // Sécuriser le module des affectations financières
                        .requestMatchers("/api/affectations-dons", "/api/affectations-dons/**").authenticated()

                        // Sécuriser le module des affectations matérielles
                        .requestMatchers("/api/affectations-dons-materiels", "/api/affectations-dons-materiels/**").authenticated()

                        // Sécuriser le module des aides distribuées
                        .requestMatchers("/api/aides-distribuees", "/api/aides-distribuees/**").authenticated()

                        // Sécuriser le module des articles de demande
                        .requestMatchers("/api/articles-demande", "/api/articles-demande/**").authenticated()

                        // Sécuriser le module des attributions de dons libres
                        .requestMatchers("/api/attributions-dons-libres", "/api/attributions-dons-libres/**").authenticated()

                        // Sécuriser le module des badges
                        .requestMatchers("/api/badges", "/api/badges/**").authenticated()

                        // Inscription publique des bénéficiaires
                        .requestMatchers(
                                HttpMethod.POST,
                                "/api/beneficiaires/particuliers",
                                "/api/beneficiaires/structures"
                        ).permitAll()

// Les autres opérations nécessitent une connexion
                        .requestMatchers(
                                "/api/beneficiaires",
                                "/api/beneficiaires/**"
                        ).authenticated()

                        // Sécuriser le module des catégories de demande
                        .requestMatchers("/api/categories-demande", "/api/categories-demande/**").authenticated()

                        // Sécuriser le module des dashboards
                        .requestMatchers("/api/dashboard", "/api/dashboard/**").authenticated()

                        // Sécuriser le module des demandes d'aide
                        .requestMatchers("/api/demandes-aide", "/api/demandes-aide/**").authenticated()

                        // Sécuriser le module des donateurs
                        .requestMatchers(HttpMethod.POST, "/api/donateurs").permitAll()
                        .requestMatchers("/api/donateurs", "/api/donateurs/**").authenticated()

                        // Sécuriser le module des dons
                        .requestMatchers("/api/dons", "/api/dons/**").authenticated()

                        // Sécuriser le module des dons financiers
                        .requestMatchers("/api/dons-financiers", "/api/dons-financiers/**").authenticated()

                        // Sécuriser le module des dons matériels
                        .requestMatchers("/api/dons-materiels", "/api/dons-materiels/**").authenticated()
                        //lier des etude de terrain 
                        .requestMatchers("/api/etudes-terrain", "/api/etudes-terrain/**").authenticated()
                        // Sécuriser le module des rapports de besoin
.requestMatchers(
        "/api/rapports-besoin",
        "/api/rapports-besoin/**"
).authenticated()

// Sécuriser le module des rapports techniques
.requestMatchers(
        "/api/rapports-techniques",
        "/api/rapports-techniques/**"
).authenticated()
// Sécuriser le module des images des demandes
.requestMatchers(
        "/api/images-demandes", "/api/images-demandes/**").authenticated()
        // Sécuriser le module des likes des organisations
.requestMatchers(
        "/api/likes-organisations",
        "/api/likes-organisations/**"
)
                        .authenticated()
// Inscription publique
                        .requestMatchers(
                                HttpMethod.POST,
                                "/api/organisations-partenaires"
                        ).permitAll()

// Consultation publique de toutes les organisations
                        .requestMatchers(
                                HttpMethod.GET,
                                "/api/organisations-partenaires"
                        ).permitAll()

// Protéger les autres opérations
                        .requestMatchers(
                                "/api/organisations-partenaires",
                                "/api/organisations-partenaires/**"
                        ).authenticated()

// paiement
.requestMatchers("/api/paiements-dons/**").authenticated()
//pays
.requestMatchers(HttpMethod.GET, "/api/pays").permitAll()
.requestMatchers("/api/pays/**").authenticated()
.requestMatchers(
        "/api/preuves-distribution",
        "/api/preuves-distribution/**"
).authenticated()
// Justificatifs
.requestMatchers(
        "/api/justificatifs",
        "/api/justificatifs/**"
).authenticated()

// Types de justificatifs
.requestMatchers(
        "/api/types-justificatif",
        "/api/types-justificatif/**"
).authenticated()
// Preuves de distribution
.requestMatchers(
        "/api/preuves-distribution",
        "/api/preuves-distribution/**"
).authenticated()
                        .requestMatchers("/uploads/**").permitAll()
                        .requestMatchers("/error").permitAll()

                        // Les autres modules seront sécurisés progressivement
.anyRequest().authenticated()                )

                // Utiliser notre fournisseur d'authentification
                .authenticationProvider(authenticationProvider())


                // Ajouter le filtre JWT avant UsernamePasswordAuthenticationFilter
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
