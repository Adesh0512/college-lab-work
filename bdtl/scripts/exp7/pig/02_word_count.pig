-- Experiment 7 | Part 3 : count the frequency of every distinct word
lines   = LOAD '/bdt/exp7/input.txt' AS (line:chararray);
tokens  = FOREACH lines  GENERATE TOKENIZE(line) AS tokens;   -- bag of words per line
words   = FOREACH tokens GENERATE FLATTEN(tokens) AS word;    -- one tuple per word
grouped = GROUP words BY word;                                -- all occurrences of a word together
counts  = FOREACH grouped GENERATE group AS word, COUNT(words) AS freq;
sorted  = ORDER counts BY freq DESC, word ASC;
DESCRIBE words;
DESCRIBE grouped;
DESCRIBE counts;
-- write the result to HDFS and print it
rmf /bdt/exp7/output_wordcount
STORE sorted INTO '/bdt/exp7/output_wordcount' USING PigStorage('\t');
fs -ls /bdt/exp7/output_wordcount
fs -cat /bdt/exp7/output_wordcount/part*
