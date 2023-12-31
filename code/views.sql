--Виведення кількості завдань до кожного проекта і їхнього статусу--
CREATE VIEW project_task_summary AS
SELECT
	p.project_name,
	COUNT(task.id_task) AS total_task,
	SUM(CASE WHEN task.status='Completed' THEN 1 ELSE 0 END) AS completed_tasks,
	SUM(CASE WHEN task.status='In progress' THEN 1 ELSE 0 END) AS in_progress_tasks,
	SUM(CASE WHEN task.status='Pending' THEN 1 ELSE 0 END) AS pending_tasks
FROM project p
LEFT JOIN task ON task.id_project=p.id_project
GROUP BY p.project_name;

SELECT*FROM project_task_summary ;

DROP VIEW IF EXISTS project_task_summary;

--Виведення волонтерів, проектів в яких вони беруть участь, координаторів цих проектів
--тренінгів і відповідно координаторів тренінгів
CREATE VIEW volonteer_project_training_coordinator AS
SELECT
    v.surname AS volunteer,
    STRING_AGG(DISTINCT p.project_name, E'\n') AS projects,
    STRING_AGG(DISTINCT pc.surname, E'\n') AS project_coordinators,
    STRING_AGG(DISTINCT t.name, E'\n') AS trainings,
    STRING_AGG(DISTINCT tc.surname, E'\n') AS training_coordinators
FROM volonteer v
LEFT JOIN report r ON r.id_volonteer = v.id_volonteer
LEFT JOIN task ON r.id_task = task.id_task
LEFT JOIN project p ON task.id_project = p.id_project
LEFT JOIN coordinator pc ON p.id_coordinator = pc.id_coordinator
LEFT JOIN feedback f ON v.id_volonteer = f.id_volonteer
LEFT JOIN training t ON f.id_training = t.id_training
LEFT JOIN coordinator tc ON t.id_coordinator = tc.id_coordinator
GROUP BY v.surname
HAVING 
    NOT (MAX(p.project_name) IS NULL
    AND MAX(pc.surname) IS NULL
    AND MAX(t.name) IS NULL
    AND MAX(tc.surname) IS NULL);

SELECT*FROM volonteer_project_training_coordinator;

DROP VIEW IF EXISTS volonteer_project_training_coordinator;

--Виведення організацій, кількість фінансових ресурсів і загальної суми ресурсів, зібраної для певної організації
CREATE VIEW organization_resource_summary AS
SELECT 
    o.name_organization AS organization_name,
    COUNT(r.id_resource) AS total_resources,
    COALESCE(SUM(r.amount), 0) AS total_amount
FROM organization o
LEFT JOIN resource r ON o.id_organization = r.id_organization
GROUP BY o.name_organization;

SELECT*FROM organization_resource_summary;

DROP VIEW IF EXISTS organization_resource_summary;