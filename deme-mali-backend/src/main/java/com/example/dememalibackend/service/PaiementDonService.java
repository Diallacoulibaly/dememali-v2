
package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.PaiementDonRequestDTO;
import com.example.dememalibackend.dto.PaiementDonResponseDTO;

public interface PaiementDonService {

    PaiementDonResponseDTO effectuerPaiement(
            PaiementDonRequestDTO dto);
}
