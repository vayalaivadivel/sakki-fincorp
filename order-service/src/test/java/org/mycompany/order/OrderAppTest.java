package org.mycompany.order;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.ApplicationContext;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
public class OrderAppTest {


    // You can optionally inject the ApplicationContext to perform checks
    @Autowired
    private ApplicationContext context;

    /**
     * A simple test to check if the application context loads successfully.
     * If the context fails to load, an exception will be thrown, causing the test to fail.
     */
    @Test
    void contextLoads() {
        // Empty method is sufficient; if no exception is thrown, the test passes.
        // You can add assertions to verify specific beans are loaded, e.g.,
        assertThat(context).isNotNull();
    }
}
