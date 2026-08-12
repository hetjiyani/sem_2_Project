import java.sql.*;
import java.util.Scanner;

public class organization {

    Scanner sc = new Scanner(System.in);
    Connection con;

    public organization() throws Exception {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    // ===================== MAIN MENU =====================
    public void menu() throws Exception {

        while (true) {

            System.out.println("\n========== ORGANIZATION ==========");
            System.out.println("1. Register");
            System.out.println("2. Login");
            System.out.println("3. Exit");
            int ch;

            while (true) {
                try {
                    System.out.print("Enter Choice : ");
                    ch = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (ch <= 0) {
                        System.out.println("Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            switch (ch) {

                case 1:
                    registerOrganization();
                    break;

                case 2:

                    int id = loginOrganization();

                    if (id != -1)
                        organizationMenu(id);

                    break;

                case 3:
                    return;

                default:
                    System.out.println("Invalid Choice.");
            }

        }

    }

    // ===================== REGISTER =====================
    public void registerOrganization() throws SQLException {

        System.out.println("\n========== Organization Registration ==========\n");


        System.out.print("Enter Organization Name : ");
        String organizationName = sc.nextLine();


        String email="";

        while (true) {
            System.out.print("Enter Organization Email: ");
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

        System.out.print("Enter Contact Person Name : ");
        String contactPerson = sc.nextLine();

        long phone;

        while (true) {
            System.out.print("Enter Phone Number: ");

            if (sc.hasNextLong()) {
                phone = sc.nextLong();

                if (phone >= 1000000000L && phone <= 9999999999L) {
                    sc.nextLine();
                    break;
                } else {
                    System.out.println("Invalid phone number! Please enter exactly 10 digits.");
                }
            } else {
                System.out.println("Invalid input! Enter digits only.");
                sc.next(); // Clear invalid input
            }
        }

        System.out.print("Enter Website : ");
        String website = sc.nextLine();

        System.out.println("\nOrganization Types:");
        System.out.println("1. Company");
        System.out.println("2. College");
        System.out.println("3. University");
        System.out.println("4. Startup");
        System.out.println("5. Community");
        System.out.println("6. NGO");
        int choice;

        while (true) {
            try {
                System.out.print("Select Type : ");
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

        String organizationType = "";

        switch (choice) {
            case 1:
                organizationType = "Company";
                break;
            case 2:
                organizationType = "College";
                break;
            case 3:
                organizationType = "University";
                break;
            case 4:
                organizationType = "Startup";
                break;
            case 5:
                organizationType = "Community";
                break;
            case 6:
                organizationType = "NGO";
                break;
            default:
                organizationType = "Other";
        }

        System.out.print("Enter City : ");
        String city = sc.nextLine();

        String check = "SELECT * FROM organization WHERE email=?";

        PreparedStatement pst = con.prepareStatement(check);
        pst.setString(1, email);

        ResultSet rs = pst.executeQuery();

        if (rs.next()) {

            System.out.println("An organization with this email is already registered.");

            rs.close();
            pst.close();
            return;
        }

        rs.close();
        pst.close();

        String sql = "INSERT INTO organization(" +
                "organization_name," +
                "email," +
                "password," +
                "contact_person," +
                "phone," +
                "website," +
                "organization_type," +
                "city) VALUES(?,?,?,?,?,?,?,?)";

        PreparedStatement pst1 = con.prepareStatement(sql);

        pst1.setString(1, organizationName);
        pst1.setString(2, email);
        pst1.setString(3, password);
        pst1.setString(4, contactPerson);
        pst1.setString(5, phone+"");
        pst1.setString(6, website);
        pst1.setString(7, organizationType);
        pst1.setString(8, city);

        pst1.executeUpdate();

        System.out.println("\nOrganization Registered Successfully!");
        pst1.close();
    }

    // ===================== LOGIN =====================
    public int loginOrganization() throws SQLException {

        System.out.print("Enter Organization Email : ");
        String email = sc.next();

        System.out.print("Enter Password : ");
        String password = sc.next();

        String sql =
                "SELECT organization_id FROM organization WHERE email=? AND password=?";

        PreparedStatement pst = con.prepareStatement(sql);

        pst.setString(1, email);
        pst.setString(2, password);

        ResultSet rs = pst.executeQuery();

        if (rs.next()) {

            System.out.println("Login Successful.");
            int id = rs.getInt("organization_id");

            rs.close();
            pst.close();

            return id;

        }

        rs.close();
        pst.close();

        System.out.println("Invalid Email or Password.");
        System.out.println("Please Register First.");

        return -1;

    }

    // ===================== ORGANIZATION MENU =====================
    public void organizationMenu(int organizationId) throws Exception {

        Hackathon h = new Hackathon();

        while (true) {

            System.out.println("\n========== ORGANIZATION PANEL ==========");
            System.out.println("1. Add Hackathon");
            System.out.println("2. Delete Hackathon");
            System.out.println("3. View My Hackathons");
            System.out.println("4. Logout");
            int ch;

            while (true) {
                try {
                    System.out.print("Enter Choice : ");
                    ch = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (ch <= 0) {
                        System.out.println("Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            switch (ch) {

                case 1:
                    h.addHackathon(organizationId);
                    break;

                case 2:
                    h.deleteHackathon(organizationId);
                    break;

                case 3:
                    h.viewHackathon(organizationId);
                    break;

                case 4:
                    System.out.println("Logged Out Successfully.");
                    return;

                default:
                    System.out.println("Invalid Choice.");

            }

        }

    }

}