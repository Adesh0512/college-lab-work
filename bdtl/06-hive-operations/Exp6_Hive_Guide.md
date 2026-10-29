# BDT Lab – Experiment 6: Operations on Hive (Create, Insert, Update)

Each step below matches a heading in your lab sheet's **Results** section. Take one screenshot per step (on a Mac, press **Cmd + Shift + 4**, then **Space**, then click the Terminal window).

---

## 0. One-time setup (≈ 15–20 min, mostly downloading)

**On your Mac (Terminal):**

```bash
# create the Ubuntu VM (skip if you already have it)
multipass launch 24.04 --name bigdata --cpus 2 --memory 4G --disk 20G

# copy the setup script into the VM (run from the folder where you saved it)
multipass transfer exp6_setup.sh bigdata:

# open Ubuntu
multipass shell bigdata
```

**Inside Ubuntu** (prompt looks like `ubuntu@bigdata:~$`):

```bash
bash exp6_setup.sh
source ~/.bashrc
```

The script installs Java 8, Hadoop 3.3.6 and Hive 3.1.2, writes all the config files, formats HDFS, starts Hadoop, creates the Hive folders in HDFS and initialises the Derby metastore. It picks the right Hadoop build for Intel or Apple-chip Macs automatically.

> Every later session: `multipass shell bigdata`, then `start-dfs.sh && start-yarn.sh`.
> When done: `stop-yarn.sh && stop-dfs.sh`, `exit`, then on the Mac `multipass stop bigdata`.

---

## 1. Hive – installation, configuration  *(screenshots)*

```bash
ls -l ~ | grep -E "hadoop|hive"
tail -15 ~/.bashrc
cat $HIVE_HOME/conf/hive-site.xml
hive --version
```

## 2. Starting Hadoop  *(screenshot)*

```bash
start-dfs.sh
start-yarn.sh
jps
```

`jps` should list **NameNode, DataNode, SecondaryNameNode, ResourceManager, NodeManager**.
(If it says they're already running, that's fine: the setup script started them.)

## 3. Creating directories, giving write permissions, initialising Derby  *(screenshot)*

The script already did this. These commands are safe to run again for your screenshot:

```bash
hdfs dfs -mkdir -p /tmp /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -ls /user/hive
schematool -dbType derby -info
```

(`-info` shows the already-initialised schema. Running `-initSchema` a second time gives an error because it already exists.)

## 4. Launching Hive  *(screenshot)*

```bash
hive
```

```sql
show databases;
```

The SLF4J and "Hive-on-MR is deprecated" warnings at startup are normal; your lab sheet shows them too.

---

## 5. Operations on Hive

### Prepare the data file (in a **second** Ubuntu tab)

On the Mac, open a new Terminal tab and run `multipass shell bigdata` again. Then:

```bash
cat > info.csv <<EOF
101,Aarav,TY,Computer Engg
102,Diya,SY,IT
103,Kabir,FY,Mechanical
104,Meera,TY,Data Science
105,Rohan,SY,Civil
EOF

hdfs dfs -mkdir -p /info
hdfs dfs -put -f info.csv /info/
hdfs dfs -ls /info
```

