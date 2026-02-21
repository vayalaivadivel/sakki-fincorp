package org.mycompany.order.service;

import org.mycompany.core.common.Order;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

@Service
public class OrderManageService {
    private static final Logger LOG = LoggerFactory.getLogger(OrderManageService.class);

    public Order confirm(Order orderPayment, Order orderStock) {
        LOG.info("Order payment status: {}", orderPayment.status());


        String status=orderPayment.status();
        String source=orderPayment.source();
        if (orderPayment.status().equals("ACCEPT") &&
                orderStock.status().equals("ACCEPT")) {
            status="CONFIRMED";
        } else if (orderPayment.status().equals("REJECT") &&
                orderStock.status().equals("REJECT")) {
            status="REJECTED";
        } else if (orderPayment.status().equals("REJECT") ||
                orderStock.status().equals("REJECT")) {
            source = orderPayment.status().equals("REJECT")
                    ? "PAYMENT" : "STOCK";
            status="ROLLBACK";
        }


        return new Order(orderPayment.id(),
                orderPayment.customerId(),
                orderPayment.productId(),
                orderPayment.productCount(),
                orderPayment.price(), status, source);
    }
}
