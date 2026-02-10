package com.pedalshootout.api;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

/**
 * Smoke test — verifies the Spring application context loads successfully.
 * This catches configuration errors, missing beans, and entity mapping issues.
 */
@SpringBootTest
class PedalShootoutApiApplicationTests {

    @Test
    void contextLoads() {
        // If this test passes, it means:
        //   1. All @Entity classes mapped to database tables correctly
        //   2. All @Repository, @Service, @Controller beans wired up
        //   3. Database connection works
        //   4. Flyway baseline ran successfully
    }
}
