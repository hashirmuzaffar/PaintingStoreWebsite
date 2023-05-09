/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;

/**
 *
 * @author hashi
 */
public class rentServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try ( PrintWriter out = response.getWriter()) {

            int C_no = Integer.parseInt(request.getParameter("CNumber"));
            int P_no = Integer.parseInt(request.getParameter("PNumber"));
            String C_date = request.getParameter("CDate");
            PreparedStatement myStmt = null;

            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Success!</title>");
            out.println("<link rel='stylesheet' href='styling.css' />");
            out.println("</head>");
            out.println("<body>");

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");

                Connection conn = (Connection) DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "c##hashirmuz", "hashir");
                runIfOpened(conn);

                // Prepare to call the stored procedure RAISESAL.
                // This sample uses the SQL92 syntax
                CallableStatement cstmt = conn.prepareCall("{? = call check_avail (?)}");

                // Declare that the first ? is a return value of type Int
                cstmt.registerOutParameter(1, Types.CHAR);

                // We want to raise LESLIE's salary by 20,000
                cstmt.setInt(2, P_no);  // The name argument is the second ?

                // Do the raise
                cstmt.execute();

                // Get the new salary back
                String status = cstmt.getString(1);

                System.out.println("The new salary is: " + status);

                // Close the statement
                cstmt.close();
                
                CallableStatement cstmtt = conn.prepareCall("{? = call IsReturned(?)}");

                // Declare that the first ? is a return value of type Int
                cstmtt.registerOutParameter(1, Types.CHAR);

                // We want to raise LESLIE's salary by 20,000
                cstmtt.setInt(2, P_no);  // The name argument is the second ?

                // Do the raise
                cstmtt.execute();

                // Get the new salary back
                String stat = cstmtt.getString(1);

                System.out.println("The new salary is: " + status);

                // Close the statement
                cstmtt.close();
                
                CallableStatement pp = conn.prepareCall("{? = call CALCULATE_PRICE(?,?,?)}");

                // Declare that the first ? is a return value of type Int
                pp.registerOutParameter(1, Types.FLOAT);

                // We want to raise LESLIE's salary by 20,000
                pp.setInt(2, P_no);  // The name argument is the second ?
                pp.setInt(3, C_no);
                pp.setString(4, C_date);
                // Do the raise
                pp.execute();

                // Get the new salary back
                Float due = pp.getFloat(1);
                double own = due*0.10;
                
                System.out.println("The new salary is: " + status);

                // Close the statement
                pp.close();

                if (status.equals("Y") && stat.equals("N")) {
                    String qry = "BEGIN rent_painting(?,?,?); END;";

                    myStmt = conn.prepareStatement(qry);
                    myStmt.setInt(1, C_no);
                    myStmt.setInt(2, P_no);
                    myStmt.setString(3, C_date);
                    int r = myStmt.executeUpdate();
                    if (r == 1) {
                        String str = P_no + " was rented to " + C_no;
                        String str1 = C_no + "'s BILL IS = " + due+"$";
                        String str2 = "OWNERS SHARE " + own +"$";
                        out.println("<h2 class='heading heading2'>Painting was Succesfully rented!</h2>");
                        out.println(str);
                        out.println("<br>");
                        out.println(str1);
                        out.println("<br>");
                        out.println(str2);
                        out.println("<br>");
                        out.println("<a href='index.html'>");
                        out.println("<button class='btn enter Customer'>HOME</button>");
                        out.println("</a>");
                    } else {
                        out.println("<h2 class='heading heading2'>Opps Sorry!</h2>");
                        out.println(P_no + "<h2>Looks like a problem has occured while Adding </h>");
                        out.println("<a href='index.html'>");
                        out.println("<button class='button enter Customer'>CANCEL</button>");
                        out.println("</a>");
                    }
                } else if (status.equals("N") || stat.equals("Y")) {
                    out.println("<h2 class='heading heading2'>Opps Sorry!</h2>");
                    out.println(P_no + "<h2 class='heading'>Painting not available</h><br>");
                    out.println("<a href='index.html'>");
                    out.println("<button class='btn enter Customer'>HOME</button>");
                    out.println("</a>");

                }
                myStmt.close();
                conn.close();

            } catch (Exception e) {
                e.printStackTrace();
            }
            // out.println("</body>");
            // out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

    public static void runIfOpened(Connection connection) throws SQLException {
        if (connection != null && !connection.isClosed()) {
            System.out.print("true");
        } else {
            System.out.print(false);
            // handle closed connection path
        }
    }

}
