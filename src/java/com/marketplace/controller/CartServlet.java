/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.controller;

import com.marketplace.dao.*;
import com.marketplace.model.*;
import java.io.IOException;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 *
 * @author Afifah Isnarudin
 */
@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

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
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loggedUser");
        if (user == null) { response.sendRedirect("login.jsp"); return; }
        
        String action = request.getParameter("action");
        CartDAO cartDao = new CartDAO();

        if ("add".equals(action)) {
            String itemIdStr = request.getParameter("itemId");
            int quantityToAdd = Integer.parseInt(request.getParameter("quantity"));
            int userId = user.getUserId();
            int itemId = Integer.parseInt(itemIdStr);
            
            Item item = new ItemDAO().getItemById(itemId);
            int currentStock = item.getQty();
            
            CartItem existingItem = cartDao.getCartItemByUserIdAndItemId(userId, itemId);
            
            if(existingItem != null){
                int newTotalQty = existingItem.getQty()+quantityToAdd;
                
                if(newTotalQty > currentStock){
                    response.sendRedirect("item-details.jsp?id=" + itemId + "&error=limit_exceeded");
                    return;
                }
                cartDao.updateCartQuantity(existingItem.getCartId(), newTotalQty);
            }else{
                cartDao.addToCart(userId, itemId, quantityToAdd);
            }
            
//            cartDao.addToCart(user.getUserId(), Integer.parseInt(itemId));
//            response.sendRedirect("cart.jsp");
            response.sendRedirect("cart.jsp?id="+ itemIdStr + "&status=added");
        } 
        else if ("delete".equals(action)) { // Requirement 5 fix
            int cartId = Integer.parseInt(request.getParameter("cartId"));
            cartDao.deleteCartItem(cartId);
            response.sendRedirect("cart.jsp?status=deleted");
        }
        else if ("checkout".equals(action)) {
            int sellerId = Integer.parseInt(request.getParameter("sellerId"));
            
            String method = request.getParameter("paymentMethod");
            User seller = new UserDAO().getUserByUserId(sellerId);
            boolean hasQR = seller.getPaymentQr() != null && !seller.getPaymentQr().trim().isEmpty();
            if ("QR".equals(method) && !hasQR) {
                response.sendRedirect("checkout.jsp?sellerId=" + sellerId + "&total=" +
                        request.getParameter("total") + "&error=invalid_payment");
                return;
            }
            
            List<CartItem> all = cartDao.getCartItems(user.getUserId());
            List<Integer> targets = new ArrayList<Integer>();
            for(CartItem c : all) if(c.getSellerId() == sellerId) targets.add(c.getItemId());
            
            if (new OrderDAO().checkout(user.getUserId(), sellerId, method, targets)) {
                response.sendRedirect("dashboard.jsp?status=order_success");
            }else{
                //if failed: eg. database error or item sold out
                response.sendRedirect("checkout.jsp?sellerId=" + sellerId + "&total=" + request.getParameter("total") + "&error=order_failed");
            }
        }
        else if("update_qty".equals(action)) {
            try {
                int cartId = Integer.parseInt(request.getParameter("cartId"));
                int newQty = Integer.parseInt(request.getParameter("newQty"));
                int itemId = Integer.parseInt(request.getParameter("itemId"));
                
                Item item = new ItemDAO().getItemById(itemId);

                if (newQty >= 1) {
                    
                    if (newQty > item.getQty()) {
                        response.sendRedirect("cart.jsp?status=error&msg=stock_limit");
                        return;
                    }
                    
                    CartDAO dao = new CartDAO();
                    boolean success = dao.updateCartQuantity(cartId, newQty);

                    if (success) {
                        response.sendRedirect("cart.jsp?status=updated");
                    } else {
                        response.sendRedirect("cart.jsp?status=error");
                    }
                } else {
                    response.sendRedirect("cart.jsp");
                }
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("cart.jsp?status=error");
            }
        }
    }
}