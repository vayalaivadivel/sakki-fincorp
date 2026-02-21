package org.mycompany.order.controller;

import org.apache.kafka.streams.StoreQueryParameters;
import org.apache.kafka.streams.state.KeyValueIterator;
import org.apache.kafka.streams.state.QueryableStoreTypes;
import org.apache.kafka.streams.state.ReadOnlyKeyValueStore;
import org.mycompany.core.common.Order;
import org.mycompany.order.service.OrderGeneratorService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.config.StreamsBuilderFactoryBean;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

@RestController
@RequestMapping("/orders")
public class OrderController {

    private static final Logger LOG = LoggerFactory.getLogger(OrderController.class);
    private final AtomicLong id = new AtomicLong();
    private final KafkaTemplate<Long, Order> template;
    private final StreamsBuilderFactoryBean kafkaStreamsFactory;
    private final OrderGeneratorService orderGeneratorService;

    public OrderController(KafkaTemplate<Long, Order> template,
                           StreamsBuilderFactoryBean kafkaStreamsFactory,
                           OrderGeneratorService orderGeneratorService) {
        this.template = template;
        this.kafkaStreamsFactory = kafkaStreamsFactory;
        this.orderGeneratorService = orderGeneratorService;
    }

    @PostMapping
    public Order create(@RequestBody Order order) {
        Order updatedOrder = new Order(
                id.incrementAndGet(),
                order.customerId(),
                order.productId(),
                2,    // new count
                100,  // new price
                order.status(),
                order.source()
        );
        template.send("orders", updatedOrder.id(), updatedOrder);
        LOG.info("Order has been sent: {}", updatedOrder);
        return updatedOrder;
    }

    @PostMapping("/generate")
    public boolean create() {
        LOG.info("Create multiple orders");
        orderGeneratorService.generate();
        return true;
    }

    @GetMapping
    public List<Order> all() {
        List<Order> orders = new ArrayList<>();
        ReadOnlyKeyValueStore<Long, Order> store = kafkaStreamsFactory
                .getKafkaStreams()
                .store(StoreQueryParameters.fromNameAndType(
                        "orders",
                        QueryableStoreTypes.keyValueStore()));
        KeyValueIterator<Long, Order> it = store.all();
        it.forEachRemaining(kv -> orders.add(kv.value));
        return orders;
    }
}