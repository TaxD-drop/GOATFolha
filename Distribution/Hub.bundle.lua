-- GENERATED FILE. Edit Config.lua/HubClient and run tools/build_bundle.py.
-- This bundle, not an editable module, is the executor deployment artifact.

local __config = (function()
    -- Contrato revisavel do GOATFolha Hub. Regenere o bundle apos alterar.
    -- Os IDs 0 bloqueiam a inicializacao de proposito ate serem confirmados.

    return table.freeze({
        IDENTITY = table.freeze({
            NAME = "GOATFolha Hub",
            GUI_NAME = "GOATFolhaHub",
            GLOBAL_APP_KEY = "__GOATFOLHA_HUB_APP",
            GLOBAL_STATE_KEY = "__GOATFOLHA_HUB_STATE_V1",
            TELEPORT_STATE_KEY = "GOATFolhaHub_State_v1",
            SETTINGS_DIRECTORY = "GOATHub",
        }),

        GAME_ID = 10518836988,
        PLACE_IDS = table.freeze({ 89907728898683 }),
        UI_STYLE = "Modern",

        ICON = table.freeze({
            -- Substitua por uma URL raw fixa quando o repositorio de deploy existir.
            URL = "https://raw.githubusercontent.com/TaxD-drop/GOATFolha/refs/heads/main/UI/Ico/logo.png",
            CACHE_DIRECTORY = "GOATHub/UI/Ico",
            CACHE_FILE = "logo.png",
            MAX_BYTES = 512 * 1024,
        }),

        UI = table.freeze({
            TITLE = "GOAT Hub — Folha",
            PADDING = 6,
            DESKTOP_WIDTH = 380,
            DESKTOP_HEIGHT = 600,
            COMPACT_WIDTH = 350,
            COMPACT_BREAKPOINT = 520,
            NARROW_BREAKPOINT = 620,
        }),

        MODERN_UI = table.freeze({
            TITLE = "GOAT Hub — Folha",
            SUBTITLE = "LEAF AUTOMATION  /  CLIENT HUB",
            PADDING = 6,
            DESKTOP_WIDTH = 660,
            DESKTOP_HEIGHT = 520,
            COMPACT_WIDTH = 570,
            COMPACT_BREAKPOINT = 520,
            NARROW_BREAKPOINT = 620,
            MIN_WIDTH = 300,
            DEFAULT_SCALE_PERCENT = 100,
            DEFAULT_THEME = "Dark",
            HEADER_HEIGHT = 54,
            COMPACT_HEADER_HEIGHT = 48,
            TAB_HEIGHT = 44,
        }),

        FEATURES = table.freeze({
            COLLECT_BATCH_SIZE = 25,
            SELL_AT_CAPACITY_RATIO = 1,
            UPGRADE_ORDER = table.freeze({
                "Capacity",
                "Yield",
                "Cooldown",
                "RakeSpeed",
                "RakeArea",
                "RakeRange",
                "BlowerRange",
                "BlowerRadius",
                "BlowerCooldown",
            }),
        }),

        TIMING = table.freeze({
            COLLECT_POLL = 0.20,
            SELL_POLL = 0.50,
            SELL_CONFIRM_TIMEOUT = 2,
            SELL_RETRY_DELAY = 1,
            UPGRADE_POLL = 0.50,
            UPGRADE_CONFIRM_TIMEOUT = 2,
            REBIRTH_POLL = 1,
            REBIRTH_CONFIRM_TIMEOUT = 5,
        }),
    })
end)()

local function __validId(value)
    return typeof(value) == "number" and value > 0 and value % 1 == 0
end

if not __validId(__config.GAME_ID) then
    warn("[GOATHub] Configure GAME_ID e regenere o bundle.")
    return
end
if game.GameId ~= __config.GAME_ID then
    return
end

local __hasConfiguredPlace = false
local __placeAllowed = false
for _, placeId in ipairs(__config.PLACE_IDS) do
    if __validId(placeId) then
        __hasConfiguredPlace = true
        if game.PlaceId == placeId then
            __placeAllowed = true
        end
    end
end
if not __hasConfiguredPlace then
    warn("[GOATHub] Configure PLACE_IDS e regenere o bundle.")
    return
end
if not __placeAllowed then
    return
end

local __factories = {}
local __cache = { Config = __config }
local __require

__factories["Core/ExecutorSettings"] = function()
    local HttpService = game:GetService("HttpService")

    local Config = __require("Config")
    local Theme = __require("Core/Theme")

    local ExecutorSettings = {}
    ExecutorSettings.__index = ExecutorSettings

    local configuredDirectory = Config.IDENTITY.SETTINGS_DIRECTORY
    local DIRECTORY = if typeof(configuredDirectory) == "string"
            and string.match(configuredDirectory, "^[%w_-]+$")
        then configuredDirectory
        else "GOATHub"
    local FILE_PATH = DIRECTORY .. "/settings.json"
    local FILE_VERSION = 4
    local MAX_FILE_BYTES = 4096
    local ICON_CACHE_PATH = "GOATHub/UI/Ico/logo.png"
    local SCALE_PERCENTAGES = {
        [25] = true,
        [50] = true,
        [75] = true,
        [100] = true,
        [125] = true,
        [150] = true,
    }
    local LEGACY_WIDTH_PERCENTAGES = {
        [25] = true,
        [50] = true,
        [75] = true,
        [100] = true,
    }

    local function validScalePercent(value)
        return typeof(value) == "number"
            and value % 1 == 0
            and SCALE_PERCENTAGES[value] == true
    end

    local function configuredIconUrl()
        local icon = Config.ICON
        local url = typeof(icon) == "table" and icon.URL or ""
        if typeof(url) == "string"
            and #url <= 512
            and url:match("^https://raw%.githubusercontent%.com/")
            and url:match("%.png$") then
            return url
        end
        return ""
    end

    function ExecutorSettings.new()
        local defaultScale = Config.MODERN_UI.DEFAULT_SCALE_PERCENT
        if not validScalePercent(defaultScale) then
            defaultScale = 100
        end

        local self = setmetatable({
            scalePercent = defaultScale,
            iconUrl = configuredIconUrl(),
            themeName = Theme.normalizeName(Config.MODERN_UI.DEFAULT_THEME),
            customTheme = Theme.defaultCustom(),
            migrationNeeded = false,
            persistent = typeof(writefile) == "function" and typeof(makefolder) == "function",
            loaded = false,
        }, ExecutorSettings)
        self.loaded = self:_load()
        if (not self.loaded or self.migrationNeeded) and self.persistent then
            self:_save()
        end
        return self
    end

    function ExecutorSettings:_ensureDirectory()
        if typeof(makefolder) ~= "function" then
            return false
        end
        if typeof(isfolder) == "function" then
            local checked, exists = pcall(isfolder, DIRECTORY)
            if checked and exists then
                return true
            end
        end
        return pcall(makefolder, DIRECTORY)
    end

    function ExecutorSettings:_load()
        if typeof(readfile) ~= "function" then
            return false
        end
        local readOk, source = pcall(readfile, FILE_PATH)
        if not readOk or typeof(source) ~= "string" or #source == 0 or #source > MAX_FILE_BYTES then
            return false
        end

        local decodedOk, decoded = pcall(function()
            return HttpService:JSONDecode(source)
        end)
        if not decodedOk
            or typeof(decoded) ~= "table"
            or (decoded.version ~= 1
                and decoded.version ~= 2
                and decoded.version ~= 3
                and decoded.version ~= FILE_VERSION)
            or typeof(decoded.ui) ~= "table"
        then
            return false
        end
        if decoded.version == FILE_VERSION then
            if not validScalePercent(decoded.ui.scalePercent) then
                return false
            end
            self.scalePercent = decoded.ui.scalePercent
        elseif typeof(decoded.ui.widthPercent) ~= "number"
            or LEGACY_WIDTH_PERCENTAGES[decoded.ui.widthPercent] ~= true then
            return false
        end
        local validStoredTheme = false
        if decoded.version >= 3 and typeof(decoded.theme) == "table" then
            self.themeName = Theme.normalizeName(decoded.theme.name)
            self.customTheme = Theme.normalizeCustom(decoded.theme.custom)
            validStoredTheme = decoded.theme.name == self.themeName
                and typeof(decoded.theme.custom) == "table"
            if validStoredTheme then
                for _, key in ipairs(Theme.KEYS) do
                    if decoded.theme.custom[key] ~= self.customTheme[key] then
                        validStoredTheme = false
                        break
                    end
                end
            end
        end
        if decoded.version == FILE_VERSION
            and typeof(decoded.icon) == "table"
            and decoded.icon.url == self.iconUrl
            and decoded.icon.cachePath == ICON_CACHE_PATH
            and validStoredTheme then
            self.migrationNeeded = false
        else
            self.migrationNeeded = true
        end
        return true
    end

    function ExecutorSettings:_save()
        if not self.persistent or not self:_ensureDirectory() then
            return false
        end
        local encodedOk, encoded = pcall(function()
            return HttpService:JSONEncode({
                version = FILE_VERSION,
                ui = {
                    scalePercent = self.scalePercent,
                },
                icon = {
                    url = self.iconUrl,
                    cachePath = ICON_CACHE_PATH,
                },
                theme = {
                    name = self.themeName,
                    custom = self.customTheme,
                },
            })
        end)
        if not encodedOk or typeof(encoded) ~= "string" or #encoded > MAX_FILE_BYTES then
            return false
        end
        return pcall(writefile, FILE_PATH, encoded)
    end

    function ExecutorSettings:getScalePercent()
        return self.scalePercent
    end

    function ExecutorSettings:getIcon()
        return {
            url = self.iconUrl,
            cachePath = ICON_CACHE_PATH,
        }
    end

    function ExecutorSettings:setScalePercent(value)
        value = tonumber(value)
        if not validScalePercent(value) then
            return false
        end
        self.scalePercent = value
        return self:_save()
    end

    ExecutorSettings.getWidthPercent = ExecutorSettings.getScalePercent
    ExecutorSettings.setWidthPercent = ExecutorSettings.setScalePercent

    function ExecutorSettings:getTheme()
        return {
            name = self.themeName,
            custom = Theme.normalizeCustom(self.customTheme),
        }
    end

    function ExecutorSettings:setTheme(name)
        if Theme.normalizeName(name) ~= name then
            return false
        end
        self.themeName = name
        return self:_save()
    end

    function ExecutorSettings:setThemeColor(key, value)
        local known = false
        for _, candidate in ipairs(Theme.KEYS) do
            if candidate == key then
                known = true
                break
            end
        end
        local normalized = Theme.normalizeHex(value)
        if not known or not normalized then
            return false
        end
        self.customTheme[key] = normalized
        return self:_save()
    end

    function ExecutorSettings:isPersistent()
        return self.persistent
    end

    function ExecutorSettings:getPath()
        return FILE_PATH
    end

    return ExecutorSettings
end

__factories["Core/IconCache"] = function()
    -- GitHub PNG -> cache fixo do executor -> URI para ImageLabel.

    local Config = __require("Config")

    local IconCache = {}

    local CACHE_DIRECTORY = "GOATHub/UI/Ico"
    local CACHE_PATH = CACHE_DIRECTORY .. "/logo.png"
    local MAX_BYTES = 512 * 1024
    local attempted = false
    local cachedAsset = nil
    local lastFailure = nil

    local function validPng(source)
        return typeof(source) == "string"
            and #source >= 8
            and #source <= MAX_BYTES
            and source:sub(1, 8) == "\137PNG\13\10\26\10"
    end

    local function ensureCacheDirectory()
        if typeof(makefolder) ~= "function" then
            return false
        end
        for _, directory in ipairs({ "GOATHub", "GOATHub/UI", CACHE_DIRECTORY }) do
            local exists = false
            if typeof(isfolder) == "function" then
                local checked, value = pcall(isfolder, directory)
                exists = checked and value == true
            end
            if not exists and not pcall(makefolder, directory) then
                return false
            end
        end
        return true
    end

    local function readCachedPng()
        if typeof(readfile) ~= "function" then
            return nil
        end
        if typeof(isfile) == "function" then
            local checked, exists = pcall(isfile, CACHE_PATH)
            if not checked or not exists then
                return nil
            end
        end
        local readOk, source = pcall(readfile, CACHE_PATH)
        return if readOk and validPng(source) then source else nil
    end

    local function configuredUrl(options)
        local iconConfig = Config.ICON
        local url = typeof(options) == "table" and options.url
            or (typeof(iconConfig) == "table" and iconConfig.URL or nil)
        if typeof(url) ~= "string"
            or not url:match("^https://raw%.githubusercontent%.com/")
            or url:find("OWNER/REPOSITORY/COMMIT", 1, true)
        then
            return nil
        end
        return url
    end

    local function downloadPng(url)
        if not url then
            return nil
        end
        local downloaded, source = pcall(function()
            return game:HttpGet(url)
        end)
        return if downloaded and validPng(source) then source else nil
    end

    local function localAssetLoader()
        if typeof(getcustomasset) == "function" then
            return getcustomasset
        end
        if typeof(getsynasset) == "function" then
            return getsynasset
        end
        if typeof(getexecutorasset) == "function" then
            return getexecutorasset
        end
        local env = if typeof(getgenv) == "function" then getgenv() else _G
        if typeof(env) == "table" then
            for _, name in ipairs({ "getcustomasset", "getsynasset", "getexecutorasset" }) do
                if typeof(env[name]) == "function" then
                    return env[name]
                end
            end
        end
        if typeof(syn) == "table" and typeof(syn.getcustomasset) == "function" then
            return syn.getcustomasset
        end
        return nil
    end

    function IconCache.getAsset(options)
        if attempted then
            return cachedAsset, lastFailure
        end
        attempted = true

        local png = readCachedPng()
        if not png then
            png = downloadPng(configuredUrl(options))
            if not png or not ensureCacheDirectory() or typeof(writefile) ~= "function" then
                lastFailure = "download ou filesystem indisponivel"
                return nil, lastFailure
            end
            if not pcall(writefile, CACHE_PATH, png) then
                lastFailure = "nao foi possivel salvar " .. CACHE_PATH
                return nil, lastFailure
            end
        end

        local loader = localAssetLoader()
        if not loader then
            lastFailure = "executor sem getcustomasset/getsynasset/getexecutorasset"
            return nil, lastFailure
        end
        local loaded, asset = pcall(loader, CACHE_PATH)
        if loaded and typeof(asset) == "string" and asset ~= "" then
            cachedAsset = asset
            lastFailure = nil
        else
            lastFailure = "API de asset rejeitou " .. CACHE_PATH .. ": " .. tostring(asset)
        end
        return cachedAsset, lastFailure
    end

    function IconCache.loadAsync(options, callback)
        task.spawn(function()
            local asset, failure = IconCache.getAsset(options)
            if typeof(callback) == "function" then
                callback(asset, failure)
            end
        end)
    end

    return IconCache
