import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../services/api';

@Component({
  selector: 'app-orders',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './orders.html',
  styleUrl: './orders.css'
})
export class OrdersComponent implements OnInit {
  orders: any[] = [];

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.loadOrders();
  }

  loadOrders() {
    this.api.getOrders().subscribe(data => {
      // FILTRO: Mostriamo solo gli ordini che NON sono ancora stati consegnati
      this.orders = data.filter((o: any) => o.status !== 'CONSEGNATO');
    });
  }

  changeStatus(id: number, newStatus: string) {
    this.api.updateOrderStatus(id, newStatus).subscribe(() => {
      this.loadOrders(); // Ricarica la lista: l'ordine sparirà se lo stato diventa 'CONSEGNATO'
    });
  }
}