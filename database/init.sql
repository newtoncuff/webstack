-- Initialize database with basic structure
-- This file will be executed when the MySQL container starts for the first time

-- Create database if it doesn't exist (MySQL container should already create it)
CREATE DATABASE IF NOT EXISTS annotyze_db;

-- Grant permissions to the user for this database
GRANT ALL PRIVILEGES ON annotyze_db.* TO 'nalan'@'%';
FLUSH PRIVILEGES;

USE annotyze_db;

-- Create a simple table to store system information
CREATE TABLE IF NOT EXISTS system_info (
    id INT AUTO_INCREMENT PRIMARY KEY,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insert initial record
INSERT INTO system_info (id) VALUES (1);
