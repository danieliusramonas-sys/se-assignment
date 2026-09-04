package com.seassignment.backend.task2;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/task2")
public class PiController {

    private final PiService piService;

    public PiController(PiService piService) {
        this.piService = piService;
    }

    @GetMapping("/pi")
    public PiResult calculatePi(@RequestParam Integer precision) {
        return piService.calculatePi(precision);
    }
}
