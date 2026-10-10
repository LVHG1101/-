package com.example.secondhand.controller;

import com.example.secondhand.service.AiService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/ai")
public class AiController {

    @Autowired
    private AiService aiService;

    /** AI 智能估价 + 标题/描述生成 */
    @PostMapping("/appraise")
    public Map<String, Object> appraise(@RequestBody Map<String, Object> body) {
        Map<String, Object> map = new HashMap<>();
        String name = body.get("name") == null ? "" : String.valueOf(body.get("name"));
        String description = body.get("description") == null ? "" : String.valueOf(body.get("description"));
        String quality = body.get("quality") == null ? "" : String.valueOf(body.get("quality"));
        if (name.isBlank()) {
            map.put("code", 400);
            map.put("message", "商品名称不能为空");
            return map;
        }
        try {
            map.put("code", 200);
            map.put("message", "估价成功");
            map.put("data", aiService.appraise(name, description, quality));
        } catch (Exception e) {
            map.put("code", 500);
            map.put("message", e.getMessage());
        }
        return map;
    }

    /** AI 智能客服问答 */
    @PostMapping("/chat")
    public Map<String, Object> chat(@RequestBody Map<String, String> body) {
        Map<String, Object> map = new HashMap<>();
        String question = body.getOrDefault("question", "");
        if (question.isBlank()) {
            map.put("code", 400);
            map.put("message", "问题不能为空");
            return map;
        }
        try {
            Map<String, Object> data = new HashMap<>();
            data.put("answer", aiService.chat(question));
            map.put("code", 200);
            map.put("message", "回复成功");
            map.put("data", data);
        } catch (Exception e) {
            map.put("code", 500);
            map.put("message", e.getMessage());
        }
        return map;
    }
}
