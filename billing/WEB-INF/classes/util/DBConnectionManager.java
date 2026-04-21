package util; 
import java.sql.*;
import javax.naming.*;
import javax.sql.*;

public final class DBConnectionManager 
	{
	private static 	DBConnectionManager manager = new DBConnectionManager();
	private DataSource ds;
		
	private DBConnectionManager()
		{
		try 
			{
			Context initCtx = new InitialContext();
			Context envCtx 	= (Context) initCtx.lookup("java:comp/env"); 
			ds 		= (DataSource)envCtx.lookup("jdbc/jangel1db"); 
			System.out.println("Connection Created by Pooling Method"); 
			}
		catch(Exception e)
			{
			e.printStackTrace();	
			} 
		}
	
	public static Connection getConnectionFromPool() throws SQLException
		{
		Connection con = 	manager.ds.getConnection();
		con.setAutoCommit(false);
		
		return con;
		}
	
	}////////////End of Class
