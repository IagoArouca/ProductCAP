using ProductService as service from './product-service';

annotate service.Orders with @(
    UI.HeaderInfo: {
        TypeName: 'Pedido',
        TypeNamePlural: 'Meus Pedidos',
        Title: { Value: orderNo },
        Description: { Value: customerName }
    },

    UI.SelectionFields: [ orderNo, customerName ],

    UI.LineItem: [
        { Value: orderNo, Label: 'Número do Pedido' },
        { Value: customerName, Label: 'Cliente' },
        { Value: createdAt, Label: 'Data da Compra' },
        { Value: totalAmount, Label: 'Valor Total' },
        { Value: currency_code, Label: 'Moeda' }
    ],

    UI.Facets: [
        {
            $Type: 'UI.ReferenceFacet',
            Label: 'Resumo do Pedido',
            Target: '@UI.FieldGroup#OrderDetails'
        },
        {
            $Type: 'UI.ReferenceFacet',
            Label: 'Itens do Carrinho',
            Target: 'items/@UI.LineItem'
        }
    ],

    UI.FieldGroup #OrderDetails: {
        Data: [
            { Value: orderNo },
            { Value: customerName },
            { Value: totalAmount },
            { Value: createdAt }
        ]
    }
);

annotate service.OrderItems with @(
    UI.LineItem: [
        { Value: product.imageURL, Label: 'Foto' },
        { Value: product.name, Label: 'Produto' },
        { Value: quantity, Label: 'Qtd' },
        { Value: itemPrice, Label: 'Preço Unit.' },
        { Value: currency_code, Label: 'Moeda' }
    ]
);

annotate service.OrderItems with {
    product @(
        Common.Text: product.name,
        Common.TextArrangement: #TextOnly
    );
};
