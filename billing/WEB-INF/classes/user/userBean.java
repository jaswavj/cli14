
package user;
import java.sql.*;
import java.util.*;
import java.text.*;

import com.sun.rowset.*; 	
import javax.sql.rowset.*;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

public class userBean {

    public userBean() {
    }
    
    // Password hashing utility - Updated to SHA-512
    private String hashPassword(String password) throws Exception {
        java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-512");
        byte[] hash = md.digest(password.getBytes("UTF-8"));
        StringBuilder sb = new StringBuilder();
        for (byte b : hash) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
    
    // Check software license validity
    public boolean checkLicenseValidity() throws Exception {
        Connection con = null;
        Statement checkStmt = null;
        ResultSet checkRs = null;
        Statement dateStmt = null;
        ResultSet dateRs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            // Check license days from heading table (active field = number of days)
            String checkSql = "SELECT active FROM heading WHERE id = 1";
            checkStmt = con.createStatement();
            checkRs = checkStmt.executeQuery(checkSql);
            
            int licenseDays = 0;
            if (checkRs.next()) {
                licenseDays = checkRs.getInt("active");
            }
            
            // If active field is 0 or less, license check is disabled
            if (licenseDays <= 0) {
                return true;
            }
            
            // Get the first entry date from prod_bill
            String dateSql = "SELECT MIN(date) as first_date FROM prod_bill";
            dateStmt = con.createStatement();
            dateRs = dateStmt.executeQuery(dateSql);
            
            if (dateRs.next()) {
                java.sql.Date firstDate = dateRs.getDate("first_date");
                
                // If no data in prod_bill, allow login
                if (firstDate == null) {
                    return true;
                }
                
                // Calculate days between first date and today
                long firstTimeMillis = firstDate.getTime();
                long todayTimeMillis = System.currentTimeMillis();
                long daysDiff = (todayTimeMillis - firstTimeMillis) / (1000 * 60 * 60 * 24);
                
                // Use the active field value directly as number of days
                long allowedDays = licenseDays;
                
                // If exceeded license period, deny access
                if (daysDiff > allowedDays) {
                    return false;
                }
            } else {
                // No data in prod_bill, allow login
                return true;
            }
            
            return true;
            
        } finally {
            if (checkRs != null) {
                try { checkRs.close(); } catch (SQLException e) { }
            }
            if (checkStmt != null) {
                try { checkStmt.close(); } catch (SQLException e) { }
            }
            if (dateRs != null) {
                try { dateRs.close(); } catch (SQLException e) { }
            }
            if (dateStmt != null) {
                try { dateStmt.close(); } catch (SQLException e) { }
            }
            if (con != null) {
                try { con.close(); } catch (Exception e) { }
            }
        }
    }
    
    public Connection check() throws SQLException
   		{
		return util.DBConnectionManager.getConnectionFromPool();
		}
//////////////////////////----------------------------
public Vector getUserCredential() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT user_name,PASSWORD,id FROM `users` WHERE is_active=1;");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector(); 

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			vec.addElement(rs.getString(3) );
			

		major.addElement(vec);

		}
		return major;
	}
finally
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
//////////////////////////--------------------------
public Vector getUserPermission(int uid)throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT module_id FROM `user_permission` WHERE uid=?;");	
	
		pt.setInt(1,uid);
		
		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));

		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
