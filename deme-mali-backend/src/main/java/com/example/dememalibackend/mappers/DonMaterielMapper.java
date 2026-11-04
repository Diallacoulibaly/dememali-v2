
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.Enum.StatutReception;
import com.example.dememalibackend.Enum.TypeDon;
import com.example.dememalibackend.dto.DonMaterielRequestDTO;
import com.example.dememalibackend.dto.DonMaterielResponseDTO;
import com.example.dememalibackend.entity.DonMateriel;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class DonMaterielMapper {

    // Convertir le DTO de requête en entité
    public DonMateriel toEntity(DonMaterielRequestDTO dto) {

        DonMateriel don = new DonMateriel();

        don.setDesignation(dto.getDesignation());
        don.setQuantite(dto.getQuantite());
        don.setUnite(dto.getUnite());
        don.setEtatMateriel(dto.getEtatMateriel());

        // Informations du don
        don.setDateDon(LocalDate.now());
        don.setTypeDon(TypeDon.MATERIEL);
        don.setAnonyme(dto.isAnonyme());

        // Informations de réception
        don.setStatutReception(StatutReception.EN_ATTENTE);
        don.setAdresseLivraison(dto.getAdresseLivraison());
        don.setQuantiteRecue(0);

        // L'organisation sera associée dans le service,
        // après vérification de son existence et de sa validation.

        return don;
    }

    // Convertir l'entité en DTO de réponse
    public DonMaterielResponseDTO toResponseDTO(DonMateriel don) {

        DonMaterielResponseDTO dto = new DonMaterielResponseDTO();

        dto.setId(don.getId());
        dto.setDesignation(don.getDesignation());
        dto.setQuantite(don.getQuantite());
        dto.setUnite(don.getUnite());

        if (don.getEtatMateriel() != null) {
            dto.setEtatMateriel(don.getEtatMateriel().name());
        }

        if (don.getStatutReception() != null) {
            dto.setStatutReception(don.getStatutReception().name());
        }

        dto.setQuantiteRecue(don.getQuantiteRecue());
        dto.setAdresseLivraison(don.getAdresseLivraison());
        dto.setDateDon(don.getDateDon());
        dto.setAnonyme(don.isAnonyme());

        // Informations du donateur
        if (don.getDonateur() != null) {
            dto.setDonateurId(don.getDonateur().getId());
        }

        // Informations de la demande d'aide
        if (don.getDemandeAide() != null) {
            dto.setDemandeAideId(don.getDemandeAide().getId());
            dto.setTitreDemandeAide(don.getDemandeAide().getTitre());
        }

        // Identifiant de l'organisation destinataire
        if (don.getOrganisationPartenaire() != null) {
            dto.setOrganisationPartenaireId(
                    don.getOrganisationPartenaire().getId()
            );
        }

        return dto;
    }
}
