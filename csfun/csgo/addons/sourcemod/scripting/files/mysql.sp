void SA_MySQLConnect()
{
	if (hDB != null)
	{
		return;
	}
	
	if (!SQL_CheckConfig("sa3"))
	{
		delete hDB;
		SetFailState("%s Cannot find the \"sa3\" entry in your databases.cfg", SA3);
		return;
	}
	
	Database.Connect(SA_OnConnect, "sa3");
}

public void SA_OnConnect(Database db, const char[] error, any data)
{
    if (db == null || strlen(error) > 0)
    {
        SetFailState("(OnConnect) Connection to database failed: %s", error);
        return;
    }

    DBDriver iDriver = db.Driver;
    
    char sType[18];
    iDriver.GetIdentifier(sType, sizeof(sType));

    if (!StrEqual(sType, "mysql", false))
    {
        SetFailState("(OnConnect) TTT has only MySQL and SQLite support!");
        return;
    }

    hDB = db;
    
    SA_MySQLCheckTables();
}

bool SA_MySQLCheckTables()
{
	return false;
}
