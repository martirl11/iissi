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
INSERT INTO Grades (gradeId, value, gradeCall, withHonours, studentId, groupId) VALUES	(11, 9.5, 1, 1, 1, 3);
INSERT INTO Grades (gradeId, value, gradeCall, withHonours, studentId, groupId) VALUES	(12, 8.5, 2, 1, 1, 3);	
SELECT* FROM grades;

DELIMITER//
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
DELIMITER;
NSERT INTO Grades (gradeId, value, gradeCall, withHonours, studentId, groupId) VALUES	(13, 6, 1, 0, 1, 2);	

DELIMITER//
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
DELIMITER;
-- Para probar que el trigger salta (intentamos actualizar una nota de un 4.50 a un 10.0)
UPDATE Grades SET value = 10.0 WHERE gradeId = 1;