-------------CONFIG--------------------
local COLLECTION_ID = WORKSHOP_ID_HERE
local IS_DEDICATED_SERVER = false 
local tagColor = Color(228, 225, 93)
local finishedColor = Color(115, 255, 0)
local failColor = Color(165, 19, 19)
---------------------------------------

local workshopAdd = resource.AddWorkshop

local function FoolProofID(ID)
    local retID = ""
    ID = tostring(ID)

    for i = 1, string.len(ID) do
        local curchar = string.sub(ID, i, i)

		local asbyte = string.byte(curchar)

		local in_range = false

		if(asbyte > string.byte("0") - 1 and asbyte < string.byte("9") + 1) then
			in_range = true
		end

		retID = retID .. curchar
    end

    return retID
end

local function ParseWorkshopCollection(html)
    local links = string.gmatch(html, "https%://steamcommunity%.com/sharedfiles/filedetails/%?id=(%d+)",1)
    local workshopFiles = {}
    local workshopTitles = {}

    for link in links do
        if link == COLLECTION_ID then continue end
        workshopFiles[link] = true

        http.Fetch(string.format("https://steamcommunity.com/sharedfiles/filedetails/?id=%s", link), function(body)
            local title = string.find(body, "<title>([%a]+)</title>")
            workshopTitles[link] = title
        end)
    end

    local count = 0
    for id, v in pairs(workshopFiles) do
        local title = workshopTitles[id]

        MsgC(tagColor, "[RyansWorkshopDL] ", color_white, string.format("Adding the following workshop ID: %s (%s)\n", id, title))
        workshopAdd(id)

        count = count + 1
    end

    MsgC(tagColor, "[RyansWorkshopDL] ", finishedColor, string.format("Finished parsing workshop collection. Successfully added %i addons!\n", count))
end

---- Workaround hibernation
if IS_DEDICATED_SERVER then
    hook.Add("Tick", "RyansWorkshopDL.Initialize", function()
        if #player.GetAll() < 1 then
            MsgC(tagColor, "[RyansWorkshopDL] ", color_white, "Initiating http error workaround\n")
            RunConsoleCommand("bot")

            timer.Simple(3, function()
                MsgC(tagColor, "[RyansWorkshopDL] ", color_white, "Finished http error workaround, kicking bot.\n")

                player.GetBots()[1]:Kick()
            end)
        end
        hook.Remove("Tick", "RyansWorkshopDL.Initialize")
    end)
end

if COLLECTION_ID ~= 1234567890 then
    COLLECTION_ID = FoolProofID(COLLECTION_ID)
    local COLLECTION_URL = "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. COLLECTION_ID
    
    timer.Simple(0.1, function()
        MsgC(tagColor, "[RyansWorkshopDL] ", finishedColor, "Fetching collection from " .. COLLECTION_URL .. "\n")
        http.Fetch(COLLECTION_URL, function(body)
            ParseWorkshopCollection(body)
        end, function(err)
            MsgC(tagColor, "[RyansWorkshopDL] ", failColor, "Failed fetching workshop collection\n")
            print(err)
        end)
    end)
end