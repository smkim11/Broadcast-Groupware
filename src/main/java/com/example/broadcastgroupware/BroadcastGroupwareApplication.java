package com.example.broadcastgroupware;

import org.springframework.boot.SpringApplication;

import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@EnableScheduling
@SpringBootApplication
public class BroadcastGroupwareApplication implements WebMvcConfigurer{

	public static void main(String[] args) {
		SpringApplication.run(BroadcastGroupwareApplication.class, args);
	}
	@Override
	public void addResourceHandlers(ResourceHandlerRegistry registry) {
		// registry.addResourceHandler("/final/**").addResourceLocations("file:///C:/final/"); 로컬경로
		registry.addResourceHandler("/upload/**")
		.addResourceLocations("file:/home/ubuntu/upload/");
	}
}
