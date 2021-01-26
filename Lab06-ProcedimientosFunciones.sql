DELIMITER //
CREATE OR REPLACE PROCEDURE procDeleteGrades(studentDni CHAR(9))
	BEGIN
 		DECLARE id INT;
 		SET id = (SELECT studentId FROM Students WHERE dni=studentDni);
  		DELETE FROM Grades WHERE studentId=id;
	END //
DELIMITER ;

SELECT* FROM grades;
--ejecutamos procedimientos
CALL procDeleteGrades('12345678A');

--procedimeintos para borrar los dats de todas las tablas
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

CALL procDeleteData();
SELECT * FROM students;

DELIMITER //
CREATE OR REPLACE FUNCTION avgGrade (studentId INT) RETURNS DOUBLE
	BEGIN
		DECLARE avgStudentGrade DOUBLE; 
 		SET avgStudentGrade=(SELECT AVG(value) 
		 			FROM Grades 
					WHERE GRADES.studentId=studentId);
		 RETURN avgStudentGrade;
	END //
DELIMITER ;

SELECT  avgGrade(1) ;
SELECT firstName, surname, avgGrade(studentId) FROM Students;

