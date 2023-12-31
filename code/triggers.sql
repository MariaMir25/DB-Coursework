--Тригер, при видаленні координатора, автоматично видаляє пов'язані записи з інших таблиць--
CREATE OR REPLACE FUNCTION delete_related_data()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM training WHERE id_coordinator = OLD.id_coordinator;
    DELETE FROM project WHERE id_coordinator = OLD.id_coordinator;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_related_data_trigger
AFTER DELETE ON coordinator
FOR EACH ROW
EXECUTE FUNCTION delete_related_data();

--Якщо дата початку пізніша або рівна даті закінчення, спрацьовує помилка, і вставка запису не відбувається--
CREATE OR REPLACE FUNCTION check_project_dates()
RETURNS TRIGGER AS $$
BEGIN
	IF NEW.start_date>=NEW.end_date THEN
		RAISE EXCEPTION 'Start date must be earlier than end date';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_project_dates_trigger
BEFORE INSERT ON project
FOR EACH ROW
EXECUTE FUNCTION check_project_dates();

--Перевірка, чи існує вже така електронна пошта в таблиці volonteer--
CREATE OR REPLACE FUNCTION check_volonteer_email()
RETURNS TRIGGER AS $$
BEGIN
	IF EXISTS(SELECT 1 FROM volonteer WHERE email=NEW.email)THEN
		RAISE EXCEPTION 'Email already exists in volonteer table';
	END IF;
	RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_volonteer_email_trigger
BEFORE INSERT ON volonteer
FOR EACH ROW
EXECUTE FUNCTION check_volonteer_email();

--Виведення середнього рейтингу після оновлення таблиці feedback--
CREATE OR REPLACE FUNCTION calculate_avg_rating()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating DECIMAL;
BEGIN
    SELECT AVG(rating) INTO avg_rating
    FROM feedback
    WHERE id_volonteer = NEW.id_volonteer;

    RAISE NOTICE 'Average rating after inserting: %', avg_rating;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER calculate_avg_rating_trigger
AFTER INSERT ON feedback
FOR EACH ROW EXECUTE FUNCTION calculate_avg_rating();

INSERT INTO feedback(id_volonteer, id_training, rating)
VALUES( 11,	9, 4);

--Виведення помилки при спробі вставити в рейтинг число більше 5 або менше 1--
CREATE OR REPLACE FUNCTION check_rating()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.rating < 1 OR NEW.rating > 5 THEN
        RAISE EXCEPTION 'Рейтинг повинен бути в межах від 1 до 5';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enforce_rating_check
BEFORE INSERT OR UPDATE ON feedback
FOR EACH ROW EXECUTE FUNCTION check_rating();

-- Тригер для перевірки бюджету тренінгу
CREATE OR REPLACE FUNCTION check_training_budget()
RETURNS TRIGGER AS $$
DECLARE
    org_budget DECIMAL(15, 2);
BEGIN
    
    SELECT SUM(amount) INTO org_budget FROM resource WHERE id_organization = NEW.id_coordinator;
    
    IF NEW.budget > org_budget THEN
        RAISE EXCEPTION 'Training budget exceeds organization budget';
    ELSE
        UPDATE resource SET amount = amount - NEW.budget WHERE id_organization = NEW.id_coordinator;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_training_budget_trigger
BEFORE INSERT ON training
FOR EACH ROW EXECUTE FUNCTION check_training_budget();


-- Тригер для перевірки бюджету проекту
CREATE OR REPLACE FUNCTION check_project_budget()
RETURNS TRIGGER AS $$
DECLARE
    org_budget DECIMAL(15, 2);
BEGIN
   
    SELECT SUM(amount) INTO org_budget FROM resource WHERE id_organization = NEW.id_coordinator;

    IF NEW.budget > org_budget THEN
        RAISE EXCEPTION 'Project budget exceeds organization budget';
    ELSE       
        UPDATE resource SET amount = amount - NEW.budget WHERE id_organization = NEW.id_coordinator;
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_project_budget_trigger
BEFORE INSERT ON project
FOR EACH ROW EXECUTE FUNCTION check_project_budget();
