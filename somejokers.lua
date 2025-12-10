SMODS.Atlas({
    key = "modicon", 
    path = "ModIcon.png", 
    px = 34,
    py = 34,
    atlas_table = "ASSET_ATLAS"
})

SMODS.Atlas({
    key = "Jokers", 
    path = "Jokers.png", 
    px = 71,
    py = 95, 
    atlas_table = "ASSET_ATLAS"
})

local JOKERS ={
    "uptheranks",
    "extendedplay"
}

local function load_jokers()
    for _, name in ipairs(JOKERS) do
        local path = "jokers/"..name..".lua"
        assert(SMODS.load_file(path))()
    end
end

load_jokers()