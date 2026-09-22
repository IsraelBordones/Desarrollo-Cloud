import { Component, OnInit, OnDestroy } from '@angular/core';
import { MsalService, MsalBroadcastService } from '@azure/msal-angular';
import { InteractionStatus } from '@azure/msal-browser';
import { Subject } from 'rxjs';
import { filter, takeUntil } from 'rxjs/operators';

/**
 * Root component. MsalRedirectComponent (bootstrapped via <app-redirect>) handles
 * the redirect promise; here we only track login state to toggle the navbar and
 * keep an active account selected.
 */
@Component({
  selector: 'app-root',
  template: `
    <app-navbar *ngIf="loggedIn"></app-navbar>
    <router-outlet></router-outlet>
  `
})
export class AppComponent implements OnInit, OnDestroy {
  loggedIn = false;
  private readonly destroying$ = new Subject<void>();

  constructor(
    private msal: MsalService,
    private broadcast: MsalBroadcastService
  ) {}

  ngOnInit(): void {
    this.setLoginState();
    this.broadcast.inProgress$
      .pipe(
        filter((status: InteractionStatus) => status === InteractionStatus.None),
        takeUntil(this.destroying$)
      )
      .subscribe(() => this.setLoginState());
  }

  private setLoginState(): void {
    const accounts = this.msal.instance.getAllAccounts();
    this.loggedIn = accounts.length > 0;
    if (this.loggedIn && !this.msal.instance.getActiveAccount()) {
      this.msal.instance.setActiveAccount(accounts[0]);
    }
  }

  ngOnDestroy(): void {
    this.destroying$.next();
    this.destroying$.complete();
  }
}
