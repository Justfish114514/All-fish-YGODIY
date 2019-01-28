--测 试 用
IsHasEffect
Duel.IsEnvironment
TYPE_SPSUMMON
function cxxxxxxxx.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	return g:GetCount()>=2 and g:IsExists(function(c)
	return c:IsType(TYPE_TUNER)
	end,1,nil)
end
local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
if g:GetCount()>=2 and g:IsExists(function(c)
	return c:IsType(TYPE_TUNER)
	end,1,nil) then
--effect
end
function cxxxxxxxx.attfilter(c,att1,att2)
	return c:GetAttribute() ~= att1 and c:GetAttribute() ~= att2 and c:IsType(TYPE_MONSTER)
end
local att1=e:GetLabel()

	local type=TYPE_NORMAL+TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,function(c,type) return c:IsType(type) and c:IsAbleToGrave() end,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,1,1,nil)
	if bit.band(type,g1:GetFirst():GetType)~=0 then
		type=type-bit.band(type,g1:GetFirst():GetType)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,function(c,type) return c:IsType(type) and c:IsAbleToGrave() end,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,1,1,g1)
	if bit.band(type,g2:GetFirst():GetType)~=0 then
		type=type-bit.band(type,g2:GetFirst():GetType)
	end
	g1:Merge(g2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g3=Duel.SelectMatchingCard(tp,function(c,type) return c:IsType(type) and c:IsAbleToGrave() end,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_EXTRA,0,1,1,g1)
	g1:Merge(g3)
	Duel.SendtoGrave(g1,REASON_EFFECT)