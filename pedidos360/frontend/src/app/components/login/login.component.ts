import { Component, Inject, OnInit } from '@angular/core';
import { Router } from '@angular/router';
import {
  MsalService,
  MSAL_GUARD_CONFIG,
  MsalGuardConfiguration
} from '@azure/msal-angular';
import { RedirectRequest } from '@azure/msal-browser';

/**
 * Public login page. Starts the OAuth 2.0 / OpenID Connect authorization code
 * flow (with PKCE) against Azure AD via MSAL redirect.
 */
@Component({
  selector: 'app-login',
  template: `
    <div class="login-wrap">
      <div class="card" style="max-width:420px; text-align:center;">
        <h1>Pedidos360</h1>
        <p>Sistema Cloud Native de gestión de pedidos.</p>
        <p style="color:#6b7280;font-size:14px;">
          Inicia sesión con tu cuenta corporativa de Microsoft (Azure AD)
          para obtener un token JWT y acceder al sistema.
        </p>
        <button class="btn-primary" style="width:100%;padding:12px;margin-top:12px;"
                (click)="login()">
          Iniciar sesión con Microsoft
        </button>
      </div>
    </div>
  `
})
export class LoginComponent implements OnInit {
  constructor(
    @Inject(MSAL_GUARD_CONFIG) private guardConfig: MsalGuardConfiguration,
    private msal: MsalService,
    private router: Router
  ) {}

  ngOnInit(): void {
    if (this.msal.instance.getAllAccounts().length > 0) {
      this.router.navigate(['/']);
    }
  }

  login(): void {
    if (this.guardConfig.authRequest) {
      this.msal.loginRedirect({ ...this.guardConfig.authRequest } as RedirectRequest);
    } else {
      this.msal.loginRedirect();
    }
  }
}
