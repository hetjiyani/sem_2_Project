import java.util.Scanner;

public class admin {

    Scanner sc = new Scanner(System.in);

    private final String ADMIN_USERNAME = "admin";
    private final String ADMIN_PASSWORD = "admin123";

    // ================= LOGIN =================
    public void login() throws Exception {

        System.out.println("\n========== ADMIN LOGIN ==========");

        System.out.print("Enter Username : ");
        String username = sc.next();

        System.out.print("Enter Password : ");
        String password = sc.next();

        if (username.equals(ADMIN_USERNAME) && password.equals(ADMIN_PASSWORD)) {

            System.out.println("\nLogin Successful.");
            menu();

        } else {

            System.out.println("\nInvalid Username or Password.");

        }
    }

    // ================= ADMIN MENU =================
    public void menu() throws Exception {

        while (true) {

            System.out.println("\n========== ADMIN PANEL ==========");
            System.out.println("1. User Management");
            System.out.println("2. Organization Management");
            System.out.println("3. Hackathon Management");
            System.out.println("4. Registration Management");
            System.out.println("5. Team Management");
            System.out.println("6. Statistics");
            System.out.println("7. Logout");
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

                    AdminUser user = new AdminUser();
                    user.menu();
                    break;

                case 2:

                    AdminOrganization organization = new AdminOrganization();
                    organization.menu();
                    break;

                case 3:

                    AdminHackathon hackathon = new AdminHackathon();
                    hackathon.menu();
                    break;

                case 4:

                    AdminRegistration registration = new AdminRegistration();
                    registration.menu();
                    break;

                case 5:

                    AdminTeam team = new AdminTeam();
                    team.menu();
                    break;

                case 6:

                    AdminStatistics statistics = new AdminStatistics();
                    statistics.menu();
                    break;

                case 7:

                    System.out.println("Logged Out Successfully.");
                    return;

                default:

                    System.out.println("Invalid Choice.");
            }
        }
    }
}