
/* Users(name:string, password: string, surname: string, username: string)*/
CREATE TABLE Users(
    name CHAR(20) not NULL, 
    password CHAR(20) not NULL,
    surname CHAR(20) not NULL,
    username CHAR(20),
    PRIMARY KEY (username));
/* we thought a user couldnt be saved without name, surname and password
in real systems so we made not NULL constraint but not for username 
because its primary key and not NULL is implicit for it */    
    
/* Director(username: string, nation: string)*/    
CREATE TABLE Director(
    username CHAR(20),
    nation CHAR(20) not NULL,
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES Users(username)
    ON DELETE CASCADE);
/*In description it says that every director has nation and if a username
be deleted from user table it should be deleted from director table if it
is a director also*/ 

/* Audience(username: string)*/   
CREATE TABLE Audience(
    username CHAR(20),
    PRIMARY KEY (username),
    FOREIGN KEY (username) REFERENCES Users(username)
    ON DELETE CASCADE);
/*if a username be deleted from user table it should be deleted from
audience table if it is an audience also*/

/* Platform(platform_name: string, platform_id: integer)*/  
CREATE TABLE Platform(
    platform_name CHAR(20) not NULL,
    platform_id INTEGER,
    PRIMARY KEY (platform_id),
    UNIQUE (platform_name));
/* In description it says that every platform name is unique. */

/* Theatre(district: string, capacity: integer, theatre_id: integer, theatre_name: string)*/  
CREATE TABLE Theatre(
    district CHAR(25),
    theatre_name CHAR(25) not NULL,
    capacity INTEGER,
    theatre_id INTEGER,
    PRIMARY KEY (theatre_id));
/* there is no theatre without name, so we added not null constraint */

/* Movie_Session(date: date, time_slot: integer, session_id: integer)*/
CREATE TABLE Movie_Session( -- sanirim buna movie durationu ekleyip sonraki query için end slot eklemek gerek
    date DATE not NULL,
    time_slot INTEGER not NULL,
    session_id INTEGER,
    constraint CHK_slot CHECK ( time_slot>0 and time_slot<=4), /* already in 1st project */
    PRIMARY KEY (session_id));
/* there is no theatre without slot, so we added not null constraint,
and in description it says that time slot cannot be higher than 4 so
we added check constraint */

/* Database_Manager(password: string, manager_username: string)*/
CREATE TABLE Database_Manager(
    password CHAR(20) not NULL,
    manager_username CHAR(20),
    manager_count INT DEFAULT 0,
    PRIMARY KEY (manager_username),
    CONSTRAINT check_manager_count CHECK (manager_count <= 4));
/* there cannot be a database manager without password */

DELIMITER //

CREATE TRIGGER update_manager_count
AFTER INSERT ON Database_Manager
FOR EACH ROW
BEGIN
    UPDATE Database_Manager
    SET manager_count = manager_count + 1;
END //

CREATE TRIGGER delete_manager_count
AFTER DELETE ON Database_Manager
FOR EACH ROW
BEGIN
    UPDATE Database_Manager
    SET manager_count = manager_count - 1;
END //

DELIMITER ;


/* Genre(genre_name: string, genre_id: integer)*/
CREATE TABLE Genre(
    genre_name CHAR(20) not NULL,
    genre_id INTEGER,
    PRIMARY KEY (genre_id),
    UNIQUE (genre_name));
/* There cannot be a genre without name and
in description it says that every genre name is unique. */

/* Directed_Movie(movie_name: string, duration: integer, movie_id: integer, username:string, avg_rating: integer)*/
CREATE TABLE Directed_Movie(
	movie_id INTEGER,
    movie_name CHAR(20) not NULL,
    duration INTEGER,
    username CHAR(20) not NULL,
    avg_rating INTEGER,
    PRIMARY KEY (movie_id),
    FOREIGN KEY (username) REFERENCES Director(username)
    ON DELETE CASCADE);
/* there cannot be a movie without name and without a director so these columns
have not null constraint and because of there cannot be a movie in database without
director, if director is deleted, we will delete the movie*/

/* Classify(movie_id: integer, genre_id: integer)*/
CREATE TABLE Classify(
    movie_id INTEGER,
    genre_id INTEGER,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Directed_Movie(movie_id)
    ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES Genre(genre_id)
    ON DELETE CASCADE);
/* if movie or genre in that relationship is deleted, we delete the row
because it is redundant */

