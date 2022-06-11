#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <SteamWorks>
#include <discord>


#define CLAIM_MSG "{\"username\":\"{BOTNAME}\", \"embeds\": [{\"color\": \"{COLOR}\", \"title\": \"{HOSTNAME} (steam://connect/{SERVER_IP}:{SERVER_PORT})\", \"fields\": [{\"name\": \"Player\", \"value\": \"{NAME}\"}, {\"name\": \"SteamID\", \"value\": \"{STEAMID}\"}, {\"name\": \"Bug\", \"value\": \"{MSG}\"}]}]}"


#pragma semicolon 1
#pragma newdecls required

char username[64];
char steamid[64];
char bugreport[512];
char server_port[10];
char server_ip[16];
char default_ip[16] = "0.0.0.0";
char default_port[6] = "00000";
	
ConVar g_cWebhook = null;
ConVar g_cBotName = null;
ConVar g_cColor = null;
ConVar g_cCustomIP = null;
ConVar g_cCustomPort = null;
ConVar port;
ConVar serverip; 	

public Plugin myinfo = 
{
	name = "Bug report system",
	author = "CLNissen",
	description = "System til at rapportere bugs ingame",
	version = "1.0",
	url = "hjemezez.dk"
};


public void OnPluginStart()
{
	RegConsoleCmd("sm_bug", Command_Bug, "Rapporterer bug");
	
	
	g_cBotName = CreateConVar("clnissen_reportsystem_botname", "", "Report botname, leave this blank to use the webhook default name.");
	g_cColor = CreateConVar("clnissen_reportsystem_color", "14934802", "Discord/Slack attachment color used for reports.");
	g_cWebhook = CreateConVar("clnissen_reportsystem_webhook", "calladmin", "Config key from configs/discord.cfg.");
	g_cCustomIP = CreateConVar("clnissen_reportsystem_customip", "0.0.0.0", "Set server ip her hvis der er brug af docker");
	g_cCustomPort = CreateConVar("clnissen_reportsystem_customport", "00000", "Set custom port hvis der er brug af docker");
	
	AutoExecConfig(true);
}


public Action Command_Bug(int client, int args)
{
	
	if (args == 0)
	{
		ReplyToCommand(client, "[SM] Usage: sm_bug <beskrivelse af bug>");
		return Plugin_Handled;
	}
	
	if (client == 0)
	{
		ReplyToCommand(client, "[SM] Error: Hvis du sidder og rapporterer bugs fra konsol, så burde du selv kunne fikse dem ;)");
		return Plugin_Handled;
	}
	
	
	GetCmdArgString(bugreport, sizeof(bugreport));
	Discord_EscapeString(bugreport, sizeof(bugreport));
	
	GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid));
	Discord_EscapeString(steamid, sizeof(steamid));
	
	GetClientName(client, username, sizeof(username));
	Discord_EscapeString(username, sizeof(username));
	
	char sBot[512];
	g_cBotName.GetString(sBot, sizeof(sBot));
	
	char sColor[10];
	g_cColor.GetString(sColor, sizeof(sColor));
	
	char customipvalue[64];
	g_cCustomIP.GetString(customipvalue, sizeof(customipvalue));

	char customportvalue[64];
	g_cCustomPort.GetString(customportvalue, sizeof(customportvalue));

	
	if (StrEqual(customipvalue, default_ip))
	{
		serverip = FindConVar("ip");
	
		GetConVarString(serverip, server_ip, sizeof(server_ip));
		Discord_EscapeString(server_ip, sizeof(server_ip));
	}
	else
	{
		GetConVarString(g_cCustomIP, server_ip, sizeof(server_ip));
		Discord_EscapeString(server_ip, sizeof(server_ip));
	}
	
	if (StrEqual(customportvalue, default_port))
	{
		port = FindConVar("hostport");
	
		GetConVarString(port, server_port, sizeof(server_port));
		Discord_EscapeString(server_port, sizeof(server_port));
	}
	else
	{
		GetConVarString(g_cCustomPort, server_port, sizeof(server_port));
		Discord_EscapeString(server_port, sizeof(server_port));
	}
	
	char sMSG[512] = CLAIM_MSG;
	
	ReplaceString(sMSG, sizeof(sMSG), "{BOTNAME}", sBot);
	ReplaceString(sMSG, sizeof(sMSG), "{COLOR}", sColor);
	ReplaceString(sMSG, sizeof(sMSG), "{STEAMID}", steamid);
	ReplaceString(sMSG, sizeof(sMSG), "{NAME}", username);
	ReplaceString(sMSG, sizeof(sMSG), "{MSG}", bugreport);
	
	ReplaceString(sMSG, sizeof(sMSG), "{HOSTNAME}", "HjemEZEZ");
	ReplaceString(sMSG, sizeof(sMSG), "{SERVER_IP}", server_ip);
	ReplaceString(sMSG, sizeof(sMSG), "{SERVER_PORT}", server_port);
	
	char sWebhook[32];
	g_cWebhook.GetString(sWebhook, sizeof(sWebhook)); // Henter calladmin webhook fra discord.cfg
	
	Discord_SendMessage(sWebhook, sMSG);
	
	ReplyToCommand(client, "Message sent.");
	
	return Plugin_Handled;
}



	