package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.Enum.RoleEnum;
import com.example.dememalibackend.dto.AdminDTO;
import com.example.dememalibackend.dto.AdminResponseDTO;
import com.example.dememalibackend.entity.Admin;
import com.example.dememalibackend.repository.AdminRepository;
import com.example.dememalibackend.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class AdminServiceImpl implements AdminService {

    @Autowired
    private AdminRepository adminRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public AdminResponseDTO ajouterAdmin(AdminDTO dto) {

        Admin admin = new Admin();

        admin.setNom(dto.getNom());
        admin.setPrenom(dto.getPrenom());
        admin.setTelephone(dto.getTelephone());

        admin.setMotDePasse(
                passwordEncoder.encode(
                        dto.getMotDePasse()
                )
        );

        admin.setRole(RoleEnum.ADMIN);

        admin.setDateCreation(LocalDate.now());

        Admin adminSauvegarde =
                adminRepository.save(admin);

        AdminResponseDTO response =
                new AdminResponseDTO();


        response.setNom(
                adminSauvegarde.getNom()
        );

        response.setPrenom(
                adminSauvegarde.getPrenom()
        );

        response.setTelephone(
                adminSauvegarde.getTelephone()
        );

        response.setRole(
                adminSauvegarde.getRole().name()
        );

        response.setDateCreation(
                adminSauvegarde.getDateCreation()
        );

        return response;
    }

    @Override
    public List<AdminResponseDTO> afficherAdmins() {

        List<Admin> admins =
                adminRepository.findAll();

        List<AdminResponseDTO> resultat =
                new ArrayList<>();

        for (Admin admin : admins) {

            AdminResponseDTO response =
                    new AdminResponseDTO();



            response.setNom(
                    admin.getNom()
            );

            response.setPrenom(
                    admin.getPrenom()
            );

            response.setTelephone(
                    admin.getTelephone()
            );

            response.setRole(
                    admin.getRole().name()
            );

            response.setDateCreation(
                    admin.getDateCreation()
            );

            resultat.add(response);
        }

        return resultat;
    }

    @Override
    public AdminResponseDTO afficherAdmin(int id) {

        Admin admin =
                adminRepository.findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Administrateur introuvable"
                                )
                        );

        AdminResponseDTO response =
                new AdminResponseDTO();


        response.setNom(
                admin.getNom()
        );

        response.setPrenom(
                admin.getPrenom()
        );

        response.setTelephone(
                admin.getTelephone()
        );

        response.setRole(
                admin.getRole().name()
        );

        response.setDateCreation(
                admin.getDateCreation()
        );

        return response;
    }

    @Override
    public AdminResponseDTO modifierAdmin(
            int id,
            AdminDTO dto
    ) {

        Admin admin =
                adminRepository.findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Administrateur introuvable"
                                )
                        );

        admin.setNom(dto.getNom());
        admin.setPrenom(dto.getPrenom());
        admin.setTelephone(dto.getTelephone());

        if (dto.getMotDePasse() != null &&
                !dto.getMotDePasse().isBlank()) {

            admin.setMotDePasse(
                    passwordEncoder.encode(
                            dto.getMotDePasse()
                    )
            );
        }

        Admin adminModifie =
                adminRepository.save(admin);

        AdminResponseDTO response =
                new AdminResponseDTO();



        response.setNom(
                adminModifie.getNom()
        );

        response.setPrenom(
                adminModifie.getPrenom()
        );

        response.setTelephone(
                adminModifie.getTelephone()
        );

        response.setRole(
                adminModifie.getRole().name()
        );

        response.setDateCreation(
                adminModifie.getDateCreation()
        );

        return response;
    }

    @Override
    public void supprimerAdmin(int id) {

        Admin admin =
                adminRepository.findById(id)
                        .orElseThrow(
                                () -> new RuntimeException(
                                        "Administrateur introuvable"
                                )
                        );

        adminRepository.delete(admin);
    }
}