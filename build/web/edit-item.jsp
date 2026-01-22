<%-- 
    Document   : edit-item
    Created on : Nov 18, 2025, 8:55:19 PM
    Author     : Afifah Isnarudin
--%>
<%@page import="com.marketplace.dao.ItemDAO, com.marketplace.model.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    String id = request.getParameter("id");
    if(user == null || id == null) { response.sendRedirect("login.jsp"); return; }
    
    Item item = new ItemDAO().getItemById(Integer.parseInt(id));
    if(item == null || item.getSellerId() != user.getUserId()) { response.sendRedirect("seller_dashboard.jsp"); return; }
    
    boolean hasQR = user.getPaymentQr() != null && !user.getPaymentQr().trim().isEmpty();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Listing | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
</head>
<body class="bg-slate-50 min-h-screen p-6">
    <div class="max-w-2xl mx-auto bg-white rounded-[2.5rem] shadow-xl p-10 border border-slate-100">
        <h1 class="text-3xl font-black text-slate-900 mb-8">Update Listing</h1>
        
        <form action="EditItemServlet" method="POST" class="space-y-6">
            <input type="hidden" name="itemId" value="<%= item.getItemId() %>">
            
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Item Name</label>
                    <input type="text" name="itemName" value="<%= item.getItemName() %>" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>

                <div>
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Price (RM)</label>
                    <input type="number" step="0.01" min="0" name="price" value="<%= item.getPrice() %>" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>

                <div>
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Inventory Qty</label>
                    <input type="number" name="qty" min="0" value="<%= item.getQty() %>" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>

                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Stock Status</label>
                    <select name="status" class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold appearance-none text-indigo-600">
                        <option value="Available" <%= "Available".equals(item.getStatus()) ? "selected" : "" %>>Available</option>
                        <option value="Sold" <%= "Sold".equals(item.getStatus()) ? "selected" : "" %>>Sold Out</option>
                    </select>
                </div>

                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Description</label>
                    <textarea name="description" rows="3" class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold"><%= item.getDescription() %></textarea>
                </div>
            </div>

            <div class="flex gap-4 pt-6">
                <button type="submit" class="flex-1 bg-slate-900 text-white font-black py-5 rounded-3xl shadow-xl hover:bg-indigo-600 transition">Save Changes</button>
                <a href="seller_dashboard.jsp" class="flex-1 bg-slate-100 text-slate-400 font-black py-5 rounded-3xl text-center flex items-center justify-center">Cancel</a>
            </div>
        </form>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
    const qty = document.querySelector("input[name='qty']");
    const status = document.querySelector("select[name='status']");

    qty.addEventListener("input", () => {
        const q = parseInt(qty.value) || 0;
        status.value = q > 0 ? "Available" : "Sold";
    });
    </script>
    <script>
        const urlParams = new URLSearchParams(window.location.search);
                    
        if(urlParams.get('error') === 'UpdateFailed'){
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight:900; color: #b91c1c;">Update Failed</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #0f172a;">Something went wrong while saving your changes. Please check your connection.</p>',
                icon: 'error',
                confirmButtonColor: '#0f172a',
                background: '#fffffff',
                padding:'1rem',
                customClass: {
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                },
                backdrop: 'rgba(79, 70, 229, 0.15)',
                allowOutsideClick: false
            }).then(() => {
                window.history.replaceState(null, null, window.location.pathname + "?id=<%= id %>");
            })
        }
    </script>
</body>
</html>