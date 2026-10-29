-- Experiment 7 | Part 2 : LOAD a text file and display its contents
-- TextLoader reads every line of the file as one chararray field
lines = LOAD '/bdt/exp7/input.txt' USING TextLoader() AS (line:chararray);
DESCRIBE lines;
DUMP lines;
