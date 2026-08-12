import java.sql.*;
import java.util.Scanner;

public class Watchlist {

    private Connection con;

    public Watchlist() throws SQLException {
        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
    }

    // ================= ADD =================
    public void addHackathon(int userId, int hackathonId) throws SQLException {

        if (isInWatchlist(userId, hackathonId)) {
            System.out.println("Hackathon is already in your watchlist.");
            return;
        }

        // Check whether hackathon exists
        String checkHackathon = "SELECT * FROM hackathons WHERE hackathon_id=?";

        PreparedStatement pst1 = con.prepareStatement(checkHackathon);
        pst1.setInt(1, hackathonId);

        ResultSet rs = pst1.executeQuery();

        if (!rs.next()) {
            System.out.println("Hackathon ID does not exist.");
            rs.close();
            pst1.close();
            return;
        }

        rs.close();
        pst1.close();

        String sql = "INSERT INTO watchlist(user_id,hackathon_id,added_at) VALUES(?,?,NOW())";

        PreparedStatement pst = con.prepareStatement(sql);

        pst.setInt(1, userId);
        pst.setInt(2, hackathonId);

        int rows = pst.executeUpdate();

        if (rows > 0) {
            System.out.println("Hackathon added successfully.");
        }

        pst.close();
    }

    // ================= REMOVE =================
    public void removeHackathon(int userId, int hackathonId) throws Exception {

        if (!isInWatchlist(userId, hackathonId)) {
            System.out.println("Hackathon not found in watchlist.");
            return;
        }

        String sql = "DELETE FROM watchlist WHERE user_id=? AND hackathon_id=?";

        PreparedStatement pst = con.prepareStatement(sql);

        pst.setInt(1, userId);
        pst.setInt(2, hackathonId);

        int rows = pst.executeUpdate();

        if (rows > 0) {
            System.out.println("Hackathon removed successfully.");
        }

        pst.close();
    }

    // ================= VIEW =================
    public void viewWatchlist(int userId) throws Exception {

        String sql =
                "SELECT w.watchlist_id,h.hackathon_id,h.title,w.added_at " +
                        "FROM watchlist w " +
                        "JOIN hackathons h ON w.hackathon_id=h.hackathon_id " +
                        "WHERE w.user_id=?";

        PreparedStatement pst = con.prepareStatement(sql);

        pst.setInt(1, userId);

        ResultSet rs = pst.executeQuery();

        int count = 0;

        System.out.println("\n========== YOUR WATCHLIST ==========");

        while (rs.next()) {

            count++;

            System.out.println("----------------------------------");
            System.out.println("Watchlist ID : " + rs.getInt("watchlist_id"));
            System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
            System.out.println("Hackathon Name : " + rs.getString("title"));
            System.out.println("Added At : " + rs.getTimestamp("added_at"));
        }

        if (count == 0) {
            System.out.println("Watchlist is empty.");
        }

        rs.close();
        pst.close();
    }

    // ================= CHECK =================
    public boolean isInWatchlist(int userId, int hackathonId) throws SQLException {

        String sql = "SELECT * FROM watchlist WHERE user_id=? AND hackathon_id=?";

        PreparedStatement pst = con.prepareStatement(sql);

        pst.setInt(1, userId);
        pst.setInt(2, hackathonId);

        ResultSet rs = pst.executeQuery();

        boolean found = rs.next();

        rs.close();
        pst.close();

        return found;
    }

    // ================= MENU =================
    public void menu(int userId) throws Exception {

        Scanner sc = new Scanner(System.in);

        while (true) {

            System.out.println("\n========== WATCHLIST ==========");
            System.out.println("1. Add Hackathon");
            System.out.println("2. Remove Hackathon");
            System.out.println("3. View Watchlist");
            System.out.println("4. Exit");
            int ch;

            while (true) {
                try {
                    System.out.print("Enter Choice : ");
                    ch = sc.nextInt();
                    sc.nextLine(); // Clear newline

                    if (ch <= 0) {
                        System.out.println(" Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric choice.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            switch (ch) {

                case 1:

                    int addId;

                    while (true) {
                        try {
                            System.out.print("Enter Hackathon ID : ");
                            addId = sc.nextInt();
                            sc.nextLine(); // Clear newline

                            if (addId <= 0) {
                                System.out.println(" Hackathon ID must be greater than 0.");
                                continue;
                            }

                            break;
                        } catch (Exception e) {
                            System.out.println(" Invalid input! Please enter a numeric Hackathon ID.");
                            sc.nextLine(); // Clear invalid input
                        }
                    }

                    addHackathon(userId, addId);
                    break;

                case 2:

                    int removeId;

                    while (true) {
                        try {
                            System.out.print("Enter Hackathon ID : ");
                            removeId = sc.nextInt();
                            sc.nextLine(); // Clear newline

                            if (removeId <= 0) {
                                System.out.println(" Hackathon ID must be greater than 0.");
                                continue;
                            }

                            break;
                        } catch (Exception e) {
                            System.out.println(" Invalid input! Please enter a numeric Hackathon ID.");
                            sc.nextLine(); // Clear invalid input
                        }
                    }

                    removeHackathon(userId, removeId);
                    break;

                case 3:

                    viewWatchlist(userId);
                    break;

                case 4:

                    return;

                default:

                    System.out.println("Invalid Choice.");
            }
        }
    }
}