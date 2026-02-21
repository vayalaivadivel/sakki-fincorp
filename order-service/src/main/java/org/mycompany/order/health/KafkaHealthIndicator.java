package org.mycompany.order.health;

import org.apache.kafka.clients.admin.AdminClient;
import org.apache.kafka.clients.admin.ListTopicsOptions;
import org.apache.kafka.clients.admin.ListTopicsResult;
import org.springframework.boot.actuate.health.AbstractHealthIndicator;
import org.springframework.boot.actuate.health.Health;
import org.springframework.stereotype.Component;

import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Component
public class KafkaHealthIndicator extends AbstractHealthIndicator {
    private final AdminClient adminClient;

    public KafkaHealthIndicator(AdminClient adminClient) {
        this.adminClient = adminClient; // singleton
    }

    @Override
    protected void doHealthCheck(Health.Builder builder) {
        try {
            // Cluster info
            var cluster = adminClient.describeCluster();
            String clusterId = cluster.clusterId().get(3, TimeUnit.SECONDS);
            int nodeCount = cluster.nodes().get(3, TimeUnit.SECONDS).size();

            // Topics
            ListTopicsOptions options = new ListTopicsOptions();
            options.listInternal(false); // ignore internal topics
            ListTopicsResult topicsResult = adminClient.listTopics(options);

            var topics = topicsResult.names().get(5, TimeUnit.SECONDS)
                    .stream()
                    .sorted()
                    .collect(Collectors.toList());

            builder.up()
                    .withDetail("clusterId", clusterId)
                    .withDetail("nodeCount", nodeCount)
                    .withDetail("topics", topics);

        } catch (Exception e) {
            builder.down(e)
                    .withDetail("reason", e.getClass().getSimpleName() + ": " + e.getMessage());
        }
    }
}