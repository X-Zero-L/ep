local extension = Package:new("ellye_fans")
extension.extensionName = "ep"
local U = require "packages/utility/utility"
local H = require "packages/hegemony/util"

Fk:loadTranslationTable{
  ["ellye_fans"] = "怡批",
  ["ep_k__ep"] = "怡"
}

--[[
--- 构造函数，不可随意调用。
---@param package Package @ 武将所属包
---@param name string @ 武将名字
---@param kingdom string @ 武将所属势力
---@param hp integer @ 武将初始体力
---@param maxHp integer @ 武将初始最大体力
---@param gender Gender @ 武将性别
function General:initialize(package, name, kingdom, hp, maxHp, gender)
 --]]
local ellye = General:new(extension, "ep__ellye", "ep_k__ep", 5)
Fk:loadTranslationTable{
  ["ep__ellye"] = "怡宝",
  ["#ep__ellye"] = "龙根",
  ["designer:ep__ellye"] = "怡批",
  ["cv:ep__ellye"] = "怡批",
  ["illustrator:ep__ellye"] = "怡批",
}

local longgen = fk.CreateDistanceSkill{
  name = "longgen",
  frequency = Skill.Compulsory, -- 锁定技
  correct_func = function(self, from, to)
    if from:hasSkill(self) then 
    return -3 -- 攻击范围+3
    end
    if to:hasSkill(self) then
    return -3 -- 防御范围-3 双刃剑技能
    end
  end,
}

Fk:loadTranslationTable{
  ["longgen"] = "龙根",
  [":longgen"] = "锁定技，你计算的与其他角色的距离-3；其他角色计算的与你的距离-3。",
}

local huixue = fk.CreateTriggerSkill{
  name = "huixue",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data) -- 在自己的出牌阶段开始时
    return target == player and player:hasSkill(self) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    -- 回复1点体力，然后摸一张牌，跳过出牌阶段
    room:recover{
      who = player,
      num = 1,
    }
    player:drawCards(1, self.name)
    -- player:endPlayPhase() 没有效果
    room.logic:getCurrentEvent():findParent(GameEvent.Phase):shutdown()
  end,
}

Fk:loadTranslationTable{
  ["huixue"] = "回血",
  [":huixue"] = "出牌阶段开始时，你可以回复1点体力并摸一张牌，然后跳过出牌阶段。",
}

-- 龙恩，摸牌阶段开始时，你可以少摸一张牌，视为使用一张【五谷丰登】
local longen = fk.CreateTriggerSkill{
  name = "longen",
  anim_type = "drawcard",
  events = {fk.DrawNCards},
  can_trigger = function(self, event, target, player, data) -- 在自己的摸牌阶段开始时
    return target == player and player:hasSkill(self) and player.phase == Player.Draw
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = target:getCardIds("h")
    room:useVirtualCard("amazing_grace", {}, player, room.alive_players, self.name)
    data.n = data.n - 1
  end,
}
Fk:loadTranslationTable{
  ["longen"] = "龙恩",
  [":longen"] = "摸牌阶段开始时，你可以少摸1张牌，视为使用一张【五谷丰登】。",
}
-- 号令，主公技，限定技，出牌阶段限一次，号令ep，怡宝指定一名角色，势力为“怡”的所有角色从以下效果选择一个：
--[[
1. 视为对该角色使用一张【杀】；
2. 视为对你使用一张【杀】。
]]
local haoling = fk.CreateActiveSkill{
  name = "haoling$",
  frequency = Skill.Limited, -- 限定技
  anim_type = "offensive",
  pcard_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryGame) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local atk_you = {}
    local atk_target = {}
    for _, p in ipairs(room:getOtherPlayers(player)) do
      if p.kingdom ==  "ep_k__ep" and player.isAlive then
          if room:askForSkillInvoke(p, self.name, {}, "#haoling-invoke::"..player.id) then -- 对你使用一张【杀】
            -- table.insert(atk_target, p)
            local card = Fk:cloneCard("slash")
            card.skillName = self.name
            room:useCard{
              card = card,
              from = p.id,
              tos = {{ target.id }} ,
            }
          else -- 视为对你使用一张【杀】
            -- table.insert(atk_you, p)
            local card = Fk:cloneCard("slash")
            card.skillName = self.name
            room:useCard{
              card = card,
              from = p.id,
              tos = {{ player.id }} ,
            }
          end
      end
    end
  end,
}
Fk:loadTranslationTable{
  ["haoling"] = "号令",
  [":haoling"] = "主公技，限定技，出牌阶段，你可以指定一名角色，势力为“怡”的所有角色从以下效果选择一个："..
  "1. 视为对该角色使用一张【杀】；2. 视为对你使用一张【杀】。",
  ["#haoling-invoke"] = "号令：你可以视为对怡宝指定的角色使用一张【杀】，否则你视为对怡宝使用一张【杀】",
}

