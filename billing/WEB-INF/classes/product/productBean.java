package product;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;
import java.text.*;

import com.sun.rowset.*; 	
import javax.sql.rowset.*;
import java.util.Date;
import java.util.Map;
import java.util.Set;
import java.util.Vector;

public class productBean {

    public productBean() {
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
    
    public Connection check() throws SQLException
   		{
		return util.DBConnectionManager.getConnectionFromPool();
		}
//////////////////////////----------------------------
public int checkTheCateNameExist(String name)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_category WHERE name = ?");
		      pt.setString(1,name);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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
//////////////////////////----------------------------
public void AddCategory(String catName) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // IMPORTANT

        String sql = "INSERT INTO prod_category(NAME, date, time) VALUES (?, NOW(), NOW())";
        pt = con.prepareStatement(sql);
        pt.setString(1, catName);

        int rows = pt.executeUpdate();
        if (rows > 0) {
            System.out.println("Category inserted successfully.");
        } else {
            System.out.println("No rows inserted.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) {
            con.rollback();
        }
        System.err.println("Error inserting category: " + e.getMessage());
        throw e; // Rethrow so caller knows
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}

//////////////////////////----------------------------
public Vector getCategoryName() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT NAME,id FROM prod_category WHERE is_active = 1");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			

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
////////////////////////////------------------------
public void editCategory(int id,String name)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("update prod_category set name=? where id=?");
		pt.setString(1,name);
		pt.setInt(2,id);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
public void editSupplier(int id,String name,String supPhn,String supDesc,String gstin, int isGst)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("update prod_supplier set name=?,phone_number=?,description=?,gstin=?,is_gst=? where id=?");
		pt.setString(1,name);
		pt.setString(2,supPhn);
		pt.setString(3,supDesc);
		pt.setString(4,gstin);
		pt.setInt(5,isGst);
		pt.setInt(6,id);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
public void blockCategory(int id)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();

		pt=con.prepareStatement("update prod_category set is_active=0 where id=? ");
		pt.setInt(1,id);
		pt.executeUpdate();
		con.commit();
	}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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

//////////////////////////----------------------------
// Expense Type Methods
//////////////////////////----------------------------
public int checkExpenseTypeExist(String name) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        int typeId = 0;

        pt = con.prepareStatement("SELECT id FROM expense_type WHERE type = ?");
        pt.setString(1, name);
        rs = pt.executeQuery();
        if (rs.next())
            typeId = rs.getInt(1);

        return typeId;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) { }
            con = null;
        }
    }
}

//////////////////////////----------------------------
public void addExpenseType(String typeName) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        String sql = "INSERT INTO expense_type(type, is_active) VALUES (?, 1)";
        pt = con.prepareStatement(sql);
        pt.setString(1, typeName);

        int rows = pt.executeUpdate();
        if (rows > 0) {
            System.out.println("Expense type inserted successfully.");
        } else {
            System.out.println("No rows inserted.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) {
            con.rollback();
        }
        System.err.println("Error inserting expense type: " + e.getMessage());
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}

//////////////////////////----------------------------
public Vector getExpenseTypeList() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector major = new Vector();

        pt = con.prepareStatement("SELECT type, id FROM expense_type WHERE is_active = 1 ORDER BY type");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getString(1));
            vec.addElement(rs.getString(2));
            major.addElement(vec);
        }
        return major;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) { }
            con = null;
        }
    }
}

//////////////////////////----------------------------
public void editExpenseType(int id, String name) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("UPDATE expense_type SET type=? WHERE id=?");
        pt.setString(1, name);
        pt.setInt(2, id);

        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        con.rollback();
        throw e;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) { }
            con = null;
        }
    }
}

//////////////////////////----------------------------
public void blockExpenseType(int id) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("UPDATE expense_type SET is_active=0 WHERE id=?");
        pt.setInt(1, id);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        con.rollback();
        throw e;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) { }
            con = null;
        }
    }
}

//////////////////////////----------------------------
public void addExpenseEntry(int expenseType, String content, String description, double amount, String expenseDateTime, int userId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        String sql = "INSERT INTO expense_entry(exp_type, content, description, amount, exc_date_time, entry_date_time, uid, is_active) VALUES (?, ?, ?, ?, ?, NOW(), ?, 1)";
        pt = con.prepareStatement(sql);
        pt.setInt(1, expenseType);
        pt.setString(2, content);
        pt.setString(3, description);
        pt.setDouble(4, amount);
        pt.setString(5, expenseDateTime);
        pt.setInt(6, userId);

        int rows = pt.executeUpdate();
        if (rows > 0) {
            System.out.println("Expense entry inserted successfully.");
        } else {
            System.out.println("No rows inserted.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) {
            con.rollback();
        }
        System.err.println("Error inserting expense entry: " + e.getMessage());
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}

//////////////////////////----------------------------
public Vector getExpenseReport(String fromDate, String toDate, int expenseTypeId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector major = new Vector();

        String sql = "SELECT ee.exc_date_time, COALESCE(et.type, 'Unknown'), ee.content, ee.description, ee.amount, COALESCE(u.user_name, 'Unknown') " +
                     "FROM expense_entry ee " +
                     "LEFT JOIN expense_type et ON ee.exp_type = et.id " +
                     "LEFT JOIN users u ON ee.uid = u.id " +
                     "WHERE ee.is_active = 1 " +
                     "AND DATE(ee.exc_date_time) BETWEEN ? AND ? ";
        
        if (expenseTypeId > 0) {
            sql += "AND ee.exp_type = ? ";
        }
        
        sql += "ORDER BY ee.exc_date_time DESC";

        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        
        if (expenseTypeId > 0) {
            pt.setInt(3, expenseTypeId);
        }
        
        System.out.println("Executing Expense Report Query: " + sql);
        System.out.println("Parameters - fromDate: " + fromDate + ", toDate: " + toDate + ", expenseTypeId: " + expenseTypeId);
        
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getString(1));  // exc_date_time
            vec.addElement(rs.getString(2));  // expense type name
            vec.addElement(rs.getString(3));  // content
            vec.addElement(rs.getString(4));  // description
            vec.addElement(rs.getDouble(5));  // amount
            vec.addElement(rs.getString(6));  // username
            major.addElement(vec);
        }
        
        System.out.println("Records fetched: " + major.size());
        
        return major;
    } catch (Exception e) {
        System.err.println("Error in getExpenseReport: " + e.getMessage());
        e.printStackTrace();
        throw e;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) { }
            con = null;
        }
    }
}

//////////////////////////----------------------------
public void blockSupplier(int id)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();

		pt=con.prepareStatement("update prod_supplier set is_active=0 where id=? ");
		pt.setInt(1,id);
		pt.executeUpdate();
		con.commit();
	}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
//////////////////////////----------------------------
public int checkTheBrandsNameExist(String name)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_brands WHERE name = ?");
		      pt.setString(1,name);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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
//////////////////////////----------------------------
public void AddBrands(String catName) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // IMPORTANT

        String sql = "INSERT INTO prod_brands(NAME, date, time) VALUES (?, NOW(), NOW())";
        pt = con.prepareStatement(sql);
        pt.setString(1, catName);

        int rows = pt.executeUpdate();
        if (rows > 0) {
            System.out.println("Brands inserted successfully.");
        } else {
            System.out.println("No rows inserted.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) {
            con.rollback();
        }
        System.err.println("Error inserting Brands: " + e.getMessage());
        throw e; // Rethrow so caller knows
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}

//////////////////////////----------------------------
public Vector getBrandsName() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT NAME,id FROM prod_brands WHERE is_active = 1");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			

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
////////////////////////////------------------------
public Vector getUnits() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector units = new Vector();

    pt = con.prepareStatement("SELECT name,id,convertion_unit,convertion_calculation FROM prod_units ORDER BY name");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
            vec.addElement(rs.getString(3) );
            vec.addElement(rs.getBigDecimal(4) );
			

		units.addElement(vec);

		}
		return units;
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

////////////////////////////------------------------
public void editBrands(int id,String name)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("update prod_brands set name=? where id=?");
		pt.setString(1,name);
		pt.setInt(2,id);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
public void blockBrands(int id)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();

		pt=con.prepareStatement("update prod_brands set is_active=0 where id=? ");
		pt.setInt(1,id);
		pt.executeUpdate();
		con.commit();
	}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
//////////////////////////----------------------------
public int checkTheProductNameExist(String name)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_product WHERE name = ?");
		      pt.setString(1,name);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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
/////////////////////////------------------------------
/*public void addProduct(String productName,int categoryId,int brandId,String code,double cost,double mrp,int discType,double discValue,BigDecimal stock) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // IMPORTANT

        String sql = "INSERT INTO `prod_product`(NAME,category_id,brand_id, DATE, TIME,code) VALUES (?,?,?, NOW(), NOW(),?)";
        pt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS); 
        pt.setString(1, productName);
        pt.setInt(2, categoryId);
        pt.setInt(3, brandId);
        pt.setString(4, code);

        int rows = pt.executeUpdate();
        if (rows > 0) {
        	rs = pt.getGeneratedKeys();
            if (rs.next()) {
                int prodId = rs.getInt(1); 
                System.out.println("product inserted with ID: " + prodId);

                
                String sql2 = "INSERT INTO `prod_batch` (NAME, product_id, cost, mrp, stock, disc_type, discount, DATE, TIME,added_stock) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW(),?";
       			 pt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS); 
                pt.setString(1, "Z" + code);
		        pt.setInt(2, prodId);
		        pt.setDouble(3, cost);
		        pt.setDouble(4, mrp);
		        pt.setInt(5, stock);
		        pt.setInt(6, discType);
		        pt.setDouble(7, discValue);
		        pt.setDouble(8, stock);
		        
                
                
                pt2.executeUpdate();
                System.out.println("prod_batch entry added.");
                	int rows1 = pt.executeUpdate();
			        if (rows1 > 0) {
			            rs = pt.getGeneratedKeys();
			            if (rs.next()) {
			                int batchId = rs.getInt(1); 
			                System.out.println("Batch inserted with ID: " + batchId);
			
			                
			                String sql2 = "INSERT INTO `prod_lifecycle` (batch_id, stock_in,stock_now,notes,DATE,TIME,product_id) VALUES (?, ?,?,? ,NOW(),NOW(),?)";
			                pt2 = con.prepareStatement(sql2);
			                pt2.setInt(1, batchId);
			                pt2.setInt(2, stock);
			                pt2.setInt(3, stock);
			                pt2.setString(4, "WHILE ADD PRODUCT"); 
			                pt2.setInt(5, prodId);
			                
			                
			                pt2.executeUpdate();
			                System.out.println("Lifecycle entry added.");
			            }
            }
        } else {
            System.out.println("No rows inserted.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) {
            con.rollback();
        }
        System.err.println("Error inserting product: " + e.getMessage());
        throw e; // Rethrow so caller knows
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}*/
public void addProduct(String productName, int categoryId, int brandId, String code, double cost, double mrp, int discType, double discValue, BigDecimal stock,int uid,int gst, int unitId, String hsn, double commission) throws Exception {
    Connection con = null;
    PreparedStatement pt1 = null, pt2 = null, pt3 = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // Start transaction

        // Step 1: Insert into prod_product
        String sql1 = "INSERT INTO `prod_product`(NAME, category_id, brand_id, DATE, TIME, code,uid,gst,unit_id,hsn) VALUES (?, ?, ?, NOW(), NOW(), ?,?,?,?,?)";
        pt1 = con.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
        pt1.setString(1, productName);
        pt1.setInt(2, categoryId);
        pt1.setInt(3, brandId);
        pt1.setString(4, code);
        pt1.setInt(5, uid);
        pt1.setInt(6, gst);
        pt1.setInt(7, unitId);
        if (hsn != null && !hsn.trim().isEmpty()) {
            try {
                pt1.setInt(8, Integer.parseInt(hsn));
            } catch (NumberFormatException e) {
                pt1.setInt(8, 0); // Default to 0 if not a valid number
            }
        } else {
            pt1.setNull(8, java.sql.Types.INTEGER);
        }

        int rows1 = pt1.executeUpdate();
        if (rows1 <= 0) {
            throw new Exception("Product insert failed.");
        }

        rs = pt1.getGeneratedKeys();
        int prodId = 0;
        if (rs.next()) {
            prodId = rs.getInt(1);
            System.out.println("Product inserted with ID: " + prodId);
        }

        // Step 2: Insert into prod_batch
        String batchCode = "Z" + code;
        String sql2 = "INSERT INTO `prod_batch` (NAME, product_id, cost, mrp, stock, disc_type, discount, DATE, TIME, added_stock,uid,commission) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW(), ?,?,?)";
        pt2 = con.prepareStatement(sql2, Statement.RETURN_GENERATED_KEYS);
        pt2.setString(1, batchCode);
        pt2.setInt(2, prodId);
        pt2.setDouble(3, cost);
        pt2.setDouble(4, mrp);
        pt2.setBigDecimal(5, stock);
        pt2.setInt(6, discType);
        pt2.setDouble(7, discValue);
        pt2.setBigDecimal(8, stock);
        pt2.setInt(9, uid);
        pt2.setDouble(10, commission);

        int rows2 = pt2.executeUpdate();
        if (rows2 <= 0) {
            throw new Exception("Batch insert failed.");
        }

        rs = pt2.getGeneratedKeys();
        int batchId = 0;
        if (rs.next()) {
            batchId = rs.getInt(1);
            System.out.println("Batch inserted with ID: " + batchId);
        }

        // Step 3: Insert into prod_lifecycle
        String sql3 = "INSERT INTO `prod_lifecycle` (batch_id, stock_in, stock_now, notes, DATE, TIME, product_id,uid) VALUES (?, ?, ?, ?, NOW(), NOW(), ?,?)";
        pt3 = con.prepareStatement(sql3);
        pt3.setInt(1, batchId);
        pt3.setBigDecimal(2, stock);
        pt3.setBigDecimal(3, stock);
        pt3.setString(4, "WHILE ADD PRODUCT");
        pt3.setInt(5, prodId);
        pt3.setInt(6, uid);

        pt3.executeUpdate();
        System.out.println("Lifecycle entry added.");

        con.commit(); // All good
    } catch (Exception e) {
        if (con != null) con.rollback();
        System.err.println("Error inserting product: " + e.getMessage());
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt1 != null) try { pt1.close(); } catch (SQLException e) {}
        if (pt2 != null) try { pt2.close(); } catch (SQLException e) {}
        if (pt3 != null) try { pt3.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (SQLException e) {}
    }
}

//////////////////////////---------------------------
public Vector getAllProducts() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT a.`name`,a.`code`,b.`name`,c.`name`,d.`mrp`,CASE "
							+"	WHEN d.disc_type = 1 THEN CONCAT(CAST(d.discount AS UNSIGNED), ' RS')  "
							+"	WHEN d.disc_type = 2 THEN CONCAT(CAST(d.discount AS UNSIGNED), ' %') "
							+"	ELSE 'No Discount' END AS discount_display,d.stock,d.added_stock,a.id,d.cost,d.disc_type,d.discount,a.gst,a.unit_id,a.hsn,e.`name`,d.commission  "
							+"	FROM `prod_product` a "
							+"	JOIN `prod_category` b ON a.`category_id`=b.id "
							+"	JOIN `prod_brands` c ON a.`brand_id`=c.id "
							+"	JOIN `prod_batch` d ON a.id=d.`product_id` "
							+"	LEFT JOIN `prod_units` e ON a.unit_id=e.id WHERE a.is_active=1 ORDER BY CAST(SUBSTRING(a.code, 2) AS UNSIGNED);");

	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			vec.addElement(rs.getString(3) );
			vec.addElement(rs.getString(4) );
			vec.addElement(rs.getString(5) );
			vec.addElement(rs.getString(6) );
			vec.addElement(rs.getString(7) );
			vec.addElement(rs.getString(8) );
			vec.addElement(rs.getString(9) );
			vec.addElement(rs.getString(10) );
			vec.addElement(rs.getString(11) );
			vec.addElement(rs.getString(12) );
			vec.addElement(rs.getString(13) );
			vec.addElement(rs.getString(14) );  // unit_id
			vec.addElement(rs.getString(15) );  // hsn
			vec.addElement(rs.getString(16) );  // unit name
			vec.addElement(rs.getString(17) );  // commission

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
////////////////////////////
public Vector getAllProductsReverse() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT a.`name`,b.`name`,c.`name`,a.id,a.code  "
								+"	FROM `prod_product` a "
								+"	JOIN `prod_category` b ON b.`id`=a.`category_id` "
								+"	JOIN `prod_brands` c ON c.id=a.`brand_id` "
								+"	WHERE a.`is_active`=1 ORDER BY  a.date DESC;");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			vec.addElement(rs.getString(3) );
			vec.addElement(rs.getString(4) );
			vec.addElement(rs.getString(5) );
			

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
/////////////////////////////
public int checkTheProductCodeExist(String code)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int codeId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_product WHERE code = ?");
		      pt.setString(1,code);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	codeId  = rs.getInt(1);

		      return codeId;
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
///////////////////////////////------------------
public Vector getProductBySearch(String name)throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
//System.out.println("AS "+DistId);	
	
			pt = con.prepareStatement("SELECT * FROM `prod_product` WHERE NAME LIKE ? AND is_active=1 ORDER BY NAME ASC LIMIT 50");	
	
		pt.setString(1,"%"+name+"%");	
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
//////////////////////////----------------------------
public int checkTheBatchNameExist(String name)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_batch WHERE name = ?");
		      pt.setString(1,name);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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

////////////////////////----------------------------
public void addBatch(String batchName, int catId, double cost, double mrp, int discType, double discValue, BigDecimal stock) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    PreparedStatement pt2 = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); 

        String sql = "INSERT INTO `prod_batch` (NAME, product_id, cost, mrp, stock, disc_type, discount, DATE, TIME,added_stock) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW(),?)";
        pt = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS); 
        pt.setString(1, batchName);
        pt.setInt(2, catId);
        pt.setDouble(3, cost);
        pt.setDouble(4, mrp);
        pt.setBigDecimal(5, stock);
        pt.setInt(6, discType);
        pt.setDouble(7, discValue);
        pt.setBigDecimal(8, stock);
        
        int rows = pt.executeUpdate();
        if (rows > 0) {
            rs = pt.getGeneratedKeys();
            if (rs.next()) {
                int batchId = rs.getInt(1);
                System.out.println("Batch inserted with ID: " + batchId);

                String sql2 = "INSERT INTO `prod_lifecycle` (batch_id, stock_in,stock_now,notes,DATE,TIME,product_id) VALUES (?, ?,?,? ,NOW(),NOW(),?)";
                pt2 = con.prepareStatement(sql2);
                pt2.setInt(1, batchId);
                pt2.setBigDecimal(2, stock);
                pt2.setBigDecimal(3, stock);
                pt2.setString(4, "ADD BATCH"); 
                pt2.setInt(5, catId);
                
                pt2.executeUpdate();
                System.out.println("Lifecycle entry added.");
            }
        } else {
            System.out.println("No rows inserted into prod_batch.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        System.err.println("Error: " + e.getMessage());
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt2 != null) try { pt2.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
///////////////////////////////------------------
public Vector getAllProductBatch(int id)throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
//System.out.println("AS "+DistId);	
	
			pt = con.prepareStatement("SELECT b.name,b.mrp,CASE "
								      +"  WHEN b.disc_type = 1 THEN CONCAT(CAST(discount AS UNSIGNED), ' RS') "
								      +"  WHEN b.disc_type = 2 THEN CONCAT(CAST(discount AS UNSIGNED), ' %') "
								      +"  ELSE 'No Discount' END AS discount_display,b.id,b.stock,added_stock,IFNULL(u.name,'') AS unit_name,IFNULL(u.convertion_unit,'') AS convertion_unit,IFNULL(u.convertion_calculation,0) AS convertion_calculation "
							+"	FROM prod_batch b "
							+"	LEFT JOIN prod_product p ON p.id = b.product_id "
							+"	LEFT JOIN prod_units u ON u.id = p.unit_id "
							+"	WHERE b.product_id = ?;");	
	
		pt.setInt(1,id);	
		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1));
		vec1.addElement(rs.getString(2));
		vec1.addElement(rs.getString(3));
		vec1.addElement(rs.getString(4));
		vec1.addElement(rs.getString(5));
		vec1.addElement(rs.getString(6));
		vec1.addElement(rs.getString(7)); // unit_name
		vec1.addElement(rs.getString(8)); // convertion_unit
		vec1.addElement(rs.getString(9)); // convertion_calculation
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
//////////////////////////--------------------------
public void blockProduct(int id)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();

		pt=con.prepareStatement("update prod_product set is_active=0 where id=? ");
		pt.setInt(1,id);
		pt.executeUpdate();
		con.commit();
	}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
//////////////////////////////////////////////////
/*public void editProduct(int productId,String newProduct,String proCode,int categoryId,int brandId,double mrp,double cost,double discValue,int discType)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("UPDATE prod_product SET name=?,code=?,category_id=?,brand_id=? WHERE id=?");
		pt.setString(1,newProduct);
		pt.setString(2,proCode);
		pt.setInt(3,categoryId);
		pt.setInt(4,brandId);
		pt.setInt(5,productId);

		pt.executeUpdate();
		
		pt=con.prepareStatement("UPDATE `prod_batch` SET NAME = CONCAT('Z', ?),cost=?,mrp=?,disc_type=?,discount=? WHERE product_id=?");
		pt.setString(1,proCode);
		pt.setDouble(2,cost);
		pt.setDouble(3,mrp);
		pt.setInt(4,discType);
		pt.setDouble(5,discValue);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
}*/
public void editProduct(int productId, String newProduct, String proCode, int categoryId, int brandId,
                        double mrp, double cost, double discValue, int discType, int gst, int uid, int unitId, String hsn, double commission) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // start transaction


        pt = con.prepareStatement("UPDATE prod_product SET name=?, code=?, category_id=?, brand_id=?, gst=?, unit_id=?, hsn=? WHERE id=?");
        pt.setString(1, newProduct);
        pt.setString(2, proCode);
        pt.setInt(3, categoryId);
        pt.setInt(4, brandId);
        pt.setInt(5, gst);
        pt.setInt(6, unitId);
        if (hsn != null && !hsn.trim().isEmpty()) {
            try {
                pt.setInt(7, Integer.parseInt(hsn));
            } catch (NumberFormatException e) {
                pt.setInt(7, 0); // Default to 0 if not a valid number
            }
        } else {
            pt.setNull(7, java.sql.Types.INTEGER);
        }
        pt.setInt(8, productId);
        pt.executeUpdate();
        pt.close();

        pt = con.prepareStatement("SELECT * FROM prod_batch WHERE product_id=?");
        pt.setInt(1, productId);
        rs = pt.executeQuery();

        if (rs.next()) {
            // Insert old data into prod_batch_updated
            String insertSql = "INSERT INTO prod_batch_updated (product_id, name, cost, mrp, disc_type, discount, stock, added_stock, updatedUid,updatedDate,updatedTime) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?,now(),now())";
            PreparedStatement insertPt = con.prepareStatement(insertSql);
            insertPt.setInt(1, rs.getInt("product_id"));
            insertPt.setString(2, rs.getString("name"));
            insertPt.setDouble(3, rs.getDouble("cost"));
            insertPt.setDouble(4, rs.getDouble("mrp"));
            insertPt.setInt(5, rs.getInt("disc_type"));
            insertPt.setDouble(6, rs.getDouble("discount"));
            insertPt.setBigDecimal(7, rs.getBigDecimal("stock"));
            insertPt.setBigDecimal(8, rs.getBigDecimal("added_stock"));
            insertPt.setInt(9, uid);
            insertPt.executeUpdate();
            insertPt.close();
        }
        rs.close();
        pt.close();

        pt = con.prepareStatement("UPDATE prod_batch SET name = CONCAT('Z', ?), cost=?, mrp=?, disc_type=?, discount=?, commission=? WHERE product_id=?");
        pt.setString(1, proCode);
        pt.setDouble(2, cost);
        pt.setDouble(3, mrp);
        pt.setInt(4, discType);
        pt.setDouble(5, discValue);
        pt.setDouble(6, commission);
        pt.setInt(7, productId);
        pt.executeUpdate();
        pt.close();

        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ignore) {}
        if (pt != null) try { pt.close(); } catch (SQLException ignore) {}
        if (con != null) try { con.close(); } catch (SQLException ignore) {}
    }
}

