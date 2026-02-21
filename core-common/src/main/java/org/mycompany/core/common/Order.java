package org.mycompany.core.common;

public record Order(
        Long id,
        Long customerId,
        Long productId,
        int productCount,
        int price,
        String status,
        String source
) {
    // Constructor 1: Defaults count/price to 0 and source to null
    public Order(Long id, Long customerId, Long productId, String status) {
        this(id, customerId, productId, 0, 0, status, null);
    }

    // Constructor 2: Defaults status to "NEW" and source to null
    public Order(Long id, Long customerId, Long productId, int productCount, int price) {
        this(id, customerId, productId, productCount, price, "NEW", null);
    }

    public Order(Long id, Long customerId, Long productId, int productCount, int price, String status) {
        this(id, customerId, productId, productCount, price, status, null);
    }

    // This for whole controller
    public Order {
    }
}