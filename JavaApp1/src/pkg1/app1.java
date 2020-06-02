package pkg1;

import java.io.IOException;
import java.io.PrintWriter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Calendar;
import java.util.concurrent.atomic.AtomicLong;

import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

/**
 * Servlet implementation class app1
 */

@WebServlet("/app1")
public class app1 extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private int counter = 0;
	private static String startTime = null;
	private static final AtomicLong visitors = new AtomicLong(0l);
	private final DateFormat dateFormat = SimpleDateFormat.getDateTimeInstance();
	private String runningVersion;
	private final Calendar calendar = Calendar.getInstance();
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public app1() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see Servlet#init(ServletConfig)
	 */
	public void init(ServletConfig servletConfig) throws ServletException {
		super.init();
	    startTime = dateFormat.format(calendar.getTime());
	    runningVersion = servletConfig.getServletContext().getRealPath("/");
	}

	/**
	 * @see Servlet#getServletConfig()
	 */
	public ServletConfig getServletConfig() {
		// TODO Auto-generated method stub
		return null;
	}

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		if ("true".equals(request.getParameter("forget"))) {
			request.getSession(true).invalidate();
			response.sendRedirect(request.getRequestURI());
			return;
		}
		int waitMs = getIntParameter(request, "waitMs", 0);
		//final Calendar calendar = Calendar.getInstance();
		if (startTime == null) {
			startTime = dateFormat.format(calendar.getTime());
		}

		final HttpSession httpSession = request.getSession(true);
		if (httpSession.isNew()) {
			httpSession.setAttribute("userArrived", dateFormat.format(calendar.getTime()));
		}
		
		counter++;
		//visitors.incrementAndGet();
		PrintWriter out = response.getWriter();	
		out.println("<html>");
		out.println("<head><title>User Session</title></head>");
		out.println("<body bgcolor='gray'>");
		out.println(String.format("<br> Now  %s",getTimeStamp()));
		out.println(String.format("<p>Revision: %s<br/>", runningVersion));
		out.println(String.format("Start Time: %s<br/>", startTime));
		out.println(String.format("Page Visits: %d<br/>", visitors.incrementAndGet()));
		out.println(String.format("Session ID: %s<br/>", httpSession.getId()));
		out.println(String.format("Session Started: %s<br/>", httpSession.getAttribute("userArrived")));
		out.println(String.format("Session waitMs: %d<br/>", waitMs));
		out.println(String.format("<a href=%s> Refresh</a>", request.getRequestURI()));
		out.println(String.format("<a href=%s?forget=true>New Session</a>", request.getRequestURI()));
		out.println("</body></html>");
		try {
			Thread.sleep(waitMs);
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String body = request.getReader().lines().reduce("", (accumulator, actual) -> accumulator + actual);
		
		System.out.println(String.format("POST %s", body));
		
		response.setContentType("text/html; charset=utf-8");
		response.setStatus(HttpServletResponse.SC_OK);
	}
	
	public int getIntParameter(HttpServletRequest request, String name, int v) {
		int result = v;
		try {
			result = Integer.parseInt(request.getParameter(name));
		} catch (Exception e) {
			result = v;
		}
		return result;
	}
	
	public String getTimeStamp() {
		DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
		LocalDateTime now = LocalDateTime.now();
		// System.out.println(dtf.format(now)); //2016/11/16 12:08:43
		return dtf.format(now);
	}

}
