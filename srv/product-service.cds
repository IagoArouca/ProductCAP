using { app.products as my } from '../db/schema';

service ProductService {

    entity Products as projection on my.Products;

    @readonly entity Categories as projection on my.Categories;

    entity Orders as projection on my.Orders;
}