/* Next_To(pre_id: integer, suc_id: integer)*/
CREATE TABLE Next_To(
    pre_id INTEGER,
    suc_id INTEGER,
    PRIMARY KEY (pre_id, suc_id),
    FOREIGN KEY (pre_id) REFERENCES Directed_Movie(movie_id)
    ON DELETE CASCADE,
    FOREIGN KEY (suc_id) REFERENCES Directed_Movie(movie_id)
    ON DELETE CASCADE);
/* if predecessor or successor in that relationship is deleted, 
we delete the row because it is redundant, there would be no pre-suc 
relationship anymore */

/* Located(session_id: integer, theatre_id: integer)*/
CREATE TABLE Located(
    session_id INTEGER,
    theatre_id INTEGER,
    PRIMARY KEY (session_id, theatre_id),
    FOREIGN KEY (session_id) REFERENCES Movie_Session(session_id)
    ON DELETE CASCADE,
    FOREIGN KEY (theatre_id) REFERENCES Theatre(theatre_id)
    ON DELETE CASCADE);
/* if session or theatre in that relationship is deleted, 
we delete the row because it is redundant, there would be no located
relationship anymore */

/* Play(session_id: integer, movie_id: integer)*/
CREATE TABLE Play(
    session_id INTEGER,
    movie_id INTEGER,
    PRIMARY KEY (session_id, movie_id),
    FOREIGN KEY (session_id) REFERENCES Movie_Session(session_id)
    ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Directed_Movie(movie_id)
    ON DELETE CASCADE);
/* if session or movie in that relationship is deleted, 
we delete the row because it is redundant, there would be no play
relationship anymore */

/* Rate(username: string, movie_id: integer, rating:real)*/
CREATE TABLE Rate(
    username CHAR(20),
    movie_id INTEGER,
    rating FLOAT not NULL,
    PRIMARY KEY (username, movie_id),
    FOREIGN KEY (username) REFERENCES Audience(username)
    ON DELETE CASCADE,
    FOREIGN KEY (movie_id) REFERENCES Directed_Movie(movie_id)
    ON DELETE CASCADE);
/* if username or movie in that relationship is deleted, we delete 
the row because it is redundant, there would be no rate relationship
anymore, and also the whole point is rating so that cannot be null*/
DELIMITER //

CREATE TRIGGER update_avg_rating
AFTER INSERT ON Rate
FOR EACH ROW
BEGIN
    -- Calculate the new average rating for the movie
    UPDATE Directed_Movie
    SET avg_rating = (
        SELECT AVG(rating)
        FROM Rate
        WHERE movie_id = NEW.movie_id
    )
    WHERE movie_id = NEW.movie_id;
END //

DELIMITER ;

/* Buy(username: string, session_id: integer)*/
CREATE TABLE Buy(
    username CHAR(20),
    session_id INTEGER,
    PRIMARY KEY (username, session_id),
    FOREIGN KEY (username) REFERENCES Audience(username)
    ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES Movie_Session(session_id)
    ON DELETE CASCADE);
/* if session or username in that relationship is deleted, 
we delete the row because it is redundant, there would be no buy
relationship anymore and also we use audience username because only
audiences buy ticket*/

/* Agreement(username: string, platform_id: integer)*/
CREATE TABLE Agreement(
    username CHAR(20),
    platform_id INTEGER,
    PRIMARY KEY (username, platform_id),
    FOREIGN KEY (username) REFERENCES Director(username)
    ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES Platform(platform_id)
    ON DELETE CASCADE);
/* if username or platform_id in that relationship is deleted, 
we delete the row because it is redundant, there would be no play
relationship anymore and also we use director username because only
directors make an agreement*/

/* Subscribe(username: string, platform_id: integer)*/
CREATE TABLE Subscribe(
    username CHAR(20),
    platform_id INTEGER,
    PRIMARY KEY (username, platform_id),
    FOREIGN KEY (username) REFERENCES Audience(username)
    ON DELETE CASCADE,
    FOREIGN KEY (platform_id) REFERENCES Platform(platform_id)
    ON DELETE CASCADE);
/* if platform or username in that relationship is deleted, 
we delete the row because it is redundant, there would be no subscribe
relationship anymore and also we use audience username because only
audiences subscribe to platforms*/
    
/* Because of not null constraint is implicit for primary keys, we didnt write*/