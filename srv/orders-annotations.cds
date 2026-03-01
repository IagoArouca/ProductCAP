using ProductService as service from './product-service';



annotate service.Orders with @(
    UI.HeaderInfo: {
        TypeName: 'Pedido',
        TypeNamePlural: 'Pedidos',
        Title: { Value: orderNo },
        Description: { Value: customerName }
    },

    UI.SelectionFields: [ orderNo, customerName ],

    UI.LineItem: [
        { Value: orderNo, Label: 'Número do Pedido' },
        { Value: customerName, Label: 'Cliente' },
        { Value: createdAt, Label: 'Data da Compra' },
        { Value: totalAmount, Label: 'Valor Total' }
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
            { Value: orderNo, Label: 'Número do Pedido' },
            { Value: customerName, Label: 'Cliente' },
            { Value: totalAmount, Label: 'Valor Total' },
            { Value: createdAt, Label: 'Data da Compra' }
        ]
    }
);

annotate service.Orders with {
    orderNo @readonly;
    totalAmount @(readonly, Core.Computed);
    createdAt @readonly;
};


annotate service.OrderItems with @(
    UI.LineItem: [
        { Value: product.imageURL, Label: ' ' },
        { Value: product_ID, Label: 'Produto' },
        { Value: quantity, Label: 'Qtd' },
        { Value: itemPrice, Label: 'Preço Unit.' }
    ]
);

annotate service.OrderItems with {
    itemPrice @Common.FieldControl: #ReadOnly;
    product @(
        Common.Text: product.name,
        Common.TextArrangement: #TextFirst,
        Common.ValueList : {
            $Type : 'Common.ValueListType',
            CollectionPath : 'Products',
            Parameters : [
                {
                    $Type : 'Common.ValueListParameterInOut',
                    LocalDataProperty : product_ID,
                    ValueListProperty : 'ID',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'name',
                },
                {
                    $Type : 'Common.ValueListParameterDisplayOnly',
                    ValueListProperty : 'price',
                }
            ]
        }
    );
};


annotate service.OrderItems with @Common.SideEffects #ItemChanged : {
    SourceProperties : [ 'quantity', 'product_ID' ],
    TargetProperties : [ 'parent/totalAmount' ]
};