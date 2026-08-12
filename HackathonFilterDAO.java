import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;


/**
 * HackathonFilterDAO
 * -------------------
 * Java filter class for the hackathon project. Each public method calls one
 * of the stored procedures in hackathon_filter_procedures.sql and returns
 * the result as a List<Map<String,Object>> — one Map per row, keyed by
 * column name. This keeps a single class working for every procedure even
 * though they each return different columns (no need for 9 separate model
 * classes).
 *
 * Requires: hackathon_filter_procedures.sql already run against the
 * `hackthone` database (creates sp_hackathon_master_details, sp_filter_city_
 * mode_prize, sp_search_by_title, sp_filter_by_skill, sp_filter_by_domain,
 * sp_open_seats, sp_hackathon_status, sp_trending_hackathons, sp_combined_filter).
 */
public class HackathonFilterDAO {

    private final Connection conn;

    public HackathonFilterDAO(Connection conn) {
        this.conn = conn;
    }

    // ------------------------------------------------------------------
    // 1) Master details — all info in one go, no filters
    // ------------------------------------------------------------------
    public List<Map<String, Object>> getMasterDetails() throws SQLException {
        return callProcedure("sp_hackathon_master_details");
    }

    // ------------------------------------------------------------------
    // 2) Filter by city + mode + prize range
    // ------------------------------------------------------------------
    public List<Map<String, Object>> filterByCityModePrize(String city, String mode,
                                                           double minPrize, double maxPrize) throws SQLException {
        return callProcedure("sp_filter_city_mode_prize", city, mode, minPrize, maxPrize);
    }

    // ------------------------------------------------------------------
    // 3) Search by title keyword
    // ------------------------------------------------------------------
    public List<Map<String, Object>> searchByTitle(String keyword) throws SQLException {
        return callProcedure("sp_search_by_title", keyword);
    }

    // ------------------------------------------------------------------
    // 4) Filter by required skill
    // ------------------------------------------------------------------
    public List<Map<String, Object>> filterBySkill(String skillName) throws SQLException {
        return callProcedure("sp_filter_by_skill", skillName);
    }

    // ------------------------------------------------------------------
    // 5) Filter by domain / interest
    // ------------------------------------------------------------------
    public List<Map<String, Object>> filterByDomain(String domainName) throws SQLException {
        return callProcedure("sp_filter_by_domain", domainName);
    }

    // ------------------------------------------------------------------
    // 6) Open seats + registration still open (no params)
    // ------------------------------------------------------------------
    public List<Map<String, Object>> getOpenSeats() throws SQLException {
        return callProcedure("sp_open_seats");
    }

    // ------------------------------------------------------------------
    // 7) Filter by status: pass null for all rows (with status column),
    //    or "UPCOMING" / "ONGOING" / "CLOSED" to filter to one status
    // ------------------------------------------------------------------
    public List<Map<String, Object>> getByStatus(String status) throws SQLException {
        return callProcedure("sp_hackathon_status", status);
    }

    // ------------------------------------------------------------------
    // 8) Trending / most bookmarked hackathons
    // ------------------------------------------------------------------
    public List<Map<String, Object>> getTrending(int limit) throws SQLException {
        return callProcedure("sp_trending_hackathons", limit);
    }

    // ------------------------------------------------------------------
    // 9) Combined filter — city + skill + open seats, sorted by prize
    // ------------------------------------------------------------------
    public List<Map<String, Object>> combinedFilter(String city, String skillName) throws SQLException {
        return callProcedure("sp_combined_filter", city, skillName);
    }

    // ------------------------------------------------------------------
    // Generic helper: builds "{CALL procName(?,?,...)}", binds params,
    // executes, and maps every row of the ResultSet into a Map<column,value>.
    // ------------------------------------------------------------------
    private List<Map<String, Object>> callProcedure(String procName, Object... params) throws SQLException {
        StringBuilder placeholders = new StringBuilder();
        for (int i = 0; i < params.length; i++) {
            placeholders.append(i == 0 ? "?" : ",?");
        }
        String call = "{CALL " + procName + "(" + placeholders + ")}";

        List<Map<String, Object>> rows = new ArrayList<>();

        try (CallableStatement cs = conn.prepareCall(call)) {
            for (int i = 0; i < params.length; i++) {
                cs.setObject(i + 1, params[i]);
            }

            boolean hasResultSet = cs.execute();
            if (hasResultSet) {
                try (ResultSet rs = cs.getResultSet()) {
                    ResultSetMetaData meta = rs.getMetaData();
                    int columnCount = meta.getColumnCount();

                    while (rs.next()) {
                        Map<String, Object> row = new LinkedHashMap<>();
                        for (int col = 1; col <= columnCount; col++) {
                            row.put(meta.getColumnLabel(col), rs.getObject(col));
                        }
                        rows.add(row);
                    }
                }
            }
        }
        return rows;
    }

    // ------------------------------------------------------------------
    // Quick manual test (edit connection details and run this class directly)
    // ------------------------------------------------------------------
}

