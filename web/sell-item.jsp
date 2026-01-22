<%-- 
    Document   : sell-item
    Created on : Nov 18, 2025, 8:54:48 PM
    Author     : Afifah Isnarudin
--%>

<%@page import="com.marketplace.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    if(user == null) { response.sendRedirect("login.jsp"); return; }
    else if(!user.isIsSeller()) { response.sendRedirect("become_seller.jsp"); return; }
    
    boolean hasQR = user.getPaymentQr() != null && !user.getPaymentQr().trim().isEmpty();
%>
<!DOCTYPE html>
<html>
<head>
    <title>List New Item | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body class="bg-slate-50 min-h-screen p-6">
    <div class="max-w-2xl mx-auto bg-white rounded-[2.5rem] shadow-xl p-10 border border-slate-100">
        <h1 class="text-3xl font-black text-slate-900 mb-8">List an Item</h1>
        
        <form action="SellItemServlet" method="POST" enctype="multipart/form-data" class="space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Item Name</label>
                    <input type="text" name="itemName" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>
                
                <div>
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Price (RM)</label>
                    <input type="number" step="0.01" name="price" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>

                <div>
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Category</label>
                    <select name="categoryId" class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold appearance-none">
                        <option value="1">Textbooks</option>
                        <option value="2">Electronics</option>
                        <option value="3">Clothing</option>
                        <option value="4">Food</option>
                        <option value="5">Others</option>
                    </select>
                </div>

                <div>
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Quantity</label>
                    <input type="number" name="qty" value="1" required class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold">
                </div>

                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Description</label>
                    <textarea name="description" rows="3" class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 font-bold"></textarea>
                </div>

                <div class="md:col-span-2">
                    <label class="block text-[10px] font-black uppercase text-slate-400 mb-2 ml-1">Product Image</label>
                    <input type="file" name="itemPhoto" id="itemPhoto" required onchange="handleFileUpload(this)" class="text-xs text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-[10px] file:font-black file:bg-slate-900 file:text-white transition cursor-pointer">
                </div>
            </div>

            <div class="flex gap-4 pt-6">
                <button type="submit" class="flex-1 bg-indigo-600 text-white font-black py-5 rounded-3xl shadow-xl hover:bg-slate-900 transition active:scale-95">Post Listing</button>
                <a href="seller_dashboard.jsp" class="flex-1 bg-slate-200 text-slate-700 font-black py-5 rounded-3xl text-center flex items-center justify-center border border-slate-100 hover:bg-slate-300 transition shadow-sm">Cancel</a>
            </div>
        </form>
    </div>
    
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function handleFileUpload(input){
            if(input.files && input.files[0]){
                const selectedFile = input.files[0];
                const fileName = selectedFile.name;                
                const fileSize = selectedFile.size / 1024 / 1024 //Converts to MB
                
                if(fileSize>10){
                    Swal.fire({
                        title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #b91c1c;">File Too Large!</span>',
                        html: '<p style="font-family:ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #0f172a;">Maximum size is 10MB. Please choose a smaller image.</p>',
                        icon: 'error',
                        iconColor: '#e11d48',
                        confirmButtonColor: '#0f172a',
                        padding: '1rem',
                        customClass: { 
                            popup: 'rounded-[2.5rem] border-none shadow-2xl',
                            confirmButton: 'px-10 py-4 rounded-2x1 font-black text-lg uppercase tracking-tight'
                        }
                    });
                    input.value = "";
                }else{
                    Swal.fire({
                        title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a;">Picture Added!</span>',
                        html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">Picture has been added successfully.</p>',
                        icon: 'success',
                        iconColor: '#4f46e5',
                        confirmButtonText: 'Great!',
                        confirmButtonColor: '#4f46e5',
                        background: '#ffffff',
                        padding: '1rem',
                        customClass: {
                            popup: 'rounded-[2.5rem] border-none shadow-2xl',
                            confirmButton: 'px-10 py-2 rounded-2xl font-black text-lg uppercase tracking-tight'
                        }
                    });
                }
            }
        }
    </script>
</body>
</html>