ellye:addSkill(longen)
ellye:addSkill(huixue)
ellye:addSkill(longgen)
ellye:addSkill(haoling)


local sanlai = General:new(extension, "ep__sanlai", "ep_k__ep", 3)
Fk:loadTranslationTable{
  ["ep__sanlai"] = "三来",
  ["#ep__sanlai"] = "钓鱼佬",
  ["designer:ep__sanlai"] = "怡批",
  ["cv:ep__sanlai"] = "怡批",
  ["illustrator:ep__sanlai"] = "怡批",
}

-- 打窝，锁定技，当你受到伤害后/于弃牌阶段弃置手牌后，你获得X枚“窝”（X为伤害值/你弃置的手牌数）。
local dawo = fk.CreateTriggerSkill{
  name = "dawo",
  frequency = Skill.Compulsory, -- 锁定技
  events = {fk.Damaged, fk.AfterCardsMove},
  can_trigger = function(self, event, target, player, data)
    if player:hasSkill(self) then
      if event == fk.Damaged then
        return target == player
      else
        if player.phase == Player.Discard then
          for _, move in ipairs(data) do
            if move.from == player.id and move.moveReason == fk.ReasonDiscard then
              for _, info in ipairs(move.moveInfo) do
                if info.fromArea == Card.PlayerHand then
                  return true
                end
              end
            end
          end
        end
      end
    end
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if event == fk.Damaged then
      room:addPlayerMark(player, "@sanlai_wo", data.damage)
    else -- fk.AfterCardsMove
      local n = 0
      for _, move in ipairs(data) do
        if move.from == player.id and move.moveReason == fk.ReasonDiscard then
          for _, info in ipairs(move.moveInfo) do
            if info.fromArea == Card.PlayerHand then
              n = n + 1
            end
          end
        end
      end
      room:addPlayerMark(player, "@sanlai_wo", n)
    end
  end,
  refresh_events = {fk.EventLoseSkill},
  can_refresh = function(self, event, target, player, data)
    return player == target and data == self and player:getMark("@sanlai_wo") ~= 0
  end,
  on_refresh = function(self, event, target, player, data)
    player.room:setPlayerMark(player, "@sanlai_wo", 0)
  end,
}

-- 钓鱼，准备阶段开始时，你可以弃置所有的“窝”，然后进行等量次的判定，若判定结果为♦，你摸一张牌，获得一枚“鱼”；若判定结果为♥，你回复1点体力，获得一枚“鱼”。
local diaoyu = fk.CreateTriggerSkill{
  name = "diaoyu",
  anim_type = "drawcard",
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    -- 获取“窝”的数量
    local n = player:getMark("@sanlai_wo")
    return target == player and player:hasSkill(self) and player.phase == Player.Start and n > 0
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local n = player:getMark("@sanlai_wo")
    room:setPlayerMark(player, "@sanlai_wo", 0)
    for _ = 1, n do
      local judge = {
        who = target,
        reason = self.name,
        pattern = ".|.|diamond,heart",
      }
      room:judge(judge)
      if judge.card.suit == Card.Diamond then -- ♦
        player:drawCards(2, self.name)
        room:addPlayerMark(player, "@sanlai_yu", 1)
      elseif judge.card.suit == Card.Heart then -- ♥
        room:recover{
          who = player,
          num = 1,
        }
        room:addPlayerMark(player, "@sanlai_yu", 1)
      end
    end
  end,
}

Fk:loadTranslationTable{
  ["dawo"] = "打窝",
  [":dawo"] = "锁定技，当你受到伤害后/于弃牌阶段弃置手牌后，你获得X枚“窝”（X为伤害值/你弃置的手牌数）。",
  ["@sanlai_wo"] = "窝",
  ["diaoyu"] = "钓鱼",
  [":diaoyu"] = "准备阶段开始时，你可以弃置所有的“窝”，然后进行等量次的判定，若判定结果为♦，你摸两张牌，获得一枚“鱼”；若判定结果为♥，你回复1点体力，获得一枚“鱼”。",
  ["@sanlai_yu"] = "鱼",
}
-- 还差一个觉醒技，以后再加
sanlai:addSkill(dawo)
sanlai:addSkill(diaoyu)

local maxesisn = General:new(extension, "ep__maxesisn", "ep_k__ep", 3, 6)

Fk:loadTranslationTable{
  ["ep__maxesisn"] = "麦克西",
  ["#ep__maxesisn"] = "简单吃点",
  ["designer:ep__maxesisn"] = "怡批",
  ["cv:ep__maxesisn"] = "怡批",
  ["illustrator:ep__maxesisn"] = "怡批",
}

