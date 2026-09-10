-- ============================================================
-- VFMS - Virtual File Management System
-- Database Schema
-- ============================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS vfms_db;

USE vfms_db;


-- ============================================================
-- 1. USERS TABLE
-- ============================================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'USER') DEFAULT 'USER',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- ============================================================
-- 2. FOLDERS TABLE
-- ============================================================

CREATE TABLE folders (
    folder_id INT AUTO_INCREMENT PRIMARY KEY,
    folder_name VARCHAR(100) NOT NULL,
    parent_folder_id INT NULL,
    owner_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_folder_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_parent_folder
        FOREIGN KEY (parent_folder_id)
        REFERENCES folders(folder_id)
        ON DELETE CASCADE
);


-- ============================================================
-- 3. FILES TABLE
-- ============================================================

CREATE TABLE files (
    file_id INT AUTO_INCREMENT PRIMARY KEY,

    file_name VARCHAR(255) NOT NULL,

    file_type VARCHAR(50),

    file_size BIGINT DEFAULT 0,

    file_path VARCHAR(500) NOT NULL,

    owner_id INT NOT NULL,

    folder_id INT NULL,

    upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    last_modified TIMESTAMP
        DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    is_deleted BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_file_owner
        FOREIGN KEY (owner_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_file_folder
        FOREIGN KEY (folder_id)
        REFERENCES folders(folder_id)
        ON DELETE SET NULL
);


-- ============================================================
-- 4. FILE VERSIONS TABLE
-- ============================================================

CREATE TABLE file_versions (
    version_id INT AUTO_INCREMENT PRIMARY KEY,

    file_id INT NOT NULL,

    version_number INT NOT NULL,

    file_path VARCHAR(500) NOT NULL,

    file_size BIGINT DEFAULT 0,

    uploaded_by INT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_version_file
        FOREIGN KEY (file_id)
        REFERENCES files(file_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_version_user
        FOREIGN KEY (uploaded_by)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    UNIQUE (file_id, version_number)
);


-- ============================================================
-- 5. SHARED FILES TABLE
-- ============================================================

CREATE TABLE shared_files (
    share_id INT AUTO_INCREMENT PRIMARY KEY,

    file_id INT NOT NULL,

    shared_by INT NOT NULL,

    shared_with INT NOT NULL,

    permission ENUM('VIEW', 'EDIT') DEFAULT 'VIEW',

    shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_shared_file
        FOREIGN KEY (file_id)
        REFERENCES files(file_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_shared_by
        FOREIGN KEY (shared_by)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_shared_with
        FOREIGN KEY (shared_with)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    UNIQUE (file_id, shared_with)
);


-- ============================================================
-- 6. FAVORITES TABLE
-- ============================================================

CREATE TABLE favorites (
    favorite_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    file_id INT NOT NULL,

    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_favorite_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_favorite_file
        FOREIGN KEY (file_id)
        REFERENCES files(file_id)
        ON DELETE CASCADE,

    UNIQUE (user_id, file_id)
);


-- ============================================================
-- 7. TRASH TABLE
-- ============================================================

CREATE TABLE trash (
    trash_id INT AUTO_INCREMENT PRIMARY KEY,

    file_id INT NULL,

    folder_id INT NULL,

    deleted_by INT NOT NULL,

    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    restore_status BOOLEAN DEFAULT FALSE,

    CONSTRAINT fk_trash_file
        FOREIGN KEY (file_id)
        REFERENCES files(file_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_trash_folder
        FOREIGN KEY (folder_id)
        REFERENCES folders(folder_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_trash_user
        FOREIGN KEY (deleted_by)
        REFERENCES users(user_id)
        ON DELETE CASCADE
);


-- ============================================================
-- 8. ACTIVITY LOG TABLE
-- ============================================================

CREATE TABLE activity_logs (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    file_id INT NULL,

    folder_id INT NULL,

    action VARCHAR(50) NOT NULL,

    description VARCHAR(255),

    activity_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_activity_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_activity_file
        FOREIGN KEY (file_id)
        REFERENCES files(file_id)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_folder
        FOREIGN KEY (folder_id)
        REFERENCES folders(folder_id)
        ON DELETE SET NULL
);


-- ============================================================
-- 9. STORAGE TABLE
-- ============================================================

CREATE TABLE storage (
    storage_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,

    total_storage BIGINT DEFAULT 1073741824,

    used_storage BIGINT DEFAULT 0,

    available_storage BIGINT
        GENERATED ALWAYS AS
        (total_storage - used_storage)
        STORED,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_storage_user
        FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    UNIQUE (user_id)
);


-- ============================================================
-- INSERT SAMPLE USERS
-- ============================================================

INSERT INTO users
(full_name, username, email, password, role)
VALUES
('Admin User', 'admin', 'admin@vfms.com', 'admin123', 'ADMIN'),

('Rahul Sharma', 'rahul', 'rahul@vfms.com', 'rahul123', 'USER'),

('Priya Patil', 'priya', 'priya@vfms.com', 'priya123', 'USER'),

('Amit Joshi', 'amit', 'amit@vfms.com', 'amit123', 'USER');


-- ============================================================
-- INSERT SAMPLE FOLDERS
-- ============================================================

INSERT INTO folders
(folder_name, parent_folder_id, owner_id)
VALUES
('Documents', NULL, 2),

('Projects', NULL, 2),

('College', NULL, 2),

('Assignments', 3, 2),

('Personal', NULL, 3);


-- ============================================================
-- INSERT SAMPLE FILES
-- ============================================================

INSERT INTO files
(file_name, file_type, file_size, file_path, owner_id, folder_id)
VALUES
('DBMS_Notes.pdf',
 'PDF',
 204800,
 '/uploads/DBMS_Notes.pdf',
 2,
 1),

('Project_Report.docx',
 'DOCX',
 512000,
 '/uploads/Project_Report.docx',
 2,
 2),

('Python_Practice.py',
 'PY',
 10240,
 '/uploads/Python_Practice.py',
 2,
 3),

('Assignment_1.pdf',
 'PDF',
 307200,
 '/uploads/Assignment_1.pdf',
 2,
 4),

('Personal_Notes.txt',
 'TXT',
 5000,
 '/uploads/Personal_Notes.txt',
 3,
 5);


-- ============================================================
-- INSERT FILE VERSIONS
-- ============================================================

INSERT INTO file_versions
(file_id, version_number, file_path, file_size, uploaded_by)
VALUES
(1, 1, '/uploads/DBMS_Notes.pdf', 204800, 2),

(2, 1, '/uploads/Project_Report.docx', 512000, 2),

(3, 1, '/uploads/Python_Practice.py', 10240, 2);


-- ============================================================
-- INSERT SHARED FILES
-- ============================================================

INSERT INTO shared_files
(file_id, shared_by, shared_with, permission)
VALUES
(1, 2, 3, 'VIEW'),

(2, 2, 3, 'EDIT'),

(3, 2, 4, 'VIEW');


-- ============================================================
-- INSERT FAVORITES
-- ============================================================

INSERT INTO favorites
(user_id, file_id)
VALUES
(2, 1),

(2, 2),

(3, 1);


-- ============================================================
-- INSERT ACTIVITY LOGS
-- ============================================================

INSERT INTO activity_logs
(user_id, file_id, folder_id, action, description)
VALUES
(2, 1, 1, 'UPLOAD', 'Uploaded DBMS Notes'),

(2, 2, 2, 'UPLOAD', 'Uploaded Project Report'),

(2, 3, 3, 'UPLOAD', 'Uploaded Python Practice'),

(2, 1, 1, 'VIEW', 'Viewed DBMS Notes'),

(3, 1, 1, 'VIEW', 'Viewed shared DBMS Notes');


-- ============================================================
-- INSERT STORAGE DATA
-- ============================================================

INSERT INTO storage
(user_id, total_storage, used_storage)
VALUES
(1, 1073741824, 0),

(2, 1073741824, 1021952),

(3, 1073741824, 204800),

(4, 1073741824, 0);


-- ============================================================
-- USEFUL VIEWS
-- ============================================================


-- View 1: File information with owner name

CREATE VIEW file_details AS
SELECT
    f.file_id,
    f.file_name,
    f.file_type,
    f.file_size,
    f.file_path,
    u.full_name AS owner_name,
    fo.folder_name,
    f.upload_date,
    f.last_modified,
    f.is_deleted
FROM files f

JOIN users u
    ON f.owner_id = u.user_id

LEFT JOIN folders fo
    ON f.folder_id = fo.folder_id;


-- View 2: Shared files

CREATE VIEW shared_file_details AS
SELECT
    sf.share_id,
    f.file_name,

    sender.full_name AS shared_by,

    receiver.full_name AS shared_with,

    sf.permission,

    sf.shared_at

FROM shared_files sf

JOIN files f
    ON sf.file_id = f.file_id

JOIN users sender
    ON sf.shared_by = sender.user_id

JOIN users receiver
    ON sf.shared_with = receiver.user_id;


-- View 3: Storage information

CREATE VIEW storage_details AS
SELECT
    u.user_id,
    u.full_name,
    s.total_storage,
    s.used_storage,
    s.available_storage
FROM users u

JOIN storage s
    ON u.user_id = s.user_id;


-- ============================================================
-- BASIC TEST QUERIES
-- ============================================================

-- Show all users
SELECT * FROM users;


-- Show all folders
SELECT * FROM folders;


-- Show all files
SELECT * FROM files;


-- Show file details
SELECT * FROM file_details;


-- Show shared files
SELECT * FROM shared_file_details;


-- Show storage information
SELECT * FROM storage_details;


-- Show activity logs
SELECT * FROM activity_logs;


-- ============================================================
-- END OF VFMS DATABASE
-- ============================================================