local mod = SMODS.current_mod
local mod_id = mod.id

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

local SJ_JOKERS ={
    "uptheranks",
    "extendedplay"
}

local function load_jokers()
    for _, name in ipairs(SJ_JOKERS) do
        local path = "jokers/"..name..".lua"
        assert(SMODS.load_file(path))()
    end
end

load_jokers()

local SJ_JOKER_KEYS = {}
for i, joker_key in ipairs(SJ_JOKERS) do
    table.insert(SJ_JOKER_KEYS, "j_somejokers_" .. joker_key)
end

-----------------------------
-- JOKER TOGGLE STUFF HERE --
-----------------------------

local function enableJoker(key)
    mod.config.disabled_jokers[key] = nil
    SMODS.save_mod_config(mod)

    -- inject into current run
    if G.GAME and G.GAME.banned_keys then
        G.GAME.banned_keys[key] = nil
    end

    return true
end


local function disableJoker(key)
    mod.config.disabled_jokers[key] = true
    SMODS.save_mod_config(mod)

    -- inject into current run
    if G.GAME and G.GAME.banned_keys then
        G.GAME.banned_keys[key] = true
    end

    return true
end


-- hook into game start to inject disabled_jokers into banned_keys
local game_start_run_ref = Game.start_run
function Game:start_run(args)
    local result = game_start_run_ref(self, args)
    
    G.GAME.banned_keys = G.GAME.banned_keys or {}
    for key, _ in pairs(mod.config.disabled_jokers) do
        G.GAME.banned_keys[key] = true
    end
    
    return result
end

-------------------
-- UI STUFF HERE --
-------------------

G.FUNCS.open_joker_toggle = function(e)
    G.SETTINGS.paused = true
    G.FUNCS.overlay_menu({
        definition = create_UIBox_joker_toggle()
    })
end

local JOKER_CARD_REFS = {}

G.FUNCS.toggle_jokers = function(e)
    local joker_key = e.config.id
    local joker = G.P_CENTERS[joker_key]
    local card = JOKER_CARD_REFS[joker_key]
    
    if mod.config.disabled_jokers[joker_key] then
        if enableJoker(joker_key) then
            e.config.colour = G.C.GREEN
            G.JOKER_TOGGLE_STATES[joker_key] = "Enabled"
            card:juice_up(0.3, 0.5)
            card.greyed = false 
        end
    else
        if disableJoker(joker_key) then
            e.config.colour = G.C.UI.TEXT_INACTIVE
            G.JOKER_TOGGLE_STATES[joker_key] = "Disabled"
            card:juice_up(0.3, 0.5)
            card.greyed = true
        end
    end
end

G.FUNCS.enable_all_jokers = function(e)
    for i, joker_key in ipairs(SJ_JOKER_KEYS) do
        if mod.config.disabled_jokers[joker_key] then
            enableJoker(joker_key)
            G.JOKER_TOGGLE_STATES[joker_key] = "Enabled"
            
            local card = JOKER_CARD_REFS[joker_key]
            if card then
                card.greyed = false
            end
        end
    end
    
    -- just refresh the menu, too lazy to store button references for now
    G.FUNCS.overlay_menu({
        definition = create_UIBox_joker_toggle()
    })
end

G.FUNCS.disable_all_jokers = function(e)
    for i, joker_key in ipairs(SJ_JOKER_KEYS) do
        if not mod.config.disabled_jokers[joker_key] then
            disableJoker(joker_key)
            G.JOKER_TOGGLE_STATES[joker_key] = "Disabled"
            
            local card = JOKER_CARD_REFS[joker_key]
            if card then
                card.greyed = true
            end
        end
    end
    
    -- just refresh the menu, too lazy to store button references for now
    G.FUNCS.overlay_menu({
        definition = create_UIBox_joker_toggle()
    })
end

