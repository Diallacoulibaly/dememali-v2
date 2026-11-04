
package com.example.dememalibackend.serviceImpl;

import com.example.dememalibackend.dto.JustificatifRequestDTO;
import com.example.dememalibackend.dto.JustificatifResponseDTO;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;
import java.util.Objects;

@Service
public class JwtService {

    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${jwt.access-token-expiration}")
    private long accessTokenExpiry;

    // Générer le token d'accès
    public String generateAccessToken(UserDetails userDetails) {

        Map<String, Object> claims = new HashMap<>();

        String role = userDetails.getAuthorities()
                .stream()
                .findFirst()
                .map(GrantedAuthority::getAuthority)
                .orElse(null);

        claims.put("role", role);

        return createToken(
                claims,
                userDetails.getUsername(),
                accessTokenExpiry
        );
    }

    // Construire et signer le token
    private String createToken(
            Map<String, Object> claims,
            String subject,
            long expiry
    ) {

        if (expiry <= 0) {
            throw new IllegalArgumentException(
                    "La durée de validité du token doit être positive."
            );
        }

        Date dateActuelle = new Date();

        return Jwts.builder()
                .claims(claims)
                .subject(subject)
                .issuedAt(dateActuelle)
                .expiration(
                        new Date(dateActuelle.getTime() + expiry)
                )
                .signWith(
                        getSignInKey(),
                        Jwts.SIG.HS256
                )
                .compact();
    }

    // Vérifier la validité du token
    public boolean isTokenValid(
            String token,
            UserDetails userDetails
    ) {

        try {
            Claims claims = extractAllClaims(token);

            String username = claims.getSubject();
            Date expiration = claims.getExpiration();

            return Objects.equals(
                    username,
                    userDetails.getUsername()
            )
                    && expiration != null
                    && expiration.after(new Date());

        } catch (io.jsonwebtoken.JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    // Extraire le numéro de téléphone du token
    public String extractUsername(String token) {

        return extractClaim(
                token,
                Claims::getSubject
        );
    }

    // Extraire une information particulière du token
    public <T> T extractClaim(
            String token,
            Function<Claims, T> claimsResolver
    ) {

        Claims claims = extractAllClaims(token);

        return claimsResolver.apply(claims);
    }

    // Extraire et vérifier les informations du token
    private Claims extractAllClaims(String token) {

        return Jwts.parser()
                .verifyWith(getSignInKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();
    }

    // Récupérer la clé de signature
    private SecretKey getSignInKey() {

        byte[] keyBytes = Decoders.BASE64.decode(secretKey);

        return Keys.hmacShaKeyFor(keyBytes);
    }
}
