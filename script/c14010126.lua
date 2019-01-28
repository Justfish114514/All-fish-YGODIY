--异次元超特急 和平空轨
local m=14010126
local cm=_G["c"..m]
function cm.initial_effect(c)
	--xyz summon
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	c:SetSPSummonOnce(m)
	--attach
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(cm.tg)
	e1:SetOperation(cm.op)
	c:RegisterEffect(e1)
end
function cm.filter(c,tp)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
		and (c:IsControler(tp) or c:IsAbleToChangeControler()) not c:IsImmuneToEffect(e)
end
function cm.efilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end
function cm.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_REMOVED,0,1,nil,tp) and Duel.IsExistingTarget(cm.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g1=Duel.SelectTarget(tp,cm.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g2=Duel.SelectTarget(tp,cm.spfilter1,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(cm.efilter,nil,e)
	local c=e:GetHandler()
	if #tg>0 and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) then
		local tc=tg:GetFirst()
		local ov=Group.CreateGroup()
		while tc do
			local og=tc:GetOverlayGroup()
			if og:GetCount()>0 then
				ov:Merge(ov)
			end
			tc=tg:GetNext()
		end
		Duel.SendtoGrave(ov,REASON_RULE)
		Duel.Overlay(c,tg)
	end
end