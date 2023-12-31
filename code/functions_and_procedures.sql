--Повернення інформації про волонтера за його прізвищем--
CREATE OR REPLACE FUNCTION get_volonteer_info_by_surname(IN volonteer_surname VARCHAR(50))
RETURNS TABLE(
	id_volonteer INT,
	surname VARCHAR(50),
	name_organization VARCHAR(255),
	phone_number VARCHAR(10),
	email VARCHAR(255)	
)
AS $$
BEGIN
	RETURN QUERY SELECT v.id_volonteer, v.surname, o.name_organization, v.phone_number, v.email
	FROM volonteer v
	INNER JOIN organization o ON v.id_organization=o.id_organization
	WHERE volonteer_surname=v.surname;
END;
$$ LANGUAGE plpgsql;

SELECT*FROM get_volonteer_info_by_surname('Young');


--Повернення тренінгів, які провів певний координатор--
CREATE OR REPLACE FUNCTION get_info_about_training_or_project(IN coordinator_surname VARCHAR(50))
RETURNS TABLE (
    coordinator VARCHAR(50),
    training_or_project VARCHAR(100), 
	 type_info VARCHAR(20),
    start_date DATE,
    end_date DATE   
)
AS $$
BEGIN
    RETURN QUERY
    (SELECT c.surname, t.name,  CAST('training' AS VARCHAR(20)) AS type_info, t.start_date, t.end_date
    FROM coordinator c
    INNER JOIN training t ON t.id_coordinator = c.id_coordinator
    WHERE c.surname = coordinator_surname)
    
    UNION 
    
    (SELECT c.surname, p.project_name, CAST('project' AS VARCHAR(20)) AS type_info, p.start_date, p.end_date
    FROM coordinator c
    INNER JOIN project p ON p.id_coordinator = c.id_coordinator
    WHERE c.surname = coordinator_surname);
END;
$$ LANGUAGE plpgsql;
												
SELECT*FROM get_info_about_training_or_project('Miller');

--Функція для оновлення статусу завдання--
SELECT *FROM task WHERE id_task=1;

CREATE OR REPLACE FUNCTION update_task_status(task_id INT, new_status VARCHAR(50))
RETURNS VOID 
AS $$
BEGIN
	UPDATE task
	SET status=new_status	
	WHERE id_task=task_id;
END;
$$ LANGUAGE plpgsql;

SELECT update_task_status(1, 'Completed');


--Виведення проектів які ще не завершені--
CREATE OR REPLACE FUNCTION get_incomplete_tasks()
RETURNS TABLE (
    task_id INT,    
    name VARCHAR(100),
    status VARCHAR(50),
    notes TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT id_task , t.name, t.status, t.notes
    FROM task t
    WHERE t.status <> 'Completed';
END;
$$ LANGUAGE plpgsql;

SELECT * FROM get_incomplete_tasks();


--Виведення повідомлення ким є вказана людина: координатором, волонтером чи такого прізвища нема в базі--
CREATE OR REPLACE PROCEDURE check_person(person_surname VARCHAR(50))
AS $$
DECLARE
	is_volonteer BOOLEAN;
	is_coordinator BOOLEAN;
BEGIN
	SELECT EXISTS(SELECT 1 FROM volonteer WHERE surname = person_surname) INTO is_volonteer;	
	SELECT EXISTS(SELECT 1 FROM coordinator WHERE surname = person_surname) INTO is_coordinator;
	
	IF is_volonteer THEN
		RAISE NOTICE '% is volonteer', person_surname;
	ELSIF is_coordinator THEN
		RAISE NOTICE '% is coordinator', person_surname;
	ELSE 
		RAISE NOTICE 'This person is not found';
	END IF;
END;
$$ LANGUAGE plpgsql;

CALL check_person('Miller');

--Виведення назв організацій та сум фінансування для певного типу фінансування--
CREATE OR REPLACE PROCEDURE get_organizations_by_funding(IN funding_type VARCHAR(100))
AS $$
DECLARE
    row  RECORD;
BEGIN
	CREATE TEMPORARY TABLE temp_table AS
	SELECT DISTINCT org.name_organization, r.amount
	FROM organization org
	INNER JOIN resource r ON org.id_organization=r.id_organization
	WHERE r.type_funding=funding_type;
	
	FOR row IN SELECT*FROM temp_table LOOP
	  RAISE NOTICE 'Organization: %s %	       Amount: % %', row.name_organization, E'\n', row.amount, E'\n';
	END LOOP;	
	
	DROP TABLE IF EXISTS temp_table; 
END $$ LANGUAGE plpgsql;

CALL get_organizations_by_funding('Donation');

-- Виведення інформації про волонтерів до тих пір, поки не закінчаться рядки у таблиці--
	CREATE OR REPLACE PROCEDURE display_volonteers()
	AS $$
	DECLARE
		row_record volonteer%ROWTYPE;
		done BOOLEAN := FALSE;
		counter INT := 0;
	BEGIN
		WHILE NOT done LOOP
			SELECT * INTO row_record FROM volonteer OFFSET counter LIMIT 1;

			IF FOUND THEN
			RAISE NOTICE '% Volonteer ID: % % Surname: % % Email: % % Phone number: % %', 
	   E'\n', row_record.id_volonteer, E'\n', row_record.surname, E'\n', row_record.email, E'\n', row_record.phone_number,  E'\n';
			ELSE
				done := TRUE; 
			END IF;

			counter := counter + 1;
		END LOOP;
	END $$ LANGUAGE plpgsql;

CALL display_volonteers();

--Знайти всі тренінги, які навчають певній навичці--
CREATE OR REPLACE FUNCTION find_trainings_with_skill(IN skill_name VARCHAR(100))
RETURNS TABLE (   
    training_name VARCHAR(100),
    type_training VARCHAR(100),
    start_date DATE,
    end_date DATE,
	skill VARCHAR(100)
)
AS $$
BEGIN
    RETURN QUERY
    SELECT  t.name, t.type_training, t.start_date, t.end_date, s.name
    FROM training t
    INNER JOIN training_skill ts ON t.id_training = ts.id_training
    INNER JOIN skill s ON ts.id_skill = s.id_skill
    WHERE s.name = skill_name;
END $$ LANGUAGE plpgsql;

SELECT * FROM find_trainings_with_skill('Volunteer Coordination');

--Знайти тренінг з середнім рейтингом 5--
CREATE OR REPLACE PROCEDURE find_training_with_avg_rating_5()
AS $$
DECLARE
    training_row RECORD;
BEGIN
    FOR training_row IN
        SELECT f.id_training, t.name AS training_name, AVG(f.rating) AS average_rating
        FROM feedback f
        INNER JOIN training t ON f.id_training = t.id_training
        GROUP BY f.id_training, t.name
        HAVING AVG(f.rating) = 5
    LOOP
        RAISE NOTICE '% ID: % % Training Name: % % Average Rating: % %', E'\n',  training_row.id_training, E'\n',  training_row.training_name,E'\n',  training_row.average_rating, E'\n';
    END LOOP;
END $$ LANGUAGE plpgsql;

CALL find_training_with_avg_rating_5();

--Додавання до таблиці координатора--
CREATE OR REPLACE PROCEDURE add_coordinator(  
	IN org_id INT,
    IN surname VARCHAR(50),
    IN phone NUMERIC(10),
    IN email VARCHAR(255)
)
AS $$
BEGIN
    INSERT INTO coordinator (id_organization, surname, phone_number, email)
    VALUES (org_id, surname, phone, email);
END $$ LANGUAGE plpgsql;

CALL add_coordinator(5, 'Thomson', 123456788, 'thomson@gmail.com');

