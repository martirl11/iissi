DELIMITER //
CREATE OR REPLACE FUNCTION avgGrade (studentId INT) RETURNS DOUBLE
	BEGIN
 		RETURN (	SELECT AVG(value) 
		 			FROM Grades 
					WHERE GRADES.studentId=studentId);
	END //
DELIMITER ;

SELECT firstName, surname, avgGrade(studentId) FROM Students;

