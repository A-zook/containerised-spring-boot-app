package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    @GetMapping("/hello")
    public String sayHello() {
        return "Hello from Spring Boot - STAGING Environment!";
    }

    @GetMapping("/status")
    public String getStatus() {
        return "Staging server is running! Version 1.1";
    }
}
