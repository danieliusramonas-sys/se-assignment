// AgeService.java
package com.seassignment.backend.task1;

import org.springframework.stereotype.Service;

@Service
public class AgeService {

    private final AgeRepository ageRepository;

    public AgeService(AgeRepository ageRepository) {
        this.ageRepository = ageRepository;
    }

    public AgeResult calculateAge(Integer age) {
        return ageRepository.getAgeResult(age);
    }
}