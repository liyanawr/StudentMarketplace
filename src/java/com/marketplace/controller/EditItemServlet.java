/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.controller;

import com.marketplace.dao.ItemDAO;
import com.marketplace.model.Item;
import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 *
 * @author Afifah Isnarudin
 */
@WebServlet("/EditItemServlet")
public class EditItemServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        try {
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            int newQty = Integer.parseInt(request.getParameter("qty"));
            String newStatus = request.getParameter("status");

            ItemDAO dao = new ItemDAO();
            Item existingItem = dao.getItemById(itemId);

            if (existingItem == null) {
                response.sendRedirect("seller_dashboard.jsp?error=ItemNotFound");
                return;
            }

            int finalQty = newQty;
            String finalStatus = newStatus;

            // 1️⃣ Never allow negative stock
            if (finalQty < 0) {
                finalQty = 0;
            }

            // 2️⃣ If item was sold out and seller switches to Available without qty → revive to 1
            if (existingItem.getQty() == 0
                    && "Available".equals(newStatus)
                    && finalQty == 0) {
                finalQty = 1;
            }

            // 3️⃣ If seller manually sets qty to 0 → SOLD OUT
            if (finalQty == 0) {
                finalStatus = "Sold";
            }

            // 4️⃣ If seller sets qty > 0 → AVAILABLE
            if (finalQty > 0) {
                finalStatus = "Available";
            }

            // 5️⃣ Explicit Sold always locks qty
            if ("Sold".equals(newStatus)) {
                finalQty = 0;
                finalStatus = "Sold";
            }

            Item item = new Item();
            item.setItemId(itemId);
            item.setItemName(request.getParameter("itemName"));
            item.setDescription(request.getParameter("description"));
            item.setPrice(Double.parseDouble(request.getParameter("price")));
            item.setStatus(finalStatus);
            item.setQty(finalQty);

            if (dao.updateItem(item)) {
                response.sendRedirect("seller_dashboard.jsp?msg=ItemUpdated");
            } else {
                response.sendRedirect("edit-item.jsp?id=" + itemId + "&error=UpdateFailed");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("seller_dashboard.jsp?error=InvalidInput");
        }
    }
}