end

__factories["Core/StateStore"] = function()
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")

    local StateStore = {}
    StateStore.__index = StateStore

    local Config = __require("Config")

    local TELEPORT_KEY = Config.IDENTITY.TELEPORT_STATE_KEY
    local GLOBAL_KEY = Config.IDENTITY.GLOBAL_STATE_KEY
    local MAX_STATE_BYTES = 16384

    local function environment()
        if typeof(getgenv) == "function" then
            return getgenv()
        end
        return _G
    end

    local function copySupported(source)
        local result = {}
        if typeof(source) ~= "table" then
            return result
        end
        for key, value in pairs(source) do
            local valueType = typeof(value)
            if typeof(key) == "string"
                and (valueType == "boolean" or valueType == "number" or valueType == "string")
            then
                result[key] = value
            end
        end
        return result
    end

    function StateStore.new()
        local env = environment()
        local values = nil
        local ok, stored = pcall(function()
            return TeleportService:GetTeleportSetting(TELEPORT_KEY)
        end)
        if ok
            and typeof(stored) == "string"
            and stored ~= ""
            and #stored <= MAX_STATE_BYTES
        then
            local decodedOk, decoded = pcall(function()
                return HttpService:JSONDecode(stored)
            end)
            if decodedOk then
                values = decoded
            end
        elseif ok and typeof(stored) == "table" then
            values = stored
        end
        if typeof(values) ~= "table" then
            values = env[GLOBAL_KEY]
        end

        local self = setmetatable({
            values = copySupported(values),
            env = env,
        }, StateStore)
        self.env[GLOBAL_KEY] = self.values
        return self
    end

    function StateStore:_save()
        self.env[GLOBAL_KEY] = self.values
        local ok, encoded = pcall(function()
            return HttpService:JSONEncode(self.values)
        end)
        if ok and typeof(encoded) == "string" and #encoded <= MAX_STATE_BYTES then
            pcall(function()
                TeleportService:SetTeleportSetting(TELEPORT_KEY, encoded)
            end)
        end
    end

    function StateStore:getBoolean(key, defaultValue)
        local value = self.values[key]
        if typeof(value) == "boolean" then
            return value
        end
        return defaultValue == true
    end

    function StateStore:has(key)
        return self.values[key] ~= nil
    end

    function StateStore:getNumber(key, defaultValue, minimum, maximum)
        local value = tonumber(self.values[key]) or tonumber(defaultValue) or 0
        if minimum ~= nil and maximum ~= nil then
            value = math.clamp(value, minimum, maximum)
        end
        return value
    end

    function StateStore:setBoolean(key, value)
        value = value == true
        if self.values[key] == value then
            return
        end
        self.values[key] = value
        self:_save()
    end

    function StateStore:setNumber(key, value, minimum, maximum)
        value = tonumber(value) or 0
        if minimum ~= nil and maximum ~= nil then
            value = math.clamp(value, minimum, maximum)
        end
        if self.values[key] == value then
            return
        end
        self.values[key] = value
        self:_save()
    end

    function StateStore:remove(key)
        if self.values[key] == nil then
            return
        end
        self.values[key] = nil
        self:_save()
    end

    function StateStore:flush()
        self:_save()
    end

    return StateStore
end

__factories["Core/Theme"] = function()
    local Theme = {}

    Theme.DEFAULT_NAME = "Dark"
    Theme.KEYS = table.freeze({
        "background",
        "panel",
        "header",
        "surface",
        "card",
        "cardHover",
        "text",
        "muted",
        "accent",
        "accentBright",
        "green",
        "red",
        "border",
        "track",
    })

    Theme.LABELS = table.freeze({
        background = "Fundo e barra de status",
        panel = "Painel principal",
        header = "Barra superior",
        surface = "Navegacao e superficies",
        card = "Cards",
        cardHover = "Cards ao tocar/passar",
        text = "Texto principal",
        muted = "Texto secundario",
        accent = "Destaque",
        accentBright = "Destaque claro",
        green = "Sucesso",
        red = "Perigo",
        border = "Bordas",
        track = "Trilhos e controles",
    })

    local PRESETS = {
        Dark = {
            background = "#030303",
            panel = "#090909",
            header = "#101010",
            surface = "#151515",
            card = "#1B1B1B",
            cardHover = "#272727",
            text = "#F5F5F5",
            muted = "#9A9A9A",
            accent = "#686868",
            accentBright = "#D4D4D4",
            green = "#3ED38F",
            red = "#F45B69",
            border = "#303030",
            track = "#3A3A3A",
        },
        Light = {
            background = "#E9EEF6",
            panel = "#F7F9FC",
            header = "#FFFFFF",
            surface = "#E7EDF7",
            card = "#FFFFFF",
            cardHover = "#DDE6F3",
            text = "#172033",
            muted = "#66738C",
            accent = "#4F6BED",
            accentBright = "#2997D6",
            green = "#249B68",
            red = "#D94354",
            border = "#C4D0E1",
            track = "#C9D3E2",
        },
        Custom = {
            background = "#071306",
            panel = "#0C2109",
            header = "#0B190A",
            surface = "#163710",
            card = "#245F15",
            cardHover = "#2F7A1C",
            text = "#F4FFF1",
            muted = "#A8C79F",
            accent = "#51C925",
            accentBright = "#8BEA5D",
            green = "#53E39A",
            red = "#FF6574",
            border = "#3F7432",
            track = "#325528",
        },
    }

    function Theme.normalizeName(value)
        if value == "Dark" or value == "Light" or value == "Custom" then
            return value
        end
        return Theme.DEFAULT_NAME
    end

    function Theme.normalizeHex(value)
        if typeof(value) ~= "string" then
            return nil
        end
        local normalized = string.upper(value)
        if normalized:match("^#%x%x%x%x%x%x$") then
            return normalized
        end
        return nil
    end

    local function copyPalette(source)
        local copy = {}
        for _, key in ipairs(Theme.KEYS) do
            copy[key] = source[key]
        end
        return copy
    end

    function Theme.defaultCustom()
        return copyPalette(PRESETS.Custom)
    end

    function Theme.normalizeCustom(source)
        source = typeof(source) == "table" and source or {}
        local result = Theme.defaultCustom()
        for _, key in ipairs(Theme.KEYS) do
            result[key] = Theme.normalizeHex(source[key]) or result[key]
        end
        return result
    end

    function Theme.resolveHex(name, custom)
        name = Theme.normalizeName(name)
        if name == "Custom" then
            return Theme.normalizeCustom(custom)
        end
        return copyPalette(PRESETS[name])
    end

    function Theme.toColor3(hex)
        local normalized = Theme.normalizeHex(hex) or "#000000"
        return Color3.fromRGB(
            tonumber(normalized:sub(2, 3), 16),
            tonumber(normalized:sub(4, 5), 16),
            tonumber(normalized:sub(6, 7), 16)
        )
    end

    function Theme.fromColor3(color)
        if typeof(color) ~= "Color3" then
            return "#000000"
        end
        return string.format(
            "#%02X%02X%02X",
            math.clamp(math.floor(color.R * 255 + 0.5), 0, 255),
            math.clamp(math.floor(color.G * 255 + 0.5), 0, 255),
            math.clamp(math.floor(color.B * 255 + 0.5), 0, 255)
        )
    end

    function Theme.hexToHSV(hex)
        return Theme.toColor3(hex):ToHSV()
    end

    function Theme.hsvToHex(hue, saturation, value)
        return Theme.fromColor3(Color3.fromHSV(
            math.clamp(tonumber(hue) or 0, 0, 1),
            math.clamp(tonumber(saturation) or 0, 0, 1),
            math.clamp(tonumber(value) or 0, 0, 1)
        ))
    end

    function Theme.resolveColors(name, custom)
        local colors = {}
        for key, hex in pairs(Theme.resolveHex(name, custom)) do
            colors[key] = Theme.toColor3(hex)
        end
        return colors
    end

    return Theme
end

__factories["Features/AutoCollect"] = function()
    local Config = __require("Config")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local AutoCollect = {}
    AutoCollect.__index = AutoCollect

    local REBIRTH_UNLOCKS = {
        Playground = 5,
        Skatepark = 10,
        Court = 25,
    }

    local function valueOf(parent, name, fallback)
        local object = parent and parent:FindFirstChild(name)
        return object and object.Value or fallback
    end

    function AutoCollect.new(onStatus)
        return setmetatable({
            enabled = false,
            generation = 0,
            onStatus = onStatus or function() end,
        }, AutoCollect)
    end

    function AutoCollect:_areaUnlocked(player, areaName)
        local requiredRebirth = REBIRTH_UNLOCKS[areaName]
        if not requiredRebirth then
            return true
        end

        local hiddenData = player:FindFirstChild("HiddenData")
        local unlockedDoors = hiddenData and hiddenData:FindFirstChild("UnlockedDoors")
        if unlockedDoors and unlockedDoors:FindFirstChild(areaName) then
            return true
        end

        local leaderstats = player:FindFirstChild("leaderstats")
        return valueOf(leaderstats, "Rebirth", 0) >= requiredRebirth
    end

    function AutoCollect:_collectBatch(player, leafData, remote)
        local playerData = player:FindFirstChild("PlayerData")
        if not playerData or player:GetAttribute("IsSelling") then
            return 0
        end

        local leavesHeld = valueOf(playerData, "Leaves", 0)
        local maxHold = valueOf(playerData, "MaxHold", 0)
        local infiniteExpiry = valueOf(playerData, "InfiniteCapacityExpiry", 0)
        local remaining = if infiniteExpiry > os.time() then math.huge else math.max(0, maxHold - leavesHeld)
        if remaining <= 0 then
            return 0
        end

        local luckChance = math.max(0, valueOf(playerData, "RealLuckChance", 0)
            + valueOf(playerData, "BasementLuckyBonus", 0))
        local limit = math.min(Config.FEATURES.COLLECT_BATCH_SIZE, remaining)
        local batch = {}
        local indexes = {}

        for index, leaf in ipairs(leafData.leaves) do
            if #batch >= limit then
                break
            end
            if not leaf.pickedUp and leaf.cframe and self:_areaUnlocked(player, leaf.areaName) then
                table.insert(batch, {
                    AreaName = leaf.areaName or "Unknown",
                    IsLucky = math.random() <= luckChance,
                    LeafIndex = index,
                    Position = leaf.cframe.Position,
                })
                table.insert(indexes, index)
            end
        end

        if #batch == 0 then
            return 0
        end

        remote:FireServer(batch)
        for _, index in ipairs(indexes) do
            leafData.MarkPickedUp(index)
        end
        return #batch
    end

    function AutoCollect:_run(generation)
        local player = Players.LocalPlayer
        local modules = ReplicatedStorage:WaitForChild("Modules", 10)
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        local leafDataModule = modules and modules:WaitForChild("LeafData", 10)
        local remote = remotes and remotes:WaitForChild("LeafPickedUp", 10)
        if not leafDataModule or not remote or not remote:IsA("RemoteEvent") then
            self.onStatus("Coleta: dependencias ausentes")
            self:setEnabled(false)
            return
        end

        local leafData = require(leafDataModule)
        self.onStatus("Auto Collect ativo")
        while self.enabled and self.generation == generation do
            local ok, result = pcall(function()
                return self:_collectBatch(player, leafData, remote)
            end)
            if not ok then
                self.onStatus("Coleta falhou: " .. tostring(result))
            elseif result > 0 then
                self.onStatus("Coletadas " .. tostring(result) .. " folhas")
            end
            task.wait(Config.TIMING.COLLECT_POLL)
        end
    end

    function AutoCollect:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then return end
        self.enabled = enabled
        self.generation += 1
        if enabled then
            local generation = self.generation
            task.spawn(function() self:_run(generation) end)
        else
            self.onStatus("Auto Collect desativado")
        end
    end

    function AutoCollect:stop()
        self:setEnabled(false)
    end

    return AutoCollect
