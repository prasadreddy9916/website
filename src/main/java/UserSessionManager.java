import jakarta.servlet.http.HttpSession;
import java.util.concurrent.ConcurrentHashMap;
import java.util.logging.Logger;

public class UserSessionManager {
    private static final ConcurrentHashMap<String, HttpSession> activeSessions = new ConcurrentHashMap<>();
    private static final Logger LOGGER = Logger.getLogger(UserSessionManager.class.getName());

    public static void registerSession(String email, HttpSession session) {
        if (email == null || session == null) {
            LOGGER.warning("Attempted to register session with null email or session");
            return;
        }

        synchronized (UserSessionManager.class) {
            HttpSession oldSession = activeSessions.get(email);
            if (oldSession != null) {
                try {
                    oldSession.invalidate();
                    LOGGER.info("Invalidated old session for email: " + email);
                } catch (IllegalStateException e) {
                    LOGGER.info("Old session for " + email + " was already invalidated");
                }
            }
            activeSessions.put(email, session);
            LOGGER.info("Registered new session for email: " + email);
        }
    }

    public static void removeSession(String email) {
        if (email == null) {
            LOGGER.warning("Attempted to remove session with null email");
            return;
        }

        synchronized (UserSessionManager.class) {
            HttpSession session = activeSessions.remove(email);
            if (session != null) {
                try {
                    session.invalidate();
                    LOGGER.info("Removed and invalidated session for email: " + email);
                } catch (IllegalStateException e) {
                    LOGGER.info("Session for " + email + " was already invalidated");
                }
            } else {
                LOGGER.info("No session found to remove for email: " + email);
            }
        }
    }

    public static HttpSession getSession(String email) {
        if (email == null) {
            LOGGER.warning("Attempted to get session with null email");
            return null;
        }

        synchronized (UserSessionManager.class) {
            HttpSession session = activeSessions.get(email);
            if (session != null && isSessionValid(session)) {
                return session;
            }
            // Remove stale or invalid session
            activeSessions.remove(email);
            LOGGER.info("Removed invalid or expired session for email: " + email);
            return null;
        }
    }

    private static boolean isSessionValid(HttpSession session) {
        try {
            session.getAttribute("email");
            return true;
        } catch (IllegalStateException e) {
            return false;
        }
    }

    // New method to clean up all invalid sessions
    public static void cleanupInvalidSessions() {
        synchronized (UserSessionManager.class) {
            activeSessions.entrySet().removeIf(entry -> !isSessionValid(entry.getValue()));
            LOGGER.info("Cleaned up invalid sessions");
        }
    }
}