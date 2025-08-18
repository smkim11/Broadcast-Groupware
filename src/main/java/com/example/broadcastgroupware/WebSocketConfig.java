package com.example.broadcastgroupware;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    /**
     * 클라이언트가 연결할 엔드포인트를 정의
     * 예: ws://localhost:8080/ws-stomp
     */
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // SockJS를 지원하는 STOMP 엔드포인트 등록
        registry.addEndpoint("/ws-stomp")
                .setAllowedOrigins("*") // CORS 허용
                .withSockJS(); // SockJS 사용
    }

    /**
     * 메시지 브로커 설정
     */
    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // 서버 → 클라이언트로 메시지를 보낼 때 사용할 경로 prefix
        // /topic → 여러 명에게 브로드캐스트, /queue → 1:1 메시지
        registry.enableSimpleBroker("/topic", "/queue");

        // 클라이언트 → 서버로 메시지를 보낼 때 prefix
        registry.setApplicationDestinationPrefixes("/app");
    }
}
