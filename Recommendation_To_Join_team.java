

import java.sql.*;
import java.util.*;

public class Recommendation_To_Join_team {

//    static void main(String[] args) throws Exception{
//        Recommendation_To_Join_team a=new Recommendation_To_Join_team();
//        a.recommendTeams(1);
//
//    }




    // Main Method
    public void recommendTeams(int userId) throws SQLException {
        Connection con =  DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        Scanner sc = new Scanner(System.in);

        int hackathonId;

        while (true) {
            System.out.print("Enter Hackathon ID : ");

            if (sc.hasNextInt()) {
                hackathonId = sc.nextInt();

                if (hackathonId > 0) {
                    break;
                } else {
                    System.out.println("❌ Hackathon ID must be greater than 0.");
                }
            } else {
                System.out.println("❌ Invalid input! Please enter a numeric Hackathon ID.");
                sc.next(); // Discard invalid input
            }
        }

        String sql = "SELECT * FROM hackathons WHERE hackathon_id=?";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, hackathonId);

        ResultSet rs = pst.executeQuery();

        if(!rs.next()){

            System.out.println("Hackathon not found.");

            rs.close();
            pst.close();
            return;
        }

        rs.close();
        pst.close();

        ArrayList<Integer> userSkills =
                getUserSkills(userId);

//        System.out.println(userSkills);
        ArrayList<Integer> requiredSkills =
                getHackathonRequiredSkills(hackathonId);
//        System.out.println(requiredSkills);
        requiredSkills.removeIf(userSkills::contains);
//        System.out.println(requiredSkills);
        ArrayList<Integer> teams =
                getTeamsOfHackathon(hackathonId);
//        System.out.println(teams);
        HashMap<Integer,Integer> score =
                new HashMap<>();

        for(Integer teamId : teams){

            HashSet<Integer> teamSkills =
                    getTeamSkills(teamId);

            int count = 0;

            for(Integer skill : requiredSkills){

                if(teamSkills.contains(skill))
                    count++;
            }

            score.put(teamId,count);

        }

        LinkedHashMap<Integer,Integer> result =
                sortTopTeams(score);

        System.out.println("\n========== Recommended Teams ==========");

        for(Map.Entry<Integer,Integer> entry : result.entrySet()){

            System.out.println("Team ID : "
                    + entry.getKey()
                    + " | Missing Skills Covered : "
                    + entry.getValue());

        }

    }
    // Get User Skills
    public ArrayList<Integer> getUserSkills(int userId) throws SQLException {
        Connection con =  DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        ArrayList<Integer> userSkills = new ArrayList<>();

        String sql = "SELECT skill_id FROM userskills WHERE user_id=?";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, userId);

        ResultSet rs = pst.executeQuery();

        while (rs.next()) {

            userSkills.add(rs.getInt("skill_id"));

        }

        rs.close();
        pst.close();

        return userSkills;
    }

    // Get Required Skills of Hackathon
    public ArrayList<Integer> getHackathonRequiredSkills(int hackathonId) throws SQLException {
        Connection con =  DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        ArrayList<Integer> requiredSkills = new ArrayList<>();

        String sql = "SELECT skill_id FROM hackathonskillrequired WHERE hackathon_id=?";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, hackathonId);

        ResultSet rs = pst.executeQuery();

        while (rs.next()) {

            requiredSkills.add(rs.getInt("skill_id"));

        }

        rs.close();
        pst.close();

        return requiredSkills;
    }


    public ArrayList<Integer> getTeamsOfHackathon(int hackathonId) throws SQLException {
        Connection con =  DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        ArrayList<Integer> teams = new ArrayList<>();

        String sql = "SELECT team_id FROM teams WHERE hackathon_id=?";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, hackathonId);

        ResultSet rs = pst.executeQuery();

        while(rs.next()){

            teams.add(rs.getInt("team_id"));

        }

        rs.close();
        pst.close();

        return teams;
    }
    public HashSet<Integer> getTeamSkills(int teamId) throws SQLException {
        Connection con =  DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        HashSet<Integer> teamSkills = new HashSet<>();

        String sql = "SELECT user_id FROM teammembers WHERE team_id=?";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, teamId);

        ResultSet rs = pst.executeQuery();

        while(rs.next()){

            int memberId = rs.getInt("user_id");

            String sql2 = "SELECT skill_id FROM userskills WHERE user_id=?";

            PreparedStatement pst2 = con.prepareStatement(sql2);
            pst2.setInt(1, memberId);

            ResultSet rs2 = pst2.executeQuery();

            while(rs2.next()){

                teamSkills.add(rs2.getInt("skill_id"));

            }

            rs2.close();
            pst2.close();

        }

        rs.close();
        pst.close();

        return teamSkills;
    }
    public LinkedHashMap<Integer,Integer> sortTopTeams(HashMap<Integer,Integer> map){

        List<Map.Entry<Integer,Integer>> list =
                new ArrayList<>(map.entrySet());

        Collections.sort(list,(a,b)->b.getValue()-a.getValue());

        LinkedHashMap<Integer,Integer> result =
                new LinkedHashMap<>();

        int count = 0;

        for(Map.Entry<Integer,Integer> entry : list){

            result.put(entry.getKey(),entry.getValue());

            count++;

            if(count==10)
                break;
        }

        return result;
    }
    public void displayRecommendation(int userId) throws SQLException {
        Connection con =  DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/hackthone",
                "root",
                "");
        String sql = "SELECT hackathon_id FROM registration WHERE user_id=?";

        PreparedStatement pst = con.prepareStatement(sql);
        pst.setInt(1, userId);

        ResultSet rs = pst.executeQuery();

        while(rs.next()){

            int hackathonId = rs.getInt("hackathon_id");

            ArrayList<Integer> userSkills = getUserSkills(userId);

            ArrayList<Integer> requiredSkills =
                    getHackathonRequiredSkills(hackathonId);

            requiredSkills.removeIf(userSkills::contains);

            ArrayList<Integer> teams =
                    getTeamsOfHackathon(hackathonId);

            HashMap<Integer,Integer> score =
                    new HashMap<>();

            for(Integer teamId : teams){

                HashSet<Integer> teamSkills =
                        getTeamSkills(teamId);

                int matched = 0;

                for(Integer skill : requiredSkills){

                    if(teamSkills.contains(skill))
                        matched++;

                }

                score.put(teamId,matched);

            }

            LinkedHashMap<Integer,Integer> result =
                    sortTopTeams(score);

            System.out.println("\n================================");
            System.out.println("Hackathon ID : "+hackathonId);
            System.out.println("Top Recommended Teams");
            System.out.println("================================");

            for(Map.Entry<Integer,Integer> entry : result.entrySet()){

                System.out.println(
                        "Team ID : "+entry.getKey()+
                                " | Matching Skills : "+entry.getValue());

            }

            System.out.println();

        }

        rs.close();
        pst.close();
    }
}