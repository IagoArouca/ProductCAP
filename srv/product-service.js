const cds = require('@sap/cds')

module.exports = class ProductService extends cds.ApplicationService {
    async init() {
        // Buscando as entidades com o namespace correto
        const { Products, Orders, OrderItems } = cds.entities('app.products')

        this.on('addToCart', 'Products', async (req) => {
            const { quantity } = req.data
            const productID = req.params[0]

            if (!quantity || quantity <= 0) return req.error(400, 'A quantidade deve ser maior que zero.')

            // Pegamos a transação atual
            const tx = cds.tx(req)
            
            // 1. Buscar produto
            const product = await tx.run(SELECT.one.from(Products).where({ ID: productID }))
            
            if (!product) return req.error(404, 'Produto não encontrado.')
            if (product.stock < quantity) return req.error(400, `Estoque insuficiente. Disponível: ${product.stock}`)

            // 2. Lógica de Pedido
            // Buscamos um pedido existente para este "cliente" (mockado como Alex Dev)
            let activeOrder = await tx.run(SELECT.one.from(Orders).where({ customerName: 'Alex (Dev)' }))
            
            let orderID
            if (!activeOrder) {
                orderID = cds.utils.uuid() 
                await tx.run(INSERT.into(Orders).entries({
                    ID: orderID,
                    customerName: 'Alex (Dev)',
                    orderNo: `ORD-${Math.floor(1000 + Math.random() * 9000)}`,
                    totalAmount: (product.price * quantity),
                    currency_code: product.currency_code
                }))
            } else {
                orderID = activeOrder.ID
                // Atualiza o valor total do pedido existente
                const newTotal = Number(activeOrder.totalAmount) + (Number(product.price) * quantity)
                await tx.run(UPDATE(Orders).set({ totalAmount: newTotal }).where({ ID: orderID }))
            }

            // 3. Criar o item no carrinho (OrderItems)
            await tx.run(INSERT.into(OrderItems).entries({
                ID: cds.utils.uuid(),
                parent_ID: orderID,
                product_ID: productID,
                quantity: quantity,
                itemPrice: product.price,
                currency_code: product.currency_code
            }))

            // 4. Atualizar Estoque do Produto
            const newStock = product.stock - quantity
            let newCrit = 3
            if (newStock <= 0) newCrit = 1
            else if (newStock <= 5) newCrit = 2

            await tx.run(UPDATE(Products).set({ 
                stock: newStock, 
                criticality: newCrit 
            }).where({ ID: productID }))

            return `O produto ${product.name} foi adicionado ao pedido!`
        })

        await super.init()
    }
}