///////////////////////////////////
public int checkTheProductNameExistId(String name,int id)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_product WHERE NAME = ? AND id!=?");
		      pt.setString(1,name);
		      pt.setInt(2,id);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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
public int checkTheProductCodeExistId(String code,int id)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int codeId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_product WHERE code = ? and id!=?");
		      pt.setString(1,code);
		      pt.setInt(2,id);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	codeId  = rs.getInt(1);

		      return codeId;
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
public int checkTheSuppNameExist(String name,int id)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_supplier WHERE NAME = ? AND id!=?");
		      pt.setString(1,name);
		      pt.setInt(2,id);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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
/////////////////////////////////////////////////
public BigDecimal getCurrentStock(int id)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  BigDecimal stock = BigDecimal.ZERO;

		      pt = con.prepareStatement("SELECT stock FROM prod_batch WHERE product_id=?;");
		      pt.setInt(1,id);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	stock = rs.getBigDecimal(1);
		      if(stock == null) stock = BigDecimal.ZERO;

		      return stock;
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
////////////////////////////------------------------
public void addProductStock(int prodId, BigDecimal discValue, String reason, BigDecimal curStock, int proBatch,int discType,int uid) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); 

        
        pt = con.prepareStatement("UPDATE `prod_batch` SET stock = stock + ? WHERE id = ?");
        pt.setBigDecimal(1, discValue);
        pt.setInt(2, proBatch); 
        pt.executeUpdate();
        pt.close(); 

        // Read actual current stock from DB after update
        pt = con.prepareStatement("SELECT stock FROM prod_batch WHERE id = ?");
        pt.setInt(1, proBatch);
        rs = pt.executeQuery();
        BigDecimal stockNow = BigDecimal.ZERO;
        if (rs.next()) stockNow = rs.getBigDecimal(1);
        pt.close();
        rs.close();
        rs = null;
        String reason1 = "Adding Stock - " + reason;

        pt = con.prepareStatement("INSERT INTO `prod_lifecycle` (batch_id, stock_in, stock_now, notes, DATE, TIME, product_id,uid,stockAdjType) VALUES (?, ?, ?, ?, NOW(), NOW(), ?,?,1)");
        pt.setInt(1, proBatch);
        pt.setBigDecimal(2, discValue);
        pt.setBigDecimal(3, stockNow);
        pt.setString(4, reason1); 
        pt.setInt(5, prodId);
        pt.setInt(6, uid);
        pt.executeUpdate();
        pt.close();
        
        pt = con.prepareStatement("INSERT INTO `prod_stock_adjustment` (product_id,batch_id,stockType,stock,DATE,TIME,notes,uid) VALUES (?,?,?,?,NOW(),NOW(),?,?);");
        pt.setInt(1, prodId);
        pt.setInt(2, proBatch);
        pt.setInt(3, discType);
        pt.setBigDecimal(4, discValue); 
        pt.setString(5, reason1);
        pt.setInt(6, uid); 
        pt.executeUpdate();

        con.commit(); 
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}
////////////////////////////------------------------
public void removeProductStock(int prodId, BigDecimal discValue, String reason, BigDecimal curStock, int proBatch,int discType,int uid) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); 

        
        pt = con.prepareStatement("UPDATE `prod_batch` SET stock = stock - ? WHERE id = ?");
        pt.setBigDecimal(1, discValue);
        pt.setInt(2, proBatch); 
        pt.executeUpdate();
        pt.close(); 

        // Read actual current stock from DB after update
        pt = con.prepareStatement("SELECT stock FROM prod_batch WHERE id = ?");
        pt.setInt(1, proBatch);
        rs = pt.executeQuery();
        BigDecimal stockNow = BigDecimal.ZERO;
        if (rs.next()) stockNow = rs.getBigDecimal(1);
        pt.close();
        rs.close();
        rs = null;
        String reason1 = "Removing Stock - " + reason;

        pt = con.prepareStatement("INSERT INTO `prod_lifecycle` (batch_id, stock_out, stock_now, notes, DATE, TIME, product_id,uid,stockAdjType) VALUES (?, ?, ?, ?, NOW(), NOW(), ?,?,2)");
        pt.setInt(1, proBatch);
        pt.setBigDecimal(2, discValue);
        pt.setBigDecimal(3, stockNow);
        pt.setString(4, reason1); 
        pt.setInt(5, prodId);
        pt.setInt(6, uid);
        pt.executeUpdate();
        pt.close();
        
        pt = con.prepareStatement("INSERT INTO `prod_stock_adjustment` (product_id,batch_id,stockType,stock,DATE,TIME,notes,uid) VALUES (?,?,?,?,NOW(),NOW(),?,?);");
        pt.setInt(1, prodId);
        pt.setInt(2, proBatch);
        pt.setInt(3, discType);
        pt.setBigDecimal(4, discValue); 
        pt.setString(5, reason1);
        pt.setInt(6, uid);
        pt.executeUpdate();

        con.commit(); 
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

////////////////////////////------------------------
public void removeStockForDamage(int prodId, BigDecimal discValue, String reason, BigDecimal curStock, int proBatch, int discType, int uid) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); 

        // Update prod_batch - reduce stock
        pt = con.prepareStatement("UPDATE `prod_batch` SET stock = stock - ? WHERE id = ?");
        pt.setBigDecimal(1, discValue);
        pt.setInt(2, proBatch); 
        pt.executeUpdate();
        pt.close(); 

        // Read actual current stock from DB after update
        pt = con.prepareStatement("SELECT stock FROM prod_batch WHERE id = ?");
        pt.setInt(1, proBatch);
        rs = pt.executeQuery();
        BigDecimal stockNow = BigDecimal.ZERO;
        if (rs.next()) stockNow = rs.getBigDecimal(1);
        pt.close();
        rs.close();
        rs = null;
        String reason1 = "Damage - " + reason;

        pt = con.prepareStatement("INSERT INTO `prod_lifecycle` (batch_id, stock_out, stock_now, notes, DATE, TIME, product_id, uid, stockAdjType) VALUES (?, ?, ?, ?, NOW(), NOW(), ?, ?, 3)");
        pt.setInt(1, proBatch);
        pt.setBigDecimal(2, discValue);
        pt.setBigDecimal(3, stockNow);
        pt.setString(4, reason1); 
        pt.setInt(5, prodId);
        pt.setInt(6, uid);
        pt.executeUpdate();
        pt.close();
        
        // Insert to prod_stock_adjustment
        pt = con.prepareStatement("INSERT INTO `prod_stock_adjustment` (product_id, batch_id, stockType, stock, DATE, TIME, notes, uid) VALUES (?, ?, ?, ?, NOW(), NOW(), ?, ?);");
        pt.setInt(1, prodId);
        pt.setInt(2, proBatch);
        pt.setInt(3, discType);
        pt.setBigDecimal(4, discValue); 
        pt.setString(5, reason1);
        pt.setInt(6, uid);
        pt.executeUpdate();

        con.commit(); 
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

////////////////////////////------------------------
public void removeStockForInternalUse(int prodId, BigDecimal discValue, String reason, BigDecimal curStock, int proBatch, int discType, int uid) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); 

        // Update prod_batch - reduce stock
        pt = con.prepareStatement("UPDATE `prod_batch` SET stock = stock - ? WHERE id = ?");
        pt.setBigDecimal(1, discValue);
        pt.setInt(2, proBatch); 
        pt.executeUpdate();
        pt.close(); 

        // Read actual current stock from DB after update
        pt = con.prepareStatement("SELECT stock FROM prod_batch WHERE id = ?");
        pt.setInt(1, proBatch);
        rs = pt.executeQuery();
        BigDecimal stockNow = BigDecimal.ZERO;
        if (rs.next()) stockNow = rs.getBigDecimal(1);
        pt.close();
        rs.close();
        rs = null;
        String reason1 = "Internal Use - " + reason;

        pt = con.prepareStatement("INSERT INTO `prod_lifecycle` (batch_id, stock_out, stock_now, notes, DATE, TIME, product_id, uid, stockAdjType) VALUES (?, ?, ?, ?, NOW(), NOW(), ?, ?, 4)");
        pt.setInt(1, proBatch);
        pt.setBigDecimal(2, discValue);
        pt.setBigDecimal(3, stockNow);
        pt.setString(4, reason1); 
        pt.setInt(5, prodId);
        pt.setInt(6, uid);
        pt.executeUpdate();
        pt.close();
        
        // Insert to prod_stock_adjustment
        pt = con.prepareStatement("INSERT INTO `prod_stock_adjustment` (product_id, batch_id, stockType, stock, DATE, TIME, notes, uid) VALUES (?, ?, ?, ?, NOW(), NOW(), ?, ?);");
        pt.setInt(1, prodId);
        pt.setInt(2, proBatch);
        pt.setInt(3, discType);
        pt.setBigDecimal(4, discValue); 
        pt.setString(5, reason1);
        pt.setInt(6, uid);
        pt.executeUpdate();

        con.commit(); 
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/////////////////////////////////////////////////
public int getBatch(int id)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_batch WHERE product_id=?;");
		      pt.setInt(1,id);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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
//////////////////////////----------------------------
public int checkTheSupNameExist(String name)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM prod_supplier WHERE name = ?");
		      pt.setString(1,name);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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
///////////////////////////////--------------------------
public void AddSupplier(String name,String supDesc,String supPhn,String gstin, int isGst) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // IMPORTANT

        String sql = "INSERT INTO prod_supplier(NAME, date, time,description,phone_number,gstin,is_gst) VALUES (?, NOW(), NOW(),?,?,?,?)";
        pt = con.prepareStatement(sql);
        pt.setString(1, name);
		pt.setString(2, supDesc);
		pt.setString(3, supPhn);
		pt.setString(4, gstin);
		pt.setInt(5, isGst);
		
        int rows = pt.executeUpdate();
        if (rows > 0) {
            System.out.println("Supplier inserted successfully.");
        } else {
            System.out.println("No rows inserted.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) {
            con.rollback();
        }
        System.err.println("Error inserting category: " + e.getMessage());
        throw e; // Rethrow so caller knows
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
////////////////////////////--------------------
public Vector getSupplierDetails() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT NAME,id, "
							 +"   CASE WHEN description = '' OR description IS NULL THEN '-' ELSE description END AS description, "
							+"    CASE WHEN phone_number = '' OR phone_number IS NULL THEN '-' ELSE phone_number END AS phone_number, "
							+"    CASE WHEN gstin = '' OR gstin IS NULL THEN '-' ELSE gstin END AS gstin, "
							+"    COALESCE(is_gst, 0) AS is_gst "
					+"		FROM prod_supplier "
					+"		WHERE is_active = 1;");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			vec.addElement(rs.getString(3) );
			vec.addElement(rs.getString(4) );
			vec.addElement(rs.getString(5) );
			vec.addElement(rs.getString(6) );
			

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
//////////////////////////---------------------------
// Customer Management Methods
///////////////////////////////--------------------------
public void AddCustomer(String name,String custAddress,String custPhn,String gstin, int isGst, int isEligibleForCommission) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false); // IMPORTANT

        String sql = "INSERT INTO customers(name, date, time, address, phone_number, gstin, is_gst, is_eligible_for_commission) VALUES (?, NOW(), NOW(), ?, ?, ?, ?, ?)";
        pt = con.prepareStatement(sql);
        pt.setString(1, name);
		pt.setString(2, custAddress);
		pt.setString(3, custPhn);
		pt.setString(4, gstin);
		pt.setInt(5, isGst);
		pt.setInt(6, isEligibleForCommission);
		
        int rows = pt.executeUpdate();
        if (rows > 0) {
            System.out.println("Customer inserted successfully.");
        } else {
            System.out.println("No rows inserted.");
        }

        con.commit();
    } catch (Exception e) {
        if (con != null) {
            con.rollback();
        }
        System.err.println("Error inserting customer: " + e.getMessage());
        throw e; // Rethrow so caller knows
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
////////////////////////////--------------------
public Vector getCustomerDetails() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT name,id, "
							 +"   CASE WHEN address = '' OR address IS NULL THEN '-' ELSE address END AS address, "
							+"    CASE WHEN phone_number = '' OR phone_number IS NULL THEN '-' ELSE phone_number END AS phone_number, "
							+"    CASE WHEN gstin = '' OR gstin IS NULL THEN '-' ELSE gstin END AS gstin, "
							+"    COALESCE(is_gst, 0), COALESCE(is_eligible_for_commission, 0) "
					+"		FROM customers "
					+"		WHERE is_active = 1;");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			vec.addElement(rs.getString(3) );
			vec.addElement(rs.getString(4) );
			vec.addElement(rs.getString(5) );
			vec.addElement(rs.getString(6) );
			vec.addElement(rs.getString(7) );
			

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
///////////////////////////////--------------------------
public void editCustomer(int id, String name, String custPhn, String custAddress, String gstin, int isGst, int isEligibleForCommission) throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("UPDATE customers SET name=?, phone_number=?, address=?, gstin=?, is_gst=?, is_eligible_for_commission=? WHERE id=?");
		pt.setString(1,name);
		pt.setString(2,custPhn);
		pt.setString(3,custAddress);
		pt.setString(4,gstin);
		pt.setInt(5,isGst);
		pt.setInt(6,isEligibleForCommission);
		pt.setInt(7,id);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
//////////////////////////----------------------------
public void blockCustomer(int id)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con					= util.DBConnectionManager.getConnectionFromPool();

		pt=con.prepareStatement("update customers set is_active=0 where id=? ");
		pt.setInt(1,id);
		pt.executeUpdate();
		con.commit();
	}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
//////////////////////////----------------------------
public int checkTheCustomerNameExist(String name)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int custId  = 0;

		      pt = con.prepareStatement("SELECT id FROM customers WHERE name = ?");
		      pt.setString(1,name);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	custId  = rs.getInt(1);

		      return custId;
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
/////////////////////////////////////////////////
public int checkTheCustomerNameExist(String name,int id)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int custId  = 0;

		      pt = con.prepareStatement("SELECT id FROM customers WHERE name = ? AND id!=?");
		      pt.setString(1,name);
		      pt.setInt(2,id);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	custId  = rs.getInt(1);

		      return custId;
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
/////////////////////////////////////////////////
public Vector getCommissionCustomers() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector major = new Vector();
        pt = con.prepareStatement(
            "SELECT id, name FROM customers " +
            "WHERE is_active = 1 AND is_eligible_for_commission = 1 " +
            "ORDER BY name"
        );
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getInt(1));    // id
            vec.addElement(rs.getString(2)); // name
            major.addElement(vec);
        }
        return major;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
/////////////////////////////////////////////////
public Vector searchCustomers(String query) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector major = new Vector();
        
        pt = con.prepareStatement(
            "SELECT id, name, " +
            "CASE WHEN phone_number = '' OR phone_number IS NULL THEN '-' ELSE phone_number END AS phone_number, " +
            "CASE WHEN address = '' OR address IS NULL THEN '-' ELSE address END AS address, " +
            "CASE WHEN gstin = '' OR gstin IS NULL THEN '-' ELSE gstin END AS gstin, " +
            "COALESCE(credit_limit, 0) AS credit_limit, " +
            "COALESCE(is_gst, 0) AS is_gst, " +
            "COALESCE(is_eligible_for_commission, 0) AS is_eligible_for_commission, " +
            "COALESCE(exchange_point, 0) AS exchange_point " +
            "FROM customers " +
            "WHERE is_active = 1 AND name LIKE ? " +
            "ORDER BY name LIMIT 10"
        );
        pt.setString(1, "%" + query + "%");
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getInt(1));      // id
            vec.addElement(rs.getString(2));   // name
            vec.addElement(rs.getString(3));   // phone
            vec.addElement(rs.getString(4));   // address
            vec.addElement(rs.getString(5));   // gstin
            vec.addElement(rs.getDouble(6));   // credit_limit
            vec.addElement(rs.getInt(7));      // is_gst
            vec.addElement(rs.getInt(8));      // is_eligible_for_commission
            vec.addElement(rs.getDouble(9));   // exchange_point
            major.addElement(vec);
        }
        
        return major;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
/////////////////////////////////////////////////
public Vector searchCustomersByPhone(String phone) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector major = new Vector();
        pt = con.prepareStatement(
            "SELECT id, name, " +
            "CASE WHEN phone_number = '' OR phone_number IS NULL THEN '-' ELSE phone_number END AS phone_number, " +
            "CASE WHEN address = '' OR address IS NULL THEN '-' ELSE address END AS address, " +
            "CASE WHEN gstin = '' OR gstin IS NULL THEN '-' ELSE gstin END AS gstin, " +
            "COALESCE(credit_limit, 0) AS credit_limit, " +
            "COALESCE(is_gst, 0) AS is_gst, " +
            "COALESCE(is_eligible_for_commission, 0) AS is_eligible_for_commission, " +
            "COALESCE(exchange_point, 0) AS exchange_point " +
            "FROM customers " +
            "WHERE is_active = 1 AND phone_number LIKE ? " +
            "ORDER BY name LIMIT 10"
        );
        pt.setString(1, "%" + phone + "%");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getInt(1));
            vec.addElement(rs.getString(2));
            vec.addElement(rs.getString(3));
            vec.addElement(rs.getString(4));
            vec.addElement(rs.getString(5));
            vec.addElement(rs.getDouble(6));
            vec.addElement(rs.getInt(7));
            vec.addElement(rs.getInt(8));
            vec.addElement(rs.getDouble(9));
            major.addElement(vec);
        }
        return major;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
/////////////////////////////////////////////////
public Vector searchSuppliers(String query) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector major = new Vector();
        
        pt = con.prepareStatement(
            "SELECT id, name, " +
            "CASE WHEN phone_number = '' OR phone_number IS NULL THEN '-' ELSE phone_number END AS phone_number, " +
            "CASE WHEN DESCRIPTION = '' OR DESCRIPTION IS NULL THEN '-' ELSE DESCRIPTION END AS address, " +
            "CASE WHEN gstin = '' OR gstin IS NULL THEN '-' ELSE gstin END AS gstin " +
            "FROM prod_supplier " +
            "WHERE is_active = 1 AND name LIKE ? " +
            "ORDER BY name LIMIT 10"
        );
        pt.setString(1, "%" + query + "%");
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getInt(1));      // id
            vec.addElement(rs.getString(2));   // name
            vec.addElement(rs.getString(3));   // phone
            vec.addElement(rs.getString(4));   // address
            vec.addElement(rs.getString(5));   // gstin
            major.addElement(vec);
        }
        
        return major;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