(Change the names to your own classmates' if you like.)

### (i) Create a database MyDB  *(back in the hive tab)*

```sql
CREATE DATABASE IF NOT EXISTS MyDB;
SHOW DATABASES;
USE MyDB;
```

### (ii) Create and describe table Stud_info

```sql
CREATE TABLE Stud_info (Roll_No INT, Name STRING, Year STRING, Course STRING)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

DESCRIBE Stud_info;
```

### (iii) Load data from info.csv stored in HDFS

```sql
LOAD DATA INPATH '/info/info.csv' INTO TABLE Stud_info;
SELECT * FROM Stud_info;
```

(After this, `hdfs dfs -ls /info` in the other tab shows the file has **moved** into `/user/hive/warehouse/mydb.db/stud_info/`.)

### (iv) Insert data through commands

```sql
INSERT INTO TABLE Stud_info VALUES (106, 'Sneha', 'LY', 'Electronics');
INSERT INTO TABLE Stud_info VALUES (107, 'Arjun', 'FY', 'Chemical');
SELECT * FROM Stud_info;
```

Each INSERT runs a MapReduce job (you'll see `Launching Job 1 out of …`, `map = 100%, reduce = 100%`). It takes about 15–30 seconds. That's normal.

### (v) Update a record (ACID table)

Normal text tables in Hive **cannot** be updated. If you try this:

```sql
UPDATE Stud_info SET Course = 'AI-ML' WHERE Roll_No = 101;
```

Hive refuses: it says the table is not transactional / doesn't support update or delete. (This error is a good screenshot to include, because it shows *why* the next step is needed.)

UPDATE needs a **transactional (ACID) table stored as ORC**. The setup script already enabled transactions in `hive-site.xml`.

```sql
CREATE TABLE Stud_info_acid (Roll_No INT, Name STRING, Year STRING, Course STRING)
STORED AS ORC
TBLPROPERTIES ('transactional'='true');

INSERT INTO TABLE Stud_info_acid SELECT * FROM Stud_info;
SELECT * FROM Stud_info_acid;

UPDATE Stud_info_acid SET Course = 'AI-ML' WHERE Roll_No = 101;
UPDATE Stud_info_acid SET Year = 'LY' WHERE Name = 'Diya';
SELECT * FROM Stud_info_acid;

-- bonus: DELETE also works on ACID tables
DELETE FROM Stud_info_acid WHERE Roll_No = 107;
SELECT * FROM Stud_info_acid;
```

### (vi) Managed vs External table (theory section 3.2)

Prepare a file in the second tab:

```bash
cp info.csv data.txt
```

In hive:

```sql
CREATE EXTERNAL TABLE Stud_external (Roll_No INT, Name STRING, Year STRING, Course STRING)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
LOCATION '/user/hive/data/stud_external';

LOAD DATA LOCAL INPATH '/home/ubuntu/data.txt' INTO TABLE Stud_external;
SELECT * FROM Stud_external;
DROP TABLE Stud_external;
```

Then in the second tab:

```bash
hdfs dfs -ls /user/hive/data/stud_external/
```

The file is **still there** after the DROP. That's the key difference between external and managed tables.

### (vii) View it in the Hadoop Web UI  *(screenshots, like the last page of your sheet)*

On the Mac:

```bash
multipass info bigdata | grep IPv4
```

Open `http://<that-IP>:9870` in Safari or Chrome. Go to **Utilities → Browse the file system**, then open `/`, `/user/hive/warehouse` and `/user/hive/warehouse/mydb.db`.

---

## Handwritten questions – answers

**Q1. Create CollegeDB, select it, create table Student(RollNo, Name, Department, Marks)**

```sql
CREATE DATABASE IF NOT EXISTS CollegeDB;
USE CollegeDB;
CREATE TABLE Student (RollNo INT, Name STRING, Department STRING, Marks INT)
ROW FORMAT DELIMITED FIELDS TERMINATED BY ','
STORED AS TEXTFILE;
```

**Q2. Insert at least five records and display them**

```sql
INSERT INTO TABLE Student VALUES
  (1, 'Aarav', 'Computer', 82),
  (2, 'Diya',  'IT',       68),
  (3, 'Kabir', 'Mechanical', 91),
  (4, 'Meera', 'Civil',    74),
  (5, 'Rohan', 'Electronics', 79);
SELECT * FROM Student;
```

**Q3. Students with marks > 75, in descending order of marks**

```sql
SELECT * FROM Student WHERE Marks > 75 ORDER BY Marks DESC;
```

With the data above, the result is Kabir 91, Aarav 82, Rohan 79.

**Q4. Managed vs external tables; metadata; updating a record**

- **Managed (internal) table:** Hive owns both the metadata *and* the data files, which are stored under `/user/hive/warehouse/<db>.db/<table>`. `DROP TABLE` deletes both.
- **External table:** Hive owns only the metadata. The data stays at the `LOCATION` you gave. `DROP TABLE` removes only the metadata, so the files remain in HDFS for other tools (Pig, Spark…).
- **Showing metadata:** `DESCRIBE Student;` shows columns. `DESCRIBE FORMATTED Student;` shows the full metadata: owner, location, table type (MANAGED_TABLE / EXTERNAL_TABLE), input format and properties. Also `SHOW CREATE TABLE Student;`.
- **Updating a record:** Hive only allows `UPDATE` on **ACID tables**. These need `hive.support.concurrency=true` and `hive.txn.manager=DbTxnManager`, and the table must be `STORED AS ORC TBLPROPERTIES ('transactional'='true')`. Example:
  `UPDATE Student_acid SET Marks = 85 WHERE RollNo = 2;`
  For a non-ACID table, the workaround is to rewrite the table:
  `INSERT OVERWRITE TABLE Student SELECT RollNo, Name, Department, CASE WHEN RollNo = 2 THEN 85 ELSE Marks END FROM Student;`

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `hive: command not found` | Run `source ~/.bashrc` (or open a new tab). |
| `jps` doesn't show NameNode after a VM restart | `start-dfs.sh && start-yarn.sh` |
| `Name node is in safe mode` | Wait 30 s, or run `hdfs dfsadmin -safemode leave` |
| `localhost: Permission denied (publickey)` on start-dfs.sh | `cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys` then retry |
| INSERT/UPDATE job stuck at `map = 0%` for minutes | VM is low on memory. On the Mac run `multipass stop bigdata`, then `multipass set local.bigdata.memory=6G` (if your Mac has 16 GB), then `multipass start bigdata` |
| Anything else | Copy the last ~20 lines of the error and send them to me |
