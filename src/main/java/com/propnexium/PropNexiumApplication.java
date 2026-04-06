package com.propnexium;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;

/**
 * PropNexium — Real Estate Platform
 *
 * Entity Relationship Diagram:
 *   users (1) <---> (1) agent_profiles
 *   users (1) <---> (N) properties         [as agent]
 *   properties (1) <---> (N) property_images
 *   properties (1) <---> (1) property_amenities
 *   properties (1) <---> (N) inquiries
 *   users (1) <---> (N) inquiries           [as inquirer]
 *   users (1) <---> (N) wishlists
 *   properties (1) <---> (N) wishlists
 *   users (1) <---> (N) reviews             [as agent]
 *   users (1) <---> (N) reviews             [as reviewer]
 *   users (1) <---> (N) notifications
 */
@SpringBootApplication
@EnableAsync
@EnableScheduling
public class PropNexiumApplication extends SpringBootServletInitializer {

    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(PropNexiumApplication.class);
    }

    public static void main(String[] args) {
        SpringApplication.run(PropNexiumApplication.class, args);
    }
}
