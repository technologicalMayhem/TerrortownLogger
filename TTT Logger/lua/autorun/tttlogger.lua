--ConVars
CreateConVar("tttlogger_enabled", 1, 256, "Enables the TTTLogger.")
CreateConVar("tttlogger_debug", 0, 256, "Enables Debug Mode.")
CreateConVar("tttlogger_debug_printtochat", 0, 256, "Prints to chat instead of log.")
CreateConVar("tttlogger_min_players", 3, 256, "Minimum ammount of players needed for the Logger to work.")
--Vars
local Timestamp = os.time()
local FileTimeString = os.date( "%Y-%m-%d - %H-%M-%S" , Timestamp )
local damagetypes = {[1]="DMG_CRUSH",[2]="DMG_BULLET",[4]="DMG_SLASH",[8]="DMG_BURN",[16]="DMG_VEHICLE",[32]="DMG_FALL",[64]="DMG_BLAST",[128]="DMG_CLUB",[16384]="DMG_DROWN"}
local boolstring = {[false]="false", [true]="true"}
local playerlastdamage = {}
local playerhealth = {}
local matchinprogress = false
local LogFile = "TTTLogger/TTTLog/missingtimestamp.txt"
local RoundTime = 0
--Functions
if not game.IsDedicated() and not engine.ActiveGamemode() == "terrortown" then
	GetConVar("tttlogger_enabled"):SetString("0")
end
local function onBeginRound()
	if (SERVER) and countactiveplayers() > GetConVar( "tttlogger_min_players"):GetInt() and GetConVar( "tttlogger_enabled"):GetInt() == 1 or GetConVar( "tttlogger_debug"):GetInt() == 1 and GetConVar( "tttlogger_enabled"):GetInt() == 1 then
		matchinprogress = true
		RoundTime = CurTime()
		updatetimesstamp()
		PrintMessage( HUD_PRINTTALK, "Round tracking is enabled for this round." )
		print( "Round tracking has started. Log File: " .. LogFile )
		addtolog( "<Timestamp> [" .. Timestamp .. "]\n<Map> [" .. game.GetMap() .. "]\n")
		for k, ply in pairs(player.GetAll()) do
			addtolog( "<PlayerInfo>" .. logGetPlayerInfo(ply) .. "[" .. boolstring[ply:IsSpec()] .. "][" .. math.Round(ply:GetBaseKarma()) .. "]\n" )
			logSetHealth(ply)
		end
	elseif (SERVER) then
		logPrintinfo( "Round tracking aborted. Not enough players." )
	end
end
local function onTTTOrderedEquipment( ply, equipment, is_item)
	if is_item then
		addtolog( "<TTTOrderedEquipment>" .. logGetPlayerInfo(ply) .. " has bought equipment [" .. equipment .. "]\n" )
	else
		addtolog( "<TTTOrderedWeapon>" .. logGetPlayerInfo(ply) .. " has bought weapon [" .. equipment .. "]\n" )
	end
end
local function onPlayerDeath( victim, inflictor, attacker )  -- Kill Handling
	if matchinprogress then
		if ( attacker:IsWorld() or attacker:GetClass() == "trigger_hurt" ) then
			addtolog( "<PlayerDeathWorld>" .. logGetPlayerInfo(victim) .. " was killed by the World. The cause was [" .. playerlastdamage[victim:SteamID64()] .. "]\n" )
		else
			addtolog( "<PlayerKilled>" .. logGetPlayerInfo(victim) .. " was killed by " .. logGetPlayerInfo(attacker) .. "\n" )
		end
	end
end
local function onEntityTakeDamage ( target, dmginfo )
	if matchinprogress and target:IsPlayer() then
		if target:Alive() then
			if tableHasKey( damagetypes, dmginfo:GetDamageType() ) then
				playerlastdamage[target:SteamID64()] = damagetypes[dmginfo:GetDamageType()]
			else
				playerlastdamage[target:SteamID64()] = "Unknown"
			end
			if dmginfo:GetDamage() ~= 0 and dmginfo:GetAttacker():IsPlayer() then
				waitLog( "<TakeDamageWeapon>" .. logGetPlayerInfo( dmginfo:GetAttacker() ) .. " dealt [", target, "] damage by using [" .. logGetWeapon(dmginfo) .. "] to " .. logGetPlayerInfo(target) .. "\n" )
			elseif dmginfo:GetInflictor():IsWorld() then
				waitLog( "<TakeDamageWorld>The world dealt [", target, "][" .. damagetypes[dmginfo:GetDamageType()] .. "] damage to " .. logGetPlayerInfo(target) .. "\n" )
			end
		end
	end
