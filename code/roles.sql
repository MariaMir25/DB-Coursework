--Створення ролей--
CREATE ROLE coordinator;
CREATE ROLE mentor;
CREATE ROLE volonteer;


--Координатор--
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE project TO coordinator;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE training TO coordinator;
GRANT SELECT (id_volonteer, id_task), UPDATE (id_volonteer, id_task), INSERT (id_volonteer, id_task) ON report TO coordinator;
GRANT SELECT ON feedback, volonteer TO  coordinator;
GRANT SELECT (date, results) ON report TO coordinator;

--Ментор--
GRANT SELECT ON volonteer, feedback, report TO mentor;
GRANT SELECT, UPDATE ON task TO mentor;

--Волонтер--
GRANT SELECT, UPDATE, INSERT, DELETE ON feedback TO volonteer;
GRANT SELECT (date, results), UPDATE (date, results), INSERT (date, results) ON report TO volonteer;
GRANT SELECT (id_volonteer, id_task) ON report TO volonteer;
GRANT SELECT ON project TO volonteer;
GRANT SELECT ON training TO volonteer;

--Створення користувачів--
CREATE USER coordinator_user WITH
PASSWORD 'pass1';
GRANT coordinator TO
coordinator_user;

CREATE USER mentor_user WITH
PASSWORD 'pass2';
GRANT mentor TO
mentor_user;


CREATE USER volonteer_user WITH
PASSWORD 'pass4';
GRANT volonteer TO
volonteer_user;


--Видалення користувачів і ролей--

REVOKE SELECT, INSERT, UPDATE, DELETE ON  project FROM coordinator;
REVOKE SELECT, INSERT, UPDATE, DELETE ON  training FROM coordinator;
REVOKE SELECT (id_volonteer, id_task), UPDATE (id_volonteer, id_task), INSERT (id_volonteer, id_task) ON report FROM coordinator;
REVOKE SELECT ON feedback,  volonteer FROM coordinator;
REVOKE SELECT (date, results) ON  report FROM coordinator;

DROP ROLE IF EXISTS coordinator;
DROP USER IF EXISTS coordinator_user;

----
REVOKE SELECT ON volonteer, feedback, report FROM mentor;
REVOKE SELECT, UPDATE ON task FROM mentor;

DROP ROLE IF EXISTS mentor;
DROP USER  IF EXISTS mentor_user;

----
REVOKE SELECT, UPDATE, INSERT, DELETE ON  feedback FROM volonteer;
REVOKE SELECT (date, results), UPDATE (date, results), INSERT (date, results) ON report FROM volonteer;
REVOKE SELECT (id_volonteer, id_task) ON  report FROM volonteer;
REVOKE SELECT ON  project FROM volonteer;
REVOKE SELECT ON  training FROM volonteer;

DROP ROLE IF EXISTS volonteer;
DROP USER IF EXISTS volonteer_user;

