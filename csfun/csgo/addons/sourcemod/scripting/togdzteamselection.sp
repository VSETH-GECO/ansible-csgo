/*
	
*/

#pragma semicolon 1
#define PLUGIN_VERSION "1.0.0"
#define LoopValidPlayers(%1)						for(int %1 = 1; %1 <= MaxClients; %1++)		if(IsValidClient(%1))

#include <sourcemod>
#include <autoexecconfig>	//https://github.com/Impact123/AutoExecConfig or https://forums.alliedmods.net/showthread.php?p=1862459
#include <sdkhooks>
#include <sdktools>

#pragma newdecls required

int g_iMaxTeamPlayers = 0;
bool g_bWarmupActive = false;

char a_sTeamNames[][] = {"Black", "Yellow", "Green", "Red", "Pink", "Blue", "Orange", "White", "Purple", "Grey"};

public Plugin myinfo =
{
	name = "TOG Danger Zone Team Selection",
	author = "That One Guy",
	description = "Provides menus for team selection at the start of a match in danger zone (CS:GO).",
	version = PLUGIN_VERSION,
	url = "https://www.togcoding.com/togcoding/"
}

public void OnPluginStart()
{
	CreateConVar("tdzts_version", PLUGIN_VERSION, "TOG Danger Zone Team Selection - version number.", FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	HookEvent("player_team", Event_TeamJoined, EventHookMode_Post);
	//HookEvent("round_start", Event_RoundStart, EventHookMode_Post);
	HookEvent("player_spawn", Event_PlayerSpawn);
	
	RegConsoleCmd("sm_jointeam", Cmd_JoinTeam, "Joins a team in danger zone.");
}

public void OnConfigsExecuted()
{
	ConVar cTeamCnt = FindConVar("sv_dz_team_count");
	if(cTeamCnt == null)
	{
		SetFailState("No such Cvar 'sv_dz_team_count'");
	}
	g_iMaxTeamPlayers = cTeamCnt.IntValue;
	delete cTeamCnt;
}

public void OnMapStart()
{
	g_bWarmupActive = true;
	StartWarmupTeamSelection();
}

public void OnMapEnd()
{
	g_bWarmupActive = true;
}

/*public Action Event_RoundStart(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	StartWarmupTeamSelection();
}*/

void StartWarmupTeamSelection()
{
	ConVar cWarmupLen = FindConVar("mp_warmuptime");
	if(cWarmupLen == null)
	{
		SetFailState("No such Cvar 'mp_warmuptime'");
	}
	float fWarmupLen = cWarmupLen.FloatValue;
	delete cWarmupLen;
	
	CreateTimer(fWarmupLen, TimerCB_WarmupEnding, _, TIMER_FLAG_NO_MAPCHANGE);
}

public Action TimerCB_WarmupEnding(Handle hTimer)
{
	g_bWarmupActive = false;
}

public void OnClientPutInServer(int client)
{
	ShowPlayerMenu(client);
}

public void OnClientDisconnect(int client)
{
	RedrawMenus();
}

void ShowPlayerMenu(int client)
{
	if(!g_bWarmupActive)
	{
		return;
	}
	
	//Store player teams
	int a_iSurvivalTeam[MAXPLAYERS + 1] = {-1, ...};
	LoopValidPlayers(i)
	{
		if(IsValidClient(i))
		{
			a_iSurvivalTeam[i] = GetEntProp(i, Prop_Send, "m_nSurvivalTeam");
		}
	}
	
	Menu oMenu = new Menu(MenuCB_TeamSelection);
	oMenu.SetTitle("- Team Selection -\nJoin teams with chat command !jointeam (followed by team name or number)\nExample: !jointeam 3");
	oMenu.ExitButton = false;
	oMenu.ExitBackButton = false;
	
	ArrayList a_sEmptyTeams;
	a_sEmptyTeams = new ArrayList(50);
	a_sEmptyTeams.Clear();
	
	for(int iTeamNameSlot = 0; iTeamNameSlot < sizeof(a_sTeamNames); iTeamNameSlot++)
	{
		char sBuffer[300];
		Format(sBuffer, sizeof(sBuffer), "Team %s (%i):", a_sTeamNames[iTeamNameSlot], iTeamNameSlot + 1);
		
		int iPlyrCnt = 0;
		bool bFirst = true;
		LoopValidPlayers(i)
		{
			if(a_iSurvivalTeam[i] != iTeamNameSlot)
			{
				continue;
			}

			if(bFirst)
			{
				Format(sBuffer, sizeof(sBuffer), "%s (%N)", sBuffer, i);
				bFirst = false;
			}
			else
			{
				Format(sBuffer, sizeof(sBuffer), "%s, (%N)", sBuffer, i);
			}
			iPlyrCnt++;
		}

		for(int j = iPlyrCnt; j < g_iMaxTeamPlayers; j++)
		{
			Format(sBuffer, sizeof(sBuffer), "%s, <EMPTY>", sBuffer);
		}
		if(iPlyrCnt)
		{
			oMenu.AddItem("", sBuffer);
		}
		else
		{
			char sBuffer2[50];
			Format(sBuffer2, sizeof(sBuffer2), "%s (%i)", a_sTeamNames[iTeamNameSlot], iTeamNameSlot + 1);
			a_sEmptyTeams.PushString(sBuffer2);
		}
	}
	
	if(a_sEmptyTeams.Length)
	{
		char sBuffer[300];
		bool bFirst = true;
		for(int i = 0; i < a_sEmptyTeams.Length; i++)
		{
			char sTeamName[50];
			a_sEmptyTeams.GetString(i, sTeamName, sizeof(sTeamName));
			if(bFirst)
			{
				Format(sBuffer, sizeof(sBuffer), "Empty Teams: %s", sTeamName);
				bFirst = false;
			}
			else
			{
				Format(sBuffer, sizeof(sBuffer), "%s, %s", sBuffer, sTeamName);
			}
		}
		oMenu.AddItem("", sBuffer, ITEMDRAW_DISABLED);
	}
	
	
	//Add a line for players not on teams
	char sBuffer[1000];
	bool bFirst = true;
	LoopValidPlayers(i)
	{
		if(IsValidClient(i))
		{
			if(GetEntProp(i, Prop_Send, "m_nSurvivalTeam") == -1)
			{
				if(bFirst)
				{
					Format(sBuffer, sizeof(sBuffer), "Spectators: (%N)", i);
					bFirst = false;
				}
				else
				{
					Format(sBuffer, sizeof(sBuffer), "%s ; (%N)", sBuffer, i);
				}
			}
		}
	}
	if(!bFirst)	//if at least one player found
	{
		oMenu.AddItem("", sBuffer, ITEMDRAW_DISABLED);
	}
	
	oMenu.Display(client, MENU_TIME_FOREVER);
	delete oMenu;
}

public int MenuCB_TeamSelection(Menu oMenu, MenuAction action, int client, int param2)
{
	if(action == MenuAction_End)
	{
		if(oMenu != null)
		{
			delete oMenu;
		}
		return;
	}

	if(action == MenuAction_Select)
	{
		FakeClientCommand(client, "dz_jointeam %i", param2 + 1);
		RedrawMenus();
	}
}

void RedrawMenus()
{
	LoopValidPlayers(i)
	{
		ShowPlayerMenu(i);
	}
}

public Action Event_PlayerSpawn(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int iUserID = hEvent.GetInt("userid");
	int client = GetClientOfUserId(iUserID);
	if(!IsValidClient(client))
	{
		return;
	}
	
	CreateTimer(3.0, TimerCB_ShowMenu, iUserID, TIMER_FLAG_NO_MAPCHANGE|TIMER_REPEAT);
}

public Action TimerCB_ShowMenu(Handle hTimer, any iUserID)
{
	int client = GetClientOfUserId(iUserID);
	if(!IsValidClient(client))
	{
		return Plugin_Stop;
	}
	
	if(!g_bWarmupActive)
	{
		return Plugin_Stop;
	}
	
	ShowPlayerMenu(client);
	return Plugin_Continue;
}

public Action Event_TeamJoined(Event hEvent, const char[] sName, bool bDontBroadcast)
{
	int client = GetClientOfUserId(hEvent.GetInt("userid"));
	if(IsValidClient(client))
	{
		RedrawMenus();
	}
	return Plugin_Continue;
}

public Action Cmd_JoinTeam(int client, int iArgs)
{
	if(!IsValidClient(client))
	{
		ReplyToCommand(client, "You must be in game to use this command!");
		return Plugin_Handled;
	}
	
	char sTeam[50];
	int iValue = 0;
	GetCmdArg(1, sTeam, sizeof(sTeam));
	if(IsNumeric(sTeam))
	{
		iValue = StringToInt(sTeam);
		if(iValue > 10)
		{
			ReplyToCommand(client, "The highest team number available is 10! Please try again.");
			return Plugin_Handled;
		}
		else
		{
			FakeClientCommand(client, "dz_jointeam %i", iValue);
			return Plugin_Handled;
		}
	}
	else
	{
		for(int iTeamNameSlot = 0; iTeamNameSlot < sizeof(a_sTeamNames); iTeamNameSlot++)
		{
			char sTeamName[50], sTeamName2[50];
			Format(sTeamName, sizeof(sTeamName), "%s", a_sTeamNames[iTeamNameSlot]);
			Format(sTeamName2, sizeof(sTeamName2), "Team %s", a_sTeamNames[iTeamNameSlot]);
			if(StrEqual(sTeamName, sTeam, false) || StrEqual(sTeamName2, sTeam, false))
			{
				FakeClientCommand(client, "dz_jointeam %i", iTeamNameSlot + 1);
				return Plugin_Handled;
			}
		}
		ReplyToCommand(client, "Team not found. Please try again using either a team number or match the team name.");
		return Plugin_Handled;
	}
}

bool IsNumeric(char[] sString)
{
	for(int i = sString[0] == '-' ? 1 : 0; i < strlen(sString); i++)	//first char can be - for neg num
	{
		if(!IsCharNumeric(sString[i]))
		{
			return false;
		}
	}
	return true;
}

bool IsValidClient(int client)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client))
	{
		return false;
	}
	return true;
}

stock void Log(char[] sPath, const char[] sMsg, any ...)		//TOG logging function - path is relative to logs folder.
{
	char sLogFilePath[PLATFORM_MAX_PATH], sFormattedMsg[1500];
	BuildPath(Path_SM, sLogFilePath, sizeof(sLogFilePath), "logs/%s", sPath);
	VFormat(sFormattedMsg, sizeof(sFormattedMsg), sMsg, 3);
	LogToFileEx(sLogFilePath, "%s", sFormattedMsg);
}

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////// CHANGE LOG //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
	1.0.0
		* Initial creation.
		
*/