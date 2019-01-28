--追根溯源
local m=14110003
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCost(cm.drcost)
	e1:SetCondition(cm.drcon)
	e1:SetTarget(cm.drtg)
	e1:SetOperation(cm.drop)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cm.handcon)
	c:RegisterEffect(e2)
end
function cm.handcon(e)
	local c=e:GetHandler()
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0 or (not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER))
end
function cm.cfilter(c,tp)
	return (c:IsPreviousLocation(LOCATION_DECK) and c:IsAbleToHandAsCost()) or c:IsPreviousLocation(LOCATION_HAND)
end
function cm.drcon(e,tp,eg,ep,ev,re,r,rp)
	return (eg:IsExists(cm.cfilter,1,nil,tp) or eg:IsExists(cm.cfilter,1,nil,1-tp)) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
end
function cm.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SendtoHand(eg,nil,REASON_COST)
end
function cm.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function cm.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end