public boolean addUser(String fullName, String userName, String password, String[] modules) {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con						= util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);

            // 1. Insert into users table
            ps = con.prepareStatement(
                "INSERT INTO users(user_name,password,is_active,fullName) VALUES(?,?,1,?)",
                Statement.RETURN_GENERATED_KEYS
            );
            ps.setString(1, userName);
            ps.setString(2, hashPassword(password));  
            ps.setString(3, fullName);
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            int uid = 0;
            if (rs.next()) {
                uid = rs.getInt(1);
            }
            rs.close();
            ps.close();

            // 2. Insert module permissions
            if (modules != null) {
                ps = con.prepareStatement("INSERT INTO user_permission(module_id, uid) VALUES(?, ?)");
                for (String moduleId : modules) {
                    ps.setInt(1, Integer.parseInt(moduleId));
                    ps.setInt(2, uid);
                    ps.addBatch();
                }
                ps.executeBatch();
            }

            con.commit();
            return true;

        } catch (Exception e) {
            try { if (con != null) con.rollback(); } catch (Exception ex) {}
            e.printStackTrace();
            return false;
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
    }
    public Vector getUserModules()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT a.id,a.`module_name` FROM `user_modules` a;");	
	

		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));
		vec1.addElement(rs.getString(2));


		vec.addElement(vec1);
		}
	return vec;
	 }
 	finally 
		{
		if (rs != null)
			{
      		try	 { rs.close(); } catch (SQLException e) { ; }
      		rs = null;
			}
			
		if (pt != null)
			{
      		try	 { pt.close(); } catch (SQLException e) { ; }
      		pt = null;
			}
		    		
		if(con!= null)			
			{
			try{con.close();}catch(Exception e){}
			con = null;	
			}
		}
}
public String getUserName(int id)throws Exception
	{
			Connection con 			= null;
	PreparedStatement pt	= null;
	ResultSet rs			= null;
	try{
	
	con						= util.DBConnectionManager.getConnectionFromPool();
	pt = con.prepareStatement("SELECT fullName FROM `users` WHERE id=?;");
	pt.setInt(1,id);
	rs=pt.executeQuery();
	if(rs.next())
		{
		return rs.getString(1);
		}
	return null;
	}
finally
	{
	if (pt != null)
		{
		try	 { pt.close(); } catch (SQLException e) { ; }
		pt = null;
		}
		
	if (rs != null)
		{
		try	 { rs.close(); } catch (SQLException e) { ; }
		rs = null;
		}
		    		
	if(con!= null)			
		{
		try{con.close();}catch(Exception e){}
		con = null;	
		}
	}
	}
public String getHead1()throws Exception
	{
			Connection con 			= null;
	PreparedStatement pt	= null;
	ResultSet rs			= null;
	try{
	
	con						= util.DBConnectionManager.getConnectionFromPool();
	pt = con.prepareStatement("SELECT head1 FROM `heading`");
	
	rs=pt.executeQuery();
	if(rs.next())
		{
		return rs.getString(1);
		}
	return null;
	}
finally
	{
	if (pt != null)
		{
		try	 { pt.close(); } catch (SQLException e) { ; }
		pt = null;
		}
		
	if (rs != null)
		{
		try	 { rs.close(); } catch (SQLException e) { ; }
		rs = null;
		}
		    		
	if(con!= null)			
		{
		try{con.close();}catch(Exception e){}
		con = null;	
		}
	}
	}
	public String getHead2()throws Exception
	{
			Connection con 			= null;
	PreparedStatement pt	= null;
	ResultSet rs			= null;
	try{
	
	con						= util.DBConnectionManager.getConnectionFromPool();
	pt = con.prepareStatement("SELECT head2 FROM `heading`");
	
	rs=pt.executeQuery();
	if(rs.next())
		{
		return rs.getString(1);
		}
	return null;
	}
finally
	{
	if (pt != null)
		{
		try	 { pt.close(); } catch (SQLException e) { ; }
		pt = null;
		}
		
	if (rs != null)
		{
		try	 { rs.close(); } catch (SQLException e) { ; }
		rs = null;
		}
		    		
	if(con!= null)			
		{
		try{con.close();}catch(Exception e){}
		con = null;	
		}
	}
	}
	public String getHead3()throws Exception
	{
			Connection con 			= null;
	PreparedStatement pt	= null;
	ResultSet rs			= null;
	try{
	
	con						= util.DBConnectionManager.getConnectionFromPool();
	pt = con.prepareStatement("SELECT head3 FROM `heading`");
	
	rs=pt.executeQuery();
	if(rs.next())
		{
		return rs.getString(1);
		}
	return null;
	}
finally
	{
	if (pt != null)
		{
		try	 { pt.close(); } catch (SQLException e) { ; }
		pt = null;
		}
		
	if (rs != null)
		{
		try	 { rs.close(); } catch (SQLException e) { ; }
		rs = null;
		}
		    		
	if(con!= null)			
		{
		try{con.close();}catch(Exception e){}
		con = null;	
		}
	}
	}
