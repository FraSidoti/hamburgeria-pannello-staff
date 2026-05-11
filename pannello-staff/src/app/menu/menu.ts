import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms'; // Per i form
import { ApiService } from '../services/api';

@Component({
  selector: 'app-menu',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './menu.html',
  styleUrl: './menu.css'
})
export class MenuComponent implements OnInit {
  products: any[] = [];
  newProduct = { name: '', price: 0, image: '', category: 'panini' };

  constructor(private api: ApiService) {}

  ngOnInit() {
    this.loadProducts();
  }

  loadProducts() {
    this.api.getProducts().subscribe(data => this.products = data);
  }

  saveProduct() {
    this.api.addProduct(this.newProduct).subscribe(() => {
      this.loadProducts();
      this.newProduct = { name: '', price: 0, image: '', category: 'panini' };
    });
  }

  removeProduct(id: number) {
    this.api.deleteProduct(id).subscribe(() => this.loadProducts());
  }
}