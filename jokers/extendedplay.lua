SMODS.Joker{ --Extended Play
    key = "extendedplay",
    config = {
        extra = {
            hand_change = 1
        }
    },
    loc_txt = {
        ['name'] = 'Extended Play',
        ['text'] = {
            [1] = '{C:blue}+1{} hand per round'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 1,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 1,
    blueprint_compat = false,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',

    add_to_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hand_change
    end,

    remove_from_deck = function(self, card, from_debuff)
        G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hand_change
    end
}