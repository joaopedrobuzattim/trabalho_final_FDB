drop database if exists olympic_participation;
create database olympic_participation;
use olympic_participation;


CREATE TABLE Athlete (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    age INT NOT NULL,
    birthday DATETIME NOT NULL,
    deceased_date DATETIME, 
    height VARCHAR(255), 
    hometown VARCHAR(255) NOT NULL,
    education VARCHAR(255), 
    gold_medals INT NOT NULL,
    silver_medals INT NOT NULL,
    bronze_medals INT NOT NULL
);

CREATE TABLE Sport (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    season VARCHAR(255) NOT NULL
);

CREATE TABLE Olympics (
    id INT PRIMARY KEY AUTO_INCREMENT,
    edition VARCHAR(255) NOT NULL,
    country VARCHAR(255) NOT NULL,
    city VARCHAR(255) NOT NULL,
    year INT NOT NULL,
    season VARCHAR(255) NOT NULL
);

CREATE TABLE Participation (
    id INT PRIMARY KEY AUTO_INCREMENT,
    athlete_id INT,
    olympics_id INT,
    FOREIGN KEY (athlete_id) REFERENCES Athlete(id),
    FOREIGN KEY (olympics_id) REFERENCES Olympics(id)
);

CREATE TABLE AtlheteSport (
    id INT PRIMARY KEY AUTO_INCREMENT,
    athlete_id INT,
    sport_id INT,
    FOREIGN KEY (athlete_id) REFERENCES Athlete(id),
    FOREIGN KEY (sport_id) REFERENCES Sport(id)
);


