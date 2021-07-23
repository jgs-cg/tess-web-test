package com.capgroup.tess.tess_web_auto.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties
@ComponentScan("com.capgroup.tess.tess_web_auto")
public class SpringConfig {

    private String url;
    private String environment;
}
