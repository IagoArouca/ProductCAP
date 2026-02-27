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
        { Value: imageURL },
        { Value: identifier, Label: 'SKU' },
        { Value: name, Label: 'Produto' },
        { Value: category.name, Label: 'Categoria' },
        { 
            Value: price, 
            Criticality: criticality 
        },
        { Value: stock, Label: 'Estoque' },
        { 
            Value: criticality, 
            Criticality: criticality, 
            Label: 'Status' 
        }
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
            { Value: identifier },
            { Value: name },
            { Value: category_ID },
            { Value: description }
        ]
    },

    UI.FieldGroup #FinancialData: {
        Data: [
            { Value: price },
            { Value: currency_code },
            { Value: stock }
        ]
    }
);

annotate service.Products with {
    imageURL @UI.IsImageURL: true;
};