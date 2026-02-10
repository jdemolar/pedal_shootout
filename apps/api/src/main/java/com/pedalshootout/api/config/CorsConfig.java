package com.pedalshootout.api.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * CORS (Cross-Origin Resource Sharing) configuration.
 *
 * Browsers block requests from one origin (localhost:8080) to another (localhost:8081)
 * by default — this is a security feature. Since our React dev server runs on port 8080
 * and this API runs on port 8081, we need to explicitly allow cross-origin requests.
 *
 * @Configuration tells Spring this class provides configuration beans.
 * Implementing WebMvcConfigurer lets us hook into Spring MVC's setup process.
 */
@Configuration
public class CorsConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/api/**")           // Apply to all /api/* routes
                .allowedOrigins("http://localhost:8080")  // React dev server
                .allowedMethods("GET");           // Only GET for now
    }
}
