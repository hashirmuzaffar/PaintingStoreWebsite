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
public class RentalServlet extends HttpServlet {

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
                CallableStatement cstmt = conn.prepareCall("{? = call DISPLAY_CUSTOMER_DETAILS (?)}");

                // Declare that the first ? is a return value of type Int
                cstmt.registerOutParameter(1, Types.VARCHAR);

                // We want to raise LESLIE's salary by 20,000
                cstmt.setInt(2, C_no);  // The name argument is the second ?

                // Do the raise
                cstmt.execute();

                // Get the new salary back
                String display = cstmt.getString(1);
                String[] str = display.split("_");

                        out.println("<h2 class='heading heading2'>Customer Rental Report</h2>");
                        out.println("<a href='index.html'>");
                        out.println("<button class='btn enter Customer'>HOME</button><br>");
                        out.println("</a>");
                        for(int i=0;i<str.length;i++){
                        out.println(str[i]+"<p class='dt'></p>");
                        }

                // Close the statement
                cstmt.close();

                CallableStatement cstmt2 = conn.prepareCall("{? = call CUSTOMER_REPORT_VIEW (?)}");

                // Declare that the first ? is a return value of type Int
                cstmt2.registerOutParameter(1, Types.VARCHAR);

                // We want to raise LESLIE's salary by 20,000
                cstmt2.setInt(2, C_no);  // The name argument is the second ?

                // Do the raise
                cstmt2.execute();

                // Get the new salary back
                display = cstmt2.getString(1);
                String[] str2 = display.split("_");
                        out.println("--------------------------------------------------------------------------------------------"+"<br>");
                        out.println("Painting No  |  "+" Painting Title  |   "+" Painting Theme  |  "+" Date of Hire |  "+" Due Date  |   "+" Returned ");
                        for(int i=0;i<str.length;i++){
                        out.println(str2[i]+"<p class='dt'></p>");
                        }
                       

                // Close the statement
                cstmt2.close();
                conn.close();
                 
                        out.println("</body>");
             out.println("</html>");

            } catch (Exception e) {
                e.printStackTrace();
            }
             
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
