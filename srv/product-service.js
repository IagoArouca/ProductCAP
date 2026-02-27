const cds = require('@sap/cds')

module.exports = class ProductService extends cds.ApplicationService {
    init() {
        const { Products, OrderItems, Orders } = this.entities

        this.on('addToCart', 'Products', async (req) => {
            const { quantity } = req.data
            const productID = req.params[0]

            if (!quantity || quantity <= 0) return req.error(400, 'A quantidade deve ser maior que zero.')

           return cds.tx(req, async (tx) => {

            const product = await tx.run(
                SELECT.one.from(Products)
                    .where({ ID: productID })
                    .forUpdate()
            )

                if (!product) return req.error(404, 'Produto não encontrado.')
                if (product.stock < quantity)
                    return req.error(400, `Estoque insuficiente para ${product.name}. Disponível: ${product.stock}`)

                let activeOrder = await tx.run(
                    SELECT.from(Orders)
                        .where({ customerName: 'Iago (Dev)' })
                        .limit(1)
                )

                let orderID

                if (activeOrder.length === 0) {

                    const newOrder = await tx.run(
                        INSERT.into(Orders).entries({
                            customerName: 'Iago (Dev)',
                            orderNo: `ORD-${Math.floor(1000 + Math.random() * 9000)}`,
                            totalAmount: 0,
                            currency_code: product.currency_code
                        })
                    )

                    orderID = newOrder.ID
                } else {
                    orderID = activeOrder[0].ID
                }

                    await tx.run(
                        INSERT.into(OrderItems).entries({
                            parent_ID: orderID,
                            product_ID: productID,
                            quantity: quantity,
                            itemPrice: product.price,
                            currency_code: product.currency_code
                        })
                    )

                const newStock = product.stock - quantity

                let newCriticality = 3
                if (newStock <= 0) newCriticality = 1
                else if (newStock <= 10) newCriticality = 2

                await tx.run(
                    UPDATE(Products)
                        .set({
                            stock: newStock,
                            criticality: newCriticality
                        })
                        .where({ ID: productID })
                )

                req.notify(`Sucesso! ${quantity} unidade(s) de ${product.name} adicionada(s) ao pedido ${orderID}.`)
            })
        })

        return super.init()
    }
}