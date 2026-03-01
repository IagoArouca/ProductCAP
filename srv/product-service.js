const cds = require('@sap/cds')

module.exports = class ProductService extends cds.ApplicationService {

    async init() {
        const { Products, Orders, OrderItems } = this.entities;

        const _recalculateDraftTotal = async (parentID, req, currentItem = null) => {
            const tx = cds.tx(req);
            if (!parentID) return;

            console.log(`[CÁLCULO] Iniciando recalculo para Pedido (Draft): ${parentID}`);

            await new Promise(resolve => setTimeout(resolve, 50)); 

            let items = await tx.run(
                SELECT.from(OrderItems.drafts).where({ parent_ID: parentID })
            );

            if (req.event === 'CREATE' && currentItem) {
                const exists = items.find(i => i.ID === currentItem.ID);
                if (!exists) {
                    items.push(currentItem);
                }
            }

            const total = items.reduce((sum, item) => {
                return sum + (Number(item.quantity || 0) * Number(item.itemPrice || 0));
            }, 0);

            console.log(`[CÁLCULO] Total calculado: ${total}`);

            await tx.run(
                UPDATE(Orders.drafts)
                    .set({ totalAmount: total })
                    .where({ ID: parentID })
            );
        };

        const _recalculateActiveTotal = async (orderID, req) => {
            const tx = cds.tx(req);
            const items = await tx.run(
                SELECT.from(OrderItems).where({ parent_ID: orderID })
            );
            const total = items.reduce((sum, item) => sum + (Number(item.quantity || 0) * Number(item.itemPrice || 0)), 0);
            await tx.run(
                UPDATE(Orders).set({ totalAmount: total }).where({ ID: orderID })
            );
        };


        this.before('NEW', 'Orders.drafts', (req) => {
            req.data.orderNo = `ORD-${Math.floor(1000 + Math.random() * 9000)}`;
            req.data.customerName = 'Novo Cliente';
            req.data.totalAmount = 0;
            req.data.currency_code = 'BRL';
        });

        this.before('NEW', 'OrderItems.drafts', (req) => {
            req.data.quantity = 1;
            req.data.currency_code = 'BRL';
        });

        this.before(['CREATE','UPDATE'], 'OrderItems.drafts', async (req) => {
            if (!req.data.product_ID) return;
            const tx = cds.tx(req);
            const product = await tx.run(
                SELECT.one.from(Products).where({ ID: req.data.product_ID })
            );
            if (product) {
                req.data.itemPrice = product.price;
                req.data.currency_code = 'BRL';
            }
        });

        this.after(['CREATE', 'UPDATE', 'DELETE'], 'OrderItems.drafts', async (data, req) => {
            const parentID = data.parent_ID || req.data.parent_ID;

            await _recalculateDraftTotal(parentID, req, data);
        });

        this.before('draftActivate', 'Orders', async (req) => {
            await _recalculateActiveTotal(req.data.ID, req);
        });


        this.on('addToCart', 'Products', async (req) => {
            const { quantity, order_ID } = req.data; 
            const productID = req.params[0];
            const userName = req.user.id; 

            if (!quantity || quantity <= 0) return req.error(400, 'A quantidade deve ser maior que zero.');

            const tx = cds.tx(req);
            const product = await tx.run(SELECT.one.from(Products).where({ ID: productID }));
            
            if (!product) return req.error(404, 'Produto não encontrado.');

            let targetOrderID = order_ID;

            if (!targetOrderID) {
                targetOrderID = cds.utils.uuid();
                await tx.run(INSERT.into(Orders.drafts).entries({
                    ID: targetOrderID,
                    customerName: userName,
                    orderNo: `ORD-${Math.floor(1000 + Math.random() * 9000)}`,
                    totalAmount: 0,
                    currency_code: product.currency_code,
                    IsActiveEntity: false,
                    DraftAdministrativeData_DraftUUID: cds.utils.uuid()
                }));
            }

            const itemID = cds.utils.uuid();
            await tx.run(INSERT.into(OrderItems.drafts).entries({
                ID: itemID,
                parent_ID: targetOrderID,
                product_ID: productID,
                quantity: quantity,
                itemPrice: product.price,
                currency_code: product.currency_code,
                IsActiveEntity: false,
                DraftAdministrativeData_DraftUUID: cds.utils.uuid()
            }));

            await _recalculateDraftTotal(targetOrderID, req, { ID: itemID, quantity, itemPrice: product.price });

            return `Produto adicionado ao pedido com sucesso!`;
        });

        await super.init();
    }
}