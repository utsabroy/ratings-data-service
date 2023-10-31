package io.javabrains.ratingsdataservice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class RatingsDataServiceApplication {

	private final Logger log = LoggerFactory.getLogger(RatingsDataServiceApplication.class);

	public static void main(String[] args) {
		SpringApplication.run(RatingsDataServiceApplication.class, args);
	}
}

