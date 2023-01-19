/******************************************************************************************/
-- Queries to create a smaller version of IMDB database 
/*****************************************************************************************/
-- Creating and using the database 
DROP DATABASE IF EXISTS imdb;

CREATE DATABASE imdb;

USE imdb;

-- Creating the structure of various tables in the database
DROP TABLE IF EXISTS movie;
CREATE TABLE movie
 (
  id VARCHAR(10) NOT NULL,
  title VARCHAR(200) DEFAULT NULL,
  year INT DEFAULT NULL,
  date_published DATE DEFAULT null,
  duration INT,
  country VARCHAR(250),
  worlwide_gross_income VARCHAR(30),
  languages VARCHAR(200),
  production_company VARCHAR(200),
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS genre;
CREATE TABLE genre
 (
	movie_id VARCHAR(10),
    genre VARCHAR(20),
	PRIMARY KEY (movie_id, genre)
);

DROP TABLE IF EXISTS director_mapping;
CREATE TABLE director_mapping	
 (
	movie_id VARCHAR(10),
    name_id VARCHAR(10),
	PRIMARY KEY (movie_id, name_id)
);

DROP TABLE IF EXISTS role_mapping;
CREATE TABLE role_mapping
 (
	movie_id VARCHAR(10) NOT NULL,
    name_id VARCHAR(10) NOT NULL,
    category VARCHAR(10),
	PRIMARY KEY (movie_id, name_id)
);
	
DROP TABLE IF EXISTS names;
CREATE TABLE names
 (
  id varchar(10) NOT NULL,
  name varchar(100) DEFAULT NULL,
  height int DEFAULT NULL,
  date_of_birth date DEFAULT null,
  known_for_movies varchar(100),
  PRIMARY KEY (id)
);

DROP TABLE IF EXISTS ratings; 
CREATE TABLE ratings
(
	movie_id VARCHAR(10) NOT NULL,
	avg_rating DECIMAL(3,1),
	total_votes INT,
	median_rating INT,
    PRIMARY KEY (movie_id)
);

