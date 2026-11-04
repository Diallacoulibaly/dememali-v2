package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.AdminDTO;
import com.example.dememalibackend.dto.AdminResponseDTO;
import com.example.dememalibackend.entity.Admin;

import java.util.List;

public interface AdminService {

    AdminResponseDTO ajouterAdmin(AdminDTO dto);

    List<AdminResponseDTO> afficherAdmins();

    AdminResponseDTO afficherAdmin(int id);

    AdminResponseDTO modifierAdmin(
            int id,
            AdminDTO dto
    );

    void supprimerAdmin(int id);
}
