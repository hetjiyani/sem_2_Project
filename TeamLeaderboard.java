import java.sql.*;
import java.util.HashSet;
import java.util.Scanner;

// Ranks the teams of ONE hackathon by how well they match its required skills,
// plus a small bonus for team size. Uses the hand-built MyPriorityQueue above
// instead of java.util.PriorityQueue.
public class TeamLeaderboard {

    Scanner sc = new Scanner(System.in);

    public void showLeaderboard() {

        int hackathonId;

        while (true) {
            try {
                while (true) {
                    try {
                        while (true) {
                            try {
                                while (true) {
                                    try {
                                        while (true) {
                                            try {
                                                System.out.print("Enter Hackathon ID for the leaderboard: ");
                                                hackathonId = sc.nextInt();
                                                sc.nextLine(); // Clear newline

                                                if (hackathonId <= 0) {
                                                    System.out.println(" Hackathon ID must be greater than 0.");
                                                    continue;
                                                }

                                                break;
                                            } catch (Exception e) {
                                                System.out.println(" Invalid input! Please enter a numeric Hackathon ID.");
                                                sc.nextLine(); // Clear invalid input
                                            }
                                        }

                                        if (hackathonId <= 0) {
                                            System.out.println(" Hackathon ID must be greater than 0.");
                                            continue;
                                        }

                                        break;
                                    } catch (Exception e) {
                                        System.out.println(" Invalid input! Please enter a numeric Hackathon ID.");
                                        sc.nextLine(); // Clear invalid input
                                    }
                                }

                                if (hackathonId <= 0) {
                                    System.out.println(" Hackathon ID must be greater than 0.");
                                    continue;
                                }
                                break;
                            } catch (Exception e) {
                                System.out.println(" Invalid input! Please enter a valid numeric Hackathon ID.");
                                sc.nextLine(); // Clear invalid input
                            }
                        }

                        if (hackathonId <= 0) {
                            System.out.println(" Hackathon ID must be greater than 0.");
                            continue;
                        }

                        break;
                    } catch (Exception e) {
                        System.out.println(" Invalid input! Please enter a numeric Hackathon ID.");
                        sc.nextLine(); // Clear invalid input
                    }
                }

                if (hackathonId <= 0) {
                    System.out.println(" Hackathon ID must be greater than 0.");
                    continue;
                }

                break;
            } catch (Exception e) {
                System.out.println(" Invalid input! Please enter a numeric Hackathon ID.");
                sc.nextLine(); // Clear invalid input
            }
        }

        try {

            Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/hackthone",
                    "root",
                    "");

            // Required skills for this hackathon
            HashSet<Integer> requiredSkills = new HashSet<>();

            PreparedStatement reqPs = con.prepareStatement(
                    "SELECT skill_id FROM hackathonskillrequired WHERE hackathon_id=?");
            reqPs.setInt(1, hackathonId);
            ResultSet reqRs = reqPs.executeQuery();

            while (reqRs.next()) {
                requiredSkills.add(reqRs.getInt("skill_id"));
            }
            reqRs.close();
            reqPs.close();

            // Every team registered under this hackathon
            PreparedStatement teamPs = con.prepareStatement(
                    "SELECT team_id, team_name FROM teams WHERE hackathon_id=?");
            teamPs.setInt(1, hackathonId);
            ResultSet teamRs = teamPs.executeQuery();

            MyPriorityQueue pq = new MyPriorityQueue(100);

            while (teamRs.next()) {

                int teamId = teamRs.getInt("team_id");
                String teamName = teamRs.getString("team_name");

                // Union of all this team's members' skills (HashSet auto-dedupes)
                HashSet<Integer> teamSkills = new HashSet<>();

                PreparedStatement memberPs = con.prepareStatement(
                        "SELECT user_id FROM teammembers WHERE team_id=?");
                memberPs.setInt(1, teamId);
                ResultSet memberRs = memberPs.executeQuery();

                int memberCount = 0;

                while (memberRs.next()) {
                    memberCount++;
                    int uid = memberRs.getInt("user_id");

                    PreparedStatement skillPs = con.prepareStatement(
                            "SELECT skill_id FROM userskills WHERE user_id=?");
                    skillPs.setInt(1, uid);
                    ResultSet skillRs = skillPs.executeQuery();

                    while (skillRs.next()) {
                        teamSkills.add(skillRs.getInt("skill_id"));
                    }
                    skillRs.close();
                    skillPs.close();
                }
                memberRs.close();
                memberPs.close();

                // How many of the REQUIRED skills this team covers
                int matched = 0;
                for (Integer skill : requiredSkills) {
                    if (teamSkills.contains(skill)) matched++;
                }

                // Score = skill coverage (weighted higher) + a small bonus for team size
                int score = (matched * 10) + (memberCount * 2);

                pq.insert(new TeamNode(teamId, teamName, score));
            }

            teamRs.close();
            teamPs.close();

            pq.display();

            con.close();

        } catch (Exception e) {
            System.out.println(e);
        }
    }
}
class TeamNode {

