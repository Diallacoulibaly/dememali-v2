package com.example.dememalibackend.config;


import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.entity.Admin;
import com.example.dememalibackend.entity.TypeJustificatif;
import com.example.dememalibackend.repository.AdminRepository;
import com.example.dememalibackend.repository.TypeJustificatifRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;

@Configuration
@RequiredArgsConstructor
public class InsererAdmin {

    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner initDatabase(
            AdminRepository adminRepository,
            TypeJustificatifRepository typeJustificatifRepository
    ) {

        return args -> {

            if (adminRepository.findAll().isEmpty()) {

                Admin admin = new Admin();

                admin.setNom("Coulibaly");
                admin.setPrenom("Ibrahim");
                admin.setTelephone("77990488");

                admin.setMotDePasse(
                        passwordEncoder.encode("pass1234")
                );

                admin.setRole(RoleEnum.ADMIN);

                adminRepository.save(admin);

                System.out.println(
                        "--> Administrateur par défaut créé avec succès !"
                );

            } else {

                System.out.println(
                        "--> Un administrateur existe déjà."
                );
            }

            // Initialisation des types de justificatifs par défaut
            List<String> typesParDefaut = List.of(
                    "Certificat médical",
                    "Pièce d'identité",
                    "Certificat de scolarité",
                    "Facture d'électricité / eau",
                    "Autre justificatif"
            );

            for (String nomType : typesParDefaut) {
                if (!typeJustificatifRepository.existsByNom(nomType)) {
                    typeJustificatifRepository.save(
                            TypeJustificatif.builder().nom(nomType).build()
                    );
                }
            }
        };
    }
}