end
local function onTTTEndRound(result)
	if matchinprogress then
		matchinprogress = false
		if result == WIN_TRAITOR then
			addtolog( "<EndRound> The [Traitors] have won!\n" )
		elseif result == WIN_INNOCENT then
			addtolog( "<EndRound> The [Innocent] have won!\n" )
		elseif result == WIN_TIMELIMIT then
			addtolog( "<EndRound> The [Time] has run up! The Innocent win!\n" )
		end
		for k, ply in pairs(player.GetAll()) do
			addtolog( "<PlayerInfoEnd>" .. logGetPlayerInfo(ply) .. "[" .. boolstring[ply:Alive()] .. "]\n" )
		end
		--addtolog( "<RoundTime> Round took [" .. math.Round(CurTime() - RoundTime, 2) .. "] seconds." )
		logPrintinfo("Round Tracking ended! Round Length: " .. string.ToMinutesSeconds(math.Round(CurTime() - RoundTime, 2)) .. "." )
	end
end
function waitLog(part1, ply, part2)
	timer.Simple(0.0001, function()
		addtolog(part1 .. logUpdateHealth(ply) .. part2)
	end)
end
function logSetHealth(ply)
	playerhealth[ply:SteamID64()] = ply:Health()
end
function logUpdateHealth(ply)
	local diff = playerhealth[ply:SteamID64()] - ply:Health()
	playerhealth[ply:SteamID64()] = ply:Health()
	return diff
end
function logGetWeapon( dmginfo )
	if(dmginfo:GetInflictor():IsPlayer()) then
		return(dmginfo:GetInflictor():GetActiveWeapon():GetClass())
	else
		return(dmginfo:GetInflictor():GetClass())
	end
end
function logPrintinfo(message)
	PrintMessage( HUD_PRINTTALK, message )
	print( message )
end
function tableHasKey(table,key)
    return table[key] ~= nil
end
function addtolog( message )
	if GetConVar( "tttlogger_debug_printtochat"):GetBool() then
		print ( message )
		PrintMessage ( HUD_PRINTTALK, message )
	else
		file.Append( LogFile, math.Round(CurTime() - RoundTime, 2) .. "|" .. message )
	end
end
function logGetPlayerInfo(ply)
	if ply:IsPlayer() then
		return ply:Name() .. "[" .. ply:SteamID64() .. "][" .. ply:GetRoleString() .. "]"
	else
		return "[Error, not a player it was" .. ply:GetClass() .. "]"
	end
end
function countactiveplayers()
	local activeplayers = 0
	for k, ply in pairs(player.GetAll()) do
		if ply:IsSpec() == false then
			activeplayers = activeplayers + 1
		end
	end
	return activeplayers
end
function updatetimesstamp()
	loddate = os.date( "%Y-%m-%d" , os.time() )
	logtime = os.date( "%H-%M-%S" , os.time() )
	if not file.Exists( "tttlogger", "DATA" ) then
		file.CreateDir( "tttlogger" )
	end
	if not file.Exists( "tttlogger/" .. loddate, "DATA" ) then
		file.CreateDir( "tttlogger/" .. loddate )
	end
	LogFile = "tttlogger/" .. loddate .. "/" .. logtime .. ".txt"
end
--Hooks
hook.Add( "TTTBeginRound", "tttloggerBeginRound", onBeginRound )
hook.Add( "TTTOrderedEquipment", "tttloggerTTTOrderedEquipment", onTTTOrderedEquipment )
hook.Add( "TTTEndRound", "tttloggerBeginRound", onTTTEndRound )
hook.Add( "PlayerDeath", "tttloggerPlayerDeath", onPlayerDeath )
hook.Add( "EntityTakeDamage", "tttloggerEntityTakeDamage", onEntityTakeDamage )