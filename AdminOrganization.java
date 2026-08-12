import java.sql.*;
import java.util.Scanner;

public class AdminOrganization {

    Scanner sc = new Scanner(System.in);
    Connection con;

    public AdminOrganization() throws SQLException {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    // ================= MENU =================

    public void menu() {

        while (true) {

            System.out.println("\n========== ORGANIZATION MANAGEMENT ==========");
            System.out.println("1. View Organizations");
            System.out.println("2. Search Organization");
            System.out.println("3. Delete Organization");
            System.out.println("4. View Organization Hackathons");
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
                    viewOrganizations();
                    break;

                case 2:
                    searchOrganization();
                    break;

                case 3:
                    deleteOrganization();
                    break;

                case 4:
                    viewOrganizationHackathons();
                    break;

                case 5:
                    return;

                default:
                    System.out.println("Invalid Choice.");

            }

        }

    }

    // ================= VIEW ORGANIZATIONS =================

    public void viewOrganizations() {

        try {

            String sql = "SELECT * FROM organization";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            System.out.println("\n========== ORGANIZATIONS ==========\n");

            while (rs.next()) {

                System.out.println("---------------------------------------");
                System.out.println("Organization ID : " + rs.getInt("organization_id"));
                System.out.println("Organization Name : " + rs.getString("organization_name"));
                System.out.println("Email : " + rs.getString("email"));
                System.out.println("Contact Person : " + rs.getString("contact_person"));
                System.out.println("Phone : " + rs.getString("phone"));
                System.out.println("Website : " + rs.getString("website"));
                System.out.println("Type : " + rs.getString("organization_type"));
                System.out.println("City : " + rs.getString("city"));

            }

            rs.close();
            pst.close();

        } catch (Exception e) {
            System.out.println(e);
        }

    }

    // ================= SEARCH =================

    public void searchOrganization() {

        try {

            System.out.print("Enter Organization Name : ");
            String name = sc.nextLine();

            String sql =
                    "SELECT * FROM organization WHERE organization_name LIKE ?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setString(1, "%" + name + "%");

            ResultSet rs = pst.executeQuery();

            boolean found = false;

            while (rs.next()) {

                found = true;

                System.out.println("---------------------------------------");
                System.out.println("Organization ID : " + rs.getInt("organization_id"));
                System.out.println("Organization Name : " + rs.getString("organization_name"));
                System.out.println("Email : " + rs.getString("email"));
                System.out.println("Contact Person : " + rs.getString("contact_person"));
                System.out.println("Phone : " + rs.getString("phone"));
                System.out.println("Website : " + rs.getString("website"));
                System.out.println("Type : " + rs.getString("organization_type"));
                System.out.println("City : " + rs.getString("city"));

            }

            if (!found) {

                System.out.println("Organization Not Found.");

            }

            rs.close();
            pst.close();

        } catch (Exception e) {
            System.out.println(e);
        }

    }

    // ================= DELETE =================

    public void deleteOrganization() {

        try {

            int id;

            while (true) {
                try {
                    System.out.print("Enter Organization ID : ");
                    id = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (id <= 0) {
                        System.out.println("Organization ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            String sql =
                    "DELETE FROM organization WHERE organization_id=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setInt(1, id);

            int rows = pst.executeUpdate();

            if (rows > 0)
                System.out.println("Organization Deleted Successfully.");
            else
                System.out.println("Organization Not Found.");

            pst.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= VIEW ORGANIZATION HACKATHONS =================

    public void viewOrganizationHackathons() {

        try {

            int organizationId;

            while (true) {
                try {
                    System.out.print("Enter Organization ID : ");
                    organizationId = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (organizationId <= 0) {
                        System.out.println("Organization ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            String sql =
                    "SELECT h.* " +
                            "FROM organizationhackthone oh " +
                            "JOIN hackathons h ON oh.hackthone_id = h.hackathon_id " +
                            "WHERE oh.organization_id=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setInt(1, organizationId);

            ResultSet rs = pst.executeQuery();

            boolean found = false;

            System.out.println("\n========== ORGANIZATION HACKATHONS ==========\n");

            while (rs.next()) {

                found = true;

                System.out.println("---------------------------------------");
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

            }

            if (!found) {

                System.out.println("No Hackathons Found.");

            }

            rs.close();
            pst.close();

        }

        catch (Exception e) {

            System.out.println(e);

        }

    }

}