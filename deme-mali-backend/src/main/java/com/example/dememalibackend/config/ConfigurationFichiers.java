package com.example.dememalibackend.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Paths;

@Configuration
public class ConfigurationFichiers implements WebMvcConfigurer {

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {

        // Rendre accessibles les fichiers justificatifs et les preuves de distribution.
        String cheminJustificatifs = Paths.get("uploads/justificatifs")
                .toAbsolutePath()
                .toUri()
                .toString();

        String cheminDistributions = Paths.get("uploads/distributions")
                .toAbsolutePath()
                .toUri()
                .toString();

        registry.addResourceHandler("/uploads/**").addResourceLocations(Paths.get("uploads").toAbsolutePath().toUri().toString() + "/");

        registry.addResourceHandler("/uploads/justificatifs-organisations/**").addResourceLocations(Paths.get("uploads/justificatifs-organisations").toAbsolutePath().toUri().toString() + "/");

        registry.addResourceHandler("/uploads/justificatifs/**")
                .addResourceLocations(cheminJustificatifs);

        registry.addResourceHandler("/uploads/distributions/**")
                .addResourceLocations(cheminDistributions);

        // Rendre accessibles les photos
        String cheminPhotos = Paths.get("uploads/photos")
                .toAbsolutePath()
                .toUri()
                .toString();

        registry.addResourceHandler("/uploads/photos/**")
                .addResourceLocations(cheminPhotos);

        // Images illustratives des demandes d'aide
        String cheminImagesDemandes = Paths.get("uploads/images-demandes")
                .toAbsolutePath()
                .toUri()
                .toString();

        registry.addResourceHandler("/uploads/images-demandes/**")
                .addResourceLocations(cheminImagesDemandes);

        // Images des badges donateurs
        String cheminBadges = Paths.get("uploads/badges")
                .toAbsolutePath()
                .toUri()
                .toString();

        registry.addResourceHandler("/uploads/badges/**")
                .addResourceLocations(cheminBadges.endsWith("/") ? cheminBadges : cheminBadges + "/");
    }
}
