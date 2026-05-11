import { Routes } from '@angular/router';
import { OrdersComponent } from './orders/orders';
import { MenuComponent } from './menu/menu';

export const routes: Routes = [
  { path: 'orders', component: OrdersComponent },
  { path: 'menu', component: MenuComponent },
  { path: '', redirectTo: '/orders', pathMatch: 'full' }
];