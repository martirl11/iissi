-- RF-006
DELIMITER //
CREATE OR REPLACE PROCEDURE procDeleteGrades(studentDni CHAR(9))
	BEGIN
 		DECLARE id INT;
 		SET id = (SELECT studentId FROM Students WHERE dni=studentDni);
  		DELETE FROM Grades WHERE studentId=id;
	END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE procDeleteData()
	BEGIN
		DELETE FROM Grades;
		DELETE FROM GroupsStudents;
		DELETE FROM Students;
		DELETE FROM Groups;
		DELETE FROM Subjects;
		DELETE FROM Degrees;
	END //
DELIMITER ;

-- CALL procDeleteGrades('12345678A');
CALL procDeleteData();

DELIMITER //
CREATE OR REPLACE FUNCTION avgGrade(studentId INT) RETURNS DOUBLE
	BEGIN
		DECLARE avgStudentGrade DOUBLE;
		SET avgStudentGrade = (SELECT AVG(value) FROM Grades
									  WHERE Grades.studentId = studentId);
		RETURN avgStudentGrade;
	END //
DELIMITER ;
