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
public class resubmitServlet extends HttpServlet {

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

            int P_no = Integer.parseInt(request.getParameter("PNumber"));
            int O_no = Integer.parseInt(request.getParameter("ONumber"));

            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Success!</title>");
            out.println("<link rel='stylesheet' href='styling.css' />");
            out.println("</head>");
            out.println("<body>");
            //out.println("<h2 class='heading heading2'>Painting was Succesfully added!</h2>");

            try {
                Class.forName("oracle.jdbc.driver.OracleDriver");

                Connection myCon = (Connection) DriverManager.getConnection("jdbc:oracle:thin:@localhost:1521:orcl", "c##hashirmuz", "hashir");
                runIfOpened(myCon);
                CallableStatement cstmt = myCon.prepareCall("{? = call eligble_to_ReHire (?)}");

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
                if (status.equals("K")) {
                    String qry = "BEGIN del_return_to_owner(?,?); END;";
                    PreparedStatement myStmt;
                    myStmt = myCon.prepareStatement(qry);
                    myStmt.setInt(1, P_no);
                    myStmt.setInt(2, O_no);
                    int r = myStmt.executeUpdate();
                    myStmt.close();
                    if (r == 1) {
                        out.println(P_no + "<h2 class='heading'> is avaiable for rent now</h><br>");
                        out.println("<a href='index.html'>");
                        out.println("<button class='btn enter Customer'>HOME</button>");
                        out.println("</a>");
                    } else {
                        out.println("<h2>Looks like a problem has occured while Adding </h>" + P_no);
                        out.println("<a href='index.html'>");
                        out.println("<button class='button enter Customer'>CANCEL</button>");
                        out.println("</a>");
                    }
                } else {
                    out.println("<h2>Looks like a problem has occured while Adding </h>" + P_no);
                    out.println("<h2>Its not been three month since its return</h>" + P_no);
                    out.println("<a href='index.html'>");
                    out.println("<button class='button enter Customer'>CANCEL</button>");
                    out.println("</a>");
                }

                myCon.close();

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
