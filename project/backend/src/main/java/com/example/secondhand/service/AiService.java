package com.example.secondhand.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class AiService {

    @Value("${ai.deepseek.api-key:}")
    private String apiKey;

    @Value("${ai.deepseek.base-url:https://api.deepseek.com}")
    private String baseUrl;

    @Value("${ai.deepseek.model:deepseek-chat}")
    private String model;

    private static final String SYSTEM_PROMPT =
            "你是一名专业的二手闲置物品估价助手。请根据用户提供的商品名称、成色和描述，"
                    + "给出合理的二手估价，并生成优化后的标题和描述。"
                    + "必须严格按照 JSON 格式输出，不要输出任何多余文字或 Markdown，字段如下："
                    + "{\"price\": 建议挂牌价(数字,单位元), \"priceRange\": \"建议价格区间,如 3500-4200 元\", "
                    + "\"title\": \"优化后的商品标题\", \"description\": \"优化后的商品描述\", "
                    + "\"analysis\": \"估价理由与建议(1-2句话)\"}";

    private final ObjectMapper objectMapper = new ObjectMapper();

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    public Map<String, Object> appraise(String name, String description, String quality) {
        ObjectNode root = objectMapper.createObjectNode();
        root.put("model", model);
        ArrayNode messages = root.putArray("messages");
        ObjectNode sys = messages.addObject();
        sys.put("role", "system");
        sys.put("content", SYSTEM_PROMPT);
        ObjectNode usr = messages.addObject();
        usr.put("role", "user");
        usr.put("content", "商品名称：" + name + "\n成色：" + (quality == null ? "" : quality)
                + "\n描述：" + (description == null ? "" : description) + "\n请给出估价。");
        root.put("temperature", 0.7);
        root.put("stream", false);
        ObjectNode rf = root.putObject("response_format");
        rf.put("type", "json_object");

        try {
            String body = objectMapper.writeValueAsString(root);
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(baseUrl + "/v1/chat/completions"))
                    .timeout(Duration.ofSeconds(60))
                    .header("Content-Type", "application/json")
                    .header("Authorization", "Bearer " + apiKey)
                    .POST(HttpRequest.BodyPublishers.ofString(body))
                    .build();

            HttpResponse<String> resp = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            JsonNode respNode = objectMapper.readTree(resp.body());
            String content = respNode.path("choices").path(0).path("message").path("content").asText("");
            JsonNode result = objectMapper.readTree(content);

            Map<String, Object> out = new LinkedHashMap<>();
            out.put("price", result.path("price").asDouble(0));
            out.put("priceRange", result.path("priceRange").asText(""));
            out.put("title", result.path("title").asText(""));
            out.put("description", result.path("description").asText(""));
            out.put("analysis", result.path("analysis").asText(""));
            return out;
        } catch (Exception e) {
            throw new RuntimeException("AI 服务调用失败：" + e.getMessage(), e);
        }
    }
}
