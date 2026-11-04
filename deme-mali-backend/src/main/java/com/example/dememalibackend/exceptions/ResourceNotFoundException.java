package com.example.dememalibackend.exceptions;

    public class ResourceNotFoundException
            extends RuntimeException {

        public ResourceNotFoundException(String message) {
            super(message);
        }
    }