-- 1. 简吃 你可以弃置x张牌，视为使用一张【桃】（x为本轮你使用此技能的次数+1）
local jianchi_active = fk.CreateActiveSkill{
  name = "jianchi_active",
---@diagnostic disable-next-line: assign-type-mismatch
  card_num = function()
    return Self:usedSkillTimes("jianchi", Player.HistoryRound) -- 本轮你使用此技能的次数
  end,
  target_num = 0,
  card_filter = function(self, to_select, selected, targets) -- 要求选中x张牌, 且颜色相同
    local card = Fk:getCardById(to_select)
    if Self:prohibitDiscard(card) then return false end
    if #selected == 0 then
      return true
    else
      return #selected <= Self:usedSkillTimes("jianchi", Player.HistoryRound) and card.color == Fk:getCardById(selected[1]).color
    end
  end,
}

local jianchi = fk.CreateViewAsSkill{
  name = "jianchi",
  anim_type = "special",
  prompt = function ()
    return "#jianchi-viewas:::" .. tostring(Self:usedSkillTimes("jianchi", Player.HistoryRound) + 1)
  end,
  pattern = "peach",
  interaction = function()
    local all_names = { "peach" }
    local names = U.getViewAsCardNames(Self, "jianchi", all_names)
    if #names > 0 then
      return UI.ComboBox { choices = names, all_choices = all_names }
    end
  end,
  card_filter = Util.FalseFunc,
  view_as = function(self, cards)
    if not self.interaction.data then return nil end
    local card = Fk:cloneCard(self.interaction.data)
    card.skillName = self.name
    return card
  end,
  before_use = function(self, player)
    local room = player.room
    local x = player:usedSkillTimes(self.name, Player.HistoryRound)
    if x == 1 then
      if #room:askForDiscard(player, 1, 1, true, self.name, false, "", "#jianchi-discard:::1") == 0 then
        return ""
      end
    else
      local red, black = {}, {}
      local card
      for _, id in ipairs(player:getCardIds("he")) do
        card = Fk:getCardById(id)
        if not player:prohibitDiscard(card) then
          if card.color == Card.Red then
            table.insert(red, id)
          elseif card.color == Card.Black then
            table.insert(black, id)
          end
        end
      end
      local toDiscard = {}
      if #red >= x then
        toDiscard = table.random(red, x)
      elseif #black >= x then
        toDiscard = table.random(black, x)
      else
        return ""
      end
      local _, ret = room:askForUseActiveSkill(player, "jianchi_active", "#jianchi-discard:::"..tostring(x), false)
      if ret then
        toDiscard = ret.cards
      end
      room:throwCard(toDiscard, self.name, player, player)
    end
  end,
  enabled_at_play = function(self, player)
    local x = player:usedSkillTimes(self.name, Player.HistoryRound) + 1
    local a,b,c = 0,0,0
    local card
    for _, id in ipairs(player:getCardIds("he")) do
      card = Fk:getCardById(id)
      if not player:prohibitDiscard(card) then
        if card.color == Card.Red then
          a = a + 1
        elseif card.color == Card.Black then
          b = b + 1
        else
          c = c + 1
        end
      end
    end
    return a >= x or b >= x or (c > 0 and x == 1)
  end,
  enabled_at_response = function(self, player, response)
    local x = player:usedSkillTimes(self.name, Player.HistoryRound) + 1
    local a,b,c = 0,0,0
    local card
    for _, id in ipairs(player:getCardIds("he")) do
      card = Fk:getCardById(id)
      if not player:prohibitDiscard(card) then
        if card.color == Card.Red then
          a = a + 1
        elseif card.color == Card.Black then
          b = b + 1
        else
          c = c + 1
        end
      end
    end
    return a >= x or b >= x or (c > 0 and x == 1)
  end,
}

Fk:loadTranslationTable{
  ["jianchi"] = "简吃",
  [":jianchi"] = "当你需要使用或打出【桃】时，你可以：弃置X张颜色相同的牌（X为你本轮发动本技能的次数），视为你使用或打出【桃】。",
  ["jianchi_active"] = "简吃",
  ["#jianchi-viewas"] = "发动简吃，弃置%arg张颜色相同的牌，来视为使用或打出一张桃",
  ["#jianchi-discard"] = "简吃：弃置%arg张颜色相同的牌，视为使用此基本牌",
}

Fk:addSkill(jianchi_active)
maxesisn:addSkill(jianchi)

local natie = General:new(extension, "ep__natie", "ep_k__ep", 3)

Fk:loadTranslationTable{
  ["ep__natie"] = "拿铁",
  ["#ep__natie"] = "野人王",
  ["designer:ep__natie"] = "怡批",
  ["cv:ep__natie"] = "怡批",
  ["illustrator:ep__natie"] = "怡批",
}

