using ProductService as service from './product-service';

annotate service.Products with @(
    UI.HeaderInfo: {
        TypeName: 'Produto',
        TypeNamePlural: 'Produtos',
        Title: { Value: name },
        Description: { Value: identifier },
        ImageUrl: imageURL
    },

    UI.SelectionFields: [ category_ID, identifier ],

    UI.LineItem: [

        {
            $Type: 'UI.DataFieldForAction',
            Action: 'ProductService.addToCart',
            Label: 'Adicionar ao Carrinho',
            Inline: true,
            Mapping: [{
                $Type: 'UI.ParameterMapping',
                LocalProperty: 'quantity',
                ValueListProperty: 'quantity'
            }]
        },
        { Value: imageURL, Label: 'Imagem' },
        { Value: identifier, Label: 'SKU' },
        { Value: name, Label: 'Produto' },
        { Value: category.name, Label: 'Categoria' },
        { Value: price, Criticality: criticality, Label: 'Preço' },
        { Value: stock, Label: 'Estoque' }
    ],

    UI.Facets: [
        {
            $Type: 'UI.ReferenceFacet',
            Label: 'Informações Gerais',
            Target: '@UI.FieldGroup#GeneralData'
        },
        {
            $Type: 'UI.ReferenceFacet',
            Label: 'Preços e Estoque',
            Target: '@UI.FieldGroup#FinancialData'
        }
    ],

    UI.FieldGroup #GeneralData: {
        Data: [
            { Value: identifier, Label: 'SKU' },
            { Value: name, Label: 'Nome do Produto' },
            { Value: category_ID, Label: 'Categoria' },
            { Value: description, Label: 'Descrição' }
        ]
    },

    UI.FieldGroup #FinancialData: {
        Data: [
            { Value: price, Label: 'Preço' },
            { Value: currency_code, Label: 'Moeda' },
            { Value: stock, Label: 'Estoque' }
        ]
    },

    UI.Identification: [
        {
            $Type: 'UI.DataFieldForAction',
            Action: 'ProductService.addToCart',
            Label: 'Adicionar ao Carrinho'
        }
    ]
);

annotate service.Products with {
    imageURL @UI.IsImageURL: true;
    category @Common.Text: category.name @Common.TextArrangement: #TextOnly;
};

annotate service.Products with @Common.SideEffects #ProductUpdated : {
    SourceEntities : [ $self ],
    TargetEntities : [ $self ]
};

annotate ProductService.Products with actions {
    addToCart (
        order_ID @(
            Common.Label : 'Selecionar Pedido',
            Common.ValueList : {
                $Type : 'Common.ValueListType',
                CollectionPath : 'Orders',
                Parameters : [
                    {
                        $Type : 'Common.ValueListParameterInOut',
                        LocalDataProperty : order_ID,
                        ValueListProperty : 'ID'
                    },
                    {
                        $Type : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'orderNo'
                    },
                    {
                        $Type : 'Common.ValueListParameterDisplayOnly',
                        ValueListProperty : 'customerName'
                    }
                ]
            }
        )
    );
};