/////////////////////////////////////////////////
public String getCustomerNameById(int customerId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        pt = con.prepareStatement("SELECT name FROM customers WHERE id = ?");
        pt.setInt(1, customerId);
        rs = pt.executeQuery();
        
        if (rs.next()) {
            return rs.getString(1);
        }
        
        return "-";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { }
        if (pt != null) try { pt.close(); } catch (SQLException e) { }
        if (con != null) try { con.close(); } catch (Exception e) { }
    }
}
//////////////////////////---------------------------
public Vector getCurrentStockDetails() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT b.`name`,b.`code`,a.stock,FORMAT(a.`cost`,2),FORMAT(a.`mrp`,2),FORMAT(CASE "
							+"	        WHEN disc_type = 1 THEN discount  "                
							+"	        WHEN disc_type = 2 THEN ROUND(mrp * (discount/100), 2)  "
							+"	        ELSE 0 END,2) AS discount_in_rs,a.discount,FORMAT(a.cost*a.stock,2) AS costTotal,FORMAT(a.mrp*a.stock,2) AS mrpTotal,IFNULL(u.name,'') AS unit_name "
							+"	FROM `prod_batch` a "
							+"	JOIN `prod_product` b ON b.id=a.`product_id` "
							+"	LEFT JOIN `prod_units` u ON u.id=b.`unit_id` "
							+"	WHERE a.`stock`>0 ORDER BY CAST(SUBSTRING(b.code, 2) AS UNSIGNED);");
	rs =pt.executeQuery();
	while(rs.next())
		{

		Vector vec = new Vector();

			vec.addElement(rs.getString(1) );
			vec.addElement(rs.getString(2) );
			vec.addElement(rs.getString(3) );
			vec.addElement(rs.getString(4) );
			vec.addElement(rs.getString(5) );
			vec.addElement(rs.getString(6) );
			vec.addElement(rs.getString(7) );
			vec.addElement(rs.getString(8) );
			vec.addElement(rs.getString(9) );
			vec.addElement(rs.getString(10) ); // unit_name
			

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
///////////////////////-----------------------------
public Vector getCurrentStockDetailsWithCategory() throws Exception
{
Connection con = null;
PreparedStatement pt = null;
ResultSet rs = null;
try{
	con = util.DBConnectionManager.getConnectionFromPool();
	
Vector major = new Vector();

pt = con.prepareStatement("SELECT b.`name`,b.`code`,a.stock,FORMAT(a.`cost`,2),FORMAT(a.`mrp`,2),FORMAT(CASE "
						+"	        WHEN disc_type = 1 THEN discount  "                
						+"	        WHEN disc_type = 2 THEN ROUND(mrp * (discount/100), 2)  "
						+"	        ELSE 0 END,2) AS discount_in_rs,a.discount,FORMAT(a.cost*a.stock,2) AS costTotal,FORMAT(a.mrp*a.stock,2) AS mrpTotal,IFNULL(u.name,'') AS unit_name,b.category_id,IFNULL(c.name,'') AS category_name,IFNULL(u.convertion_unit,'') AS convertion_unit "
						+"	FROM `prod_batch` a "
						+"	JOIN `prod_product` b ON b.id=a.`product_id` "
						+"	LEFT JOIN `prod_units` u ON u.id=b.`unit_id` "
						+"	LEFT JOIN `prod_category` c ON c.id=b.`category_id` "
						+"	WHERE a.`stock`>0 ORDER BY CAST(SUBSTRING(b.code, 2) AS UNSIGNED);");
rs =pt.executeQuery();
while(rs.next())
	{

	Vector vec = new Vector();

		vec.addElement(rs.getString(1) ); // name
		vec.addElement(rs.getString(2) ); // code
		vec.addElement(rs.getString(3) ); // stock
		vec.addElement(rs.getString(4) ); // cost
		vec.addElement(rs.getString(5) ); // mrp
		vec.addElement(rs.getString(6) ); // discount
		vec.addElement(rs.getString(7) ); // discount value
		vec.addElement(rs.getString(8) ); // cost total
		vec.addElement(rs.getString(9) ); // mrp total
		vec.addElement(rs.getString(10) ); // unit_name
		vec.addElement(rs.getString(11) ); // category_id
		vec.addElement(rs.getString(12) ); // category_name
		vec.addElement(rs.getString(13) ); // convertion_unit
		vec.addElement(rs.getString(8) ); // cost total
		vec.addElement(rs.getString(9) ); // mrp total
		vec.addElement(rs.getString(10) ); // unit_name
		vec.addElement(rs.getString(11) ); // category_id
		

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
///////////////////////-----------------------------
public Vector GetSupplier()throws Exception
{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
		Vector vec=new Vector();
		pt=con.prepareStatement("SELECT id,NAME FROM prod_supplier WHERE is_active=1 order by name");
		rs=pt.executeQuery();
		while(rs.next())
			{
			Vector vec1=new Vector();
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
public Vector getStockAdjReport(String from, String to, int productId, int stockType) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        String sql = "SELECT psa.id, psa.product_id, p.name AS product_name, psa.batch_id, " +
                     "psa.stockType, psa.stock, psa.date, psa.time, psa.notes, " +
                     "psa.uid, u.user_name, IFNULL(pu.convertion_unit,'') AS convertion_unit " +
                     "FROM prod_stock_adjustment psa " +
                     "JOIN prod_product p ON psa.product_id = p.id " +
                     "JOIN users u ON psa.uid = u.id " +
                     "LEFT JOIN prod_units pu ON pu.id = p.unit_id " +
                     "WHERE psa.date BETWEEN ? AND ? ";

        if (productId > 0) {
            sql += " AND psa.product_id = ? ";
        }
        
        if (stockType > 0) {
            sql += " AND psa.stockType = ? ";
        }

        sql += " ORDER BY psa.date DESC, psa.time DESC";

        pt = con.prepareStatement(sql);
        int paramIndex = 1;
        pt.setString(paramIndex++, from);
        pt.setString(paramIndex++, to);

        if (productId > 0) {
            pt.setInt(paramIndex++, productId);
        }
        
        if (stockType > 0) {
            pt.setInt(paramIndex++, stockType);
        }

        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));  // id
            vec1.addElement(rs.getString(2));  // product_id
            vec1.addElement(rs.getString(3));  // product_name
            vec1.addElement(rs.getString(4));  // batch_id
            vec1.addElement(rs.getString(5));  // stockType
            vec1.addElement(rs.getString(6));  // stock
            vec1.addElement(rs.getString(7));  // date
            vec1.addElement(rs.getString(8));  // time
            vec1.addElement(rs.getString(9));  // notes
            vec1.addElement(rs.getString(10)); // uid
            vec1.addElement(rs.getString(11)); // user_name
            vec1.addElement(rs.getString(12)); // convertion_unit

            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// Overloaded method for backward compatibility
public Vector getStockAdjReport(String from, String to, int productId) throws Exception {
    return getStockAdjReport(from, to, productId, 0);
}

/**
 * Returns one summary row per active category for the given date range.
 * Row layout:
 *   0  category_id       (int)
 *   1  category_name     (String)
 *   2  total_qty         (double) – sum of qty sold
 *   3  total_amount      (double) – sum of bill-detail totals
 *   4  bill_count        (int)    – distinct bills containing this category
 *   5  product_count     (int)    – distinct products sold
 *   6  top_product       (String) – product with highest qty in period
 *   7  top_product_qty   (double)
 */
public Vector getCategorySalesStats(String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        // Category summary
        String sql =
            "SELECT c.id, c.name," +
            "  COALESCE(SUM(bd.qty), 0)      AS total_qty," +
            "  COALESCE(SUM(bd.total), 0)    AS total_amount," +
            "  COUNT(DISTINCT b.id)          AS bill_count," +
            "  COUNT(DISTINCT p.id)          AS product_count" +
            " FROM prod_category c" +
            " LEFT JOIN prod_product p ON p.category_id = c.id" +
            " LEFT JOIN prod_bill_details bd ON bd.prod_id = p.id" +
            " LEFT JOIN prod_bill b ON b.id = bd.bill_id AND b.is_cancelled = 0" +
            "   AND b.date BETWEEN ? AND ?" +
            " WHERE c.is_active = 1" +
            " GROUP BY c.id, c.name" +
            " ORDER BY total_amount DESC";

        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        rs = pt.executeQuery();

        while (rs.next()) {
            int catId = rs.getInt(1);
            Vector row = new Vector();
            row.addElement(catId);                      // 0 category_id
            row.addElement(rs.getString(2));            // 1 category_name
            row.addElement(rs.getDouble(3));            // 2 total_qty
            row.addElement(rs.getDouble(4));            // 3 total_amount
            row.addElement(rs.getInt(5));               // 4 bill_count
            row.addElement(rs.getInt(6));               // 5 product_count
            row.addElement("");                         // 6 top_product (filled below)
            row.addElement(0.0);                        // 7 top_product_qty
            vec.addElement(row);
        }
        rs.close(); pt.close();

        // Top product per category
        String topSql =
            "SELECT p.category_id, p.name, SUM(bd.qty) AS tq" +
            " FROM prod_bill_details bd" +
            " JOIN prod_product p ON p.id = bd.prod_id" +
            " JOIN prod_bill b ON b.id = bd.bill_id AND b.is_cancelled = 0" +
            "   AND b.date BETWEEN ? AND ?" +
            " GROUP BY p.category_id, p.id, p.name";

        pt = con.prepareStatement(topSql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        rs = pt.executeQuery();

        // Build map: catId -> (topName, topQty)
        java.util.HashMap<Integer,Object[]> topMap = new java.util.HashMap<>();
        while (rs.next()) {
            int cid  = rs.getInt(1);
            String nm = rs.getString(2);
            double tq = rs.getDouble(3);
            if (!topMap.containsKey(cid) || tq > (Double) topMap.get(cid)[1]) {
                topMap.put(cid, new Object[]{nm, tq});
            }
        }
        rs.close(); pt.close();

        // Merge top product into summary rows
        for (int i = 0; i < vec.size(); i++) {
            Vector row = (Vector) vec.get(i);
            int cid = (Integer) row.get(0);
            if (topMap.containsKey(cid)) {
                row.set(6, topMap.get(cid)[0]);
                row.set(7, topMap.get(cid)[1]);
            }
        }

        return vec;
    } finally {
        if (rs  != null) try { rs.close();  } catch (SQLException e) {}
        if (pt  != null) try { pt.close();  } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception   e) {}
    }
}

/**
 * Returns product-level detail rows for a single category in the date range.
 * Row layout:
 *   0  product_id   (int)
 *   1  product_name (String)
 *   2  total_qty    (double)
 *   3  total_amount (double)
 *   4  bill_count   (int)
 *   5  avg_price    (double)
 */
public Vector getCategoryProductDetails(int categoryId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        String sql =
            "SELECT p.id, p.name," +
            "  COALESCE(SUM(bd.qty), 0)           AS total_qty," +
            "  COALESCE(SUM(bd.total), 0)          AS total_amount," +
            "  COUNT(DISTINCT b.id)                AS bill_count," +
            "  COALESCE(AVG(bd.price), 0)          AS avg_price" +
            " FROM prod_product p" +
            " LEFT JOIN prod_bill_details bd ON bd.prod_id = p.id" +
            " LEFT JOIN prod_bill b ON b.id = bd.bill_id AND b.is_cancelled = 0" +
            "   AND b.date BETWEEN ? AND ?" +
            " WHERE p.category_id = ?" +
            " GROUP BY p.id, p.name" +
            " ORDER BY total_amount DESC";

        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        pt.setInt(3, categoryId);
        rs = pt.executeQuery();

        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt(1));      // 0 product_id
            row.addElement(rs.getString(2));   // 1 product_name
            row.addElement(rs.getDouble(3));   // 2 total_qty
            row.addElement(rs.getDouble(4));   // 3 total_amount
            row.addElement(rs.getInt(5));      // 4 bill_count
            row.addElement(rs.getDouble(6));   // 5 avg_price
            vec.addElement(row);
        }
        return vec;
    } finally {
        if (rs  != null) try { rs.close();  } catch (SQLException e) {}
        if (pt  != null) try { pt.close();  } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception   e) {}
    }
}

