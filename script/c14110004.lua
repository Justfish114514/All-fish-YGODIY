--追根溯源（测试
local m=14110004
local cm=_G["c"..m]
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(m,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CUSTOM+m)
	e1:SetCost(cm.discost)
	--e1:SetCondition(cm.discon)
	e1:SetTarget(cm.distg)
	e1:SetOperation(cm.disop)
	c:RegisterEffect(e1)
	--act in hand
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(cm.handcon)
	c:RegisterEffect(e2)
	if not cm.global_check then
		cm.global_check=true
		cm[0]=Group.CreateGroup()
		cm[0]:KeepAlive()
		local ge1=Effect.GlobalEffect()
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetOperation(cm.checkop1)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.GlobalEffect()
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_TO_GRAVE)
		ge2:SetOperation(cm.checkop2)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_CHAIN_END)
		ge3:SetOperation(cm.resetcount)
		Duel.RegisterEffect(ge3,0)
	end
end
function cm.resetcount(e,tp,eg,ep,ev,re,r,rp)
	cm[0]=:Clear()
end
function cm.checkop1(e,tp,eg,ep,ev,re,r,rp)
	if cm[0]:GetCount()==0 then return end
	local g=eg:Filter(cm.cfilter,nil)
	if cm[0]:GetCount()~=0 then
		Duel.RaiseEvent(eg,EVENT_CUSTOM+m,e,0,0,0,ev)
	end
end
function cm.checkop2(e,tp,eg,ep,ev,re,r,rp)
	cm[0]:Clear()
	g=eg:Filter(Duel.GetMatchingGroup(cm.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,tp):Filter(cm.cfilter,nil),nil)
	cm[0]:Merge(g)
end
function cm.handcon(e)
	local c=e:GetHandler()
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0 or (not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),LOCATION_GRAVE,0,1,nil,TYPE_MONSTER))
end
function cm.cfilter(c,tp)
	return (c:IsPreviousLocation(LOCATION_DECK) or c:IsPreviousLocation(LOCATION_HAND)) and c:IsAbleToHandAsCost() and c:IsLocation(LOCATION_GRAVE)
end
--function cm.discon(e,tp,eg,ep,ev,re,r,rp)
	--return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
--end
function cm.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SendtoHand(cm[0],nil,REASON_COST)
end
function cm.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
function cm.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsRelateToEffect(re)  then
		Duel.SendtoGrave(eg,REASON_EFFECT)
	end
end