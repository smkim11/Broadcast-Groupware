package com.example.broadcastgroupware.rest;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.server.ResponseStatusException;

import reactor.core.publisher.Mono;

@RestController
@RequestMapping("/api/weather")
public class WeatherRestController {
	
	@Value("${weather.owm.base-url}") private String baseUrl;
	@Value("${weather.owm.api-key}")  private String apiKey;
	@Value("${weather.owm.units}")	  private String defaultUnits;
	@Value("${weather.owm.lang}") 	  private String defaultLang;
	
	private final WebClient.Builder webClientBuilder;
	
	public WeatherRestController(WebClient.Builder webClientBuilder) {
		this.webClientBuilder = webClientBuilder;
	}
	
	 // 빠졌던 헬퍼 추가
    private WebClient web() {
        return webClientBuilder.baseUrl(baseUrl).build();
    }
	
	//@Cacheable(cacheNames = "wx:current", key ="#lat + ',' + #lon + ':' + #units + ':' + #lang", unless = "#result == null")
	
	@GetMapping("/current")
	public Mono<Map<String,Object>> current(
            @RequestParam(required = false) Double lat,
            @RequestParam(required = false) Double lon,
            @RequestParam(required = false) String city,
            @RequestParam(required = false) String units,
            @RequestParam(required = false) String lang) {

		final String u = (units == null || units.isBlank()) ? defaultUnits.trim() : units.trim();
		final String l = (lang  == null || lang.isBlank())  ? defaultLang.trim()  : lang.trim();
        final String qCity = (city == null || city.isBlank()) ? "서울" : city.trim();


        Mono<double[]> coordsMono;

        if (lat != null && lon != null) {
            coordsMono = Mono.just(new double[]{lat, lon});
        } else if (city != null && !city.isBlank()) {
            // 1) 도시명 → 좌표(OWM 지오코딩)
            coordsMono = web().get().uri(uri -> uri.path("/geo/1.0/direct")
                    .queryParam("q", qCity)
                    .queryParam("limit", 1)
                    .queryParam("appid", apiKey)
                    .queryParam("lang", l) // 선택사항(지오코딩도 lang 지원)
                    .build())
                .retrieve()
                .onStatus(
                    HttpStatusCode::isError,
                    resp -> resp.bodyToMono(String.class).flatMap(body ->
                        Mono.error(new ResponseStatusException(resp.statusCode(), body))))
                .bodyToMono(new ParameterizedTypeReference<List<Map<String, Object>>>() {})
                .flatMap(list -> {
                    if (list == null || list.isEmpty()) {
                        return Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "City not found"));
                    }
                    Map<String, Object> first = list.get(0);
                    Double glat = toDouble(first.get("lat"));
                    Double glon = toDouble(first.get("lon"));
                    if (glat == null || glon == null) {
                        return Mono.error(new ResponseStatusException(HttpStatus.NOT_FOUND, "Coordinate not found"));
                    }
                    return Mono.just(new double[]{glat, glon});
                });
        } else {
            // 둘 다 없는 경우
            return Mono.error(new ResponseStatusException(HttpStatus.BAD_REQUEST, "lat/lon or city is required"));
        }

        // 2) 좌표 → 현재 날씨
        return coordsMono.flatMap(coords ->
            web().get().uri(uri -> uri.path("/data/2.5/weather")
                    .queryParam("lat", coords[0])
                    .queryParam("lon", coords[1])
                    .queryParam("appid", apiKey)
                    .queryParam("units", u)
                    .queryParam("lang", l)
                    .build())
                .retrieve()
                .onStatus(
                    HttpStatusCode::isError,
                    resp -> resp.bodyToMono(String.class).flatMap(body ->
                        Mono.error(new ResponseStatusException(resp.statusCode(), body))))
                .bodyToMono(new ParameterizedTypeReference<Map<String, Object>>() {}));
    }

    private static Double toDouble(Object o) {
        if (o instanceof Number n) return n.doubleValue();
        try { return o != null ? Double.parseDouble(o.toString()) : null; }
        catch (Exception e) { return null; }
    }
}
