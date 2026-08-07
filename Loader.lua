-- Hospede Distribution/Hub.bundle.lua e configure somente esta URL.
local BUNDLE_URL = "https://raw.githubusercontent.com/TaxD-drop/GOATFolha/refs/heads/main/Distribution/Hub.bundle.lua"
local MAX_BUNDLE_BYTES = 2 * 1024 * 1024

if BUNDLE_URL:find("COLOQUE_AQUI", 1, true) then
    warn("[GOATFolha] Configure BUNDLE_URL em Loader.lua.")
    return
end
if not BUNDLE_URL:match("^https://") then
    warn("[GOATFolha] BUNDLE_URL precisa usar HTTPS.")
    return
end

local env = if typeof(getgenv) == "function" then getgenv() else _G
env.__GOATFOLHA_RELOAD_URL = BUNDLE_URL

local ok, source = pcall(function()
    return game:HttpGet(BUNDLE_URL)
end)
if not ok then
    warn("[GOATFolha] Falha ao baixar o bundle: " .. tostring(source))
    return
end
if typeof(source) ~= "string" or #source == 0 or #source > MAX_BUNDLE_BYTES then
    warn("[GOATFolha] Bundle vazio ou acima do limite permitido.")
    return
end

local chunk, compileError = loadstring(source)
if not chunk then
    warn("[GOATFolha] Bundle invalido: " .. tostring(compileError))
    return
end

return chunk()
