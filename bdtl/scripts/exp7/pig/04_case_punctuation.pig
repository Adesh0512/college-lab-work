-- Experiment 7 | Part 5 : input "Big Data is useful. Big Data is powerful."
-- (a) plain TOKENIZE: case-sensitive and punctuation stays attached to words
raw = LOAD '/bdt/exp7/q4.txt' AS (line:chararray);
w1  = FOREACH raw GENERATE FLATTEN(TOKENIZE(line)) AS word;
g1  = GROUP w1 BY word;
c1  = FOREACH g1 GENERATE group AS word, COUNT(w1) AS freq;
DUMP c1;
-- (b) cleaned: punctuation removed and converted to lower case before counting
clean = FOREACH raw GENERATE LOWER(REPLACE(line, '[^a-zA-Z ]', '')) AS line;
w2  = FOREACH clean GENERATE FLATTEN(TOKENIZE(line)) AS word;
g2  = GROUP w2 BY word;
c2  = FOREACH g2 GENERATE group AS word, COUNT(w2) AS freq;
o2  = ORDER c2 BY freq DESC, word ASC;
DUMP o2;
