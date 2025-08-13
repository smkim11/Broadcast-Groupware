package com.example.broadcastgroupware;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;

@SpringBootApplication
public class BroadcastGroupwareApplication {

	public static void main(String[] args) {
		SpringApplication.run(BroadcastGroupwareApplication.class, args);
	}
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		registry.addResourceHandler("/final/**").addResourceLocations("file:///C:/final/");
	}
}
