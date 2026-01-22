<%-- 
    Document   : cart
    Created on : Dec 30, 2025, 1:59:16 AM
    Author     : Afifah Isnarudin
--%>

<%@page import="java.util.*"%>
<%@page import="com.marketplace.dao.CartDAO, com.marketplace.model.*"%>
<%@page import="com.marketplace.model.Item"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    if(user == null) { 
        response.sendRedirect("login.jsp"); 
        return; 
    }
    
    List<CartItem> cartItems = new CartDAO().getCartItems(user.getUserId());
    
    Map<Integer, List<CartItem>> sellerGroups = new HashMap<Integer, List<CartItem>>();
    if (cartItems != null) {
        for (CartItem item : cartItems) {
            Integer sId = item.getSellerId();
            if (!sellerGroups.containsKey(sId)) {
                sellerGroups.put(sId, new ArrayList<CartItem>());
            }
            sellerGroups.get(sId).add(item);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>My Cart | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="bg-slate-50 font-sans text-slate-900">
    <nav class="bg-white border-b border-slate-200">
        <div class="max-w-5xl mx-auto px-6 h-20 flex justify-between items-center">
            <a href="home.jsp" class="text-indigo-600 font-black text-2xl tracking-tighter">CampusMart</a>
            <a href="dashboard.jsp" class="font-bold text-slate-500 hover:text-indigo-600 uppercase text-xs tracking-widest transition">Dashboard</a>
        </div>
    </nav>

    <main class="max-w-4xl mx-auto px-6 py-12">
        <h1 class="text-4xl font-black mb-2 tracking-tight text-slate-900">Shopping Cart</h1>
        <p class="text-slate-400 font-medium mb-12">Items are grouped by seller. Pay one seller at a time.</p>

        <% if(cartItems == null || cartItems.isEmpty()) { %>
            <div class="text-center py-24 bg-white rounded-[3rem] border border-slate-200 shadow-sm">
                <div class="w-24 h-24 bg-slate-50 text-slate-200 rounded-full flex items-center justify-center mx-auto mb-8 text-4xl shadow-inner">
                    <i class="fas fa-shopping-basket"></i>
                </div>
                <p class="text-slate-400 font-black text-2xl">Your cart is empty</p>
                <a href="home.jsp" class="inline-block mt-8 bg-indigo-600 text-white px-8 py-4 rounded-2xl font-black hover:bg-indigo-700 transition shadow-lg shadow-indigo-100">Browse Items</a>
            </div>
        <% } else { 
            for(Map.Entry<Integer, List<CartItem>> entry : sellerGroups.entrySet()) {
                List<CartItem> items = entry.getValue();
                String sellerName = (items != null && !items.isEmpty()) ? items.get(0).getSellerName() : "Unknown Seller";
                double subtotal = 0;
                if(items != null) {
                    for(CartItem subItem : items) { 
                        subtotal += (subItem.getPrice() * subItem.getQty()); 
                    }
                }
        %>
            <div class="bg-white rounded-[2.5rem] shadow-sm border border-slate-200 overflow-hidden mb-10">
                <div class="bg-slate-50/80 px-10 py-5 border-b border-slate-200 flex justify-between items-center">
                    <span class="text-[10px] font-black uppercase tracking-[0.2em] text-slate-400">Seller Account</span>
                    <span class="font-black text-slate-800 text-lg"><%= sellerName %></span>
                </div>
                
                <div class="p-10 space-y-8">
                    <% for(CartItem ci : items) { %>
                        <div class="flex items-center gap-8">
                            <div class="w-20 h-20 bg-slate-100 rounded-2xl flex-shrink-0 overflow-hidden shadow-inner border border-slate-200">
                                <img src="<%= request.getContextPath() %>/uploads/items/<%= ci.getItemPhoto() %>" 
                                     class="w-full h-full object-cover" 
                                     onerror="this.src='https://placehold.co/200x200?text=No+Image'">
                            </div>

                            <div class="flex-grow">
                                <h4 class="font-black text-xl text-slate-800 leading-tight mb-1"><%= ci.getItemName() %></h4>
                                
                                <div class="flex items-center gap-6 mt-2">
                                    <p class="text-indigo-600 font-black text-lg italic">RM <%= String.format("%.2f", ci.getPrice()) %></p>

                                    <div class="flex items-center bg-slate-100 rounded-xl p-1 border border-slate-200">
                                        <form action="CartServlet" method="POST" class="inline">
                                            <input type="hidden" name="action" value="update_qty">
                                            <input type="hidden" name="cartId" value="<%= ci.getCartId() %>">
                                            <input type="hidden" name="itemId" value="<%= ci.getItemId() %>">
                                            <input type="hidden" name="newQty" value="<%= ci.getQty() - 1 %>">
                                            <button type="submit" <%= (ci.getQty() <= 1) ? "disabled" : "" %> 
                                                    class="w-8 h-8 flex items-center justify-center hover:bg-white rounded-lg transition disabled:opacity-30 text-slate-500">
                                                <i class="fas fa-minus text-[10px]"></i>
                                            </button>
                                        </form>

                                        <span class="w-10 text-center font-black text-slate-700 text-sm">
                                            <%= ci.getQty() %>
                                        </span>

                                        <form action="CartServlet" method="POST" class="inline">
                                            <input type="hidden" name="action" value="update_qty">
                                            <input type="hidden" name="cartId" value="<%= ci.getCartId() %>">
                                            <input type="hidden" name="itemId" value="<%= ci.getItemId() %>">
                                            <input type="hidden" name="newQty" value="<%= ci.getQty() + 1 %>">
                                            
                                            <%
                                                int itemStock = new com.marketplace.dao.ItemDAO().getItemById(ci.getItemId()).getQty();
                                            %>
                                            
                                            <button type="submit" <%= (ci.getQty() >= itemStock) ? "disabled" : "" %> 
                                                    class="w-8 h-8 flex items-center justify-center hover:bg-white rounded-lg transition disabled:opacity-30 text-slate-500">
                                                <i class="fas fa-plus text-[10px]"></i>
                                            </button>
                                        </form>
                                    </div>
                                </div>
                                <p class="text-[10px] text-slate-400 font-bold mt-2 uppercase tracking-widest">
                                    Subtotal: RM <%= String.format("%.2f", ci.getPrice() * ci.getQty()) %>
                                </p>
                            </div>

                            <form action="CartServlet" method="POST" id="deleteForm<%= ci.getCartId() %>">
                                <input type="hidden" name="action" value="delete">
                                <input type="hidden" name="cartId" value="<%= ci.getCartId() %>">
                                <button type="button" onclick="confirmDelete(<%= ci.getCartId()%>)" 
                                        class="w-16 h-16 rounded-[1.5rem] bg-red-50 text-red-300 hover:text-red-500 hover:bg-red-100 transition-all flex items-center justify-center transform hover:rotate-12">
                                    <i class="fas fa-trash-alt text-lg"></i>
                                </button>
                            </form>
                        </div>
                    <% } %>
                </div>

                <div class="bg-indigo-50/30 p-10 flex flex-col md:flex-row justify-between items-center gap-8 border-t border-indigo-100">
                    <div>
                        <p class="text-slate-400 text-[10px] font-black uppercase tracking-[0.2em] mb-2">Group Subtotal</p>
                        <p class="text-3xl font-black text-indigo-600 italic tracking-tight">RM <%= String.format("%.2f", subtotal) %></p>
                    </div>
                    <form action="checkout.jsp" method="POST" class="w-full md:w-auto">
                        <input type="hidden" name="sellerId" value="<%= entry.getKey() %>">
                        <input type="hidden" name="sellerName" value="<%= sellerName %>">
                        <input type="hidden" name="total" value="<%= String.format("%.2f", subtotal) %>">
                        <button type="submit" class="w-full md:w-auto bg-slate-900 text-white font-black px-12 py-5 rounded-2xl shadow-xl shadow-slate-200 hover:bg-indigo-600 transition transform active:scale-95 text-lg">
                            Checkout with Seller
                        </button>
                    </form>
                </div>
            </div>
        <% 
            } 
        } 
        %>
    </main>
    
    <script>
        const urlParams = new URLSearchParams(window.location.search);
        const status = urlParams.get('status');

        if (status === 'added') {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Success!</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">Successfully added to cart.</p>',
                icon: 'success',
                iconColor: '#4f46e5',
                confirmButtonText: 'Great!',
                confirmButtonColor: '#4f46e5',
                background: '#ffffff',
                padding: '1rem',
                customClass: {
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-light'
                }
            })        
        }

        if (status === 'deleted') {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Item Removed</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748;">Your cart has been updated.</p>',
                icon: 'info',
                iconColor: '#0f172a',
                confirmButtonColor: '#0f172a',
                confirmButtonText: 'Done',
                background: '#ffffff',
                padding: '1rem',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-light'
                }
            }).then(() => { window.history.replaceState(null, null, window.location.pathname); });
        }

        function confirmDelete(cartId) {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #b91c1c;">Remove Item?</span>',
                text: "Are you sure you want to take this item out?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#e11d48',
                cancelButtonColor: '#0f172a',
                confirmButtonText: 'Yes, remove it!',
                background: '#ffffff',
                padding: '1rem',
                customClass: { 
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-light',
                    cancelButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-light'
                }
            }).then((result) => {
                if (result.isConfirmed) { document.getElementById('deleteForm' + cartId).submit(); }
            });
        }
    </script>
</body>
</html>