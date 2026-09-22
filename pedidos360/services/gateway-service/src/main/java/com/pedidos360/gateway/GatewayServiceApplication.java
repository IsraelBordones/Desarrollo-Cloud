package com.pedidos360.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point for the API Gateway / BFF service. It validates the Azure AD JWT
 * (same rules as the AWS API Gateway JWT authorizer) and forwards authorized
 * requests to the downstream microservices.
 */
@SpringBootApplication
public class GatewayServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(GatewayServiceApplication.class, args);
    }
}
