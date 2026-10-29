-- Experiment 7 | Part 4 : total number of words (and lines) in the file
lines     = LOAD '/bdt/exp7/input.txt' AS (line:chararray);
words     = FOREACH lines GENERATE FLATTEN(TOKENIZE(line)) AS word;
all_words = GROUP words ALL;
all_lines = GROUP lines ALL;
total     = FOREACH all_words GENERATE COUNT(words) AS total_words;
distinct_words = DISTINCT words;
all_distinct   = GROUP distinct_words ALL;
n_distinct     = FOREACH all_distinct GENERATE COUNT(distinct_words) AS distinct_words;
n_lines        = FOREACH all_lines GENERATE COUNT(lines) AS total_lines;
DUMP total;
DUMP n_distinct;
DUMP n_lines;
