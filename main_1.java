import java.util.Scanner;

public class main_1 {

    public static void main(String[] args) throws Exception {

        Scanner sc = new Scanner(System.in);

        while (true) {

            System.out.println("\n==================================");
            System.out.println("   HACKATHON DISCOVERY PLATFORM");
            System.out.println("==================================");
            System.out.println("1. User");
            System.out.println("2. Organization");
            System.out.println("3. Admin");
            System.out.println("4. Exit");
//            System.out.print("Enter Choice : ");

            int choice;

            while (true) {
                try {
                    System.out.print("Enter choice: ");
                    choice = sc.nextInt();
                    sc.nextLine(); // Consume the newline
                    break;
                } catch (java.util.InputMismatchException e) {
                    System.out.println("Invalid input! Please enter an integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            switch (choice) {

                case 1:

                    MainApp a = new MainApp();
                    a.main_user();
                    break;

                case 2:

                    organization org = new organization();
                    org.menu();
                    break;

                case 3:

                    admin admin = new admin();
                    admin.login();
                    break;

                case 4:

                    System.out.println("Thank You!");
                    return;

                default:

                    System.out.println("Invalid Choice.");

            }
        }
    }
}