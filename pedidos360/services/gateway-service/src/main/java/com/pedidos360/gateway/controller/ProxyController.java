package com.pedidos360.gateway.controller;

import java.net.URI;

import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClient;
import org.springframework.web.servlet.HandlerMapping;

import com.pedidos360.gateway.config.RoutingProperties;

import jakarta.servlet.http.HttpServletRequest;

/**
 * Generic reverse proxy. Requests reaching this controller have already passed
 * JWT validation (issuer, audience, signature, expiration). The controller
 * forwards them to the appropriate downstream microservice, propagating the
 * Authorization header for defense-in-depth (each service validates too).
 */
@RestController
public class ProxyController {

    private final RestClient restClient;
    private final RoutingProperties routes;

    public ProxyController(RestClient restClient, RoutingProperties routes) {
        this.restClient = restClient;
        this.routes = routes;
    }

    @RequestMapping("/pedidos/**")
    public ResponseEntity<byte[]> pedidos(HttpServletRequest request, @RequestBody(required = false) byte[] body) {
        return forward("pedidos", request, body);
    }

    @RequestMapping("/productos/**")
    public ResponseEntity<byte[]> productos(HttpServletRequest request, @RequestBody(required = false) byte[] body) {
        return forward("productos", request, body);
    }

    @RequestMapping("/clientes/**")
    public ResponseEntity<byte[]> clientes(HttpServletRequest request, @RequestBody(required = false) byte[] body) {
        return forward("clientes", request, body);
    }

    @RequestMapping("/notificaciones/**")
    public ResponseEntity<byte[]> notificaciones(HttpServletRequest request, @RequestBody(required = false) byte[] body) {
        return forward("notificaciones", request, body);
    }

    private ResponseEntity<byte[]> forward(String segment, HttpServletRequest request, byte[] body) {
        String base = routes.resolve(segment);
        if (base == null) {
            return ResponseEntity.notFound().build();
        }
        String path = (String) request.getAttribute(HandlerMapping.PATH_WITHIN_HANDLER_MAPPING_ATTRIBUTE);
        if (path == null) {
            path = request.getRequestURI();
        }
        String query = request.getQueryString();
        String targetUrl = base + path + (StringUtils.hasText(query) ? "?" + query : "");

        HttpMethod method = HttpMethod.valueOf(request.getMethod());
        RestClient.RequestBodySpec spec = restClient.method(method).uri(URI.create(targetUrl));

        String auth = request.getHeader(HttpHeaders.AUTHORIZATION);
        if (StringUtils.hasText(auth)) {
            spec.header(HttpHeaders.AUTHORIZATION, auth);
        }
        String contentType = request.getContentType();
        if (StringUtils.hasText(contentType)) {
            spec.contentType(MediaType.parseMediaType(contentType));
        }
        if (body != null && body.length > 0) {
            spec.body(body);
        }
        return spec.retrieve().toEntity(byte[].class);
    }
}
