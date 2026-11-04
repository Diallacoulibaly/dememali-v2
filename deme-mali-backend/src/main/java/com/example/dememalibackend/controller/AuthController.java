package com.example.dememalibackend.controller;

import com.example.dememalibackend.dto.LoginRequest;
import com.example.dememalibackend.dto.LoginResponse;
import com.example.dememalibackend.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
            @RequestBody LoginRequest request) {

        LoginResponse response = authService.login(request);

        return ResponseEntity.ok(response);
    }
    @PostMapping("/logout")
    public ResponseEntity<String> logout() {

        return ResponseEntity.ok(
                "Déconnexion réussie"
        );
    }


}
