-- 创建数据库
CREATE DATABASE IF NOT EXISTS knowledge_base CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE knowledge_base;

-- 创建文档表
CREATE TABLE IF NOT EXISTS documents (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    published_at TIMESTAMP NULL DEFAULT NULL,
    reference_summary TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建摘要表
CREATE TABLE IF NOT EXISTS summaries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    document_id INT NOT NULL,
    summary TEXT NOT NULL,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建评估指标表
CREATE TABLE IF NOT EXISTS summary_metrics (
    id INT AUTO_INCREMENT PRIMARY KEY,
    summary_id INT NOT NULL,
    rouge1 FLOAT,
    evaluated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (summary_id) REFERENCES summaries(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 创建索引
CREATE INDEX idx_generated_at ON summaries(generated_at);
CREATE INDEX idx_evaluated_at ON summary_metrics(evaluated_at);