import java.sql.*;
import java.util.*;

public class recommendation_for_Best_hackthone {


    public HashMap<Integer, Integer> recommendHackathons(int userId) throws SQLException {
        Connection con = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        // Store user's skill IDs
        ArrayList<Integer> userSkills = new ArrayList<>();

        String sql = "SELECT skill_id FROM userskills WHERE user_id=?";
        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, userId);

        ResultSet rs = pst.executeQuery();

        while (rs.next()) {
//            System.out.println(rs.getInt("skill_id"));
            userSkills.add(rs.getInt("skill_id"));
        }

        rs.close();
        pst.close();

        // Find maximum hackathon ID
        int maxHackathonId = 0;

        sql = "SELECT max(hackathon_id) FROM hackathons";
        Statement st = con.createStatement();
        rs = st.executeQuery(sql);

        if (rs.next()) {
//            System.out.println(rs.getInt(1));
            maxHackathonId = rs.getInt(1);
        }

        rs.close();
        st.close();

        // Store (hackathon_id, matched_skill_count)
        HashMap<Integer, Integer> map = new HashMap<>();

        // Loop from 1 to max(hackathon_id)
        for (int hackathonId = 1; hackathonId <= maxHackathonId; hackathonId++) {

            ArrayList<Integer> hackathonSkills = new ArrayList<>();

            sql = "SELECT skill_id FROM hackathonskillrequired WHERE hackathon_id=?";
            pst = con.prepareStatement(sql);
            pst.setInt(1, hackathonId);

            rs = pst.executeQuery();

            while (rs.next()) {
                hackathonSkills.add(rs.getInt("skill_id"));
            }

            rs.close();
            pst.close();

            if (hackathonSkills.size() == 0)
                continue;

            int count = 0;

            for (Integer skill : hackathonSkills) {

                if (userSkills.contains(skill)) {
                    count++;
                }

            }

            map.put(hackathonId, count);
        }

        return sortTop10(map);
    }

    private HashMap<Integer, Integer> sortTop10(HashMap<Integer, Integer> map) {

        List<Map.Entry<Integer, Integer>> list =
                new ArrayList<>(map.entrySet());

        Collections.sort(list, (a, b) -> b.getValue() - a.getValue());

        HashMap<Integer, Integer> result = new LinkedHashMap<>();

        int c = 0;

        for (Map.Entry<Integer, Integer> entry : list) {

            result.put(entry.getKey(), entry.getValue());

            c++;

            if (c == 10)
                break;
        }
//        System.out.println("----------------------------");

        return result;
    }

    public void displayRecommendation(int userId) throws SQLException {

        HashMap<Integer, Integer> result = recommendHackathons(userId);

        System.out.println("Top Recommended Hackathons\n");


        for (Map.Entry<Integer, Integer> entry : result.entrySet()) {

            System.out.println("Hackathon ID : " + entry.getKey());
            System.out.println("Matched Skills : " + entry.getValue());
            System.out.println("-----------------------------");
        }
    }


}
