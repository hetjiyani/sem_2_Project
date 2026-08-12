import java.sql.*;
import java.util.ArrayList;
import java.util.Scanner;

public class User {

    String name;
    String email;
    String password;
    String city;

    Scanner sc = new Scanner(System.in);
    private int skillId;

    // ==========================================================
    // Register User
    // ==========================================================
    String registerUser() {

        System.out.println("\n===== User Registration =====");

        System.out.print("Enter Name: ");
        name = sc.nextLine();

        String email;

        while (true) {
            System.out.print("Enter Email: ");
            email = sc.nextLine().trim();

            if (email.contains("@") && email.endsWith("@gmail.com")) {
                break;
            } else {
                System.out.println("Please enter a valid Gmail address.");
            }
        }

        String password;

        while (true) {
            System.out.print("Enter Password: ");
            password = sc.nextLine();

            boolean upper = false;
            boolean lower = false;
            boolean digit = false;
            boolean special = false;

            if (password.length() < 8) {
                System.out.println("Password must be at least 8 characters long.");
                continue;
            }

            for (char ch : password.toCharArray()) {

                if (Character.isUpperCase(ch))
                    upper = true;
                else if (Character.isLowerCase(ch))
                    lower = true;
                else if (Character.isDigit(ch))
                    digit = true;
                else
                    special = true;
            }

            if (upper && lower && digit && special) {
                break;
            } else {
                System.out.println("Password must contain:");
                if (!upper) System.out.println("- At least one uppercase letter");
                if (!lower) System.out.println("- At least one lowercase letter");
                if (!digit) System.out.println("- At least one digit");
                if (!special) System.out.println("- At least one special character");
            }
        }

        System.out.print("Enter City: ");
        city = sc.nextLine();

        int age;

        while (true) {
            try {
                System.out.print("Enter Age: ");
                age = sc.nextInt();
                sc.nextLine();

                if (age <= 0) {
                    System.out.println(" Age must be greater than 0.");
                    continue;
                }

                break;
            } catch (Exception e) {
                System.out.println(" Invalid input! Please enter a numeric age.");
                sc.nextLine(); // Clear invalid input
            }
        }

        if (age < 18) {
            System.out.println("Sorry, you are not eligible to register. Minimum age required is 18.");
            return null;
        }

        try {
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hackthone", "root", "");

            String query = "INSERT INTO users(name, email, password_hash, city) VALUES (?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(query);

            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, password);
            ps.setString(4, city);

            ps.executeUpdate();
            int id=0;
            String sql = "SELECT user_id FROM users WHERE email = ?";

            PreparedStatement psq = con.prepareStatement(sql);
            psq.setString(1, email);

            ResultSet rs = psq.executeQuery();

            if (rs.next()) {
                id = rs.getInt("user_id");
            }
            int skillChoice = 1;

            do {
                addSkill(id);

                System.out.println("\n1. Add Another Skill");
                System.out.println("2. Finish Adding Skills");

                while (true) {
                    try {
                        System.out.print("Enter Choice: ");
                        skillChoice = sc.nextInt();
                        sc.nextLine();

                        if (skillChoice <= 0) {
                            System.out.println(" Choice must be greater than 0.");
                            continue;
                        }

                        break;
                    } catch (Exception e) {
                        System.out.println(" Invalid input! Please enter a numeric choice.");
                        sc.nextLine(); // Clear invalid input
                    }
                }

            } while (skillChoice == 1);

            int interestChoice = 1;

            do {
                addInterest(email);

                System.out.println("\n1. Add Another Interest");
                System.out.println("2. Finish Adding Interests");

                while (true) {
                    try {
                        System.out.print("Enter Choice: ");
                        interestChoice = sc.nextInt();
                        sc.nextLine();

                        if (interestChoice <= 0) {
                            System.out.println(" Choice must be greater than 0.");
                            continue;
                        }

                        break;
                    } catch (Exception e) {
                        System.out.println(" Invalid input! Please enter a numeric choice.");
                        sc.nextLine(); // Clear invalid input
                    }
                }

            } while (interestChoice == 1);

            System.out.println("User Registered Successfully!");

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
        return email;
    }

