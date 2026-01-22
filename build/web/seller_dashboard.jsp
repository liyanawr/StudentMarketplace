<%-- 
    Document   : seller_dashboard
    Created on : Dec 30, 2025, 2:53:12 AM
    Author     : Afifah Isnarudin
--%>

<%@page import="java.util.List, com.marketplace.dao.*, com.marketplace.model.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    if(user == null || !user.isIsSeller()) { response.sendRedirect("login.jsp"); return; }
    
    List<Item> myItems = new ItemDAO().getItemsBySellerId(user.getUserId());
    List<Order> mySales = new OrderDAO().getSellerSales(user.getUserId());
    
    double revenue = 0;
    int soldCount = 0;
    int activeListings = 0;
    
    for(Item i : myItems) if("Available".equals(i.getStatus())) activeListings++;
    for(Order s : mySales) {
        if("Completed".equals(s.getStatus())) {
            revenue += s.getPrice();
            soldCount++;
        }
    }
%>
<%!
    private boolean hasPendingOrder(int itemId, List<Order> sales) {
        if (sales == null) return false;
        for(Order o : sales) {
            // Check jika ID barang sama DAN status adalah Pending
            if(o.getItemId() == itemId && "Pending".equals(o.getStatus())) {
                return true;
            }
        }
        return false;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Seller Center | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="bg-slate-50 font-sans text-slate-900">
    <nav class="bg-slate-900 h-20 flex items-center px-10 justify-between sticky top-0 z-50 text-white">
        <a href="home.jsp" class="text-indigo-400 font-black text-2xl tracking-tighter">CampusMart</a>
        <div class="flex items-center gap-8">
            <a href="dashboard.jsp" class="font-black text-xs uppercase text-slate-500 hover:text-white transition">Buyer Mode</a>
            <a href="LogoutServlet" class="bg-red-500/10 text-red-500 p-2 rounded-xl transition hover:bg-red-500"><i class="fas fa-sign-out-alt"></i></a>
        </div>
    </nav>

    <div class="max-w-7xl mx-auto px-10 py-12">
        <!-- Dashboard Statistics -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-8 mb-16">
            <div class="bg-white p-10 rounded-[2.5rem] border border-slate-200 shadow-sm">
                <p class="text-[10px] font-black uppercase text-slate-400 tracking-widest">Active Listings</p>
                <h3 class="text-4xl font-black mt-2 text-slate-900"><%= activeListings %> Items</h3>
            </div>
            <div class="bg-indigo-600 p-10 rounded-[2.5rem] text-white shadow-2xl shadow-indigo-100">
                <p class="text-[10px] font-black uppercase text-indigo-200 tracking-widest">Revenue</p>
                <h3 class="text-4xl font-black italic mt-2">RM <%= String.format("%.2f", revenue) %></h3>
            </div>
            <div class="bg-white p-10 rounded-[2.5rem] border border-slate-200 shadow-sm">
                <p class="text-[10px] font-black uppercase text-slate-400 tracking-widest">Successful Sales</p>
                <h3 class="text-4xl font-black text-emerald-500 mt-2"><%= soldCount %> Items</h3>
            </div>
        </div>
            
        <h2 class="text-3xl font-black mb-10 pt-5 tracking-tight">Orders & Feedback</h2>
        <div class="bg-white rounded-[3rem] border overflow-hidden shadow-sm mb-20">
            <table class="w-full text-left">
                <thead class="bg-slate-50 border-b">
                    <tr><th class="px-10 py-8 text-[10px] font-black uppercase text-slate-400">Order Detail</th><th class="px-10 py-8 text-right text-[10px] font-black uppercase text-slate-400">Action/Rating</th></tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    <% for(Order s : mySales) { %>
                    <%
                        String waMsg = "Hello! I’m the seller for your order: '" 
                                     + s.getItemName() 
                                     + "'. Please let me know regarding payment / pickup.";

                        String buyerPhone = s.getBuyerPhone();
                        if (buyerPhone != null && buyerPhone.startsWith("0")) {
                            buyerPhone = "6" + buyerPhone; // Malaysia format
                        }

                        String waUrl = "https://wa.me/" + buyerPhone +
                                       "?text=" + java.net.URLEncoder.encode(waMsg, "UTF-8");
                    %>
                    <tr class="hover:bg-slate-50 transition duration-300">
                        <td class="px-10 py-10">
                            <div class="space-y-3">

                                <!-- Item Name -->
                                <p class="font-black text-slate-900 text-xl leading-tight">
                                    <%= s.getItemName() %>
                                </p>

                                <!-- Order Meta -->
                                <div class="flex items-center gap-4 text-xs font-black">

                                    <!-- Qty Badge -->
                                    <span class="bg-slate-100 text-slate-700 px-3 py-1 rounded-full uppercase tracking-wide">
                                        Qty <%= s.getQty() %>
                                    </span>

                                    <!-- Subtotal -->
                                    <span class="bg-emerald-50 text-emerald-600 px-3 py-1 rounded-full uppercase tracking-wide">
                                        RM <%= String.format("%.2f", s.getPrice()) %>
                                    </span>

                                </div>

                                <!-- Buyer Contact -->
                                <a href="<%= waUrl %>" target="_blank"
                                    class="inline-flex items-center gap-2 mt-3
                                           bg-green-500 text-white px-5 py-2.5 rounded-xl
                                           font-black text-xs shadow-lg shadow-green-100
                                           hover:bg-green-600 transition">

                                     <i class="fab fa-whatsapp"></i>
                                     Chat Buyer
                                 </a>

                            </div>
                        </td>
                        <td class="px-10 py-10 text-right">
                            <% if("Pending".equals(s.getStatus())) { %>
                            <p class="text-xs font-bold text-slate-400 mb-2">
                                Qty Ordered: <%= s.getQty() %>
                            </p>
                            <div class="flex justify-end gap-3">
                                <form action="OrderServlet" method="POST"><input type="hidden" name="action" value="updateStatus"><input type="hidden" name="orderId" value="<%= s.getOrderId() %>"><input type="hidden" name="status" value="Completed"><button class="bg-indigo-600 text-white px-5 py-2.5 rounded-2xl font-black text-xs shadow-lg shadow-indigo-100 hover:bg-indigo-700 transition">Confirm Sale</button></form>
                                <form action="OrderServlet" method="POST"><input type="hidden" name="action" value="updateStatus"><input type="hidden" name="orderId" value="<%= s.getOrderId() %>"><input type="hidden" name="status" value="Available"><button class="bg-red-50 text-red-500 px-5 py-2.5 rounded-2xl font-black text-xs hover:bg-red-100 transition">Cancel Order</button></form>
                            </div>
                            <% } else if(s.isIsRated()) { 
                                    String rawData = s.getPaymentMethod();
                                    String displayFeedback = "No feedback";

                                    if(rawData != null && rawData.contains("(") && rawData.contains(")")) {
                                        displayFeedback = rawData.substring(rawData.indexOf("(") + 1, rawData.lastIndexOf(")"));
                                    }
                                %>
                                    <div class="inline-block text-left bg-yellow-50 p-4 rounded-2xl border border-yellow-100 max-w-xs">
                                        <span class="text-[10px] font-black text-yellow-600 uppercase">Rated Transaction</span>
                                        <p class="text-slate-700 font-bold text-xs mt-1">Feedback: "<%= displayFeedback %>"</p>
                                    </div>
<!--                                <div class="inline-block text-left bg-yellow-50 p-4 rounded-2xl border border-yellow-100 max-w-xs">
                                    <span class="text-[10px] font-black text-yellow-600 uppercase">Rated Transaction</span>
                                    <p class="text-slate-700 font-bold text-xs mt-1">Feedback: "<%= s.getPaymentMethod().substring(s.getPaymentMethod().indexOf("(")+1, s.getPaymentMethod().length()-1) %>"</p>
                                </div>-->
                            <% } else { %>
                                <span class="text-xs font-black text-slate-300 uppercase tracking-widest italic"><%= s.getStatus() %> Transaction</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
            
        <div class="flex justify-between items-center mb-10 pt-5 border-t">
            <h2 class="text-3xl font-black tracking-tight">Active Inventory</h2>
            <a href="sell-item.jsp" class="bg-slate-900 text-white px-10 py-5 rounded-[2rem] font-black shadow-xl">+ New Product</a>
        </div>
        <div class="bg-white rounded-[3rem] border overflow-hidden shadow-sm">
            <table class="w-full text-left">
                <thead class="bg-slate-50 border-b">
                    <tr><th class="px-10 py-8 text-[10px] font-black uppercase text-slate-400">Product Info</th><th class="px-10 py-8 text-right text-[10px] font-black uppercase text-slate-400">Manage</th></tr>
                </thead>
                <tbody class="divide-y divide-slate-100">
                    <% for(Item i : myItems) { %>
                    <tr class="hover:bg-slate-50 transition">
                        <td class="px-10 py-10 flex items-center gap-10">
                            <div class="w-20 h-20 bg-slate-100 rounded-3xl overflow-hidden border shadow-inner"><img src="uploads/items/<%= i.getItemPhoto() %>" class="w-full h-full object-cover"></div>
                            <div><p class="font-black text-2xl text-slate-800 leading-tight mb-2"><%= i.getItemName() %></p><span class="bg-indigo-50 text-indigo-600 text-[10px] font-black uppercase px-3 py-1 rounded-lg">Stock: <%= i.getQty() %> • RM <%= i.getPrice() %></span></div>
                        </td>
                        <td class="px-10 py-10 text-right space-x-3">
                            <a href="edit-item.jsp?id=<%= i.getItemId() %>" class="inline-flex items-center justify-center w-14 h-14 bg-slate-100 text-slate-400 rounded-2xl hover:bg-indigo-600 hover:text-white transition"><i class="fas fa-edit"></i></a>
                            <% if(hasPendingOrder(i.getItemId(), mySales)) { %>
                            <button onclick="alertPendingTransaction()" class="inline-flex items-center justify-center w-14 h-14 bg-red-50 text-amber-500 rounded-2xl hover:bg-amber-500 hover:text-white transition">
                                <i class="fas fa-trash-alt"></i>
                            </button>
                            <%} else{%>
                                <button onclick="confirmDelete(<%= i.getItemId() %>)" class="inline-flex items-center justify-center w-14 h-14 bg-red-50 text-red-500 rounded-2xl hover:bg-red-500 hover:text-white transition">
                                    <i class="fas fa-trash-alt"></i>
                                </button>
                            <% } %> 
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>
    <script>
        const urlParams = new URLSearchParams(window.location.search);
        
        const msg = urlParams.get('msg');
        const status = urlParams.get('status');
        const errorParam = urlParams.get('error');
    
        if (msg === 'Activated') {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Congratulations!</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">You are now officially a <b>CampusMart Seller</b>. Let\'s start selling!</p>',
                icon: 'success',
                iconColor: '#4f46e5',
                confirmButtonText: 'Let\'s Go!',
                confirmButtonColor: '#4f46e5',
                background: '#ffffff',
                padding: '1rem',
                customClass: {
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(() => {
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        //1.Success Confirm Sale
        if(msg === 'SaleConfirmed'){
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Sale Confirmed!</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">Transaction completed. Your revenue has been updated!</p>',
                icon: 'success',
                iconColor: '#4f46e5',
                confirmButtonText: 'Awesome!',
                confirmButtonColor: '#4f46e5',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2x1', 
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(()=>{
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        //2. Success Cancel Order
        if(msg === 'OrderCancelled'){
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Order Cancelled</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">The item has been returned to your active inventory.</p>',
                icon: 'info',
                iconColor: '#0f172a',
                confirmButtonText: 'Done',
                confirmButtonColor: '#0f172a',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2x1',
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(() => {
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        //3.Order Updated
        if(msg === 'OrderUpdated'){
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Updated!</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">The order status has been successfully modified!</p>',
                icon: 'success',
                iconColor: '#4f46e5',
                confirmButtonText: 'Awesome!',
                confirmButtonColor: '#4f46e5',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2x1', 
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(()=>{
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        //4.Update Failed
        if (errorParam === 'UpdateFailed') {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #b91c1c;">Update Failed</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">Something went wrong while updating the order. Please try again.</p>',
                icon: 'error',
                iconColor: '#e11d48',
                confirmButtonText: 'Try Again',
                confirmButtonColor: '#0f172a',
                background: '#ffffff',
                padding: '1rem',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2x1',
                    confirmButton: 'px-10 py-4 roundeed-2x1 font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(()=>{
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        if(status === 'success'){
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Item Listed!</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">Your item has been successfully added to CampusMart.</p>',
                icon: 'success',
                iconColor: '#4f46e5',
                confirmButtonText: 'View My Shop',
                confirmButtonColor: '#4f46e5',
                background: '#ffffff',
                padding: '1rem',
                customClass: {
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            })
        }
        
        if(msg === 'OrderUpdated'){
            Swal.fire({
            title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Item Updated!</span>',
            html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">Your product details have been successfully refreshed.</p>',
            icon: 'success',
            iconColor: '#4f46e5',
            confirmButtonText: 'Great!',
            confirmButtonColor: '#4f46e5',
            customClass: { 
                popup: 'rounded-[2.5rem] border-none shadow-2xl', 
                confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
            },
            backdrop: 'rgba(79, 70, 229, 0.15)',
            allowOutsideClick: false
            }).then(()=>{
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        function confirmDelete(id) {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900;">Are you sure?</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">You won\'t be able to revert this!<p>',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#e11d48',
                cancelButtonColor: '#0f172a',
                confirmButtonText: 'Yes, delete it!',
                background: '#ffffff',
                padding: '1rem',
                customClass: {
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-light',
                    cancelButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-light'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then((result) => {
                if (result.isConfirmed) {
                    window.location.href = 'DeleteServlet?id=' + id;
                }
            })
        }
        
        if(msg === 'Deleted'){
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif ; font-weight: 900; color: #0f172a;">Item Removed</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">The product has been successfully deleted.</p>',
                icon: 'success',
                iconColor: '#4f46e5',
                confirmButtonText: 'Done',
                confirmButtonColor: '#4f46e5',
                background: '#ffffff',
                padding: '1rem',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2xl', 
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(()=>{
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        if(errorParam === 'DeleteFailed'){
            Swal.fire({
                icon: 'error',
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif ; font-weight: 900; color: #b91c1c;">Delete Failed</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif ; font-weight: 900; color: #b91c1c;">Something went wrong. This item might be part of an existing order.</p>',
                iconColor: '#e11d48',
                confirmButtonColor: '#0f172a',
                background: '#ffffff',
                padding: '1rem',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(()=>{
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        function alertPendingTransaction() {
    Swal.fire({
        title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Action</span>',
        html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">This item <b>cannot be deleted</b> because this item have pending transaction.</p>',
        icon: 'warning',
        iconColor: '#f59e0b',
        confirmButtonText: 'I Understand',
        confirmButtonColor: '#0f172a',
        padding: '1rem',
        background: '#ffffff',
        customClass: {
            popup: 'rounded-[2.5rem] border-none shadow-2xl',
            confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
        },
        backdrop: 'rgba(79, 70, 229, 0.15)'
    });
}
    </script>
</body>
</html>