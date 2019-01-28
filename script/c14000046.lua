--点晴枯树-Qlibody
local m=14000046
local cm=_G["c"..m]
cm.named_with_another=1
function cm.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--remove and recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(m,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCost(cm.rmcost)
	e2:SetTarget(cm.rmtg)
	e2:SetOperation(cm.rmop)
	c:RegisterEffect(e2)
	--lp Recover
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(cm.lpcon)
	e3:SetOperation(cm.lpop)
	c:RegisterEffect(e3)
end
function cm.ANOTHER(c)
	local m=_G["c"..c:GetCode()]
	return m and m.named_with_another
end
function cm.costfilter(c)
	return cm.ANOTHER(c) and c:IsAbleToRemoveAsCost()
end
function cm.cfilter(c)
	return cm.ANOTHER(c) and c:IsFaceup()
end
function cm.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cm.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cm.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cm.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,nil)
end
function cm.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,nil)
	if g:GetCount()>0 then
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==0 then return end
		Duel.BreakEffect()
		local g1=Duel.GetMatchingGroup(cm.cfilter,tp,LOCATION_REMOVED,0,nil)
		local ct=g1:GetCount()
		if ct>0 then
			Duel.Recover(tp,ct*400,REASON_EFFECT)
		end
	end
end
function cm.lpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,14000041)==0 and e:GetHandler():IsFaceup()
end
function cm.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,14000041,RESET_PHASE+PHASE_END,0,1)
	Duel.Hint(HINT_CARD,0,m)
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,0)
	local ct=Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	if ct>0 then
		Duel.Recover(tp,ct*400,REASON_EFFECT)
	end
end