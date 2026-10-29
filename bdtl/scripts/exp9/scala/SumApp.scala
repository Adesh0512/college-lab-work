// Experiment 9 | Basic Spark application: create a collection of numbers and calculate their sum
// (run inside spark-shell, where the SparkContext `sc` and SparkSession `spark` already exist)
println("Spark version  : " + spark.version)
println("Spark master   : " + sc.master)
println("Application    : " + sc.appName)

val numbers = sc.parallelize(1 to 10)            // transformation source: RDD from a local collection
println("Numbers        : " + numbers.collect().mkString(", "))
println("Partitions     : " + numbers.getNumPartitions)

val total = numbers.reduce(_ + _)                // action: sum of all elements
println("Sum            : " + total)
println("Count          : " + numbers.count())
println("Average        : " + numbers.mean())

val squares = numbers.map(x => x * x)            // transformation (lazy)
println("Sum of squares : " + squares.sum())     // action triggers the computation

System.exit(0)