end

__factories["Features/AutoRebirth"] = function()
    local Config = __require("Config")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Workspace = game:GetService("Workspace")

    local AutoRebirth = {}
    AutoRebirth.__index = AutoRebirth

    local function valueOf(parent, name, fallback)
        local object = parent and parent:FindFirstChild(name)
        return object and object.Value or fallback
    end

    local function maxCapacityReady(player)
        local leaderstats = player:FindFirstChild("leaderstats")
        local playerData = player:FindFirstChild("PlayerData")
        local levels = playerData and playerData:FindFirstChild("UpgradeLevels")
        if valueOf(levels, "CapacityLevel", 0) < 5 then return false end
        if valueOf(leaderstats, "Rebirth", 0) < 1 then return true end
        return valueOf(levels, "BasementCapacityLevel", 0) >= 4
    end

    local function plotReady(player)
        local hiddenData = player:FindFirstChild("HiddenData")
        if valueOf(hiddenData, "HasClearedPlotThisRebirth", false) == true then
            return true
        end
        local saved = hiddenData and hiddenData:FindFirstChild("SavedLeafCounts")
        local areas = Workspace:FindFirstChild("Areas")
        if not saved or not areas then return false end

        local rebirth = valueOf(player:FindFirstChild("leaderstats"), "Rebirth", 0)
        local total, remaining = 0, 0
        for _, area in ipairs(areas:GetChildren()) do
            local unlocked = (area.Name ~= "Playground" or rebirth >= 5)
                and (area.Name ~= "Skatepark" or rebirth >= 10)
                and (area.Name ~= "Court" or rebirth >= 25)
            if area:IsA("Folder") and unlocked then
                local amount = area:GetAttribute("LeafAmount") or 50
                total += amount
                remaining += valueOf(saved, area.Name, amount)
            end
        end
        return total > 0 and (total - remaining) / total >= 0.999
    end

    function AutoRebirth.new(onStatus)
        return setmetatable({
            enabled = false,
            generation = 0,
            onStatus = onStatus or function() end,
        }, AutoRebirth)
    end

    function AutoRebirth:_run(generation)
        local player = Players.LocalPlayer
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        local remote = remotes and remotes:WaitForChild("RebirthEvent", 10)
        if not remote or not remote:IsA("RemoteEvent") then
            self.onStatus("Rebirth: remote ausente")
            self:setEnabled(false)
            return
        end

        self.onStatus("Auto Rebirth ativo")
        while self.enabled and self.generation == generation do
            if maxCapacityReady(player) and plotReady(player) then
                local leaderstats = player:FindFirstChild("leaderstats")
                local before = valueOf(leaderstats, "Rebirth", 0)
                remote:FireServer()
                local deadline = os.clock() + Config.TIMING.REBIRTH_CONFIRM_TIMEOUT
                repeat
                    task.wait(0.1)
                until not self.enabled or self.generation ~= generation
                    or valueOf(leaderstats, "Rebirth", 0) > before or os.clock() >= deadline
                if valueOf(leaderstats, "Rebirth", 0) > before then
                    self.onStatus("Rebirth confirmado")
                end
            end
            task.wait(Config.TIMING.REBIRTH_POLL)
        end
    end

    function AutoRebirth:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then return end
        self.enabled = enabled
        self.generation += 1
        if enabled then
            local generation = self.generation
            task.spawn(function() self:_run(generation) end)
        else
            self.onStatus("Auto Rebirth desativado")
        end
    end

    function AutoRebirth:stop()
        self:setEnabled(false)
    end

    return AutoRebirth
end

__factories["Features/AutoSell"] = function()
    local Config = __require("Config")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local AutoSell = {}
    AutoSell.__index = AutoSell

    local function valueOf(parent, name, fallback)
        local object = parent and parent:FindFirstChild(name)
        return object and object.Value or fallback
    end

    function AutoSell.new(onStatus)
        return setmetatable({
            enabled = false,
            generation = 0,
            onStatus = onStatus or function() end,
        }, AutoSell)
    end

    function AutoSell:_shouldSell(player)
        local playerData = player:FindFirstChild("PlayerData")
        local leaves = valueOf(playerData, "Leaves", 0)
        local maxHold = valueOf(playerData, "MaxHold", 0)
        return leaves > 0 and maxHold > 0
            and leaves >= maxHold * Config.FEATURES.SELL_AT_CAPACITY_RATIO
    end

    function AutoSell:_requestSell(player, remote, generation)
        local playerData = player:FindFirstChild("PlayerData")
        local leavesBefore = valueOf(playerData, "Leaves", 0)

        -- Nos oito ciclos capturados, SellVisuals encerra a venda com math.huge.
        -- Usar somente esse marcador evita inventar os valores parciais calculados
        -- a partir dos oito argumentos que o servidor envia ao cliente.
        remote:FireServer(math.huge)

        local deadline = os.clock() + Config.TIMING.SELL_CONFIRM_TIMEOUT
        repeat
            task.wait(0.1)
            local leavesNow = valueOf(playerData, "Leaves", 0)
            if leavesNow < leavesBefore then
                self.onStatus("Auto Sell: venda confirmada")
                return true
            end
        until not self.enabled or self.generation ~= generation or os.clock() >= deadline

        if self.enabled and self.generation == generation then
            self.onStatus("Auto Sell: servidor nao confirmou")
        end
        return false
    end

    function AutoSell:_run(generation)
        local player = Players.LocalPlayer
        local remote = ReplicatedStorage:WaitForChild("SellLeavesEvent", 10)
        if not remote or not remote:IsA("RemoteEvent") then
            self.onStatus("Venda: SellLeavesEvent ausente")
            self:setEnabled(false)
            return
        end

        self.onStatus("Auto Sell remoto ativo")
        while self.enabled and self.generation == generation do
            if self:_shouldSell(player) then
                local ok, result = pcall(function()
                    return self:_requestSell(player, remote, generation)
                end)
                if not ok then
                    self.onStatus("Venda falhou: " .. tostring(result))
                end
                task.wait(Config.TIMING.SELL_RETRY_DELAY)
            else
                task.wait(Config.TIMING.SELL_POLL)
            end
        end
    end

    function AutoSell:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then return end
        self.enabled = enabled
        self.generation += 1
        if enabled then
            local generation = self.generation
            task.spawn(function() self:_run(generation) end)
        else
            self.onStatus("Auto Sell desativado")
        end
    end

    function AutoSell:stop()
        self:setEnabled(false)
    end

    return AutoSell
end

__factories["Features/AutoUpgrade"] = function()
    local Config = __require("Config")

    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local AutoUpgrade = {}
    AutoUpgrade.__index = AutoUpgrade

    local TOOL_REQUIREMENTS = {
        RakeSpeed = "hasRake",
        RakeArea = "hasRake",
        RakeRange = "hasRake",
        BlowerRange = "hasLeafblower",
        BlowerRadius = "hasLeafblower",
        BlowerCooldown = "hasLeafblower",
    }

    local function valueOf(parent, name, fallback)
        local object = parent and parent:FindFirstChild(name)
        return object and object.Value or fallback
    end

    local function isUnlocked(playerData, upgradeName)
        local requirement = TOOL_REQUIREMENTS[upgradeName]
        return not requirement or valueOf(playerData, requirement, false) == true
    end

    function AutoUpgrade.new(onStatus)
        return setmetatable({
            enabled = false,
            generation = 0,
            onStatus = onStatus or function() end,
        }, AutoUpgrade)
    end


    function AutoUpgrade:_findCheapest(player, manager)
        local playerData = player:FindFirstChild("PlayerData")
        local levels = playerData and playerData:FindFirstChild("UpgradeLevels")
        local cash = valueOf(playerData, "Cash", 0)
        if not levels then return nil end

        local rebirth = valueOf(player:FindFirstChild("leaderstats"), "Rebirth", 0)
        local maxLevel = manager.MAX_LEVEL or 5
        local best
        for _, upgradeName in ipairs(Config.FEATURES.UPGRADE_ORDER) do
            local levelObject = levels:FindFirstChild(upgradeName .. "Level")
            local level = levelObject and levelObject.Value or 1
            local capacityAllowed = upgradeName ~= "Capacity" or rebirth == 0
            if levelObject and level < maxLevel and capacityAllowed and isUnlocked(playerData, upgradeName) then
                local cost = manager.GetModifiedCost(player, upgradeName, level)
                if cost > 0 and cost <= cash and (not best or cost < best.cost) then
                    best = {
                        name = upgradeName,
                        levelObject = levelObject,
                        level = level,
                        cost = cost,
                    }
                end
            end
        end
        return best
    end

    function AutoUpgrade:_purchase(player, manager, remote, generation)
        local candidate = self:_findCheapest(player, manager)
        if not candidate then return false end

        remote:FireServer(candidate.name)
        local deadline = os.clock() + Config.TIMING.UPGRADE_CONFIRM_TIMEOUT
        repeat
            task.wait(0.1)
            if candidate.levelObject.Value > candidate.level then
                self.onStatus("Upgrade confirmado: " .. candidate.name)
                return true
            end
        until not self.enabled or self.generation ~= generation or os.clock() >= deadline

        if self.enabled and self.generation == generation then
            self.onStatus("Upgrade nao confirmado: " .. candidate.name)
        end
        return false
    end

    function AutoUpgrade:_run(generation)
        local player = Players.LocalPlayer
        local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
        local modules = ReplicatedStorage:WaitForChild("Modules", 10)
        local remote = remotes and remotes:WaitForChild("UpgradeRequest", 10)
        local managerModule = modules and modules:WaitForChild("UpgradeManager", 10)
        if not remote or not remote:IsA("RemoteEvent") or not managerModule then
            self.onStatus("Upgrade: dependencias ausentes")
            self:setEnabled(false)
            return
        end

        local manager = require(managerModule)
        self.onStatus("Auto Upgrade ativo")
        while self.enabled and self.generation == generation do
            local ok, result = pcall(function()
                return self:_purchase(player, manager, remote, generation)
            end)
            if not ok then
                self.onStatus("Upgrade falhou: " .. tostring(result))
            end
            task.wait(Config.TIMING.UPGRADE_POLL)
        end
    end

    function AutoUpgrade:setEnabled(enabled)
        enabled = enabled == true
        if self.enabled == enabled then return end
        self.enabled = enabled
        self.generation += 1
        if enabled then
            local generation = self.generation
            task.spawn(function() self:_run(generation) end)
        else
            self.onStatus("Auto Upgrade desativado")
        end
    end

    function AutoUpgrade:stop()
        self:setEnabled(false)
    end

    return AutoUpgrade
end

