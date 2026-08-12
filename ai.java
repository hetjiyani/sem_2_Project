
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

class ai {

    ai(String prom) {
        System.out.println();
        System.out.println();
        System.out.println("genrating text...");
        String apiKey = ""; // ENTER YOUR API HERE
        String model = "gemini-2.5-flash";
        int a = 0;

        while (a != 1) {
            a++;
            String input = prom;

            if (input.equalsIgnoreCase("exit"))
                break;

            try {
                String endpoint = "https://generativelanguage.googleapis.com/v1/models/"
                        + model + ":generateContent?key=" + apiKey;

                // Escape quotes in user input
                String jsonBody = "{ \"contents\": [{ \"parts\": [{ \"text\": \""
                        + input.replace("\"", "\\\"") + "\" }] }] }";

                HttpURLConnection conn = (HttpURLConnection) new URL(endpoint).openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setDoOutput(true);

                try (OutputStream os = conn.getOutputStream()) {
                    os.write(jsonBody.getBytes("UTF-8"));
                }

                int status = conn.getResponseCode();
                InputStream is = (status >= 400)
                        ? conn.getErrorStream()
                        : conn.getInputStream();

                BufferedReader br = new BufferedReader(new InputStreamReader(is, "UTF-8"));
                StringBuilder response = new StringBuilder();
                String line;
                while ((line = br.readLine()) != null) {
                    response.append(line);
                }

                if (status >= 400) {
                    System.out.println("API Error (" + status + "): " + response);
                    continue;
                }

                // ==============================
                // Escape-safe extraction starts
                // ==============================
                String res = response.toString();
                StringBuilder answer = new StringBuilder();
                int index = 0;

                while ((index = res.indexOf("\"text\":", index)) != -1) {
                    int start = res.indexOf("\"", index + 7) + 1;
                    StringBuilder part = new StringBuilder();
                    boolean escape = false;

                    for (int i = start; i < res.length(); i++) {
                        char c = res.charAt(i);

                        if (escape) {
                            // Handle escaped chars like \n, \\, \"
                            switch (c) {
                                case 'n': part.append('\n'); break;
                                case 't': part.append('\t'); break;
                                case 'r': part.append('\r'); break;
                                default: part.append(c); break;
                            }
                            escape = false;
                        } else if (c == '\\') {
                            escape = true;
                        } else if (c == '"') {
                            index = i;
                            break;
                        } else {
                            part.append(c);
                        }
                    }

                    answer.append(part);
                }

                // Print the final response
                System.out.println(answer.toString());

                // ==============================
                // Escape-safe extraction ends
                // ==============================

            } catch (Exception e) {
                System.out.println("Java Error: " + e.getMessage());
            }
        }
    }

}