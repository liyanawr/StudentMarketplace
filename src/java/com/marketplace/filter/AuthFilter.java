/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.filter;

import java.io.IOException;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.http.*;

/**
 *
 * @author Afifah Isnarudin
 */
@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Optional: initialization code
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String uri = request.getRequestURI();

        // Allow public resources
        if (uri.endsWith("login.jsp")
                || uri.endsWith("register.jsp")
                || uri.endsWith("home.jsp")
                || uri.endsWith("item-details.jsp")
                || uri.endsWith("LoginServlet")
                || uri.endsWith("RegisterServlet")
                || uri.endsWith("LogoutServlet")
                || uri.contains("/css/")
                || uri.contains("/js/")
                || uri.contains("/uploads/")
                || uri.contains("/images/")) {

            chain.doFilter(req, res);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loggedUser") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // No cache for protected pages
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        chain.doFilter(req, res);
    }

    @Override
    public void destroy() {
        // Optional: cleanup code
    }
}