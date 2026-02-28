using { app.products as my } from '../db/schema';

service ProductService {
    
    entity Products as projection on my.Products actions {

        @cds.odata.bindingparameter.name: '_it'
        @Common.SideEffects: { TargetEntities: ['_it']}
        action addToCart(quantity: Integer) returns String;
    };

    @readonly entity Categories as projection on my.Categories;

    @odata.draft.enabled
    entity Orders as projection on my.Orders;

    entity OrderItems as projection on my.OrderItems;
}