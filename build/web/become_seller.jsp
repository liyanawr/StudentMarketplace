<%-- 
    Document   : become_seller
    Created on : Dec 30, 2025, 2:05:51 AM
    Author     : Afifah Isnarudin
--%>

<%@page import="com.marketplace.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    if(user == null) { response.sendRedirect("login.jsp"); return; }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Become a Seller | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
</head>
<body class="bg-indigo-600 p-6 min-h-screen flex items-center justify-center">
    <div class="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl p-10 md:p-14">
        <div class="text-center mb-10">
            <h1 class="text-3xl font-black text-slate-900 tracking-tight">Identity Verification</h1>
            <p class="text-slate-400 font-medium text-sm mt-2 italic">Confirm your details to start selling.</p>
        </div>

        <% if("AuthFailed".equals(request.getParameter("error"))) { %>
            <div class="bg-red-50 text-red-500 p-4 rounded-2xl mb-8 text-[10px] font-black uppercase text-center border border-red-100">
                Verification Failed: ID or Password is incorrect!
            </div>
        <% } %>

        <form action="ProfileServlet" method="POST" enctype="multipart/form-data" class="space-y-6">
            <input type="hidden" name="action" value="activate_seller">
            
            <div>
                <label class="block text-[10px] font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">Confirmation ID</label>
                <input type="text" name="verifyId" required 
                       class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 outline-none transition font-black text-slate-700"
                       placeholder="Identification No">
            </div>

            <div>
                <label class="block text-[10px] font-black uppercase tracking-widest text-slate-400 mb-2 ml-1">Account Password</label>
                <input type="password" name="verifyPassword" required 
                       class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none focus:ring-2 focus:ring-indigo-600 outline-none transition font-black text-slate-700"
                       placeholder="••••••••">
            </div>

            <div class="bg-indigo-50/50 p-6 rounded-3xl border border-indigo-100">
                <label class="block text-[10px] font-black uppercase tracking-widest text-indigo-400 mb-3 ml-1">DuitNow QR (Optional)</label>
                <input type="file" name="qrPhoto" id="qrPhoto"
                       class="text-xs text-slate-500 file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-[10px] file:font-black file:bg-white file:text-indigo-600 hover:file:bg-indigo-100 transition">
                <p class="text-[10px] text-slate-400 font-bold mt-4 leading-relaxed">
                    <i class="fas fa-info-circle mr-1 text-indigo-400"></i>  If no QR is uploaded, customers can only pay you via Cash (COD).
                </p>
            </div>

            <button type="submit" class="w-full bg-slate-900 text-white font-black py-5 rounded-3xl shadow-xl hover:bg-indigo-600 transform transition active:scale-95 text-lg">
                Verify and Activate
            </button>
        </form>
        
        <p class="mt-8 text-center">
            <a href="dashboard.jsp" class="text-slate-400 font-bold text-sm hover:text-indigo-600 transition">Return to Dashboard</a>
        </p>
    </div>
    <script>
        document.getElementById('qrPhoto').addEventListener('change', function(e){
            if(this.files && this.files[0]){
                const fileName = this.files[0].name;
                const fileSize = this.files[0].size / 1024 / 1024; //Convert to MB
                
                if(fileSize > 10){
                    Swal.fire({
                        title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #b91c1c;">File Too Large!</span>',
                        html: '<p style="font-family:ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #0f172a;">Maximum size is 10MB. Please choose a smaller image.</p>',
                        icon: 'error',
                        iconColor: '#e11d48',
                        confirmButtonColor: '#0f172a',
                        padding: '1rem',
                        customClass: { 
                            popup: 'rounded-[2.5rem] border-none shadow-2x1',
                            confirmButton: 'px-10 py-4 rounded-2x1 font-black text-lg uppercase tracking-tight'
                        }
                    });
                    this.value = '';
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
        });
        
        //Pop up if Auth Failed (from url)
        const urlParams = new URLSearchParams(window.location.search);
        if (urlParams.get('error') === 'AuthFailed') {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #b91c1c;">Auth Failed!</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #0f172a;">Identification ID or Password is incorrect.</p>',
                icon: 'error',
                iconColor: '#e11d48',
                confirmButtonText: 'Try Again',
                confirmButtonColor: '#0f172a',
                padding: '1rem',
                customClass: {
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-tight'
                }
            }).then(() => {
                window.history.replaceState(null, null, window.location.pathname);
            });
        }
        
        if (urlParams.get('error') === 'server_error') {
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #b91c1c;">System Error!</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #0f172a;">Something went wrong. Please try again later.</p>',
                icon: 'error',
                confirmButtonColor: '#0f172a',
                customClass: { 
                    popup: 'rounded-[2.5rem]border-none shadow-2xl', 
                    confirmButton: 'px-10 py-3 rounded-2xl font-black text-lg uppercase tracking-tight'
                }
            });
        }
    </script>
</body>
</html>