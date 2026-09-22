package com.pedidos360.gateway.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

/**
 * Downstream microservice base URLs. Configured via environment variables so the
 * same jar works locally (docker-compose) and on EC2 (private IPs).
 */
@Configuration
@ConfigurationProperties(prefix = "gateway.routes")
public class RoutingProperties {

    private String pedidos;
    private String productos;
    private String clientes;
    private String notificaciones;

    public String getPedidos() { return pedidos; }
    public void setPedidos(String pedidos) { this.pedidos = pedidos; }
    public String getProductos() { return productos; }
    public void setProductos(String productos) { this.productos = productos; }
    public String getClientes() { return clientes; }
    public void setClientes(String clientes) { this.clientes = clientes; }
    public String getNotificaciones() { return notificaciones; }
    public void setNotificaciones(String notificaciones) { this.notificaciones = notificaciones; }

    /**
     * Resolves the downstream base URL for a given top-level path segment.
     */
    public String resolve(String segment) {
        return switch (segment) {
            case "pedidos" -> pedidos;
            case "productos" -> productos;
            case "clientes" -> clientes;
            case "notificaciones" -> notificaciones;
            default -> null;
        };
    }
}
