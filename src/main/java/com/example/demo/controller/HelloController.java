package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/hello")
    public String sayHello() {
        return "Hello from Spring Boot - DEV Environment!";
    }

    @GetMapping("/dev")
    public String getDevInfo() {
        return "Development server active! Version 0.1-SNAPSHOT";
    }

    @GetMapping("/status")
    public String getStatus() {
        return "Dev server is running! Version 0.1-SNAPSHOT";
    }
}
