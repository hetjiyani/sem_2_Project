import java.sql.*;

public class mail_for_joining {

    public void mail_join(int userId, int hackathonId) {

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            // Get User Details
            String sql1 = "SELECT name, email FROM users WHERE user_id=?";

            PreparedStatement pst1 = con.prepareStatement(sql1);
            pst1.setInt(1, userId);

            ResultSet rs1 = pst1.executeQuery();

            if (!rs1.next()) {

                System.out.println("User not found.");

                rs1.close();
                pst1.close();
                con.close();

                return;
            }

            String userName = rs1.getString("name");
            String email = rs1.getString("email");

            rs1.close();
            pst1.close();

            // Get Hackathon Details
            String sql2 = "SELECT title, prize_pool, start_date FROM hackathons WHERE hackathon_id=?";

            PreparedStatement pst2 = con.prepareStatement(sql2);
            pst2.setInt(1, hackathonId);

            ResultSet rs2 = pst2.executeQuery();

            if (!rs2.next()) {

                System.out.println("Hackathon not found.");

                rs2.close();
                pst2.close();
                con.close();

                return;
            }

            String title = rs2.getString("title");
            double prizePool = rs2.getDouble("prize_pool");
            Date startDate = rs2.getDate("start_date");

            rs2.close();
            pst2.close();

            String subject = "Hackathon Registration Successful";

            String body =
                    "Dear " + userName + ",\n\n" +
                            "Congratulations! Your registration for the hackathon has been confirmed.\n\n" +
                            "Hackathon Details\n" +
                            "-----------------------------\n" +
                            "Title      : " + title + "\n" +
                            "Prize Pool : ₹" + prizePool + "\n" +
                            "Start Date : " + startDate + "\n\n" +
                            "We wish you all the best for the competition.\n\n" +
                            "Regards,\n" +
                            "Hackathon Discovery Platform";

            Mailer m=new Mailer(email,subject,body);


            con.close();

        }
        catch (Exception e) {

            System.out.println(e);

        }
    }

}