    // ==========================================================
    // User Login
    // ==========================================================
    public boolean loginUser(String loginEmail, String loginPassword) {

        email = loginEmail;
        password = loginPassword;
        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            String sql = "SELECT * FROM users WHERE email=? AND password_hash=?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setString(1, loginEmail);
            pst.setString(2, loginPassword);

            ResultSet rs = pst.executeQuery();

            if (rs.next()) {

                System.out.println("Login Successful.");

                rs.close();
                pst.close();
                con.close();

                return true;
            } else {

                System.out.println("Invalid Email or Password.");

                rs.close();
                pst.close();
                con.close();

                return false;
            }

        } catch (Exception e) {

            System.out.println(e);
            return false;

        }

    }

    // ==========================================================
    // Edit Profile
    // ==========================================================
    public void editProfile() {

        try {
            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hackthone", "root", "");

            System.out.println("\n===== Edit Profile =====");
            System.out.println("1. Change City");
            System.out.println("2. Change Password");
            System.out.println("3. Add Skill");
            System.out.println("4. Remove Skill");
            System.out.println("5. Add Interest");
            System.out.println("6. Remove Interest");
            int choice;

            while (true) {
                try {
                    System.out.print("Enter Choice: ");
                    choice = sc.nextInt();
                    sc.nextLine();

                    if (choice <= 0) {
                        System.out.println(" Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric choice.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            switch (choice) {

                case 1:

                    System.out.print("Enter New City: ");
                    city = sc.nextLine();

                    String cityQuery = "UPDATE users SET city=? WHERE email=?";

                    PreparedStatement cityPs = con.prepareStatement(cityQuery);

                    cityPs.setString(1, city);
                    cityPs.setString(2, email);

                    cityPs.executeUpdate();

                    System.out.println("City Updated Successfully!");
                    break;

                case 2:

                    while (true) {
                        System.out.print("Enter new Password: ");
                        password = sc.nextLine();

                        boolean upper = false;
                        boolean lower = false;
                        boolean digit = false;
                        boolean special = false;

                        if (password.length() < 8) {
                            System.out.println("Password must be at least 8 characters long.");
                            continue;
                        }

                        for (char ch : password.toCharArray()) {

                            if (Character.isUpperCase(ch))
                                upper = true;
                            else if (Character.isLowerCase(ch))
                                lower = true;
                            else if (Character.isDigit(ch))
                                digit = true;
                            else
                                special = true;
                        }

                        if (upper && lower && digit && special) {
                            break;
                        } else {
                            System.out.println("Password must contain:");
                            if (!upper) System.out.println("- At least one uppercase letter");
                            if (!lower) System.out.println("- At least one lowercase letter");
                            if (!digit) System.out.println("- At least one digit");
                            if (!special) System.out.println("- At least one special character");
                        }
                    }

                    String passQuery = "UPDATE users SET password_hash=? WHERE email=?";

                    PreparedStatement passPs = con.prepareStatement(passQuery);

                    passPs.setString(1, password);
                    passPs.setString(2, email);

                    passPs.executeUpdate();

                    System.out.println("Password Updated Successfully!");
                    break;

                case 3:
                    String sql = "SELECT user_id FROM users WHERE email = ?";

                    PreparedStatement ps = con.prepareStatement(sql);
                    ps.setString(1, email);

                    ResultSet rs = ps.executeQuery();
                    int id=0;
                    if (rs.next()) {
                        id = rs.getInt("user_id");
                    }
                    addSkill(id);
                    break;

                case 4:
                    removeSkill();
                    break;

                case 5:
                    addInterest(email);
                    break;

                case 6:
                    removeInterest();
                    break;

                default:
                    System.out.println("Invalid Choice.");
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Add Skill
    // ==========================================================
    public void addSkill(int userId) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            ArrayList<Integer> skillIds = new ArrayList<>();
            ArrayList<String> skillNames = new ArrayList<>();

            String allSkillsQuery = "SELECT skill_id, skill_name FROM skills ORDER BY skill_name";
            PreparedStatement allSkillsPs = con.prepareStatement(allSkillsQuery);
            ResultSet allSkillsRs = allSkillsPs.executeQuery();

            System.out.println("\n===== Available Skills =====");
            int index = 1;

            while (allSkillsRs.next()) {
                int id = allSkillsRs.getInt("skill_id");
                String nm = allSkillsRs.getString("skill_name");

                skillIds.add(id);
                skillNames.add(nm);

                System.out.println(index + ". " + nm);
                index++;
            }

            allSkillsRs.close();
            allSkillsPs.close();

            if (skillIds.isEmpty()) {
                System.out.println("No skills available in the system yet.");
                con.close();
                return;
            }

            int choice;

            while (true) {
                try {
                    System.out.print("Select Skill (Enter number): ");
                    choice = sc.nextInt();
                    sc.nextLine();

                    if (choice <= 0) {
                        System.out.println(" Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric choice.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            if (choice < 1 || choice > skillIds.size()) {
                System.out.println("Invalid Choice!");
                con.close();
                return;
            }

            int skillId = skillIds.get(choice - 1);
            String skill = skillNames.get(choice - 1);



            String checkUserSkill = "SELECT * FROM userskills WHERE user_id=? AND skill_id=?";

            PreparedStatement checkPs = con.prepareStatement(checkUserSkill);
            checkPs.setInt(1, userId);
            checkPs.setInt(2, skillId);

            ResultSet checkRs = checkPs.executeQuery();

            if (checkRs.next()) {

                System.out.println("Skill Already Exists!");

            } else {

                String userSkillQuery =
                        "INSERT INTO userskills(user_id, skill_id, proficiency_level) VALUES(?,?,?)";

                PreparedStatement userSkillPs = con.prepareStatement(userSkillQuery);
                userSkillPs.setInt(1, userId);
                userSkillPs.setInt(2, skillId);
                userSkillPs.setString(3, "Beginner");

                userSkillPs.executeUpdate();

                System.out.println("Skill '" + skill + "' Added Successfully!");
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Remove Skill
    // ==========================================================
    public void removeSkill() {

        try {

            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hackthone", "root", "");

            ArrayList<Integer> skillIds = new ArrayList<>();
            ArrayList<String> skillNames = new ArrayList<>();

            String query =
                    "SELECT s.skill_id, s.skill_name " +
                            "FROM userskills us " +
                            "JOIN skills s ON us.skill_id = s.skill_id " +
                            "JOIN users u ON us.user_id = u.user_id " +
                            "WHERE u.email=?";

            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            System.out.println("\n===== Your Skills =====");
            int index = 1;

            while (rs.next()) {
                skillIds.add(rs.getInt("skill_id"));
                skillNames.add(rs.getString("skill_name"));
                System.out.println(index + ". " + rs.getString("skill_name"));
                index++;
            }

            rs.close();
            ps.close();

            if (skillIds.isEmpty()) {
                System.out.println("You have no skills added.");
                con.close();
                return;
            }

            int choice;

            while (true) {
                try {
                    System.out.print("Select Skill to Remove (Enter number): ");
                    choice = sc.nextInt();
                    sc.nextLine();

                    if (choice <= 0) {
                        System.out.println(" Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric choice.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            if (choice < 1 || choice > skillIds.size()) {
                System.out.println("Invalid Choice!");
                con.close();
                return;
            }

            int skillId = skillIds.get(choice - 1);

            PreparedStatement userPs = con.prepareStatement("SELECT user_id FROM users WHERE email=?");
            userPs.setString(1, email);

            ResultSet userRs = userPs.executeQuery();

            int userId = 0;

            if (userRs.next()) {
                userId = userRs.getInt("user_id");
            }

            PreparedStatement deletePs =
                    con.prepareStatement("DELETE FROM userskills WHERE user_id=? AND skill_id=?");

            deletePs.setInt(1, userId);
            deletePs.setInt(2, skillId);

            int rows = deletePs.executeUpdate();

            if (rows > 0) {
                System.out.println("Skill Removed Successfully!");
            } else {
                System.out.println("Skill Not Found!");
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Add Interest
    // ==========================================================
    public void addInterest(String email) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            ArrayList<Integer> interestIds = new ArrayList<>();
            ArrayList<String> interestNames = new ArrayList<>();

            String allInterestsQuery = "SELECT skill_id, skill_name FROM skills ORDER BY skill_name";
            PreparedStatement allInterestsPs = con.prepareStatement(allInterestsQuery);
            ResultSet allInterestsRs = allInterestsPs.executeQuery();

            System.out.println("\n===== Available Domains / Interests =====");
            int index = 1;

            while (allInterestsRs.next()) {
                int id = allInterestsRs.getInt("skill_id");
                String nm = allInterestsRs.getString("skill_name");

                interestIds.add(id);
                interestNames.add(nm);

                System.out.println(index + ". " + nm);
                index++;
            }

            allInterestsRs.close();
            allInterestsPs.close();

            if (interestIds.isEmpty()) {
                System.out.println("No domains/interests available in the system yet.");
                con.close();
                return;
            }

            int choice;

            while (true) {
                try {
                    System.out.print("Select Interest (Enter number): ");
                    choice = sc.nextInt();
                    sc.nextLine();

                    if (choice <= 0) {
                        System.out.println(" Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric choice.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            if (choice < 1 || choice > interestIds.size()) {
                System.out.println("Invalid Choice!");
                con.close();
                return;
            }

            int interestId = interestIds.get(choice - 1);
            String interestName = interestNames.get(choice - 1);

            int userId = 0;

            String userQuery = "SELECT user_id FROM users WHERE email = ?";
            PreparedStatement userPs = con.prepareStatement(userQuery);
            userPs.setString(1, email);

            ResultSet userRs = userPs.executeQuery();

            if (userRs.next()) {
                userId = userRs.getInt("user_id");
            } else {
                System.out.println("User Not Found!");
                con.close();
                return;
            }

            String checkQuery = "SELECT * FROM userinterests WHERE user_id=? AND interest_id=?";

            PreparedStatement checkPs = con.prepareStatement(checkQuery);
            checkPs.setInt(1, userId);
            checkPs.setInt(2, interestId);

            ResultSet checkRs = checkPs.executeQuery();

            if (checkRs.next()) {

                System.out.println("Interest Already Added!");

            } else {

                String insertQuery = "INSERT INTO userinterests(user_id, interest_id) VALUES(?,?)";

                PreparedStatement insertPs = con.prepareStatement(insertQuery);
                insertPs.setInt(1, userId);
                insertPs.setInt(2, interestId);

                insertPs.executeUpdate();

                System.out.println("Interest '" + interestName + "' Added Successfully!");
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Remove Interest
    // ==========================================================
    public void removeInterest() {

        try {

            Connection con = DriverManager.getConnection("jdbc:mysql://localhost:3306/hackthone", "root", "");

            ArrayList<Integer> interestIds = new ArrayList<>();
            ArrayList<String> interestNames = new ArrayList<>();

            String query =
                    "SELECT s.skill_id, s.skill_name " +
                            "FROM userinterests ui " +
                            "JOIN skills s ON ui.interest_id = s.skill_id " +
                            "JOIN users u ON ui.user_id = u.user_id " +
                            "WHERE u.email=?";

            PreparedStatement ps = con.prepareStatement(query);
            ps.setString(1, email);

            ResultSet rs = ps.executeQuery();

            System.out.println("\n===== Your Interests =====");
            int index = 1;

            while (rs.next()) {
                interestIds.add(rs.getInt("skill_id"));
                interestNames.add(rs.getString("skill_name"));
                System.out.println(index + ". " + rs.getString("skill_name"));
                index++;
            }

            rs.close();
            ps.close();

            if (interestIds.isEmpty()) {
                System.out.println("You have no interests added.");
                con.close();
                return;
            }

            int choice;

            while (true) {
                try {
                    System.out.print("Select Interest to Remove (Enter number): ");
                    choice = sc.nextInt();
                    sc.nextLine();

                    if (choice <= 0) {
                        System.out.println(" Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println(" Invalid input! Please enter a numeric choice.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            if (choice < 1 || choice > interestIds.size()) {
                System.out.println("Invalid Choice!");
                con.close();
                return;
            }

            int interestId = interestIds.get(choice - 1);

            PreparedStatement userPs = con.prepareStatement("SELECT user_id FROM users WHERE email=?");
            userPs.setString(1, email);

            ResultSet userRs = userPs.executeQuery();

            int userId = 0;

            if (userRs.next()) {
                userId = userRs.getInt("user_id");
            }

            PreparedStatement deletePs =
                    con.prepareStatement("DELETE FROM userinterests WHERE user_id=? AND interest_id=?");

            deletePs.setInt(1, userId);
            deletePs.setInt(2, interestId);

            int rows = deletePs.executeUpdate();

            if (rows > 0) {
                System.out.println("Interest Removed Successfully!");
            } else {
                System.out.println("Interest Not Found!");
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // View Profile
    // ==========================================================
    public void viewProfile() {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    ""
            );

            String userQuery = "SELECT * FROM users WHERE email=?";

            PreparedStatement userPs = con.prepareStatement(userQuery);
            userPs.setString(1, email);

            ResultSet userRs = userPs.executeQuery();

            if (!userRs.next()) {
                System.out.println("User Not Found!");
                con.close();
                return;
            }

            int userId = userRs.getInt("user_id");

            System.out.println("\n===== User Profile =====");
            System.out.println("Name      : " + userRs.getString("name"));
            System.out.println("Email     : " + userRs.getString("email"));
            System.out.println("City      : " + userRs.getString("city"));

            System.out.print("Skills    : ");

            String skillQuery =
                    "SELECT s.skill_name " +
                            "FROM userskills us " +
                            "JOIN skills s ON us.skill_id = s.skill_id " +
                            "WHERE us.user_id=?";

            PreparedStatement skillPs = con.prepareStatement(skillQuery);
            skillPs.setInt(1, userId);

            ResultSet skillRs = skillPs.executeQuery();

            boolean found = false;

            while (skillRs.next()) {
                found = true;
                System.out.print(skillRs.getString("skill_name") + "  ");
            }

            if (!found) {
                System.out.print("No Skills Added");
            }

            System.out.println();

            System.out.print("Interests : ");

            String interestQuery =
                    "SELECT s.skill_name " +
                            "FROM userinterests ui " +
                            "JOIN skills s ON ui.interest_id = s.skill_id " +
                            "WHERE ui.user_id=?";

            PreparedStatement interestPs = con.prepareStatement(interestQuery);
            interestPs.setInt(1, userId);

            ResultSet interestRs = interestPs.executeQuery();

            boolean foundInterest = false;

            while (interestRs.next()) {
                foundInterest = true;
                System.out.print(interestRs.getString("skill_name") + "  ");
            }

            if (!foundInterest) {
                System.out.print("No Interests Added");
            }

            System.out.println();

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    public String getEmail() {
        return email;
    }

}