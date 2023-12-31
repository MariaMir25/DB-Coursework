--1)Виведення організацій і проектів які ці організації проводять

SELECT pr.project_name, org.name_organization, pr.start_date, pr.end_date
FROM organization org
INNER JOIN coordinator c  ON org.id_organization=c.id_organization
INNER JOIN project pr ON pr.id_coordinator=c.id_coordinator
ORDER BY org.name_organization;


--2)Виведення волонтерів і навички, які ці волонтери отримали, якщо пройшли тренінги--

SELECT v.surname AS volonteer_surname, 
    STRING_AGG(DISTINCT skill.name, ', 	') AS all_skills
FROM volonteer v
LEFT JOIN (
    SELECT tv.id_volonteer, s.name
    FROM training_volonteer tv
    LEFT JOIN training t ON tv.id_training = t.id_training
    LEFT JOIN training_skill ts ON t.id_training = ts.id_training
    LEFT JOIN skill s ON ts.id_skill = s.id_skill
) AS skill ON skill.id_volonteer = v.id_volonteer
GROUP BY v.id_volonteer, v.surname
ORDER BY volonteer_surname;

--3)Знайти всі проекти, в яких бере участь волонтер з ідентифікатором 6--
SELECT  project_name, start_date, end_date
FROM project
WHERE id_project IN (
    SELECT id_project
	FROM task
    WHERE id_task IN(
		SELECT id_task
		FROM report 
		WHERE id_volonteer IN(6)
	) 
);


-- 4)Вибрати ресурси, чия сума більша за це середнє значення--

SELECT *, ROUND((SELECT AVG(amount) FROM resource), 2) AS average_amount
FROM resource
WHERE amount > (SELECT AVG(amount) FROM resource);

-- 5)Сортування результатів в порядку спадання за кількістю тренувань, в яких брав участь кожен волонтер--
SELECT volonteer.id_volonteer, volonteer.surname, COALESCE(vol_count.count, 0) AS training_count
FROM volonteer
LEFT JOIN (
    SELECT id_volonteer, COUNT(id_training) AS count
    FROM training_volonteer
    GROUP BY id_volonteer
) AS vol_count ON volonteer.id_volonteer = vol_count.id_volonteer
ORDER BY training_count DESC;

-- 6)Виведення проектів і волонтерів які беруть участь в цьому проекті--
SELECT 
    p.project_name,
    STRING_AGG(DISTINCT v.surname, ',	') AS volunteer_names
FROM 
    volonteer v,
    project p,
    task t,
    report r
WHERE 
    v.id_volonteer = r.id_volonteer 
    AND t.id_task = r.id_task 
    AND t.id_project = p.id_project
GROUP BY 
    p.project_name;
	
--7) Виведення координаторів і волонтерів які пов'язані з певними проектом

SELECT role, surname, STRING_AGG(project_name, '_______') AS projects
FROM (
    SELECT 'Coordinator' AS role, c.surname, p.project_name
    FROM coordinator c
    INNER JOIN project p ON p.id_coordinator = c.id_coordinator

    UNION ALL

    SELECT 'Volonteer' AS role, v.surname, p.project_name
    FROM volonteer v
    INNER JOIN report r 
		ON v.id_volonteer = r.id_volonteer
    INNER JOIN task t 
		ON t.id_task = r.id_task
    INNER JOIN project p 
		ON p.id_project = t.id_project
) AS combined_data
GROUP BY role, surname;

--8) Виведення назви навчань та відповідні навички з умовою, 
--що назва навчання починається з літери "C"
SELECT t.name AS training, s.name AS skill
FROM training t
JOIN training_skill ts 
	ON ts.id_training = t.id_training
JOIN skill s
	ON s.id_skill = ts.id_skill
WHERE t.name LIKE 'C%'
ORDER BY t.name;

--9) Виведення організації і  суми яку ця організація отримала 
SELECT o.name_organization AS organization, SUM(r.amount) AS total_amount_received
FROM organization o
INNER JOIN resource r 
	ON o.id_organization = r.id_organization
GROUP BY o.name_organization
ORDER BY o.name_organization;

--10) Виведення завдання які треба виконати і волонтера якого призначили на це завдання  
SELECT t.name AS task, v.surname AS volonteer, t.status
FROM task AS t
INNER JOIN report AS r ON r.id_task = t.id_task
INNER JOIN volonteer AS v ON r.id_volonteer = v.id_volonteer
WHERE t.status <> 'Completed'
ORDER BY t.name;

--11)Знайти організації, які не мають жодного фінансового ресурсу
SELECT *FROM organization
WHERE id_organization NOT IN(
	SELECT id_organization FROM resource	
);

--12) Виведення назви організації, кількість ресурсів цієї організації, загальна 
--сума ресурсів, середнє значення ресурсів, найновіша й найстарша дата отримання ресурсу організацією

SELECT o.id_organization, 
	o.name_organization, 
	COUNT(r.id_resource) AS resource_count,
    SUM(r.amount) AS total_amount, 
	 ROUND(AVG(r.amount), 2) AS avg_amount,
    MIN(r.receiving_date) AS earliest_date, 
	MAX(r.receiving_date) AS latest_date
