CREATE TABLE organization (
    id_organization SERIAL PRIMARY KEY,
    name_organization VARCHAR(255) NOT NULL,
    field_activity VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(10) NOT NULL CHECK (LENGTH(phone_number) = 10 AND phone_number REGEXP '^[0-9]+$'),
    email VARCHAR(255) UNIQUE NOT NULL,
    head_of_organization VARCHAR(100) NOT NULL
);

CREATE TABLE coordinator (
    id_coordinator SERIAL PRIMARY KEY,
    id_organization INT,
    surname VARCHAR(50) NOT NULL,
    phone_number VARCHAR(10) NOT NULL CHECK (LENGTH(phone_number) = 10 AND phone_number REGEXP '^[0-9]+$'),
    email VARCHAR(255) UNIQUE NOT NULL,
    CONSTRAINT fk_organization_coordinator FOREIGN KEY (id_organization) REFERENCES organization (id_organization)
);
CREATE TABLE resource (
    id_resource SERIAL PRIMARY KEY,
    id_organization INT,
    amount DECIMAL(15, 2) NOT NULL CHECK (amount >= 0),
    type_funding VARCHAR(100),
    receiving_date DATE NOT NULL,
    CONSTRAINT fk_organization_resource FOREIGN KEY (id_organization) REFERENCES organization (id_organization)
);
CREATE TABLE training (
    id_training SERIAL PRIMARY KEY,
    id_coordinator INT,
    name VARCHAR(100) NOT NULL,
    type_training VARCHAR(100),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
	budget DECIMAL(15, 2) NOT NULL CHECK (amount >= 0),
    CONSTRAINT fk_coordinator_training FOREIGN KEY (id_coordinator) REFERENCES coordinator (id_coordinator),
);	
CREATE TABLE project (
    id_project SERIAL PRIMARY KEY,
    id_coordinator INT,
    project_name VARCHAR(100) NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    goal VARCHAR(255),
	budget DECIMAL(15, 2) NOT NULL CHECK (amount >= 0),
    CONSTRAINT fk_coordinator_project FOREIGN KEY (id_coordinator) REFERENCES coordinator (id_coordinator),
);
CREATE TABLE volonteer (
    id_volonteer SERIAL PRIMARY KEY,
    id_organization INT,
    surname VARCHAR(50) NOT NULL,
    phone_number VARCHAR(10) NOT NULL CHECK (LENGTH(phone_number) = 10 AND phone_number REGEXP '^[0-9]+$'),
    email VARCHAR(255) UNIQUE NOT NULL,
    experience VARCHAR(255),
    CONSTRAINT fk_organization_volonteer FOREIGN KEY (id_organization) REFERENCES organization (id_organization)
);
CREATE TABLE feedback (
    id_feedback SERIAL PRIMARY KEY,
    id_volonteer INT,
    id_training INT,
    recommendations TEXT,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT fk_volonteer_feedback FOREIGN KEY (id_volonteer) REFERENCES volonteer (id_volonteer),
    CONSTRAINT fk_training_feedback FOREIGN KEY (id_training) REFERENCES training (id_training)
);
CREATE TABLE task (
    id_task SERIAL PRIMARY KEY,
    id_project INT,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    CONSTRAINT fk_project_task FOREIGN KEY (id_project) REFERENCES project (id_project)
);
CREATE TABLE report (
    id_report SERIAL PRIMARY KEY,
    id_volonteer INT,
    id_task INT UNIQUE,
    date DATE NOT NULL,
    results TEXT NOT NULL,
    CONSTRAINT fk_volonteer_report FOREIGN KEY (id_volonteer) REFERENCES volonteer (id_volonteer),
    CONSTRAINT fk_task_report FOREIGN KEY (id_task) REFERENCES task (id_task)
);
CREATE TABLE skill (
    id_skill SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL
);

CREATE TABLE training_skill (
    id_training INT,
    id_skill INT,
    CONSTRAINT fk_training_skill FOREIGN KEY (id_training) REFERENCES training (id_training),
    CONSTRAINT fk_skill_training FOREIGN KEY (id_skill) REFERENCES skill (id_skill)
);

CREATE TABLE training_volonteer (
    id_training INT,
    id_volonteer INT,
    CONSTRAINT fk_training_volonteer FOREIGN KEY (id_training) REFERENCES training (id_training),
    CONSTRAINT fk_volonteer_training FOREIGN KEY (id_volonteer) REFERENCES volonteer (id_volonteer)
);