-- 1. 野王，锁定技，【南蛮入侵】对你无效；当其他角色使用的【南蛮入侵】结算结束后，你获得之。
local yewang = fk.CreateTriggerSkill{
  name = "yewang",
  anim_type = "defensive",
  frequency = Skill.Compulsory,
  events = {fk.PreCardEffect, fk.TargetSpecified, fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if not (player:hasSkill(self) and data.card and data.card.trueName == "savage_assault") then return end
    if event == fk.PreCardEffect then
      return data.to == player.id
    else
      return target ~= player and U.hasFullRealCard(player.room, data.card)
    end
  end,
  on_use = function(self, event, target, player, data)
    if event == fk.PreCardEffect then -- 【南蛮入侵】对你无效
      return true
    elseif event == fk.TargetSpecified then -- 【南蛮入侵】的伤害来源
      data.extra_data = data.extra_data or {}
      data.extra_data.yewang = player.id
    else -- 结算结束后，你获得之
      player.room:obtainCard(player, data.card, true, fk.ReasonJustMove)
    end
  end,
  
  refresh_events = {fk.PreDamage}, -- 伤害结算前
  can_refresh = function(self, event, target, player, data)
    if data.card and data.card.trueName == "savage_assault" then
      local e = player.room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
      if e then
        local use = e.data[1]
        return use.extra_data and use.extra_data.yewang
      end
    end
  end,
  on_refresh = function(self, event, target, player, data)
    local room = player.room
    local e = room.logic:getCurrentEvent():findParent(GameEvent.UseCard)
    if e then
      local use = e.data[1]
      data.from = room:getPlayerById(use.extra_data.yewang)
    end
  end,
}

Fk:loadTranslationTable{
  ["yewang"] = "野王",
  [":yewang"] = "锁定技，【南蛮入侵】对你无效，你视为【南蛮入侵】的伤害来源；当其他角色使用的【南蛮入侵】结算结束后，你获得之。",
}

local zhidian = fk.CreateTriggerSkill{
  name = "zhidian",
  events = {fk.TurnStart},
  mute = true,
  can_trigger = function(self, event, target, player, data)
    return player ~= target and not target.dead and player:hasSkill(self)
  end,
  on_cost = function(self, event, target, player, data) -- 弃置一张牌以发动技能
    self.cost_data = player.room:askForDiscard(player, 1, 1, true, self.name, true, ".", "#zhidian-invoke::"..target.id, true)
    return true
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    if #self.cost_data == 1 then -- 弃置了一张牌
      local suits = {"spade", "heart", "club", "diamond", "nosuit"}
      local anim_types = {"support", "drawcard", "control", "offensive", "negative"}
      local index = table.indexOf(suits, Fk:getCardById(self.cost_data[1]):getSuitString()) -- 获取弃置的牌的花色
      room:notifySkillInvoked(player, self.name, anim_types[index])
      if index < 5 then
        player:broadcastSkillInvoke(self.name, index + 1)
      end
      room:throwCard(self.cost_data, self.name, player, player)
      if index == 1 then 
        room:useVirtualCard("analeptic", nil, target, target, self.name, false) -- 当前回合角色使用一张【酒】
      elseif index == 2 then
        room:useVirtualCard("peach", nil, target, target, self.name, false) -- 当前回合角色使用一张【桃】
      elseif index == 3 then
        room:useVirtualCard("iron_chain", nil, player, target, self.name, false) -- 对当前回合角色使用一张【铁索连环】
      elseif index == 4 then
        room:useVirtualCard("fire__slash", nil, player, target, self.name, false) -- 对当前回合角色使用一张【火杀】
      end
    end
  end,
}
Fk:loadTranslationTable{
  ["zhidian"] = "指点",
  [":zhidian"] = "其他角色的回合开始时，你可以弃置一张牌，根据弃置牌的花色执行效果：" ..
    "{♠，其视为使用一张【酒】；<font color='red'>♥</font>，其视为使用一张【桃】；"..
  "♣，你视为对其使用一张【铁索连环】；<font color='red'>♦</font>，你视为对其使用一张火【杀】。}",
  ["#zhidian-invoke"] = "指点：%dest的回合，选择一张牌弃置并根据花色执行对应效果",
}

-- 自治：锁定技，出牌阶段开始时，你选择一项：1.本回合你对其他角色造成伤害时，防止之；2. 失去1点体力
local zizhi = fk.CreateTriggerSkill{
  name = "zizhi",
  anim_type = "special",
  frequency = Skill.Compulsory,
  events = {fk.EventPhaseStart},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and player.phase == Player.Play
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local choices = {"zizhi_1", "zizhi_2"}
    local choice = room:askForChoice(player, choices, self.name, "#zizhi-ask")
    if choice == "zizhi_1" then
      room:setPlayerMark(player, "@zizhi", 1)
    else
      room:loseHp(player, 1)
    end
  end,
}

Fk:loadTranslationTable{
  ["zizhi"] = "自治",
  [":zizhi"] = "锁定技，出牌阶段开始时，你选择一项：1.本回合你对其他角色造成伤害时，防止之；2. 失去1点体力。",
  ["zizhi_1"] = "防止伤害",
  ["zizhi_2"] = "失去体力",
  ["#zizhi-ask"] = "请选择一项：1.本回合你对其他角色造成伤害时，防止之；2. 失去1点体力",
}

natie:addSkill(yewang)
natie:addSkill(zizhi)
natie:addSkill(zhidian)

local chali = General:new(extension, "ep__chali", "ep_k__ep", 4)

Fk:loadTranslationTable{
  ["ep__chali"] = "查理",
  ["#ep__chali"] = "龙少",
  ["designer:ep__chali"] = "怡批",
  ["cv:ep__chali"] = "怡批",
  ["illustrator:ep__chali"] = "怡批",
}

-- 1. 龙少，锁定技，游戏开始时，多摸4张牌。
local longshao = fk.CreateTriggerSkill{
  name = "longshao",
  events = {fk.GameStart},
  frequency = Skill.Compulsory,
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    player.room:drawCards(player, player.maxHp, self.name)
  end,
}
local longshao_maxcards = fk.CreateMaxCardsSkill{
  name = "#longshao_maxcards",
  correct_func = function(self, player)
    if player:hasSkill(self) then
      return player.maxHp
    else
      return 0
    end
  end,
}
longshao:addRelatedSkill(longshao_maxcards)
Fk:loadTranslationTable{
  ["longshao"] = "龙少",
  [":longshao"] = "锁定技，1.你的手牌上限+X。2.游戏开始时，你摸X张牌。（X为你的体力上限）",
}

chali:addSkill(longshao)

local ark = General:new(extension, "ep__ark", "ep_k__ep", 4)

Fk:loadTranslationTable{
  ["ep__ark"] = "方舟",
  ["#ep__ark"] = "方舟",
  ["designer:ep__ark"] = "怡批",
  ["cv:ep__ark"] = "怡批",
  ["illustrator:ep__ark"] = "怡批",
}

-- 当你成为其他角色使用的普通锦囊牌的唯一目标时，你可以将其视为【决斗】
local nilin = fk.CreateTriggerSkill{
  name = "nilin",
  events = {fk.AfterCardTargetDeclared},
  can_trigger = function(self, event, target, player, data)
    return target ~= player and player:hasSkill(self) -- 不是自己出的牌
    and data.card:isCommonTrick() and data.tos -- 是普通锦囊牌
    and #TargetGroup:getRealTargets(data.tos) == 1 -- 目标只有一个
    and table.contains(TargetGroup:getRealTargets(data.tos), player.id) -- 你是目标之一
  end,
  on_use = function(self, event, target, player, data)
    data.card = Fk:cloneCard('duel')
    data.card.skillName = self.name
  end,
}

local shinue = fk.CreateViewAsSkill{
  name = "shinue",
  anim_type = "offensive",
  pattern = "slash",
  card_filter = function(self, to_select, selected)
    return #selected == 0
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("slash")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  enabled_at_play = function(self, player)
    return not player:isNude() and player.phase == Player.NotActive
  end,
  enabled_at_response = function(self, player, cardResponsing)
    return not player:isNude() and player.phase == Player.NotActive
  end,
}
Fk:loadTranslationTable{
  ["nilin"] = "逆鳞",
  [":nilin"] = "当你成为其他角色使用的普通锦囊牌的唯一目标时，你可以将其视为【决斗】",
  ["shinue"] = "施虐",
  [":shinue"] = "你的回合外，你可以将一张牌视为【杀】使用或打出。",
}
ark:addSkill(nilin)
ark:addSkill(shinue)

local tomoyo = General:new(extension, "ep__tomoyo", "ep_k__ep", 3)
Fk:loadTranslationTable{
  ["ep__tomoyo"] = "将遗憾写成歌",
  ["#ep__tomoyo"] = "纯情男高",
  ["designer:ep__tomoyo"] = "怡批",
  ["cv:ep__tomoyo"] = "怡批",
  ["illustrator:ep__tomoyo"] = "怡批",
}

-- 高玩，出牌阶段限一次，你可以将一张手牌视为【决斗】使用，并摸一张牌。
local gaowan = fk.CreateViewAsSkill{
  name = "gaowan",
  anim_type = "offensive",
  pattern = "duel",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("duel")
    c.skillName = self.name
    c:addSubcard(cards[1])
    return c
  end,
  before_use = function(self, player)
    player:drawCards(1, self.name)
  end,
  enabled_at_play = function(self, player) -- 出牌阶段限一次
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0 and player.phase == Player.Play
  end,
  enabled_at_response = function(self, player, cardResponsing) -- 不可以打出（响应）
    return false
  end,
}
--[[
local gaowan_trigger = fk.CreateTriggerSkill{
  name = "#gaowan_trigger",
  events = {fk.AfterCardUseDeclared},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self) and data.card.trueName == "duel" and target == player
  end,
  on_use = function(self, event, target, player, data)
    player:drawCards(1, self.name)
  end,
}
gaowan:addRelatedSkill(gaowan_trigger)
]]--