public Vector getAllProduct()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();

	
			pt = con.prepareStatement("SELECT id,name FROM `prod_product` WHERE  is_active=1 ORDER BY NAME ");	
	
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
                ps = con.prepareStatement("INSERT INTO user_permission(module_id, uid,date,time) VALUES(?, ?,now(),now())");
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
    
  public Vector getAllUser()throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();

	
			pt = con.prepareStatement("SELECT id, CONCAT(fullName, ' (', user_name, ')') AS uname " +
                         "FROM users WHERE is_active=1 ORDER BY fullName ");	
	
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
public Vector getUserPermissions(int uid) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        String sql = "SELECT module_id FROM user_permission WHERE uid=?";

        pt = con.prepareStatement(sql);
        pt.setInt(1, uid);

        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));  // id


            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) {}
        if (pt != null) try { pt.close(); } catch (SQLException e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void clearUserPermissions(int uid)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("DELETE FROM user_permission WHERE uid=?");
		
		pt.setInt(1,uid);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
public void addUserPermission(int uid, int moduleId)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("INSERT INTO user_permission (uid, module_id,date,time) VALUES (?, ?,now(),now())");
		
		pt.setInt(1,uid);
		pt.setInt(2,moduleId);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
public int checkTheUserNameExist(String name)throws Exception
{
		Connection con			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;


		con						= util.DBConnectionManager.getConnectionFromPool();
		try
			{
			  int prodId  = 0;

		      pt = con.prepareStatement("SELECT id FROM users WHERE user_name = ?");
		      pt.setString(1,name);
		      rs = pt.executeQuery();
		      if(rs.next())
		      	prodId  = rs.getInt(1);

		      return prodId;
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

public boolean validateOldPassword(int uid, String oldPassword) {
        boolean isValid = false;
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
		con						= util.DBConnectionManager.getConnectionFromPool();
            ps = con.prepareStatement("SELECT password FROM users WHERE id=? AND is_active=1");
            ps.setInt(1, uid);
            rs = ps.executeQuery();

            if (rs.next()) {
                String dbPassword = rs.getString("password");
                if (dbPassword.equals(hashPassword(oldPassword))) {
                    isValid = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
        return isValid;
    }

    // Update password using uid
    
  public void updatePassword(int uid, String newPassword)throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{
		con						= util.DBConnectionManager.getConnectionFromPool();
		pt=con.prepareStatement("UPDATE users SET password=? WHERE id=?");
		
		pt.setString(1,hashPassword(newPassword));
		pt.setInt(2,uid);

		pt.executeUpdate();
		con.commit();
		}
	catch(Exception e)
		{
		con.rollback();
		throw e;
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
///////////////////////-----------------------------
public Vector getAutoLoadDetails(String name,int typeId) throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{	
		con					= util.DBConnectionManager.getConnectionFromPool();
	
		Vector vec			= new Vector();
		
		pt = con.prepareStatement("SELECT a.name, a.code FROM `prod_product` a WHERE (a.NAME LIKE ? OR a.code LIKE ?) AND a.is_active=1 ORDER BY a.NAME ASC LIMIT 50");
		pt.setString(1,"%"+name+"%");
		pt.setString(2,"%"+name+"%");
		rs = pt.executeQuery();
		while(rs.next())
			{
			Vector vec1		= new Vector();
			vec1.addElement(rs.getString(1));
			vec1.addElement(rs.getString(2) != null ? rs.getString(2) : "");
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
///////////////////////-----------------------------
public String getProductFullDetails(String productName) throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null; 
	ResultSet rs			= null;
	ResultSet rs1			= null;
	try
		{	
		con					= util.DBConnectionManager.getConnectionFromPool();

		String productDetails	= "";
		String Qry				= "";
		

		pt = con.prepareStatement("SELECT a.name AS prodsName,b.name AS catName,c.name AS brandName,d.name AS batchNo,d.cost,d.mrp,a.id AS prodsId,b.id AS catId,c.id AS brandId,d.id AS batchId,COALESCE(u.name,'') AS unitName,COALESCE(u.convertion_unit,'') AS convertion_unit,COALESCE(u.convertion_calculation,1) AS convertion_calculation,COALESCE(a.gst,0) AS gst FROM prod_product a JOIN prod_category b ON a.category_id=b.id JOIN prod_brands c ON a.brand_id=c.id JOIN prod_batch d ON a.id=d.product_id LEFT JOIN prod_units u ON u.id=a.unit_id WHERE a.name=?");
		pt.setString(1,productName);									  
		rs = pt.executeQuery();
		if(rs.next())
			{	
			String prodName		= rs.getString(1);
			String catName		= rs.getString(2);
			String brandName	= rs.getString(3);
			String batchNo		= rs.getString(4);
			String cost			= rs.getString(5);
			String mrp			= rs.getString(6);
			String prodsId		= rs.getString(7);
			String catId		= rs.getString(8);
			String brandId		= rs.getString(9);
			String batchId		= rs.getString(10);
			String unitName		= rs.getString(11);
							
			String convertionUnit	= rs.getString(12);
			String convertionCalc	= rs.getString(13);
			String gst				= rs.getString(14);
			productDetails		= prodName+"<#>"+catName+"<#>"+brandName+"<#>"+batchNo+"<#>"+cost+"<#>"+mrp+"<#>"+prodsId+"<#>"+catId+"<#>"+brandId+"<#>"+batchId+"<#>"+unitName+"<#>"+convertionUnit+"<#>"+convertionCalc+"<#>"+gst+"<#>";
			}
		else
			productDetails		= "Invalid Input";
				
		return productDetails;
		}
	finally
		{
		if (rs != null)
			{
	  		try	 { rs.close(); } catch (SQLException e) { ; }
	  		rs = null;
			}
		
		if (rs1 != null)
			{
	  		try	 { rs1.close(); } catch (SQLException e) { ; }
	  		rs1 = null;
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
///////////////////////-----------------------------
public Vector getPaymentTypeDetails() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{	
		con					= util.DBConnectionManager.getConnectionFromPool();
	
		Vector vec			= new Vector();
		
		pt = con.prepareStatement("SELECT id,NAME FROM configure_payment_type WHERE is_blocked=0");
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
///////////////////////-----------------------------
public int getSupplierGstStatus(int supplierId) throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	int isGst = 0;
	try
		{	
		con					= util.DBConnectionManager.getConnectionFromPool();
		
		pt = con.prepareStatement("SELECT is_gst FROM prod_supplier WHERE id = ?");
		pt.setInt(1, supplierId);
		rs = pt.executeQuery();
		if(rs.next())
			{
			isGst = rs.getInt(1);
			}
		return isGst;
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
///////////////////////-----------------------------
public Vector getBillPaymentTypes() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{	
		con					= util.DBConnectionManager.getConnectionFromPool();
	
		Vector vec			= new Vector();
		
		pt = con.prepareStatement("SELECT id,TYPE FROM prod_bill_payment_type WHERE id!=0 ORDER BY id;");
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
///////////////////////-----------------------------
public Vector getBankDetails() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try
		{	
		con					= util.DBConnectionManager.getConnectionFromPool();
	
		Vector vec			= new Vector();
		
		pt = con.prepareStatement("SELECT id,NAME FROM configure_bank_details WHERE is_blocked=0");
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
	public Vector getProductName() throws Exception
	{
	Connection con 			= null;
	PreparedStatement pt 	= null;
	ResultSet rs			= null;
	try{
		con						= util.DBConnectionManager.getConnectionFromPool();
		
	Vector major = new Vector();

	pt = con.prepareStatement("SELECT NAME,id,code FROM prod_product WHERE is_active = 1");
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
///////////////////////-----------------------------
/*public String savePurchaseBill(String invArr,String payArr,String prodArr,int uid) throws Exception
	{
		Connection con = null;
		PreparedStatement pt = null;
		ResultSet rs = null;
		ResultSet rs1 = null;
		try {
			con = util.DBConnectionManager.getConnectionFromPool();

			String purchaseNo	= "";
			int bill	=	0;

			// Split invArr by <#>
			String[] invFields = invArr != null ? invArr.split("<#>") : new String[0];
			String supplier = invFields.length > 0 ? invFields[0] : "";
			String invoiceNo = invFields.length > 1 ? invFields[1] : "";
			String invoiceDate = invFields.length > 2 ? invFields[2] : "";

			// Split payArr by <#>
			String[] payFields = payArr != null ? payArr.split("<#>") : new String[0];
			String payType = payFields.length > 0 ? payFields[0] : "";
			String bank = payFields.length > 1 ? payFields[1] : "";
			String grandTotal = payFields.length > 2 ? payFields[2] : "";
			String paidAmount = payFields.length > 3 ? payFields[3] : "";
			String extraDisc = payFields.length > 4 ? payFields[4] : "";
			String balanceAmount = payFields.length > 5 ? payFields[5] : "";			
			
			pt = con.prepareStatement("SELECT COUNT(id)+1 FROM prod_purchase");
			rs = pt.executeQuery();
			if(rs.next())
				purchaseNo	= "PR"+rs.getString(1);
						
			pt = con.prepareStatement("INSERT INTO prod_purchase(prno,invno,invdate,total,paid,balance,discount,net,ent_uid,pay_type,bank_id,deal_id,ent_date,ent_time) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,NOW(),NOW())");
			pt.setString(1,purchaseNo);
			pt.setString(2,invoiceNo);
			pt.setString(3,invoiceDate);
			pt.setDouble(4,Double.parseDouble(grandTotal));
			pt.setDouble(5,Double.parseDouble(paidAmount));
			pt.setDouble(6,Double.parseDouble(balanceAmount));
			pt.setDouble(7,Double.parseDouble(extraDisc));
			pt.setDouble(8,Double.parseDouble(grandTotal));
			pt.setInt(9,uid);
			pt.setInt(10,Integer.parseInt(payType));
			pt.setInt(11,Integer.parseInt(bank));
			pt.setInt(12,Integer.parseInt(supplier));
			//pt.setDate(13,new java.sql.Date(System.currentTimeMillis()));
			//pt.setTime(14,new java.sql.Time(System.currentTimeMillis()));
			pt.executeUpdate();
			
			//////////////////////
			{
				String[] productRows = prodArr.split("<@>");
				for (String row : productRows) 
				{
					if (row.trim().isEmpty()) continue; 
					String[] fields = row.split("<#>");

				
					String productName = fields[0];
					double pack = Double.parseDouble(fields[1]);
					double qtyPerPack = Double.parseDouble(fields[2]);
					double totQty = Double.parseDouble(fields[3]);
					double freeQty = Double.parseDouble(fields[4]);
					double cost = Double.parseDouble(fields[5]);
					double mrp = Double.parseDouble(fields[6]);
					double disc = Double.parseDouble(fields[7]);
					double tax = Double.parseDouble(fields[8]);
					int purid = 0;
					int prodsid = 0;
					double totalamt	= totQty*cost;
					double taxamt	= totalamt*(tax/100);
					double netamt	= totalamt + taxamt;
					double discAmt	= 0;
					double sgstper	= tax/2;
					double cgstper	= tax/2;
					double sgstAmt 	= taxamt/2;
					double cgstAmt 	= taxamt/2;
					double unitcost	= cost/totQty;
					double unitmrp	= mrp/totQty;


					pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase");
					rs = pt.executeQuery();
					if(rs.next())
						purid	= rs.getInt(1);
					rs.close();
					pt.close();
					
					pt = con.prepareStatement("SELECT id FROM prod_product WHERE NAME =?");
					pt.setString(1,productName);
					rs = pt.executeQuery();
					if(rs.next())
						prodsid	= rs.getInt(1);
					rs.close();
					pt.close();
					
					// Validate product ID - never insert with product ID 0
					if (prodsid == 0) {
						con.rollback();
						throw new Exception("Product not found: " + productName + ". Please check product name for special characters or spelling.");
					}

					pt = con.prepareStatement("INSERT INTO prod_purchase_details(prid,prods_id,pack,qtypack,quantity,free,rate,mrp,totalamt,tax,tax_amt,disc_per,disc,netamt,isinvoicereceived,sgst_per,cgst_per,sgst_amt,cgst_amt,unitrate,unitmrp) "
									+"VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
					pt.setInt(1,purid);
					pt.setInt(2,prodsid);
					pt.setInt(3, (int) pack);
					pt.setDouble(4, qtyPerPack);
					pt.setDouble(5, totQty);
					pt.setDouble(6, freeQty);
					pt.setDouble(7,cost);
					pt.setDouble(8,mrp);
					pt.setDouble(9,totalamt);
					pt.setDouble(10,tax);
					pt.setDouble(11,taxamt);
					pt.setDouble(12,disc);
					pt.setDouble(13,discAmt);
					pt.setDouble(14,netamt);
					pt.setInt(15,1);
					pt.setDouble(16,sgstper);
					pt.setDouble(17,cgstper);
					pt.setDouble(18,cgstAmt);
					pt.setDouble(19,cgstAmt);
					pt.setDouble(20,unitcost);
					pt.setDouble(21,unitmrp);
					bill=pt.executeUpdate();
					
					double stock	= totQty+freeQty;
					String userNotes= "While Stock Added Through Purchase Entry";
									
					int prodTotId	= 0;
					
					pt = con.prepareStatement("SELECT id FROM prod_stock_totals WHERE prods_id =?");
					pt.setString(1,productName);
					rs = pt.executeQuery();
					if(rs.next())
						prodTotId	= rs.getInt(1);
					
					double stockin	= 0;
					double stocknow= 0;
					
					pt = con.prepareStatement("SELECT stock_in,stock_now FROM prod_lifecycle WHERE product_id =? ORDER BY id DESC LIMIT 1");
					pt.setInt(1,prodsid);
					rs = pt.executeQuery();
					if(rs.next())
						stockin	= rs.getDouble(1);
						stocknow= rs.getDouble(2);
					
					pt = con.prepareStatement("INSERT INTO prod_lifecycle(batch_id,product_id,stock_in,stock_now,is_zero_stock_bill,notes,uid,stock_type,DATE,TIME) VALUES(?,?,?,?,?,?,?,?,NOW(),NOW())");
					pt.setInt(1,1);
					pt.setInt(2,prodsid);
					pt.setDouble(3,stock);
					pt.setDouble(4,stock+stocknow);
					pt.setInt(5,2);  ///2 is just assigned
					pt.setString(6,userNotes);
					pt.setInt(7,uid);
					pt.setInt(8,2); ///2 is assigned as stock type
					pt.executeUpdate();
						
					if(prodTotId==0)
					{
						pt = con.prepareStatement("INSERT INTO prod_stock_totals(prods_id,stock,userlog) VALUES(?,?,?)");
						pt.setInt(1,prodsid);
						pt.setDouble(2,stock);
						pt.setString(3,userNotes);
						pt.executeUpdate();					
						
					}
					else
					{
						pt = con.prepareStatement("UPDATE prod_stock_totals SET stock=stock+?,userlog=? WHERE prods_id=?");						
						pt.setDouble(1,stock);
						pt.setString(2,userNotes);
						pt.setInt(3,prodsid);
						pt.executeUpdate();					
						
					}
					
				}
			}
			//////////////////////
			con.commit();
			
			return bill+"";
		} finally {
			if (rs != null) {
				try { rs.close(); } catch (SQLException e) { ; }
				rs = null;
			}
			if (rs1 != null) {
				try { rs1.close(); } catch (SQLException e) { ; }
				rs1 = null;
			}
			if (pt != null) {
				try { pt.close(); } catch (SQLException e) { ; }
				pt = null;
			}
			if (con != null) {
				try { con.close(); } catch (Exception e) {}
				con = null;
			}
		}
	}*/
public String savePurchaseBill(String invArr, String payArr, String prodArr, int uid) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);  // Start the transaction

        String purchaseNo = "";
        int bill = 0;

        // Split invArr by <#>
        String[] invFields = invArr != null ? invArr.split("<#>") : new String[0];
        String supplier = invFields.length > 0 ? invFields[0] : "";
        String invoiceNo = invFields.length > 1 ? invFields[1] : "";
        String invoiceDate = invFields.length > 2 ? invFields[2] : "";
        String offer = invFields.length > 3 ? invFields[3] : "";
        String offerDate = invFields.length > 4 ? invFields[4] : "";
        String lrNo = invFields.length > 5 ? invFields[5] : "";
        String lrDate = invFields.length > 6 ? invFields[6] : "";
        String lrName = invFields.length > 7 ? invFields[7] : "";

        // Split payArr by <#>
        String[] payFields = payArr != null ? payArr.split("<#>") : new String[0];
        String payType = payFields.length > 0 ? payFields[0] : "";
        String bank = payFields.length > 1 ? payFields[1] : "";
        String grandTotal = payFields.length > 2 ? payFields[2] : "";
        String paidAmount = payFields.length > 3 ? payFields[3] : "";
        String extraDisc = payFields.length > 4 ? payFields[4] : "";
        String balanceAmount = payFields.length > 5 ? payFields[5] : "";  

        // Debug logging
        System.out.println("=== Purchase Save Debug ===");
        System.out.println("invArr: " + invArr);
        System.out.println("invFields.length: " + invFields.length);
        System.out.println("offer: [" + offer + "]");
        System.out.println("offerDate: [" + offerDate + "]");

        pt = con.prepareStatement("SELECT COUNT(id)+1 FROM prod_purchase");
        rs = pt.executeQuery();
        if (rs.next())
            purchaseNo = "GRN-" + rs.getString(1);

        pt = con.prepareStatement("INSERT INTO prod_purchase(prno,invno,invdate,total,paid,balance,discount,net,ent_uid,pay_type,bank_id,deal_id,offer,offer_date,lr_no,lr_date,lr_name,ent_date,ent_time) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW(),NOW())");
        pt.setString(1, purchaseNo);
        pt.setString(2, invoiceNo);
        pt.setString(3, invoiceDate);
        pt.setDouble(4, Double.parseDouble(grandTotal));
        pt.setDouble(5, Double.parseDouble(paidAmount));
        pt.setDouble(6, Double.parseDouble(balanceAmount));
        pt.setDouble(7, Double.parseDouble(extraDisc));
        pt.setDouble(8, Double.parseDouble(grandTotal));
        pt.setInt(9, uid);
        pt.setInt(10, Integer.parseInt(payType));
        pt.setInt(11, Integer.parseInt(bank));
        pt.setInt(12, Integer.parseInt(supplier));
        pt.setString(13, (offer == null || offer.trim().isEmpty()) ? null : offer.trim());
        pt.setString(14, (offerDate == null || offerDate.trim().isEmpty()) ? null : offerDate.trim());
        pt.setString(15, (lrNo == null || lrNo.trim().isEmpty()) ? null : lrNo.trim());
        pt.setString(16, (lrDate == null || lrDate.trim().isEmpty()) ? null : lrDate.trim());
        pt.setString(17, (lrName == null || lrName.trim().isEmpty()) ? null : lrName.trim());
        pt.executeUpdate();
        // Get the latest `prod_purchase` id
        int purids = 0;
        pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase");
        rs = pt.executeQuery();
        if (rs.next()) purids = rs.getInt(1);

        // Insert into prod_purchase_supplier_payment table
        pt = con.prepareStatement("INSERT INTO prod_purchase_supplier_payment(prid, deal_id, total, paid, balance, is_active) VALUES(?,?,?,?,?,?)");
        pt.setInt(1, purids);
        pt.setInt(2, Integer.parseInt(supplier)); // Assuming supplier is `deal_id`
        pt.setDouble(3, Double.parseDouble(grandTotal));
        pt.setDouble(4, Double.parseDouble(paidAmount));
        pt.setDouble(5, Double.parseDouble(balanceAmount));
        pt.setInt(6, 1);  // Set `is_active` as 1 (active)
        pt.executeUpdate();

        // Get the latest `prod_purchase_supplier_payment` id
        int supPayId = 0;
        pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_supplier_payment");
        rs = pt.executeQuery();
        if (rs.next()) supPayId = rs.getInt(1);

        // Insert into prod_purchase_supplier_payment_details table
        pt = con.prepareStatement("INSERT INTO prod_purchase_supplier_payment_details(supPayId, payable, paid, balance, pay_type, pay_mode, uid, notes,date,time) VALUES(?,?,?,?,?,?,?,?,now(),now())");
        pt.setInt(1, supPayId);
        pt.setDouble(2, Double.parseDouble(grandTotal));
        pt.setDouble(3, Double.parseDouble(paidAmount));
        pt.setDouble(4, Double.parseDouble(balanceAmount));
        pt.setInt(5, Integer.parseInt(payType));
        pt.setInt(6, Integer.parseInt(bank));
        pt.setInt(7, uid);
        pt.setString(8, "Payment for Purchase Bill");  // You can customize this message as needed
        pt.executeUpdate();
        // Process product details
        if (prodArr != null && !prodArr.trim().isEmpty()) {
            String[] productRows = prodArr.split("<@>");
            for (String row : productRows) {
                if (row.trim().isEmpty()) continue;
                String[] fields = row.split("<#>");

                String productName = fields[0];
                double pack = Double.parseDouble(fields[1]);
                double qtyPerPack = Double.parseDouble(fields[2]);
                double totQty = Double.parseDouble(fields[3]);
                double freeQty = Double.parseDouble(fields[4]);
                double cost = Double.parseDouble(fields[5]);
                double mrp = Double.parseDouble(fields[6]);
                double disc = Double.parseDouble(fields[7]);
                double tax = Double.parseDouble(fields[8]);
                double convertionCalc = fields.length > 10 ? Double.parseDouble(fields[10]) : 1.0;
                if (convertionCalc <= 0) convertionCalc = 1.0;
                int purid = 0;
                int prodsid = 0;
                double totalamt = totQty * cost;
                double taxamt = totalamt * (tax / 100);
                double netamt = totalamt + taxamt;
                double discAmt = 0;
                double sgstper = tax / 2;
                double cgstper = tax / 2;
                double sgstAmt = taxamt / 2;
                double cgstAmt = taxamt / 2;
                double unitcost = cost / totQty;
                double unitmrp = mrp / totQty;

                pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase");
                rs = pt.executeQuery();
                if (rs.next()) purid = rs.getInt(1);

                pt = con.prepareStatement("SELECT id FROM prod_product WHERE NAME =?");
                pt.setString(1, productName);
                rs = pt.executeQuery();
                if (rs.next()) prodsid = rs.getInt(1);

                pt = con.prepareStatement("INSERT INTO prod_purchase_details(prid,prods_id,pack,qtypack,quantity,free,rate,mrp,totalamt,tax,tax_amt,disc_per,disc,netamt,isinvoicereceived,sgst_per,cgst_per,sgst_amt,cgst_amt,unitrate,unitmrp) "
                        + "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
                pt.setInt(1, purid);
                pt.setInt(2, prodsid);
                pt.setInt(3, (int) pack);
                pt.setDouble(4, qtyPerPack);
                pt.setDouble(5, totQty);
                pt.setDouble(6, freeQty);
                pt.setDouble(7, cost);
                pt.setDouble(8, mrp);
                pt.setDouble(9, totalamt);
                pt.setDouble(10, tax);
                pt.setDouble(11, taxamt);
                pt.setDouble(12, disc);
                pt.setDouble(13, discAmt);
                pt.setDouble(14, netamt);
                pt.setInt(15, 1);
                pt.setDouble(16, sgstper);
                pt.setDouble(17, cgstper);
                pt.setDouble(18, cgstAmt);
                pt.setDouble(19, cgstAmt);
                pt.setDouble(20, unitcost);
                pt.setDouble(21, unitmrp);
                bill = pt.executeUpdate();

                BigDecimal stock = BigDecimal.valueOf((totQty + freeQty) * convertionCalc);
                double convertedCost = convertionCalc > 1 ? cost / convertionCalc : cost;
                double convertedMrp = convertionCalc > 1 ? mrp / convertionCalc : mrp;
                String userNotes = "While Stock Added Through Purchase Entry";
                
                pt = con.prepareStatement("UPDATE prod_product SET gst=? WHERE id = ?");
                pt.setDouble(1, tax);  // Update gst
                pt.setInt(2, prodsid);  // Product ID
                pt.executeUpdate();

                // Update stock, cost and mrp in prod_batch
                pt = con.prepareStatement("UPDATE prod_batch SET stock = stock + ?, cost = ?, mrp = ? WHERE product_id = ?");
                pt.setBigDecimal(1, stock);  // Update stock (converted units)
                pt.setDouble(2, convertedCost);  // Update cost per base unit
                pt.setDouble(3, convertedMrp);  // Update mrp per base unit
                pt.setInt(4, prodsid);  // Product ID
                pt.executeUpdate();

                int prodTotId = 0;
                pt = con.prepareStatement("SELECT id FROM prod_stock_totals WHERE prods_id =?");
                pt.setInt(1, prodsid);
                rs = pt.executeQuery();
                if (rs.next()) prodTotId = rs.getInt(1);

                pt = con.prepareStatement("SELECT stock_in,stock_now FROM prod_lifecycle WHERE product_id =? ORDER BY id DESC LIMIT 1");
                pt.setInt(1, prodsid);
                rs = pt.executeQuery();
                BigDecimal stockin = BigDecimal.ZERO;
                BigDecimal stocknow = BigDecimal.ZERO;
                if (rs.next()) {
                    stockin = rs.getBigDecimal(1);
                    stocknow = rs.getBigDecimal(2);
                }

                pt = con.prepareStatement("INSERT INTO prod_lifecycle(batch_id,product_id,stock_in,stock_now,is_zero_stock_bill,notes,uid,stock_type,DATE,TIME) VALUES(?,?,?,?,?,?,?,?,NOW(),NOW())");
                pt.setInt(1, 1);
                pt.setInt(2, prodsid);
                pt.setBigDecimal(3, stock);
                pt.setBigDecimal(4, stock.add(stocknow));
                pt.setInt(5, 2);  // 2 is just assigned
                pt.setString(6, userNotes);
                pt.setInt(7, uid);
                pt.setInt(8, 2);  // 2 is assigned as stock type
                pt.executeUpdate();

                if (prodTotId == 0) {
                    pt = con.prepareStatement("INSERT INTO prod_stock_totals(prods_id,stock,userlog) VALUES(?,?,?)");
                    pt.setInt(1, prodsid);
                    pt.setBigDecimal(2, stock);
                    pt.setString(3, userNotes);
                    pt.executeUpdate();
                } else {
                    pt = con.prepareStatement("UPDATE prod_stock_totals SET stock=stock+?,userlog=? WHERE prods_id=?");
                    pt.setBigDecimal(1, stock);
                    pt.setString(2, userNotes);
                    pt.setInt(3, prodsid);
                    pt.executeUpdate();
                }
            }
        }

        // Commit the transaction
        con.commit();
        
        // Handle supplier cheque auto-allocation after successful purchase
        double balance = Double.parseDouble(balanceAmount);
        if (balance > 0 && purids > 0) {
            try {
                // Auto-clear cheques that have passed due date
                cheque.supplierChequeBean supChequeBean = new cheque.supplierChequeBean();
                supChequeBean.checkAndAutoClearCheques();
                
                // Auto-allocate available cheque to this credit purchase
                int supplierId = Integer.parseInt(supplier);
                supChequeBean.allocatePendingChequesToPurchase(supplierId, purids, balance);
            } catch (Exception e) {
                // Log error but don't stop purchase processing
                System.err.println("Error handling supplier cheque auto-allocation: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        return purchaseNo;

    } catch (Exception e) {
        // Rollback on error
        if (con != null) {
            con.rollback();
        }
        throw e;
    } finally {
        // Close resources
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (rs1 != null) try { rs1.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (SQLException e) { ; }
    }
}

/**
 * Save Purchase Bill with PO tracking
 * @param invArr - Supplier, Invoice No, Invoice Date
 * @param payArr - Payment details
 * @param prodArr - Product details
 * @param uid - User ID
 * @param poId - Purchase Order ID (0 if standalone)
 * @param mode - "from-po" or "standalone"
 * @return bill count
 */
public String savePurchaseBill(String invArr, String payArr, String prodArr, int uid, int poId, String mode) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    ResultSet rs1 = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);  // Start the transaction

        String purchaseNo = "";
        int bill = 0;

        // Split invArr by <#>
        String[] invFields = invArr != null ? invArr.split("<#>") : new String[0];
        String supplier = invFields.length > 0 ? invFields[0] : "";
        String invoiceNo = invFields.length > 1 ? invFields[1] : "";
        String invoiceDate = invFields.length > 2 ? invFields[2] : "";
        String offer = invFields.length > 3 ? invFields[3] : "";
        String offerDate = invFields.length > 4 ? invFields[4] : "";
        String lrNo = invFields.length > 5 ? invFields[5] : "";
        String lrDate = invFields.length > 6 ? invFields[6] : "";
        String lrName = invFields.length > 7 ? invFields[7] : "";

        // Split payArr by <#>
        String[] payFields = payArr != null ? payArr.split("<#>") : new String[0];
        String payType = payFields.length > 0 ? payFields[0] : "";
        String bank = payFields.length > 1 ? payFields[1] : "";
        String grandTotal = payFields.length > 2 ? payFields[2] : "";
        String paidAmount = payFields.length > 3 ? payFields[3] : "";
        String extraDisc = payFields.length > 4 ? payFields[4] : "";
        String balanceAmount = payFields.length > 5 ? payFields[5] : "";  

        // Generate purchase receipt number using counter table
        // Initialize counter table if not exists
        pt = con.prepareStatement("SELECT COUNT(*) FROM prod_purchase_counter WHERE id = 1");
        rs = pt.executeQuery();
        int counterExists = 0;
        if (rs.next()) {
            counterExists = rs.getInt(1);
        }
        rs.close();
        pt.close();
        
        if (counterExists == 0) {
            pt = con.prepareStatement("INSERT INTO prod_purchase_counter (id, last_pr_no) VALUES (1, 0)");
            pt.executeUpdate();
            pt.close();
        }
        
        // Get and increment counter (only for is_po=0 purchases)
        pt = con.prepareStatement("SELECT last_pr_no FROM prod_purchase_counter WHERE id = 1 FOR UPDATE");
        rs = pt.executeQuery();
        int lastPrNo = 0;
        if (rs.next()) {
            lastPrNo = rs.getInt("last_pr_no");
        }
        rs.close();
        pt.close();
        
        lastPrNo++;
        purchaseNo = "GRN-" + lastPrNo;
        
        pt = con.prepareStatement("UPDATE prod_purchase_counter SET last_pr_no = ? WHERE id = 1");
        pt.setInt(1, lastPrNo);
        pt.executeUpdate();
        pt.close();

        pt = con.prepareStatement("INSERT INTO prod_purchase(prno,invno,invdate,total,paid,balance,discount,net,ent_uid,pay_type,bank_id,deal_id,is_po,offer,offer_date,lr_no,lr_date,lr_name,ent_date,ent_time) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW(),NOW())");
        pt.setString(1, purchaseNo);
        pt.setString(2, invoiceNo);
        pt.setString(3, invoiceDate);
        pt.setDouble(4, Double.parseDouble(grandTotal));
        pt.setDouble(5, Double.parseDouble(paidAmount));
        pt.setDouble(6, Double.parseDouble(balanceAmount));
        pt.setDouble(7, Double.parseDouble(extraDisc));
        pt.setDouble(8, Double.parseDouble(grandTotal));
        pt.setInt(9, uid);
        pt.setInt(10, Integer.parseInt(payType));
        pt.setInt(11, Integer.parseInt(bank));
        pt.setInt(12, Integer.parseInt(supplier));
        pt.setInt(13, 0); // is_po = 0 for purchase receipts
        pt.setString(14, (offer == null || offer.trim().isEmpty()) ? null : offer.trim());
        pt.setString(15, (offerDate == null || offerDate.trim().isEmpty()) ? null : offerDate.trim());
        pt.setString(16, (lrNo == null || lrNo.trim().isEmpty()) ? null : lrNo.trim());
        pt.setString(17, (lrDate == null || lrDate.trim().isEmpty()) ? null : lrDate.trim());
        pt.setString(18, (lrName == null || lrName.trim().isEmpty()) ? null : lrName.trim());
        pt.executeUpdate();
        pt.close();
        
        // Get the latest `prod_purchase` id (GRN ID)
        int purids = 0;
        pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase");
        rs = pt.executeQuery();
        if (rs.next()) purids = rs.getInt(1);
        rs.close();
        pt.close();
        
        // If receiving from PO, update the PO record's grn_id
        if (mode != null && mode.equals("from-po") && poId > 0) {
            pt = con.prepareStatement("UPDATE prod_purchase SET grn_id = ? WHERE id = ?");
            pt.setInt(1, purids); // Set GRN ID to the newly created purchase receipt
            pt.setInt(2, poId);   // Update the original PO record
            pt.executeUpdate();
            pt.close();
        }

        // Check if this is from PO with advance payment
        int existingSupPayId = 0;
        double oldPaid = 0;
        if (mode != null && mode.equals("from-po") && poId > 0) {
            // Check for existing advance payment record
            pt = con.prepareStatement(
                "SELECT sp.id, sp.paid " +
                "FROM prod_purchase_supplier_payment sp " +
                "JOIN prod_purchase_supplier_payment_details spd ON sp.id = spd.supPayId " +
                "WHERE sp.prid = ? AND spd.notes LIKE ?"
            );
            pt.setInt(1, poId); // PO ID was temporarily stored as prid
            pt.setString(2, "%Advance Payment for PO%ID: " + poId + ")%");
            rs = pt.executeQuery();
            if (rs.next()) {
                existingSupPayId = rs.getInt("id");
                oldPaid = rs.getDouble("paid");
            }
            rs.close();
            pt.close();
        }

        int supPayId = 0;
        double newPaidAmount = Double.parseDouble(paidAmount);
        double newGrandTotal = Double.parseDouble(grandTotal);
        
        if (existingSupPayId > 0) {
            // Update existing record (from advance payment)
            double totalPaid = oldPaid + newPaidAmount;
            double newBalance = newGrandTotal - totalPaid;
            
            pt = con.prepareStatement(
                "UPDATE prod_purchase_supplier_payment " +
                "SET prid = ?, total = ?, paid = ?, balance = ? " +
                "WHERE id = ?"
            );
            pt.setInt(1, purids);           // Update prid to actual purchase receipt ID
            pt.setDouble(2, newGrandTotal);  // Update total to current purchase total
            pt.setDouble(3, totalPaid);      // paid = old paid + new paid
            pt.setDouble(4, newBalance);     // balance = total - total paid
            pt.setInt(5, existingSupPayId);
            pt.executeUpdate();
            pt.close();
            
            supPayId = existingSupPayId;
        } else {
            // Insert new record (standalone purchase or PO without advance)
            pt = con.prepareStatement("INSERT INTO prod_purchase_supplier_payment(prid, deal_id, total, paid, balance, is_active) VALUES(?,?,?,?,?,?)");
            pt.setInt(1, purids);
            pt.setInt(2, Integer.parseInt(supplier));
            pt.setDouble(3, newGrandTotal);
            pt.setDouble(4, newPaidAmount);
            pt.setDouble(5, Double.parseDouble(balanceAmount));
            pt.setInt(6, 1);
            pt.executeUpdate();
            pt.close();

            // Get the latest `prod_purchase_supplier_payment` id
            pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_supplier_payment");
            rs = pt.executeQuery();
            if (rs.next()) supPayId = rs.getInt(1);
            rs.close();
            pt.close();
        }

        // Insert into prod_purchase_supplier_payment_details table
        pt = con.prepareStatement("INSERT INTO prod_purchase_supplier_payment_details(supPayId, payable, paid, balance, pay_type, pay_mode, uid, notes,date,time) VALUES(?,?,?,?,?,?,?,?,now(),now())");
        pt.setInt(1, supPayId);
        pt.setDouble(2, newGrandTotal);
        pt.setDouble(3, newPaidAmount);
        pt.setDouble(4, newGrandTotal - newPaidAmount); // Balance for this transaction only
        pt.setInt(5, Integer.parseInt(payType));
        pt.setInt(6, Integer.parseInt(bank));
        pt.setInt(7, uid);
        pt.setString(8, mode != null && mode.equals("from-po") ? "Payment for Purchase from PO" : "Payment for Purchase Bill");
        pt.executeUpdate();
        pt.close();
        
        // Process product details
        if (prodArr != null && !prodArr.trim().isEmpty()) {
            String[] productRows = prodArr.split("<@>");
            for (String row : productRows) {
                if (row.trim().isEmpty()) continue;
                String[] fields = row.split("<#>");

                String productName = fields[0];
                double pack = Double.parseDouble(fields[1]);
                double qtyPerPack = Double.parseDouble(fields[2]);
                double totQty = Double.parseDouble(fields[3]);
                double freeQty = Double.parseDouble(fields[4]);
                double cost = Double.parseDouble(fields[5]);
                double mrp = Double.parseDouble(fields[6]);
                double disc = Double.parseDouble(fields[7]);
                double tax = Double.parseDouble(fields[8]);
                int poDetailId = fields.length > 9 ? Integer.parseInt(fields[9]) : 0;
                double convertionCalc = fields.length > 10 ? Double.parseDouble(fields[10]) : 1.0;
                if (convertionCalc <= 0) convertionCalc = 1.0;
                
                int purid = 0;
                int prodsid = 0;
                double totalamt = totQty * cost;
                double taxamt = totalamt * (tax / 100);
                double netamt = totalamt + taxamt;
                double discAmt = 0;
                double sgstper = tax / 2;
                double cgstper = tax / 2;
                double sgstAmt = taxamt / 2;
                double cgstAmt = taxamt / 2;
                double unitcost = cost / totQty;
                double unitmrp = mrp / totQty;

                pt = con.prepareStatement("SELECT MAX(id) FROM prod_purchase");
                rs = pt.executeQuery();
                if (rs.next()) purid = rs.getInt(1);
                rs.close();
                pt.close();

                pt = con.prepareStatement("SELECT id FROM prod_product WHERE NAME =?");
                pt.setString(1, productName);
                rs = pt.executeQuery();
                if (rs.next()) prodsid = rs.getInt(1);
                rs.close();
                pt.close();
                
                // Validate product ID - never insert with product ID 0
                if (prodsid == 0) {
                    con.rollback();
                    throw new Exception("Product not found: " + productName + ". Please check product name for special characters or spelling.");
                }

                pt = con.prepareStatement("INSERT INTO prod_purchase_details(prid,prods_id,pack,qtypack,quantity,free,rate,mrp,totalamt,tax,tax_amt,disc_per,disc,netamt,isinvoicereceived,sgst_per,cgst_per,sgst_amt,cgst_amt,unitrate,unitmrp) "
                        + "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);");
                pt.setInt(1, purid);
                pt.setInt(2, prodsid);
                pt.setInt(3, (int) pack);
                pt.setDouble(4, qtyPerPack);
                pt.setDouble(5, totQty);
                pt.setDouble(6, freeQty);
                pt.setDouble(7, cost);
                pt.setDouble(8, mrp);
                pt.setDouble(9, totalamt);
                pt.setDouble(10, tax);
                pt.setDouble(11, taxamt);
                pt.setDouble(12, disc);
                pt.setDouble(13, discAmt);
                pt.setDouble(14, netamt);
                pt.setInt(15, 1);
                pt.setDouble(16, sgstper);
                pt.setDouble(17, cgstper);
                pt.setDouble(18, cgstAmt);
                pt.setDouble(19, cgstAmt);
                pt.setDouble(20, unitcost);
                pt.setDouble(21, unitmrp);
                bill = pt.executeUpdate();
                pt.close();
                
                // If this item came from a purchase order, update the PO detail record
                if (mode != null && mode.equals("from-po") && poId > 0 && poDetailId > 0) {
                    // Get the ordered quantity and current received quantity from the PO detail
                    pt = con.prepareStatement("SELECT ordered_qty, COALESCE(received_qty, 0) FROM prod_purchase_details WHERE id = ?");
                    pt.setInt(1, poDetailId);
                    rs = pt.executeQuery();
                    double orderedQty = 0;
                    double currentReceivedQty = 0;
                    if (rs.next()) {
                        orderedQty = rs.getDouble(1);
                        currentReceivedQty = rs.getDouble(2);
                    }
                    rs.close();
                    pt.close();
                    
                    // Calculate the new totals
                    double newReceivedQty = currentReceivedQty + totQty;
                    double newPendingQty = orderedQty - newReceivedQty;
                    int isFullyReceived = (orderedQty == newReceivedQty) ? 1 : 0;
                    
                    // Update the PO detail record with calculated values
                    pt = con.prepareStatement(
                        "UPDATE prod_purchase_details SET " +
                        "received_qty = ?, " +
                        "pending_qty = ?, " +
                        "is_fully_received = ? " +
                        "WHERE id = ?"
                    );
                    pt.setDouble(1, newReceivedQty);
                    pt.setDouble(2, newPendingQty);
                    pt.setInt(3, isFullyReceived);
                    pt.setInt(4, poDetailId);
                    pt.executeUpdate();
                    pt.close();
                }

                BigDecimal stock = BigDecimal.valueOf((totQty + freeQty) * convertionCalc);
                double convertedCost = convertionCalc > 1 ? cost / convertionCalc : cost;
                double convertedMrp = convertionCalc > 1 ? mrp / convertionCalc : mrp;
                String userNotes = "While Stock Added Through Purchase Entry";
                
                pt = con.prepareStatement("UPDATE prod_product SET gst=? WHERE id = ?");
                pt.setDouble(1, tax);  // Update gst
                pt.setInt(2, prodsid);  // Product ID
                pt.executeUpdate();
                pt.close();

                // Update stock, cost and mrp in prod_batch
                pt = con.prepareStatement("UPDATE prod_batch SET stock = stock + ?, cost = ?, mrp = ? WHERE product_id = ?");
                pt.setBigDecimal(1, stock);  // Update stock (converted units)
                pt.setDouble(2, convertedCost);  // Update cost per base unit
                pt.setDouble(3, convertedMrp);  // Update mrp per base unit
                pt.setInt(4, prodsid);  // Product ID
                pt.executeUpdate();
                pt.close();

                int prodTotId = 0;
                pt = con.prepareStatement("SELECT id FROM prod_stock_totals WHERE prods_id =?");
                pt.setInt(1, prodsid);
                rs = pt.executeQuery();
                if (rs.next()) prodTotId = rs.getInt(1);
                rs.close();
                pt.close();

                pt = con.prepareStatement("SELECT stock_in,stock_now FROM prod_lifecycle WHERE product_id =? ORDER BY id DESC LIMIT 1");
                pt.setInt(1, prodsid);
                rs = pt.executeQuery();
                BigDecimal stockin = BigDecimal.ZERO;
                BigDecimal stocknow = BigDecimal.ZERO;
                if (rs.next()) {
                    stockin = rs.getBigDecimal(1);
                    stocknow = rs.getBigDecimal(2);
                }
                rs.close();
                pt.close();

                pt = con.prepareStatement("INSERT INTO prod_lifecycle(batch_id,product_id,stock_in,stock_now,is_zero_stock_bill,notes,uid,stock_type,DATE,TIME) VALUES(?,?,?,?,?,?,?,?,NOW(),NOW())");
                pt.setInt(1, 1);
                pt.setInt(2, prodsid);
                pt.setBigDecimal(3, stock);
                pt.setBigDecimal(4, stock.add(stocknow));
                pt.setInt(5, 2);  // 2 is just assigned
                pt.setString(6, userNotes);
                pt.setInt(7, uid);
                pt.setInt(8, 2);  // 2 is assigned as stock type
                pt.executeUpdate();
                pt.close();

                if (prodTotId == 0) {
                    pt = con.prepareStatement("INSERT INTO prod_stock_totals(prods_id,stock,userlog) VALUES(?,?,?)");
                    pt.setInt(1, prodsid);
                    pt.setBigDecimal(2, stock);
                    pt.setString(3, userNotes);
                    pt.executeUpdate();
                    pt.close();
                } else {
                    pt = con.prepareStatement("UPDATE prod_stock_totals SET stock=stock+?,userlog=? WHERE prods_id=?");
                    pt.setBigDecimal(1, stock);
                    pt.setString(2, userNotes);
                    pt.setInt(3, prodsid);
                    pt.executeUpdate();
                    pt.close();
                }
            }
        }

        // Commit the transaction
        con.commit();
        
        // Handle supplier cheque auto-allocation after successful purchase
        double balance = Double.parseDouble(balanceAmount);
        if (balance > 0 && purids > 0) {
            try {
                // Auto-clear cheques that have passed due date
                cheque.supplierChequeBean supChequeBean = new cheque.supplierChequeBean();
                supChequeBean.checkAndAutoClearCheques();
                
                // Auto-allocate available cheque to this credit purchase
                int supplierId = Integer.parseInt(supplier);
                supChequeBean.allocatePendingChequesToPurchase(supplierId, purids, balance);
            } catch (Exception e) {
                // Log error but don't stop purchase processing
                System.err.println("Error handling supplier cheque auto-allocation: " + e.getMessage());
                e.printStackTrace();
            }
        }
        
        return purchaseNo;

    } catch (Exception e) {
        // Rollback on error
        if (con != null) {
            con.rollback();
        }
        throw e;
    } finally {
        // Close resources
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (rs1 != null) try { rs1.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (SQLException e) { ; }
    }
}

///////////////////////-----------------------------
public Vector getProductList(String searchKey) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector list = new Vector();   // <-- no <String>

    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT name FROM prod_product WHERE is_active=1 AND name LIKE ? ORDER BY name";
        ps = con.prepareStatement(sql);
        ps.setString(1, "%" + searchKey + "%");
        rs = ps.executeQuery();

        while (rs.next()) {
            list.add(rs.getString("name"));
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return list;
}

public Vector getPurchaseReport(String from, String to, int supId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        StringBuilder sql = new StringBuilder();
        sql.append("SELECT a.`id`, a.`invno`,a.`invdate`,a.`total`,a.`paid`,a.`balance`,a.`ent_date`,a.`ent_time`,b.user_name,c.name,a.prno ");
        sql.append("FROM `prod_purchase` a, users b ,prod_supplier c ");
        sql.append("WHERE a.`ent_uid` = b.id AND c.id=a.deal_id ");
        sql.append("AND a.`ent_date` BETWEEN ? AND ? ");
        sql.append("AND a.is_cancelled = 0 AND a.invno!='' ");
        
        if (supId > 0) {
            sql.append("AND a.deal_id = ? ");
        }

        ps = con.prepareStatement(sql.toString());
        ps.setString(1, from);
        ps.setString(2, to);

        if (supId > 0) {
            ps.setInt(3, supId);
        }

        rs = ps.executeQuery();

        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1)); // purchase id
            row.addElement(rs.getString(2)); // invoice no
            row.addElement(rs.getString(2));
            row.addElement(rs.getString(3));
            row.addElement(rs.getString(4));
            row.addElement(rs.getString(5));
            row.addElement(rs.getString(6));
            row.addElement(rs.getString(7));
            row.addElement(rs.getString(8));
            row.addElement(rs.getString(9));
            row.addElement(rs.getString(10));
            row.addElement(rs.getString(11));
            

            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}

public Vector getPurchaseGSTReport(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT p.invno AS invoice_no, s.name AS supplier_name, p.invdate AS invoice_date, prod.name AS item_description, " +
                     "pd.netamt AS purchase_amount, pd.totalamt AS taxable_amount, pd.tax AS gst_rate, " +
                     "pd.cgst_amt AS cgst_amount, pd.sgst_amt AS sgst_amount, pd.igst_amt AS igst_amount, " +
                     "pd.netamt AS total_amount " +
                     "FROM prod_purchase p " +
                     "JOIN prod_purchase_details pd ON p.id = pd.prid " +
                     "JOIN prod_product prod ON pd.prods_id = prod.id " +
                     "JOIN prod_supplier s ON p.deal_id = s.id " +
                     "WHERE p.ent_date BETWEEN ? AND ? AND p.is_cancelled = 0 AND p.is_po=0 " +
                     "ORDER BY p.invdate DESC, p.invno;";
        
        ps = con.prepareStatement(sql);
        ps.setString(1, from);
        ps.setString(2, to);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString("invoice_no"));
            row.addElement(rs.getString("supplier_name"));
            row.addElement(rs.getString("invoice_date"));
            row.addElement(rs.getString("item_description"));
            row.addElement(rs.getString("purchase_amount"));
            row.addElement(rs.getString("taxable_amount"));
            row.addElement(rs.getString("gst_rate"));
            row.addElement(rs.getString("cgst_amount"));
            row.addElement(rs.getString("sgst_amount"));
            row.addElement(rs.getString("igst_amount"));
            row.addElement(rs.getString("total_amount"));
            
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}

public Vector getGSTSummary(String from,String to)throws Exception
{
		Connection con 			= null;
		PreparedStatement pt 	= null;
		ResultSet rs			= null;
	try
	  {
	   con						= util.DBConnectionManager.getConnectionFromPool();
		Vector vec = new Vector();
	
	
			pt = con.prepareStatement("SELECT a.gst AS gst_rate, SUM(a.total / (1 + a.gst/100)) AS taxable_value,  "
						 +"      a.gst/2 AS sgst_percent, SUM((a.total / (1 + a.gst/100)) * a.gst / 200) AS sgst_amount, "
						 +"      a.gst/2 AS cgst_percent, SUM((a.total / (1 + a.gst/100)) * a.gst / 200) AS cgst_amount, "
						 +"      SUM((a.total / (1 + a.gst/100)) * a.gst / 100) AS total_gst,SUM(a.total) AS total,SUM(a.`total`) AS inoice_total "
					+"	FROM prod_bill_details a JOIN prod_bill b ON a.bill_id = b.id "
					+"	WHERE b.is_cancelled = 0 AND a.is_cancelled=0 AND b.date BETWEEN ? AND ? "
					+"	GROUP BY a.gst ORDER BY a.gst;");	
	
		pt.setString(1,from);
		pt.setString(2,to);	
	
		rs = pt.executeQuery();
	while(rs.next())
		{	
		Vector vec1		= new Vector();
		vec1.addElement(rs.getString(1)); 	
		vec1.addElement(rs.getString(2));	
		vec1.addElement(rs.getString(3));
		vec1.addElement(rs.getString(4));	
		vec1.addElement(rs.getString(5));	
		vec1.addElement(rs.getString(6));	
		vec1.addElement(rs.getString(7));	
		vec1.addElement(rs.getString(8));
		vec1.addElement(rs.getString(9));	

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

public Vector getPurchaseGSTSummary(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        pt = con.prepareStatement("SELECT pd.tax AS gst_rate, SUM(pd.totalamt) AS taxable_value, " +
                         "MAX(pd.sgst_per) AS sgst_percent, SUM(pd.sgst_amt) AS sgst_amount, " +
                         "MAX(pd.cgst_per) AS cgst_percent, SUM(pd.cgst_amt) AS cgst_amount, " +
                         "SUM(pd.sgst_amt + pd.cgst_amt + pd.igst_amt) AS total_gst, SUM(pd.netamt) AS total, SUM(p.total) AS invoice_total " +
                         "FROM prod_purchase_details pd JOIN prod_purchase p ON pd.prid = p.id " +
                         "WHERE p.is_cancelled = 0 AND p.ent_date AND p.is_po=0 BETWEEN ? AND ? " +
                         "GROUP BY pd.tax ORDER BY pd.tax;");

        pt.setString(1, from);
        pt.setString(2, to);

        rs = pt.executeQuery();
        while (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));
            vec1.addElement(rs.getString(2));
            vec1.addElement(rs.getString(3));
            vec1.addElement(rs.getString(4));
            vec1.addElement(rs.getString(5));
            vec1.addElement(rs.getString(6));
            vec1.addElement(rs.getString(7));
            vec1.addElement(rs.getString(8));
            vec1.addElement(rs.getString(9));

            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }

        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }

        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

// GSTR-3B Related Methods
public Vector getGSTR3BSalesData(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        // Get sales summary with CGST, SGST breakdown
        pt = con.prepareStatement(
            "SELECT " +
            "  SUM(a.total / (1 + a.gst/100)) AS taxable_value, " +
            "  0 AS igst_amount, " +  // Currently no IGST tracking - needs customer state field
            "  SUM((a.total / (1 + a.gst/100)) * a.gst / 200) AS cgst_amount, " +
            "  SUM((a.total / (1 + a.gst/100)) * a.gst / 200) AS sgst_amount " +
            "FROM prod_bill_details a " +
            "JOIN prod_bill b ON a.bill_id = b.id " +
            "WHERE b.is_cancelled = 0 AND a.is_cancelled = 0 " +
            "AND b.date BETWEEN ? AND ?"
        );

        pt.setString(1, from);
        pt.setString(2, to);

        rs = pt.executeQuery();
        if (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));  // taxable_value
            vec1.addElement(rs.getString(2));  // igst
            vec1.addElement(rs.getString(3));  // cgst
            vec1.addElement(rs.getString(4));  // sgst
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

public Vector getGSTR3BPurchaseData(String from, String to) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();

        // Get purchase summary for ITC
        pt = con.prepareStatement(
            "SELECT " +
            "  SUM(pd.totalamt) AS taxable_value, " +
            "  COALESCE(SUM(pd.igst_amt), 0) AS igst_amount, " +
            "  COALESCE(SUM(pd.cgst_amt), 0) AS cgst_amount, " +
            "  COALESCE(SUM(pd.sgst_amt), 0) AS sgst_amount " +
            "FROM prod_purchase_details pd " +
            "JOIN prod_purchase p ON pd.prid = p.id " +
            "WHERE p.is_cancelled = 0 AND p.is_po = 0 " +
            "AND p.ent_date BETWEEN ? AND ?"
        );

        pt.setString(1, from);
        pt.setString(2, to);

        rs = pt.executeQuery();
        if (rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString(1));  // taxable_value
            vec1.addElement(rs.getString(2));  // igst
            vec1.addElement(rs.getString(3));  // cgst
            vec1.addElement(rs.getString(4));  // sgst
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

public Vector getGSTR3BITCData(String from, String to) throws Exception {
    // Currently same as purchase data - ITC available equals purchase GST
    // Future enhancement: track ITC reversals separately
    return getGSTR3BPurchaseData(from, to);
}

public Vector getPurchaseHeaderById(int purchaseId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String sql = "SELECT a.`id`, a.`invno`, a.`invdate`, a.`total`, a.`paid`, a.`balance`, a.`ent_date`, a.`ent_time`, b.user_name, c.name " +
                     "FROM `prod_purchase` a, users b, prod_supplier c " +
                     "WHERE a.`ent_uid` = b.id AND c.id = a.deal_id AND a.`id` = ? AND a.is_cancelled = 0";

        ps = con.prepareStatement(sql);
        ps.setInt(1, purchaseId);
        rs = ps.executeQuery();

        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1)); // id
            row.addElement(rs.getString(2)); // invno
            row.addElement(rs.getString(3)); // invdate
            row.addElement(rs.getString(4)); // total
            row.addElement(rs.getString(5)); // paid
            row.addElement(rs.getString(6)); // balance
            row.addElement(rs.getString(7)); // ent_date
            row.addElement(rs.getString(8)); // ent_time
            row.addElement(rs.getString(9)); // user_name
            row.addElement(rs.getString(10)); // supplier name
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}

public Vector getPurchaseDetailsById(int purchaseId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();

        String sql = "SELECT pd.`id`, p.`name` AS product_name, pd.`pack`, pd.`qtypack`, pd.`quantity`, pd.`free`, " +
                     "pd.`rate`, pd.`mrp`, pd.`totalamt`, pd.`tax`, pd.`cgst_per`, pd.`sgst_per`, pd.`igst_per`, " +
                     "pd.`cgst_amt`, pd.`sgst_amt`, pd.`igst_amt`, pd.`netamt` " +
                     "FROM `prod_purchase_details` pd " +
                     "JOIN `prod_product` p ON pd.`prods_id` = p.`id` " +
                     "WHERE pd.`prid` = ?";

        ps = con.prepareStatement(sql);
        ps.setInt(1, purchaseId);
        rs = ps.executeQuery();

        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));  // id
            row.addElement(rs.getString(2));  // product_name
            row.addElement(rs.getString(3));  // pack
            row.addElement(rs.getString(4));  // qtypack
            row.addElement(rs.getString(5));  // quantity
            row.addElement(rs.getString(6));  // free
            row.addElement(rs.getString(7));  // rate
            row.addElement(rs.getString(8));  // mrp
            row.addElement(rs.getString(9));  // totalamt
            row.addElement(rs.getString(10)); // tax
            row.addElement(rs.getString(11)); // cgst_per
            row.addElement(rs.getString(12)); // sgst_per
            row.addElement(rs.getString(13)); // igst_per
            row.addElement(rs.getString(14)); // cgst_amt
            row.addElement(rs.getString(15)); // sgst_amt
            row.addElement(rs.getString(16)); // igst_amt
            row.addElement(rs.getString(17)); // netamt
            vec.add(row);
        }
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
    return vec;
}

////////////////////////////------------------------
// Product Components Methods
////////////////////////////------------------------

// Add component to a product
public void addProductComponent(int productId, int componentProductId, BigDecimal quantity, int userId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        pt = con.prepareStatement(
            "INSERT INTO prod_product_components (product_id, component_product_id, quantity, created_by) VALUES (?, ?, ?, ?)"
        );
        pt.setInt(1, productId);
        pt.setInt(2, componentProductId);
        pt.setBigDecimal(3, quantity);
        pt.setInt(4, userId);
        pt.executeUpdate();
        
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (SQLException e) { ; }
    }
}

// Get all components for a product
public Vector getProductComponents(int productId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        Vector components = new Vector();
        
        pt = con.prepareStatement(
            "SELECT c.id, p.name, p.code, c.quantity, p.id as comp_prod_id " +
            "FROM prod_product_components c " +
            "JOIN prod_product p ON c.component_product_id = p.id " +
            "WHERE c.product_id = ? AND p.is_active = 1"
        );
        pt.setInt(1, productId);
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getInt("id"));
            vec.addElement(rs.getString("name"));
            vec.addElement(rs.getString("code"));
            vec.addElement(rs.getDouble("quantity"));
            vec.addElement(rs.getInt("comp_prod_id"));
            components.addElement(vec);
        }
        
        con.commit();
        return components;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (SQLException e) { ; }
    }
}

// Delete a component
public void deleteProductComponent(int componentId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        pt = con.prepareStatement("DELETE FROM prod_product_components WHERE id = ?");
        pt.setInt(1, componentId);
        pt.executeUpdate();
        
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (SQLException e) { ; }
    }
}

// Get products that have components configured
public Vector getProductsWithComponents() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        Vector products = new Vector();
        
        pt = con.prepareStatement(
            "SELECT DISTINCT p.id, p.name, p.code, COUNT(c.id) as component_count " +
            "FROM prod_product p " +
            "LEFT JOIN prod_product_components c ON p.id = c.product_id " +
            "WHERE p.is_active = 1 " +
            "GROUP BY p.id, p.name, p.code " +
            "HAVING component_count > 0 " +
            "ORDER BY p.name"
        );
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector vec = new Vector();
            vec.addElement(rs.getInt("id"));
            vec.addElement(rs.getString("name"));
            vec.addElement(rs.getString("code"));
            vec.addElement(rs.getInt("component_count"));
            products.addElement(vec);
        }
        
        con.commit();
        return products;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (SQLException e) { ; }
    }
}

///////////////////////-----------------------------
// Get product name by ID
public String getProductNameById(int productId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT name FROM prod_product WHERE id = ?");
        pt.setInt(1, productId);
        rs = pt.executeQuery();
        if (rs.next()) {
            return rs.getString("name");
        }
        return "";
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (SQLException e) { ; }
    }
}

