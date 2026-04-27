package com.spring.flyway.controller;

import com.spring.flyway.entity.Product;
import com.spring.flyway.entity.User;
import com.spring.flyway.repository.ProductRepository;
import com.spring.flyway.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Simple REST controller to verify that the migrated schema works correctly.
 * <p>
 * Available endpoints:
 *  GET  /api/users           - list all users (seeded by V4)
 *  GET  /api/users/{id}      - get user by id
 *  POST /api/users           - create a new user
 *  GET  /api/products        - list all products (seeded by V4)
 *  GET  /api/products/{id}   - get product by id
 *  POST /api/products        - create a new product
 *  GET  /api/flyway/info     - show migration history info
 */
@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class DemoController {

    private final UserRepository userRepository;
    private final ProductRepository productRepository;

    // ─── Users ────────────────────────────────────────────────────────────────

    @GetMapping("/users")
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/users/{id}")
    public ResponseEntity<User> getUserById(@PathVariable Long id) {
        return userRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/users")
    public User createUser(@RequestBody User user) {
        return userRepository.save(user);
    }

    // ─── Products ─────────────────────────────────────────────────────────────

    @GetMapping("/products")
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }

    @GetMapping("/products/{id}")
    public ResponseEntity<Product> getProductById(@PathVariable Long id) {
        return productRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/products")
    public Product createProduct(@RequestBody Product product) {
        return productRepository.save(product);
    }
}

