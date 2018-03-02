DROP TABLE scalar_integers;
DROP TABLE goto;

-- Store all the integers in here throughout the program.
CREATE TABLE scalar_integers (
    name CHAR
    , value INTEGER
);

CREATE TABLE goto (
    cur INTEGER
    , next INTEGER
    , next_false INTEGER
);

.mode csv
.import goto.csv goto

SELECT next FROM goto WHERE cur = 0;
