
package com.example.dememalibackend.mappers;

import com.example.dememalibackend.Enum.TypeDon;
import com.example.dememalibackend.dto.DonFinancierRequestDTO;
import com.example.dememalibackend.dto.DonFinancierResponseDTO;
import com.example.dememalibackend.entity.DemandeAide;
import com.example.dememalibackend.entity.DonFinancier;
import com.example.dememalibackend.entity.Donateur;
import org.springframework.stereotype.Component;

import java.time.LocalDate;

@Component
public class DonFinancierMapper {

    public DonFinancier toEntity(
            DonFinancierRequestDTO dto,
            Donateur donateur,
            DemandeAide demandeAide) {

        if (dto == null) {
            return null;
        }

        DonFinancier don = new DonFinancier();

        don.setDateDon(LocalDate.now());
        don.setTypeDon(TypeDon.FINANCIER);
        don.setAnonyme(dto.isAnonyme());

        don.setDonateur(donateur);
        don.setDemandeAide(demandeAide);

        don.setMontant(dto.getMontant());
        don.setModePaiement(dto.getModePaiement());

        return don;
    }

    public DonFinancierResponseDTO toResponseDTO(DonFinancier don) {

        if (don == null) {
            return null;
        }

        return DonFinancierResponseDTO.builder()
                .id(don.getId())
                .montant(don.getMontant())
                .modePaiement(don.getModePaiement())
                .dateDon(don.getDateDon())
                .typeDon(don.getTypeDon())
                .anonyme(don.isAnonyme())

                .donateurId(
                        don.getDonateur() != null
                                ? don.getDonateur().getId()
                                : null
                )

                .demandeAideId(
                        don.getDemandeAide() != null
                                ? don.getDemandeAide().getId()
                                : null
                )

                .titreDemandeAide(
                        don.getDemandeAide() != null
                                ? don.getDemandeAide().getTitre()
                                : null
                )

                .organisationPartenaireId(
                        don.getOrganisationPartenaire() != null
                                ? don.getOrganisationPartenaire().getId()
                                : null
                )

                .build();
    }
}
