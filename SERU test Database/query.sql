-- C:\Users\ridzk\OneDrive\Pictures\tes\query.sql
-- Buat database jika belum ada
CREATE DATABASE IF NOT EXISTS tes_seru;

-- Gunakan database
USE tes_seru;

-- Buat tabel guru jika belum ada
CREATE TABLE IF NOT EXISTS teachers (
    id INT AUTO_INCREMENT,
    name VARCHAR(100),
    subject VARCHAR(50),
    PRIMARY KEY(id)
);

-- Masukkan data ke tabel guru jika belum ada
INSERT INTO teachers (name, subject) 
SELECT 'Pak Anton', 'Matematika'
WHERE NOT EXISTS (SELECT 1 FROM teachers WHERE name = 'Pak Anton' AND subject = 'Matematika');

INSERT INTO teachers (name, subject) 
SELECT 'Bu Dina', 'Bahasa Indonesia'
WHERE NOT EXISTS (SELECT 1 FROM teachers WHERE name = 'Bu Dina' AND subject = 'Bahasa Indonesia');

INSERT INTO teachers (name, subject) 
SELECT 'Pak Eko', 'Biologi'
WHERE NOT EXISTS (SELECT 1 FROM teachers WHERE name = 'Pak Eko' AND subject = 'Biologi');

-- Buat tabel kelas jika belum ada
CREATE TABLE IF NOT EXISTS classes (
    id INT AUTO_INCREMENT,
    name VARCHAR(50),
    teacher_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(id)
);

-- Masukkan data ke tabel kelas jika belum ada
INSERT INTO classes (name, teacher_id) 
SELECT 'Kelas 10A', 1
WHERE NOT EXISTS (SELECT 1 FROM classes WHERE name = 'Kelas 10A' AND teacher_id = 1);

INSERT INTO classes (name, teacher_id) 
SELECT 'Kelas 11B', 2
WHERE NOT EXISTS (SELECT 1 FROM classes WHERE name = 'Kelas 11B' AND teacher_id = 2);

INSERT INTO classes (name, teacher_id) 
SELECT 'Kelas 12C', 3
WHERE NOT EXISTS (SELECT 1 FROM classes WHERE name = 'Kelas 12C' AND teacher_id = 3);

-- Buat tabel siswa jika belum ada
CREATE TABLE IF NOT EXISTS students (
    id INT AUTO_INCREMENT,
    name VARCHAR(100),
    age INT,
    class_id INT,
    PRIMARY KEY(id),
    FOREIGN KEY (class_id) REFERENCES classes(id)
);

-- Masukkan data ke tabel siswa jika belum ada
INSERT INTO students (name, age, class_id) 
SELECT 'Budi', 16, 1
WHERE NOT EXISTS (SELECT 1 FROM students WHERE name = 'Budi' AND age = 16 AND class_id = 1);

INSERT INTO students (name, age, class_id) 
SELECT 'Ani', 17, 2
WHERE NOT EXISTS (SELECT 1 FROM students WHERE name = 'Ani' AND age = 17 AND class_id = 2);

INSERT INTO students (name, age, class_id) 
SELECT 'Candra', 18, 3
WHERE NOT EXISTS (SELECT 1 FROM students WHERE name = 'Candra' AND age = 18 AND class_id = 3);


-- #1 Tampilkan daftar siswa beserta kelas dan guru yang mengajar kelas tersebut
-- Query ini menampilkan nama siswa, nama kelas, dan nama guru yang mengajar kelas tersebut.
SELECT s.name AS nama_siswa, c.name AS nama_kelas, t.name AS nama_guru
FROM students s
JOIN classes c ON s.class_id = c.id
JOIN teachers t ON c.teacher_id = t.id;


--#2 Tampilkan daftar kelas yang diajar oleh guru yang sama:
-- Query ini menampilkan nama guru dan daftar kelas yang diajar oleh guru tersebut.
-- Hanya menampilkan guru yang mengajar lebih dari satu kelas.
SELECT t.name AS nama_guru, GROUP_CONCAT(c.name ORDER BY c.name) AS daftar_kelas
FROM teachers t
JOIN classes c ON t.id = c.teacher_id
GROUP BY t.id
HAVING COUNT(c.id) > 1;

-- #3 Buat query view untuk siswa, kelas, dan guru yang mengajar
-- Query ini membuat view bernama student_class_teacher yang berisi data siswa, kelas, dan guru yang mengajar.
-- View ini memudahkan untuk mengakses data siswa, kelas, dan guru secara bersamaan.
CREATE VIEW student_class_teacher AS
SELECT s.name AS nama_siswa, c.name AS nama_kelas, t.name AS nama_guru
FROM students s
JOIN classes c ON s.class_id = c.id
JOIN teachers t ON c.teacher_id = t.id;

SELECT * FROM student_class_teacher;


-- #4 Buat query yang sama (nomor 1) tapi menggunakan stored procedure
-- Query ini membuat stored procedure bernama GetStudentClassTeacher yang melakukan hal yang sama dengan query nomor 1.
-- Stored procedure ini memudahkan untuk menjalankan query yang sama berulang kali tanpa harus menulis ulang query tersebut.
DELIMITER //
CREATE PROCEDURE GetStudentClassTeacher()
BEGIN
    SELECT s.name AS nama_siswa, c.name AS nama_kelas, t.name AS nama_guru
    FROM students s
    JOIN classes c ON s.class_id = c.id
    JOIN teachers t ON c.teacher_id = t.id;
END //
DELIMITER ;

CALL GetStudentClassTeacher();


-- #5 Buat query input, yang akan memberikan warning error jika ada data yang sama pernah masuk (contoh untuk tabel siswa)
-- Query ini membuat stored procedure bernama InsertStudent yang menerima nama siswa, umur, dan id kelas sebagai input.
-- Stored procedure ini akan memeriksa apakah data siswa sudah ada di database.
-- Jika data sudah ada, maka akan muncul pesan error.
-- Jika data belum ada, maka data siswa akan dimasukkan ke database.
DELIMITER //
CREATE PROCEDURE InsertStudent(IN student_name VARCHAR(100), IN student_age INT, IN class_id INT)
BEGIN
    DECLARE duplicate_count INT;

    SELECT COUNT(*) INTO duplicate_count
    FROM students
    WHERE name = student_name AND age = student_age AND class_id = class_id;

    IF duplicate_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Data siswa sudah ada';
    ELSE
        INSERT INTO students (name, age, class_id) VALUES (student_name, student_age, class_id);
    END IF;
END //
DELIMITER ;

CALL InsertStudent('Doni', 16, 1);  -- Jika berhasil, data akan dimasukkan
CALL InsertStudent('Budi', 16, 1); -- Akan memunculkan error karena Budi sudah ada di Kelas 10A
