/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.dao;

import com.marketplace.model.CartItem;
import com.marketplace.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.marketplace.model.Item;
/**
 *
 * @author Afifah Isnarudin
 */
public class CartDAO {
    
    // Add to Cart
    public boolean addToCart(int userId, int itemId, int qty) {
        String sql = "INSERT INTO cart (user_id, item_id, qty) VALUES (?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, itemId);
            ps.setInt(3, qty);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }
    
    //Method to update quantity
    public boolean updateCartQuantity(int cartId, int newQty){
        String sql="UPDATE cart SET qty = ? WHERE cart_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, newQty);
            ps.setInt(2, cartId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<CartItem> getCartItems(int userId) {
        List<CartItem> list = new ArrayList<CartItem>();
        String sql = "SELECT c.cart_id,c.qty, i.item_id, i.item_name, i.price, i.item_photo, u.name as seller_name, u.user_id as seller_id " +
                     "FROM cart c JOIN items i ON c.item_id = i.item_id " +
                     "JOIN users u ON i.seller_id = u.user_id " +
                     "WHERE c.user_id = ? AND i.qty > 0 AND i.status = 'Available'";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                CartItem item = new CartItem();
                item.setCartId(rs.getInt("cart_id"));
                item.setItemId(rs.getInt("item_id"));
                item.setItemName(rs.getString("item_name"));
                item.setPrice(rs.getDouble("price"));
                item.setItemPhoto(rs.getString("item_photo"));
                item.setSellerName(rs.getString("seller_name"));
                item.setSellerId(rs.getInt("seller_id"));
                item.setQty(rs.getInt("qty"));
                list.add(item);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean deleteCartItem(int cartId) {
        String sql = "DELETE FROM cart WHERE cart_id = ?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }
    
    public CartItem getCartItemByUserIdAndItemId(int userId, int itemId) {
        CartItem cartItem = null;
        try {
            String sql = "SELECT * FROM cart WHERE user_id = ? AND item_id = ?";
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, itemId);

            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                cartItem = new CartItem();
                cartItem.setCartId(rs.getInt("cart_id"));
                cartItem.setQty(rs.getInt("qty")); 
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return cartItem; 
    }
}