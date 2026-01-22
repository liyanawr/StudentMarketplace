<%-- 
    Document   : rate_seller
    Created on : Dec 30, 2025, 6:21:00 PM
    Author     : Afifah Isnarudin
--%>

<%@page import="com.marketplace.model.User"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    User user = (User) session.getAttribute("loggedUser");
    if(user == null) { response.sendRedirect("login.jsp"); return; }
    String orderId = request.getParameter("id");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Rate Experience | CampusMart</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        /* CSS Trick: Sibling selector turns previous stars yellow when hover/check */
        .star-rating { display: flex; flex-direction: row-reverse; justify-content: center; gap: 10px; }
        .star-rating input { display: none; }
        .star-rating label { color: #e2e8f0; font-size: 3rem; cursor: pointer; transition: 0.2s; }
        .star-rating input:checked ~ label,
        .star-rating label:hover,
        .star-rating label:hover ~ label { color: #fbbf24 !important; }
    </style>
</head>
<body class="bg-indigo-600 min-h-screen flex items-center justify-center p-6">
    <div class="bg-white w-full max-w-md rounded-[2.5rem] shadow-2xl p-10 text-center">
        <h1 class="text-3xl font-black text-slate-900 mb-2">Rate Seller</h1>
        <p class="text-slate-400 font-medium mb-10 text-sm">Order #<%= orderId %></p>

        <form action="OrderServlet" method="POST" class="space-y-8" id="ratingForm">
            <input type="hidden" name="action" value="rate">
            <input type="hidden" name="orderId" value="<%= orderId %>">
            
            <div class="star-rating">
                <input type="radio" name="score" value="5" id="s5"><label for="s5"><i class="fas fa-star"></i></label>
                <input type="radio" name="score" value="4" id="s4"><label for="s4"><i class="fas fa-star"></i></label>
                <input type="radio" name="score" value="3" id="s3"><label for="s3"><i class="fas fa-star"></i></label>
                <input type="radio" name="score" value="2" id="s2"><label for="s2"><i class="fas fa-star"></i></label>
                <input type="radio" name="score" value="1" id="s1" checked><label for="s1"><i class="fas fa-star"></i></label>
            </div>

            <textarea name="comment" rows="3" placeholder="Feedback..." class="w-full px-6 py-4 rounded-2xl bg-slate-50 border-none outline-none focus:ring-2 focus:ring-indigo-600 font-bold text-slate-700"></textarea>

            <button type="button" onclick="confirmRating()" class="w-full bg-slate-900 text-white font-black py-5 rounded-3xl shadow-xl hover:bg-indigo-700 transition transform active:scale-95 text-lg">Submit</button>
        </form>
    </div>
            
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function confirmRating(){
            const score = document.querySelector('input[name="score"]:checked').value;
            
            Swal.fire({
                title: '<span style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 900; color: #0f172a">Submit Rating?</span>',
                html: '<p style="font-family: ui-sans-serif, system-ui, sans-serif; font-weight: 500; color: #64748b;">You are giving this seller ' + score + ' stars.</p>',
                icon: 'question',
                showCancelButton: true,
                confirmButtonColor: '#4f46e5', // Warna indigo
                cancelButtonColor: '#64748b',
                confirmButtonText: 'Yes, Submit!',
                cancelButtonText: 'Review Again',
                customClass: {
                    popup: 'rounded-[2.5rem] border-none shadow-2xl',
                    confirmButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight',
                    cancelButton: 'px-10 py-4 rounded-2xl font-black text-lg uppercase tracking-tight'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    document.getElementById('ratingForm').submit();
                }
            });
        }        
    </script>
</body>
</html>