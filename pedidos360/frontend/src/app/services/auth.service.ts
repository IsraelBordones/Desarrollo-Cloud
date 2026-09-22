import { Injectable } from '@angular/core';
import { MsalService } from '@azure/msal-angular';
import { AccountInfo } from '@azure/msal-browser';

/**
 * Helper around MsalService to read user identity and claims from the ID token.
 */
@Injectable({ providedIn: 'root' })
export class AuthService {
  constructor(private msal: MsalService) {}

  private account(): AccountInfo | null {
    const accounts = this.msal.instance.getAllAccounts();
    return accounts.length > 0 ? accounts[0] : null;
  }

  isLoggedIn(): boolean {
    return this.msal.instance.getAllAccounts().length > 0;
  }

  getName(): string {
    return this.account()?.name ?? 'Usuario';
  }

  getEmail(): string {
    const claims = this.account()?.idTokenClaims as Record<string, any> | undefined;
    return claims?.['email'] ?? claims?.['preferred_username'] ?? '';
  }

  getOid(): string {
    const claims = this.account()?.idTokenClaims as Record<string, any> | undefined;
    return claims?.['oid'] ?? '';
  }

  getRoles(): string[] {
    const claims = this.account()?.idTokenClaims as Record<string, any> | undefined;
    return (claims?.['roles'] as string[]) ?? [];
  }
}
