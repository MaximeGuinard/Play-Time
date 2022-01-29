AddCSLuaFile()
util.AddNetworkString("playtime")
util.AddNetworkString("playtimeRefreshQuery")
util.AddNetworkString("sendCurPlaytime")

if SERVER then
    function tableExist() -- check the table does exist, or doesn't
        if sql.TableExists("playtime") then -- table exist
            return true
        else -- table doesn't exist
            local createTable = "CREATE TABLE playtime (steamid varchar(255), time int)"
            local createTable = sql.Query(createTable) -- create table

            return true -- now table is exist
        end
    end

    function checkPlayer(ply) -- checks if player is new on the server, or not 
        local tableExist = tableExist() -- check the table exist and if not it'll create table
        if tableExist == true then -- it isn't possible to table isn't exist now :/
            local steamid = ply:SteamID() -- get steamid of player

            local getData = "SELECT * FROM playtime WHERE steamid = '" .. steamid .. "'" -- try to get all data about the player
            local getData = sql.Query(getData)

            if (getData == nil) then -- checks if the player is in the table
                -- player isn't be in the table
                local createData = "INSERT INTO playtime VALUES('" .. steamid .. "', 0)"
                local createData = sql.Query(createData) -- insert data of player into the table

                countPlaytime()
            else
                countPlaytime()
            end
        end
    end

    function countPlaytime() -- this function responsible for counting time of the players
        timer.Create("Update Playtime", 1, 0, function() -- this timer create infinite loop to update playtime of the player
            for k, v in pairs(player.GetAll()) do
                local steamid = v:SteamID()
        
                local getPlaytime = "SELECT time FROM playtime WHERE steamid = '" .. steamid .. "'"
                local getPlaytime = sql.QueryValue(getPlaytime) -- get current playtime of the player

                -- now playtime'll iterate by one sec
                local newPlaytime = getPlaytime + 1
                local updatePlaytime = "UPDATE playtime SET time = " .. newPlaytime .. " WHERE steamid = '" .. steamid .. "'"
                local updatePlaytime = sql.Query(updatePlaytime) -- playtime was updated!
            end
        end)
    end

    function getPlayertimeData(ply) -- get playtime of the player
        local steamid = ply:SteamID()
        local getPlaytimeQuery = "SELECT time FROM playtime WHERE steamid = '" .. steamid .. "'"
        local getPlaytime = sql.QueryValue(getPlaytimeQuery) -- get current playtime of the player
    
        local formattedPlaytime = string.FormattedTime(getPlaytime) -- format int into the table
        local formattedPlaytime = formattedPlaytime.h .. "h  " .. formattedPlaytime.m .. "m " .. formattedPlaytime.s .. "s"
    
        return formattedPlaytime -- return playtime of the player
    end
end

local function spawn(ply)
    checkPlayer(ply)
end
hook.Add("PlayerInitialSpawn", "playtimeSpawn", spawn)

local function playtimeCommand(ply, text, public) 
    local time = getPlayertimeData(ply)
        
    if text == "/playtime" then --if the command's "/playtime" then show playtime on chat
        ply:PrintMessage(HUD_PRINTTALK, "Votre temps de jeu est de " .. time .. "") -- print's in the chat playtime of the player

        return ""
    else
        if text == "/time" then --if the command's "/time" then show playtime on chat
        ply:PrintMessage(HUD_PRINTTALK, "Votre temps de jeu est de : " .. time .. "") -- print's in the chat playtime of the player

        return ""
    end
end
end
hook.Add("PlayerSay", "playtimeCommand", playtimeCommand)

net.Receive("playtimeRefreshQuery", function(len, ply) -- this function'll send to client his actual playtime
    local curPlaytime = getPlayertimeData(ply)

    net.Start("sendCurPlaytime")
    net.WriteString(curPlaytime)
    net.Send(ply)
end)