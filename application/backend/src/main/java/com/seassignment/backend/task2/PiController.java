package com.seassignment.backend.task2;

import jakarta.validation.Valid;

import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/task2")
public class PiController {

    private final PiService piService;

    public PiController(PiService piService) {
        this.piService = piService;
    }

    @PostMapping("/pi")
    public PiResult calculatePi(@Valid @RequestBody PiRequest request) {
        return piService.calculatePi(request.precision());
    }
}