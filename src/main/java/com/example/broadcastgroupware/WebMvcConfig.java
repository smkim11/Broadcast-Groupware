package com.example.broadcastgroupware;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

  @Override
  public void addResourceHandlers(ResourceHandlerRegistry registry) {
    // /uploads/**  →  C:\final\** 로 매핑
    registry.addResourceHandler("/uploads/**")  
            // .addResourceLocations("file:/c:/final/"); // 마지막 슬래시 꼭!  로컬경로
    		.addResourceLocations("file:/home/ubuntu/upload/");
  }
}
