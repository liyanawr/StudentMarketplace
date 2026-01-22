<%-- 
    Document   : checkout
    Created on : Dec 30, 2025, 2:00:03 AM
    Author     : Afifah Isnarudin
--%>

<%@page import="com.marketplace.model.*, com.marketplace.dao.*, java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    if(user == null) { response.sendRedirect("login.jsp"); return; }

    String sellerIdParam = request.getParameter("sellerId");
    String totalParam = request.getParameter("total");
    
    if(sellerIdParam == null || totalParam == null){
        response.sendRedirect("cart.jsp");
        return;
    }
    
    int sId = Integer.parseInt(sellerIdParam);
    User seller = new UserDAO().getUserByUserId(sId);
    
    String total = totalParam;
    
    boolean hasQR = seller.getPaymentQr() != null && !seller.getPaymentQr().trim().isEmpty();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Checkout | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="bg-indigo-600 p-6 min-h-screen flex items-center justify-center">
    <div class="bg-white w-full max-w-lg rounded-[2.5rem] p-10 md:p-14 shadow-2xl relative">
        <a href="cart.jsp" class="absolute top-10 left-10 text-slate-400 hover:text-indigo-600 font-bold text-sm transition"><i class="fas fa-arrow-left mr-2"></i> Back</a>
        <h1 class="text-3xl font-black text-center mb-10 mt-6 tracking-tight text-slate-900">Checkout</h1>
        
        <div class="bg-slate-50 p-6 rounded-3xl mb-8 flex justify-between items-center border border-slate-100">
            <span class="font-bold text-slate-400 uppercase text-[10px] tracking-widest">To Pay</span>
            <span class="font-black text-2xl text-indigo-600 italic">RM <%= total %></span>
        </div>

        <form action="CartServlet" method="POST" class="space-y-8">
            <input type="hidden" name="action" value="checkout">
            <input type="hidden" name="sellerId" value="<%= sId %>">
            
            <div>
                <label class="block text-[10px] font-black uppercase text-slate-400 mb-4 tracking-widest ml-1">Payment Method</label>
                <div class="grid grid-cols-1 gap-4">
                    <!-- COD is always available -->
                    <label class="relative flex items-center p-6 rounded-2xl bg-slate-50 cursor-pointer has-[:checked]:bg-indigo-600 has-[:checked]:text-white font-black transition border-2 border-transparent has-[:checked]:border-indigo-300">
                        <input type="radio" name="paymentMethod" value="COD" checked class="hidden" onclick="toggleQR(false)">
                        <i class="fas fa-handshake mr-4 text-xl"></i> Cash on Delivery
                    </label>

                    <!-- QR only available if seller has uploaded it -->
                    <% if(hasQR) { %>
                        <label class="relative flex items-center p-6 rounded-2xl bg-slate-50 cursor-pointer has-[:checked]:bg-indigo-600 has-[:checked]:text-white font-black transition border-2 border-transparent has-[:checked]:border-indigo-300">
                            <input type="radio" name="paymentMethod" value="QR" class="hidden" onclick="toggleQR(true)">
                            <i class="fas fa-qrcode mr-4 text-xl"></i> DuitNow QR
                        </label>
                    <% } else { %>
                        <div class="p-6 rounded-2xl bg-slate-100 opacity-60 flex items-center border-2 border-dashed border-slate-200">
                            <i class="fas fa-qrcode mr-4 text-xl text-slate-400"></i>
                            <div>
                                <p class="text-[10px] font-black uppercase text-slate-500">QR Unavailable</p>
                                <p class="text-[10px] font-bold text-slate-400 italic">Seller has no payment QR</p>
                            </div>
                        </div>
                    <% } %>
                </div>
            </div>

            <div id="qr-box" class="hidden bg-indigo-50 p-8 rounded-[2rem] text-center border-2 border-dashed border-indigo-200">
                <img src="uploads/qr/<%= seller.getPaymentQr() %>" class="w-48 h-48 mx-auto rounded-3xl shadow-xl mb-6" onerror="this.src='https://placehold.co/200x200?text=QR+Error'">
                <p class="text-[10px] font-bold text-indigo-600 italic">SAVE RECEIPT: Contact seller after payment.</p>
            </div>
            
            <button type="submit" class="w-full bg-slate-900 text-white font-black py-5 rounded-3xl shadow-xl hover:bg-indigo-700 transition active:scale-95 text-lg">
                Place Order
            </button>
        </form>
    </div>
    <script>
        function toggleQR(show) {
            const qrBox = document.getElementById('qr-box');
            if(show) qrBox.classList.remove('hidden');
            else qrBox.classList.add('hidden');
        }
    </script>
</body>
</html>