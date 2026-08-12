import java.sql.*;

public class Recommendation {



    public void buildRecommendationPrompt(int userId) throws SQLException {
        Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        StringBuilder prompt = new StringBuilder();

        prompt.append("You are an AI Hackathon Recommendation Assistant.\n\n");

        // ==========================
        // USER SKILLS
        // ==========================

        prompt.append("USER SKILLS:\n");

        String skillQuery =
                "SELECT s.skill_name, us.proficiency_level " +
                        "FROM userskills us " +
                        "JOIN skills s ON us.skill_id = s.skill_id " +
                        "WHERE us.user_id=?";

        PreparedStatement pst = con.prepareStatement(skillQuery);
        pst.setInt(1, userId);

        ResultSet rs = pst.executeQuery();

        while(rs.next()){

            prompt.append("- ")
                    .append(rs.getString("skill_name"))
                    .append(" : ")
                    .append(rs.getString("proficiency_level"))
                    .append("\n");
        }

        rs.close();
        pst.close();



        // ==========================
        // USER INTERESTS
        // ==========================

        prompt.append("\nUSER INTERESTS:\n");

        String interestQuery =
                "SELECT skill_name " +
                        "FROM skills " +
                        "JOIN userinterests ON interest_id=skill_id " +
                        "WHERE user_id=?";

        pst = con.prepareStatement(interestQuery);
        pst.setInt(1, userId);

        rs = pst.executeQuery();

        while(rs.next()){

            prompt.append("- ")
                    .append(rs.getString("skill_name"))
                    .append("\n");
        }

        rs.close();
        pst.close();



        // ==========================
        // REGISTERED HACKATHONS
        // ==========================

        prompt.append("\nREGISTERED HACKATHONS:\n");

        String registrationQuery =
                "SELECT hackathon_id,status " +
                        "FROM registration " +
                        "WHERE user_id=?";

        pst = con.prepareStatement(registrationQuery);
        pst.setInt(1, userId);

        rs = pst.executeQuery();

        while(rs.next()){

            int hackathonId = rs.getInt("hackathon_id");

            prompt.append("\nHackathon ID : ")
                    .append(hackathonId)
                    .append("\n");

            prompt.append("Registration Status : ")
                    .append(rs.getString("status"))
                    .append("\n");



            // ==========================
            // REQUIRED SKILLS
            // ==========================

            prompt.append("Required Skills:\n");

            String requiredSkillQuery =
                    "SELECT s.skill_name " +
                            "FROM hackathonskillrequired hs " +
                            "JOIN skills s ON hs.skill_id=s.skill_id " +
                            "WHERE hs.hackathon_id=?";

            PreparedStatement pst2 = con.prepareStatement(requiredSkillQuery);

            pst2.setInt(1, hackathonId);

            ResultSet rs2 = pst2.executeQuery();

            while(rs2.next()){

                prompt.append("- ")
                        .append(rs2.getString("skill_name"))
                        .append("\n");
            }

            rs2.close();
            pst2.close();

            prompt.append("\n-------------------------------------\n");
        }

        rs.close();
        pst.close();

        Recommendation_for_Learning a=new Recommendation_for_Learning();
        a.RELearning(prompt.toString());
    }


}