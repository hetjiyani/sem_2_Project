import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Scanner;

public class MainApp {

    public void main_user() throws Exception {
        Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        Scanner sc = new Scanner(System.in);

        User user = new User();
        Hackathon hackathon = new Hackathon();
        Team team = new Team();
        Registration registration = new Registration();
        Recommendation recommendation = new Recommendation();

        int userId = -1;
        String userEmail = "";
        int choice;

        do {

            System.out.println("\n========== HACKATHON PORTAL ==========");
            System.out.println("1. Register");
            System.out.println("2. Login");
            System.out.println("3. Exit");
//            int choice;

            while (true) {
                try {
                    System.out.print("Enter Choice: ");
                    choice = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (choice <= 0) {
                        System.out.println("Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            switch (choice) {

                case 1:
                    userEmail = user.registerUser();

                    if (userEmail == null) {
                        break;
                    }

                    String sql = "SELECT user_id FROM users WHERE email = ?";
                    PreparedStatement pst = con.prepareStatement(sql);
                    pst.setString(1, userEmail);
                    ResultSet rs = pst.executeQuery();

                    if (rs.next()) {
                        userId = rs.getInt("user_id");
                    } else {
                        System.out.println("User not found!");
                    }

                    break;

                case 2:
                    System.out.print("Enter Email: ");
                    String loginEmail = sc.nextLine();

                    System.out.print("Enter Password: ");
                    String loginPassword = sc.nextLine();

                    userEmail = loginEmail;
                    String sql1 = "SELECT user_id FROM users WHERE email = ?";

                    PreparedStatement pst2 = con.prepareStatement(sql1);
                    pst2.setString(1, loginEmail);

                    ResultSet rs1 = pst2.executeQuery();

                    if (rs1.next()) {
                        userId = rs1.getInt("user_id");
                    }

                    if (user.loginUser(loginEmail, loginPassword)) {

                        int userChoice;

                        do {

                            System.out.println("\n========== USER MENU ==========");
                            System.out.println("1. Profile");
                            System.out.println("2. Hackathons");
                            System.out.println("3. Recommendations");
                            System.out.println("4. Filter Hackathons");
                            System.out.println("5. Logout");

//                            int userChoice;

                            while (true) {
                                try {
                                    System.out.print("Enter Choice: ");
                                    userChoice = sc.nextInt();
                                    sc.nextLine(); // Consume the newline

                                    if (userChoice <= 0) {
                                        System.out.println("Choice must be greater than 0.");
                                        continue;
                                    }

                                    break;
                                } catch (Exception e) {
                                    System.out.println("Invalid input! Please enter a valid integer.");
                                    sc.nextLine(); // Clear the invalid input
                                }
                            }

                            switch (userChoice) {

                                case 1:

                                    int profileChoice;

                                    do {

                                        System.out.println("\n========== PROFILE ==========");
                                        System.out.println("1. View Profile");
                                        System.out.println("2. Edit Profile");
                                        System.out.println("3. Exit");
                                        while (true) {
                                            try {
                                                System.out.print("Enter Choice: ");
                                                profileChoice = sc.nextInt();
                                                sc.nextLine(); // Consume the newline

                                                if (profileChoice <= 0) {
                                                    System.out.println("Choice must be greater than 0.");
                                                    continue;
                                                }

                                                break;
                                            } catch (Exception e) {
                                                System.out.println("Invalid input! Please enter a valid integer.");
                                                sc.nextLine(); // Clear the invalid input
                                            }
                                        }

                                        switch (profileChoice) {

                                            case 1:
                                                user.viewProfile();
                                                break;

                                            case 2:
                                                user.editProfile();
                                                break;

                                            case 3:
                                                System.out.println("Returning...");
                                                break;

                                            default:
                                                System.out.println("Invalid Choice!");
                                        }

                                    } while (profileChoice != 3);

                                    break;

                                case 2:

                                    int hackChoice;

                                    do {

                                        System.out.println("\n========== HACKATHONS ==========");
                                        System.out.println("1. View All Hackathons");
                                        System.out.println("2. Search Hackathon");
                                        System.out.println("3. Create Team");
                                        System.out.println("4. Join Team");
                                        System.out.println("5. Leave Team");
                                        System.out.println("6. View Teams");
                                        System.out.println("7. View Team Members");
                                        System.out.println("8. Register for Hackathon");
                                        System.out.println("9. Bookmark Hackathon");
                                        System.out.println("10. Cancel Registration");
                                        System.out.println("11. Team Leaderboard");
                                        System.out.println("12. Search History");
                                        System.out.println("13. Clear Search History");
                                        System.out.println("14. Exit");

                                        while (true) {
                                            try {
                                                System.out.print("Enter Choice: ");
                                                hackChoice = sc.nextInt();
                                                sc.nextLine(); // Consume the newline

                                                if (hackChoice <= 0) {
                                                    System.out.println("Choice must be greater than 0.");
                                                    continue;
                                                }

                                                break;
                                            } catch (Exception e) {
                                                System.out.println("Invalid input! Please enter a valid integer.");
                                                sc.nextLine(); // Clear the invalid input
                                            }
                                        }

                                        switch (hackChoice) {

                                            case 1:
                                                hackathon.viewHackathon();
                                                break;

                                            case 2:
                                                hackathon.searchHackathon();
                                                break;

                                            case 3:
                                                team.createTeam(userEmail);
                                                break;

                                            case 4:
                                                team.joinTeam(userEmail);
                                                break;

                                            case 5:
                                                team.leaveTeam(userEmail);
                                                break;

                                            case 6:
                                                team.viewTeam();
                                                break;

                                            case 7:
                                                team.viewTeamMembers();
                                                break;

                                            case 8:
                                                registration.registerHackathon(userEmail);
                                                break;

                                            case 9:
                                                Watchlist a = new Watchlist();
                                                a.menu(userId);
                                                break;

                                            case 10:
                                                int hackathonId;

                                                while (true) {
                                                    try {
                                                        System.out.print("Enter Hackathon ID to Cancel: ");
                                                        hackathonId = sc.nextInt();
                                                        sc.nextLine(); // Consume the newline

                                                        if (hackathonId <= 0) {
                                                            System.out.println("Hackathon ID must be greater than 0.");
                                                            continue;
                                                        }

                                                        break;
                                                    } catch (Exception e) {
                                                        System.out.println("Invalid input! Please enter a valid integer.");
                                                        sc.nextLine(); // Clear the invalid input
                                                    }
                                                }

                                                String sql7 =
                                                        "UPDATE registration SET status='CANCELLED' WHERE user_id=? AND hackathon_id=?";

                                                PreparedStatement ps = con.prepareStatement(sql7);

                                                ps.setInt(1, userId);
                                                ps.setInt(2, hackathonId);

                                                int rows = ps.executeUpdate();

                                                if (rows > 0) {
                                                    System.out.println("Registration Cancelled Successfully.");
                                                } else {
                                                    System.out.println("No Registration Found.");
                                                }
                                                break;

                                            case 11:
                                                TeamLeaderboard leaderboard = new TeamLeaderboard();
                                                leaderboard.showLeaderboard();
                                                break;

                                            case 12:
                                                SearchHistory h = new SearchHistory();
                                                h.displayHistory();
                                                break;

                                            case 13:
                                                SearchHistory h2 = new SearchHistory();
                                                h2.clearHistory();
                                                break;

                                            case 14:
                                                System.out.println("Returning...");
                                                break;

                                            default:
                                                System.out.println("Invalid Choice!");
                                        }

                                    } while (hackChoice != 14);

                                    break;

                                case 3:

                                    int recChoice;

                                    do {

                                        System.out.println("\n========== RECOMMENDATIONS ==========");
                                        System.out.println("1. Recommended Best Hackathons");
                                        System.out.println("2. Recommended Roadmap");
                                        System.out.println("3. Project Ideas / AI Chatbot");
                                        System.out.println("4. Recommended Join Team");
                                        System.out.println("5. Exit");
                                        while (true) {
                                            try {
                                                System.out.print("Enter Choice: ");
                                                recChoice = sc.nextInt();
                                                sc.nextLine(); // Consume the newline

                                                if (recChoice <= 0) {
                                                    System.out.println("Choice must be greater than 0.");
                                                    continue;
                                                }

                                                break;
                                            } catch (Exception e) {
                                                System.out.println("Invalid input! Please enter a valid integer.");
                                                sc.nextLine(); // Clear the invalid input
                                            }
                                        }

                                        switch (recChoice) {

                                            case 1:
                                                recommendation_for_Best_hackthone a = new recommendation_for_Best_hackthone();
                                                a.displayRecommendation(userId);
                                                break;

                                            case 2:
                                                Recommendation a1 = new Recommendation();
                                                a1.buildRecommendationPrompt(userId);
                                                break;

                                            case 3:
                                                Recommendation_project_idea a2 = new Recommendation_project_idea();
                                                a2.chat();
                                                break;

                                            case 4:
                                                Recommendation_To_Join_team a3 = new Recommendation_To_Join_team();
                                                a3.recommendTeams(userId);
                                                break;

                                            case 5:
                                                System.out.println("Returning...");
                                                break;

                                            default:
                                                System.out.println("Invalid Choice!");
                                        }

                                    } while (recChoice != 5);

                                    break;

                                case 4:
                                    hackathon.filterHackathons();
                                    break;

                                case 5:
                                    System.out.println("Logged Out Successfully!");
                                    break;

                                default:
                                    System.out.println("Invalid Choice!");
                            }

                        } while (userChoice != 5);

                    } else {
                        System.out.println("Login Failed!");
                    }

                    break;

                case 3:
                    System.out.println("Thank You!");
                    break;

                default:
                    System.out.println("Invalid Choice!");
            }

        } while (choice != 3);

//        sc.close();
    }
}