Fk:loadTranslationTable{
  ["gaowan"] = "高玩",
  [":gaowan"] = "出牌阶段限一次，你可以将一张手牌视为【决斗】使用，并摸一张牌。",
  ["#gaowan_trigger"] = "高玩",
}

-- 纯情，当一名角色成为杀的目标时，当你不为杀的使用者且目标不包括你时，你可以展示一张红色手牌，转移此杀的目标至你。
local chunqing = fk.CreateTriggerSkill{
  name = "chunqing",
  events = {fk.TargetConfirming},
  can_trigger = function(self, event, target, player, data)
    return target ~= player 
    and player:hasSkill(self) 
    and data.card.trueName == "slash" 
    and data.from ~= player.id 
    and not table.contains(AimGroup:getAllTargets(data.tos), player.id) 
    and not player.room:getPlayerById(data.from):isProhibited(player, data.card)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player.player_cards[Player.Hand]
    local red = table.filter(cards, function (id) return Fk:getCardById(id).color == Card.Red end)
    local ids, choice = U.askforChooseCardsAndChoice(player, red, {"OK"},
    self.name, "#chunqing-view", {"Cancel"}, 1, 1, cards)
    if #ids > 0 then
      player:showCards(ids)
      TargetGroup:removeTarget(data.targetGroup, target.id)
      TargetGroup:pushTargets(data.targetGroup, player.id)
    end
  end,
}

