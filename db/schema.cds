namespace app.products;

using {
    managed,
    Currency,
    sap.common.CodeList
} from '@sap/cds/common';

entity Products : managed {
    key ID             : UUID;
    @title: '{i18n>ProductID}'
    identifier         : String(20);
    @title: '{i18n>ProductName}'
    name               : String(100);
    @title: '{i18n>Description}'
    description        : String(1000);
    @title: '{i18n>ImageURL}'
    imageURL           : String;
    @title: '{i18n>Price}'
    price              : Decimal(15, 2);
    currency           : Currency;
    @title: '{i18n>Stock}'
    stock              : Integer;

    criticality        : Integer;

    category           : Association to Categories;
}

entity Categories : CodeList {
    key ID  : Integer;
}

entity Orders : managed {
    key ID           : UUID;
    @title: '{i18n>OrderNumber}'
    orderNo          : String(10) @readonly;
    customerName     : String(100);
    totalAmount      : Decimal(15, 2);
    currency         : Currency;

    items            : Composition of many OrderItems on items.parent = $self;

}

entity OrderItems : managed {
    key ID           : UUID;
    parent           : Association to Orders;
    product          : Association to Products;
    quantity         : Integer;
    @title:  '{i18n>ItemPrice}'
    itemPrice        : Decimal(15, 2);
    currency         : Currency;
}