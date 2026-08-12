import java.sql.*;
import java.util.Scanner;

public class AdminUser {

    Scanner sc = new Scanner(System.in);
    Connection con;

    public AdminUser() throws SQLException {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    // ================= MENU =================

    public void menu() {

        while (true) {

            System.out.println("\n========== USER MANAGEMENT ==========");
            System.out.println("1. View Users");
            System.out.println("2. Search User");
            System.out.println("3. Delete User");
            System.out.println("4. View User Profile");
            System.out.println("5. Back");
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
                    viewUsers();
                    break;

                case 2:
                    searchUser();
                    break;

                case 3:
                    deleteUser();
                    break;

                case 4:
                    viewUserProfile();
                    break;

                case 5:
                    return;

                default:
                    System.out.println("Invalid Choice.");

            }

        }

    }

    // ================= VIEW USERS =================

    public void viewUsers() {

        try {

            String sql = "SELECT * FROM users";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            System.out.println("\n========== USERS ==========\n");

            System.out.println("╔═════╦══════════════════════╦════════════════════════════════════╦══════════════╦═══════════════════════╗");
            System.out.println("║ ID  ║ NAME                 ║ EMAIL                              ║ CITY         ║ CREATED AT            ║");
            System.out.println("╠═════╬══════════════════════╬════════════════════════════════════╬══════════════╬═══════════════════════╣");

            boolean found = false;

            while (rs.next()) {

                found = true;

                System.out.printf(
                        "║ %-3d ║ %-20.20s ║ %-34.34s ║ %-12.12s ║ %-19s ║%n",
                        rs.getInt("user_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("city"),
                        rs.getTimestamp("created_at")
                );
            }

            System.out.println("╚═════╩══════════════════════╩════════════════════════════════════╩══════════════╩═══════════════════════╝");

            if (!found) {
                System.out.println("No users found.");
            }

            rs.close();
            pst.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= SEARCH USER =================

    public void searchUser() {

        try {

            System.out.print("Enter User Name : ");
            String name = sc.nextLine();

            String sql =
                    "SELECT * FROM users WHERE name LIKE ?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setString(1, "%" + name + "%");

            ResultSet rs = pst.executeQuery();

            boolean found = false;

            while (rs.next()) {

                found = true;

                System.out.println("------------------------------------");
                System.out.println("User ID : " + rs.getInt("user_id"));
                System.out.println("Name : " + rs.getString("name"));
                System.out.println("Email : " + rs.getString("email"));
                System.out.println("City : " + rs.getString("city"));
                System.out.println("Created At : " + rs.getTimestamp("created_at"));

            }

            if (!found) {

                System.out.println("User Not Found.");

            }

            rs.close();
            pst.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= DELETE USER =================

    public void deleteUser() {

        try {

            int userId;

            while (true) {
                try {
                    System.out.print("Enter User ID : ");
                    userId = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (userId <= 0) {
                        System.out.println("User ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            // Delete user's skills
            String sql1 =
                    "DELETE FROM userskills WHERE user_id=?";

            PreparedStatement pst1 = con.prepareStatement(sql1);

            pst1.setInt(1, userId);

            pst1.executeUpdate();

            pst1.close();

            // Delete user
            String sql2 =
                    "DELETE FROM users WHERE user_id=?";

            PreparedStatement pst2 = con.prepareStatement(sql2);

            pst2.setInt(1, userId);

            int rows = pst2.executeUpdate();

            if (rows > 0) {

                System.out.println("User Deleted Successfully.");

            } else {

                System.out.println("User Not Found.");

            }

            pst2.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= USER PROFILE =================

    public void viewUserProfile() {

        try {

            int userId;

            while (true) {
                try {
                    System.out.print("Enter User ID : ");
                    userId = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (userId <= 0) {
                        System.out.println("User ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            String sql =
                    "SELECT * FROM users WHERE user_id=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setInt(1, userId);

            ResultSet rs = pst.executeQuery();

            if (!rs.next()) {

                System.out.println("User Not Found.");

                rs.close();
                pst.close();
                return;

            }

            System.out.println("\n========== USER PROFILE ==========");

            System.out.println("User ID : " + rs.getInt("user_id"));
            System.out.println("Name : " + rs.getString("name"));
            System.out.println("Email : " + rs.getString("email"));
            System.out.println("City : " + rs.getString("city"));
            System.out.println("Created At : " + rs.getTimestamp("created_at"));

            rs.close();
            pst.close();

            System.out.println("\nSkills:");

            String sql2 =
                    "SELECT s.skill_name " +
                            "FROM userskills us " +
                            "JOIN skills s ON us.skill_id=s.skill_id " +
                            "WHERE us.user_id=?";

            PreparedStatement pst2 = con.prepareStatement(sql2);

            pst2.setInt(1, userId);

            ResultSet rs2 = pst2.executeQuery();

            boolean found = false;

            while (rs2.next()) {

                found = true;

                System.out.println("- " + rs2.getString("skill_name"));

            }

            if (!found) {

                System.out.println("No Skills Added.");

            }

            rs2.close();
            pst2.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

}