__factories["UI/Layout"] = function()
    local Layout = {}

    local SCALE_PERCENTAGES = {
        [25] = true,
        [50] = true,
        [75] = true,
        [100] = true,
        [125] = true,
        [150] = true,
    }

    function Layout.normalizeScalePercent(value, defaultValue)
        value = tonumber(value)
        if SCALE_PERCENTAGES[value] then
            return value
        end
        defaultValue = tonumber(defaultValue)
        if SCALE_PERCENTAGES[defaultValue] then
            return defaultValue
        end
        return 100
    end

    function Layout.calculate(viewport, config, scalePercent)
        local padding = config.PADDING
        local availableWidth = math.max(1, viewport.X - padding * 2)
        local availableHeight = math.max(1, viewport.Y - padding * 2)

        local width
        local narrow
        local compact
        local mode
        if scalePercent ~= nil then
            local normalized = Layout.normalizeScalePercent(scalePercent, config.DEFAULT_SCALE_PERCENT)
            local baseWidth = config.DESKTOP_WIDTH
            local baseHeight = config.DESKTOP_HEIGHT
            local requestedScale = normalized / 100
            local fitScale = math.min(availableWidth / baseWidth, availableHeight / baseHeight)
            local effectiveScale = math.min(requestedScale, fitScale)
            width = baseWidth * effectiveScale
            local height = baseHeight * effectiveScale
            mode = effectiveScale < 1 and "scaled" or "desktop"
            return {
                mode = mode,
                padding = padding,
                width = width,
                height = height,
                baseWidth = baseWidth,
                baseHeight = baseHeight,
                scale = effectiveScale,
                requestedScale = requestedScale,
                centerX = viewport.X / 2,
                centerY = viewport.Y / 2,
                headerHeight = config.HEADER_HEIGHT or 42,
                effectiveHeaderHeight = (config.HEADER_HEIGHT or 42) * effectiveScale,
                rowHeight = 38,
                textSize = 13,
            }
        else
            narrow = viewport.X <= config.NARROW_BREAKPOINT
            compact = narrow or viewport.Y <= config.COMPACT_BREAKPOINT
            if narrow then
                width = config.DESKTOP_WIDTH
                mode = "narrow"
            elseif compact then
                width = config.COMPACT_WIDTH
                mode = "compact"
            else
                width = config.DESKTOP_WIDTH
                mode = "desktop"
            end
            width = math.min(width, availableWidth)
        end

        return {
            mode = mode,
            padding = padding,
            width = width,
            height = math.min(config.DESKTOP_HEIGHT, availableHeight),
            centerX = viewport.X / 2,
            centerY = viewport.Y / 2,
            headerHeight = compact
                and (config.COMPACT_HEADER_HEIGHT or 38)
                or (config.HEADER_HEIGHT or 42),
            rowHeight = compact and 34 or 38,
            textSize = compact and 12 or 13,
        }
    end

    -- Compatibilidade somente para consumidores legacy da API anterior.
    Layout.normalizeWidthPercent = Layout.normalizeScalePercent

    function Layout.clampCenter(centerX, centerY, width, height, viewport, padding)
        local halfWidth = width / 2
        local halfHeight = height / 2
        local minX = padding + halfWidth
        local maxX = viewport.X - padding - halfWidth
        local minY = padding + halfHeight
        local maxY = viewport.Y - padding - halfHeight

        if minX > maxX then
            centerX = viewport.X / 2
        else
            centerX = math.clamp(centerX, minX, maxX)
        end
        if minY > maxY then
            centerY = viewport.Y / 2
        else
            centerY = math.clamp(centerY, minY, maxY)
        end
        return centerX, centerY
    end

    function Layout.clampDragCenter(centerX, centerY, width, height, viewport, padding, headerHeight)
        local halfWidth = width / 2
        local halfHeight = height / 2
        local visibleWidth = math.min(width, 112)
        local minX = padding + visibleWidth - halfWidth
        local maxX = viewport.X - padding - visibleWidth + halfWidth
        local minY = padding + halfHeight
        local maxY = viewport.Y - padding - headerHeight + halfHeight

        if minX > maxX then
            centerX = viewport.X / 2
        else
            centerX = math.clamp(centerX, minX, maxX)
        end
        if minY > maxY then
            centerY = viewport.Y / 2
        else
            centerY = math.clamp(centerY, minY, maxY)
        end
        return centerX, centerY
    end

    return Layout
end

__factories["UI/LegacyUI"] = function()
    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local Config = __require("Config")
    local Layout = __require("UI/Layout")

    local UI = {}

    local COLORS = table.freeze({
        panel = Color3.fromRGB(20, 22, 29),
        header = Color3.fromRGB(31, 35, 45),
        card = Color3.fromRGB(39, 43, 55),
        cardHover = Color3.fromRGB(48, 53, 67),
        text = Color3.fromRGB(240, 243, 250),
        muted = Color3.fromRGB(164, 173, 194),
        accent = Color3.fromRGB(58, 135, 255),
        green = Color3.fromRGB(42, 170, 100),
        red = Color3.fromRGB(220, 67, 73),
        border = Color3.fromRGB(73, 80, 100),
    })

    local function corner(parent, radius)
        local value = Instance.new("UICorner")
        value.CornerRadius = UDim.new(0, radius)
        value.Parent = parent
        return value
    end

    local function stroke(parent, color, thickness)
        local value = Instance.new("UIStroke")
        value.Color = color
        value.Thickness = thickness or 1
        value.Parent = parent
        return value
    end

    local function makeLabel(parent, text, height)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 0, height or 20)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = COLORS.muted
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 12
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = parent
        return label
    end

    function UI.new(title)
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local previous = playerGui:FindFirstChild(Config.IDENTITY.GUI_NAME)
        if previous then
            previous:Destroy()
        end

        local self = {
            colors = COLORS,
            connections = {},
            cameraConnection = nil,
            destroyed = false,
            closeCallback = nil,
            collapsed = false,
            dragState = "idle",
            dragKind = nil,
            dragInput = nil,
            dragStart = nil,
            startCenter = nil,
            layout = nil,
        }

        local gui = Instance.new("ScreenGui")
        gui.Name = Config.IDENTITY.GUI_NAME
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        pcall(function()
            gui.ScreenInsets = Enum.ScreenInsets.None
        end)
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = playerGui
        self.gui = gui

        local frame = Instance.new("Frame")
        frame.Name = "Window"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        frame.BackgroundColor3 = COLORS.panel
        frame.ClipsDescendants = true
        frame.Parent = gui
        corner(frame, 11)
        stroke(frame, COLORS.border, 1)
        self.frame = frame

        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.BackgroundColor3 = COLORS.header
        topBar.Parent = frame
        self.topBar = topBar

        local dragHandle = Instance.new("TextButton")
        dragHandle.Name = "DragHandle"
        dragHandle.Size = UDim2.new(1, -84, 1, 0)
        dragHandle.BackgroundTransparency = 1
        dragHandle.Text = "  " .. (title or Config.UI.TITLE)
        dragHandle.TextColor3 = COLORS.text
        dragHandle.Font = Enum.Font.GothamBold
        dragHandle.TextSize = 14
        dragHandle.TextXAlignment = Enum.TextXAlignment.Left
        dragHandle.AutoButtonColor = false
        dragHandle.Parent = topBar
        self.dragHandle = dragHandle

        local minimizeButton = Instance.new("TextButton")
        minimizeButton.Name = "Minimize"
        minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
        minimizeButton.Position = UDim2.new(1, -43, 0.5, 0)
        minimizeButton.Size = UDim2.fromOffset(32, 28)
        minimizeButton.BackgroundColor3 = COLORS.card
        minimizeButton.Text = "–"
        minimizeButton.TextColor3 = COLORS.text
        minimizeButton.Font = Enum.Font.GothamBold
        minimizeButton.TextSize = 19
        minimizeButton.Parent = topBar
        corner(minimizeButton, 7)
        self.minimizeButton = minimizeButton

        local closeButton = Instance.new("TextButton")
        closeButton.Name = "Close"
        closeButton.AnchorPoint = Vector2.new(1, 0.5)
        closeButton.Position = UDim2.new(1, -7, 0.5, 0)
        closeButton.Size = UDim2.fromOffset(32, 28)
        closeButton.BackgroundColor3 = COLORS.card
        closeButton.Text = "×"
        closeButton.TextColor3 = COLORS.text
        closeButton.Font = Enum.Font.GothamBold
        closeButton.TextSize = 20
        closeButton.Parent = topBar
        corner(closeButton, 7)
        self.closeButton = closeButton

        local content = Instance.new("ScrollingFrame")
        content.Name = "Content"
        content.BackgroundTransparency = 1
        content.BorderSizePixel = 0
        content.CanvasSize = UDim2.new()
        content.AutomaticCanvasSize = Enum.AutomaticSize.Y
        content.ScrollingDirection = Enum.ScrollingDirection.Y
        content.ScrollBarThickness = 4
        content.ScrollBarImageColor3 = COLORS.accent
        content.Parent = frame
        self.content = content

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 9)
        padding.PaddingRight = UDim.new(0, 9)
        padding.PaddingTop = UDim.new(0, 9)
        padding.PaddingBottom = UDim.new(0, 9)
        padding.Parent = content

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 7)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content

        local function currentViewport()
            local camera = Workspace.CurrentCamera
            return camera and camera.ViewportSize or Vector2.new(800, 600)
        end

        function self:_applyLayout(resetCenter)
            if self.destroyed then
                return
            end
            local viewport = currentViewport()
            local calculated = Layout.calculate(viewport, Config.UI)
            local effectiveHeight = self.collapsed and calculated.headerHeight or calculated.height
            local centerX = resetCenter and calculated.centerX or self.frame.Position.X.Offset
            local centerY = resetCenter and calculated.centerY or self.frame.Position.Y.Offset
            if resetCenter and not self.collapsed then
                centerX, centerY = Layout.clampCenter(
                    centerX,
                    centerY,
                    calculated.width,
                    effectiveHeight,
                    viewport,
                    calculated.padding
                )
            else
                centerX, centerY = Layout.clampDragCenter(
                    centerX,
                    centerY,
                    calculated.width,
                    effectiveHeight,
                    viewport,
                    calculated.padding,
                    calculated.headerHeight
                )
            end

            self.layout = calculated
            self.frame.Size = UDim2.fromOffset(calculated.width, effectiveHeight)
            self.frame.Position = UDim2.fromOffset(centerX, centerY)
            self.topBar.Size = UDim2.new(1, 0, 0, calculated.headerHeight)
            self.content.Position = UDim2.fromOffset(0, calculated.headerHeight)
            self.content.Size = UDim2.new(1, 0, 1, -calculated.headerHeight)
            self.content.Visible = not self.collapsed
        end

        function self:_bindCamera()
            if self.cameraConnection then
                self.cameraConnection:Disconnect()
                self.cameraConnection = nil
            end
            local camera = Workspace.CurrentCamera
            if camera then
                self.cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    self:_applyLayout(false)
                end)
            end
            self:_applyLayout(false)
        end

        local function finishDrag(input)
            local finishedMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseButton1
            local finishedTouch = self.dragKind == "touch" and input == self.dragInput
            if not finishedMouse and not finishedTouch then
                return
            end
            self.dragState = "idle"
            self.dragKind = nil
            self.dragInput = nil
            self.dragStart = nil
            self.startCenter = nil
        end

        table.insert(self.connections, dragHandle.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch
            then
                return
            end
            self.dragState = "pressed"
            self.dragKind = input.UserInputType == Enum.UserInputType.Touch and "touch" or "mouse"
            self.dragInput = self.dragKind == "touch" and input or nil
            self.dragStart = input.Position
            self.startCenter = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end))

        table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
            local movingMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseMovement
            local movingTouch = self.dragKind == "touch" and input == self.dragInput
            if self.dragState == "idle" or (not movingMouse and not movingTouch) then
                return
            end
            local delta = input.Position - self.dragStart
            if self.dragState == "pressed" and delta.Magnitude >= 5 then
                self.dragState = "dragging"
            end
            if self.dragState ~= "dragging" then
                return
            end

            local viewport = currentViewport()
            local effectiveHeight = self.collapsed and self.layout.headerHeight or self.layout.height
            local x, y = Layout.clampDragCenter(
                self.startCenter.X + delta.X,
                self.startCenter.Y + delta.Y,
                self.layout.width,
                effectiveHeight,
                viewport,
                self.layout.padding,
                self.layout.headerHeight
            )
            frame.Position = UDim2.fromOffset(x, y)
        end))

        table.insert(self.connections, UserInputService.InputEnded:Connect(finishDrag))
        table.insert(self.connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            self:_bindCamera()
        end))
        table.insert(self.connections, closeButton.Activated:Connect(function()
            if self.closeCallback then
                self.closeCallback()
            end
        end))
        table.insert(self.connections, minimizeButton.Activated:Connect(function()
            local currentHeight = self.frame.Size.Y.Offset
            local top = self.frame.Position.Y.Offset - currentHeight / 2
            self.collapsed = not self.collapsed
            minimizeButton.Text = self.collapsed and "+" or "–"
            local nextHeight = self.collapsed and self.layout.headerHeight or self.layout.height
            self.frame.Position = UDim2.fromOffset(
                self.frame.Position.X.Offset,
                top + nextHeight / 2
            )
            self:_applyLayout(false)
        end))

        function self:setCloseCallback(callback)
            self.closeCallback = callback
        end

        function self:Destroy()
            if self.destroyed then
                return
            end
            self.destroyed = true
            self.dragState = "idle"
            self.dragKind = nil
            self.dragInput = nil
            if self.cameraConnection then
                self.cameraConnection:Disconnect()
                self.cameraConnection = nil
            end
            for _, connection in ipairs(self.connections) do
                connection:Disconnect()
            end
            table.clear(self.connections)
            if self.gui then
                self.gui:Destroy()
                self.gui = nil
            end
        end

        self:_applyLayout(true)
        self:_bindCamera()
        return self
    end

    function UI.section(parent, text)
        local label = makeLabel(parent, text, 20)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = COLORS.muted
        label.TextSize = 11
        return label
    end

    function UI.info(parent, text, height)
        local label = makeLabel(parent, text, height or 34)
        label.TextColor3 = COLORS.text
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Top
        return label
    end

    function UI.button(parent, text, color, height)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, height or 36)
        button.BackgroundColor3 = color or COLORS.card
        button.AutoButtonColor = true
        button.Text = text
        button.TextColor3 = COLORS.text
        button.Font = Enum.Font.GothamBold
        button.TextSize = 13
        button.Parent = parent
        corner(button, 7)
        return button
    end

    function UI.checkbox(parent, text, initial, callback)
        local row = UI.button(parent, "", COLORS.card, 38)
        local box = Instance.new("TextLabel")
        box.AnchorPoint = Vector2.new(0, 0.5)
        box.Position = UDim2.new(0, 10, 0.5, 0)
        box.Size = UDim2.fromOffset(20, 20)
        box.BackgroundColor3 = COLORS.panel
        box.TextColor3 = COLORS.text
        box.Font = Enum.Font.GothamBold
        box.TextSize = 15
        box.Parent = row
        corner(box, 5)
        stroke(box, COLORS.border, 1)

        local label = makeLabel(row, text, 38)
        label.Position = UDim2.fromOffset(40, 0)
        label.Size = UDim2.new(1, -48, 1, 0)
        label.TextColor3 = COLORS.text
        label.TextSize = 13

        local checked = initial == true
        local function render()
            box.Text = checked and "✓" or ""
            box.BackgroundColor3 = checked and COLORS.green or COLORS.panel
        end
        render()

        row.Activated:Connect(function()
            checked = not checked
            render()
            callback(checked)
        end)
        return row
    end

    function UI.numberInput(parent, text, initial, minimum, maximum, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 42)
        row.BackgroundColor3 = COLORS.card
        row.Parent = parent
        corner(row, 7)

        local label = makeLabel(row, text, 42)
        label.Position = UDim2.fromOffset(10, 0)
        label.Size = UDim2.new(1, -112, 1, 0)
        label.TextColor3 = COLORS.text
        label.TextSize = 12

        local box = Instance.new("TextBox")
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Position = UDim2.new(1, -8, 0.5, 0)
        box.Size = UDim2.fromOffset(92, 28)
        box.BackgroundColor3 = COLORS.panel
        box.TextColor3 = COLORS.text
        box.PlaceholderColor3 = COLORS.muted
        box.ClearTextOnFocus = false
        box.Font = Enum.Font.GothamBold
        box.TextSize = 13
        box.Text = tostring(initial)
        box.Parent = row
        corner(box, 6)
        stroke(box, COLORS.border, 1)

        local value = math.clamp(tonumber(initial) or minimum, minimum, maximum)
        local function commit()
            value = math.clamp(tonumber(box.Text) or value, minimum, maximum)
            box.Text = tostring(math.floor(value + 0.5))
            callback(value)
        end
        box.FocusLost:Connect(commit)
        return row, box
    end

    return UI
