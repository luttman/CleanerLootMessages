-- Color codes for currencies
local COPPER_COLOR = "|cffeda55f" -- Bronze color for Copper
local SILVER_COLOR = "|cffc7c7cf" -- Silver color for Silver
local GOLD_COLOR = "|cffffd700"   -- Gold color for Gold
local RESET_COLOR = "|r"

-- Function to color-code currency strings
local function ColorCurrencyString(currencyString)
    -- Patterns to match currency amounts (e.g., "1 Gold 2 Silver 3 Copper")
    local gold, silver, copper
    gold = currencyString:match("(%d+) Gold")
    silver = currencyString:match("(%d+) Silver")
    copper = currencyString:match("(%d+) Copper")

    local result = currencyString

    -- Replace each currency with color-coded version
    if gold then
        result = result:gsub("(%d+) Gold", GOLD_COLOR .. "%1 Gold" .. RESET_COLOR)
    end
    if silver then
        result = result:gsub("(%d+) Silver", SILVER_COLOR .. "%1 Silver" .. RESET_COLOR)
    end
    if copper then
        result = result:gsub("(%d+) Copper", COPPER_COLOR .. "%1 Copper" .. RESET_COLOR)
    end

    return result
end

-- Your existing string pattern match function
function stringPaternMatch(oldString, newString)
    local oldPatern = string.gmatch(oldString, "%%.");
    local newPatern = string.gmatch(newString, "%%.");
    local oldPaternIteration = oldPatern();
    local newPaternIteration = newPatern();
    while oldPaternIteration ~= nil or newPaternIteration ~= nil do
        if oldPaternIteration ~= newPaternIteration then
            return false;
        end
        oldPaternIteration = oldPatern();
        newPaternIteration = newPatern();
    end
    return true;
end

