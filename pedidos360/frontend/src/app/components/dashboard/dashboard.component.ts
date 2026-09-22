import { Component, OnInit } from '@angular/core';
import { forkJoin } from 'rxjs';
import { ApiService } from '../../services/api.service';
import { AuthService } from '../../services/auth.service';

/**
 * Dashboard showing summary counts and the identity claims read from the JWT.
 */
@Component({
  selector: 'app-dashboard',
  template: `
    <div class="container">
      <div class="card">
        <h1>Bienvenido, {{ name }}</h1>
        <p style="color:#6b7280;">Correo: {{ email || 'N/D' }}</p>
        <p style="color:#6b7280;">OID (Azure AD): {{ oid || 'N/D' }}</p>
        <p>Roles del token:
          <span class="badge" *ngFor="let r of roles">{{ r }}</span>
          <span *ngIf="roles.length === 0" style="color:#9ca3af;">sin roles asignados</span>
        </p>
      </div>

      <div class="grid">
        <div class="card"><div>Pedidos</div><div class="stat">{{ pedidos }}</div></div>
        <div class="card"><div>Productos</div><div class="stat">{{ productos }}</div></div>
        <div class="card"><div>Clientes</div><div class="stat">{{ clientes }}</div></div>
      </div>

      <div class="card" *ngIf="error">
        <p style="color:#e11d48;">{{ error }}</p>
      </div>
    </div>
  `
})
export class DashboardComponent implements OnInit {
  name = this.auth.getName();
  email = this.auth.getEmail();
  oid = this.auth.getOid();
  roles = this.auth.getRoles();

  pedidos = 0;
  productos = 0;
  clientes = 0;
  error = '';

  constructor(private api: ApiService, private auth: AuthService) {}

  ngOnInit(): void {
    forkJoin({
      pedidos: this.api.getPedidos(),
      productos: this.api.getProductos(),
      clientes: this.api.getClientes()
    }).subscribe({
      next: (r) => {
        this.pedidos = r.pedidos.length;
        this.productos = r.productos.length;
        this.clientes = r.clientes.length;
      },
      error: () => {
        this.error = 'No se pudieron cargar los datos. Verifica el API Gateway y el token.';
      }
    });
  }
}
