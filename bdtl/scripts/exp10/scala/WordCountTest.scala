// Experiment 10 | WordCountTest.scala - unit tests for WordCount.countWords
var passed = 0
var failed = 0
def check(name: String, lines: Seq[String], expected: Map[String, Int]): Unit = {
  val actual = WordCount.countWords(sc.parallelize(lines)).collect().toMap
  if (actual == expected) { passed += 1; println(s"[PASS] $name -> $actual") }
  else { failed += 1; println(s"[FAIL] $name\n       expected: $expected\n       actual  : $actual") }
}

check("normal input",   Seq("Apache Spark is fast"),
      Map("Apache" -> 1, "Spark" -> 1, "is" -> 1, "fast" -> 1))
check("repeated words", Seq("Big Data Big Analytics"),
      Map("Big" -> 2, "Data" -> 1, "Analytics" -> 1))
check("empty input",    Seq.empty[String], Map.empty[String, Int])
check("blank lines and extra spaces", Seq("", "   ", "  Spark   Spark "), Map("Spark" -> 2))
check("multiple lines", Seq("Spark is fast", "Hadoop is reliable", "Spark and Hadoop"),
      Map("Spark" -> 2, "is" -> 2, "fast" -> 1, "Hadoop" -> 2, "reliable" -> 1, "and" -> 1))
check("case sensitivity", Seq("Data data DATA"), Map("Data" -> 1, "data" -> 1, "DATA" -> 1))

println(s"Unit tests: $passed passed, $failed failed, ${passed + failed} total")
