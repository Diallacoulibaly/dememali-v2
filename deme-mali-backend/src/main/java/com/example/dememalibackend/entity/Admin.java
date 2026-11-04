package com.example.dememalibackend.entity;

import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "admins")
@NoArgsConstructor
public class Admin extends Utilisateur {
}
