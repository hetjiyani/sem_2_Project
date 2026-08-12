import java.sql.*;

public class organization_auditLog {

    Connection con;

    public organization_auditLog() throws SQLException {

        con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");

    }

    public void addLog(int hackathonId, String action) throws SQLException {

        int organizationId = -1;

        String orgQuery =
                "SELECT organization_id FROM organizationhackthone WHERE hackthone_id=?";

        PreparedStatement pst1 = con.prepareStatement(orgQuery);
        pst1.setInt(1, hackathonId);

        ResultSet rs1 = pst1.executeQuery();

        if (rs1.next()) {
            organizationId = rs1.getInt("organization_id");
        } else {
            rs1.close();
            pst1.close();
            return;
        }

        rs1.close();
        pst1.close();

        String hackQuery =
                "SELECT * FROM hackathons WHERE hackathon_id=?";

        PreparedStatement pst2 = con.prepareStatement(hackQuery);
        pst2.setInt(1, hackathonId);

        ResultSet rs2 = pst2.executeQuery();

        if (!rs2.next()) {
            System.out.println("Hackathon not found.");
            rs2.close();
            pst2.close();
            return;
        }

        String title = rs2.getString("title");
        String location = rs2.getString("location_city");
        String mode = rs2.getString("mode");
        double prizePool = rs2.getDouble("prize_pool");
        Date startDate = rs2.getDate("start_date");
        Date endDate = rs2.getDate("end_date");
        Date registrationDeadline = rs2.getDate("registration_deadline");
        int maxParticipants = rs2.getInt("max_participants");
        int currentParticipants = rs2.getInt("current_participants");

        rs2.close();
        pst2.close();

        String insert =
                "INSERT INTO organization_auditLog(" +
                        "organization_id," +
                        "hackathon_id," +
                        "title," +
                        "location_city," +
                        "mode," +
                        "prize_pool," +
                        "start_date," +
                        "end_date," +
                        "registration_deadline," +
                        "max_participants," +
                        "current_participants," +
                        "action) " +
                        "VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";

        PreparedStatement pst3 = con.prepareStatement(insert);

        pst3.setInt(1, organizationId);
        pst3.setInt(2, hackathonId);
        pst3.setString(3, title);
        pst3.setString(4, location);
        pst3.setString(5, mode);
        pst3.setDouble(6, prizePool);
        pst3.setDate(7, startDate);
        pst3.setDate(8, endDate);
        pst3.setDate(9, registrationDeadline);
        pst3.setInt(10, maxParticipants);
        pst3.setInt(11, currentParticipants);
        pst3.setString(12, action);

        pst3.executeUpdate();

        pst3.close();
        con.close();
    }
}