    int teamId;
    String teamName;
    int score;

    public TeamNode(int teamId, String teamName, int score) {
        this.teamId = teamId;
        this.teamName = teamName;
        this.score = score;
    }
}
// A hand-built Max Priority Queue using a plain array.
// Higher `score` = higher priority = appears first.
// This deliberately avoids java.util.PriorityQueue so the insertion/removal
// logic (and its complexity) is visible and explainable for viva.
class MyPriorityQueue {

    private TeamNode[] queue;
    private int size;

    public MyPriorityQueue(int capacity) {
        queue = new TeamNode[capacity];
        size = 0;
    }

    public boolean isEmpty() {
        return size == 0;
    }

    // Insertion-sort style insert: O(n) worst case, but keeps the array
    // ALWAYS fully sorted descending by score, so display() is trivial O(n).
    public void insert(TeamNode node) {

        if (size == queue.length) {
            System.out.println("Queue Full");
            return;
        }

        queue[size] = node;

        int i = size;

        while (i > 0 && queue[i].score > queue[i - 1].score) {
            TeamNode temp = queue[i];
            queue[i] = queue[i - 1];
            queue[i - 1] = temp;
            i--;
        }

        size++;
    }

    // Removes and returns the highest-scoring team (front of the array)
    public TeamNode delete() {

        if (isEmpty())
            return null;

        TeamNode node = queue[0];

        for (int i = 1; i < size; i++) {
            queue[i - 1] = queue[i];
        }

        size--;

        return node;
    }

    public void display() {

        if (isEmpty()) {
            System.out.println("No Teams Available.");
            return;
        }

        System.out.println("\n========== TEAM LEADERBOARD ==========");

        for (int i = 0; i < size; i++) {

            String medal = (i == 0) ? "🥇" : (i == 1) ? "🥈" : (i == 2) ? "🥉" : (i + 1) + ".";

            System.out.println(medal + " " + queue[i].teamName + "  |  Score : " + queue[i].score);
        }
    }
}
class SearchNode {

    String keyword;
    SearchNode next;

    public SearchNode(String keyword) {
        this.keyword = keyword;
        this.next = null;
    }
}
// A hand-built singly linked list. Newest item is always added at the HEAD,
// so displaying head-to-tail naturally shows "most recent search first" —
// which is exactly what a history feature needs. Avoids java.util.LinkedList
// so the pointer manipulation is visible for viva.
class MyLinkedList {

    private SearchNode head;
    private int size;

    public MyLinkedList() {
        head = null;
        size = 0;
    }

    // Insert at head — O(1), no traversal needed
    public void addFirst(String keyword) {
        SearchNode newNode = new SearchNode(keyword);
        newNode.next = head;
        head = newNode;
        size++;
    }

    public boolean isEmpty() {
        return head == null;
    }

    public int size() {
        return size;
    }

    public void display() {

        if (isEmpty()) {
            System.out.println("No search history yet.");
            return;
        }

        System.out.println("\n========== SEARCH HISTORY ==========");

        SearchNode current = head;
        int index = 1;

        while (current != null) {
            System.out.println(index + ". " + current.keyword);
            current = current.next;
            index++;
        }
    }

    public void clear() {
        head = null;
        size = 0;
    }
}
// IMPORTANT: the underlying list is `static` on purpose.
// Main.java creates a NEW SearchHistory object every time the menu case runs
// (e.g. `SearchHistory h = new SearchHistory();`). If `history` were a normal
// instance field, every new object would start with an EMPTY list and you'd
// lose everything searched earlier in the session. Making it `static` means
// all SearchHistory objects share the same one list for the whole run of the
// program — which is what a "history" feature actually needs.
class SearchHistory {

    private static MyLinkedList history = new MyLinkedList();

    public void addSearch(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) return;
        history.addFirst(keyword);
    }

    public void displayHistory() {
        history.display();
    }

    public void clearHistory() {
        history.clear();
        System.out.println("Search history cleared.");
    }
}