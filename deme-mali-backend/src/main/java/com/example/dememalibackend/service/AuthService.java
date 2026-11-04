package com.example.dememalibackend.service;

import com.example.dememalibackend.dto.LoginRequest;
import com.example.dememalibackend.dto.LoginResponse;

public interface AuthService {
    LoginResponse login(LoginRequest request);
    void logout();

}