//////////////////////////---------------------------

    // Method to update user password by user ID (for migration)
    public void updateUserPassword(int userId, String hashedPassword) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            pt = con.prepareStatement("UPDATE users SET password=? WHERE id=?");
            pt.setString(1, hashedPassword);
            pt.setInt(2, userId);
            pt.executeUpdate();
            con.commit();
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }
    
    // Get all special permissions from special_permission table
    public Vector getAllSpecialPermissions() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector permissions = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            pt = con.prepareStatement("SELECT id, content FROM special_permission ORDER BY id");
            rs = pt.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getInt("id"));
                row.addElement(rs.getString("content"));
                permissions.addElement(row);
            }
            
            return permissions;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }
    
    // Check if user has a specific special permission
    public boolean checkUserSpecialPermission(int userId, int contentId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            pt = con.prepareStatement("SELECT COUNT(*) FROM user_special_permission WHERE user_id = ? AND content_id = ?");
            pt.setInt(1, userId);
            pt.setInt(2, contentId);
            rs = pt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }
    
    // Get user's special permissions
    public Vector getUserSpecialPermissions(int userId) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        Vector permissions = new Vector();
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            pt = con.prepareStatement("SELECT content_id FROM user_special_permission WHERE user_id = ?");
            pt.setInt(1, userId);
            rs = pt.executeQuery();
            
            while (rs.next()) {
                Vector row = new Vector();
                row.addElement(rs.getInt("content_id"));
                permissions.addElement(row);
            }
            
            return permissions;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }
    
    // Update user special permissions
    public void updateUserSpecialPermissions(int userId, String[] permissionIds) throws Exception {
        Connection con = null;
        PreparedStatement ptDelete = null;
        PreparedStatement ptInsert = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            // First, delete all existing permissions for this user
            ptDelete = con.prepareStatement("DELETE FROM user_special_permission WHERE user_id = ?");
            ptDelete.setInt(1, userId);
            ptDelete.executeUpdate();
            
            // Then insert the new permissions
            if (permissionIds != null && permissionIds.length > 0) {
                ptInsert = con.prepareStatement("INSERT INTO user_special_permission (content_id, user_id) VALUES (?, ?)");
                
                for (String permissionId : permissionIds) {
                    ptInsert.setInt(1, Integer.parseInt(permissionId));
                    ptInsert.setInt(2, userId);
                    ptInsert.addBatch();
                }
                
                ptInsert.executeBatch();
            }
            
            con.commit();
        } catch (Exception e) {
            if (con != null) con.rollback();
            throw e;
        } finally {
            if (ptDelete != null) try { ptDelete.close(); } catch (SQLException e) { ; }
            if (ptInsert != null) try { ptInsert.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }
    
    // Get company details
    public Vector getCompanyDetails() throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            pt = con.prepareStatement("SELECT id, shop_name, address, gstin, print_type, printer_name, bank_details, barcode_printer FROM company_details LIMIT 1");
            rs = pt.executeQuery();
            
            Vector details = new Vector();
            if (rs.next()) {
                details.addElement(rs.getInt("id"));
                details.addElement(rs.getString("shop_name"));
                details.addElement(rs.getString("address"));
                details.addElement(rs.getString("gstin"));
                details.addElement(rs.getInt("print_type"));
                details.addElement(rs.getString("printer_name"));
                details.addElement(rs.getString("bank_details"));
                details.addElement(rs.getString("barcode_printer"));
            }
            
            return details;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) try { con.close(); } catch (Exception e) { ; }
        }
    }
    
    // Save or update company details
    public boolean saveCompanyDetails(String shopName, String address, String gstin, int printType, String printerName, String bankDetails, String barcodePrinter) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);  // Start transaction
            
            // Check if record exists
            pt = con.prepareStatement("SELECT id FROM company_details LIMIT 1");
            rs = pt.executeQuery();
            
            if (rs.next()) {
                // Update existing record
                int id = rs.getInt("id");
                rs.close();
                pt.close();
                
                pt = con.prepareStatement("UPDATE company_details SET shop_name=?, address=?, gstin=?, print_type=?, printer_name=?, bank_details=?, barcode_printer=? WHERE id=?");
                pt.setString(1, shopName);
                pt.setString(2, address);
                pt.setString(3, gstin);
                pt.setInt(4, printType);
                pt.setString(5, printerName);
                pt.setString(6, bankDetails);
                pt.setString(7, barcodePrinter);
                pt.setInt(8, id);
                pt.executeUpdate();
            } else {
                // Insert new record
                rs.close();
                pt.close();
                
                pt = con.prepareStatement("INSERT INTO company_details (shop_name, address, gstin, print_type, printer_name, bank_details, barcode_printer) VALUES (?, ?, ?, ?, ?, ?, ?)");
                pt.setString(1, shopName);
                pt.setString(2, address);
                pt.setString(3, gstin);
                pt.setInt(4, printType);
                pt.setString(5, printerName);
                pt.setString(6, bankDetails);
                pt.setString(7, barcodePrinter);
                pt.executeUpdate();
            }
            
            con.commit();  // Commit transaction
            return true;
        } catch (Exception e) {
            if (con != null) {
                try { 
                    con.rollback();  // Rollback on error
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
            if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
            if (con != null) {
                try { 
                    con.setAutoCommit(true);  // Reset auto-commit
                    con.close(); 
                } catch (Exception e) { ; }
            }
        }
    }

/**
 * Returns all active users with their discount percentage.
 * Each Vector row: [id(int), user_name(String), fullName(String), disc_per(int)]
 */
public Vector getAllUsersWithDiscount() throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT id, user_name, IFNULL(fullName,'') AS fullName, IFNULL(disc_per,100) AS disc_per " +
            "FROM users WHERE is_active = 1 ORDER BY user_name");
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("user_name"));
            row.addElement(rs.getString("fullName"));
            row.addElement(rs.getInt("disc_per"));
            vec.add(row);
        }
        return vec;
    } finally {
        if (rs  != null) try { rs.close();  } catch (SQLException e) { ; }
        if (ps  != null) try { ps.close();  } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e)   { ; }
    }
}

/**
 * Updates the disc_per (discount percentage) for a user.
 */
public void updateUserDiscount(int userId, int discPer) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        ps = con.prepareStatement("UPDATE users SET disc_per = ? WHERE id = ?");
        ps.setInt(1, discPer);
        ps.setInt(2, userId);
        ps.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) try { con.rollback(); } catch (Exception ex) { ; }
        throw e;
    } finally {
        if (ps  != null) try { ps.close();  } catch (SQLException e) { ; }
        if (con != null) {
            try { con.setAutoCommit(true); con.close(); } catch (Exception e) { ; }
        }
    }
}

/**
 * Returns the maximum discount percentage allowed for a user.
 * Defaults to 100 if not set.
 */
public int getUserDiscPer(int userId) {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement("SELECT IFNULL(disc_per, 100) FROM users WHERE id = ?");
        ps.setInt(1, userId);
        rs = ps.executeQuery();
        if (rs.next()) return rs.getInt(1);
    } catch (Exception e) {
        // fall through to default
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return 100;
}
}
