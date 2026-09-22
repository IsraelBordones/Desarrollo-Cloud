package com.pedidos360.gateway.config;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.client.RestClientResponseException;

/**
 * Propagates downstream HTTP errors (status + body) back to the caller instead
 * of masking them as a generic 500.
 */
@RestControllerAdvice
public class GatewayExceptionHandler {

    @ExceptionHandler(RestClientResponseException.class)
    public ResponseEntity<byte[]> handleDownstream(RestClientResponseException ex) {
        return ResponseEntity.status(ex.getStatusCode())
                .body(ex.getResponseBodyAsByteArray());
    }
}
