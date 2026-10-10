local function check(modern, appearanceFormat, hasAppearanceFilter)
    local filters = {}
    local secret = setmetatable({}, { __index = function() error("Secret message was inspected") end })
    local env = setmetatable({
        LOOT_ITEM_SELF = "You receive loot: %s.",
        LOOT_ITEM_MULTIPLE = "%s receives loot: %s x%d.",
        LOOT_ITEM_CREATED_SELF = "You create: %s.",
        FACTION_STANDING_INCREASED_ACH_BONUS = "Reputation with %s increased by %d. Bonus: %.1f%%.",
        FACTION_STANDING_INCREASED_ACH_PART = "Bonus: %.1f%%.",
        FACTION_STANDING_INCREASED_DOUBLE_BONUS = "%s: %d (%.1f%% and %.1f%%).",
        CURRENCY_GAINED = "Currency: %d", -- A changed argument type must be preserved.
        LOOT_ITEM = "%2$s received by %1$s", -- Localized argument ordering.
        LOOT_ITEM_PUSHED = "%s receives %s (%d)", -- Extra client argument.
        SKILL_RANK_UP = true, -- Unexpected client value.
        ERR_SKILL_UP_SI = "Your skill in %s has increased to %d.",
        table = {}, -- WoW does not need the removed table.foreach helper.
        ERR_LEARN_TRANSMOG_S = appearanceFormat,
    }, { __index = _G })
    env._G = env
    local function register(event, callback)
        assert(not filters[event], "Duplicate chat filter")
        filters[event] = callback
    end
    if modern then
        env.ChatFrameUtil = { AddMessageEventFilter = register }
        env.ChatFrame_AddMessageEventFilter = function() error("Deprecated API used") end
        env.issecretvalue = function(value) return value == secret end
    else
        env.ChatFrame_AddMessageEventFilter = register
    end

    local addon = assert(loadfile("CleanerLootMessages.lua"))
    setfenv(addon, env)
    addon()
    assert(env.LOOT_ITEM_SELF == "+ %s")
    assert(env.LOOT_ITEM_MULTIPLE == "+ %s : %s x%d")
    assert(string.format(env.LOOT_ITEM_MULTIPLE, "Player", "[Item]", 2) == "+ Player : [Item] x2")
    assert(env.LOOT_ITEM_CREATED_SELF == "+ %s (craft)")
    assert(string.format(env.FACTION_STANDING_INCREASED_ACH_BONUS, "Faction", 10, 2.5) == "Faction + 10 (+2.5 bonus)")
    assert(env.FACTION_STANDING_INCREASED_ACH_PART == "(+%.1f bonus)")
    assert(env.FACTION_STANDING_INCREASED_DOUBLE_BONUS == "%s + %d. (+%.1f + %.1f bonus)")
    assert(env.CURRENCY_GAINED == "Currency: %d")
    assert(env.LOOT_ITEM == "%2$s received by %1$s")
    assert(env.LOOT_ITEM_PUSHED == "%s receives %s (%d)")
    assert(env.SKILL_RANK_UP == true)
    assert(env.ERR_SKILL_UP_SI == "%s = %d")
    for skill, rank in pairs({Axes = 27, Skinning = 50, Unarmed = 61, Guns = 50}) do
        assert(string.format(env.ERR_SKILL_UP_SI, skill, rank) == skill .. " = " .. rank)
    end
    assert(rawget(env, "LOOT_ITEM_REFUND") == nil)
    assert(rawget(env, "stringPaternMatch") == nil, "Helper leaked into WoW globals")
    assert(filters.CHAT_MSG_LOOT == nil, "Item names must not be recolored")

    local filter = assert(filters.CHAT_MSG_MONEY)
    local hidden, message, sender, trailing = filter(nil, "CHAT_MSG_MONEY", "+ 1 Gold 2 Silver 3 Copper", "Player", 42)
    assert(hidden == false and sender == "Player" and trailing == 42)
    assert(message == "+ |cffffd7001 Gold|r |cffc7c7cf2 Silver|r |cffeda55f3 Copper|r")
    local coins = "+ 1|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"
    assert(select(2, filter(nil, "CHAT_MSG_MONEY", coins)) == coins)
    assert(select(2, filter(nil, "CHAT_MSG_MONEY", "+ 2 Goldmuenzen")) == "+ 2 Goldmuenzen")
    assert(filter(nil, "CHAT_MSG_MONEY", nil) == false)
    if modern then
        assert(filter(nil, "CHAT_MSG_MONEY", secret) == false)
    end

    local appearanceFilter = filters.CHAT_MSG_SYSTEM
    if hasAppearanceFilter then
        assert(appearanceFilter)
        assert(env.ERR_LEARN_TRANSMOG_S == appearanceFormat, "Blizzard's appearance format must be preserved")
        for _, link in ipairs({
            "|cffa335ee|Hitem:12345::::::::|h[Gloves (Heroic) + 100%]|h|r",
            "|cnIQ4:|Hitem:12345::::::::|h[Rainwalker Boots]|h|r",
            "|cnIQ3:|Hitem:12346::::::::|h[Sun-beaten Cloak]|h|r",
            "|Htransmogappearance:12345|h[Appearance]|h",
        }) do
            local original = string.format(appearanceFormat, link)
            local hidden, message, sender, trailing = appearanceFilter(nil, "CHAT_MSG_SYSTEM", original, "", 42)
            assert(hidden == false and message == "+ transmog : " .. link)
            assert(sender == "" and trailing == 42)
            for _, unrelated in ipairs({"Player has come online.", "Guild: " .. original, original .. " Extra text", "You receive loot: " .. link .. ".", "+ transmog : " .. link}) do
                assert(select(2, appearanceFilter(nil, "CHAT_MSG_SYSTEM", unrelated)) == unrelated)
            end
        end
        assert(appearanceFilter(nil, "CHAT_MSG_SYSTEM", nil) == false)
        local plain = string.format(appearanceFormat, "Item without a hyperlink")
        assert(select(2, appearanceFilter(nil, "CHAT_MSG_SYSTEM", plain)) == plain)
        if modern then
            assert(appearanceFilter(nil, "CHAT_MSG_SYSTEM", secret) == false)
        end
    else
        assert(appearanceFilter == nil, "Unsupported appearance formats must not register a filter")
    end
end

check(false)
check(true)
for _, modern in ipairs({false, true}) do
    check(modern, "%s has been added to your appearance collection.", true)
    check(modern, "%s wurde deiner Vorlagensammlung hinzugefuegt.", true)
    check(modern, "Appearance (%s) + [collection] 100%% unlocked!", true)
    check(modern, "%s / %d appearances collected.", false)
    check(modern, true, false)
end
print("PASS: chat APIs, formats, money, secret messages, skill gains and localized appearance notifications with intact links")
