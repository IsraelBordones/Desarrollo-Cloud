package com.pedidos360.gateway.controller;

import java.util.Map;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Public health endpoint used by the load balancer / API Gateway.
 */
@RestController
public class HealthController {

    @GetMapping("/gateway/health")
    public Map<String, String> health() {
        return Map.of("status", "UP", "service", "gateway-service");
    }
}