///////////////////////-----------------------------
// Supplier Payment Report Methods
public Vector getSupplierPaymentReport(String fromDate, String toDate, int supplierId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT sp.id, p.ent_date as pay_date, p.prno, s.name as supplier_name, ");
        sql.append("sp.total, sp.paid, sp.balance ");
        sql.append("FROM prod_purchase_supplier_payment sp ");
        sql.append("INNER JOIN prod_supplier s ON sp.deal_id = s.id ");
        sql.append("INNER JOIN prod_purchase p ON sp.prid = p.id ");
        sql.append("WHERE p.ent_date BETWEEN ? AND ? ");
        
        if (supplierId > 0) {
            sql.append("AND sp.deal_id = ? ");
        }
        
        sql.append("ORDER BY p.ent_date DESC, sp.id DESC");
        
        pt = con.prepareStatement(sql.toString());
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        
        if (supplierId > 0) {
            pt.setInt(3, supplierId);
        }
        
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("pay_date"));
            row.addElement(rs.getString("prno"));
            row.addElement(rs.getString("supplier_name"));
            row.addElement(rs.getDouble("total"));
            row.addElement(rs.getDouble("paid"));
            row.addElement(rs.getDouble("balance"));
            vec.addElement(row);
        }
        
        return vec;
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getSupplierPaymentDetailsReport(int paymentId) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT spd.paid, ");
        sql.append("CONCAT(DATE_FORMAT(spd.date, '%d-%m-%Y'), ' ', ");
        sql.append("TIME_FORMAT(spd.time, '%h:%i %p')) as dateTime, ");
        sql.append("CASE ");
        sql.append("  WHEN spd.pay_type = 1 THEN 'CASH' ");
        sql.append("  WHEN spd.pay_type = 2 THEN 'UPI' ");
        sql.append("  WHEN spd.pay_type = 3 THEN 'DEBIT/CEDIT CARD' ");
        sql.append("  WHEN spd.pay_type = 4 THEN 'BANK TRANSFER' ");
        sql.append("  ELSE 'Other' ");
        sql.append("END as paymentMode, ");
        sql.append("u.user_name as userName ");
        sql.append("FROM prod_purchase_supplier_payment_details spd ");
        sql.append("LEFT JOIN users u ON spd.uid = u.id ");
        sql.append("WHERE spd.supPayId = ? ");
        sql.append("ORDER BY spd.date DESC, spd.time DESC");
        
        pt = con.prepareStatement(sql.toString());
        pt.setInt(1, paymentId);
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getDouble("paid"));
            row.addElement(rs.getString("dateTime"));
            row.addElement(rs.getString("paymentMode"));
            String userName = rs.getString("userName");
            row.addElement(userName != null ? userName : "N/A");
            vec.addElement(row);
        }
        
        return vec;
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get last N purchase history for a product from a specific supplier
 * @param productName - name of the product
 * @param supplierId - ID of the supplier
 * @param limit - number of records to fetch
 * @return Vector of purchase details
 */