FROM organization o
LEFT JOIN resource r ON o.id_organization = r.id_organization
GROUP BY o.id_organization, o.name_organization
ORDER BY o.id_organization;

--13)Інформація про завдання номер 7 і про волонтерів які це завдання виконують
SELECT t.id_task,r.date AS report_date, v.surname AS volunteer_surname,  v.email AS volunteer_email,
        t.name AS task_name, t.status AS task_status, t.notes AS task_notes,
        r.results
FROM report r
INNER JOIN volonteer v ON r.id_volonteer = v.id_volonteer
INNER JOIN task t ON r.id_task = t.id_task
WHERE t.id_task IN (2, 3, 7);

--14)Виведення інформації про волонтерів і організації до якої вони належать
SELECT  v.id_volonteer, v.surname AS volonteer_surname, v.phone_number AS volonteer_phone, v.email AS volonteer_email,
	o.name_organization,  o.email, o.head_of_organization       
FROM organization o
RIGHT JOIN volonteer v 
	ON o.id_organization = v.id_organization;
	
--15) Щоб виконати завдання треба мати навичку Team Building або
--Healthcare Support або Volunteer Coordination. 
--Знайти волонтерів які відповідають цим вимогам
SELECT v.surname AS volonteer, v.phone_number, v.email 
FROM volonteer v
WHERE v.id_volonteer IN (
    SELECT tv.id_volonteer 
    FROM training_volonteer tv
    WHERE tv.id_training IN (
        SELECT ts.id_training
        FROM training_skill ts
        WHERE ts.id_skill IN (
            SELECT s.id_skill
            FROM skill s
            WHERE s.name IN ('Team Building', 'Healthcare Support', 'Volunteer Coordination')
        )
    )
);

--16) Запит для виведення волонтера, відгука який він залишив про тренінг і координатора який цей тренінг проводив 
SELECT v.surname AS volonteer_surname,
       t.name AS training_name,
       f.recommendations,
       f.rating,
       c.surname AS coordinator_surname
FROM feedback f
INNER JOIN training t ON f.id_training = t.id_training
INNER JOIN volonteer v ON f.id_volonteer = v.id_volonteer
INNER JOIN coordinator c ON t.id_coordinator = c.id_coordinator;

--17) Виведення волонтерів і проектів та тренінгів в яких волонтер брав участь
SELECT DISTINCT v.surname AS volunteer_surname, p.project_name AS project_name, t.name AS training_name
FROM volonteer v
LEFT JOIN report r ON v.id_volonteer = r.id_volonteer
LEFT JOIN task tk ON r.id_task = tk.id_task
LEFT JOIN project p ON tk.id_project = p.id_project
LEFT JOIN training_volonteer tv ON tv.id_volonteer=v.id_volonteer
LEFT JOIN training t ON tv.id_training = t.id_training;

--18) Отримати список тренінгів та кількість волонтерів з кожної організації, які брали участь у цих тренінгах
SELECT t.name AS training_name, 
       o.name_organization,  
       COUNT(DISTINCT v.id_volonteer) AS total_volunteers 
FROM organization o 
LEFT JOIN coordinator c ON o.id_organization = c.id_organization 
LEFT JOIN training t ON c.id_coordinator = t.id_coordinator 
LEFT JOIN training_volonteer tv ON t.id_training = tv.id_training 
LEFT JOIN volonteer v ON tv.id_volonteer = v.id_volonteer 
WHERE t.id_training IS NOT NULL 
GROUP BY o.name_organization, t.name 
ORDER BY total_volunteers;


--19)Запит вибирає лише ті тренінги, які надають більше ніж 1 навичку
SELECT t.name, COUNT(ts.id_skill) AS skill_count
FROM training t
LEFT JOIN training_skill ts ON t.id_training = ts.id_training
GROUP BY t.id_training
HAVING COUNT(ts.id_skill) > 1;

--20)Виведення середньої оцінки за тренінг

SELECT 
   t.id_training,
    t.name AS training_name, 
	SUM(f.rating) / COUNT(f.id_feedback) AS average_rating   
FROM 
    training t
LEFT JOIN 
    feedback f ON t.id_training = f.id_training
GROUP BY 
    t.id_training, t.name
HAVING 
    COUNT(f.id_feedback) > 0
ORDER BY 
    t.id_training;	
	
--21)
SELECT t.name AS task_name, v.surname AS volunteer_name, t.status
FROM task t
JOIN project p ON t.id_project = p.id_project
JOIN coordinator c ON p.id_coordinator = c.id_coordinator
JOIN volonteer v ON c.id_organization = v.id_organization
WHERE t.status = 'Pending';

--22)
SELECT o.name_organization, 
       COUNT(DISTINCT v.id_volonteer) AS volunteer_count,
       COUNT(DISTINCT c.id_coordinator) AS coordinator_count
FROM organization o
LEFT JOIN volonteer v ON o.id_organization = v.id_organization
LEFT JOIN coordinator c ON o.id_organization = c.id_organization
GROUP BY o.name_organization;