/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.controller;

import com.marketplace.dao.ItemDAO;
import com.marketplace.model.Item;
import com.marketplace.model.User;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

/**
 *
 * @author Afifah Isnarudin
 */

@WebServlet("/SellItemServlet")
@MultipartConfig(fileSizeThreshold=1024*1024*2, maxFileSize=1024*1024*10, maxRequestSize=1024*1024*50)
public class SellItemServlet extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("loggedUser");
        
        if (user == null) { 
            response.sendRedirect("login.jsp"); 
            return; 
        }

        try {
            String appPath = request.getServletContext().getRealPath("");
            String uploadPath = appPath + File.separator + "uploads" + File.separator + "items";
            
            File itemsDir = new File(uploadPath);
            if (!itemsDir.exists()) itemsDir.mkdirs();

            String fileName = "default.png";
            Part part = request.getPart("itemPhoto");
            
//            if (part != null && part.getSize() > 0) {
//                String submittedName = part.getSubmittedFileName();
//                fileName = submittedName.substring(Math.max(submittedName.lastIndexOf('/'), submittedName.lastIndexOf('\\')) + 1);
//                
//                // FIXED: Direct stream copy bypasses GlassFish absolute path bugs
//                File fileToSave = new File(itemsDir, fileName);
//                try (InputStream input = part.getInputStream()) {
//                    Files.copy(input, fileToSave.toPath(), StandardCopyOption.REPLACE_EXISTING);
//                }
//            }

            if (part != null && part.getSize() > 0) {
                // 2. FIX FILENAME: Buat nama unik & buang spasi
                String originalName = part.getSubmittedFileName();
                String extension = originalName.substring(originalName.lastIndexOf("."));
                // Contoh: item_1705500000_gambar.png
                fileName = "item_" + System.currentTimeMillis() + "_" + originalName.replaceAll("\\s+", "_");
                
                File fileToSave = new File(itemsDir, fileName);
                
                // 3. Simpan fail guna InputStream
                try (InputStream input = part.getInputStream()) {
                    Files.copy(input, fileToSave.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
                
                // Debug: Tengok kat console/output NetBeans mana gambar ni pergi
                System.out.println("Picture are kept at : " + fileToSave.getAbsolutePath());
            }

            Item item = new Item();
            item.setItemName(request.getParameter("itemName"));
            item.setDescription(request.getParameter("description"));
            
            // Safe Numeric Parsing
            String priceStr = request.getParameter("price");
            String catStr = request.getParameter("categoryId");
            String qtyStr = request.getParameter("qty");

            item.setPrice(parsePrice(priceStr));
            item.setCategoryId(parseInteger(catStr, 5)); 
            item.setQty(parseInteger(qtyStr, 1)); 
            
            item.setItemPhoto(fileName);
            item.setSellerId(user.getUserId());

            if (new ItemDAO().addItem(item)) {
                response.sendRedirect("seller_dashboard.jsp?status=success");
            } else {
                response.sendRedirect("sell-item.jsp?error=error");
            }
        } catch (Exception e) {
            e.printStackTrace(); 
            response.sendRedirect("sell-item.jsp?error=InvalidInput");
        }
    }

    private double parsePrice(String val) {
        if (val == null || val.trim().isEmpty()) return 0.0;
        try {
            return Double.parseDouble(val.replaceAll("[^0-9.]", ""));
        } catch (Exception e) { return 0.0; }
    }

    private int parseInteger(String val, int defaultVal) {
        if (val == null || val.trim().isEmpty()) return defaultVal;
        try {
            return Integer.parseInt(val.replaceAll("[^0-9]", ""));
        } catch (Exception e) { return defaultVal; }
    }
}