Fk:loadTranslationTable{
  ["chunqing"] = "纯情",
  [":chunqing"] = "当一名其他角色成为【杀】的目标时，若你不为使用者且目标不含有你，你可以展示一张红色手牌，将此目标转移给你。",
  ["#chunqing-view"] = "纯情：展示一张红色手牌，转移此杀的目标至你",
}

tomoyo:addSkill(gaowan)
tomoyo:addSkill(chunqing)

local sayyiku = General:new(extension, "ep__sayyiku", "ep_k__ep", 3)

Fk:loadTranslationTable{
  ["ep__sayyiku"] = "sa酱",
  ["#ep__sayyiku"] = "catcat.blog",
  ["designer:ep__sayyiku"] = "怡批",
  ["cv:ep__sayyiku"] = "怡批",
  ["illustrator:ep__sayyiku"] = "怡批",
}

-- 1. 测评（测评vps）
-- 出牌阶段限一次，你可以选择一名其他角色并展示其一张手牌，根据牌的类型执行以下效果：
--[[
1. 若该牌为基本牌，你摸一张牌；
2. 若该牌为锦囊牌，你与该角色各摸一张牌；
3. 若该牌为装备牌，你弃置该角色的一张牌。
--]]

local ceping = fk.CreateActiveSkill{
  name = "ceping",
  anim_type = "control",
  pcard_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id and not Fk:currentRoom():getPlayerById(to_select):isKongcheng()
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local id1 = room:askForCardChosen(player, target, "h", self.name)
    target:showCards(id1)
    local card = Fk:getCardById(id1)
    if card.type == Card.TypeBasic then
      player:drawCards(1, self.name)
    elseif card.type == Card.TypeTrick then
      player:drawCards(1, self.name)
      target:drawCards(1, self.name)
    elseif card.type == Card.TypeEquip then
      local id2 = room:askForCardChosen(player, target, "h", self.name)
      room:throwCard(id2, self.name, target, player)
    end
  end,
}

Fk:loadTranslationTable{
  ["ceping"] = "测评",
  [":ceping"] = "出牌阶段限一次，你可以选择一名其他角色并展示其一张手牌，根据牌的类型执行以下效果："..
    "1. 若该牌为基本牌，你摸一张牌；"..
    "2. 若该牌为锦囊牌，你与该角色各摸一张牌；"..
    "3. 若该牌为装备牌，你弃置该角色的一张牌。",
}

-- 药神，当一名角色进入濒死状态时，你可以弃置一张红色牌，令其回复1点体力。
local yaoshen = fk.CreateTriggerSkill{
  name = "yaoshen",
  anim_type = "defensive",
  events = {fk.EnterDying},
  can_trigger = function(self, event, target, player, data)
    return player:hasSkill(self)
  end,
  on_use = function(self, event, target, player, data)
    local room = player.room
    local cards = player.player_cards[Player.Hand]
    local red = table.filter(cards, function (id) return Fk:getCardById(id).color == Card.Red end)
    local ids, choice = U.askforChooseCardsAndChoice(player, red, {"OK"},
    self.name, "#yaoshen-view", {"Cancel"}, 1, 1, cards)
    if #ids > 0 then
      room:throwCard(ids, self.name, player, player)
      room:recover{
        who = target,
        num = 1,
      }
    end
  end,
}