public Vector getProductPurchaseHistory(String productName, int supplierId, int limit) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector history = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT p.invdate, p.invno, pd.pack, pd.qtypack, pd.quantity, pd.free, pd.rate, pd.mrp, pd.disc, pd.tax "
					+"	FROM prod_purchase p JOIN prod_purchase_details pd ON p.id = pd.prid "
					+"	JOIN prod_product pp ON pd.prods_id = pp.id WHERE pp.name = ? AND p.deal_id = ? AND p.is_cancelled=0 AND is_po=0 ORDER BY p.invdate DESC, p.id DESC LIMIT ?;";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, productName);
        pt.setInt(2, supplierId);
        pt.setInt(3, limit);
        
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString("invdate"));      // 0
            row.add(rs.getString("invno"));        // 1
            row.add(rs.getInt("pack"));            // 2
            row.add(rs.getDouble("qtypack"));             // 3
            row.add(rs.getDouble("quantity"));          // 4
            row.add(rs.getInt("free"));            // 5
            row.add(rs.getDouble("rate"));         // 6
            row.add(rs.getDouble("mrp"));          // 7
            row.add(rs.getDouble("disc"));         // 8
            row.add(rs.getDouble("tax"));          // 9
            history.add(row);
        }
        
        return history;
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// Overloaded method to get purchase history without supplier filter
public Vector getProductPurchaseHistory(String productName, int limit) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector history = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT s.name AS supplier_name, "
                   + "DATE_FORMAT(p.ent_date, '%d-%m-%Y') AS formatted_date, "
                   + "DATE_FORMAT(p.ent_time, '%H:%i') AS formatted_time, "
                   + "p.invno, pd.pack, pd.qtypack, pd.quantity, pd.free, pd.rate, pd.mrp, pd.disc, pd.tax, "
                   + "COALESCE(u.name,'') AS unit_name "
                   + "FROM prod_purchase p "
                   + "JOIN prod_purchase_details pd ON p.id = pd.prid "
                   + "JOIN prod_product pp ON pd.prods_id = pp.id "
                   + "JOIN prod_supplier s ON p.deal_id = s.id "
                   + "LEFT JOIN prod_units u ON u.id = pp.unit_id "
                   + "WHERE pp.name = ? AND p.is_cancelled = 0 AND p.is_po = 0 "
                   + "ORDER BY p.invdate DESC, p.ent_time DESC, p.id DESC LIMIT ?";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, productName);
        pt.setInt(2, limit);
        
        rs = pt.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString("supplier_name"));                                      // 0
            row.add(rs.getString("formatted_date") + " " + rs.getString("formatted_time")); // 1
            row.add(rs.getString("invno"));                                               // 2
            row.add(rs.getInt("pack"));                                                   // 3
            row.add(rs.getDouble("qtypack"));                                                // 4
            row.add(rs.getDouble("quantity"));                                               // 5
            row.add(rs.getInt("free"));                                                   // 6
            row.add(rs.getDouble("rate"));                                                // 7
            row.add(rs.getDouble("mrp"));                                                 // 8
            row.add(rs.getDouble("disc"));                                                // 9
            row.add(rs.getDouble("tax"));                                                 // 10
            row.add(rs.getString("unit_name"));                                               // 11
            history.add(row);
        }
        
        return history;
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// Salesman Management Methods
public void addSalesman(String name) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("INSERT INTO sales_man(name, is_active) VALUES (?, 1)");
        pt.setString(1, name);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getSalesmanList() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector list = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id, name, is_active FROM sales_man ORDER BY name");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            row.addElement(rs.getInt("is_active"));
            list.addElement(row);
        }
        return list;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getActiveSalesmanList() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector list = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id, name FROM sales_man WHERE is_active = 1 ORDER BY name");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            list.addElement(row);
        }
        return list;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void updateSalesman(int id, String name) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("UPDATE sales_man SET name = ? WHERE id = ?");
        pt.setString(1, name);
        pt.setInt(2, id);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void updateSalesmanStatus(int id, int isActive) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("UPDATE sales_man SET is_active = ? WHERE id = ?");
        pt.setInt(1, isActive);
        pt.setInt(2, id);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// Area Management Methods
public void addArea(String name) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("INSERT INTO sales_area(name, is_active) VALUES (?, 1)");
        pt.setString(1, name);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getAreaList() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector list = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id, name, is_active FROM sales_area ORDER BY name");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            row.addElement(rs.getInt("is_active"));
            list.addElement(row);
        }
        return list;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getActiveAreaList() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector list = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id, name FROM sales_area WHERE is_active = 1 ORDER BY name");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            list.addElement(row);
        }
        return list;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void updateArea(int id, String name) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("UPDATE sales_area SET name = ? WHERE id = ?");
        pt.setString(1, name);
        pt.setInt(2, id);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void updateAreaStatus(int id, int isActive) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("UPDATE sales_area SET is_active = ? WHERE id = ?");
        pt.setInt(1, isActive);
        pt.setInt(2, id);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getCustomerById(int id) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector customer = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT name, phone_number, address, gstin, is_gst, salesman, area, credit_limit FROM customers WHERE id = ?");
        pt.setInt(1, id);
        rs = pt.executeQuery();
        if (rs.next()) {
            customer.addElement(rs.getString("name"));
            customer.addElement(rs.getString("phone_number"));
            customer.addElement(rs.getString("address"));
            customer.addElement(rs.getString("gstin"));
            customer.addElement(rs.getInt("is_gst"));
            customer.addElement(rs.getInt("salesman"));
            customer.addElement(rs.getInt("area"));
            customer.addElement(rs.getDouble("credit_limit"));
        }
        return customer;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

// Units Management Methods
public void addUnit(String name, String convertionUnit, BigDecimal convertionCalculation) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("INSERT INTO prod_units(name, convertion_unit, convertion_calculation, is_active) VALUES (?, ?, ?, 1)");
        pt.setString(1, name);
        if (convertionUnit != null && convertionUnit.trim().length() > 0) {
            pt.setString(2, convertionUnit.trim());
        } else {
            pt.setNull(2, java.sql.Types.VARCHAR);
        }

        if (convertionCalculation != null) {
            pt.setBigDecimal(3, convertionCalculation);
        } else {
            pt.setNull(3, java.sql.Types.DECIMAL);
        }
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getUnitsList() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector list = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id, name, convertion_unit, convertion_calculation, is_active FROM prod_units ORDER BY name");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            row.addElement(rs.getString("convertion_unit"));
            row.addElement(rs.getBigDecimal("convertion_calculation"));
            row.addElement(rs.getInt("is_active"));
            list.addElement(row);
        }
        return list;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getActiveUnitsList() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector list = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id, name FROM prod_units WHERE is_active = 1 ORDER BY name");
        rs = pt.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            list.addElement(row);
        }
        return list;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public Vector getUnitById(int id) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    Vector row = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT id, name, convertion_unit, convertion_calculation, is_active FROM prod_units WHERE id = ?");
        pt.setInt(1, id);
        rs = pt.executeQuery();
        if (rs.next()) {
            row.addElement(rs.getInt("id"));
            row.addElement(rs.getString("name"));
            row.addElement(rs.getString("convertion_unit"));
            row.addElement(rs.getBigDecimal("convertion_calculation"));
            row.addElement(rs.getInt("is_active"));
        }
        return row;
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void updateUnit(int id, String name, String convertionUnit, BigDecimal convertionCalculation) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("UPDATE prod_units SET name = ?, convertion_unit = ?, convertion_calculation = ? WHERE id = ?");
        pt.setString(1, name);

        if (convertionUnit != null && convertionUnit.trim().length() > 0) {
            pt.setString(2, convertionUnit.trim());
        } else {
            pt.setNull(2, java.sql.Types.VARCHAR);
        }

        if (convertionCalculation != null) {
            pt.setBigDecimal(3, convertionCalculation);
        } else {
            pt.setNull(3, java.sql.Types.DECIMAL);
        }

        pt.setInt(4, id);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

public void updateUnitStatus(int id, int isActive) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        pt = con.prepareStatement("UPDATE prod_units SET is_active = ? WHERE id = ?");
        pt.setInt(1, isActive);
        pt.setInt(2, id);
        pt.executeUpdate();
        con.commit();
    } catch (Exception e) {
        if (con != null) con.rollback();
        throw e;
    } finally {
        if (pt != null) try { pt.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get available cheques for a supplier
 * @param supplierId - The supplier ID
 * @return Vector - List of cheque details (Vector of Vectors)
 */
public Vector getAvailableCheques(int supplierId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector result = new Vector();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String sql = "SELECT cheque_number, entry_date, bank_name "
					+"	FROM `prod_supplier_cheque_stock` "
					+"	WHERE supplier_id = ? AND STATUS = 'AVAILABLE' "
					+"	ORDER BY entry_date DESC";
        
        ps = con.prepareStatement(sql);
        ps.setInt(1, supplierId);
        rs = ps.executeQuery();
        
        while (rs.next()) {
            Vector row = new Vector();
            row.add(rs.getString("cheque_number"));
            row.add(rs.getString("entry_date"));
            row.add(rs.getString("bank_name"));
            result.add(row);
        }
        
        return result;
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Validate if supplier has available cheques
 * @param supplierId - The supplier ID
 * @return String - "1" if has cheques, "0" if no cheques
 */
public String validateSupplierCheques(int supplierId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        // Check if supplier has available cheques
        String chequeSql = "SELECT COUNT(*) as cnt FROM prod_supplier_cheque_stock " +
                          "WHERE supplier_id = ? AND status = 'AVAILABLE'";
        ps = con.prepareStatement(chequeSql);
        ps.setInt(1, supplierId);
        rs = ps.executeQuery();
        
        boolean hasCheques = false;
        if (rs.next() && rs.getInt("cnt") > 0) {
            hasCheques = true;
        }
        
        return hasCheques ? "1" : "0";
        
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception e) {}
        if (ps != null) try { ps.close(); } catch (Exception e) {}
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

///////////////////////-----------------------------
// GSTR-1 Report Methods
///////////////////////-----------------------------

/**
 * Get B2B Sales data for GSTR-1 Report
 * B2B = Registered customers with valid GSTIN (15 characters)
 * Returns invoice-wise data grouped by GST rate
 * Columns: GSTIN, Customer Name, Invoice No, Date, Place of Supply, Rate, Taxable Value, CGST, SGST, IGST, Invoice Value
 */
public Vector getGSTR1_B2B(String fromDate, String toDate, String myGSTIN) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        String sql = "SELECT " +
            "c.gstin AS customer_gstin, " +
            "c.name AS customer_name, " +
            "b.bill_display AS invoice_no, " +
            "b.date AS invoice_date, " +
            "CASE " +
            "  WHEN SUBSTRING(c.gstin, 1, 2) = SUBSTRING(?, 1, 2) THEN 'Tamil Nadu (Local)' " +
            "  ELSE CONCAT('Inter-State (', SUBSTRING(c.gstin, 1, 2), ')') " +
            "END AS place_of_supply, " +
            "bd.gst AS gst_rate, " +
            "SUM(bd.total / (1 + bd.gst/100)) AS taxable_value, " +
            "CASE " +
            "  WHEN SUBSTRING(c.gstin, 1, 2) = SUBSTRING(?, 1, 2) THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 200) " +
            "  ELSE 0 " +
            "END AS cgst, " +
            "CASE " +
            "  WHEN SUBSTRING(c.gstin, 1, 2) = SUBSTRING(?, 1, 2) THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 200) " +
            "  ELSE 0 " +
            "END AS sgst, " +
            "CASE " +
            "  WHEN SUBSTRING(c.gstin, 1, 2) != SUBSTRING(?, 1, 2) THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 100) " +
            "  ELSE 0 " +
            "END AS igst, " +
            "SUM(bd.total) AS invoice_value " +
            "FROM prod_bill b " +
            "JOIN prod_bill_details bd ON b.id = bd.bill_id " +
            "LEFT JOIN customers c ON b.customerId = c.id " +
            "WHERE b.date BETWEEN ? AND ? " +
            "AND b.is_cancelled = 0 " +
            "AND bd.is_cancelled = 0 " +
            "AND c.gstin IS NOT NULL " +
            "AND c.gstin != '' " +
            "AND LENGTH(c.gstin) = 15 " +
            "GROUP BY b.id, bd.gst, c.gstin, c.name, b.bill_display, b.date " +
            "ORDER BY b.date, b.bill_display, bd.gst";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, myGSTIN);
        pt.setString(2, myGSTIN);
        pt.setString(3, myGSTIN);
        pt.setString(4, myGSTIN);
        pt.setString(5, fromDate);
        pt.setString(6, toDate);
        
        rs = pt.executeQuery();
        
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString("customer_gstin"));
            vec1.addElement(rs.getString("customer_name"));
            vec1.addElement(rs.getString("invoice_no"));
            vec1.addElement(rs.getString("invoice_date"));
            vec1.addElement(rs.getString("place_of_supply"));
            vec1.addElement(String.format("%.0f", rs.getDouble("gst_rate")));
            vec1.addElement(String.format("%.2f", rs.getDouble("taxable_value")));
            vec1.addElement(String.format("%.2f", rs.getDouble("cgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("sgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("igst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("invoice_value")));
            vec.addElement(vec1);
        }
        
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get B2CL Sales data for GSTR-1 Report
 * B2CL = Unregistered customers with invoice value > 2.5 Lakhs
 * Returns invoice-wise data
 * Columns: Invoice No, Date, Invoice Value, Place of Supply, Rate, Taxable Value, CGST, SGST, IGST
 */
public Vector getGSTR1_B2CL(String fromDate, String toDate, String myGSTIN) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        String sql = "SELECT " +
            "b.bill_display AS invoice_no, " +
            "b.date AS invoice_date, " +
            "b.cusName AS customer_name, " +
            "bd.gst AS gst_rate, " +
            "SUM(bd.total / (1 + bd.gst/100)) AS taxable_value, " +
            "CASE " +
            "  WHEN MAX(c.local) = 1 THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 200) " +
            "  ELSE 0 " +
            "END AS cgst, " +
            "CASE " +
            "  WHEN MAX(c.local) = 1 THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 200) " +
            "  ELSE 0 " +
            "END AS sgst, " +
            "CASE " +
            "  WHEN MAX(c.local) = 0 OR MAX(c.local) IS NULL THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 100) " +
            "  ELSE 0 " +
            "END AS igst, " +
            "SUM(bd.total) AS invoice_value, " +
            "CASE " +
            "  WHEN MAX(c.local) = 1 THEN 'Tamil Nadu' " +
            "  ELSE 'Inter-State' " +
            "END AS place_of_supply " +
            "FROM prod_bill b " +
            "JOIN prod_bill_details bd ON b.id = bd.bill_id " +
            "LEFT JOIN customers c ON b.customerId = c.id " +
            "WHERE b.date BETWEEN ? AND ? " +
            "AND b.is_cancelled = 0 " +
            "AND bd.is_cancelled = 0 " +
            "AND (c.is_gst = 0 OR c.is_gst IS NULL OR (c.gstin IS NULL OR c.gstin = '' OR LENGTH(c.gstin) != 15)) " +
            "GROUP BY b.id, bd.gst, b.bill_display, b.date, b.cusName " +
            "HAVING invoice_value > 250000 " +
            "ORDER BY b.date, b.bill_display";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        
        rs = pt.executeQuery();
        
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString("invoice_no"));
            vec1.addElement(rs.getString("invoice_date"));
            vec1.addElement(rs.getString("customer_name"));
            vec1.addElement(rs.getString("place_of_supply"));
            vec1.addElement(String.format("%.0f", rs.getDouble("gst_rate")));
            vec1.addElement(String.format("%.2f", rs.getDouble("taxable_value")));
            vec1.addElement(String.format("%.2f", rs.getDouble("cgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("sgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("igst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("invoice_value")));
            vec.addElement(vec1);
        }
        
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get B2CS Sales data for GSTR-1 Report
 * B2CS = Unregistered customers with invoice value <= 2.5 Lakhs (Consolidated)
 * Returns data grouped by Place of Supply and GST Rate
 * Columns: Place of Supply, Rate, Taxable Value, CGST, SGST, IGST
 */
public Vector getGSTR1_B2CS(String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        String sql = "SELECT " +
            "CASE " +
            "  WHEN MAX(COALESCE(c.local, 0)) = 1 THEN 'Tamil Nadu' " +
            "  ELSE 'Other States' " +
            "END AS place_of_supply, " +
            "bd.gst AS gst_rate, " +
            "SUM(bd.total / (1 + bd.gst/100)) AS taxable_value, " +
            "CASE " +
            "  WHEN MAX(COALESCE(c.local, 0)) = 1 THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 200) " +
            "  ELSE 0 " +
            "END AS cgst, " +
            "CASE " +
            "  WHEN MAX(COALESCE(c.local, 0)) = 1 THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 200) " +
            "  ELSE 0 " +
            "END AS sgst, " +
            "CASE " +
            "  WHEN MAX(COALESCE(c.local, 0)) = 0 THEN SUM((bd.total / (1 + bd.gst/100)) * bd.gst / 100) " +
            "  ELSE 0 " +
            "END AS igst " +
            "FROM prod_bill b " +
            "JOIN prod_bill_details bd ON b.id = bd.bill_id " +
            "LEFT JOIN customers c ON b.customerId = c.id " +
            "WHERE b.date BETWEEN ? AND ? " +
            "AND b.is_cancelled = 0 " +
            "AND bd.is_cancelled = 0 " +
            "AND (c.is_gst = 0 OR c.is_gst IS NULL OR (c.gstin IS NULL OR c.gstin = '' OR LENGTH(c.gstin) != 15)) " +
            "AND b.id IN ( " +
            "  SELECT b2.id FROM prod_bill b2 " +
            "  JOIN prod_bill_details bd2 ON b2.id = bd2.bill_id " +
            "  WHERE b2.date BETWEEN ? AND ? " +
            "  AND b2.is_cancelled = 0 " +
            "  AND bd2.is_cancelled = 0 " +
            "  GROUP BY b2.id " +
            "  HAVING SUM(bd2.total) <= 250000 " +
            ") " +
            "GROUP BY COALESCE(c.local, 0), bd.gst " +
            "ORDER BY place_of_supply, bd.gst";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        pt.setString(3, fromDate);
        pt.setString(4, toDate);
        
        rs = pt.executeQuery();
        
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString("place_of_supply"));
            vec1.addElement(String.format("%.0f", rs.getDouble("gst_rate")));
            vec1.addElement(String.format("%.2f", rs.getDouble("taxable_value")));
            vec1.addElement(String.format("%.2f", rs.getDouble("cgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("sgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("igst")));
            vec.addElement(vec1);
        }
        
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get Nil Rated / Exempt Sales data for GSTR-1 Report
 * Returns invoices with GST = 0
 * Columns: Invoice No, Date, Customer Name, Value
 */
public Vector getGSTR1_NilRated(String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        String sql = "SELECT " +
            "b.bill_display AS invoice_no, " +
            "b.date AS invoice_date, " +
            "b.cusName AS customer_name, " +
            "SUM(bd.total) AS invoice_value " +
            "FROM prod_bill b " +
            "JOIN prod_bill_details bd ON b.id = bd.bill_id " +
            "WHERE b.date BETWEEN ? AND ? " +
            "AND b.is_cancelled = 0 " +
            "AND bd.is_cancelled = 0 " +
            "AND bd.gst = 0 " +
            "GROUP BY b.id, b.bill_display, b.date, b.cusName " +
            "ORDER BY b.date, b.bill_display";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, fromDate);
        pt.setString(2, toDate);
        
        rs = pt.executeQuery();
        
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString("invoice_no"));
            vec1.addElement(rs.getString("invoice_date"));
            vec1.addElement(rs.getString("customer_name"));
            vec1.addElement(String.format("%.2f", rs.getDouble("invoice_value")));
            vec.addElement(vec1);
        }
        
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get HSN Summary data for GSTR-1 Report
 * Returns HSN-wise consolidated data across all invoices
 * Columns: HSN Code, Description, UQC, Total Qty, Taxable Value, CGST, SGST, IGST
 */
public Vector getGSTR1_HSN(String fromDate, String toDate, String myGSTIN) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        String sql = "SELECT " +
            "CASE " +
            "  WHEN p.hsn IS NULL OR p.hsn = '' THEN 'N/A' " +
            "  ELSE p.hsn " +
            "END AS hsn_code, " +
            "GROUP_CONCAT(DISTINCT p.name SEPARATOR ', ') AS description, " +
            "SUM(bd.qty) AS total_qty, " +
            "bd.gst AS gst_rate, " +
            "SUM(bd.total / (1 + bd.gst/100)) AS taxable_value, " +
            "SUM(CASE " +
            "  WHEN SUBSTRING(COALESCE(c.gstin, ''), 1, 2) = SUBSTRING(?, 1, 2) OR COALESCE(c.local, 0) = 1 " +
            "  THEN (bd.total / (1 + bd.gst/100)) * bd.gst / 200 " +
            "  ELSE 0 " +
            "END) AS cgst, " +
            "SUM(CASE " +
            "  WHEN SUBSTRING(COALESCE(c.gstin, ''), 1, 2) = SUBSTRING(?, 1, 2) OR COALESCE(c.local, 0) = 1 " +
            "  THEN (bd.total / (1 + bd.gst/100)) * bd.gst / 200 " +
            "  ELSE 0 " +
            "END) AS sgst, " +
            "SUM(CASE " +
            "  WHEN (SUBSTRING(COALESCE(c.gstin, ''), 1, 2) != SUBSTRING(?, 1, 2) AND LENGTH(c.gstin) = 15) OR COALESCE(c.local, 0) = 0 " +
            "  THEN (bd.total / (1 + bd.gst/100)) * bd.gst / 100 " +
            "  ELSE 0 " +
            "END) AS igst " +
            "FROM prod_bill b " +
            "JOIN prod_bill_details bd ON b.id = bd.bill_id " +
            "JOIN prod_product p ON bd.prod_id = p.id " +
            "LEFT JOIN customers c ON b.customerId = c.id " +
            "WHERE b.date BETWEEN ? AND ? " +
            "AND b.is_cancelled = 0 " +
            "AND bd.is_cancelled = 0 " +
            "GROUP BY CASE WHEN p.hsn IS NULL OR p.hsn = '' THEN 'N/A' ELSE p.hsn END, bd.gst " +
            "ORDER BY hsn_code, bd.gst";
        
        pt = con.prepareStatement(sql);
        pt.setString(1, myGSTIN);
        pt.setString(2, myGSTIN);
        pt.setString(3, myGSTIN);
        pt.setString(4, fromDate);
        pt.setString(5, toDate);
        
        rs = pt.executeQuery();
        
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getString("hsn_code"));
            vec1.addElement(rs.getString("description"));
            vec1.addElement(String.format("%.0f", rs.getDouble("total_qty")));
            vec1.addElement(String.format("%.0f", rs.getDouble("gst_rate")));
            vec1.addElement(String.format("%.2f", rs.getDouble("taxable_value")));
            vec1.addElement(String.format("%.2f", rs.getDouble("cgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("sgst")));
            vec1.addElement(String.format("%.2f", rs.getDouble("igst")));
            vec.addElement(vec1);
        }
        
        return vec;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}



///////////////////////-----------------------------
// GSTR-3B Methods
///////////////////////-----------------------------

/**
 * Get GSTIN and Trade Name
 */
public Map<String, String> getGSTINInfo() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    Map<String, String> info = new HashMap<>();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        pt = con.prepareStatement("SELECT gstin, shop_name FROM company_details LIMIT 1");
        rs = pt.executeQuery();
        
        if (rs.next()) {
            info.put("gstin", rs.getString("gstin"));
            info.put("shop_name", rs.getString("shop_name"));
        } else {
            info.put("gstin", "");
            info.put("shop_name", "");
        }
        
        return info;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get GSTR-3B Outward Supplies (Sales) - Table 3.1(a)
 * Returns: Map<GST Rate, Map<"taxable"|"cgst"|"sgst"|"igst", Amount>>
 */
public Map<Double, Map<String, Double>> getOutwardSupplies(String startDate, String endDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    Map<Double, Map<String, Double>> result = new TreeMap<>();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String query = "SELECT " +
            "bd.gst, " +
            "SUM(bd.total) as total_amount, " +
            "COALESCE(c.local, 1) as local " +
            "FROM prod_bill_details bd " +
            "INNER JOIN prod_bill b ON bd.bill_id = b.id " +
            "LEFT JOIN customers c ON b.customerId = c.id " +
            "WHERE b.is_cancelled = 0 " +
            "AND b.date >= ? " +
            "AND b.date <= ? " +
            "GROUP BY bd.gst, c.local";
        
        pt = con.prepareStatement(query);
        pt.setString(1, startDate);
        pt.setString(2, endDate);
        rs = pt.executeQuery();
        
        while (rs.next()) {
            double gstRate = rs.getDouble("gst");
            double totalAmount = rs.getDouble("total_amount");
            int isLocal = rs.getInt("local");
            
            if (gstRate > 0) {
                // Calculate taxable value (reverse calculation from total including GST)
                double taxableValue = totalAmount * 100 / (100 + gstRate);
                double taxAmount = totalAmount - taxableValue;
                
                // Get or create map for this GST rate
                Map<String, Double> taxMap = result.getOrDefault(gstRate, new HashMap<>());
                
                // Add to existing values
                taxMap.put("taxable", taxMap.getOrDefault("taxable", 0.0) + taxableValue);
                
                if (isLocal == 1) {
                    // Local: Split into CGST and SGST
                    double cgst = taxAmount / 2;
                    double sgst = taxAmount / 2;
                    taxMap.put("cgst", taxMap.getOrDefault("cgst", 0.0) + cgst);
                    taxMap.put("sgst", taxMap.getOrDefault("sgst", 0.0) + sgst);
                    taxMap.put("igst", taxMap.getOrDefault("igst", 0.0));
                } else {
                    // Inter-state: IGST
                    taxMap.put("igst", taxMap.getOrDefault("igst", 0.0) + taxAmount);
                    taxMap.put("cgst", taxMap.getOrDefault("cgst", 0.0));
                    taxMap.put("sgst", taxMap.getOrDefault("sgst", 0.0));
                }
                
                result.put(gstRate, taxMap);
            }
        }
        
        return result;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get Nil Rated Supplies - Table 3.1(c)
 */
public double getNilRatedSupplies(String startDate, String endDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String query = "SELECT " +
            "SUM(bd.total) as total_amount " +
            "FROM prod_bill_details bd " +
            "INNER JOIN prod_bill b ON bd.bill_id = b.id " +
            "WHERE b.is_cancelled = 0 " +
            "AND b.date >= ? " +
            "AND b.date <= ? " +
            "AND bd.gst = 0";
        
        pt = con.prepareStatement(query);
        pt.setString(1, startDate);
        pt.setString(2, endDate);
        rs = pt.executeQuery();
        
        if (rs.next()) {
            return rs.getDouble("total_amount");
        }
        
        return 0.0;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Get Input Tax Credit (ITC) from Purchases - Table 4
 * Returns: Map<"cgst"|"sgst"|"igst", Amount>
 */
public Map<String, Double> getInputTaxCredit(String startDate, String endDate) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    
    Map<String, Double> itc = new HashMap<>();
    
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        
        String query = "SELECT " +
            "SUM(pd.cgst_amt) as total_cgst, " +
            "SUM(pd.sgst_amt) as total_sgst, " +
            "SUM(pd.igst_amt) as total_igst " +
            "FROM prod_purchase_details pd " +
            "INNER JOIN prod_purchase p ON pd.prid = p.id " +
            "INNER JOIN prod_supplier ps ON p.deal_id = ps.id " +
            "WHERE p.is_cancelled = 0 " +
            "AND ps.is_gst = 1 " +
            "AND p.ent_date >= ? " +
            "AND p.ent_date <= ?";
        
        pt = con.prepareStatement(query);
        pt.setString(1, startDate);
        pt.setString(2, endDate);
        rs = pt.executeQuery();
        
        if (rs.next()) {
            itc.put("cgst", rs.getDouble("total_cgst"));
            itc.put("sgst", rs.getDouble("total_sgst"));
            itc.put("igst", rs.getDouble("total_igst"));
        } else {
            itc.put("cgst", 0.0);
            itc.put("sgst", 0.0);
            itc.put("igst", 0.0);
        }
        
        return itc;
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { ; }
        if (pt != null) try { pt.close(); } catch (SQLException e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) {}
    }
}

/**
 * Calculate Tax Payable
 * Returns: Map<"cgst"|"sgst"|"igst"|"total", Amount>
 */
public Map<String, Double> calculateTaxPayable(
    Map<Double, Map<String, Double>> outwardSupplies,
    Map<String, Double> itc
) {
    Map<String, Double> taxPayable = new HashMap<>();
    
    // Calculate total output tax
    double totalOutputCGST = 0.0;
    double totalOutputSGST = 0.0;
    double totalOutputIGST = 0.0;
    
    for (Map<String, Double> taxMap : outwardSupplies.values()) {
        totalOutputCGST += taxMap.getOrDefault("cgst", 0.0);
        totalOutputSGST += taxMap.getOrDefault("sgst", 0.0);
        totalOutputIGST += taxMap.getOrDefault("igst", 0.0);
    }
    
    // Calculate tax payable (output - input)
    double cgstPayable = totalOutputCGST - itc.getOrDefault("cgst", 0.0);
    double sgstPayable = totalOutputSGST - itc.getOrDefault("sgst", 0.0);
    double igstPayable = totalOutputIGST - itc.getOrDefault("igst", 0.0);
    
    // Ensure no negative values
    if (cgstPayable < 0) cgstPayable = 0;
    if (sgstPayable < 0) sgstPayable = 0;
    if (igstPayable < 0) igstPayable = 0;
    
    taxPayable.put("cgst", cgstPayable);
    taxPayable.put("sgst", sgstPayable);
    taxPayable.put("igst", igstPayable);
    taxPayable.put("total", cgstPayable + sgstPayable + igstPayable);
    
    return taxPayable;
}

/**
 * Get summary totals from outward supplies
 */
public Map<String, Double> getOutwardSuppliesTotals(Map<Double, Map<String, Double>> outwardSupplies) {
    Map<String, Double> totals = new HashMap<>();
    
    double totalTaxable = 0.0;
    double totalCGST = 0.0;
    double totalSGST = 0.0;
    double totalIGST = 0.0;
    
    for (Map<String, Double> taxMap : outwardSupplies.values()) {
        totalTaxable += taxMap.getOrDefault("taxable", 0.0);
        totalCGST += taxMap.getOrDefault("cgst", 0.0);
        totalSGST += taxMap.getOrDefault("sgst", 0.0);
        totalIGST += taxMap.getOrDefault("igst", 0.0);
    }
    
    totals.put("taxable", totalTaxable);
    totals.put("cgst", totalCGST);
    totals.put("sgst", totalSGST);
    totals.put("igst", totalIGST);
    
    return totals;
}

    // Check if user has special permission for specific content
    public boolean checkUserSpecialPermission(int userId, int contentId) throws Exception {
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            
            String sql = "SELECT COUNT(*) as count FROM user_special_permission " +
                         "WHERE user_id = ? AND content_id = ?";
            
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setInt(2, contentId);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }
            
            return false;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (ps != null) {
                try { ps.close(); } catch (SQLException e) { ; }
                ps = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }

///////////////////////-----------------------------
    /**
     * Get products for bulk MRP and GST update with filtering
     * @param filterName - Filter by product name (partial match), empty string for no filter
     * @param filterCategory - Filter by category ID, empty string for no filter
     * @return Vector - Vector containing product details (id, name, code, gst, category_name, mrp, batch_id)
     */
    public Vector getProductsForBulkUpdate(String filterName, String filterCategory) throws Exception {
        Connection con = null;
        PreparedStatement pt = null;
        ResultSet rs = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            Vector products = new Vector();
            
            // Build query based on filters
            StringBuilder query = new StringBuilder();
            query.append("SELECT p.id, p.name, p.code, p.gst, c.name AS category_name, ");
            query.append("b.mrp, b.id AS batch_id ");
            query.append("FROM prod_product p ");
            query.append("JOIN prod_category c ON p.category_id = c.id ");
            query.append("JOIN prod_batch b ON b.product_id = p.id ");
            query.append("WHERE p.is_active = 1 ");
            
            // Add filters
            if (filterName != null && !filterName.trim().isEmpty()) {
                query.append("AND p.name LIKE ? ");
            }
            if (filterCategory != null && !filterCategory.trim().isEmpty()) {
                query.append("AND p.category_id = ? ");
            }
            
            query.append("ORDER BY p.name");
            
            pt = con.prepareStatement(query.toString());
            
            int paramIndex = 1;
            if (filterName != null && !filterName.trim().isEmpty()) {
                pt.setString(paramIndex++, "%" + filterName.trim() + "%");
            }
            if (filterCategory != null && !filterCategory.trim().isEmpty()) {
                pt.setInt(paramIndex++, Integer.parseInt(filterCategory));
            }
            
            rs = pt.executeQuery();
            
            while (rs.next()) {
                Vector product = new Vector();
                product.addElement(rs.getInt("id"));              // 0: product_id
                product.addElement(rs.getString("name"));         // 1: product_name
                product.addElement(rs.getString("code"));         // 2: product_code
                product.addElement(rs.getInt("gst"));             // 3: gst
                product.addElement(rs.getString("category_name")); // 4: category_name
                product.addElement(rs.getDouble("mrp"));          // 5: mrp
                product.addElement(rs.getInt("batch_id"));        // 6: batch_id
                products.addElement(product);
            }
            
            return products;
            
        } finally {
            if (rs != null) {
                try { rs.close(); } catch (SQLException e) { ; }
                rs = null;
            }
            if (pt != null) {
                try { pt.close(); } catch (SQLException e) { ; }
                pt = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }

    /**
     * Update MRP and GST for a product
     * @param productId - The product ID
     * @param batchId - The batch ID
     * @param mrp - New MRP value
     * @param gst - New GST percentage
     * @return boolean - true if update successful, false otherwise
     */
    public boolean updateProductMrpAndGst(int productId, int batchId, double mrp, int gst) throws Exception {
        Connection con = null;
        PreparedStatement pt1 = null;
        PreparedStatement pt2 = null;
        
        try {
            con = util.DBConnectionManager.getConnectionFromPool();
            con.setAutoCommit(false);
            
            // Update MRP in prod_batch
            pt1 = con.prepareStatement("UPDATE prod_batch SET mrp = ? WHERE id = ?");
            pt1.setDouble(1, mrp);
            pt1.setInt(2, batchId);
            int rows1 = pt1.executeUpdate();
            
            // Update GST in prod_product
            pt2 = con.prepareStatement("UPDATE prod_product SET gst = ? WHERE id = ?");
            pt2.setInt(1, gst);
            pt2.setInt(2, productId);
            int rows2 = pt2.executeUpdate();
            
            if (rows1 > 0 && rows2 > 0) {
                con.commit();
                return true;
            } else {
                con.rollback();
                return false;
            }
            
        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
                } catch (Exception rollbackEx) {
                    rollbackEx.printStackTrace();
                }
            }
            throw e;
        } finally {
            if (pt1 != null) {
                try { pt1.close(); } catch (SQLException e) { ; }
                pt1 = null;
            }
            if (pt2 != null) {
                try { pt2.close(); } catch (SQLException e) { ; }
                pt2 = null;
            }
            if (con != null) {
                try { con.close(); } catch (SQLException e) { ; }
                con = null;
            }
        }
    }

///////////////////////-------- ATTENDER MANAGEMENT ---------------------
/**
 * Get all attenders
 */
public Vector getAllAttenders() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        pt = con.prepareStatement("SELECT id, name, code, is_active FROM attender ORDER BY name");
        rs = pt.executeQuery();
        
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getInt("id"));
            vec1.addElement(rs.getString("name"));
            vec1.addElement(rs.getString("code"));
            vec1.addElement(rs.getInt("is_active"));
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

/**
 * Get active attenders only
 */
public Vector getActiveAttenders() throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        Vector vec = new Vector();
        
        pt = con.prepareStatement("SELECT id, name, code FROM attender WHERE is_active = 1 ORDER BY name");
        rs = pt.executeQuery();
        
        while(rs.next()) {
            Vector vec1 = new Vector();
            vec1.addElement(rs.getInt("id"));
            vec1.addElement(rs.getString("name"));
            vec1.addElement(rs.getString("code"));
            vec.addElement(vec1);
        }
        return vec;
    } finally {
        if (rs != null) {
            try { rs.close(); } catch (SQLException e) { ; }
            rs = null;
        }
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

/**
 * Add new attender
 */
public boolean addAttender(String name, String code) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        
        pt = con.prepareStatement("INSERT INTO attender (name, code, is_active) VALUES (?, ?, 1)");
        pt.setString(1, name);
        pt.setString(2, code);
        
        int result = pt.executeUpdate();
        con.commit();
        return result > 0;
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ex) { ; }
        }
        throw e;
    } finally {
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

/**
 * Update attender
 */
public boolean updateAttender(int id, String name, String code) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        
        pt = con.prepareStatement("UPDATE attender SET name = ?, code = ? WHERE id = ?");
        pt.setString(1, name);
        pt.setString(2, code);
        pt.setInt(3, id);
        
        int result = pt.executeUpdate();
        con.commit();
        return result > 0;
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ex) { ; }
        }
        throw e;
    } finally {
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

/**
 * Block attender
 */
public boolean blockAttender(int id) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        
        pt = con.prepareStatement("UPDATE attender SET is_active = 0 WHERE id = ?");
        pt.setInt(1, id);
        
        int result = pt.executeUpdate();
        con.commit();
        return result > 0;
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ex) { ; }
        }
        throw e;
    } finally {
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

/**
 * Unblock attender
 */
public boolean unblockAttender(int id) throws Exception {
    Connection con = null;
    PreparedStatement pt = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);
        
        pt = con.prepareStatement("UPDATE attender SET is_active = 1 WHERE id = ?");
        pt.setInt(1, id);
        
        int result = pt.executeUpdate();
        con.commit();
        return result > 0;
    } catch (Exception e) {
        if (con != null) {
            try { con.rollback(); } catch (SQLException ex) { ; }
        }
        throw e;
    } finally {
        if (pt != null) {
            try { pt.close(); } catch (SQLException e) { ; }
            pt = null;
        }
        if (con != null) {
            try { con.close(); } catch (Exception e) {}
            con = null;
        }
    }
}

