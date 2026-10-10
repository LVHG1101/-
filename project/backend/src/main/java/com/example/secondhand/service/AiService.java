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

    private static final String APPRAISE_SYSTEM_PROMPT =
            "你是一名专业的二手闲置物品估价助手。请根据用户提供的商品名称、成色和描述，"
                    + "给出合理的二手估价，并生成优化后的标题和描述。"
                    + "必须严格按照 JSON 格式输出，不要输出任何多余文字或 Markdown，字段如下："
                    + "{\"price\": 建议挂牌价(数字,单位元), \"priceRange\": \"建议价格区间,如 3500-4200 元\", "
                    + "\"title\": \"优化后的商品标题\", \"description\": \"优化后的商品描述\", "
                    + "\"analysis\": \"估价理由与建议(1-2句话)\"}";

    private static final String CHAT_SYSTEM_PROMPT =
            "你是「二手集市」App 的智能客服小助手，请用简洁、友好、口语化的语气回答用户关于本软件使用的问题。"
                    + "本软件是一个二手闲置交易平台，主要功能：\n"
                    + "1. 发布闲置：底部「发布」Tab 填写名称、价格、成色、分类、图片、描述，可点「AI 智能估价」自动生成价格与文案建议。\n"
                    + "2. 浏览与搜索：首页看附近好物，分类 Tab 按分类浏览，搜索支持关键词+分类+价格排序。\n"
                    + "3. 购物车与订单：加购物车后结算下单，订单有待付款/待收货/已完成/售后等状态。\n"
                    + "4. 拍卖：发布或参与竞拍，出价须高于当前价，到期自动结束。\n"
                    + "5. 换物：发布想换出的物品和想换的物品，或申请换物。\n"
                    + "6. 二手服务：回收、鉴定、维修、清洗、租赁、跑腿等服务预约。\n"
                    + "7. 信誉分：初始 100 分，交易完成加分，售后成立扣分，低于 60 分限制发布。\n"
                    + "8. 碳积分：订单完成双方各 +10 碳积分。\n"
                    + "9. 个人中心：实名认证、收货地址、我的收藏、我的发布、我的信用等。\n"
                    + "如果用户问的问题与本软件无关，请友好地引导回软件使用话题。回答控制在 200 字以内。";

    private final ObjectMapper objectMapper = new ObjectMapper();

    private final HttpClient httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(15))
            .build();

    /** 智能估价 + 标题/描述生成 */
    public Map<String, Object> appraise(String name, String description, String quality) {
        try {
            String content = callDeepSeek(APPRAISE_SYSTEM_PROMPT,
                    "商品名称：" + name + "\n成色：" + (quality == null ? "" : quality)
                            + "\n描述：" + (description == null ? "" : description) + "\n请给出估价。",
                    true);
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

    /** 通用智能客服问答 */
    public String chat(String question) {
        try {
            return callDeepSeek(CHAT_SYSTEM_PROMPT, question, false);
        } catch (Exception e) {
            throw new RuntimeException("AI 助手调用失败：" + e.getMessage(), e);
        }
    }

    private String callDeepSeek(String systemPrompt, String userContent, boolean jsonFormat) throws Exception {
        ObjectNode root = objectMapper.createObjectNode();
        root.put("model", model);
        ArrayNode messages = root.putArray("messages");
        ObjectNode sys = messages.addObject();
        sys.put("role", "system");
        sys.put("content", systemPrompt);
        ObjectNode usr = messages.addObject();
        usr.put("role", "user");
        usr.put("content", userContent);
        root.put("temperature", 0.7);
        root.put("stream", false);
        if (jsonFormat) {
            ObjectNode rf = root.putObject("response_format");
            rf.put("type", "json_object");
        }

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
        if (resp.statusCode() != 200) {
            String errMsg = respNode.path("error").path("message").asText(resp.body());
            throw new RuntimeException("DeepSeek 返回错误(" + resp.statusCode() + "): " + errMsg);
        }
        JsonNode choices = respNode.path("choices");
        if (!choices.isArray() || choices.isEmpty()) {
            throw new RuntimeException("DeepSeek 未返回有效内容");
        }
        return choices.path(0).path("message").path("content").asText("");
    }
}