Fk:loadTranslationTable{
  ["yaoshen"] = "药神",
  [":yaoshen"] = "当一名角色进入濒死状态时，你可以弃置一张红色牌，令其回复1点体力。",
  ["#yaoshen-view"] = "药神：展示一张红色牌，令 %dest 回复1点体力",
}

sayyiku:addSkill(ceping)
sayyiku:addSkill(yaoshen)

local saneryy = General:new(extension, "ep__saneryy", "ep_k__ep", 3)

Fk:loadTranslationTable{
  ["ep__saneryy"] = "善恶歪歪",
  ["#ep__saneryy"] = "雌小鬼",
  ["designer:ep__saneryy"] = "怡批",
  ["cv:ep__saneryy"] = "怡批",
  ["illustrator:ep__saneryy"] = "怡批",
}

-- 1. 雌小鬼，出牌阶段限一次，你可以指定一名你在其攻击范围内的角色，
--[[令其选择一项：1.对包括你在内的角色使用一张【杀】,然后获得一枚“急”；
2.弃置一张牌。
每有一枚“急”，其计算与你的距离+1。
--]]
local cixiaogui = fk.CreateActiveSkill{
  name = "cixiaogui",
  anim_type = "control",
  card_num = 0,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = Util.FalseFunc,
  target_filter = function(self, to_select, selected) -- 选择一名你在其攻击范围内的角色
    return #selected == 0 and Fk:currentRoom():getPlayerById(to_select):inMyAttackRange(Self)
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    local use = room:askForUseCard(target, "slash", "slash", "#cixiaogui-use:", true, {exclusive_targets = {player.id}})
    if use then
      room:useCard(use)
      room:addPlayerMark(target, "@cixiaogui_ji", 1)
    else
      if not target:isNude() then
        local card = room:askForCardChosen(target, target, "he", self.name)
        room:throwCard({card}, self.name, target, target)
      end
    end
  end
}
-- 有多少枚“急”，其计算与你的距离+1
local cixiaogui_distance = fk.CreateDistanceSkill{
  name = "#cixiaogui_distance",
  correct_func = function(self, from, to)
    if to:hasSkill(self) then
      if from:getMark("@cixiaogui_ji") > 0 then
        return from:getMark("@cixiaogui_ji")
      end
    end
  end,
}
cixiaogui:addRelatedSkill(cixiaogui_distance)
Fk:loadTranslationTable{
  ["cixiaogui"] = "雌小鬼",
  [":cixiaogui"] = "出牌阶段限一次，你可以指定一名你在其攻击范围内的角色，令其选择一项："..
    "1.对包括你在内的角色使用一张【杀】,然后获得一枚“急”；"..
    "2.弃置自己一张牌。" ..
    "拥有“急”的角色计算与你的距离+X（X为其拥有的“急”标记数)",
  ["#cixiaogui-use"] = "雌小鬼：对其使用一张【杀】，然后获得一枚“急”，或弃置自己一张牌",
  ["@cixiaogui_ji"] = "急",
  ["#cixiaogui_distance"] = "雌小鬼",
}
saneryy:addSkill(cixiaogui)

local aba = General:new(extension, "ep__aba", "ep_k__ep", 3)

Fk:loadTranslationTable{
  ["ep__aba"] = "阿巴",
  ["#ep__aba"] = "阿巴",
  ["designer:ep__aba"] = "怡批",
  ["cv:ep__aba"] = "怡批",
  ["illustrator:ep__aba"] = "怡批",
}

-- 1. k头，"若一名角色使用红色【杀】仅指定唯一其他角色为目标，此牌结算后，你可从手牌中对相同目标使用一张无次数和距离限制的"..
--  "【杀】。",

local ktou = fk.CreateTriggerSkill{
  name = "ktou",
  anim_type = "offensive",
  events = {fk.CardUseFinished},
  can_trigger = function(self, event, target, player, data)
    if not player:hasSkill(self) then return false end
    if data.card.trueName == "slash" and data.card.color == Card.Red then
      local targets = TargetGroup:getRealTargets(data.tos)
      return #targets == 1 and targets[1] ~= player.id and not player.room:getPlayerById(targets[1]).dead
    end
  end,
  on_cost = function(self, event, target, player, data)
    local targets = TargetGroup:getRealTargets(data.tos)
    local use = player.room:askForUseCard(player, self.name, "slash", "#ktou-use::" .. targets[1], true,
      { must_targets = targets, bypass_distances = true, bypass_times = true })
    if use then
      self.cost_data = use
      return true
    end
  end,
  on_use = function(self, event, target, player, data)
    player.room:useCard(self.cost_data)
  end,
}

