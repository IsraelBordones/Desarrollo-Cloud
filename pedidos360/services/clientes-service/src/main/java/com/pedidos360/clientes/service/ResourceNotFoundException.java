package com.pedidos360.clientes.service;

/**
 * Thrown when a requested entity does not exist.
 */
public class ResourceNotFoundException extends RuntimeException {
    public ResourceNotFoundException(String message) {
        super(message);
    }
}
