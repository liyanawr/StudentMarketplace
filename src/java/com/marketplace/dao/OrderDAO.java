/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.dao;

import com.marketplace.model.Order;
import com.marketplace.model.CartItem;
import com.marketplace.model.Item;
import com.marketplace.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Afifah Isnarudin
 */
public class OrderDAO {
    
    // Sales tracking with integrated ratings and buyer contact
    public List<Order> getSellerSales(int sellerId) {
        List<Order> list = new ArrayList<Order>();
        String sql = "SELECT o.order_id, o.item_id, o.qty, o.status, o.payment_method, " +
        "o.price AS subtotal, " +
        "i.item_name, u.phone_number AS buyer_phone, " +
        "r.score, r.comment " +
        "FROM orders o " +
        "JOIN items i ON o.item_id = i.item_id " +
        "JOIN users u ON o.buyer_id = u.user_id " +
        "LEFT JOIN ratings r ON o.order_id = r.order_id " +
        "WHERE o.seller_id = ? ORDER BY o.order_id DESC";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order();
                o.setOrderId(rs.getInt("order_id"));
                o.setItemId(rs.getInt("item_id"));
                o.setItemName(rs.getString("item_name"));
                o.setQty(rs.getInt("qty"));
                o.setPrice(rs.getDouble("subtotal"));
                o.setBuyerPhone(rs.getString("buyer_phone"));
                o.setPaymentMethod(rs.getString("payment_method"));
                o.setStatus(rs.getString("status"));
                o.setIsRated(rs.getObject("score") != null);
                
                // If rated, we combine the info for the Seller to see
                if(o.isIsRated()) {
                    o.setPaymentMethod(o.getPaymentMethod() + " (" + rs.getInt("score") + "⭐: " + rs.getString("comment") + ")");
                }
                list.add(o);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean updateOrderStatus(int orderId, String newStatus) {
        Connection con = null;
        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);
            PreparedStatement ps = con.prepareStatement("UPDATE orders SET status = ? WHERE order_id = ?");
            ps.setString(1, "Available".equals(newStatus) ? "Cancelled" : newStatus);
            ps.setInt(2, orderId);
            ps.executeUpdate();

            if ("Available".equals(newStatus)) {
                String resSql = "UPDATE items SET status = 'Available' " +
                                "WHERE item_id = (SELECT item_id FROM orders WHERE order_id = ?)";
                PreparedStatement psRes = con.prepareStatement(resSql);
                psRes.setInt(1, orderId);
                psRes.executeUpdate();
                ps.setString(1, "Cancelled");
                ps.executeUpdate();
            }
            con.commit();
            return true;
        } catch (Exception e) {
            try { if(con!=null) con.rollback(); } catch(Exception ex){}
            return false;
        }
    }

    public boolean checkout(int buyerId, int sellerId, String paymentMethod, List<Integer> itemIds) {
        Connection con = null;

        try {
            con = DBConnection.getConnection();
            con.setAutoCommit(false);

            String oSql =
                "INSERT INTO orders (buyer_id, item_id, seller_id, qty, price, payment_method, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, 'Pending')";

            String iSql =
                "UPDATE items SET qty = qty - ? WHERE item_id = ?";

            String statusSql =
                "UPDATE items SET status = 'Sold' WHERE item_id = ? AND qty <= 0";

            String cSql =
                "DELETE FROM cart WHERE user_id = ? AND item_id = ?";

            PreparedStatement psO = con.prepareStatement(oSql);
            PreparedStatement psI = con.prepareStatement(iSql);
            PreparedStatement psS = con.prepareStatement(statusSql);
            PreparedStatement psC = con.prepareStatement(cSql);

            CartDAO cartDao = new CartDAO();
            ItemDAO itemDao = new ItemDAO();

            for (int itemId : itemIds) {

                CartItem cart = cartDao.getCartItemByUserIdAndItemId(buyerId, itemId);
                Item item = itemDao.getItemById(itemId);

                if (cart == null || item == null) {
                    con.rollback();
                    return false;
                }

                int qty = cart.getQty();
                double subtotal = item.getPrice() * qty;

                // Save order
                psO.setInt(1, buyerId);
                psO.setInt(2, itemId);
                psO.setInt(3, sellerId);
                psO.setInt(4, qty);
                psO.setDouble(5, subtotal);
                psO.setString(6, paymentMethod);
                psO.addBatch();

                // Deduct stock
                psI.setInt(1, qty);
                psI.setInt(2, itemId);
                psI.addBatch();

                // Update item status if sold out
                psS.setInt(1, itemId);
                psS.addBatch();

                // Remove from cart
                psC.setInt(1, buyerId);
                psC.setInt(2, itemId);
                psC.addBatch();
            }

            psO.executeBatch();
            psI.executeBatch();
            psS.executeBatch();
            psC.executeBatch();

            con.commit();
            return true;

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return false;
        }
    }

    public boolean addRating(int orderId, int score, String comment) {
        String sql = "INSERT INTO ratings (order_id, score, comment) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId); ps.setInt(2, score); ps.setString(3, comment); return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Order> getBuyerHistory(int buyerId) {
        List<Order> list = new ArrayList<Order>();
        String sql = "SELECT o.*, i.item_name, u.phone_number AS seller_phone,\n" +
                    "       (SELECT COUNT(*) FROM ratings r WHERE r.order_id = o.order_id) AS rCount\n" +
                    "FROM orders o\n" +
                    "JOIN items i ON o.item_id = i.item_id\n" +
                    "JOIN users u ON o.seller_id = u.user_id\n" +
                    "WHERE o.buyer_id = ?\n" +
                    "ORDER BY o.order_id DESC";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, buyerId); ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order(); o.setOrderId(rs.getInt("order_id")); o.setItemName(rs.getString("item_name"));
                o.setPrice(rs.getDouble("price")); o.setSellerPhone(rs.getString("seller_phone"));
                o.setPaymentMethod(rs.getString("payment_method")); o.setStatus(rs.getString("status"));
                o.setIsRated(rs.getInt("rCount") > 0); list.add(o);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    
    public Order getOrderById(int orderId) {
        Order order = null;
        String sql = "SELECT * FROM orders WHERE order_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                order = new Order();
                order.setOrderId(rs.getInt("order_id"));
                order.setItemId(rs.getInt("item_id"));
                order.setQty(rs.getInt("qty"));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return order;
    }
}