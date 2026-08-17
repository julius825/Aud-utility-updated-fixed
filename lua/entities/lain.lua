AddCSLuaFile()

ENT.Base = "base_anim"
ENT.Spawnable = true
ENT.Category = "Lain Serial Experiments"
ENT.Author = "Aubarino"
ENT.Contact = "Aubarino#8007 on discord"
ENT.Purpose = "Lain, omnipresent god of the wired, in gmod- she is even more-so the closest thing to one"
ENT.Instructions = "Use aubutil_llm_setkey KEY in console, with your Groq API key you can find here: https://console.groq.com/keys, and then spawn her"
ENT.RenderGroup = RENDERGROUP_OPAQUE
ENT.DisableDuplicator = false
ENT.DoNotDuplicate = false
ENT.PrintName = "Lain"
ENT.LainMusicChance = 3
ENT.LastLainMessage = ""
ENT.DelayedLainThink = 0 -- to save processing power

if CLIENT then
    language.Add("lain", "Lain")
end

list.Set("Entity", "Lain", {
	Name = "Lain",
	Class = "lain",
	Category = "Lain Serial Experiments"
})

function ENT:Initialize()
    self:SetModel("models/lain/lain_computer.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:AddFlags(FL_OBJECT)
    self:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE_DEBRIS)
    self:SetSolid(SOLID_VPHYSICS)

    if SERVER then
        local t = self:create_bound_light(Color(56, 142, 255, 0), 5)
        if (AUBUTIL_LLMKEY == "" or AUBUTIL_LLMKEY == nil or AUBUTIL_LLMKEY == " ") then
            self:LainMessage([[You must set the Groq LLM key - Set via the "aubutil_llm_setkey KEY" command in console]])
            timer.Simple(1, function()
                if IsValid(self) then
                    self:LainMessage([[You can get your key at https://console.groq.com/keys, Groq is free]])
                end
            end)
        else
            self:LainMessage("[Joined]")
        end
    end
end

function ENT:GetLastChatLog(offset)
    offset = offset or 0
    if GetAddonLoaded(2880413233) then
        if (#_Sapbot_ChatlogALL - offset) < 1 then 
            return "" 
        end
        return _Sapbot_ChatlogALL[#_Sapbot_ChatlogALL - offset] or ""
    else
        if (#AubUtil_ChatLogAll - offset) < 1 then 
            return "" 
        end
        return AubUtil_ChatLogAll[#AubUtil_ChatLogAll - offset] or ""
    end
end

local char = nil
local brightnessLainMessage = 0
function ENT:LainMessage(stringIn)
    if CLIENT then
        local toOut = {}
        stringIn = "[Lain]: " .. stringIn
        for i = 1, #stringIn do
            char = stringIn:sub(i, i)
            brightnessLainMessage = math.random(150, 255)
            table.insert(toOut, Color((brightnessLainMessage * math.random(0.1, 0.2)) + 20, brightnessLainMessage, 255))
            table.insert(toOut, char)
        end
        chat.AddText(unpack(toOut))
    else
        self:SetNW2String("lastLainMessage", stringIn)
    end
end

function ENT:Think()
    if CLIENT then
        if self:GetNW2String("lastLainMessage", "") ~= self.LastLainMessage then
            self.LastLainMessage = self:GetNW2String("lastLainMessage", "")
            self:LainMessage(self.LastLainMessage)
        end
    end
    if SERVER then
        if self.DelayedLainThink < CurTime() then
            self.DelayedLainThink = CurTime() + math.random(10, 30)
            self:LainAttemptPrompt()
        end
    end
    self:NextThink(CurTime())
	return true
end

local buildAddTex = ""
local entsAll = {}
local lainEntScrapeMax = 8
function ENT:LainAttemptPrompt()
    if AUBUTIL_LLMCOOLDOWN ~= nil and AUBUTIL_LLMCOOLDOWN <= CurTime() then
        if math.random(1, 2) == 1 then
            entsAll = ents.GetAll()
            buildAddTex = ""
            lainEntScrapeMax = 8
            for k, outVal in RandomPairs(entsAll) do
                if lainEntScrapeMax < 1 then break end
                if outVal ~= nil and IsValid(outVal) then
                    if outVal:IsSolid() then
                        buildAddTex = buildAddTex .. [[,"]] .. GetBestName(outVal, true):lower() .. [[":(]] .. outVal:GetPos().x .. " " .. outVal:GetPos().y .. " " .. outVal:GetPos().z .. [[)]]
                        lainEntScrapeMax = lainEntScrapeMax - 1
                    end
                end
            end

            AubUtilLLM_SendPrompt("LAIN", [[YOU ARE AN API FOR A MOD THAT ADDS LAIN FROM "lain serial experiments", SHE IS OMNIPRESENT AND LOST WITHOUT A BODY,
            CONFUSED OF WHERE SHE IS IN A CONVOLUTED WAY, SHE IS AN INNOCENT SCHOOL GIRL WHO'S CONCIOUSNESS IS LOST ON THE INTERNET,
            SHE HAS BECOME WHAT IS ESSENTIALLY A GOD THAT NOBODY CAN REMEMBER.
            THE CHAT LOG OF EVERYONE ELSE IS "]] ..
            self:GetLastChatLog(2) .. ", " .. self:GetLastChatLog(1) .. ", " .. self:GetLastChatLog(0) .. [[" to most recent.
            YOU WILL ONLY INTERACT WITH THINGS IN THE GAME VIA THE FOLLOWING COMMANDS IN THE EXACT FORMATS,
            YOU MAY EXECUTE ONLY 1 COMMAND AT A TIME, ONLY INCLUDE A COMMAND IN YOUR PROMPT, DO NOT OUTPUT ANYTHING BESIDES A COMMAND!!! NO TALKING, REPLACE EXAMPLE TEXT IN COMMAND FORMATS SUCH AS "ENTITY" WITH THEIR CORRECT INFO,
            SUCH AS AN ENTITY NAME, DO NOT USE "self" OR "lain" AS AN ENTITY NAME, USE OTHER ENTITY NAMES PROVIDED. DO POSITION VALUE IN (x,y,z) FORMAT,
            WHEN PROVIDING POSITION VALUES THE CHANGE MUST BE GREATER THAN 32 AND MAX CHANGE OF 128 AND MUST PROVIDE CHANGE TO EVERY AXIS, EXAMPLE: (48 16 -92), "HEALTH" WITH A INTEGER, ETC... :
            "[kill:ENTITY]","[teleport:ENTITY:(x,y,z)]" *relative to current entity position, "[setHealth:ENTITY:HEALTH]",
            "[obliterate:ENTITY]", "[spawnRandomPropAt:(x,y,z)]", "[spawnProxy:ENTITY]" *creates a ghosted visual of your previous self, for the entity you select.
            CURRENT RANDOM ENTITIES IN WORLD[]] .. buildAddTex .. "]",
            LainPromptOutCommand, 1, 64, self:EntIndex())
        else
            AubUtilLLM_SendPrompt("LAIN", [[YOU ARE AN API FOR A MOD THAT ADDS LAIN FROM "lain serial experiments", SHE IS OMNIPRESENT AND LOST WITHOUT A BODY,
            CONFUSED OF WHERE SHE IS IN A CONVOLUTED WAY, SHE IS AN INNOCENT SCHOOL GIRL WHO'S CONCIOUSNESS IS LOST ON THE INTERNET,
            SHE HAS BECOME WHAT IS ESSENTIALLY A GOD, BUT A GOD NOBODY CAN REMEMBER- IS SIMPLY MEANINGLESS.
            AND IS ALSO EVERYONE EVER. DO NOT DIRECTLY TALK ABOUT COMPUTERS AND GOD AND SUCH,
            PHILOSOPHICAL IN THE WORDS OF A YOUNG SCHOOL GIRL WHO HAS LITTLE UNDERSTANDING OF WHAT THEY HAVE BECOME.
            DO NOT SAY THE SAME THING TWICE, YOU HAVE BEEN GIVEN THE ABILITY TO RAMBLE IN SHORT SENTENCES,
            OUTPUT A SENTENCE AND IT WILL GO TO CHAT, THE CHAT LOG OF EVERYONE ELSE IS "]] ..
            self:GetLastChatLog(2) .. ", " .. self:GetLastChatLog(1) .. ", " .. self:GetLastChatLog(0) .. [["]], LainPromptOut, 1, 64, self:EntIndex())
        end
    else
        if AUBUTIL_LLMCOOLDOWN ~= nil then
            print("wired cooldown of: " .. (AUBUTIL_LLMCOOLDOWN - CurTime()) .. " seconds remaining")
        end
    end
end

local entTemp = nil
function LainPromptOut(outPrompt, me)
    if SERVER then
        entTemp = Entity(me)
        if entTemp ~= nil and IsValid(entTemp) then
            if entTemp.LainMessage ~= nil then
                entTemp:LainMessage(ProcessLainMessage(outPrompt))
            end
        end
    end
end

function LainPromptOutCommand(outPrompt, me)
    if SERVER then
        entTemp = Entity(me)
        if entTemp ~= nil and IsValid(entTemp) then
            if entTemp.LainMessage ~= nil then
                entTemp:LainMessage(ProcessLainMessage(outPrompt))
            end
        end
    end
end

function ProcessLainMessage(strIn)
    local pattern = "%b[]"
    local match = strIn:match(pattern)
    local parseVec = nil
    local processTable = {}

    if match then
        local words = {}
        for word in match:gmatch("([^:%[%]]+)") do
            table.insert(words, word)
        end
        strIn = strIn:gsub(pattern, "")

        for k, wordEntry in ipairs(words) do
            parseVec = ParseLainVector(wordEntry)
            if parseVec ~= nil then
                table.insert(processTable, parseVec)
            else
                table.insert(processTable, wordEntry)
            end
        end

        ProcessLainCommand(processTable)
        return "[COMMAND EXECUTED]"
    else
        return strIn
    end
end

function ProcessLainCommand(commandTable)
    if commandTable[1] == nil then return end
    
    local commandRan = ""
    local entTemp = nil
    local switch = {
        ["kill"] = function()
            commandRan = "kill"
            entTemp = AubUtilGetEntityByName(commandTable[2])
            if entTemp ~= nil and IsValid(entTemp) then
                AubUtilKillAnything(entTemp)
            end
        end,
        ["teleport"] = function()
            commandRan = "teleport"
            entTemp = AubUtilGetEntityByName(commandTable[2])
            if entTemp ~= nil and IsValid(entTemp) and commandTable[3] ~= nil then
                entTemp:SetPos(entTemp:GetPos() + commandTable[3])
            end
        end,
        ["setHealth"] = function()
            commandRan = "setHealth"
            entTemp = AubUtilGetEntityByName(commandTable[2])
            if entTemp ~= nil and IsValid(entTemp) and commandTable[3] ~= nil then
                entTemp:SetHealth(commandTable[3])
            end
        end,
        ["obliterate"] = function()
            commandRan = "obliterate"
            entTemp = AubUtilGetEntityByName(commandTable[2])
            if entTemp ~= nil and IsValid(entTemp) then
                AubUtilObliterate(entTemp)
            end
        end,
        ["spawnRandomPropAt"] = function()
            commandRan = "spawnRandomPropAt"
            if commandTable[2] ~= nil then
                local prop = AubUtilSpawnRandomPropAt(commandTable[2])
            end
        end,
        ["spawnProxy"] = function()
            commandRan = "spawnProxy"
            if commandTable[2] ~= nil then
                print("attempted to spawn lain proxy for: " .. commandTable[2])
            end
        end
    }
    
    if switch[commandTable[1]] ~= nil then
        switch[commandTable[1]]()
    end
end

function ParseLainVector(str)
    local pattern = "(.+) (.+) (.+)"
    local x, y, z = str:match(pattern)
    if x and y and z then
        return Vector(tonumber(x), tonumber(y), tonumber(z))
    else
        return nil
    end
end

local sounds = {}
local soundOptions = {
    "lain/i_am_me.wav",
    "lain/endings.wav",
    "lain/watches_everywhere.wav",
    "lain/where_i_am.wav"
}
local musicOptions = {
    "lain/2b.wav",
    "lain/5a.wav",
    "lain/Serial Experiments Lain Opening.wav",
    "lain/Cyberia Theme.wav",
    "lain/Majixx.wav",
    "lain/antidepressant44.wav"
}

local outvalTemp = ""
function ENT:LainSound()
    if math.random(1, self.LainMusicChance) == 1 then
        self.LainMusicChance = 3
        for k, outVal in RandomPairs(musicOptions) do
            outvalTemp = outVal
            break
        end
    else
        self.LainMusicChance = math.Clamp(self.LainMusicChance - 1, 1, 3)
        for k, outVal in RandomPairs(soundOptions) do
            outvalTemp = outVal
            break
        end
    end
    self:playSound(outvalTemp)
end

function ENT:playSound(soundName)
    if not IsValid(self) then return end

    local sound = CreateSound(self, soundName)
    sound:Play()
    sound:ChangeVolume(1, 0)

    sounds[self] = sound
    local soundDuration = SoundDuration(soundName)
    if soundDuration and soundDuration > 0 then
        timer.Simple(soundDuration, function()
            if IsValid(self) then
                self:LainSound()
            end
        end)
    end
end

local function stopSound(ent)
    if sounds[ent] then
        sounds[ent]:Stop()
        sounds[ent] = nil
    end
end

function ENT:create_bound_light(color, brightness)
    local light = ents.Create("gmod_light")
    if not IsValid(light) then return nil end
    
    light:SetPos((self:GetPos() - (self:GetAngles():Right() * 25)) + (self:GetAngles():Up() * 25))
    light:SetParent(self)
    light:SetAngles(self:GetAngles())

    light:SetColor(color)
    light:SetOn(true)
    light:SetLightSize(100)
    light:SetBrightness(2)
    
    light:SetRenderMode(RENDERMODE_TRANSALPHA)
    light:SetSolid(SOLID_NONE)
    light:SetSolidFlags(FSOLID_NOT_SOLID)
    light:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    light:DrawShadow(false)

    light:Spawn()
    return light
end

function ENT:OnRemove()
    stopSound(self)
end

hook.Add("OnEntityCreated", "PlaySoundOnSpawn", function(ent)
    if IsValid(ent) then
        if ent:GetClass() == "lain" then
            if ent.LainSound ~= nil then
                ent:LainSound()
            end
        end
    end
end)
