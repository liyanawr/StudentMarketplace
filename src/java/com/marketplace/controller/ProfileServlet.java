/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.controller;

import com.marketplace.dao.UserDAO;
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
@WebServlet("/ProfileServlet")
@MultipartConfig(fileSizeThreshold=1024*1024*2, maxFileSize=1024*1024*10, maxRequestSize=1024*1024*50)
public class ProfileServlet extends HttpServlet {

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
        UserDAO dao = new UserDAO();
        
        String appPath = request.getServletContext().getRealPath("/");
        File qrDir = new File(appPath + "uploads" + File.separator + "qr");
        if (!qrDir.exists()) qrDir.mkdirs();

        if ("activate_seller".equals(action)) {
            String verifyId = request.getParameter("verifyId");
            String verifyPass = request.getParameter("verifyPassword");

            if (verifyId == null || !verifyId.equals(user.getIdentificationNo()) || 
                verifyPass == null || !verifyPass.equals(user.getPassword())) {
                response.sendRedirect("become_seller.jsp?error=AuthFailed");
                return;
            }

            Part part = request.getPart("qrPhoto");
            String fileName = null;
            if (part != null && part.getSize() > 0) {
                String submittedName = part.getSubmittedFileName();
                fileName = submittedName.substring(Math.max(submittedName.lastIndexOf('/'), submittedName.lastIndexOf('\\')) + 1);
                
                File fileToSave = new File(qrDir, fileName);
                try (InputStream input = part.getInputStream()) {
                    Files.copy(input, fileToSave.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            }

            if (dao.activateSeller(user.getUserId(), fileName)) {
                user.setIsSeller(true);
                user.setPaymentQr(fileName);
                response.sendRedirect("seller_dashboard.jsp?msg=Activated");
            }
        }
        else if ("edit_profile".equals(action)) {
            String oldPass = request.getParameter("oldPassword");
            if (oldPass == null || !oldPass.equals(user.getPassword())) {
                response.sendRedirect("edit-profile.jsp?error=WrongOldPassword");
                return;
            }

            String name = request.getParameter("name");
            String phone = request.getParameter("phone");
            String newPass = request.getParameter("password");
            if (newPass == null || newPass.trim().isEmpty()) newPass = user.getPassword();

            Part part = request.getPart("qrPhoto");
            String finalQr = user.getPaymentQr();
            if (part != null && part.getSize() > 0) {
                String submittedName = part.getSubmittedFileName();
                finalQr = submittedName.substring(Math.max(submittedName.lastIndexOf('/'), submittedName.lastIndexOf('\\')) + 1);
                
                File fileToSave = new File(qrDir, finalQr);
                try (InputStream input = part.getInputStream()) {
                    Files.copy(input, fileToSave.toPath(), StandardCopyOption.REPLACE_EXISTING);
                }
            }

            if (dao.updateProfileComplete(user.getUserId(), name, newPass, phone, finalQr)) {
                user.setName(name);
                user.setPhoneNumber(phone);
                user.setPassword(newPass);
                user.setPaymentQr(finalQr);
                response.sendRedirect("dashboard.jsp?status=success");
            }
        }
    }
}