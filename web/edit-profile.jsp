<%-- 
    Document   : edit_profile
    Created on : Dec 30, 2025, 2:58:33 AM
    Author     : Afifah Isnarudin
--%>

<%@page import="com.marketplace.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    if(user == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Profile | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="bg-slate-50 min-h-screen flex items-center justify-center p-6 text-slate-900">
    <div class="bg-white w-full max-w-xl rounded-[2.5rem] shadow-xl p-10 md:p-14 border border-slate-100">
        <h1 class="text-3xl font-black mb-2 tracking-tight text-indigo-600">Profile Settings</h1>
        <p class="text-slate-400 font-medium mb-10 text-sm italic">Keep your seller info updated for faster payouts.</p>

        <% if("WrongOldPassword".equals(request.getParameter("error"))) { %>
            <div class="bg-red-50 text-red-600 p-4 rounded-2xl mb-8 text-[11px] font-black uppercase text-center border border-red-100 ring-2 ring-red-50">
                <i class="fas fa-exclamation-triangle mr-2"></i> Password Verification Failed!
            </div>
        <% } %>

        <form action="ProfileServlet" method="POST" enctype="multipart/form-data" class="space-y-6">
            <input type="hidden" name="action" value="edit_profile">
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Display Name</label>
                    <input type="text" name="name" value="<%= user.getName() %>" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none outline-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>
                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Phone Number</label>
                    <input type="text" name="phone" value="<%= user.getPhoneNumber() %>" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none outline-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>

                <% if(user.isIsSeller()) { %>
                <div class="md:col-span-2 bg-indigo-50/50 p-8 rounded-[2rem] border border-indigo-100/50">
                    <label class="block text-[11px] font-black uppercase text-indigo-600 mb-4 ml-1">
                        <%-- REQUIREMENT: Conditional Text Logic --%>
                        <%= (user.getPaymentQr() == null || user.getPaymentQr().isEmpty()) ? "Add DuitNow QR" : "Change DuitNow QR" %>
                    </label>
                    <input type="file" name="qrPhoto" class="text-xs text-slate-500 file:mr-4 file:py-2.5 file:px-6 file:rounded-xl file:border-0 file:text-[10px] file:font-black file:bg-indigo-600 file:text-white hover:file:bg-slate-900 transition cursor-pointer">
                    
                    <% if(user.getPaymentQr() != null && !user.getPaymentQr().isEmpty()) { %>
                        <div class="mt-6 flex items-center gap-4 bg-white p-3 rounded-2xl border border-indigo-100 w-fit">
                            <img src="uploads/qr/<%= user.getPaymentQr() %>" class="w-12 h-12 rounded-lg object-cover shadow-sm">
                            <span class="text-[10px] font-bold text-slate-400 uppercase tracking-widest">Active QR</span>
                        </div>
                    <% } %>
                </div>
                <% } %>

                <div>
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">New Password</label>
                    <input type="password" name="password" placeholder="Leave empty to keep current" class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none outline-none focus:ring-2 focus:ring-indigo-600 font-bold placeholder:text-[10px]">
                </div>
                <div>
                    <label class="block text-[10px] font-black uppercase text-indigo-600 mb-2 underline ml-1 font-bold">Verify Identity *</label>
                    <input type="password" name="oldPassword" placeholder="Current Password" required class="w-full px-6 py-4 rounded-2xl bg-indigo-50 border-none outline-none focus:ring-2 focus:ring-indigo-600 font-black shadow-inner placeholder:text-[10px]">
                </div>
            </div>

            <div class="flex gap-4 pt-6">
                <button type="submit" class="flex-1 bg-slate-900 text-white font-black py-5 rounded-3xl shadow-xl hover:bg-indigo-600 transition hover:-translate-y-1">Update Account</button>
                <a href="dashboard.jsp" class="flex-1 bg-slate-200 text-slate-700 font-black py-5 rounded-3xl text-center flex items-center justify-center border border-slate-100 hover:bg-slate-300 transition hover:-translate-y-1 shadow-sm">Back</a>
            </div>
        </form>
    </div>
</body>
</html>