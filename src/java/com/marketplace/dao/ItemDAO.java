/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package com.marketplace.dao;

import com.marketplace.model.Item;
import com.marketplace.util.DBConnection;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author Afifah Isnarudin
 */
public class ItemDAO {
    public boolean addItem(Item item) {
        String sql = "INSERT INTO items (item_name, description, price, status, item_photo, seller_id, category_id, qty) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, item.getItemName());
            ps.setString(2, item.getDescription());
            ps.setDouble(3, item.getPrice());
            ps.setString(4, "Available");
            ps.setString(5, item.getItemPhoto());
            ps.setInt(6, item.getSellerId());
            ps.setInt(7, item.getCategoryId());
            ps.setInt(8, item.getQty());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public boolean updateItem(Item item) {
        String sql = "UPDATE items SET item_name=?, description=?, price=?, status=?, qty=? WHERE item_id=?";
        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, item.getItemName());
            ps.setString(2, item.getDescription());
            ps.setDouble(3, item.getPrice());
            ps.setString(4, item.getStatus());
            ps.setInt(5, item.getQty());
            ps.setInt(6, item.getItemId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) { e.printStackTrace(); return false; }
    }

    public List<Item> searchItems(String query, String category, String sort) {
        List<Item> list = new ArrayList<>();
        
        // Base SQL query with category join
        StringBuilder sql = new StringBuilder(
            "SELECT i.*, c.category_name FROM items i " +
            "JOIN categories c ON i.category_id = c.category_id " +
            "WHERE i.status = 'Available' AND i.qty > 0 "
        );

        // 1. Dynamic Filtering by Keyword
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (LOWER(i.item_name) LIKE ? OR LOWER(i.description) LIKE ?) ");
        }

        // 2. Dynamic Filtering by Category
        if (category != null && !category.equals("0") && !category.isEmpty()) {
            sql.append("AND i.category_id = ? ");
        }

        // 3. Dynamic Sorting Logic
        if ("cheap".equals(sort)) {
            sql.append("ORDER BY i.price ASC");
        } else if ("pricey".equals(sort)) {
            sql.append("ORDER BY i.price DESC");
        } else {
            // Default sort: Latest items first
            sql.append("ORDER BY i.item_id DESC");
        }

        try (Connection con = DBConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            
            int paramIdx = 1;
            // Bind Keyword parameters
            if (query != null && !query.trim().isEmpty()) {
                String q = "%" + query.toLowerCase() + "%";
                ps.setString(paramIdx++, q);
                ps.setString(paramIdx++, q);
            }
            // Bind Category parameter
            if (category != null && !category.equals("0") && !category.isEmpty()) {
                ps.setInt(paramIdx++, Integer.parseInt(category));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Item> getAllAvailableItems() {
        return searchItems(null, null, "latest");
    }

    public Item getItemById(int id) {
        String sql = "SELECT i.*, c.category_name FROM items i JOIN categories c ON i.category_id = c.category_id WHERE i.item_id = ? AND i.status != 'Deleted'";
        try (Connection con = DBConnection.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (Exception e) { e.printStackTrace(); }
        return null;
    }

    public List<Item> getItemsBySellerId(int sellerId) {
        List<Item> list = new ArrayList<Item>();
        String sql = "SELECT i.*, c.category_name FROM items i " +
                 "JOIN categories c ON i.category_id = c.category_id " +
                 "WHERE i.seller_id = ? AND i.status != 'Deleted' " + 
                 "ORDER BY i.item_id DESC";
        try (Connection con = DBConnection.getConnection(); 
                PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, sellerId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) list.add(mapRow(rs));
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean deleteItem(int id) {
//        try (Connection con = DBConnection.getConnection()) {
//            PreparedStatement ps1 = con.prepareStatement("DELETE FROM cart WHERE item_id = ?");
//            ps1.setInt(1, id); ps1.executeUpdate();
//            PreparedStatement ps2 = con.prepareStatement("DELETE FROM items WHERE item_id = ?");
//            ps2.setInt(1, id); return ps2.executeUpdate() > 0;
//        } catch (Exception e) { e.printStackTrace(); return false; }
        try (Connection con = DBConnection.getConnection()) {
            // Kita tak DELETE, kita cuma UPDATE status jadi 'Deleted'
            // Dengan cara ni, rekod dalam table orders/cart takkan kacau (no error)
            PreparedStatement ps = con.prepareStatement("UPDATE items SET status = 'Deleted' WHERE item_id = ?");
            ps.setInt(1, id); 
            return ps.executeUpdate() > 0;
        } catch (Exception e) { 
            e.printStackTrace(); 
            return false; 
        }
    }

    public boolean increaseStock(int itemId, int amount) {
        String sql = "UPDATE items SET qty = qty + ? WHERE item_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, amount); 
            ps.setInt(2, itemId); 

            int rowsUpdated = ps.executeUpdate();
            return rowsUpdated > 0; 

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private Item mapRow(ResultSet rs) throws SQLException {
        Item i = new Item();
        i.setItemId(rs.getInt("item_id"));
        i.setItemName(rs.getString("item_name"));
        i.setDescription(rs.getString("description"));
        i.setPrice(rs.getDouble("price"));
        i.setStatus(rs.getString("status"));
        i.setItemPhoto(rs.getString("item_photo"));
        i.setSellerId(rs.getInt("seller_id"));
        i.setCategoryId(rs.getInt("category_id"));
        i.setCategoryName(rs.getString("category_name"));
        i.setQty(rs.getInt("qty"));
        return i;
    }
}