import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.util.Properties;

// Extends Thread so start() works as expected
public class Mailer extends Thread {

    private static final String FROM_EMAIL = "hetjiyanipro@gmail.com";
    private static final String APP_PASSWORD = "reev gjal ywje ynji";

    String to;
    String subject;
    String body;

    public Mailer(String to, String subject, String body) {
        this.to = to;
        this.subject = subject;
        this.body = body;

        // Starts the background thread (executes run() automatically)
        start();
    }

    @Override
    public void run() {

        Properties properties = new Properties();

        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");

        Session session = Session.getInstance(properties,
                new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(FROM_EMAIL, APP_PASSWORD);
                    }
                });

        try {

            Message message = new MimeMessage(session);

            message.setFrom(new InternetAddress(FROM_EMAIL));

            message.setRecipients(
                    Message.RecipientType.TO,
                    InternetAddress.parse(to));

            message.setSubject(subject);

            message.setText(body);

            Transport.send(message);

            // Optional: Print confirmation when background thread finishes
            // System.out.println("Email sent successfully!");

        } catch (Exception e) {
            System.out.println("Email sending failed.");
            e.printStackTrace();
        }
    }
}