-- Your translation table
local translateTable = {
    ["CURRENCY_GAINED"] = "+ %s",
    ["CURRENCY_GAINED_MULTIPLE"] = "+ %s x%d",
    ["CURRENCY_GAINED_MULTIPLE_BONUS"] = "+ %s x%d (bonus)",
    ["CURRENCY_LOST_FROM_DEATH"] = "- %s x%d",
    ["LOOT_CURRENCY_REFUND"] = "+ %s x%d",
    ["LOOT_DISENCHANT_CREDIT"] = "- %s : %s (Disenchant)",
    ["LOOT_ITEM"] = "+ %s : %s",
    ["LOOT_ITEM_BONUS_ROLL"] = "+ %s : %s (bonus)",
    ["LOOT_ITEM_BONUS_ROLL_MULTIPLE"] = "+ %s : %s x%d (bonus)",
    ["LOOT_ITEM_BONUS_ROLL_SELF"] = "+ %s (bonus)",
    ["LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE"] = "+ %s x%d (bonus)",
    ["LOOT_ITEM_MULTIPLE"] = "+ %s : %s x%d",
    ["LOOT_ITEM_PUSHED"] = "+ %s : %s",
    ["LOOT_ITEM_PUSHED_MULTIPLE"] = "+ %s : %s x%d",
    ["LOOT_ITEM_PUSHED_SELF"] = "+ %s",
    ["LOOT_ITEM_PUSHED_SELF_MULTIPLE"] = "+ %s x%d",
    ["LOOT_ITEM_REFUND"] = "+ %s",
    ["LOOT_ITEM_REFUND_MULTIPLE"] = "+ %s x%d",
    ["LOOT_ITEM_SELF"] = "+ %s",
    ["LOOT_ITEM_SELF_MULTIPLE"] = "+ %s x%d",
    ["LOOT_ITEM_WHILE_PLAYER_INELIGIBLE"] = "+ %s : %s",
    ["GUILD_NEWS_FORMAT4"] = "+ %s : %s (craft)",
    ["GUILD_NEWS_FORMAT8"] = "+ %s : %s",
    ["CREATED_ITEM"] = "+ %s : %s (craft)",
    ["CREATED_ITEM_MULTIPLE"] = "+ %s : %s x%d (craft)",
    ["LOOT_ITEM_CREATED_SELF"] = "+ %s (craft)",
    ["LOOT_ITEM_CREATED_SELF_MULTIPLE"] = "+ %s x%d (craft)",
    ["YOU_LOOT_MONEY"] = "+ %s",
    ["LOOT_MONEY_SPLIT"] = "+ %s (Shared)",
    ["YOU_LOOT_MONEY_GUILD"] = "+ %s (%s Guild)",
    ["TRADESKILL_LOG_FIRSTPERSON"] = "+ %s (craft)",
    ["TRADESKILL_LOG_THIRDPERSON"] = "+ %s : %s (craft)",
    ["COMBATLOG_XPGAIN_EXHAUSTION1"] = "%s : +%d xp (%s %s)",
    ["COMBATLOG_XPGAIN_EXHAUSTION1_GROUP"] = "%s : +%d xp (%s %s, +%d group)",
    ["COMBATLOG_XPGAIN_EXHAUSTION1_RAID"] = "%s : +%d xp (%s %s, -%d raid)",
    ["COMBATLOG_XPGAIN_EXHAUSTION2"] = "%s : +%d xp (%s %s)",
    ["COMBATLOG_XPGAIN_EXHAUSTION2_GROUP"] = "%s : +%d xp (%s %s, +%d group)",
    ["COMBATLOG_XPGAIN_EXHAUSTION2_RAID"] = "%s : +%d xp (%s %s, -%d raid)",
    ["COMBATLOG_XPGAIN_EXHAUSTION4"] = "%s : +%d xp (%s penalty %s)",
    ["COMBATLOG_XPGAIN_EXHAUSTION4_GROUP"] = "%s : +%d xp (%s penalty %s, +%d group)",
    ["COMBATLOG_XPGAIN_EXHAUSTION4_RAID"] = "%s : +%d xp (%s xp %s, -%d raid)",
    ["COMBATLOG_XPGAIN_EXHAUSTION5"] = "%s : +%d xp (%s penalty %s)",
    ["COMBATLOG_XPGAIN_EXHAUSTION5_GROUP"] = "%s : +%d xp (%s penalty %s, +%d group)",
    ["COMBATLOG_XPGAIN_EXHAUSTION5_RAID"] = "%s : +%d xp (%s penalty %s, -%d raid)",
    ["COMBATLOG_XPGAIN_FIRSTPERSON"] = "%s : +%d xp",
    ["COMBATLOG_XPGAIN_QUEST"] = "+%d xp (%s %s)",
    ["COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED"] = "+%d xp",
    ["COMBATLOG_XPGAIN_FIRSTPERSON_GROUP"] = "%s : +%d xp (+%d group)",
    ["COMBATLOG_XPGAIN_FIRSTPERSON_RAID"] = "%s : +%d xp (-%d raid)",
    ["FACTION_STANDING_CHANGED"] = "%s : %s",
    ["FACTION_STANDING_CHANGED_GUILD"] = "%s : guild",
    ["FACTION_STANDING_CHANGED_GUILDNAME"] = "%s : %s",
    ["FACTION_STANDING_DECREASED"] = "%s - %d",
    ["FACTION_STANDING_DECREASED_GENERIC"] = "%s -",
    ["FACTION_STANDING_INCREASED"] = "%s + %d",
    ["FACTION_STANDING_INCREASED_ACH_BONUS"] = "%s + %d (+%.1f bonus)",
    ["FACTION_STANDING_INCREASED_ACH_PART"] = "(+%.1f bonus)",
    ["FACTION_STANDING_INCREASED_BONUS"] = "%s + %d. (+%.1f bonus)",
    ["FACTION_STANDING_INCREASED_DOUBLE_BONUS"] = "%s + %d. (+%.1f + %.1f bonus)",
    ["FACTION_STANDING_INCREASED_GENERIC"] = "%s +",
    ["SKILL_RANK_UP"] = "%s = %d"
};

-- Apply translations
table.foreach(translateTable, function(k, v)
    if _G[k] ~= nil and stringPaternMatch(_G[k], v) == true then
        _G[k] = v
    end
end);

-- Chat filter to color currency messages
local function ChatFilter(self, event, message, ...)
    -- Check for currency-related events
    if event == "CHAT_MSG_MONEY" or event == "CHAT_MSG_LOOT" then
        -- Look for currency patterns in the message
        if message:match("%d+ Gold") or message:match("%d+ Silver") or message:match("%d+ Copper") then
            message = ColorCurrencyString(message)
        end
    end
    return false, message, ...
end

-- Register the chat filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", ChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", ChatFilter)