end

__factories["UI/ModernUI"] = function()
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local Workspace = game:GetService("Workspace")

    local Config = __require("Config")
    local IconCache = __require("Core/IconCache")
    local Theme = __require("Core/Theme")
    local Layout = __require("UI/Layout")

    local UI = {}

    local COLORS = Theme.resolveColors(Theme.DEFAULT_NAME)

    local TABS = table.freeze({ "Main", "Visual", "Misc", "Settings" })
    local TWEEN_INFO = TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local THEME_ATTRIBUTE = "GOATHubTheme_"
    local THEME_PROPERTIES = table.freeze({
        "BackgroundColor3",
        "TextColor3",
        "PlaceholderColor3",
        "ScrollBarImageColor3",
        "Color",
    })

    local function themed(instance, property, token)
        instance:SetAttribute(THEME_ATTRIBUTE .. property, token)
        instance[property] = COLORS[token]
    end

    local function applyThemeBindings(root)
        local instances = root:GetDescendants()
        table.insert(instances, root)
        for _, instance in ipairs(instances) do
            if instance:IsA("UIGradient") then
                local first = instance:GetAttribute(THEME_ATTRIBUTE .. "GradientFirst")
                local second = instance:GetAttribute(THEME_ATTRIBUTE .. "GradientSecond")
                if COLORS[first] and COLORS[second] then
                    instance.Color = ColorSequence.new(COLORS[first], COLORS[second])
                end
            else
                for _, property in ipairs(THEME_PROPERTIES) do
                    local token = instance:GetAttribute(THEME_ATTRIBUTE .. property)
                    if COLORS[token] then
                        instance[property] = COLORS[token]
                    end
                end
            end
        end
    end

    local function corner(parent, radius)
        local value = Instance.new("UICorner")
        value.CornerRadius = UDim.new(0, radius)
        value.Parent = parent
        return value
    end

    local function stroke(parent, token, thickness, transparency)
        local value = Instance.new("UIStroke")
        themed(value, "Color", token)
        value.Thickness = thickness or 1
        value.Transparency = transparency or 0
        value.Parent = parent
        return value
    end

    local function gradient(parent, first, second, rotation)
        local value = Instance.new("UIGradient")
        value:SetAttribute(THEME_ATTRIBUTE .. "GradientFirst", first)
        value:SetAttribute(THEME_ATTRIBUTE .. "GradientSecond", second)
        value.Color = ColorSequence.new(COLORS[first], COLORS[second])
        value.Rotation = rotation or 0
        value.Parent = parent
        return value
    end

    local function animate(instance, properties)
        TweenService:Create(instance, TWEEN_INFO, properties):Play()
    end

    local function animateThemed(instance, property, token)
        instance:SetAttribute(THEME_ATTRIBUTE .. property, token)
        animate(instance, { [property] = COLORS[token] })
    end

    local function label(parent, text, size)
        local value = Instance.new("TextLabel")
        value.BackgroundTransparency = 1
        value.Text = text
        themed(value, "TextColor3", "text")
        value.Font = Enum.Font.GothamMedium
        value.TextSize = size or 13
        value.TextXAlignment = Enum.TextXAlignment.Left
        value.Parent = parent
        return value
    end

    local function addPageLayout(page)
        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 14)
        padding.PaddingRight = UDim.new(0, 14)
        padding.PaddingTop = UDim.new(0, 13)
        padding.PaddingBottom = UDim.new(0, 14)
        padding.Parent = page

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 9)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = page
    end

    function UI.new(title, options)
        options = typeof(options) == "table" and options or {}
        local initialTheme = typeof(options.theme) == "table" and options.theme or {}
        local themeName = Theme.normalizeName(initialTheme.name or Config.MODERN_UI.DEFAULT_THEME)
        local customTheme = Theme.normalizeCustom(initialTheme.custom)
        for key, color in pairs(Theme.resolveColors(themeName, customTheme)) do
            COLORS[key] = color
        end
        local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local previous = playerGui:FindFirstChild(Config.IDENTITY.GUI_NAME)
        if previous then
            previous:Destroy()
        end

        local self = {
            colors = COLORS,
            connections = {},
            cameraConnection = nil,
            destroyed = false,
            closeCallback = nil,
            collapsed = false,
            dragState = "idle",
            dragKind = nil,
            dragInput = nil,
            dragStart = nil,
            startCenter = nil,
            layout = nil,
            pages = {},
            tabs = {},
            activePage = "Main",
            themeName = themeName,
            customTheme = customTheme,
            scalePercent = Layout.normalizeScalePercent(
                options.scalePercent,
                Config.MODERN_UI.DEFAULT_SCALE_PERCENT
            ),
            transitionBusy = false,
        }

        local gui = Instance.new("ScreenGui")
        gui.Name = Config.IDENTITY.GUI_NAME
        gui.ResetOnSpawn = false
        gui.IgnoreGuiInset = true
        pcall(function()
            gui.ScreenInsets = Enum.ScreenInsets.None
        end)
        gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        gui.Parent = playerGui
        self.gui = gui

        local frame = Instance.new("Frame")
        frame.Name = "ModernWindow"
        frame.AnchorPoint = Vector2.new(0.5, 0.5)
        themed(frame, "BackgroundColor3", "panel")
        frame.ClipsDescendants = true
        frame.Parent = gui
        self.frameCorner = corner(frame, 14)
        stroke(frame, "border", 1, 0.08)
        gradient(frame, "background", "panel", 90)
        self.frame = frame

        local windowScale = Instance.new("UIScale")
        windowScale.Scale = 1
        windowScale.Parent = frame
        self.windowScale = windowScale

        local topBar = Instance.new("Frame")
        topBar.Name = "TopBar"
        topBar.BackgroundTransparency = 0
        themed(topBar, "BackgroundColor3", "header")
        topBar.BorderSizePixel = 0
        topBar.Parent = frame
        corner(topBar, 12)
        self.topBar = topBar

        local dragHandle = Instance.new("TextButton")
        dragHandle.Name = "DragHandle"
        dragHandle.Size = UDim2.new(1, -94, 1, 0)
        dragHandle.BackgroundTransparency = 1
        dragHandle.Text = ""
        dragHandle.AutoButtonColor = false
        dragHandle.ZIndex = 2
        dragHandle.Parent = topBar
        self.dragHandle = dragHandle

        local brand = Instance.new("TextButton")
        brand.Name = "Brand"
        brand.AnchorPoint = Vector2.new(0.5, 0.5)
        brand.Position = UDim2.new(0, 28, 0.5, 0)
        brand.Size = UDim2.fromOffset(32, 32)
        themed(brand, "BackgroundColor3", "accent")
        brand.Text = ""
        brand.AutoButtonColor = false
        brand.ZIndex = 4
        brand.Parent = topBar
        corner(brand, 9)
        gradient(brand, "accent", "accentBright", 35)

        local brandIcon = Instance.new("ImageLabel")
        brandIcon.Name = "Icon"
        brandIcon.AnchorPoint = Vector2.new(0.5, 0.5)
        brandIcon.Position = UDim2.fromScale(0.5, 0.5)
        brandIcon.Size = UDim2.fromScale(1, 1)
        brandIcon.BackgroundTransparency = 1
        brandIcon.ScaleType = Enum.ScaleType.Fit
        brandIcon.ImageTransparency = 1
        brandIcon.Image = ""
        brandIcon.Parent = brand

        local brandFallback = label(brand, "G", 16)
        brandFallback.AnchorPoint = Vector2.new(0.5, 0.5)
        brandFallback.Position = UDim2.fromScale(0.5, 0.5)
        brandFallback.Size = UDim2.fromScale(1, 1)
        brandFallback.TextXAlignment = Enum.TextXAlignment.Center
        brandFallback.TextYAlignment = Enum.TextYAlignment.Center
        brandFallback.Font = Enum.Font.GothamBold
        brandFallback.Visible = true

        IconCache.loadAsync(options.icon, function(asset, failure)
            if self.destroyed or not brandIcon.Parent or not brandFallback.Parent then
                return
            end
            if typeof(asset) == "string" and asset ~= "" then
                brandIcon.Image = asset
                brandIcon.ImageTransparency = 0
                brandFallback.Visible = false
            elseif failure then
                warn("[" .. Config.IDENTITY.NAME .. "] Icone da TopBar: " .. tostring(failure))
            end
        end)

        local titleLabel = label(topBar, title or Config.MODERN_UI.TITLE, 14)
        titleLabel.Name = "Title"
        titleLabel.Position = UDim2.fromOffset(54, 8)
        titleLabel.Size = UDim2.new(1, -150, 0, 20)
        titleLabel.Font = Enum.Font.GothamBold

        local subtitle = label(topBar, Config.MODERN_UI.SUBTITLE or "CLIENT HUB", 9)
        subtitle.Name = "Subtitle"
        subtitle.Position = UDim2.fromOffset(54, 27)
        subtitle.Size = UDim2.new(1, -150, 0, 15)
        themed(subtitle, "TextColor3", "muted")

        local minimizeButton = Instance.new("TextButton")
        minimizeButton.Name = "Minimize"
        minimizeButton.AnchorPoint = Vector2.new(1, 0.5)
        minimizeButton.Position = UDim2.new(1, -48, 0.5, 0)
        minimizeButton.Size = UDim2.fromOffset(34, 30)
        themed(minimizeButton, "BackgroundColor3", "surface")
        minimizeButton.Text = "–"
        themed(minimizeButton, "TextColor3", "muted")
        minimizeButton.Font = Enum.Font.GothamBold
        minimizeButton.TextSize = 19
        minimizeButton.ZIndex = 3
        minimizeButton.Parent = topBar
        corner(minimizeButton, 9)
        stroke(minimizeButton, "border", 1, 0.2)
        self.minimizeButton = minimizeButton

        local closeButton = Instance.new("TextButton")
        closeButton.Name = "Close"
        closeButton.AnchorPoint = Vector2.new(1, 0.5)
        closeButton.Position = UDim2.new(1, -10, 0.5, 0)
        closeButton.Size = UDim2.fromOffset(34, 30)
        themed(closeButton, "BackgroundColor3", "surface")
        closeButton.Text = "×"
        themed(closeButton, "TextColor3", "red")
        closeButton.Font = Enum.Font.GothamBold
        closeButton.TextSize = 19
        closeButton.ZIndex = 3
        closeButton.Parent = topBar
        corner(closeButton, 9)
        stroke(closeButton, "border", 1, 0.2)
        self.closeButton = closeButton

        local tabBar = Instance.new("Frame")
        tabBar.Name = "Navigation"
        themed(tabBar, "BackgroundColor3", "surface")
        tabBar.BorderSizePixel = 0
        tabBar.Parent = frame
        corner(tabBar, 10)
        self.tabBar = tabBar

        local tabsContainer = Instance.new("Frame")
        tabsContainer.Name = "TabsContainer"
        tabsContainer.Position = UDim2.fromOffset(12, 6)
        tabsContainer.Size = UDim2.new(1, -24, 1, -11)
        tabsContainer.BackgroundTransparency = 1
        tabsContainer.Parent = tabBar

        local tabList = Instance.new("UIListLayout")
        tabList.FillDirection = Enum.FillDirection.Horizontal
        tabList.Padding = UDim.new(0, 4)
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Parent = tabsContainer

        local pageHost = Instance.new("Frame")
        pageHost.Name = "Pages"
        pageHost.BackgroundTransparency = 1
        pageHost.ClipsDescendants = true
        pageHost.Parent = frame
        self.pageHost = pageHost

        for index, pageName in ipairs(TABS) do
            local button = Instance.new("TextButton")
            button.Name = pageName
            button.Size = UDim2.new(0.25, -3, 1, 0)
            themed(button, "BackgroundColor3", "card")
            button.BackgroundTransparency = 1
            button.Text = pageName
            themed(button, "TextColor3", "muted")
            button.Font = Enum.Font.GothamBold
            button.TextSize = 12
            button.AutoButtonColor = false
            button.LayoutOrder = index
            button.Parent = tabsContainer
            corner(button, 8)

            local indicator = Instance.new("Frame")
            indicator.Name = "Indicator"
            indicator.AnchorPoint = Vector2.new(0.5, 1)
            indicator.Position = UDim2.new(0.5, 0, 1, 0)
            indicator.Size = UDim2.new(0.42, 0, 0, 2)
            themed(indicator, "BackgroundColor3", "accentBright")
            indicator.BorderSizePixel = 0
            indicator.Visible = false
            indicator.Parent = button
            corner(indicator, 2)

            local page = Instance.new("ScrollingFrame")
            page.Name = pageName .. "Page"
            page.Size = UDim2.fromScale(1, 1)
            page.BackgroundTransparency = 1
            page.BorderSizePixel = 0
            page.CanvasSize = UDim2.new()
            page.AutomaticCanvasSize = Enum.AutomaticSize.Y
            page.ScrollingDirection = Enum.ScrollingDirection.Y
            page.ScrollBarThickness = 3
            themed(page, "ScrollBarImageColor3", "accent")
            page.Visible = false
            page.Parent = pageHost
            addPageLayout(page)

            self.tabs[pageName] = {
                button = button,
                indicator = indicator,
            }
            self.pages[pageName] = page
            table.insert(self.connections, button.Activated:Connect(function()
                self:selectPage(pageName)
            end))
        end
        self.content = self.pages.Main

        local function currentViewport()
            local camera = Workspace.CurrentCamera
            return camera and camera.ViewportSize or Vector2.new(800, 600)
        end

        function self:selectPage(pageName)
            if not self.pages[pageName] then
                return
            end
            self.activePage = pageName
            for name, page in pairs(self.pages) do
                local selected = name == pageName
                page.Visible = selected and not self.collapsed
                local tab = self.tabs[name]
                tab.indicator.Visible = selected
                themed(tab.button, "TextColor3", selected and "text" or "muted")
                animate(tab.button, {
                    BackgroundTransparency = selected and 0 or 1,
                })
            end
        end

        function self:setStatus(_message)
            -- A UI moderna nao exibe barra de status; controllers continuam
            -- podendo emitir mensagens sem acoplar comportamento ao visual.
        end

        function self:setTheme(name, custom)
            if self.destroyed or Theme.normalizeName(name) ~= name then
                return false
            end
            self.themeName = name
            self.customTheme = Theme.normalizeCustom(custom or self.customTheme)
            for key, color in pairs(Theme.resolveColors(name, self.customTheme)) do
                COLORS[key] = color
            end
            applyThemeBindings(self.gui)
            self:selectPage(self.activePage)
            return true
        end

        function self:getTheme()
            return {
                name = self.themeName,
                custom = Theme.normalizeCustom(self.customTheme),
            }
        end

        function self:setScalePercent(value)
            local normalized = Layout.normalizeScalePercent(value, Config.MODERN_UI.DEFAULT_SCALE_PERCENT)
            if tonumber(value) ~= normalized then
                return false
            end
            if self.scalePercent ~= normalized then
                self.scalePercent = normalized
                self:_applyLayout(false)
            end
            return true
        end

        self.setWidthPercent = self.setScalePercent

        function self:_applyLayout(resetCenter)
            if self.destroyed then
                return
            end
            local viewport = currentViewport()
            local calculated = Layout.calculate(viewport, Config.MODERN_UI, self.scalePercent)
            if self.transitionBusy then
                self.layout = calculated
                return
            end
            local actualWidth = self.collapsed and 52 or calculated.width
            local actualHeight = self.collapsed and 52 or calculated.height
            local centerX = resetCenter and calculated.centerX or self.frame.Position.X.Offset
            local centerY = resetCenter and calculated.centerY or self.frame.Position.Y.Offset
            if resetCenter and not self.collapsed then
                centerX, centerY = Layout.clampCenter(
                    centerX,
                    centerY,
                    actualWidth,
                    actualHeight,
                    viewport,
                    calculated.padding
                )
            else
                centerX, centerY = Layout.clampDragCenter(
                    centerX,
                    centerY,
                    actualWidth,
                    actualHeight,
                    viewport,
                    calculated.padding,
                    self.collapsed and 52 or calculated.effectiveHeaderHeight
                )
            end

            self.layout = calculated
            self.frame.Position = UDim2.fromOffset(centerX, centerY)
            if self.collapsed then
                self.windowScale.Scale = 1
                self.frame.Size = UDim2.fromOffset(52, 52)
                self.frameCorner.CornerRadius = UDim.new(0, 16)
                self.topBar.Size = UDim2.fromScale(1, 1)
                brand.Position = UDim2.fromScale(0.5, 0.5)
                brand.Size = UDim2.fromOffset(38, 38)
                self.tabBar.Visible = false
                self.pageHost.Visible = false
                return
            end
            self.windowScale.Scale = calculated.scale
            self.frame.Size = UDim2.fromOffset(calculated.baseWidth, calculated.baseHeight)
            self.frameCorner.CornerRadius = UDim.new(0, 14)
            self.topBar.Size = UDim2.new(1, 0, 0, calculated.headerHeight)
            brand.Position = UDim2.new(0, 28, 0.5, 0)
            brand.Size = UDim2.fromOffset(32, 32)
            self.tabBar.Position = UDim2.fromOffset(0, calculated.headerHeight)
            self.tabBar.Size = UDim2.new(1, 0, 0, Config.MODERN_UI.TAB_HEIGHT)
            self.pageHost.Position = UDim2.fromOffset(
                0,
                calculated.headerHeight + Config.MODERN_UI.TAB_HEIGHT
            )
            self.pageHost.Size = UDim2.new(
                1,
                0,
                1,
                -(calculated.headerHeight + Config.MODERN_UI.TAB_HEIGHT)
            )
            self.tabBar.Visible = true
            self.pageHost.Visible = true
            self:selectPage(self.activePage)
        end

        function self:_bindCamera()
            if self.cameraConnection then
                self.cameraConnection:Disconnect()
                self.cameraConnection = nil
            end
            local camera = Workspace.CurrentCamera
            if camera then
                self.cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                    self:_applyLayout(false)
                end)
            end
            self:_applyLayout(false)
        end

        local function finishDrag(input)
            local finishedMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseButton1
            local finishedTouch = self.dragKind == "touch" and input == self.dragInput
            if not finishedMouse and not finishedTouch then
                return
            end
            if self.dragState == "dragging" then
                self.suppressBrandUntil = os.clock() + 0.18
            end
            self.dragState = "idle"
            self.dragKind = nil
            self.dragInput = nil
            self.dragStart = nil
            self.startCenter = nil
        end

        local function beginWindowDrag(input)
            if self.transitionBusy then
                return
            end
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch
            then
                return
            end
            self.dragState = "pressed"
            self.dragKind = input.UserInputType == Enum.UserInputType.Touch and "touch" or "mouse"
            self.dragInput = self.dragKind == "touch" and input or nil
            self.dragStart = input.Position
            self.startCenter = Vector2.new(frame.Position.X.Offset, frame.Position.Y.Offset)
        end

        table.insert(self.connections, dragHandle.InputBegan:Connect(beginWindowDrag))
        table.insert(self.connections, brand.InputBegan:Connect(beginWindowDrag))

        table.insert(self.connections, UserInputService.InputChanged:Connect(function(input)
            local movingMouse = self.dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseMovement
            local movingTouch = self.dragKind == "touch" and input == self.dragInput
            if self.dragState == "idle" or (not movingMouse and not movingTouch) then
                return
            end
            local delta = input.Position - self.dragStart
            if self.dragState == "pressed" and delta.Magnitude >= 5 then
                self.dragState = "dragging"
            end
            if self.dragState ~= "dragging" then
                return
            end

            local viewport = currentViewport()
            local effectiveWidth = self.collapsed and 52 or self.layout.width
            local effectiveHeight = self.collapsed and 52 or self.layout.height
            local x, y = Layout.clampDragCenter(
                self.startCenter.X + delta.X,
                self.startCenter.Y + delta.Y,
                effectiveWidth,
                effectiveHeight,
                viewport,
                self.layout.padding,
                self.collapsed and 52 or self.layout.effectiveHeaderHeight
            )
            frame.Position = UDim2.fromOffset(x, y)
        end))

        table.insert(self.connections, UserInputService.InputEnded:Connect(finishDrag))
        table.insert(self.connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            self:_bindCamera()
        end))
        table.insert(self.connections, closeButton.Activated:Connect(function()
            if self.closeCallback then
                self.closeCallback()
            end
        end))
        local function setHeaderDetailsVisible(visible)
            titleLabel.Visible = visible
            subtitle.Visible = visible
            minimizeButton.Visible = visible
            closeButton.Visible = visible
            dragHandle.Visible = visible
        end

        local function collapseToLogo()
            if self.collapsed or self.transitionBusy then
                return
            end
            self.transitionBusy = true
            local left = frame.Position.X.Offset - self.layout.width / 2
            local top = frame.Position.Y.Offset - self.layout.height / 2

            -- O frame usa tamanho-base + UIScale. Animar ambos misturava pixels
            -- renderizados e base, fazendo a janela crescer para a direita. A troca
            -- atomica tambem impede que um toque curto pareca um gesto de hold.
            self.dragState = "idle"
            self.dragKind = nil
            self.dragInput = nil
            self.dragStart = nil
            self.startCenter = nil
            self.collapsed = true
            self.tabBar.Visible = false
            self.pageHost.Visible = false
            setHeaderDetailsVisible(false)
            self.windowScale.Scale = 1
            brand.Position = UDim2.fromScale(0.5, 0.5)
            brand.Size = UDim2.fromOffset(38, 38)
            self.frameCorner.CornerRadius = UDim.new(0, 16)
            frame.Size = UDim2.fromOffset(52, 52)
            frame.Position = UDim2.fromOffset(left + 26, top + 26)
            self.topBar.Size = UDim2.fromScale(1, 1)
            self.transitionBusy = false
            self:_applyLayout(false)
        end

        local function expandFromLogo()
            if not self.collapsed or self.transitionBusy then
                return
            end
            self.transitionBusy = true
            local viewport = currentViewport()
            local calculated = Layout.calculate(viewport, Config.MODERN_UI, self.scalePercent)
            self.layout = calculated
            local left = frame.Position.X.Offset - 26
            local top = frame.Position.Y.Offset - 26
            local centerX = left + calculated.width / 2
            local centerY = top + calculated.height / 2
            centerX, centerY = Layout.clampDragCenter(
                centerX,
                centerY,
                calculated.width,
                calculated.height,
                viewport,
                calculated.padding,
                calculated.effectiveHeaderHeight
            )
            self.windowScale.Scale = calculated.scale
            brand.Position = UDim2.new(0, 28, 0.5, 0)
            brand.Size = UDim2.fromOffset(32, 32)
            self.frameCorner.CornerRadius = UDim.new(0, 14)
            frame.Size = UDim2.fromOffset(calculated.baseWidth, calculated.baseHeight)
            frame.Position = UDim2.fromOffset(centerX, centerY)
            setHeaderDetailsVisible(true)
            self.topBar.Size = UDim2.new(1, 0, 0, calculated.headerHeight)
            self.tabBar.Visible = true
            self.pageHost.Visible = true
            self.collapsed = false
            self:selectPage(self.activePage)
            self.transitionBusy = false
            self:_applyLayout(false)
        end

        table.insert(self.connections, minimizeButton.Activated:Connect(function()
            collapseToLogo()
        end))
        table.insert(self.connections, brand.Activated:Connect(function()
            if self.collapsed and os.clock() >= (self.suppressBrandUntil or 0) then
                self.dragState = "idle"
                self.dragKind = nil
                self.dragInput = nil
                expandFromLogo()
            end
        end))

        function self:getPage(pageName)
            return self.pages[pageName]
        end

        function self:setCloseCallback(callback)
            self.closeCallback = callback
        end

        function self:Destroy()
            if self.destroyed then
                return
            end
            self.destroyed = true
            self.dragState = "idle"
            self.dragKind = nil
            self.dragInput = nil
            if self.cameraConnection then
                self.cameraConnection:Disconnect()
                self.cameraConnection = nil
            end
            for _, connection in ipairs(self.connections) do
                connection:Disconnect()
            end
            table.clear(self.connections)
            table.clear(self.pages)
            table.clear(self.tabs)
            if self.gui then
                self.gui:Destroy()
                self.gui = nil
            end
        end

        self:_applyLayout(true)
        self:_bindCamera()
        self:selectPage("Main")
        return self
    end

    function UI.section(parent, text)
        local section = Instance.new("Frame")
        section.Size = UDim2.new(1, 0, 0, 25)
        section.BackgroundTransparency = 1
        section.Parent = parent

        local title = label(section, string.upper(text), 10)
        title.Size = UDim2.new(0.46, 0, 1, 0)
        themed(title, "TextColor3", "muted")
        title.Font = Enum.Font.GothamBold

        local line = Instance.new("Frame")
        line.AnchorPoint = Vector2.new(1, 0.5)
        line.Position = UDim2.new(1, 0, 0.5, 0)
        line.Size = UDim2.new(0.52, 0, 0, 1)
        themed(line, "BackgroundColor3", "border")
        line.BackgroundTransparency = 0.25
        line.BorderSizePixel = 0
        line.Parent = section
        return section
    end

    function UI.info(parent, text, height)
        local value = label(parent, text, 11)
        value.Size = UDim2.new(1, 0, 0, height or 42)
        themed(value, "BackgroundColor3", "surface")
        value.BackgroundTransparency = 0.12
        themed(value, "TextColor3", "muted")
        value.TextWrapped = true
        value.TextYAlignment = Enum.TextYAlignment.Center
        value.Parent = parent
        corner(value, 9)
        stroke(value, "border", 1, 0.3)

        local padding = Instance.new("UIPadding")
        padding.PaddingLeft = UDim.new(0, 12)
        padding.PaddingRight = UDim.new(0, 12)
        padding.Parent = value
        return value
    end

    function UI.button(parent, text, color, height)
        local button = Instance.new("TextButton")
        button.Size = UDim2.new(1, 0, 0, height or 42)
        if color then
            button.BackgroundColor3 = color
        else
            themed(button, "BackgroundColor3", "card")
        end
        button.AutoButtonColor = false
        button.Text = text
        themed(button, "TextColor3", "text")
        button.Font = Enum.Font.GothamBold
        button.TextSize = 12
        button.Parent = parent
        corner(button, 10)
        stroke(button, "border", 1, 0.2)

        button.MouseEnter:Connect(function()
            if not color then
                animateThemed(button, "BackgroundColor3", "cardHover")
            end
        end)
        button.MouseLeave:Connect(function()
            if not color then
                animateThemed(button, "BackgroundColor3", "card")
            end
        end)
        return button
    end

    function UI.checkbox(parent, text, initial, callback)
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 46)
        themed(row, "BackgroundColor3", "card")
        row.AutoButtonColor = false
        row.Text = ""
        row.Parent = parent
        corner(row, 10)
        stroke(row, "border", 1, 0.22)

        local title = label(row, text, 12)
        title.Position = UDim2.fromOffset(13, 0)
        title.Size = UDim2.new(1, -82, 1, 0)
        themed(title, "TextColor3", "text")
        title.Font = Enum.Font.GothamMedium

        local track = Instance.new("Frame")
        track.AnchorPoint = Vector2.new(1, 0.5)
        track.Position = UDim2.new(1, -12, 0.5, 0)
        track.Size = UDim2.fromOffset(42, 23)
        themed(track, "BackgroundColor3", "track")
        track.Parent = row
        corner(track, 12)

        local knob = Instance.new("Frame")
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.Size = UDim2.fromOffset(17, 17)
        themed(knob, "BackgroundColor3", "text")
        knob.Parent = track
        corner(knob, 9)

        local checked = initial == true
        local function render(animated)
            local trackToken = checked and "accent" or "track"
            local knobPosition = UDim2.new(0, checked and 22 or 3, 0.5, 0)
            if animated then
                animateThemed(track, "BackgroundColor3", trackToken)
                animate(knob, { Position = knobPosition })
            else
                themed(track, "BackgroundColor3", trackToken)
                knob.Position = knobPosition
            end
        end
        render(false)

        row.MouseEnter:Connect(function()
            animateThemed(row, "BackgroundColor3", "cardHover")
        end)
        row.MouseLeave:Connect(function()
            animateThemed(row, "BackgroundColor3", "card")
        end)
        row.Activated:Connect(function()
            checked = not checked
            render(true)
            callback(checked)
        end)
        return row
    end

    function UI.segmented(parent, text, options, initial, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 78)
        themed(row, "BackgroundColor3", "card")
        row.Parent = parent
        corner(row, 10)
        stroke(row, "border", 1, 0.22)

        local title = label(row, text, 11)
        title.Position = UDim2.fromOffset(13, 5)
        title.Size = UDim2.new(1, -26, 0, 24)
        themed(title, "TextColor3", "text")

        local selector = Instance.new("Frame")
        selector.Position = UDim2.fromOffset(13, 35)
        selector.Size = UDim2.new(1, -26, 0, 31)
        themed(selector, "BackgroundColor3", "background")
        selector.Parent = row
        corner(selector, 8)
        stroke(selector, "border", 1, 0.18)

        local list = Instance.new("UIListLayout")
        list.FillDirection = Enum.FillDirection.Horizontal
        list.Padding = UDim.new(0, 3)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = selector

        local values = {}
        for _, option in ipairs(options) do
            table.insert(values, tostring(option))
        end
        if #values == 0 then
            table.insert(values, tostring(initial))
        end

        local selected = tostring(initial)
        local buttons = {}
        local offset = -(3 * (#values - 1) / #values)
        local function render(animated)
            for value, button in pairs(buttons) do
                local active = value == selected
                local textToken = active and "text" or "muted"
                button:SetAttribute(THEME_ATTRIBUTE .. "TextColor3", textToken)
                local properties = {
                    BackgroundTransparency = active and 0.05 or 1,
                    TextColor3 = COLORS[textToken],
                }
                if animated then
                    animate(button, properties)
                else
                    button.BackgroundTransparency = properties.BackgroundTransparency
                    button.TextColor3 = properties.TextColor3
                end
            end
        end

        for index, value in ipairs(values) do
            local button = Instance.new("TextButton")
            button.Name = "Option" .. tostring(index)
            button.Size = UDim2.new(1 / #values, offset, 1, 0)
            themed(button, "BackgroundColor3", "accent")
            button.BackgroundTransparency = 1
            button.Text = value
            themed(button, "TextColor3", "muted")
            button.Font = Enum.Font.GothamBold
            button.TextSize = 11
            button.AutoButtonColor = false
            button.LayoutOrder = index
            button.Parent = selector
            corner(button, 7)
            buttons[value] = button
            button.Activated:Connect(function()
                if selected == value then
                    return
                end
                selected = value
                render(true)
                callback(value)
            end)
        end
        render(false)
        return row
    end

    function UI.themeEditor(parent, initialColors, callback)
        local values = Theme.normalizeCustom(initialColors)
        local selectedToken = "panel"
        local hue, saturation, brightness = Theme.hexToHSV(values[selectedToken])

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 282)
        themed(row, "BackgroundColor3", "card")
        row.Parent = parent
        corner(row, 10)
        stroke(row, "border", 1, 0.22)

        local selectedLabel = label(row, Theme.LABELS[selectedToken], 10)
        selectedLabel.Position = UDim2.fromOffset(13, 5)
        selectedLabel.Size = UDim2.new(1, -146, 0, 26)
        selectedLabel.Font = Enum.Font.GothamBold

        local preview = Instance.new("Frame")
        preview.AnchorPoint = Vector2.new(1, 0)
        preview.Position = UDim2.new(1, -84, 0, 7)
        preview.Size = UDim2.fromOffset(23, 23)
        preview.BackgroundColor3 = Theme.toColor3(values[selectedToken])
        preview.Parent = row
        corner(preview, 6)
        local previewStroke = Instance.new("UIStroke")
        previewStroke.Color = Color3.fromRGB(255, 255, 255)
        previewStroke.Transparency = 0.45
        previewStroke.Parent = preview

        local hexBox = Instance.new("TextBox")
        hexBox.AnchorPoint = Vector2.new(1, 0)
        hexBox.Position = UDim2.new(1, -11, 0, 5)
        hexBox.Size = UDim2.fromOffset(66, 28)
        themed(hexBox, "BackgroundColor3", "background")
        themed(hexBox, "TextColor3", "accentBright")
        themed(hexBox, "PlaceholderColor3", "muted")
        hexBox.ClearTextOnFocus = false
        hexBox.Font = Enum.Font.GothamBold
        hexBox.TextSize = 9
        hexBox.Text = values[selectedToken]
        hexBox.Parent = row
        corner(hexBox, 7)
        stroke(hexBox, "border", 1, 0.16)

        local tokenList = Instance.new("ScrollingFrame")
        tokenList.Position = UDim2.fromOffset(13, 39)
        tokenList.Size = UDim2.new(1, -26, 0, 34)
        tokenList.BackgroundTransparency = 1
        tokenList.BorderSizePixel = 0
        tokenList.ScrollBarThickness = 2
        tokenList.ScrollingDirection = Enum.ScrollingDirection.X
        tokenList.CanvasSize = UDim2.fromOffset(#Theme.KEYS * 105, 0)
        themed(tokenList, "ScrollBarImageColor3", "accent")
        tokenList.Parent = row

        local tokenLayout = Instance.new("UIListLayout")
        tokenLayout.FillDirection = Enum.FillDirection.Horizontal
        tokenLayout.Padding = UDim.new(0, 5)
        tokenLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tokenLayout.Parent = tokenList

        local spectrum = Instance.new("Frame")
        spectrum.Name = "Spectrum"
        spectrum.Position = UDim2.fromOffset(13, 82)
        spectrum.Size = UDim2.new(1, -67, 0, 145)
        spectrum.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        spectrum.ClipsDescendants = false
        spectrum.Parent = row
        corner(spectrum, 8)

        local whiteLayer = Instance.new("Frame")
        whiteLayer.Size = UDim2.fromScale(1, 1)
        whiteLayer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        whiteLayer.BorderSizePixel = 0
        whiteLayer.Parent = spectrum
        corner(whiteLayer, 8)
        local whiteGradient = Instance.new("UIGradient")
        whiteGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1),
        })
        whiteGradient.Parent = whiteLayer

        local blackLayer = Instance.new("Frame")
        blackLayer.Size = UDim2.fromScale(1, 1)
        blackLayer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        blackLayer.BorderSizePixel = 0
        blackLayer.Parent = spectrum
        corner(blackLayer, 8)
        local blackGradient = Instance.new("UIGradient")
        blackGradient.Rotation = 90
        blackGradient.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0),
        })
        blackGradient.Parent = blackLayer

        local spectrumInput = Instance.new("TextButton")
        spectrumInput.Size = UDim2.fromScale(1, 1)
        spectrumInput.BackgroundTransparency = 1
        spectrumInput.Text = ""
        spectrumInput.AutoButtonColor = false
        spectrumInput.ZIndex = 4
        spectrumInput.Parent = spectrum

        local spectrumCursor = Instance.new("Frame")
        spectrumCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        spectrumCursor.Size = UDim2.fromOffset(14, 14)
        spectrumCursor.BackgroundTransparency = 1
        spectrumCursor.ZIndex = 5
        spectrumCursor.Parent = spectrum
        corner(spectrumCursor, 7)
        local spectrumCursorStroke = Instance.new("UIStroke")
        spectrumCursorStroke.Color = Color3.fromRGB(255, 255, 255)
        spectrumCursorStroke.Thickness = 2
        spectrumCursorStroke.Parent = spectrumCursor

        local hueBar = Instance.new("Frame")
        hueBar.Name = "Hue"
        hueBar.AnchorPoint = Vector2.new(1, 0)
        hueBar.Position = UDim2.new(1, -13, 0, 82)
        hueBar.Size = UDim2.fromOffset(28, 145)
        hueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueBar.ClipsDescendants = false
        hueBar.Parent = row
        corner(hueBar, 8)
        local hueGradient = Instance.new("UIGradient")
        hueGradient.Rotation = 90
        hueGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)),
            ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)),
            ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)),
            ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(1, 1, 1)),
        })
        hueGradient.Parent = hueBar

        local hueInput = Instance.new("TextButton")
        hueInput.Size = UDim2.fromScale(1, 1)
        hueInput.BackgroundTransparency = 1
        hueInput.Text = ""
        hueInput.AutoButtonColor = false
        hueInput.ZIndex = 4
        hueInput.Parent = hueBar

        local hueCursor = Instance.new("Frame")
        hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
        hueCursor.Position = UDim2.fromScale(0.5, hue)
        hueCursor.Size = UDim2.new(1, 6, 0, 4)
        hueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        hueCursor.ZIndex = 5
        hueCursor.Parent = hueBar
        corner(hueCursor, 3)
        local hueCursorStroke = Instance.new("UIStroke")
        hueCursorStroke.Color = Color3.fromRGB(20, 20, 20)
        hueCursorStroke.Parent = hueCursor

        local hint = label(row, "Arraste na paleta e na faixa lateral", 9)
        hint.Position = UDim2.fromOffset(13, 238)
        hint.Size = UDim2.new(1, -26, 0, 28)
        themed(hint, "TextColor3", "muted")

        local tokenButtons = {}
        local function renderTokenButtons()
            for token, button in pairs(tokenButtons) do
                local active = token == selectedToken
                themed(button, "BackgroundColor3", active and "accent" or "surface")
                themed(button, "TextColor3", active and "text" or "muted")
                button.BackgroundTransparency = active and 0 or 0.2
            end
        end

        local function renderColor(notify, commit)
            local hex = Theme.hsvToHex(hue, saturation, brightness)
            values[selectedToken] = hex
            spectrum.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
            spectrumCursor.Position = UDim2.fromScale(saturation, 1 - brightness)
            hueCursor.Position = UDim2.fromScale(0.5, hue)
            preview.BackgroundColor3 = Theme.toColor3(hex)
            hexBox.Text = hex
            if notify then
                callback(selectedToken, hex, commit == true)
            end
        end

        local function selectToken(token)
            if values[token] == nil then
                return
            end
            selectedToken = token
            hue, saturation, brightness = Theme.hexToHSV(values[token])
            selectedLabel.Text = Theme.LABELS[token] or token
            renderTokenButtons()
            renderColor(false, false)
        end

        for index, token in ipairs(Theme.KEYS) do
            local currentToken = token
            local button = Instance.new("TextButton")
            button.Name = "Token" .. tostring(index)
            button.Size = UDim2.fromOffset(100, 29)
            button.Text = Theme.LABELS[currentToken] or currentToken
            button.TextSize = 9
            button.TextTruncate = Enum.TextTruncate.AtEnd
            button.Font = Enum.Font.GothamBold
            button.AutoButtonColor = false
            button.LayoutOrder = index
            button.Parent = tokenList
            corner(button, 7)
            tokenButtons[currentToken] = button
            button.Activated:Connect(function()
                selectToken(currentToken)
            end)
        end

        local dragging = nil
        local dragInput = nil
        local dragKind = nil
        local scrollingParent = parent:IsA("ScrollingFrame") and parent or nil
        local scrollingWasEnabled = nil

        local function updateSpectrum(position)
            local size = spectrum.AbsoluteSize
            if size.X <= 0 or size.Y <= 0 then
                return
            end
            saturation = math.clamp((position.X - spectrum.AbsolutePosition.X) / size.X, 0, 1)
            brightness = 1 - math.clamp((position.Y - spectrum.AbsolutePosition.Y) / size.Y, 0, 1)
            renderColor(true, false)
        end

        local function updateHue(position)
            local height = hueBar.AbsoluteSize.Y
            if height <= 0 then
                return
            end
            hue = math.clamp((position.Y - hueBar.AbsolutePosition.Y) / height, 0, 1)
            renderColor(true, false)
        end

        local function beginDrag(target, input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1
                and input.UserInputType ~= Enum.UserInputType.Touch then
                return
            end
            dragging = target
            dragKind = input.UserInputType == Enum.UserInputType.Touch and "touch" or "mouse"
            dragInput = dragKind == "touch" and input or nil
            if scrollingParent then
                scrollingWasEnabled = scrollingParent.ScrollingEnabled
                scrollingParent.ScrollingEnabled = false
            end
            if target == "spectrum" then
                updateSpectrum(input.Position)
            else
                updateHue(input.Position)
            end
        end

        spectrumInput.InputBegan:Connect(function(input)
            beginDrag("spectrum", input)
        end)
        hueInput.InputBegan:Connect(function(input)
            beginDrag("hue", input)
        end)

        local changedConnection = UserInputService.InputChanged:Connect(function(input)
            local mouseMove = dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseMovement
            local touchMove = dragKind == "touch" and input == dragInput
            if not dragging or (not mouseMove and not touchMove) then
                return
            end
            if dragging == "spectrum" then
                updateSpectrum(input.Position)
            else
                updateHue(input.Position)
            end
        end)

        local endedConnection = UserInputService.InputEnded:Connect(function(input)
            local mouseEnd = dragKind == "mouse"
                and input.UserInputType == Enum.UserInputType.MouseButton1
            local touchEnd = dragKind == "touch" and input == dragInput
            if not dragging or (not mouseEnd and not touchEnd) then
                return
            end
            dragging = nil
            dragInput = nil
            dragKind = nil
            if scrollingParent and scrollingWasEnabled ~= nil then
                scrollingParent.ScrollingEnabled = scrollingWasEnabled
                scrollingWasEnabled = nil
            end
            callback(selectedToken, values[selectedToken], true)
        end)

        row.Destroying:Connect(function()
            if scrollingParent and scrollingWasEnabled ~= nil then
                scrollingParent.ScrollingEnabled = scrollingWasEnabled
            end
            changedConnection:Disconnect()
            endedConnection:Disconnect()
        end)

        hexBox.FocusLost:Connect(function()
            local normalized = Theme.normalizeHex(hexBox.Text)
            if not normalized then
                hexBox.Text = values[selectedToken]
                return
            end
            values[selectedToken] = normalized
            hue, saturation, brightness = Theme.hexToHSV(normalized)
            renderColor(false, false)
            callback(selectedToken, normalized, true)
        end)

        selectToken(selectedToken)
        return row
    end

    function UI.numberInput(parent, text, initial, minimum, maximum, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 50)
        themed(row, "BackgroundColor3", "card")
        row.Parent = parent
        corner(row, 10)
        stroke(row, "border", 1, 0.22)

        local title = label(row, text, 11)
        title.Position = UDim2.fromOffset(13, 0)
        title.Size = UDim2.new(1, -126, 1, 0)
        themed(title, "TextColor3", "text")

        local box = Instance.new("TextBox")
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Position = UDim2.new(1, -11, 0.5, 0)
        box.Size = UDim2.fromOffset(98, 31)
        themed(box, "BackgroundColor3", "background")
        themed(box, "TextColor3", "accentBright")
        themed(box, "PlaceholderColor3", "muted")
        box.ClearTextOnFocus = false
        box.Font = Enum.Font.GothamBold
        box.TextSize = 12
        box.Text = tostring(initial)
        box.Parent = row
        corner(box, 8)
        stroke(box, "border", 1, 0.12)

        local value = math.clamp(tonumber(initial) or minimum, minimum, maximum)
        local function commit()
            value = math.clamp(tonumber(box.Text) or value, minimum, maximum)
            box.Text = tostring(math.floor(value + 0.5))
            callback(value)
        end
        box.FocusLost:Connect(commit)
        return row, box
    end

    return UI
end

__factories["init"] = function()
    local Config = __require("Config")
    local ExecutorSettings = __require("Core/ExecutorSettings")
    local StateStore = __require("Core/StateStore")
    local Theme = __require("Core/Theme")
    local AutoCollect = __require("Features/AutoCollect")
    local AutoSell = __require("Features/AutoSell")
    local AutoRebirth = __require("Features/AutoRebirth")
    local AutoUpgrade = __require("Features/AutoUpgrade")

    local UI
    if Config.UI_STYLE == "Legacy" then
        UI = __require("UI/LegacyUI")
    else
        UI = __require("UI/ModernUI")
    end

    local Main = {}

    local function environment()
        if typeof(getgenv) == "function" then
            return getgenv()
        end
        return _G
    end

    function Main.start()
        local env = environment()
        local previous = env[Config.IDENTITY.GLOBAL_APP_KEY]
        if typeof(previous) == "table" and typeof(previous.Destroy) == "function" then
            previous:Destroy()
        end

        local stateStore = StateStore.new()
        local executorSettings = ExecutorSettings.new()
        local savedTheme = executorSettings:getTheme()
        local uiConfig = Config.UI_STYLE == "Legacy" and Config.UI or Config.MODERN_UI
        local window = UI.new(uiConfig.TITLE, {
            scalePercent = executorSettings:getScalePercent(),
            icon = executorSettings:getIcon(),
            theme = savedTheme,
        })

        local app = {
            destroyed = false,
            window = window,
        }
        env[Config.IDENTITY.GLOBAL_APP_KEY] = app

        local function getPage(pageName)
            if typeof(window.getPage) == "function" then
                return window:getPage(pageName)
            end
            return window.content
        end

        local orderByParent = setmetatable({}, { __mode = "k" })
        local function contentItem(instance)
            local parent = instance.Parent
            orderByParent[parent] = (orderByParent[parent] or 0) + 1
            instance.LayoutOrder = orderByParent[parent]
            return instance
        end

        local mainPage = getPage("Main")
        local visualPage = getPage("Visual")
        local miscPage = getPage("Misc")
        local settingsPage = getPage("Settings")
        local statusLabel

        local function setStatus(message)
            if typeof(window.setStatus) == "function" then
                window:setStatus(tostring(message))
            end
            if statusLabel and statusLabel.Parent then
                statusLabel.Text = tostring(message)
            end
        end

        contentItem(UI.section(mainPage, "AUTOMACAO"))
        statusLabel = contentItem(UI.info(mainPage, "Pronto", 38))

        local controllers = {
            autoCollect = AutoCollect.new(setStatus),
            autoSell = AutoSell.new(setStatus),
            autoRebirth = AutoRebirth.new(setStatus),
            autoUpgrade = AutoUpgrade.new(setStatus),
        }
        app.controllers = controllers

        local controls = {
            { key = "feature.autoCollect", label = "Auto Collect Leaves", controller = controllers.autoCollect },
            { key = "feature.autoSell", label = "Auto Sell (capacidade cheia)", controller = controllers.autoSell },
            { key = "feature.autoUpgrade", label = "Auto Upgrade Items", controller = controllers.autoUpgrade },
            { key = "feature.autoRebirth", label = "Auto Rebirth", controller = controllers.autoRebirth },
        }
        for _, control in ipairs(controls) do
            local current = control
            current.initial = stateStore:getBoolean(current.key, false)
            contentItem(UI.checkbox(mainPage, current.label, current.initial, function(enabled)
                stateStore:setBoolean(current.key, enabled)
                current.controller:setEnabled(enabled)
            end))
        end

        contentItem(UI.section(mainPage, "COMPORTAMENTO"))
        contentItem(UI.info(mainPage, "Collect usa os lotes reais de LeafData. Sell usa o marcador remoto observado, sem teleporte. Upgrade compra o item disponivel mais barato. Rebirth so envia com os requisitos completos.", 82))

        contentItem(UI.section(visualPage, "VISUAL"))
        contentItem(UI.section(miscPage, "MISC"))

        contentItem(UI.section(settingsPage, "INTERFACE"))
        if typeof(UI.segmented) == "function" and typeof(window.setScalePercent) == "function" then
            local customControls = {}
            local currentTheme = executorSettings:getTheme()
            local customDraft = currentTheme.custom

            contentItem(UI.segmented(
                settingsPage,
                "Tema",
                { "Dark", "Light", "Custom" },
                currentTheme.name,
                function(selected)
                    if not window:setTheme(selected, customDraft) then
                        return
                    end
                    executorSettings:setTheme(selected)
                    for _, control in ipairs(customControls) do
                        control.Visible = selected == "Custom"
                    end
                end
            ))

            contentItem(UI.segmented(
                settingsPage,
                "Tamanho da interface",
                { "25%", "50%", "75%", "100%", "125%", "150%" },
                tostring(executorSettings:getScalePercent()) .. "%",
                function(selected)
                    local scalePercent = tonumber(string.match(selected, "^(%d+)%%$"))
                    if scalePercent and window:setScalePercent(scalePercent) then
                        executorSettings:setScalePercent(scalePercent)
                    end
                end
            ))

            if typeof(UI.themeEditor) == "function" and typeof(window.setTheme) == "function" then
                local customSection = contentItem(UI.section(settingsPage, "PALETA CUSTOM"))
                customSection.Visible = currentTheme.name == "Custom"
                table.insert(customControls, customSection)

                local editor = contentItem(UI.themeEditor(
                    settingsPage,
                    customDraft,
                    function(token, hex, commit)
                        customDraft[token] = hex
                        window:setTheme("Custom", customDraft)
                        if commit then
                            executorSettings:setThemeColor(token, hex)
                        end
                    end
                ))
                editor.Visible = currentTheme.name == "Custom"
                table.insert(customControls, editor)
            end
        end

        function app:Destroy()
            if self.destroyed then
                return
            end
            self.destroyed = true
            for _, controller in pairs(controllers) do
                controller:stop()
            end
            stateStore:flush()
            window:Destroy()
            if env[Config.IDENTITY.GLOBAL_APP_KEY] == self then
                env[Config.IDENTITY.GLOBAL_APP_KEY] = nil
            end
        end

        window:setCloseCallback(function()
            app:Destroy()
        end)
        for _, control in ipairs(controls) do
            control.controller:setEnabled(control.initial)
        end
        setStatus("Pronto")
        return app
    end

    return Main
end

__require = function(name)
    if __cache[name] ~= nil then
        return __cache[name]
    end
    local factory = __factories[name]
    if not factory then
        error("[GOATHub] Modulo inexistente: " .. tostring(name), 2)
    end
    local value = factory()
    if value == nil then
        value = true
    end
    __cache[name] = value
    return value
end

return __require("init").start()
