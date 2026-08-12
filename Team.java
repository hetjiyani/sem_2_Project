import java.sql.*;
import java.util.Scanner;

public class Team {

    private int teamId;
    private int hackathonId;
    private String teamName;
    private int maxCapacity;
    private String status;

    Scanner sc = new Scanner(System.in);

    // Create Team
    public void createTeam(String userEmail) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            System.out.println("\n===== Create Team =====");


// Hackathon ID
            while (true) {
                System.out.print("Enter Hackathon ID: ");

                if (sc.hasNextInt()) {
                    hackathonId = sc.nextInt();
                    sc.nextLine();

                    if (hackathonId > 0) {
                        break;
                    } else {
                        System.out.println(" Hackathon ID must be greater than 0.");
                    }
                } else {
                    System.out.println(" Invalid input! Please enter a valid Hackathon ID.");
                    sc.nextLine(); // Clear invalid input
                }
            }

// Team Name
            while (true) {
                System.out.print("Enter Team Name: ");
                teamName = sc.nextLine().trim();

                if (!teamName.isEmpty()) {
                    break;
                } else {
                    System.out.println(" Team Name cannot be empty.");
                }
            }

// Maximum Capacity
            while (true) {
                System.out.print("Enter Maximum Capacity: ");

                if (sc.hasNextInt()) {
                    maxCapacity = sc.nextInt();
                    sc.nextLine();

                    if (maxCapacity > 0) {
                        break;
                    } else {
                        System.out.println(" Maximum Capacity must be greater than 0.");
                    }
                } else {
                    System.out.println(" Invalid input! Please enter a valid number.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            System.out.println("Select Team Status");
            System.out.println("1. FORMING");
            System.out.println("2. FULL");
            System.out.println("3. LOCKED");
            int choice;

            while (true) {
                System.out.print("Enter Choice: ");

                if (sc.hasNextInt()) {
                    choice = sc.nextInt();
                    sc.nextLine(); // Clear newline

                    if (choice > 0) {
                        break; // Valid choice
                    } else {
                        System.out.println(" Choice must be greater than 0.");
                    }
                } else {
                    System.out.println("Invalid input! Please enter a valid number.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            if (choice == 1)
                status = "FORMING";
            else if (choice == 2)
                status = "FULL";
            else
                status = "LOCKED";

            String insertTeam =
                    "INSERT INTO teams(hackathon_id,team_name,max_capacity,status) VALUES(?,?,?,?)";

            PreparedStatement teamPs = con.prepareStatement(insertTeam);

            teamPs.setInt(1, hackathonId);
            teamPs.setString(2, teamName);
            teamPs.setInt(3, maxCapacity);
            teamPs.setString(4, status);

            teamPs.executeUpdate();

            int teamId = 0;

            String teamQuery =
                    "SELECT team_id FROM teams WHERE team_name=? AND hackathon_id=?";

            PreparedStatement getTeamPs = con.prepareStatement(teamQuery);

            getTeamPs.setString(1, teamName);
            getTeamPs.setInt(2, hackathonId);

            ResultSet teamRs = getTeamPs.executeQuery();

            if (teamRs.next()) {
                teamId = teamRs.getInt("team_id");
            }

            int userId = 0;

            String userQuery =
                    "SELECT user_id FROM users WHERE email=?";

            PreparedStatement userPs = con.prepareStatement(userQuery);

            userPs.setString(1, userEmail);

            ResultSet userRs = userPs.executeQuery();

            if (userRs.next()) {
                userId = userRs.getInt("user_id");
            }

            String memberQuery =
                    "INSERT INTO teammembers(team_id,user_id) VALUES(?,?)";

            PreparedStatement memberPs = con.prepareStatement(memberQuery);

            memberPs.setInt(1, teamId);
            memberPs.setInt(2, userId);

            memberPs.executeUpdate();

            System.out.println("Team Created Successfully!");

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // Join Team
    public void joinTeam(String userEmail) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            String viewQuery =
                    "SELECT * FROM teams WHERE status='Open'";

            PreparedStatement viewPs = con.prepareStatement(viewQuery);

            ResultSet rs = viewPs.executeQuery();

            System.out.println("\n========== Available Teams ==========");

            while (rs.next()) {

                System.out.println("--------------------------------");
                System.out.println("Team ID : " + rs.getInt("team_id"));
                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Team Name : " + rs.getString("team_name"));
                System.out.println("Maximum Capacity : " + rs.getInt("max_capacity"));
                System.out.println("Status : " + rs.getString("status"));
            }

            int teamId;

            while (true) {
                try {
                    System.out.print("\nEnter Team ID to Join: ");
                    teamId = sc.nextInt();
                    sc.nextLine();

                    if (teamId <= 0) {
                        System.out.println(" Team ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric Team ID.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            int userId = 0;

            String userQuery =
                    "SELECT user_id FROM users WHERE email=?";

            PreparedStatement userPs = con.prepareStatement(userQuery);

            userPs.setString(1, userEmail);

            ResultSet userRs = userPs.executeQuery();

            if (userRs.next()) {
                userId = userRs.getInt("user_id");
            }

            String checkQuery =
                    "SELECT * FROM teammembers WHERE team_id=? AND user_id=?";

            PreparedStatement checkPs = con.prepareStatement(checkQuery);

            checkPs.setInt(1, teamId);
            checkPs.setInt(2, userId);

            ResultSet checkRs = checkPs.executeQuery();

            if (checkRs.next()) {
                System.out.println("You are already a member of this team.");
                con.close();
                return;
            }

            int maxCapacity = 0;

            String capQuery =
                    "SELECT max_capacity FROM teams WHERE team_id=?";

            PreparedStatement capPs = con.prepareStatement(capQuery);

            capPs.setInt(1, teamId);

            ResultSet capRs = capPs.executeQuery();

            if (capRs.next()) {
                maxCapacity = capRs.getInt("max_capacity");
            }

            int currentMembers = 0;

            String countQuery =
                    "SELECT COUNT(*) FROM teammembers WHERE team_id=?";

            PreparedStatement countPs = con.prepareStatement(countQuery);

            countPs.setInt(1, teamId);

            ResultSet countRs = countPs.executeQuery();

            if (countRs.next()) {
                currentMembers = countRs.getInt(1);
            }

            if (currentMembers >= maxCapacity) {
                System.out.println("Team is Full!");
                con.close();
                return;
            }

            String joinQuery =
                    "INSERT INTO teammembers(team_id,user_id) VALUES(?,?)";

            PreparedStatement joinPs = con.prepareStatement(joinQuery);

            joinPs.setInt(1, teamId);
            joinPs.setInt(2, userId);

            joinPs.executeUpdate();

            currentMembers++;

            if (currentMembers == maxCapacity) {

                String updateQuery =
                        "UPDATE teams SET status='Full' WHERE team_id=?";

                PreparedStatement updatePs =
                        con.prepareStatement(updateQuery);

                updatePs.setInt(1, teamId);

                updatePs.executeUpdate();
            }

            System.out.println("Joined Team Successfully!");

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // Leave Team
    public void leaveTeam(String userEmail) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            int userId = 0;

            String userQuery = "SELECT user_id FROM users WHERE email=?";

            PreparedStatement userPs = con.prepareStatement(userQuery);

            userPs.setString(1, userEmail);

            ResultSet userRs = userPs.executeQuery();

            if (userRs.next()) {
                userId = userRs.getInt("user_id");
            } else {
                System.out.println("User Not Found!");
                con.close();
                return;
            }

            String viewQuery =
                    "SELECT t.team_id,t.team_name,t.status " +
                            "FROM teams t JOIN teammembers tm " +
                            "ON t.team_id=tm.team_id " +
                            "WHERE tm.user_id=?";

            PreparedStatement viewPs = con.prepareStatement(viewQuery);

            viewPs.setInt(1, userId);

            ResultSet rs = viewPs.executeQuery();

            System.out.println("\n===== Your Teams =====");

            boolean found = false;

            while (rs.next()) {

                found = true;

                System.out.println("--------------------------------");
                System.out.println("Team ID : " + rs.getInt("team_id"));
                System.out.println("Team Name : " + rs.getString("team_name"));
                System.out.println("Status : " + rs.getString("status"));
            }

            if (!found) {
                System.out.println("You have not joined any team.");
                con.close();
                return;
            }

            int teamId;

            while (true) {
                try {
                    System.out.print("\nEnter Team ID to Leave: ");
                    teamId = sc.nextInt();
                    sc.nextLine();

                    if (teamId <= 0) {
                        System.out.println(" Team ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric Team ID.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            String deleteQuery =
                    "DELETE FROM teammembers WHERE team_id=? AND user_id=?";

            PreparedStatement deletePs = con.prepareStatement(deleteQuery);

            deletePs.setInt(1, teamId);
            deletePs.setInt(2, userId);

            int rows = deletePs.executeUpdate();

            if (rows > 0) {

                String statusQuery =
                        "UPDATE teams SET status='FORMING' " +
                                "WHERE team_id=? AND status='FULL'";

                PreparedStatement statusPs = con.prepareStatement(statusQuery);

                statusPs.setInt(1, teamId);

                statusPs.executeUpdate();

                System.out.println("Left Team Successfully!");
            } else {
                System.out.println("You are not a member of this team.");
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // View All Teams
    public void viewTeam() {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            String query =
                    "SELECT * FROM teams ORDER BY team_id";

            PreparedStatement ps = con.prepareStatement(query);

            ResultSet rs = ps.executeQuery();

            System.out.println("\n========== TEAM DETAILS ==========");

            while (rs.next()) {

                int teamId = rs.getInt("team_id");

                String countQuery =
                        "SELECT COUNT(*) FROM teammembers WHERE team_id=?";

                PreparedStatement countPs =
                        con.prepareStatement(countQuery);

                countPs.setInt(1, teamId);

                ResultSet countRs = countPs.executeQuery();

                int currentMembers = 0;

                if (countRs.next()) {
                    currentMembers = countRs.getInt(1);
                }

                System.out.println("-------------------------------------------");
                System.out.println("Team ID          : " + teamId);
                System.out.println("Hackathon ID     : " + rs.getInt("hackathon_id"));
                System.out.println("Team Name        : " + rs.getString("team_name"));
                System.out.println("Maximum Capacity : " + rs.getInt("max_capacity"));
                System.out.println("Current Members  : " + currentMembers);
                System.out.println("Status           : " + rs.getString("status"));
                System.out.println("Created At       : " + rs.getTimestamp("created_at"));
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // View Members of a Team
    public void viewTeamMembers() {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            String teamQuery = "SELECT team_id, team_name FROM teams";

            PreparedStatement teamPs = con.prepareStatement(teamQuery);

            ResultSet teamRs = teamPs.executeQuery();

            System.out.println("\n========== Available Teams ==========");

            while (teamRs.next()) {

                System.out.println("--------------------------------");
                System.out.println("Team ID   : " + teamRs.getInt("team_id"));
                System.out.println("Team Name : " + teamRs.getString("team_name"));
            }

            int teamId;

            while (true) {
                try {
                    System.out.print("\nEnter Team ID: ");
                    teamId = sc.nextInt();
                    sc.nextLine();

                    if (teamId <= 0) {
                        System.out.println(" Team ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric Team ID.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            String memberQuery =
                    "SELECT u.user_id, u.name, u.email, tm.joined_at " +
                            "FROM teammembers tm " +
                            "JOIN users u ON tm.user_id = u.user_id " +
                            "WHERE tm.team_id=?";

            PreparedStatement memberPs = con.prepareStatement(memberQuery);

            memberPs.setInt(1, teamId);

            ResultSet rs = memberPs.executeQuery();

            System.out.println("\n========== Team Members ==========");

            boolean found = false;

            while (rs.next()) {

                found = true;

                System.out.println("--------------------------------");
                System.out.println("User ID   : " + rs.getInt("user_id"));
                System.out.println("Name      : " + rs.getString("name"));
                System.out.println("Email     : " + rs.getString("email"));
                System.out.println("Joined At : " + rs.getTimestamp("joined_at"));

                int userId = rs.getInt("user_id");

                String skillQuery =
                        "SELECT s.skill_name, us.proficiency_level " +
                                "FROM userskills us " +
                                "JOIN skills s ON us.skill_id = s.skill_id " +
                                "WHERE us.user_id = ?";

                PreparedStatement skillPs = con.prepareStatement(skillQuery);
                skillPs.setInt(1, userId);

                ResultSet skillRs = skillPs.executeQuery();

                System.out.print("Skills    : ");

                boolean first = true;

                while (skillRs.next()) {

                    if (!first) {
                        System.out.print(", ");
                    }

                    System.out.print(skillRs.getString("skill_name")
                            + " (" + skillRs.getString("proficiency_level") + ")");

                    first = false;
                }

                if (first) {
                    System.out.print("No Skills");
                }

                System.out.println();

                skillRs.close();
                skillPs.close();
            }

            if (!found) {
                System.out.println("No Members Found!");
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

}