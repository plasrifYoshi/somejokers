
SMODS.Joker{ --Diver
    key = "diver",
    loc_txt = {
        ['name'] = 'Diver',
        ['text'] = {
            [1] = 'Gains {C:chips}+8{} Chips',
            [2] = 'if played hand',
            [3] = 'contains a {C:attention}Flush{}',
            [4] = '{C:inactive}(Currently{} {C:blue}+#1#{} {C:inactive}Chips){}'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 2,
        y = 0
    },
    display_size = {
        w = 71 * 1,
        h = 95 * 1
    },
    cost = 4,
    rarity = 1,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = false,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',

    config = { extra = { chips = 0, chip_mod = 8 } },
    loc_vars = function(self, info_queue, card)
        return { vars = { card.ability.extra.chips, card.ability.extra.chip_mod } }
    end,
    calculate = function(self, card, context)
        if context.before and not context.blueprint and next(context.poker_hands['Flush']) then
            card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
            return {
                message = localize('k_upgrade_ex'),
                colour = G.C.ORANGE,
            }
        end
        if context.joker_main  then
            return {
                message = localize {
                    type = 'variable',
                    key = 'a_chips',
                    vars = {card.ability.extra.chips}
                },
                chip_mod = card.ability.extra.chips,
                colour = G.C.CHIPS
            }
        end
    end
}