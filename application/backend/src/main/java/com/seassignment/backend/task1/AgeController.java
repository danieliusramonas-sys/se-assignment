// AgeController.java
package com.seassignment.backend.task1;

import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/task1")
public class AgeController {

    private final AgeService ageService;

    public AgeController(AgeService ageService) {
        this.ageService = ageService;
    }

    @PostMapping("/age")
    public AgeResult calculateAge(@Valid @RequestBody AgeRequest request) {
        return ageService.calculateAge(request.age());
    }
}