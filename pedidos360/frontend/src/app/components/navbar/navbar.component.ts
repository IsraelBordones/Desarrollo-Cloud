import { Component } from '@angular/core';
import { MsalService } from '@azure/msal-angular';
import { AuthService } from '../../services/auth.service';
import { environment } from '../../../environments/environment';

/**
 * Top navigation bar with links to the CRUD sections and a logout button.
 */
@Component({
  selector: 'app-navbar',
  template: `
    <nav class="navbar">
      <div>
        <a routerLink="/" routerLinkActive="active" [routerLinkActiveOptions]="{exact:true}">Dashboard</a>
        <a routerLink="/pedidos" routerLinkActive="active">Pedidos</a>
        <a routerLink="/productos" routerLinkActive="active">Productos</a>
        <a routerLink="/clientes" routerLinkActive="active">Clientes</a>
      </div>
      <div>
        <span style="margin-right:16px;">👤 {{ name }}</span>
        <button class="btn-secondary" (click)="logout()">Cerrar sesión</button>
      </div>
    </nav>
  `
})
export class NavbarComponent {
  name = this.auth.getName();

  constructor(private msal: MsalService, private auth: AuthService) {}

  logout(): void {
    this.msal.logoutRedirect({
      postLogoutRedirectUri: environment.azure.postLogoutRedirectUri
    });
  }
}
