package com.seassignment.backend.task2;

import org.springframework.stereotype.Service;

@Service
public class PiService {

    private final PiRepository piRepository;

    public PiService(PiRepository piRepository) {
        this.piRepository = piRepository;
    }

    public PiResult calculatePi(Integer precision) {
        return new PiResult(
                precision,
                piRepository.calculatePi(precision)
        );
    }
}