///////////////////////-----------------------------

// ─────────────────────────────────────────────────────────────────────────────
//  Purchase Edit / Cancel / Return methods
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Returns purchase details including is_cancelled status (for edit/cancel UI).
 */
public Vector getPurchaseDetailsForEdit(int purchaseId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT pd.id, p.name AS product_name, pd.prods_id, " +
                     "pd.pack, pd.qtypack, pd.quantity, pd.free, " +
                     "pd.rate, pd.mrp, pd.totalamt, pd.tax, " +
                     "pd.cgst_amt, pd.sgst_amt, pd.netamt, " +
                     "IFNULL(pd.is_cancelled, 0) AS is_cancelled " +
                     "FROM prod_purchase_details pd " +
                     "JOIN prod_product p ON pd.prods_id = p.id " +
                     "WHERE pd.prid = ?";
        ps = con.prepareStatement(sql);
        ps.setInt(1, purchaseId);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt(1));      // 0 id
            row.addElement(rs.getString(2));   // 1 product_name
            row.addElement(rs.getInt(3));      // 2 prods_id
            row.addElement(rs.getDouble(4));   // 3 pack
            row.addElement(rs.getDouble(5));   // 4 qtypack
            row.addElement(rs.getDouble(6));   // 5 quantity
            row.addElement(rs.getDouble(7));   // 6 free
            row.addElement(rs.getDouble(8));   // 7 rate
            row.addElement(rs.getDouble(9));   // 8 mrp
            row.addElement(rs.getDouble(10));  // 9 totalamt
            row.addElement(rs.getDouble(11));  // 10 tax
            row.addElement(rs.getDouble(12));  // 11 cgst_amt
            row.addElement(rs.getDouble(13));  // 12 sgst_amt
            row.addElement(rs.getDouble(14));  // 13 netamt
            row.addElement(rs.getInt(15));     // 14 is_cancelled
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Edit price (rate and/or mrp) of a purchase detail line.
 * - Updates prod_purchase_details rate, mrp, totalamt, netamt
 * - Updates prod_batch cost/mrp for the product
 * - Re-calculates prod_purchase.total / .net
 * - Logs to prod_purchase_edit_log
 */
