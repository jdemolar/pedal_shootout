package com.pedalshootout.api;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * Entry point for the Spring Boot application.
 *
 * @SpringBootApplication is a shortcut that combines three annotations:
 *   - @Configuration: This class can define beans (objects Spring manages)
 *   - @EnableAutoConfiguration: Spring Boot auto-configures based on your dependencies
 *     (e.g., sees postgresql driver → configures a DataSource)
 *   - @ComponentScan: Scans this package and sub-packages for @Controller, @Service,
 *     @Repository classes and registers them automatically
 *
 * Think of it like the "app.listen()" in Express — it boots the embedded Tomcat server
 * and wires everything together.
 */
@SpringBootApplication
public class PedalShootoutApiApplication {

    public static void main(String[] args) {
        SpringApplication.run(PedalShootoutApiApplication.class, args);
    }
}
