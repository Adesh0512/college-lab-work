import java.sql.*;

/** Clears lock/transaction rows left behind by Hive sessions that were killed.
 *  Run ONLY while no Hive session is running (embedded Derby allows one user). */
public class ClearHiveLocks {
  public static void main(String[] args) throws Exception {
    String db = System.getProperty("user.home") + "/metastore_db";
    try (Connection c = DriverManager.getConnection("jdbc:derby:" + db);
         Statement s = c.createStatement()) {
      ResultSet r = s.executeQuery("SELECT COUNT(*) FROM HIVE_LOCKS"); r.next();
      System.out.println("Leftover Hive locks found : " + r.getInt(1));
      r = s.executeQuery("SELECT COUNT(*) FROM TXNS WHERE TXN_STATE = 'o'"); r.next();
      System.out.println("Open transactions found   : " + r.getInt(1));
      System.out.println("Locks removed             : " + s.executeUpdate("DELETE FROM HIVE_LOCKS"));
      System.out.println("Transactions aborted      : " +
          s.executeUpdate("UPDATE TXNS SET TXN_STATE = 'a' WHERE TXN_STATE = 'o'"));
    }
    try { DriverManager.getConnection("jdbc:derby:;shutdown=true"); }
    catch (SQLException e) { /* normal: Derby reports shutdown as an exception */ }
  }
}
