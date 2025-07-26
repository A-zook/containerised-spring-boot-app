package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/hello")
    public String sayHello() {
        return "Hello from Spring Boot - PRODUCTION Environment!";
    }

    @GetMapping("/health")
    public String getHealth() {
        return "Production server is healthy! Version 2.0";
    }
}
