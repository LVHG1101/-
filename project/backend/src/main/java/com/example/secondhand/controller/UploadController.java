package com.example.secondhand.controller;

import org.springframework.web.bind.annotation.*;

import java.io.File;
import java.nio.file.Files;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/upload")
public class UploadController {

    @PostMapping("/image")
    public Map<String, Object> uploadImage(@RequestBody Map<String, String> body) {
        Map<String, Object> map = new HashMap<>();
        String base64 = body.get("base64");
        if (base64 == null || base64.isEmpty()) {
            map.put("code", 400);
            map.put("message", "图片数据为空");
            return map;
        }
        try {
            String ext = "jpg";
            String data = base64;
            if (base64.contains(",")) {
                String[] parts = base64.split(",");
                String mime = parts[0];
                if (mime.contains("png")) {
                    ext = "png";
                } else if (mime.contains("webp")) {
                    ext = "webp";
                } else if (mime.contains("gif")) {
                    ext = "gif";
                }
                data = parts[1];
            }
            byte[] bytes = Base64.getDecoder().decode(data);
            File dir = new File("uploads");
            if (!dir.exists()) {
                dir.mkdirs();
            }
            String fileName = UUID.randomUUID().toString() + "." + ext;
            Files.write(new File(dir, fileName).toPath(), bytes);
            map.put("code", 200);
            map.put("message", "上传成功");
            map.put("data", fileName);
        } catch (Exception e) {
            map.put("code", 400);
            map.put("message", "图片上传失败");
        }
        return map;
    }
}
