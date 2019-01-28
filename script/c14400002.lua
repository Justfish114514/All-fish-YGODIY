--copy
local m=14400002
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c37564765") end,function() require("script/c37564765") end)
function cm.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--CopyEffect
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37564765,7))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(cm.InstantCopyCondition(excon))
	e2:SetOperation(cm.op)
	c:RegisterEffect(e2)
end
function cm.op(e,tp,eg,ep,ev,re,r,rp)
	local rtype=bit.band(re:GetActiveType(),0x7)
	local g=Group.CreateGroup()
	Duel.ChangeTargetCard(ev,g)
	Duel.ChangeChainOperation(ev,cm.repop)
end
function cm.repop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(1-tp)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(cm.con)
	e1:SetCost(cm.ForbiddenCost(cost))
	e1:SetTarget(cm.InstantCopyTarget)
	e1:SetOperation(cm.CopyOperation)
	Duel.RegisterEffect(e1,tp)
end
function cm.con(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function cm.InstantCopyCondition(excon)
return function(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and (not excon or excon(e,tp,eg,ep,ev,re,r,rp))
end
end
function cm.InstantCopyTarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and cm.ProtectedRun(tg,e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	local te=re:Clone()
	local tg=te:GetTarget()
	local code=te:GetCode()
	local tres,teg,tep,tev,tre,tr,trp
	if code>0 and code~=EVENT_FREE_CHAIN and code~=EVENT_CHAINING and Duel.CheckEvent(code) then
		tres,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(code,true)
	end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		local res=false
		if not tg then return true end
		if tres then return cm.ProtectedRun(tg,e,tp,teg,tep,tev,tre,tr,trp,0)
		else return cm.ProtectedRun(tg,e,tp,eg,ep,ev,re,r,rp,0) end
	end
	e:SetLabel(te:GetLabel())
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	if tg then
		if tres then
			cm.ProtectedRun(tg,e,tp,teg,tep,tev,tre,tr,trp,1)
		else
			cm.ProtectedRun(tg,e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	local ex=Effect.GlobalEffect()
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_CHAIN_END)
	ex:SetLabelObject(e)
	ex:SetOperation(function(e)
		e:GetLabelObject():SetLabel(0)
		ex:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
function cm.ProtectedRun(f,...)
	if not f then return true end
	local params={...}
	local ret={}
	local res_test=pcall(function()
		ret={f(table.unpack(params))}
	end)
	if not res_test then return false end
	return table.unpack(ret)
end
function cm.ForbiddenCost(costf)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		e:SetLabel(1)
		if not costf then return true end
		return costf(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
function cm.CopySpellNormalFilter(c,f,e,tp)
	return (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY
		or c:GetType()==TYPE_TRAP or c:GetType()==TYPE_TRAP+TYPE_COUNTER) 
		and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false) and (not f or f(c,e,tp))
end
function cm.CopySpellNormalTarget(loc1,loc2,f,x)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and cm.ProtectedRun(tg,e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	local og=Duel.GetFieldGroup(tp,loc1,loc2)
	if x then og:Merge(e:GetHandler():GetOverlayGroup()) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return og:IsExists(cm.CopySpellNormalFilter,1,nil,f,e,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=og:FilterSelect(tp,cm.CopySpellNormalFilter,1,1,nil,f,e,tp)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(true,true,true)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	e:SetLabel(te:GetLabel())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	local ex=Effect.GlobalEffect()
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_CHAIN_END)
	ex:SetLabelObject(e)
	ex:SetOperation(function(e)
		e:GetLabelObject():SetLabel(0)
		ex:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
end
function cm.CopyOperation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if te:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:GetHandler():ReleaseEffectRelation(e)
	end
	cm.ProtectedRun(op,e,tp,eg,ep,ev,re,r,rp)
end
function cm.CopySpellChainingFilter(c,e,tp,eg,ep,ev,re,r,rp,f)
	if (c:GetType()==TYPE_SPELL or c:GetType()==TYPE_SPELL+TYPE_QUICKPLAY
		or c:GetType()==TYPE_TRAP or c:GetType()==TYPE_TRAP+TYPE_COUNTER) and c:IsAbleToRemoveAsCost() and (not f or f(c,e,tp,eg,ep,ev,re,r,rp)) then
		if c:CheckActivateEffect(true,true,false) then return true end
		local te=c:GetActivateEffect()
		if te:GetCode()~=EVENT_CHAINING then return false end
		local tg=te:GetTarget()
		if not cm.ProtectedRun(tg,e,tp,eg,ep,ev,re,r,rp,0) then return false end
		return true
	else return false end
end
function cm.CopySpellChainingTarget(loc1,loc2,f,x)
return function(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc))
	end
	local og=Duel.GetFieldGroup(tp,loc1,loc2)
	if x then og:Merge(e:GetHandler():GetOverlayGroup()) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return og:IsExists(cm.CopySpellChainingFilter,1,nil,e,tp,eg,ep,ev,re,r,rp,f)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=og:FilterSelect(tp,cm.CopySpellChainingFilter,1,1,nil,e,tp,eg,ep,ev,re,r,rp,f)
	local tc=g:GetFirst()
	local te,ceg,cep,cev,cre,cr,crp
	local fchain=cm.CopySpellNormalFilter(tc)
	if fchain then
		te,ceg,cep,cev,cre,cr,crp=tc:CheckActivateEffect(true,true,true)
	else
		te=tc:GetActivateEffect()
	end
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabel(te:GetLabel())
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then
		if fchain then
			cm.ProtectedRun(tg,e,tp,ceg,cep,cev,cre,cr,crp,1)
		else
			cm.ProtectedRun(tg,e,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	local ex=Effect.GlobalEffect()
	ex:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ex:SetCode(EVENT_CHAIN_END)
	ex:SetLabelObject(e)
	ex:SetOperation(function(e)
		e:GetLabelObject():SetLabel(0)
		ex:Reset()
	end)
	Duel.RegisterEffect(ex,tp)
end
end
function cm.CopySpellModule(c,loc1,loc2,f,con,cost,ctlm,ctlmid,eloc,x)
	local e2=Effect.CreateEffect(c)
	eloc=eloc or LOCATION_MZONE
	ctlmid=ctlmid or 1
	e2:SetDescription(aux.Stringid(37564765,6))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(eloc)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0x3c0)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	if ctlm then e2:SetCountLimit(ctlm,ctlmid) end
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not Duel.CheckEvent(EVENT_CHAINING) and (not con or con(e,tp,eg,ep,ev,re,r,rp))
	end)
	e2:SetCost(cm.ForbiddenCost(cost))
	e2:SetTarget(cm.CopySpellNormalTarget(loc1,loc2,f,x))
	e2:SetOperation(cm.CopyOperation)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37564765,6))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	if ctlm then e3:SetCountLimit(ctlm,ctlmid) end
	e3:SetCost(cm.ForbiddenCost(cost))
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return not con or con(e,tp,eg,ep,ev,re,r,rp)
	end)
	e3:SetTarget(cm.CopySpellChainingTarget(loc1,loc2,f,x))
	e3:SetOperation(cm.CopyOperation)
	c:RegisterEffect(e3)
	return e2,e3
end