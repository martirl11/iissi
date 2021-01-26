-- RN-006
DELIMITER //
CREATE OR REPLACE TRIGGER triggerWithHonours
	BEFORE INSERT ON Grades
	FOR EACH ROW
	BEGIN
		IF (new.withHonours = 1 AND new.value < 9.0) THEN
			SIGNAL SQLSTATE '45000' SET message_text = 
			'You cannot insert a grade with honours whose value is less than 9';
		END IF;
	END//
DELIMITER ;
	
CREATE OR REPLACE TRIGGER triggerGradeStudentGroup
	BEFORE INSERT ON Grades
	FOR EACH ROW
	BEGIN
		DECLARE isInGroup INT;
		SET isInGroup = (SELECT COUNT(*) 
							FROM GroupsStudents
							WHERE studentId = new.studentId AND groupId = new.groupId);
		IF(isInGroup < 1) THEN
			SIGNAL SQLSTATE '45000' SET message_text = 
			'A student cannot have grades for groups in which they are not registered';
		END IF;
	END//

CREATE OR REPLACE TRIGGER triggerGradesChangeDifference
	BEFORE UPDATE ON Grades
	FOR EACH ROW
	BEGIN
		DECLARE difference DECIMAL(4,2);
		DECLARE student ROW TYPE OF Students;
		SET difference = new.value - old.value;

		IF(difference > 4) THEN
			SELECT * INTO student FROM Students WHERE studentId = new.studentId;
			SET @error_message = CONCAT('You cannot add ', difference, 
					' points to a grade for the student',
					student.firstName, ' ', student.surname);
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = @error_message;
		END IF;
	END//

CREATE OR REPLACE TRIGGER triggerGradesChangeDifference
	BEFORE UPDATE ON Grades
	FOR EACH ROW
	BEGIN
		DECLARE difference DECIMAL(4,2);
		SET difference = new.value - old.value;
		IF(difference > 4) THEN
			SET new.value = old.value + 4;
		END IF;
	END//
	
CREATE OR REPLACE TRIGGER triggerUniqueGradesSubject
	BEFORE INSERT ON Grades
	FOR EACH ROW
	BEGIN
		DECLARE subject INT; -- La asignatura en la que se inserta la nota
		DECLARE groupYear INT; -- El año al que corresponde
		DECLARE subjectGrades INT; -- Conteo de notas de la misma asignatura/alumno/año/convocatoria
		SELECT subjectId, year INTO subject, groupYear FROM Groups WHERE groupId = new.groupId;
		SET subjectGrades = (SELECT COUNT(*) 
						FROM Grades, Groups
						WHERE (Grades.studentId = new.studentId AND -- Mismo estudiante
								 Grades.gradeCall = new.gradeCall AND -- Misma convocatoria
								 Grades.groupId = Groups.groupId AND 
								 Groups.year = groupYear AND -- Mismo año
								 Groups.subjectId = subject)); -- Misma asignatura
		IF(subjectrades > 0) THEN
			SIGNAL SQLSTATE '45000' SET message_text = 
			'Un alumno no puede tener varias notas asociadas a la misma 
			asignatura en la misma convocatoria, el mismo año';
		END IF;
	END//

-- Deifnimos una vista que contenga información sobre los alumnos sus asinaturas
CREATE OR REPLACE VIEW ViewStudentSubjects AS
			SELECT GroupsStudents.studentId, Subjects.subjectId, year
			FROM Groups
			INNER JOIN Subjects ON (Groups.subjectId=Subjects.subjectId)
			INNER JOIN GroupsStudents ON (Groups.groupId=GroupsStudents.groupId)//
			
CREATE OR REPLACE TRIGGER triggerMaximumCredits
	BEFORE INSERT ON GroupsStudents
	FOR EACH ROW
	BEGIN
		DECLARE subject INT;
		DECLARE groupYear INT;
		DECLARE alreadyBelongs BOOLEAN;
		DECLARE newCredits INT;
		DECLARE currentCredits INT;
		SELECT subjectId, year INTO subject, groupYear FROM Groups WHERE groupId = new.groupId;
		
		-- Vemos si la asignatura del nuevo grupo es una a la que ya pertenecía este año
		SET already_belongs = (SELECT COUNT(DISTINCT(subjectId)) 	
									  FROM ViewStudentSubjects 
									  WHERE (studentId = new.studentId AND
											  subjectId = subject AND
											  year = groupYear));
		-- Solo es necessario seguir comprobando si es una asignatura nueva
		IF(NOT alreadyBelongs) THEN
			-- Obtenemos los créditos de la asignatura nueva
			SET newCredits = (SELECT credits FROM Subjects WHERE subjectId = subject);
			-- Obtenemos los créditos de las asignaturas en las que estaba
			SET currentCredits = (SELECT SUM(credits) 
										  FROM Subjects 
										  WHERE Subjects.subjectId IN (
										  		SELECT Groups.subjectId 
												FROM Groups 
												INNER JOIN GroupsStudents ON (Groups.groupId=GroupsStudents.groupId)
												WHERE (studentId=new.studentId AND
														 year = groupYear)));
			IF((currentCredits + newCredits) > 90) THEN
				SIGNAL SQLSTATE '45000' SET message_text = 
				'Un alumno no puede tener asignaturas con más de 90 créditos un mismo año';
			END IF;
		END IF;
	END//
		
DELIMITER ;

-- INSERT INTO Grades VALUES (NULL, 8.5, 2, 1, 1, 10);

-- INSERT INTO Grades VALUES (NULL, 8.5, 2, 0, 1, 21);

-- UPDATE Grades SET VALUE = 5.00 WHERE gradeId = 1;
-- UPDATE Grades SET VALUE = 9.30 WHERE gradeId = 1;

-- INSERT INTO Grades VALUES (NULL, 6.5, 1, 0, 1, 3);

INSERT INTO GroupsStudents VALUES (NULL, 24, 1);