public String editPurchaseItemPrice(int detailId, int purchaseId, double newRate, double newMrp, String reason, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // Fetch current detail row
        ps = con.prepareStatement(
            "SELECT prods_id, quantity, rate, mrp, tax FROM prod_purchase_details WHERE id = ? AND prid = ? AND IFNULL(is_cancelled,0) = 0");
        ps.setInt(1, detailId);
        ps.setInt(2, purchaseId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Item not found or already cancelled.");
        }
        int productId  = rs.getInt(1);
        double qty     = rs.getDouble(2);
        double oldRate = rs.getDouble(3);
        double oldMrp  = rs.getDouble(4);
        double tax     = rs.getDouble(5);
        rs.close(); ps.close();

        double newTotal   = new java.math.BigDecimal(qty * newRate).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newTaxAmt  = new java.math.BigDecimal(newTotal * tax / 100).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newNetAmt  = new java.math.BigDecimal(newTotal + newTaxAmt).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newCgstAmt = new java.math.BigDecimal(newTaxAmt / 2).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
        double newSgstAmt = newCgstAmt;

        // Update prod_purchase_details
        ps = con.prepareStatement(
            "UPDATE prod_purchase_details SET rate=?, mrp=?, totalamt=?, tax_amt=?, netamt=?, cgst_amt=?, sgst_amt=? WHERE id=?");
        ps.setDouble(1, newRate);
        ps.setDouble(2, newMrp);
        ps.setDouble(3, newTotal);
        ps.setDouble(4, newTaxAmt);
        ps.setDouble(5, newNetAmt);
        ps.setDouble(6, newCgstAmt);
        ps.setDouble(7, newSgstAmt);
        ps.setInt(8, detailId);
        ps.executeUpdate(); ps.close();

        // Update prod_batch cost / mrp for this product
        ps = con.prepareStatement(
            "UPDATE prod_batch SET cost=?, mrp=? WHERE product_id=?");
        ps.setDouble(1, newRate);
        ps.setDouble(2, newMrp);
        ps.setInt(3, productId);
        ps.executeUpdate(); ps.close();

        // Recalculate prod_purchase header totals from detail rows
        ps = con.prepareStatement(
            "UPDATE prod_purchase pp SET pp.total = (SELECT IFNULL(SUM(pd.totalamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0) = 0), " +
            "pp.net = (SELECT IFNULL(SUM(pd.netamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0) = 0) " +
            "WHERE pp.id = ?");
        ps.setInt(1, purchaseId);
        ps.executeUpdate(); ps.close();

        // Log the edit
        ps = con.prepareStatement(
            "INSERT INTO prod_purchase_edit_log(purchase_id, purchase_detail_id, product_id, edit_type, old_rate, new_rate, old_mrp, new_mrp, qty, reason, uid, date_time) " +
            "VALUES(?,?,?,'price_edit',?,?,?,?,?,?,?,NOW())");
        ps.setInt(1, purchaseId);
        ps.setInt(2, detailId);
        ps.setInt(3, productId);
        ps.setDouble(4, oldRate);
        ps.setDouble(5, newRate);
        ps.setDouble(6, oldMrp);
        ps.setDouble(7, newMrp);
        ps.setDouble(8, qty);
        ps.setString(9, reason != null ? reason : "");
        ps.setInt(10, uid);
        ps.executeUpdate(); ps.close();

        con.commit();
        return "Price updated successfully.";
    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Cancel a purchase detail line.
 * - Validates current stock >= qty to deduct.
 * - Reduces stock in prod_batch, prod_stock_totals.
 * - Inserts prod_lifecycle (stock_out, type=2).
 * - Marks prod_purchase_details.is_cancelled = 1.
 * - Recalculates prod_purchase header totals.
 * - Logs to prod_purchase_edit_log.
 */
public String cancelPurchaseItem(int detailId, int purchaseId, String reason, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // Fetch detail row
        ps = con.prepareStatement(
            "SELECT prods_id, quantity, free, rate, mrp FROM prod_purchase_details WHERE id = ? AND prid = ? AND IFNULL(is_cancelled,0) = 0");
        ps.setInt(1, detailId);
        ps.setInt(2, purchaseId);
        rs = ps.executeQuery();
        if (!rs.next()) {
            throw new Exception("Item not found or already cancelled.");
        }
        int productId = rs.getInt(1);
        double qty    = rs.getDouble(2);
        double free   = rs.getDouble(3);
        double rate   = rs.getDouble(4);
        double mrp    = rs.getDouble(5);
        rs.close(); ps.close();

        BigDecimal totalQty = new BigDecimal(qty + free).setScale(3, java.math.RoundingMode.HALF_UP);

        // Validate stock using prod_stock_totals (authoritative total across all batches)
        ps = con.prepareStatement(
            "SELECT IFNULL(stock, 0) FROM prod_stock_totals WHERE prods_id = ?");
        ps.setInt(1, productId);
        rs = ps.executeQuery();
        BigDecimal currentStock = BigDecimal.ZERO;
        if (rs.next()) currentStock = rs.getBigDecimal(1);
        rs.close(); ps.close();

        if (currentStock.compareTo(totalQty) < 0) {
            throw new Exception("Cannot cancel: current stock (" + currentStock.toPlainString()
                + ") is less than purchase qty (" + totalQty.toPlainString() + "). Reduce stock first.");
        }

        // Deduct stock from prod_batch (GREATEST prevents unsigned underflow across multiple batch rows)
        ps = con.prepareStatement(
            "UPDATE prod_batch SET stock = GREATEST(0, stock - ?) WHERE product_id = ?");
        ps.setBigDecimal(1, totalQty);
        ps.setInt(2, productId);
        ps.executeUpdate(); ps.close();

        // Deduct from prod_stock_totals
        ps = con.prepareStatement(
            "UPDATE prod_stock_totals SET stock = stock - ? WHERE prods_id = ?");
        ps.setBigDecimal(1, totalQty);
        ps.setInt(2, productId);
        ps.executeUpdate(); ps.close();

        // Get previous lifecycle row for stock_now
        ps = con.prepareStatement(
            "SELECT IFNULL(stock_now, 0) FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
        ps.setInt(1, productId);
        rs = ps.executeQuery();
        BigDecimal prevStockNow = BigDecimal.ZERO;
        if (rs.next()) prevStockNow = rs.getBigDecimal(1);
        rs.close(); ps.close();

        // Insert lifecycle entry (stock out)
        ps = con.prepareStatement(
            "INSERT INTO prod_lifecycle(batch_id, product_id, stock_out, stock_now, is_zero_stock_bill, notes, uid, stock_type, DATE, TIME) " +
            "VALUES(1, ?, ?, ?, 2, ?, ?, 2, NOW(), NOW())");
        ps.setInt(1, productId);
        ps.setBigDecimal(2, totalQty);
        ps.setBigDecimal(3, prevStockNow.subtract(totalQty));
        ps.setString(4, "Stock deducted — Purchase item cancelled (detail id: " + detailId + ")");
        ps.setInt(5, uid);
        ps.executeUpdate(); ps.close();

        // Mark item as cancelled
        ps = con.prepareStatement(
            "UPDATE prod_purchase_details SET is_cancelled = 1 WHERE id = ?");
        ps.setInt(1, detailId);
        ps.executeUpdate(); ps.close();

        // Recalculate prod_purchase header totals
        ps = con.prepareStatement(
            "UPDATE prod_purchase pp SET pp.total = (SELECT IFNULL(SUM(pd.totalamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0)=0), " +
            "pp.net = (SELECT IFNULL(SUM(pd.netamt),0) FROM prod_purchase_details pd WHERE pd.prid = pp.id AND IFNULL(pd.is_cancelled,0)=0) " +
            "WHERE pp.id = ?");
        ps.setInt(1, purchaseId);
        ps.executeUpdate(); ps.close();

        // Log
        ps = con.prepareStatement(
            "INSERT INTO prod_purchase_edit_log(purchase_id, purchase_detail_id, product_id, edit_type, old_rate, new_rate, old_mrp, new_mrp, qty, reason, uid, date_time) " +
            "VALUES(?,?,?,'cancel',?,0,?,0,?,?,?,NOW())");
        ps.setInt(1, purchaseId);
        ps.setInt(2, detailId);
        ps.setInt(3, productId);
        ps.setDouble(4, rate);
        ps.setDouble(5, mrp);
        ps.setDouble(6, qty);
        ps.setString(7, reason != null ? reason : "");
        ps.setInt(8, uid);
        ps.executeUpdate(); ps.close();

        con.commit();
        return "Item cancelled successfully. Stock reduced by " + totalQty.toPlainString() + ".";
    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * Save a purchase return.
 * itemsArr format: "detailId<#>qty<#>rate<@>detailId<#>qty<#>rate<@>..."
 * - Validates each qty <= original qty in purchase detail (minus already returned).
 * - Reduces stock in prod_batch, prod_stock_totals.
 * - Inserts prod_lifecycle (stock out).
 * - Inserts prod_purchase_return header and prod_purchase_return_details.
 */
public String savePurchaseReturn(int purchaseId, String itemsArr, String notes, int uid) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        con.setAutoCommit(false);

        // Get supplier from purchase header
        ps = con.prepareStatement("SELECT deal_id FROM prod_purchase WHERE id = ?");
        ps.setInt(1, purchaseId);
        rs = ps.executeQuery();
        int supplierId = rs.next() ? rs.getInt(1) : 0;
        rs.close(); ps.close();

        // Generate return number
        ps = con.prepareStatement("SELECT COUNT(id)+1 FROM prod_purchase_return");
        rs = ps.executeQuery();
        String returnNo = rs.next() ? "RTN" + rs.getString(1) : "RTN1";
        rs.close(); ps.close();

        // Insert return header (total updated below)
        ps = con.prepareStatement(
            "INSERT INTO prod_purchase_return(return_no, purchase_id, supplier_id, total, notes, uid, date_time) VALUES(?,?,?,0,?,?,NOW())");
        ps.setString(1, returnNo);
        ps.setInt(2, purchaseId);
        ps.setInt(3, supplierId);
        ps.setString(4, notes != null ? notes : "");
        ps.setInt(5, uid);
        ps.executeUpdate(); ps.close();

        ps = con.prepareStatement("SELECT MAX(id) FROM prod_purchase_return");
        rs = ps.executeQuery();
        int returnId = rs.next() ? rs.getInt(1) : 0;
        rs.close(); ps.close();

        double grandReturnTotal = 0;

        String[] rows = itemsArr.split("<@>");
        for (String row : rows) {
            if (row.trim().isEmpty()) continue;
            String[] fields = row.split("<#>");
            int detailId = Integer.parseInt(fields[0]);
            double returnQty = Double.parseDouble(fields[1]);
            double rate = Double.parseDouble(fields[2]);

            // Fetch original qty and product id
            ps = con.prepareStatement(
                "SELECT prods_id, quantity, free FROM prod_purchase_details WHERE id = ? AND prid = ? AND IFNULL(is_cancelled,0)=0");
            ps.setInt(1, detailId);
            ps.setInt(2, purchaseId);
            rs = ps.executeQuery();
            if (!rs.next()) {
                throw new Exception("Purchase detail id " + detailId + " not found or cancelled.");
            }
            int productId  = rs.getInt(1);
            double origQty = rs.getDouble(2) + rs.getDouble(3);
            rs.close(); ps.close();

            // Validate: total returned so far + this return <= origQty
            ps = con.prepareStatement(
                "SELECT IFNULL(SUM(prd.qty),0) FROM prod_purchase_return_details prd " +
                "JOIN prod_purchase_return pr ON prd.return_id = pr.id " +
                "WHERE prd.purchase_detail_id = ? AND pr.purchase_id = ?");
            ps.setInt(1, detailId);
            ps.setInt(2, purchaseId);
            rs = ps.executeQuery();
            double alreadyReturned = rs.next() ? rs.getDouble(1) : 0;
            rs.close(); ps.close();

            double available = origQty - alreadyReturned;
            if (returnQty <= 0 || returnQty > available) {
                throw new Exception("Return qty " + returnQty + " exceeds available qty " + available + " for product id " + productId + ".");
            }

            // Validate current stock using prod_stock_totals (authoritative total)
            ps = con.prepareStatement("SELECT IFNULL(stock,0) FROM prod_stock_totals WHERE prods_id = ?");
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            BigDecimal currentStock = rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            rs.close(); ps.close();

            BigDecimal rQty = new BigDecimal(returnQty).setScale(3, java.math.RoundingMode.HALF_UP);
            if (currentStock.compareTo(rQty) < 0) {
                throw new Exception("Insufficient stock (" + currentStock.toPlainString() + ") for product id " + productId + ".");
            }

            // Deduct stock (GREATEST prevents unsigned underflow across multiple batch rows)
            ps = con.prepareStatement("UPDATE prod_batch SET stock = GREATEST(0, stock - ?) WHERE product_id = ?");
            ps.setBigDecimal(1, rQty);
            ps.setInt(2, productId);
            ps.executeUpdate(); ps.close();

            ps = con.prepareStatement("UPDATE prod_stock_totals SET stock = stock - ? WHERE prods_id = ?");
            ps.setBigDecimal(1, rQty);
            ps.setInt(2, productId);
            ps.executeUpdate(); ps.close();

            // Lifecycle entry
            ps = con.prepareStatement(
                "SELECT IFNULL(stock_now,0) FROM prod_lifecycle WHERE product_id = ? ORDER BY id DESC LIMIT 1");
            ps.setInt(1, productId);
            rs = ps.executeQuery();
            BigDecimal prevNow = rs.next() ? rs.getBigDecimal(1) : BigDecimal.ZERO;
            rs.close(); ps.close();

            ps = con.prepareStatement(
                "INSERT INTO prod_lifecycle(batch_id, product_id, stock_out, stock_now, is_zero_stock_bill, notes, uid, stock_type, DATE, TIME) " +
                "VALUES(1,?,?,?,2,?,?,2,NOW(),NOW())");
            ps.setInt(1, productId);
            ps.setBigDecimal(2, rQty);
            ps.setBigDecimal(3, prevNow.subtract(rQty));
            ps.setString(4, "Stock deducted — Purchase return (" + returnNo + ")");
            ps.setInt(5, uid);
            ps.executeUpdate(); ps.close();

            double lineTotal = new java.math.BigDecimal(returnQty * rate).setScale(3, java.math.RoundingMode.HALF_UP).doubleValue();
            grandReturnTotal += lineTotal;

            // Insert return detail
            ps = con.prepareStatement(
                "INSERT INTO prod_purchase_return_details(return_id, purchase_detail_id, product_id, qty, rate, total, uid, date_time) " +
                "VALUES(?,?,?,?,?,?,?,NOW())");
            ps.setInt(1, returnId);
            ps.setInt(2, detailId);
            ps.setInt(3, productId);
            ps.setDouble(4, returnQty);
            ps.setDouble(5, rate);
            ps.setDouble(6, lineTotal);
            ps.setInt(7, uid);
            ps.executeUpdate(); ps.close();
        }

        // Update return header total
        ps = con.prepareStatement("UPDATE prod_purchase_return SET total = ? WHERE id = ?");
        ps.setDouble(1, grandReturnTotal);
        ps.setInt(2, returnId);
        ps.executeUpdate(); ps.close();

        con.commit();
        return returnNo;
    } catch (Exception e) {
        if (con != null) { try { con.rollback(); } catch (Exception ex) { ; } }
        throw e;
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
}

/**
 * List purchase returns with date range and optional supplier filter.
 * Returns: [id, return_no, purchase_id, prno, supplier_name, total, notes, date_time, entered_by]
 */
public Vector getPurchaseReturnList(String fromDate, String toDate, int supplierId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT pr.id, pr.return_no, pr.purchase_id, pp.prno, " +
                     "IFNULL(d.name,'—') AS supplier_name, pr.total, pr.notes, pr.date_time, " +
                     "IFNULL(u.user_name,'—') AS entered_by " +
                     "FROM prod_purchase_return pr " +
                     "JOIN prod_purchase pp ON pr.purchase_id = pp.id " +
                     "LEFT JOIN prod_supplier d ON pr.supplier_id = d.id " +
                     "LEFT JOIN users u ON pr.uid = u.id " +
                     "WHERE DATE(pr.date_time) BETWEEN ? AND ?" +
                     (supplierId > 0 ? " AND pr.supplier_id = ?" : "") +
                     " ORDER BY pr.date_time DESC";
        ps = con.prepareStatement(sql);
        ps.setString(1, fromDate);
        ps.setString(2, toDate);
        if (supplierId > 0) ps.setInt(3, supplierId);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt(1));     // 0 id
            row.addElement(rs.getString(2));  // 1 return_no
            row.addElement(rs.getInt(3));     // 2 purchase_id
            row.addElement(rs.getString(4));  // 3 prno
            row.addElement(rs.getString(5));  // 4 supplier_name
            row.addElement(rs.getDouble(6));  // 5 total
            row.addElement(rs.getString(7));  // 6 notes
            row.addElement(rs.getString(8));  // 7 date_time
            row.addElement(rs.getString(9));  // 8 entered_by
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Get items for a specific purchase return.
 * Returns: [id, product_name, qty, rate, total]
 */
public Vector getPurchaseReturnDetails(int returnId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        String sql = "SELECT prd.id, p.name, prd.qty, prd.rate, prd.total " +
                     "FROM prod_purchase_return_details prd " +
                     "JOIN prod_product p ON prd.product_id = p.id " +
                     "WHERE prd.return_id = ? ORDER BY prd.id";
        ps = con.prepareStatement(sql);
        ps.setInt(1, returnId);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt(1));     // 0 id
            row.addElement(rs.getString(2));  // 1 product_name
            row.addElement(rs.getDouble(3));  // 2 qty
            row.addElement(rs.getDouble(4));  // 3 rate
            row.addElement(rs.getDouble(5));  // 4 total
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

public int getPurchaseIdByPrno(String prno) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    int purchaseId = 0;
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement("SELECT id FROM prod_purchase WHERE prno = ? AND is_cancelled = 0 LIMIT 1");
        ps.setString(1, prno.trim());
        rs = ps.executeQuery();
        if (rs.next()) purchaseId = rs.getInt(1);
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return purchaseId;
}

/** Returns already-returned qty per purchase_detail_id for a given purchase.
 * Each element: [detailId(Integer), returnedQty(Double)] */
public Vector getAlreadyReturnedQtyForPurchase(int purchaseId) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT prd.purchase_detail_id, IFNULL(SUM(prd.qty),0) " +
            "FROM prod_purchase_return_details prd " +
            "JOIN prod_purchase_return pr ON prd.return_id = pr.id " +
            "WHERE pr.purchase_id = ? " +
            "GROUP BY prd.purchase_detail_id");
        ps.setInt(1, purchaseId);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getInt(1));     // 0 detailId
            row.addElement(rs.getDouble(2));  // 1 returnedQty
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

// ─────────────────────────────────────────────────────────────────────────────
// PRODUCT ANALYSIS REPORT METHODS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Sales transactions for a product within a date range (normal sales only).
 * Returns: [0:bill_display, 1:date, 2:cusName, 3:qty, 4:price, 5:disc, 6:gst, 7:total, 8:cost, 9:user]
 */
public Vector getProductSalesReport(int prodId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, b.date, IFNULL(b.cusName,'Walk-in'), " +
            "       bd.qty, bd.price, bd.disc, bd.gst, bd.total, bd.cost, " +
            "       IFNULL(u.user_name,'—') " +
            "FROM prod_bill_details bd " +
            "JOIN prod_bill b ON bd.bill_id = b.id " +
            "LEFT JOIN users u ON b.uid = u.id " +
            "WHERE bd.prod_id = ? AND b.date BETWEEN ? AND ? " +
            "  AND b.is_cancelled = 0 AND bd.is_cancelled = 0 AND bd.is_exchanged = 0 " +
            "ORDER BY b.date DESC, b.id DESC");
        ps.setInt(1, prodId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getString(3));   // 2 cusName
            row.addElement(rs.getDouble(4));   // 3 qty
            row.addElement(rs.getDouble(5));   // 4 price
            row.addElement(rs.getDouble(6));   // 5 disc
            row.addElement(rs.getDouble(7));   // 6 gst
            row.addElement(rs.getDouble(8));   // 7 total
            row.addElement(rs.getDouble(9));   // 8 cost
            row.addElement(rs.getString(10));  // 9 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Sales returns (is_exchanged=2) for a product within a date range.
 * Returns: [0:bill_display, 1:date, 2:cusName, 3:qty, 4:price, 5:total, 6:user]
 */
public Vector getProductSalesReturnReport(int prodId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, b.date, IFNULL(b.cusName,'Walk-in'), " +
            "       bd.qty, bd.price, bd.total, IFNULL(u.user_name,'—') " +
            "FROM prod_bill_details bd " +
            "JOIN prod_bill b ON bd.bill_id = b.id " +
            "LEFT JOIN users u ON b.uid = u.id " +
            "WHERE bd.prod_id = ? AND b.date BETWEEN ? AND ? " +
            "  AND b.is_cancelled = 0 AND bd.is_exchanged = 2 " +
            "ORDER BY b.date DESC, b.id DESC");
        ps.setInt(1, prodId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getString(3));   // 2 cusName
            row.addElement(rs.getDouble(4));   // 3 qty
            row.addElement(rs.getDouble(5));   // 4 price
            row.addElement(rs.getDouble(6));   // 5 total
            row.addElement(rs.getString(7));   // 6 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Purchase transactions for a product within a date range.
 * Returns: [0:prno, 1:invno, 2:ent_date, 3:supplier, 4:qty, 5:free, 6:rate, 7:mrp, 8:disc_per, 9:tax, 10:totalamt, 11:netamt, 12:user]
 */
public Vector getProductPurchaseReport(int prodId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT p.prno, p.invno, p.ent_date, IFNULL(s.name,'—'), " +
            "       pd.quantity, pd.free, pd.rate, pd.mrp, pd.disc_per, pd.tax, pd.totalamt, pd.netamt, " +
            "       IFNULL(u.user_name,'—') " +
            "FROM prod_purchase_details pd " +
            "JOIN prod_purchase p ON pd.prid = p.id " +
            "LEFT JOIN prod_supplier s ON p.deal_id = s.id " +
            "LEFT JOIN users u ON p.ent_uid = u.id " +
            "WHERE pd.prods_id = ? AND p.ent_date BETWEEN ? AND ? " +
            "  AND p.is_cancelled = 0 AND pd.is_cancelled = 0 " +
            "ORDER BY p.ent_date DESC, p.id DESC");
        ps.setInt(1, prodId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 prno
            row.addElement(rs.getString(2));   // 1 invno
            row.addElement(rs.getString(3));   // 2 ent_date
            row.addElement(rs.getString(4));   // 3 supplier
            row.addElement(rs.getDouble(5));   // 4 qty
            row.addElement(rs.getDouble(6));   // 5 free
            row.addElement(rs.getDouble(7));   // 6 rate
            row.addElement(rs.getDouble(8));   // 7 mrp
            row.addElement(rs.getDouble(9));   // 8 disc_per
            row.addElement(rs.getDouble(10));  // 9 tax
            row.addElement(rs.getDouble(11));  // 10 totalamt
            row.addElement(rs.getDouble(12));  // 11 netamt
            row.addElement(rs.getString(13));  // 12 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Purchase return transactions for a product within a date range.
 * Returns: [0:return_no, 1:date, 2:supplier, 3:qty, 4:rate, 5:total, 6:notes, 7:user]
 */
public Vector getProductPurchaseReturnReport(int prodId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT pr.return_no, DATE(pr.date_time), IFNULL(s.name,'—'), " +
            "       prd.qty, prd.rate, prd.total, IFNULL(pr.notes,''), IFNULL(u.user_name,'—') " +
            "FROM prod_purchase_return_details prd " +
            "JOIN prod_purchase_return pr ON prd.return_id = pr.id " +
            "LEFT JOIN prod_supplier s ON pr.supplier_id = s.id " +
            "LEFT JOIN users u ON pr.uid = u.id " +
            "WHERE prd.product_id = ? AND DATE(pr.date_time) BETWEEN ? AND ? " +
            "ORDER BY pr.date_time DESC");
        ps.setInt(1, prodId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 return_no
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getString(3));   // 2 supplier
            row.addElement(rs.getDouble(4));   // 3 qty
            row.addElement(rs.getDouble(5));   // 4 rate
            row.addElement(rs.getDouble(6));   // 5 total
            row.addElement(rs.getString(7));   // 6 notes
            row.addElement(rs.getString(8));   // 7 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Exchange transactions involving a product (as old or new) within a date range.
 * Returns: [0:bill_display, 1:date, 2:cusName, 3:old_prod, 4:new_prod, 5:direction(Out/In), 6:user]
 */
public Vector getProductExchangeReport(int prodId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, DATE(e.date_time), IFNULL(b.cusName,'Walk-in'), " +
            "       old_p.name, new_p.name, " +
            "       CASE WHEN e.old_prod_id = ? THEN 'Out' ELSE 'In' END, " +
            "       IFNULL(u.user_name,'—') " +
            "FROM pro_bill_exchange e " +
            "JOIN prod_bill b ON e.bill_id = b.id " +
            "JOIN prod_product old_p ON e.old_prod_id = old_p.id " +
            "JOIN prod_product new_p ON e.new_prod_id = new_p.id " +
            "LEFT JOIN users u ON b.uid = u.id " +
            "WHERE (e.old_prod_id = ? OR e.new_prod_id = ?) " +
            "  AND DATE(e.date_time) BETWEEN ? AND ? " +
            "ORDER BY e.date_time DESC");
        ps.setInt(1, prodId);
        ps.setInt(2, prodId);
        ps.setInt(3, prodId);
        ps.setString(4, fromDate);
        ps.setString(5, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getString(3));   // 2 cusName
            row.addElement(rs.getString(4));   // 3 old_prod
            row.addElement(rs.getString(5));   // 4 new_prod
            row.addElement(rs.getString(6));   // 5 direction
            row.addElement(rs.getString(7));   // 6 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Cancelled transactions involving a product within a date range.
 * Includes bill-level and item-level cancellations.
 * Returns: [0:bill_display, 1:date, 2:cusName, 3:qty, 4:price, 5:total, 6:cancel_type(Bill/Item), 7:user]
 */
public Vector getProductCancelReport(int prodId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, b.date, IFNULL(b.cusName,'Walk-in'), " +
            "       bd.qty, bd.price, bd.total, " +
            "       CASE WHEN b.is_cancelled = 1 THEN 'Bill' ELSE 'Item' END, " +
            "       IFNULL(u.user_name,'—') " +
            "FROM prod_bill_details bd " +
            "JOIN prod_bill b ON bd.bill_id = b.id " +
            "LEFT JOIN users u ON b.uid = u.id " +
            "WHERE bd.prod_id = ? AND b.date BETWEEN ? AND ? " +
            "  AND (b.is_cancelled = 1 OR bd.is_cancelled = 1) " +
            "ORDER BY b.date DESC, b.id DESC");
        ps.setInt(1, prodId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getString(3));   // 2 cusName
            row.addElement(rs.getDouble(4));   // 3 qty
            row.addElement(rs.getDouble(5));   // 4 price
            row.addElement(rs.getDouble(6));   // 5 total
            row.addElement(rs.getString(7));   // 6 cancel_type
            row.addElement(rs.getString(8));   // 7 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOMER ANALYSIS REPORT METHODS
// ─────────────────────────────────────────────────────────────────────────────

/**
 * Sales for a customer within a date range (normal, non-cancelled bills).
 * Returns: [0:bill_display, 1:date, 2:total, 3:payable, 4:paid, 5:balance, 6:paymentMode, 7:user]
 */
public Vector getCustomerSalesReport(int customerId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, b.date, b.total, b.payable, b.paid, b.balance, " +
            "       CASE b.paymentMode WHEN 1 THEN 'Cash' WHEN 2 THEN 'Credit' WHEN 3 THEN 'Mixed' ELSE 'Other' END, " +
            "       IFNULL(u.user_name,'—') " +
            "FROM prod_bill b " +
            "LEFT JOIN users u ON b.uid = u.id " +
            "WHERE b.customerId = ? AND b.date BETWEEN ? AND ? AND b.is_cancelled = 0 " +
            "ORDER BY b.date DESC, b.id DESC");
        ps.setInt(1, customerId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getDouble(3));   // 2 total
            row.addElement(rs.getDouble(4));   // 3 payable
            row.addElement(rs.getDouble(5));   // 4 paid
            row.addElement(rs.getDouble(6));   // 5 balance
            row.addElement(rs.getString(7));   // 6 paymentMode
            row.addElement(rs.getString(8));   // 7 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Sales returns (is_exchanged=2) for a customer within a date range.
 * Returns: [0:bill_display, 1:date, 2:prod_name, 3:qty, 4:price, 5:total, 6:user]
 */
public Vector getCustomerSalesReturnReport(int customerId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, b.date, p.name, bd.qty, bd.price, bd.total, IFNULL(u.user_name,'—') " +
            "FROM prod_bill_details bd " +
            "JOIN prod_bill b ON bd.bill_id = b.id " +
            "JOIN prod_product p ON bd.prod_id = p.id " +
            "LEFT JOIN users u ON b.uid = u.id " +
            "WHERE b.customerId = ? AND b.date BETWEEN ? AND ? " +
            "  AND b.is_cancelled = 0 AND bd.is_exchanged = 2 " +
            "ORDER BY b.date DESC, b.id DESC");
        ps.setInt(1, customerId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getString(3));   // 2 prod_name
            row.addElement(rs.getDouble(4));   // 3 qty
            row.addElement(rs.getDouble(5));   // 4 price
            row.addElement(rs.getDouble(6));   // 5 total
            row.addElement(rs.getString(7));   // 6 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Exchanges for a customer within a date range.
 * Returns: [0:bill_display, 1:date, 2:old_prod, 3:new_prod, 4:user]
 */
public Vector getCustomerExchangeReport(int customerId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, DATE(e.date_time), op.name, np.name, IFNULL(u.user_name,'—') " +
            "FROM pro_bill_exchange e " +
            "JOIN prod_bill b ON e.bill_id = b.id " +
            "JOIN prod_product op ON e.old_prod_id = op.id " +
            "JOIN prod_product np ON e.new_prod_id = np.id " +
            "LEFT JOIN users u ON b.uid = u.id " +
            "WHERE e.customer_id = ? AND DATE(e.date_time) BETWEEN ? AND ? " +
            "ORDER BY e.date_time DESC");
        ps.setInt(1, customerId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getString(3));   // 2 old_prod
            row.addElement(rs.getString(4));   // 3 new_prod
            row.addElement(rs.getString(5));   // 4 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

/**
 * Exchange point ledger for a customer within a date range.
 * Returns: [0:bill_display, 1:date, 2:old_point, 3:exchange_point(+/-), 4:total_point, 5:notes, 6:user]
 */
public Vector getCustomerExchangePoints(int customerId, String fromDate, String toDate) throws Exception {
    Connection con = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    Vector vec = new Vector();
    try {
        con = util.DBConnectionManager.getConnectionFromPool();
        ps = con.prepareStatement(
            "SELECT b.bill_display, DATE(ep.date_time), ep.old_point, ep.exchange_point, ep.total_point, " +
            "       IFNULL(ep.notes,''), IFNULL(u.user_name,'—') " +
            "FROM customers_exchange_point ep " +
            "JOIN prod_bill b ON ep.bill_id = b.id " +
            "LEFT JOIN users u ON ep.uid = u.id " +
            "WHERE ep.customer_id = ? AND DATE(ep.date_time) BETWEEN ? AND ? " +
            "ORDER BY ep.date_time ASC");
        ps.setInt(1, customerId);
        ps.setString(2, fromDate);
        ps.setString(3, toDate);
        rs = ps.executeQuery();
        while (rs.next()) {
            Vector row = new Vector();
            row.addElement(rs.getString(1));   // 0 bill_display
            row.addElement(rs.getString(2));   // 1 date
            row.addElement(rs.getDouble(3));   // 2 old_point
            row.addElement(rs.getDouble(4));   // 3 exchange_point (+/-)
            row.addElement(rs.getDouble(5));   // 4 total_point
            row.addElement(rs.getString(6));   // 5 notes
            row.addElement(rs.getString(7));   // 6 user
            vec.add(row);
        }
    } finally {
        if (rs  != null) try { rs.close();  } catch (Exception e) { ; }
        if (ps  != null) try { ps.close();  } catch (Exception e) { ; }
        if (con != null) try { con.close(); } catch (Exception e) { ; }
    }
    return vec;
}

}
