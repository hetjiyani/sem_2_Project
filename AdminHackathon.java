import java.sql.*;
import java.util.Scanner;

public class AdminHackathon {

    Scanner sc = new Scanner(System.in);
    Connection con;

    public AdminHackathon() throws SQLException {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    // ================= MENU =================

    public void menu() {

        while (true) {

            System.out.println("\n========== HACKATHON MANAGEMENT ==========");
            System.out.println("1. View All Hackathons");
            System.out.println("2. Delete Hackathon");
            System.out.println("3. View Hackathon Details");
            System.out.println("4. Back");
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
                    viewHackathons();
                    break;

                case 2:
                    deleteHackathon();
                    break;

                case 3:
                    viewHackathonDetails();
                    break;

                case 4:
                    return;

                default:
                    System.out.println("Invalid Choice.");
            }

        }

    }

    // ================= VIEW ALL =================

    public void viewHackathons() {

        try {

            String sql = "SELECT * FROM hackathons";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            System.out.println("\n========== ALL HACKATHONS ==========");

            while (rs.next()) {

                System.out.println("-----------------------------------------");
                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Title : " + rs.getString("title"));
                System.out.println("Location : " + rs.getString("location_city"));
                System.out.println("Mode : " + rs.getString("mode"));
                System.out.println("-----------------------------------------");

            }

            rs.close();
            pst.close();

        } catch (Exception e) {
            System.out.println(e);
        }

    }

    // ================= DELETE =================

    public void deleteHackathon() {

        try {

            int id;

            while (true) {
                try {
                    System.out.print("Enter Hackathon ID : ");
                    id = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (id > 0) {
                        break;
                    }

                    System.out.println("Hackathon ID must be greater than 0.");
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            String sql = "DELETE FROM hackathons WHERE hackathon_id=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setInt(1, id);

            int rows = pst.executeUpdate();

            if (rows > 0)
                System.out.println("Hackathon Deleted Successfully.");
            else
                System.out.println("Hackathon Not Found.");

            pst.close();

        } catch (Exception e) {
            System.out.println(e);
        }

    }

    // ================= DETAILS =================

    public void viewHackathonDetails() {

        try {

            int id;

            while (true) {
                try {
                    System.out.print("Enter Hackathon ID : ");
                    id = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (id > 0) {
                        break;
                    }

                    System.out.println("Hackathon ID must be greater than 0.");
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            String sql = "SELECT * FROM hackathons WHERE hackathon_id=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setInt(1, id);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {

                System.out.println("\n========== HACKATHON DETAILS ==========");

                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Title : " + rs.getString("title"));
                System.out.println("Location : " + rs.getString("location_city"));
                System.out.println("Mode : " + rs.getString("mode"));
                System.out.println("Prize Pool : " + rs.getDouble("prize_pool"));
                System.out.println("Start Date : " + rs.getDate("start_date"));
                System.out.println("End Date : " + rs.getDate("end_date"));
                System.out.println("Registration Deadline : " + rs.getDate("registration_deadline"));
                System.out.println("Maximum Participants : " + rs.getInt("max_participants"));
                System.out.println("Current Participants : " + rs.getInt("current_participants"));

            } else {

                System.out.println("Hackathon Not Found.");

            }

            rs.close();
            pst.close();

        } catch (Exception e) {
            System.out.println(e);
        }

    }

}