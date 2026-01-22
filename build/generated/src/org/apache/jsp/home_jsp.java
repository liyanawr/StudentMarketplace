package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import java.util.*;
import com.marketplace.dao.*;
import com.marketplace.model.*;

public final class home_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static final JspFactory _jspxFactory = JspFactory.getDefaultFactory();

  private static java.util.List<String> _jspx_dependants;

  private org.glassfish.jsp.api.ResourceInjector _jspx_resourceInjector;

  public java.util.List<String> getDependants() {
    return _jspx_dependants;
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    PageContext pageContext = null;
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;

    try {
      response.setContentType("text/html;charset=UTF-8");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
      out = pageContext.getOut();
      _jspx_out = out;
      _jspx_resourceInjector = (org.glassfish.jsp.api.ResourceInjector) application.getAttribute("com.sun.appserv.jsp.resource.injector");

      out.write("\n");
      out.write("\n");
      out.write("\n");
      out.write("\n");

    User currentUser = (User) session.getAttribute("loggedUser");
    String q = request.getParameter("q");
    String cat = request.getParameter("category");
    String sort = request.getParameter("sort");
    List<Item> items = new ItemDAO().searchItems(q, cat, sort);

      out.write("\n");
      out.write("<!DOCTYPE html>\n");
      out.write("<html>\n");
      out.write("<head>\n");
      out.write("    <title>CampusMart | Discover</title>\n");
      out.write("    <script src=\"https://cdn.tailwindcss.com\"></script>\n");
      out.write("    <link rel=\"stylesheet\" href=\"https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css\">\n");
      out.write("</head>\n");
      out.write("<body class=\"bg-slate-50 font-sans text-slate-900\">\n");
      out.write("    <nav class=\"bg-white border-b sticky top-0 z-50 h-20 flex items-center px-8 justify-between\">\n");
      out.write("        <a href=\"home.jsp\" class=\"text-indigo-600 font-black text-3xl tracking-tighter\">CampusMart</a>\n");
      out.write("        \n");
      out.write("        <form action=\"home.jsp\" method=\"GET\" class=\"flex-grow max-w-xl mx-10 relative\">\n");
      out.write("            <input type=\"text\" name=\"q\" value=\"");
      out.print( q!=null?q:"" );
      out.write("\" placeholder=\"Search textbooks, gadgets...\" \n");
      out.write("                   class=\"w-full pl-12 pr-4 py-3 bg-slate-100 rounded-2xl border-none outline-none focus:ring-2 focus:ring-indigo-600 transition font-medium\">\n");
      out.write("            <i class=\"fas fa-search absolute left-4 top-1/2 -translate-y-1/2 text-slate-400\"></i>\n");
      out.write("        </form>\n");
      out.write("\n");
      out.write("        <div class=\"flex items-center gap-6\">\n");
      out.write("            ");
 if (currentUser == null) { 
      out.write("<a href=\"login.jsp\" class=\"font-bold\">Login</a>");
 } 
            else { 
      out.write("<a href=\"cart.jsp\" class=\"text-slate-600 hover:text-indigo-600 transition\"><i class=\"fas fa-shopping-cart text-xl\"></i></a>\n");
      out.write("            <a href=\"dashboard.jsp\" class=\"bg-indigo-600 text-white px-6 py-3 rounded-2xl font-black shadow-xl\">Dashboard</a>");
 } 
      out.write("\n");
      out.write("        </div>\n");
      out.write("    </nav>\n");
      out.write("\n");
      out.write("    <main class=\"max-w-7xl mx-auto px-8 py-12\">\n");
      out.write("        <div class=\"flex flex-wrap items-center justify-between mb-12 gap-6\">\n");
      out.write("            <h2 class=\"text-3xl font-black text-slate-800\">Marketplace</h2>\n");
      out.write("            <form action=\"home.jsp\" method=\"GET\" class=\"flex items-center gap-4\">\n");
      out.write("                <select name=\"category\" onchange=\"this.form.submit()\" class=\"bg-white border border-slate-200 px-4 py-2 rounded-xl font-bold text-sm outline-none\">\n");
      out.write("                    <option value=\"0\">All Categories</option>\n");
      out.write("                    <option value=\"1\" ");
      out.print( "1".equals(cat) ? "selected" : "" );
      out.write(">Textbooks</option>\n");
      out.write("                    <option value=\"2\" ");
      out.print( "2".equals(cat) ? "selected" : "" );
      out.write(">Electronics</option>\n");
      out.write("                    <option value=\"3\" ");
      out.print( "3".equals(cat) ? "selected" : "" );
      out.write(">Clothing</option>\n");
      out.write("                    <option value=\"4\" ");
      out.print( "4".equals(cat) ? "selected" : "" );
      out.write(">Food</option>\n");
      out.write("                </select>\n");
      out.write("                <select name=\"sort\" onchange=\"this.form.submit()\" class=\"bg-white border border-slate-200 px-4 py-2 rounded-xl font-bold text-sm outline-none\">\n");
      out.write("                    <option value=\"latest\" ");
      out.print( "latest".equals(sort) ? "selected" : "" );
      out.write(">Latest</option>\n");
      out.write("                    <option value=\"cheap\" ");
      out.print( "cheap".equals(sort) ? "selected" : "" );
      out.write(">Cheapest</option>\n");
      out.write("                    <option value=\"pricey\" ");
      out.print( "pricey".equals(sort) ? "selected" : "" );
      out.write(">Pricier</option>\n");
      out.write("                </select>\n");
      out.write("            </form>\n");
      out.write("        </div>\n");
      out.write("\n");
      out.write("        <div class=\"grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-10\">\n");
      out.write("            ");
 for (Item i : items) { 
      out.write("\n");
      out.write("                <div class=\"group bg-white rounded-[2rem] border border-slate-100 shadow-sm overflow-hidden hover:shadow-2xl transition duration-500\">\n");
      out.write("                    <div class=\"h-60 bg-slate-100 relative\">\n");
      out.write("                        <img src=\"uploads/items/");
      out.print( i.getItemPhoto() );
      out.write("\" \n");
      out.write("                             onerror=\"this.src='uploads/items/default.png'\"\n");
      out.write("                             class=\"w-full h-full object-cover group-hover:scale-105 transition duration-700\">\n");
      out.write("                        <div class=\"absolute top-4 left-4 bg-white/90 backdrop-blur px-3 py-1 rounded-xl text-[10px] font-black uppercase tracking-widest text-indigo-600 shadow-sm\">");
      out.print( i.getCategoryName() );
      out.write("</div>\n");
      out.write("                    </div>\n");
      out.write("                    <div class=\"p-8\">\n");
      out.write("                        <h3 class=\"font-black text-xl mb-1 truncate text-slate-800\">");
      out.print( i.getItemName() );
      out.write("</h3>\n");
      out.write("                        <p class=\"text-indigo-600 font-black text-2xl mb-8 italic text-right\">RM ");
      out.print( String.format("%.2f", i.getPrice()) );
      out.write("</p>\n");
      out.write("                        <a href=\"item-details.jsp?id=");
      out.print( i.getItemId() );
      out.write("\" class=\"block text-center w-full py-4 bg-slate-900 text-white font-black rounded-2xl hover:bg-indigo-600 transition shadow-lg shadow-slate-100\">View Details</a>\n");
      out.write("                    </div>\n");
      out.write("                </div>\n");
      out.write("            ");
 } 
      out.write("\n");
      out.write("        </div>\n");
      out.write("    </main>\n");
      out.write("</body>\n");
      out.write("</html>");
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          out.clearBuffer();
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
        else throw new ServletException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
