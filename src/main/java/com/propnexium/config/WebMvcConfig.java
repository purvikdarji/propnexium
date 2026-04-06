package com.propnexium.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

/**
 * Web MVC configuration — static resource handlers, view resolvers, etc.
 * TODO: Add additional MVC customizations as needed.
 */
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${propnexium.upload.directory}")
    private String uploadDirectory;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Serve uploaded files from the uploads directory
        Path uploadPath = Paths.get(uploadDirectory).toAbsolutePath();
        registry.addResourceHandler("/uploads/**")
                .addResourceLocations(uploadPath.toUri().toString() + "/");

        // Static assets
        registry.addResourceHandler("/static/**")
                .addResourceLocations("classpath:/static/");
    }
}
