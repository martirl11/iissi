SELECT COUNT(*) FROM Students;


/*requisito de informacion alimno interno*/

CREATE TABLE AlumnoInterno(
	alumnointId INT NOT NULL AUTO_INCREMENT,
	departmentId INT NOT NULL,
	studentId INT NOT NULL,
	academicYear INT NOT NULL, 
	months INT,
	PRIMARY KEY (alumnointId),
	FOREIGN KEY (departmentId) REFERENCES  departments (departmentId),
	FOREIGN KEY (studentId) REFERENCES  students (studentId),
	CONSTRAINT mothsmax CHECK (months>=3 AND months<=9)
);

CREATE OR REPLACE PROCEDURE 
	pInsertInterns(studentId INT , departmentId INT, academicYear INT , months INT)
BEGIN 
	INSERT INTO AlumnoInterno (departmentId, studentId, academicYear, months) VALUES (departmentId, studentId, academicYear, months);
END 

CALL pInsertInterns(1, 1, 2019, 3);
CALL pInsertInterns(1, 1, 2020, 6);
CALL pInsertInterns(2, 1, 2019, null);

DELIMITER //
CREATE OR REPLACE TRIGGER tCorrectDuration
	BEFORE UPDATE  ON alumnoInterno
	FOR EACH ROW
	BEGIN
		IF (new.months >9 ) THEN
			SET new.months=8;
			SIGNAL SQLSTATE '45000' SET message_text =
			'al ser los meses mayores que 9 se cambia a 8';
		END IF;
	END//
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE pUpdateInterns(s INT, d INT)
BEGIN 
	UPDATE alumnoInterno set months=d WHERE studentId=s;
END//
DELIMITER ;
CALL pUpdateInterns(1,13);

DELIMITER //
CREATE OR REPLACE PROCEDURE pDeleteInterns(s INT)
BEGIN 
	DELETE FROM  alumnoInterno WHERE studentId=s;
END//
DELIMITER ;
CALL pDeleteInterns(2);


SELECT firstName, groups.name, teachingloads.credits 
	FROM groups, professors, teachingloads WHERE 
	professors.professorId=teachingloads.professorId AND groups.groupId=teachingloads.groupId;
	
	
SELECT AVG(VALUE) FROM Grades	WHERE groupId=2;


SELECT studentId, MAX(VALUE) FROM grades GROUP BY studentId ORDER BY MAX(VALUE) DESC ; 



SELECT firstname, surname, teachingloads.groupId FROM professors, teachingloads, groups WHERE professors.professorId=teachingloads.professorId AND teachingloads.groupId=groups.groupId ORDER BY COUNT(teachingloads.groupId) DESC; 

SELECT sum(teachingloads.groupId) FROM teachingloads, groups WHERE groups.groupId=teachingloads.groupId;