-- joker toggle menu ui
function create_UIBox_joker_toggle()
    local joker_rows = {}
    local current_row = {}
    local jokers_per_row = 5

    if not G.JOKER_TOGGLE_STATES then
        G.JOKER_TOGGLE_STATES = {}
    end
    
    for i, joker_key in ipairs(SJ_JOKER_KEYS) do
        local joker_center = G.P_CENTERS[joker_key]
    
        if joker_center then
            local card = Card(
                0, 0,
                0.7 * G.CARD_W,
                0.7 * G.CARD_H,
                nil,
                joker_center,
                { bypass_discovery_center = true }
            )

            if mod.config.disabled_jokers[joker_key] then
                card.greyed = true
            end
            
            JOKER_CARD_REFS[joker_key] = card

            local card_colour = mod.config.disabled_jokers[joker_key] and G.C.UI.TEXT_INACTIVE or G.C.GREEN
            G.JOKER_TOGGLE_STATES[joker_key] = mod.config.disabled_jokers[joker_key] and "Disabled" or "Enabled"
                
            
            -- joker card and button below it
                table.insert(current_row, {
                    n = G.UIT.C,
                    config = {
                        align = "cm",
                        padding = 0.05,
                    },
                    nodes = {
                        -- joker
                        { n = G.UIT.R, config = { align = "cm" }, nodes = {
                            { n = G.UIT.O, config = { object = card } }
                        }},
                        -- button
                        { n = G.UIT.R, config = { align = "cm", padding = 0.05 }, nodes = {
                            {
                                n = G.UIT.C,
                                config = {
                                    align = "cm",
                                    padding = 0.1,
                                    r = 0.1,
                                    minw = 0.7 * G.CARD_W,
                                    minh = 0.4,
                                    colour = card_colour,
                                    button = "toggle_jokers",
                                    id = joker_key,
                                    hover = true,
                                    shadow = true,
                                },
                                -- text
                                nodes = {
                                    {
                                        n = G.UIT.T,
                                        config = {
                                            ref_table = G.JOKER_TOGGLE_STATES,
                                            ref_value = joker_key,
                                            scale = 0.3,
                                            colour = G.C.UI.TEXT_LIGHT
                                        }
                                    }
                                }
                            }
                        }}
                    }
                })

            
            card:start_materialize()
            
            if #current_row >= jokers_per_row then
                table.insert(joker_rows, {
                    n = G.UIT.R,
                    config = { align = "cm", padding = 0.05 },
                    nodes = current_row
                })
                current_row = {}
            end
        end
    end
    
    if #current_row > 0 then
        table.insert(joker_rows, {
            n = G.UIT.R,
            config = { align = "cm", padding = 0.05 },
            nodes = current_row
        })
    end
    
    return create_UIBox_generic_options({
        back_func = 'openModUI_' .. mod_id,
        contents = {
            -- title
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.2 },
                nodes = {
                    {
                        n = G.UIT.T,
                        config = {
                            text = "Joker Toggle Menu",
                            scale = 0.6,
                            colour = G.C.UI.TEXT_LIGHT,
                            shadow = true
                        }
                    }
                }
            },
            -- enable all / disable all buttons
            {
                n = G.UIT.R,
                config = { align = "cm", padding = 0.1 },
                nodes = {
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.05 },
                        nodes = {
                            UIBox_button({
                                button = "enable_all_jokers",
                                label = {"Enable All"},
                                minw = 0.7 * G.CARD_W,
                                minh = 0.4,
                                scale = 0.3,
                                colour = G.C.GREEN,
                            })
                        }
                    },
                    {
                        n = G.UIT.C,
                        config = { align = "cm", padding = 0.05 },
                        nodes = {
                            UIBox_button({
                                button = "disable_all_jokers",
                                label = {"Disable All"},
                                minw = 0.7 * G.CARD_W,
                                minh = 0.4,
                                scale = 0.3,
                                colour = G.C.UI.TEXT_INACTIVE,
                            })
                        }
                    }
                }
            },
            -- joker grid
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    padding = 0.2,
                    r = 0.1,
                    colour = G.C.BLACK,
                    emboss = 0.05,
                    minh = 4,
                },
                nodes = joker_rows
            },
        }
    })
end

mod.config_tab = function()    
    return {
        n = G.UIT.ROOT,
        config = {
            align = "cm",
            padding = 0.05,
            colour = G.C.CLEAR,
        },
        nodes = {
            -- black box container
            {
                n = G.UIT.R,
                config = {
                    align = "cm",
                    padding = 0.2,
                    r = 0.1,
                    colour = G.C.BLACK,
                    emboss = 0.05,
                    minh = 2,
                    minw = 6,
                },
                nodes = {
                    -- joker toggle menu button
                    {
                        n = G.UIT.R,
                        config = { align = "cm", padding = 0.1 },
                        nodes = {
                            UIBox_button({
                                button = "open_joker_toggle",
                                label = {"Joker Toggle Menu"},
                                minw = 5,
                                minh = 1.2,
                                scale = 0.6,
                                colour = G.C.BLUE,
                            })
                        }
                    },
                }
            }
        }
    }
end