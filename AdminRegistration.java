import java.sql.*;
import java.util.Scanner;

public class AdminRegistration {

    Scanner sc = new Scanner(System.in);
    Connection con;

    public AdminRegistration() throws SQLException {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    // ================= MENU =================

    public void menu() {

        while (true) {

            System.out.println("\n========== REGISTRATION MANAGEMENT ==========");
            System.out.println("1. View All Registrations");
            System.out.println("2. View Cancelled Registrations");
            System.out.println("3. Back");
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
                    viewRegistrations();
                    break;

                case 2:
                    viewCancelledRegistrations();
                    break;

                case 3:
                    return;

                default:
                    System.out.println("Invalid Choice.");

            }

        }

    }

    // ================= VIEW ALL REGISTRATIONS =================

    public void viewRegistrations() {

        try {

            String sql = "SELECT * FROM registration";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            System.out.println("\n========== ALL REGISTRATIONS ==========\n");

            while (rs.next()) {

                System.out.println("--------------------------------------");
                System.out.println("Registration ID : " + rs.getInt("registration_id"));
                System.out.println("User ID : " + rs.getInt("user_id"));
                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Status : " + rs.getString("status"));
                System.out.println("Waitlist Position : " + rs.getInt("waitlist_position"));
                System.out.println("Registered At : " + rs.getTimestamp("registered_at"));

            }

            rs.close();
            pst.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= VIEW CANCELLED REGISTRATIONS =================

    public void viewCancelledRegistrations() {

        try {

            String sql = "SELECT * FROM registration WHERE status=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setString(1, "CANCELLED");

            ResultSet rs = pst.executeQuery();

            boolean found = false;

            System.out.println("\n========== CANCELLED REGISTRATIONS ==========\n");

            while (rs.next()) {

                found = true;

                System.out.println("--------------------------------------");
                System.out.println("Registration ID : " + rs.getInt("registration_id"));
                System.out.println("User ID : " + rs.getInt("user_id"));
                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Status : " + rs.getString("status"));
                System.out.println("Waitlist Position : " + rs.getInt("waitlist_position"));
                System.out.println("Registered At : " + rs.getTimestamp("registered_at"));

            }

            if (!found) {

                System.out.println("No Cancelled Registrations Found.");

            }

            rs.close();
            pst.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

}