import java.sql.*;
import java.util.Scanner;

public class Registration {

    Scanner sc = new Scanner(System.in);

    public void registerHackathon(String userEmail) {

        try (Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "")) {

            int userId = 0;
            String userQuery = "SELECT user_id FROM users WHERE email=?";

            try (PreparedStatement userPs = con.prepareStatement(userQuery)) {
                userPs.setString(1, userEmail);

                try (ResultSet userRs = userPs.executeQuery()) {
                    if (userRs.next()) {
                        userId = userRs.getInt("user_id");
                    } else {
                        System.out.println("User Not Found!");
                        return;
                    }
                }
            }

            String hackQuery =
                    "SELECT hackathon_id, title, mode, location_city, prize_pool, " +
                            "current_participants, max_participants " +
                            "FROM hackathons";

            try (PreparedStatement hackPs = con.prepareStatement(hackQuery);
                 ResultSet hackRs = hackPs.executeQuery()) {

                boolean anyHackathon = false;

                System.out.println();
                System.out.println("╔═════╦══════════════════════════════╦══════════╦══════════════╦════════════╦════════════╗");
                System.out.println("║ ID  ║ TITLE                        ║ MODE     ║ CITY         ║ PRIZE      ║ SEATS      ║");
                System.out.println("╠═════╬══════════════════════════════╬══════════╬══════════════╬════════════╬════════════╣");

                while (hackRs.next()) {

                    anyHackathon = true;

                    String seats =
                            hackRs.getInt("current_participants")
                                    + "/"
                                    + hackRs.getInt("max_participants");

                    System.out.printf(
                            "║ %-3d ║ %-28.28s ║ %-8.8s ║ %-12.12s ║ %-10.0f ║ %-10s ║%n",
                            hackRs.getInt("hackathon_id"),
                            hackRs.getString("title"),
                            hackRs.getString("mode"),
                            hackRs.getString("location_city"),
                            hackRs.getDouble("prize_pool"),
                            seats
                    );
                }

                System.out.println("╚═════╩══════════════════════════════╩══════════╩══════════════╩════════════╩════════════╝");                if (!anyHackathon) {
                    System.out.println("No Hackathons Available.");
                    return;
                }
            }
            int hackathonId;

            while (true) {
                try {
                    System.out.print("\nEnter Hackathon ID: ");
                    hackathonId = sc.nextInt();
                    sc.nextLine();

                    if (hackathonId <= 0) {
                        System.out.println("❌ Hackathon ID must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("❌ Invalid input! Please enter a numeric Hackathon ID.");
                    sc.nextLine(); // Clear invalid input
                }
            }

            String checkQuery =
                    "SELECT * FROM registration WHERE user_id=? AND hackathon_id=?";

            try (PreparedStatement checkPs = con.prepareStatement(checkQuery)) {
                checkPs.setInt(1, userId);
                checkPs.setInt(2, hackathonId);

                try (ResultSet checkRs = checkPs.executeQuery()) {
                    if (checkRs.next()) {
                        System.out.println("You are already registered!");
                        return;
                    }
                }
            }

            int current = 0;
            int max = 0;
            boolean hackathonExists = false;

            String capacityQuery =
                    "SELECT current_participants, max_participants FROM hackathons WHERE hackathon_id=?";

            try (PreparedStatement capPs = con.prepareStatement(capacityQuery)) {
                capPs.setInt(1, hackathonId);

                try (ResultSet capRs = capPs.executeQuery()) {
                    if (capRs.next()) {
                        hackathonExists = true;
                        current = capRs.getInt("current_participants");
                        max = capRs.getInt("max_participants");
                    }
                }
            }

            if (!hackathonExists) {
                System.out.println("Invalid Hackathon ID!");
                return;
            }

            String status;
            int waitlistPosition = 0;

            if (current < max) {

                status = "Registered";

                String updateQuery =
                        "UPDATE hackathons SET current_participants=current_participants+1 WHERE hackathon_id=?";

                try (PreparedStatement updatePs = con.prepareStatement(updateQuery)) {
                    updatePs.setInt(1, hackathonId);
                    updatePs.executeUpdate();
                }

            } else {

                status = "Waitlisted";

                String waitQuery =
                        "SELECT COUNT(*) FROM registration WHERE hackathon_id=? AND status='Waitlisted'";

                try (PreparedStatement waitPs = con.prepareStatement(waitQuery)) {
                    waitPs.setInt(1, hackathonId);

                    try (ResultSet waitRs = waitPs.executeQuery()) {
                        if (waitRs.next()) {
                            waitlistPosition = waitRs.getInt(1) + 1;
                        }
                    }
                }
            }

            String registerQuery =
                    "INSERT INTO registration(user_id,hackathon_id,status,waitlist_position) VALUES(?,?,?,?)";

            try (PreparedStatement registerPs = con.prepareStatement(registerQuery)) {
                registerPs.setInt(1, userId);
                registerPs.setInt(2, hackathonId);
                registerPs.setString(3, status);

                if (status.equals("Registered")) {
                    registerPs.setNull(4, Types.INTEGER);
                } else {
                    registerPs.setInt(4, waitlistPosition);
                }

                registerPs.executeUpdate();
            }

            if (status.equals("Registered")) {
                mail_for_joining m = new mail_for_joining();
                m.mail_join(userId, hackathonId);
                System.out.println("Hackathon Registration Successful!");
            } else {
                System.out.println("Hackathon Full!");
                System.out.println("You are Waitlisted.");
                System.out.println("Waitlist Position : " + waitlistPosition);
            }

        } catch (Exception e) {
            System.out.println(e);
        }
    }
}