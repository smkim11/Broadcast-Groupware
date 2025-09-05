package com.example.broadcastgroupware.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.NoOpPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;

import jakarta.servlet.DispatcherType;

@Configuration
public class SecurityConfig {

    @Autowired
    private CustomLoginSuccessHandler customLoginSuccessHandler;  // CustomLoginSuccessHandler 빈 주입

    @Autowired
    private UserDetailsService userDetailsService;
    
    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())
            .authorizeHttpRequests(auth -> auth
            	.dispatcherTypeMatchers(DispatcherType.FORWARD).permitAll() // JSP forward 허용
                .requestMatchers("/api/find/password", "/login", "/logout", "/resources/**", "/css/**", "/js/**", "/ws-stomp/**", "/session/**").permitAll()
                .requestMatchers("/home").hasAnyRole("admin","user")
                .requestMatchers("/lock", "/unlock").authenticated()
                .requestMatchers("/admin/**").hasRole("admin")
                .requestMatchers("/user/**", "/approval/**", "/myPage").hasAnyRole("admin", "user")
                .anyRequest().authenticated()
            )
            .formLogin(form -> form
                .loginPage("/login")
                .loginProcessingUrl("/login")
                .successHandler(customLoginSuccessHandler)  // 주입 받은 빈 사용
                .failureUrl("/login?error=1")   // 실패 시 ?error=1 추가
                .permitAll()
            )
            
            .logout(logout -> logout
            	.logoutRequestMatcher(new AntPathRequestMatcher("/logout", "GET"))
                .logoutUrl("/logout")
                .logoutSuccessUrl("/login?logout")
                .invalidateHttpSession(true)
                .deleteCookies("JSESSIONID","remember-me")
                .permitAll()
            );
        

        return http.build();
    }

    @Bean
    public AuthenticationManager authenticationManager(HttpSecurity http) throws Exception {
        return http.getSharedObject(AuthenticationManagerBuilder.class)
                   .userDetailsService(userDetailsService)
                   .passwordEncoder(passwordEncoder())
                   .and()
                   .build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return NoOpPasswordEncoder.getInstance();
        
        // 암호화 비밀번호 사용 시 주석 해제해서 사용: bcrypt 해시 비교(운영 권장)
        // return new BCryptPasswordEncoder();
    }
}
