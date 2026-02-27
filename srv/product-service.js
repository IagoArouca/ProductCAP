const cds = require('@sap/cds')

module.exports = class ProductService extends cds.ApplicationService {
    init() {
        const { Products, OrderItems, Orders } = this.entities

        this.on('addToCart', 'Products', async (req) => {
            const { quantity } = req.data
            const productID = req.params[0]

            if (quantity <= 0) return req.error(400, 'A quantidade deve ser maior que zero.')

            const product = await SELECT.one.from(Products).where({ ID: productID })
            if (!product) return req.error(404, 'Produto não encontrado.')
            if (product.stock < quantity) return req.error(400, `Estoque insuficiente. Disponível: ${product.stock}`)
                
            return `Sucesso! ${quantity} unidade(s) de ${product.name} adicionada(s) ao carrinho.`
        })

        return super.init()
    }
}