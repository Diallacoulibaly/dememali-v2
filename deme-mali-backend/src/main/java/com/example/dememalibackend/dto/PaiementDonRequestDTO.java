
package com.example.dememalibackend.dto;

import com.example.dememalibackend.Enum.ModePaiement;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PaiementDonRequestDTO {

    @NotNull(message = "Le montant est obligatoire")
    @Positive(message = "Le montant doit être positif")
    private Double montant;

    @NotBlank(message = "Le numéro de téléphone est obligatoire")
    private String numeroTelephone;

    @NotBlank(message = "Le code secret fictif est obligatoire")
    private String codeSecret;

    @NotNull(message = "Le mode de paiement est obligatoire")
    private ModePaiement modePaiement;

    private boolean anonyme;

    @NotNull(message = "L'identifiant du donateur est obligatoire")
    private Integer donateurId;

    private Integer demandeAideId;
    // Facultatif : don destiné directement à une organisation
    private Integer organisationPartenaireId;

}
