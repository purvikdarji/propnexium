package com.propnexium.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

/**
 * Application-level configuration and constants.
 * TODO: Add application-scope beans (e.g. ModelMapper, Jackson, caching) as
 * needed.
 */
@Configuration
public class AppConfig {

    @Value("${propnexium.app.name}")
    private String appName;

    @Value("${propnexium.app.version}")
    private String appVersion;

    @Value("${propnexium.app.base-url}")
    private String baseUrl;

    @Value("${propnexium.upload.directory}")
    private String uploadDirectory;

    // Additional application-scope beans go here
}
