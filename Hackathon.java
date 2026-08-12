import java.sql.*;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

public class Hackathon {
    Scanner sc = new Scanner(System.in);
    private String title;
    private String locationCity;
    private String mode;
    private double prizePool;
    private Date startDate;
    private Date endDate;
    private Date registrationDeadline;
    private int maxParticipants;
    private int currentParticipants = 0;

    // ==========================================================
    // Add New Hackathon (for Organization)
    // ==========================================================
    public void addHackathon(int organizationId) {

        System.out.println("\n===== Add Hackathon =====");


// Title
        while (true) {
            System.out.print("Enter Title: ");
            title = sc.nextLine().trim();

            if (!title.isEmpty())
                break;

            System.out.println("Title cannot be empty.");
        }

// Location City
        while (true) {
            System.out.print("Enter Location City: ");
            locationCity = sc.nextLine().trim();

            if (!locationCity.isEmpty())
                break;

            System.out.println("Location City cannot be empty.");
        }

// Mode
        while (true) {
            System.out.print("Enter Mode (Online/Offline/Hybrid): ");
            mode = sc.nextLine().trim();

            if (mode.equalsIgnoreCase("Online") ||
                    mode.equalsIgnoreCase("Offline") ||
                    mode.equalsIgnoreCase("Hybrid")) {
                break;
            }

            System.out.println("Invalid mode! Enter Online, Offline or Hybrid.");
        }

// Prize Pool
        while (true) {
            try {
                System.out.print("Enter Prize Pool: ");
                prizePool = sc.nextDouble();
                sc.nextLine();

                if (prizePool >= 0)
                    break;

                System.out.println("Prize Pool cannot be negative.");
            } catch (Exception e) {
                System.out.println("Invalid Prize Pool.");
                sc.nextLine();
            }
        }

// Start Date
        while (true) {
            try {
                System.out.print("Enter Start Date (yyyy-mm-dd): ");
                startDate = Date.valueOf(LocalDate.parse(sc.nextLine()));
                break;
            } catch (Exception e) {
                System.out.println("Invalid date format. Use yyyy-mm-dd.");
            }
        }

// End Date
        while (true) {
            try {
                System.out.print("Enter End Date (yyyy-mm-dd): ");
                endDate = Date.valueOf(LocalDate.parse(sc.nextLine()));

                if (!endDate.before(startDate))
                    break;

                System.out.println("End Date cannot be before Start Date.");
            } catch (Exception e) {
                System.out.println("Invalid date format. Use yyyy-mm-dd.");
            }
        }

// Registration Deadline
        while (true) {
            try {
                System.out.print("Enter Registration Deadline (yyyy-mm-dd): ");
                registrationDeadline = Date.valueOf(LocalDate.parse(sc.nextLine()));

                if (!registrationDeadline.after(startDate))
                    break;

                System.out.println("Registration Deadline cannot be after Start Date.");
            } catch (Exception e) {
                System.out.println("Invalid date format. Use yyyy-mm-dd.");
            }
        }

// Maximum Participants
        while (true) {
            try {
                System.out.print("Enter Maximum Participants: ");
                maxParticipants = sc.nextInt();
                sc.nextLine();

                if (maxParticipants > 0)
                    break;

                System.out.println("Maximum Participants must be greater than 0.");
            } catch (Exception e) {
                System.out.println("Invalid number.");
                sc.nextLine();
            }
        }

        currentParticipants = 0;

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            String query = "INSERT INTO hackathons(title,location_city,mode,prize_pool,start_date,end_date,registration_deadline,max_participants,current_participants) VALUES(?,?,?,?,?,?,?,?,?)";

            PreparedStatement ps = con.prepareStatement(query);

            ps.setString(1, title);
            ps.setString(2, locationCity);
            ps.setString(3, mode);
            ps.setDouble(4, prizePool);
            ps.setDate(5, startDate);
            ps.setDate(6, endDate);
            ps.setDate(7, registrationDeadline);
            ps.setInt(8, maxParticipants);
            ps.setInt(9, currentParticipants);
//            ps.setInt(10, organizationId);

            ps.executeUpdate();
            ps.close();

            String sql = "SELECT MAX(hackathon_id) FROM hackathons";

            PreparedStatement pst = con.prepareStatement(sql);

            ResultSet rs = pst.executeQuery();

            int hackathonId = 0;
            if (rs.next()) {
                hackathonId = rs.getInt(1);

                String sql2 = "INSERT INTO organizationhackthone(organization_id,hackthone_id) VALUES(?,?)";

                PreparedStatement pst2 = con.prepareStatement(sql2);

                pst2.setInt(1, organizationId);
                pst2.setInt(2, hackathonId);

                pst2.executeUpdate();
                pst2.close();
            }

            rs.close();
            pst.close();

            System.out.println("Hackathon Added Successfully!");

            // Add audit log
            organization_auditLog log = new organization_auditLog();
            log.addLog(hackathonId, "INSERT");


        }
        catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Email all registered users about new hackathon
    // ==========================================================
    private void notifyAllUsers(Connection con, String title, String locationCity,
                                String mode, Date startDate, Date registrationDeadline) {

        try {

            String userQuery = "SELECT name, email FROM users";

            PreparedStatement userPs = con.prepareStatement(userQuery);

            ResultSet userRs = userPs.executeQuery();

            Map<String, String> recipients = new java.util.LinkedHashMap<>();

            while (userRs.next()) {
                recipients.put(userRs.getString("email"), userRs.getString("name"));
            }

            String subject = "New Hackathon Alert: " + title;

            String bodyTemplate =
                    "Hi {name},\n\n"
                            + "A new hackathon has just been posted on HackathonHub!\n\n"
                            + "Title                 : " + title + "\n"
                            + "Location              : " + locationCity + "\n"
                            + "Mode                  : " + mode + "\n"
                            + "Start Date            : " + startDate + "\n"
                            + "Registration Deadline : " + registrationDeadline + "\n\n"
                            + "Log in to HackathonHub to register before the deadline.\n\n"
                            + "- HackathonHub Team";


        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Delete Hackathon (Organization only)
    // ==========================================================
    public void deleteHackathon(int organizationId) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            int hackathonId;

            while (true) {
                try {
                    System.out.print("Enter Hackathon ID to Delete: ");
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

            // Add audit log before deletion
            organization_auditLog log = new organization_auditLog();
            log.addLog(hackathonId, "DELETE");

            String check = "SELECT * FROM organizationhackthone WHERE organization_id=? AND hackthone_id=?";

            PreparedStatement pst = con.prepareStatement(check);

            pst.setInt(1, organizationId);
            pst.setInt(2, hackathonId);

            ResultSet rs = pst.executeQuery();

            if (!rs.next()) {

                System.out.println("You cannot delete this hackathon.");

                rs.close();
                pst.close();
                con.close();

                return;
            }

            rs.close();
            pst.close();

            String sql1 =
                    "DELETE FROM organizationhackthone WHERE organization_id=? AND hackthone_id=?";

            PreparedStatement pst1 = con.prepareStatement(sql1);

            pst1.setInt(1, organizationId);
            pst1.setInt(2, hackathonId);

            pst1.executeUpdate();

            pst1.close();

            String sql2 =
                    "DELETE FROM hackathons WHERE hackathon_id=?";

            PreparedStatement pst2 = con.prepareStatement(sql2);

            pst2.setInt(1, hackathonId);

            int rows = pst2.executeUpdate();

            if (rows > 0) {
                System.out.println("Hackathon Deleted Successfully!");
            } else {
                System.out.println("Hackathon Not Found!");
            }

            pst2.close();
            con.close();

        }
        catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // View All Hackathons (Public)
    // ==========================================================
    public void viewHackathon() {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            String query =
                    "SELECT h.hackathon_id, h.title, o.organization_name, h.mode, h.location_city, " +
                            "h.prize_pool, h.start_date, h.current_participants, h.max_participants " +
                            "FROM hackathons h " +
                            "LEFT JOIN organizationhackthone oh ON h.hackathon_id = oh.hackthone_id " +
                            "LEFT JOIN organization o ON oh.organization_id = o.organization_id";

            PreparedStatement ps = con.prepareStatement(query);

            ResultSet rs = ps.executeQuery();

            boolean found = false;

            System.out.println();
            System.out.println("╔═════╦══════════════════════════════╦════════════════════╦══════════╦══════════════╦════════════╦════════════╦══════════════╗");
            System.out.println("║ ID  ║ TITLE                        ║ ORGANIZATION       ║ MODE     ║ CITY         ║ PRIZE      ║ SEATS      ║ START DATE   ║");
            System.out.println("╠═════╬══════════════════════════════╬════════════════════╬══════════╬══════════════╬════════════╬════════════╬══════════════╣");

            while (rs.next()) {

                found = true;

                String seats =
                        rs.getInt("current_participants")
                                + "/"
                                + rs.getInt("max_participants");

                String orgName = rs.getString("organization_name");
                if (orgName == null) orgName = "Unknown";

                System.out.printf(
                        "║ %-3d ║ %-28.28s ║ %-18.18s ║ %-8.8s ║ %-12.12s ║ %-10.0f ║ %-10s ║ %-12s ║%n",

                        rs.getInt("hackathon_id"),
                        rs.getString("title"),
                        orgName,
                        rs.getString("mode"),
                        rs.getString("location_city"),
                        rs.getDouble("prize_pool"),
                        seats,
                        rs.getDate("start_date")
                );
            }

            System.out.println("╚═════╩══════════════════════════════╩════════════════════╩══════════╩══════════════╩════════════╩════════════╩══════════════╝");

            if (!found) {
                System.out.println("No Hackathons Available.");
            }

            rs.close();
            ps.close();
            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // View Hackathons for a Specific Organization
    // ==========================================================
    public void viewHackathon(int organizationId) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            String sql =
                    "SELECT h.hackathon_id, h.title, h.location_city, h.mode, " +
                            "h.prize_pool, h.start_date, h.end_date, " +
                            "h.registration_deadline, h.max_participants, " +
                            "h.current_participants " +
                            "FROM organizationhackthone o " +
                            "JOIN hackathons h " +
                            "ON o.hackthone_id = h.hackathon_id " +
                            "WHERE o.organization_id = ?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setInt(1, organizationId);

            ResultSet rs = pst.executeQuery();

            int count = 0;

            System.out.println("\n========== YOUR HACKATHONS ==========");

            while (rs.next()) {

                count++;

                System.out.println("\n-----------------------------------------");
                System.out.println("Hackathon " + count);
                System.out.println("-----------------------------------------");
                System.out.println("Hackathon ID           : " + rs.getInt("hackathon_id"));
                System.out.println("Title                  : " + rs.getString("title"));
                System.out.println("Location               : " + rs.getString("location_city"));
                System.out.println("Mode                   : " + rs.getString("mode"));
                System.out.println("Prize Pool             : " + rs.getDouble("prize_pool"));
                System.out.println("Start Date             : " + rs.getDate("start_date"));
                System.out.println("End Date               : " + rs.getDate("end_date"));
                System.out.println("Registration Deadline  : " + rs.getDate("registration_deadline"));
                System.out.println("Max Participants       : " + rs.getInt("max_participants"));
                System.out.println("Current Participants   : " + rs.getInt("current_participants"));

                String skillQuery =
                        "SELECT s.skill_name " +
                                "FROM hackathonskillrequired hsr " +
                                "JOIN skills s ON hsr.skill_id = s.skill_id " +
                                "WHERE hsr.hackathon_id = ?";

                PreparedStatement skillPs = con.prepareStatement(skillQuery);
                skillPs.setInt(1, rs.getInt("hackathon_id"));

                ResultSet skillRs = skillPs.executeQuery();

                System.out.print("Skills Required       : ");

                boolean first = true;
                while (skillRs.next()) {
                    if (!first) {
                        System.out.print(", ");
                    }
                    System.out.print(skillRs.getString("skill_name"));
                    first = false;
                }

                if (first) {
                    System.out.print("None");
                }

                System.out.println();

                skillRs.close();
                skillPs.close();
            }

            if (count == 0) {
                System.out.println("No hackathons found for this organization.");
            }

            rs.close();
            pst.close();
            con.close();

        }
        catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Search Hackathon by Title
    // ==========================================================
    public void searchHackathon() {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            System.out.print("Enter Hackathon Title : ");
            String keyword = sc.nextLine();

            SearchHistory history = new SearchHistory();
            history.addSearch(keyword);

            String sql =
                    "SELECT h.hackathon_id, h.title, h.prize_pool, h.start_date, h.mode, " +
                            "h.current_participants, h.max_participants, o.organization_name " +
                            "FROM hackathons h " +
                            "LEFT JOIN organizationhackthone oh ON h.hackathon_id = oh.hackthone_id " +
                            "LEFT JOIN organization o ON oh.organization_id = o.organization_id " +
                            "WHERE h.title LIKE ?";

            PreparedStatement pst = con.prepareStatement(sql);

            pst.setString(1, "%" + keyword + "%");

            ResultSet rs = pst.executeQuery();

            boolean found = false;

            System.out.println("\n===== SEARCH RESULTS =====");

            while (rs.next()) {

                found = true;

                System.out.println("--------------------------------");
                System.out.println("Hackathon ID : " + rs.getInt("hackathon_id"));
                System.out.println("Title        : " + rs.getString("title"));
                System.out.println("Organization : " + rs.getString("organization_name"));
                System.out.println("Prize Pool   : ₹" + rs.getDouble("prize_pool"));
                System.out.println("Start Date   : " + rs.getDate("start_date"));
                System.out.println("Mode         : " + rs.getString("mode"));
                System.out.println("Participants : " + rs.getInt("current_participants")
                        + "/" + rs.getInt("max_participants"));
            }

            if (!found) {
                System.out.println("No Hackathon Found.");
            }

            rs.close();
            pst.close();
            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }

    // ==========================================================
    // Filter Hackathons
    // ==========================================================
    public void filterHackathons() {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            HackathonFilterDAO dao = new HackathonFilterDAO(con);

            System.out.println("\n===== Filter Hackathons =====");
            System.out.println("1. City + Mode + Prize Range");
            System.out.println("2. Search by Title Keyword");
            System.out.println("3. Filter by Skill");
            System.out.println("4. Filter by Domain");
            System.out.println("5. Only Open Seats");
            System.out.println("6. Filter by Status (Upcoming/Ongoing/Closed)");
            System.out.println("7. Trending Hackathons");
            System.out.println("8. Combined Filter (City + Skill)");
            int filterChoice;

            while (true) {
                try {
                    System.out.print("Enter Choice: ");
                    filterChoice = sc.nextInt();
                    sc.nextLine(); // Consume the newline

                    if (filterChoice <= 0) {
                        System.out.println("Choice must be greater than 0.");
                        continue;
                    }

                    break;
                } catch (Exception e) {
                    System.out.println("Invalid input! Please enter a valid integer.");
                    sc.nextLine(); // Clear the invalid input
                }
            }

            List<Map<String, Object>> results = null;

            switch (filterChoice) {

                case 1:


// City
                    String city;
                    while (true) {
                        System.out.print("Enter City: ");
                        city = sc.nextLine().trim();

                        if (!city.isEmpty()) {
                            break;
                        }

                        System.out.println("City cannot be empty.");
                    }

// Mode
                    String mode;
                    while (true) {
                        System.out.print("Enter Mode (ONLINE/OFFLINE/HYBRID): ");
                        mode = sc.nextLine().trim().toUpperCase();

                        if (mode.equals("ONLINE") || mode.equals("OFFLINE") || mode.equals("HYBRID")) {
                            break;
                        }

                        System.out.println("Invalid mode! Enter ONLINE, OFFLINE or HYBRID.");
                    }

// Minimum Prize
                    double minPrize;
                    while (true) {
                        try {
                            System.out.print("Enter Min Prize: ");
                            minPrize = sc.nextDouble();
                            sc.nextLine(); // Consume newline

                            if (minPrize >= 0) {
                                break;
                            }

                            System.out.println("Minimum Prize cannot be negative.");
                        } catch (Exception e) {
                            System.out.println("Invalid input! Please enter a valid number.");
                            sc.nextLine(); // Clear invalid input
                        }
                    }

// Maximum Prize
                    double maxPrize;
                    while (true) {
                        try {
                            System.out.print("Enter Max Prize: ");
                            maxPrize = sc.nextDouble();
                            sc.nextLine(); // Consume newline

                            if (maxPrize < minPrize) {
                                System.out.println("Maximum Prize must be greater than or equal to Minimum Prize.");
                                continue;
                            }

                            break;
                        } catch (Exception e) {
                            System.out.println("Invalid input! Please enter a valid number.");
                            sc.nextLine(); // Clear invalid input
                        }
                    }
                    results = dao.filterByCityModePrize(city, mode, minPrize, maxPrize);
                    break;

                case 2:
                    System.out.print("Enter Keyword: ");
                    String keyword = sc.nextLine();

                    SearchHistory history = new SearchHistory();
                    history.addSearch(keyword);

                    results = dao.searchByTitle(keyword);
                    break;
                case 3:
                    System.out.print("Enter Skill: ");
                    String skill = sc.nextLine();
                    results = dao.filterBySkill(skill);
                    break;

                case 4:
                    System.out.print("Enter Domain: ");
                    String domain = sc.nextLine();
                    results = dao.filterByDomain(domain);
                    break;

                case 5:
                    results = dao.getOpenSeats();
                    break;

                case 6:
                    System.out.print("Enter Status (UPCOMING/ONGOING/CLOSED or leave blank for all): ");
                    String status = sc.nextLine();
                    results = dao.getByStatus(status.isEmpty() ? null : status);
                    break;

                case 7:
                    int limit;

                    while (true) {
                        try {
                            System.out.print("Enter Limit (e.g. 10): ");
                            limit = sc.nextInt();
                            sc.nextLine(); // Consume the newline

                            if (limit <= 0) {
                                System.out.println("Limit must be greater than 0.");
                                continue;
                            }

                            break;
                        } catch (Exception e) {
                            System.out.println("Invalid input! Please enter a valid integer.");
                            sc.nextLine(); // Clear the invalid input
                        }
                    }
                    results = dao.getTrending(limit);
                    break;

                case 8:
                    System.out.print("Enter City: ");
                    String cCity = sc.nextLine();
                    System.out.print("Enter Skill: ");
                    String cSkill = sc.nextLine();
                    results = dao.combinedFilter(cCity, cSkill);
                    break;

                default:
                    System.out.println("Invalid Choice!");
                    con.close();
                    return;
            }

            System.out.println("\n===== Results =====");

            if (results.isEmpty()) {
                System.out.println("No hackathons found.");
            } else {
                for (Map<String, Object> row : results) {
                    System.out.println(row);
                }
            }

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }
}