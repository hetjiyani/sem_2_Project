import java.sql.*;
import java.util.Scanner;

public class AdminTeam {

    Scanner sc = new Scanner(System.in);
    Connection con;

    public AdminTeam() throws SQLException {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    // ================= MENU =================

    public void menu() {

        while (true) {

            System.out.println("\n========== TEAM MANAGEMENT ==========");
            System.out.println("1. View Teams");
            System.out.println("2. Delete Team");
            System.out.println("3. View Team Members");
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
                    viewTeams();
                    break;

                case 2:
                    deleteTeam();
                    break;

                case 3:
                    viewTeamMembers();
                    break;

                case 4:
                    return;

                default:
                    System.out.println("Invalid Choice.");
            }
        }
    }

    // ================= VIEW TEAMS =================

    public void viewTeams() {

        try {

            String sql = "SELECT * FROM teams";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            System.out.println("\n========== ALL TEAMS ==========\n");

            while (rs.next()) {

                System.out.println("--------------------------------------");
                System.out.println("Team ID : " + rs.getInt("team_id"));
                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Team Name : " + rs.getString("team_name"));
                System.out.println("Leader User ID : " + rs.getInt("leader_user_id"));
                System.out.println("Maximum Capacity : " + rs.getInt("max_capacity"));
                System.out.println("Status : " + rs.getString("status"));
                System.out.println("Created At : " + rs.getTimestamp("created_at"));

            }

            rs.close();
            pst.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= DELETE TEAM =================

    public void deleteTeam() {

        try {

            System.out.print("Enter Team ID : ");
            int teamId = sc.nextInt();

            // Delete team members first
            String sql1 = "DELETE FROM teammembers WHERE team_id=?";

            PreparedStatement pst1 = con.prepareStatement(sql1);

            pst1.setInt(1, teamId);

            pst1.executeUpdate();

            pst1.close();

            // Delete team
            String sql2 = "DELETE FROM teams WHERE team_id=?";

            PreparedStatement pst2 = con.prepareStatement(sql2);

            pst2.setInt(1, teamId);

            int rows = pst2.executeUpdate();

            if (rows > 0) {

                System.out.println("Team Deleted Successfully.");

            } else {

                System.out.println("Team Not Found.");

            }

            pst2.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

    // ================= VIEW TEAM MEMBERS =================

    public void viewTeamMembers() {

        try {

            int teamId;

            while (true) {
                try {
                    System.out.print("Enter Team ID : ");
                    teamId = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (teamId <= 0) {
                        System.out.println("Team ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            String sql =
                    "SELECT tm.user_id, tm.joined_at " +
                            "FROM teammembers tm " +
                            "WHERE tm.team_id=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setInt(1, teamId);

            ResultSet rs = pst.executeQuery();

            boolean found = false;

            System.out.println("\n========== TEAM MEMBERS ==========\n");

            while (rs.next()) {

                found = true;

                System.out.println("--------------------------------");
                System.out.println("User ID : " + rs.getInt("user_id"));
                System.out.println("Joined At : " + rs.getTimestamp("joined_at"));

            }

            if (!found) {

                System.out.println("No Members Found.");

            }

            rs.close();
            pst.close();

        } catch (Exception e) {

            System.out.println(e);

        }

    }

}