--Видалення даних з таблиці
ALTER SEQUENCE organization_id_organization_seq RESTART WITH 1;
delete from organization;

ALTER SEQUENCE coordinator_id_coordinator_seq RESTART WITH 1;
delete from coordinator;

ALTER SEQUENCE volonteer_id_volonteer_seq RESTART WITH 1;
delete from volonteer;

ALTER SEQUENCE resource_id_resource_seq RESTART WITH 1;
delete from resource;

ALTER SEQUENCE training_id_training_seq RESTART WITH 1;
delete from training;

ALTER SEQUENCE project_id_project_seq RESTART WITH 1;
delete from project;

ALTER SEQUENCE task_id_task_seq RESTART WITH 1;
delete from task;

ALTER SEQUENCE feedback_id_feedback_seq RESTART WITH 1;
delete from feedback;

ALTER SEQUENCE report_id_report_seq RESTART WITH 1;
delete from report;

ALTER SEQUENCE skill_id_skill_seq RESTART WITH 1;
delete from skill;

delete from training_skill;

delete from training_volonteer;

--Імпортування даних
COPY resource(id_organization, amount, type_funding, receiving_date)FROM 'D:\KPI_DataBase\kursova\resource.csv'  DELIMITER ';' CSV HEADER;
COPY organization(name_organization, field_activity, address, phone_number, email, head_of_organization) FROM 'D:\KPI_DataBase\kursova\organization.csv'  DELIMITER ';' CSV HEADER;
COPY coordinator(surname, phone_number, email, id_organization) FROM 'D:\KPI_DataBase\kursova\coordinator.csv'  DELIMITER ';' CSV HEADER;
COPY volonteer(surname,id_organization,  phone_number, email, experience)FROM 'D:\KPI_DataBase\kursova\volonteer.csv'  DELIMITER ';' CSV HEADER;
COPY training( id_coordinator, name, type_training, start_date, end_date, budget)FROM 'D:\KPI_DataBase\kursova\training.csv'  DELIMITER ';' CSV HEADER;
COPY project( id_coordinator, project_name, start_date, end_date, goal, budget)FROM 'D:\KPI_DataBase\kursova\project.csv'  DELIMITER ';' CSV HEADER;
COPY task(id_project, name, status, notes)FROM 'D:\KPI_DataBase\kursova\task.csv'  DELIMITER ';' CSV HEADER;
COPY feedback(id_volonteer, id_training, recommendations, rating)FROM 'D:\KPI_DataBase\kursova\certificate.csv'  DELIMITER ';' CSV HEADER;
COPY report(id_volonteer, id_task, date, results)FROM 'D:\KPI_DataBase\kursova\report.csv'  DELIMITER ';' CSV HEADER;
COPY skill(name, description)FROM 'D:\KPI_DataBase\kursova\skill.csv'  DELIMITER ';' CSV HEADER;
COPY volonteer_skill(id_volonteer, id_skill)FROM 'D:\KPI_DataBase\kursova\volonteer_skill.csv'  DELIMITER ';' CSV HEADER;
COPY training_volonteer(id_volonteer, id_training)FROM 'D:\KPI_DataBase\kursova\training_volonteer.csv'  DELIMITER ';' CSV HEADER;
