import java.sql.*;
import java.util.Scanner;

public class AdminStatistics {

    Scanner sc = new Scanner(System.in);
    Connection con;

    public AdminStatistics() throws SQLException {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    // ================= MENU =================

    public void menu() {

        while (true) {

            System.out.println("\n========== STATISTICS ==========");
            System.out.println("1. Total Users");
            System.out.println("2. Total Organizations");
            System.out.println("3. Total Hackathons");
            System.out.println("4. Total Teams");
            System.out.println("5. Most Popular Hackathon");
            System.out.println("6. Back");
            int ch;

            while (true) {
                try {
                    System.out.print("Enter Choice : ");
                    ch = sc.nextInt();
                    sc.nextLine(); // Consume the newline
                    break;
                } catch (java.util.InputMismatchException e) {
                    System.out.println("Invalid input! Please enter a number.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            switch (ch) {

                case 1:
                    totalUsers();
                    break;

                case 2:
                    totalOrganizations();
                    break;

                case 3:
                    totalHackathons();
                    break;

                case 4:
                    totalTeams();
                    break;

                case 5:
                    mostPopularHackathon();
                    break;

                case 6:
                    return;

                default:
                    System.out.println("Invalid Choice.");

            }

        }

    }

    // ================= TOTAL USERS =================

    public void totalUsers() {

        try {

            String sql = "SELECT COUNT(user_id) FROM users";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {

                System.out.println("\nTotal Users : " + rs.getInt(1));

            }

            rs.close();
            pst.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= TOTAL ORGANIZATIONS =================

    public void totalOrganizations() {

        try {

            String sql = "SELECT COUNT(organization_id) FROM organization";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {

                System.out.println("\nTotal Organizations : " + rs.getInt(1));

            }

            rs.close();
            pst.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= TOTAL HACKATHONS =================

    public void totalHackathons() {

        try {

            String sql = "SELECT COUNT(hackathon_id) FROM hackathons";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {

                System.out.println("\nTotal Hackathons : " + rs.getInt(1));

            }

            rs.close();
            pst.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= TOTAL TEAMS =================

    public void totalTeams() {

        try {

            String sql = "SELECT COUNT(team_id) FROM teams";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {

                System.out.println("\nTotal Teams : " + rs.getInt(1));

            }

            rs.close();
            pst.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= MOST POPULAR HACKATHON =================

    public void mostPopularHackathon() {

        try {

            String sql =
                    "SELECT hackathon_id,title,current_participants " +
                            "FROM hackathons " +
                            "ORDER BY current_participants DESC " +
                            "LIMIT 1";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {

                System.out.println("\n========== MOST POPULAR HACKATHON ==========");
                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Title : " + rs.getString("title"));
                System.out.println("Participants : " + rs.getInt("current_participants"));

            } else {

                System.out.println("No Hackathon Found.");

            }

            rs.close();
            pst.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

}