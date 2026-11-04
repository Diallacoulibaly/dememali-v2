
package com.example.dememalibackend.service;

import com.example.dememalibackend.Enum.StatutDemande;
import com.example.dememalibackend.dto.DemandeAideRequestDTO;
import com.example.dememalibackend.dto.DemandeAideResponseDTO;

import java.util.List;

public interface DemandeAideService {

    // Crée une nouvelle demande d'aide financière ou matérielle.
    DemandeAideResponseDTO creer(DemandeAideRequestDTO dto);

    // Recherche une demande d'aide à partir de son identifiant.
    DemandeAideResponseDTO getById(Integer id);

    // Récupère la liste de toutes les demandes d'aide.
    List<DemandeAideResponseDTO> getAll();

    // Modifie les informations d'une demande d'aide existante.
    DemandeAideResponseDTO modifier(
            Integer id,
            DemandeAideRequestDTO dto
    );

    // Supprime une demande d'aide qui est encore en attente.
    void supprimer(Integer id);

    // Valide une demande d'aide après vérification.
    DemandeAideResponseDTO valider(Integer id);

    // Rejette une demande d'aide en enregistrant le motif du refus.
    DemandeAideResponseDTO rejeter(
            Integer id,
            String motif
    );

    // Récupère les demandes d'aide correspondant à un statut donné.
    List<DemandeAideResponseDTO> getByStatut(
            StatutDemande statut
    );

    // Récupère toutes les demandes d'aide d'un bénéficiaire donné.
    List<DemandeAideResponseDTO> getByBeneficiaire(
            Integer beneficiaireId
    );

    // Récupère toutes les demandes associées à une organisation partenaire.
    List<DemandeAideResponseDTO> getByOrganisation(
            Integer organisationPartenaireId
    );

    // Récupère toutes les demandes appartenant à une catégorie donnée.
    List<DemandeAideResponseDTO> getByCategorie(
            Integer categorieDemandeId
    );

    // Récupère les demandes validées encore disponibles pour recevoir des dons.
    List<DemandeAideResponseDTO> getDemandesDisponiblesPourDon();

    // Récupère les demandes encore ouvertes aux dons d'une organisation précise.
    List<DemandeAideResponseDTO> getDemandesDisponiblesPourDon(
            Integer organisationId
    );

    // Récupère les demandes dont la collecte est terminée et qui attendent la distribution de l'aide.
    List<DemandeAideResponseDTO> getDemandesTermineesPourAideDistribuee(
            Integer organisationId
    );
    List<DemandeAideResponseDTO> getDemandesPourPlanification(
            Integer organisationId
    );
}