Fk:loadTranslationTable{
  ["ktou"] = "k头",
  [":ktou"] = "若一名角色使用红色【杀】仅指定唯一其他角色为目标，此牌结算后，你可从手牌中对相同目标使用一张无次数和距离限制的【杀】。",
  ["#ktou-use"] = "k头：对 %dest 使用一张无次数和距离限制的【杀】",
}

local shouming = fk.CreateActiveSkill{
  name = "shouming",
  anim_type = "offensive",
  max_card_num = 1,
  target_num = 1,
  can_use = function(self, player)
    return player:usedSkillTimes(self.name, Player.HistoryPhase) == 0
  end,
  card_filter = function(self, to_select, selected)
    return Fk:getCardById(to_select).sub_type == Card.SubtypeWeapon
  end,
  target_filter = function(self, to_select, selected, selected_cards)
    return #selected == 0 and to_select ~= Self.id
  end,
  on_use = function(self, room, effect)
    local player = room:getPlayerById(effect.from)
    local target = room:getPlayerById(effect.tos[1])
    if #effect.cards > 0 then
      room:throwCard(effect.cards, self.name, player)
    else
      room:loseHp(player, 1, self.name)
    end
    room:damage{
      from = player,
      to = target,
      damage = 1,
      skillName = self.name,
    }
  end,
}

Fk:loadTranslationTable{
  ["shouming"] = "授命",
  [":shouming"] = "出牌阶段限一次，你可以失去1点体力或弃置一张武器牌，并选择一名其他角色，对其造成1点伤害。",
}

aba:addSkill(ktou)
aba:addSkill(shouming)

local neneko = General:new(extension, "ep__neneko", "ep_k__ep", 3)

Fk:loadTranslationTable{
  ["ep__neneko"] = "内扣",
  ["#ep__neneko"] = "内扣",
  ["designer:ep__neneko"] = "怡批",
  ["cv:ep__neneko"] = "怡批",
  ["illustrator:ep__neneko"] = "怡批",
}

-- 你猜：当你需要使用【闪】，你可以扣置一张手牌作为【闪】使用，然后效果发起者选择是否质疑，然后你展示此牌。
-- 若其不质疑，则继续结算
-- 若其质疑，且此牌不是【闪】，则此牌进入弃牌堆，其摸一张牌；若此牌是【闪】，则正常结算，其弃置一张牌。

local nicai = fk.CreateViewAsSkill{
  name = "nicai",
  pattern = "jink",
  anim_type = "defensive",
  card_filter = function(self, to_select, selected)
    return #selected == 0 and Fk:currentRoom():getCardArea(to_select) ~= Card.PlayerEquip
  end,
  view_as = function(self, cards)
    if #cards ~= 1 then
      return nil
    end
    local c = Fk:cloneCard("jink")
    c.skillName = self.name
    c:addSubcard(cards[1])
---@diagnostic disable-next-line: inject-field
    self.cost_data = cards
    return c
  end,
  before_use = function(self, player, use)
    local room = player.room
---@diagnostic disable-next-line: undefined-field
    local cards = self.cost_data
    local card_id = cards[1]
    room:moveCardTo(cards, Card.Processing, nil, fk.ReasonPut, self.name, "", false, player.id) -- 移动到处理区（不展示）
    local targets = TargetGroup:getRealTargets(use.tos)
    -- 这张牌响应的对象
    local source = room:getPlayerById(use.from)
    if targets and #targets > 0 then
      room:sendLog{
        type = "#nicai_use",
        from = player.id,
        to = targets,
        arg = use.card.name,
        arg2 = self.name
      }
      room:doIndicate(player.id, targets)
    else
      room:sendLog{
        type = "#nicai_no_target",
        from = player.id,
        arg = use.card.name,
        arg2 = self.name
      }
    end
    local choice = room:askForChoice(source, {"noquestion", "question"}, self.name, "#guhuo-ask::"..player.id..":"..use.card.name)
    if choice ~= "noquestion" then
      
    end
    room:sendLog{
      type = "#guhuo_query",
      from = source.id,
      arg = choice
    }
  end,
}

Fk:loadTranslationTable{
  ["nicai"] = "你猜",
  [":nicai"] = "当你成为【杀】的目标时，你可以扣置一张手牌声明为【闪】，然后效果发起者选择是否质疑，然后你展示此牌。"..
    "若其质疑，且此牌是【闪】，则其失去1点体力；若其质疑，且此牌不是【闪】，则其摸一张牌。" ..
    "若其不质疑，且此牌是【闪】，则防止此【杀】对你造成的伤害。",
}

neneko:addSkill("guhuo")

return extension