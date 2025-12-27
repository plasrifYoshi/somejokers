SMODS.Joker{ --Up the Ranks
    key = "uptheranks",
    config = {
        extra = {
        }
    },
    loc_txt = {
        ['name'] = 'Up the Ranks',
        ['text'] = {
            [1] = 'Increases rank of',
            [2] = 'first played card',
            [3] = 'by {C:attention}1{} when scored'
        },
        ['unlock'] = {
            [1] = 'Unlocked by default.'
        }
    },
    pos = {
        x = 0,
        y = 0
    },
    display_size = {
        w = 71 * 1, 
        h = 95 * 1
    },
    cost = 6,
    rarity = 3,
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    unlocked = true,
    discovered = true,
    atlas = 'Jokers',
    
    calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play then
        local other_card = context.other_card
        if other_card == context.scoring_hand[1] then
            local was_debuffed = other_card.debuff
            
            SMODS.modify_rank(other_card, 1, true)
            
            if G.GAME.blind.config.blind.key == 'bl_pillar' then
                other_card.debuff = was_debuffed
            end

            local card_suit = SMODS.Suits[other_card.base.suit].card_key
            local card_rank = SMODS.Ranks[other_card.base.value].card_key
            local newcard = G.P_CARDS[('%s_%s'):format(card_suit, card_rank)]

            return {
                extra = {
                    func = function()
                        G.E_MANAGER:add_event(Event({
                            trigger = 'immediate',
                            func = function()
                                other_card:set_sprites(nil, newcard)
                                return true
                            end
                        }))

                        card_eval_status_text(other_card, 'extra', nil, nil, nil, {
                            message = "Rank Increased!",
                            colour = G.C.FILTER
                        })

                        return true
                    end
                }
            }
        end
    end
end
}