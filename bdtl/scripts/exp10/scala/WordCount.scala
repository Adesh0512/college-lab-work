// Experiment 10 | WordCount.scala - Word Count in Apache Spark
// 1. Import the necessary Spark classes
import org.apache.spark.{SparkConf, SparkContext}
import org.apache.spark.rdd.RDD

object WordCount {

  // Core logic, kept in its own function so that it can be unit-tested
  def countWords(lines: RDD[String]): RDD[(String, Int)] =
    lines.flatMap(line => line.split("\\s+"))   // 5. split each line into words
         .filter(word => word.nonEmpty)          //    ignore empty tokens
         .map(word => (word, 1))                 //    key-value pair (word, 1)
         .reduceByKey(_ + _)                     // 6. count the occurrences of each word

  def main(args: Array[String]): Unit = {
    val conf   = new SparkConf().setAppName("WordCount")   // 2. create Spark configuration
    val sc     = SparkContext.getOrCreate(conf)            // 3. create (or reuse) the Spark context
    val input  = sc.textFile(args(0))                      // 4. load input data from HDFS
    val counts = countWords(input)
    counts.saveAsTextFile(args(1))                         // 7. save the word-count result to HDFS
    println("Word count result (sorted by frequency):")
    counts.sortBy(p => (-p._2, p._1)).collect().foreach(println)
    sc.stop()                                              // 8. stop the Spark context
  }
}
