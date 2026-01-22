/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.controller;

import com.marketplace.dao.*;
import com.marketplace.model.Order;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 *
 * @author Afifah Isnarudin
 */
@WebServlet(name = "OrderServlet", urlPatterns = {"/OrderServlet"})
public class OrderServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        OrderDAO dao = new OrderDAO();
        
        if ("updateStatus".equals(action)) {
            int id = Integer.parseInt(request.getParameter("orderId"));
            String status = request.getParameter("status");
            
            Order currentOrder = dao.getOrderById(id);
            
            if(dao.updateOrderStatus(id, status)){
                if("Completed".equals(status)){
                    response.sendRedirect("seller_dashboard.jsp?msg=SaleConfirmed");
                }else if("Available".equals(status)){
                    if(currentOrder != null){
                        ItemDAO itemDao = new ItemDAO();
                        itemDao.increaseStock(currentOrder.getItemId(), currentOrder.getQty());
                    }
                    response.sendRedirect("seller_dashboard.jsp?msg=OrderCancelled");
                }else{
                    response.sendRedirect("seller_dashboard.jsp?msg=OrderUpdated");
                }
            }else{
                response.sendRedirect("seller_dashboard.jsp?error=UpdateFailed");
            }
        } else if ("rate".equals(action)) {
            try{
                int id = Integer.parseInt(request.getParameter("orderId"));
                int score = Integer.parseInt(request.getParameter("score"));
                String comm = request.getParameter("comment");
                
                boolean success = dao.addRating(id, score, comm);
                
                if(success){
                    response.sendRedirect("dashboard.jsp?msg=RatingSuccess");
                }else{
                    response.sendRedirect("dashboard.jsp?error=RatingFailed");
                }
            } catch(Exception e){
                e.printStackTrace();
                response.sendRedirect("dashboard.jsp?error=InvalidRating");
            }
        }
    }
}
