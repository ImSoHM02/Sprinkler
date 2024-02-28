local assets =
{
	Asset("ANIM", "anim/sprinkler.zip"),
	Asset("ANIM", "anim/sprinkler_meter.zip"),
}

local prefabs =
{
	"water_spray",
}

local function IsWater(tile)
	return tile == GROUND.OCEAN_COASTAL or 
		tile == GROUND.OCEAN_COASTAL_SHORE or 
		tile == GROUND.OCEAN_SWELL or
		tile == GROUND.OCEAN_ROUGH or 
		tile == GROUND.OCEAN_BRINEPOOL or 
		tile == GROUND.OCEAN_BRINEPOOL_SHORE or 
		tile == GROUND.OCEAN_HAZARDOUS	
end

local function spawndrop(inst)
	local drop = SpawnPrefab("rain_drop")
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local angle = math.random()*2*PI
	local dist = math.random()*TUNING.SPRINKLER_RANGE
	local offset = Vector3(dist * math.cos( angle ), 0, -dist * math.sin( angle ))
	drop.Transform:SetPosition(pt.x+offset.x,0,pt.z+offset.z)	
	drop.Transform:SetScale(0.5, 0.5, 0.5)
end

local function OnFuelSectionChange(old, new, inst)
local fuelAnim = 0
if inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.01 then fuelAnim = "0"
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.1 then fuelAnim = "1"
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.2 then fuelAnim = "2"
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.3 then fuelAnim = "3" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.4 then fuelAnim = "4" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.5 then fuelAnim = "5" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.6 then fuelAnim = "6" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.7 then fuelAnim = "7" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.8 then fuelAnim = "8" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.9 then fuelAnim = "9" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 1 then fuelAnim = "10" end 
if inst then inst.AnimState:OverrideSymbol("swap_meter", "sprinkler_meter", fuelAnim) end
end

local function ontakefuelfn(inst)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/machine_fuel")
local fuelAnim = 0
if inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.01 then fuelAnim = "0"
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.1 then fuelAnim = "1"
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.2 then fuelAnim = "2"
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.3 then fuelAnim = "3" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.4 then fuelAnim = "4" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.5 then fuelAnim = "5" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.6 then fuelAnim = "6" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.7 then fuelAnim = "7" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.8 then fuelAnim = "8" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 0.9 then fuelAnim = "9" 
elseif inst and inst.components.fueled.currentfuel / inst.components.fueled.maxfuel <= 1 then fuelAnim = "10" end 
if inst then inst.AnimState:OverrideSymbol("swap_meter", "sprinkler_meter", fuelAnim) end
end

local function TurnOn(inst)
	inst.on = true
	
	inst.components.fueled:StartConsuming()
	
	if not inst.waterSpray then
		inst.waterSpray = SpawnPrefab("water_spray")
		local follower = inst.waterSpray.entity:AddFollower()
		follower:FollowSymbol(inst.GUID, "top", 0, -100, 0)
	end
	
	inst.droptask = inst:DoPeriodicTask(0.2,function() spawndrop(inst) spawndrop(inst) end)

	inst.spraytask = inst:DoPeriodicTask(0.2,function()
			if inst.components.machine:IsOn() then
				inst.UpdateSpray(inst)
			end
		end)
	
	inst.sg:GoToState("turn_on")
end

local function TurnOff(inst)
	inst.on = false
	inst.components.fueled:StopConsuming()

	if inst.waterSpray then
		inst.waterSpray:Remove()
		inst.waterSpray = nil
	end

	if inst.droptask then
		inst.droptask:Cancel()
		inst.droptask = nil
	end

	if inst.spraytask then
		inst.spraytask:Cancel()
		inst.spraytask = nil
	end

	inst.sg:GoToState("turn_off")
end

local function OnFuelEmpty(inst)
	inst.components.machine:TurnOff()
end

local function CanInteract(inst)
	return true
end

local function GetStatus(inst, viewer)
	if inst.on then
		return "ON"
	else
		return "OFF"
	end
end

local function OnEntitySleep(inst)
    inst.SoundEmitter:KillSound("firesuppressor_idle")
end

local function OnSave(inst, data)
	if inst:HasTag("burnt") or inst:HasTag("fire") then
        data.burnt = true
    end

    data.on = inst.on
end

local function OnLoad(inst, data)
	if data and data.burnt and inst.components.burnable and inst.components.burnable.onburnt then
        inst.components.burnable.onburnt(inst)
    end

    inst.on = data.on and data.on or false
end

local function OnLoadPostPass(inst, newents, data)
	if data and data.waterSpray then
		inst.waterSpray = newents[data.waterSpray].entity
	end
end

local function OnBuilt(inst)
	inst.AnimState:PlayAnimation("place")
	inst.AnimState:PushAnimation("idle_off")
	inst.SoundEmitter:PlaySound("Hamlet/common/crafted/sprinkler/place")
end

local function UpdateSpray(inst)
	OnFuelSectionChange(inst)
    local x, y, z = inst.Transform:GetWorldPosition()
	local GARDENING_CANT_TAGS = { "pickable", "stump", "withered", "barren", "INLIMBO", TUNING.SPRINKLER_WET_PLAYER }
	local ents = TheSim:FindEntities(x, y, z, TUNING.SPRINKLER_RANGE, nil, GARDENING_CANT_TAGS)

	if not inst.moisture_targets then
		inst.moisture_targets = {}
	end
	inst.moisture_targets_old = {}
	for GUID,v in pairs(inst.moisture_targets) do
    	inst.moisture_targets_old[GUID] = v
	end
    inst.moisture_targets = {} 

    for k,v in pairs(ents) do
		
		inst.moisture_targets[v.GUID] = v
		if v.components.moisture then
			if not v.components.moisture.moisture_sources then
				v.components.moisture.moisture_sources = {}
			end
			v.components.moisture.moisture_sources[inst.GUID] = inst.moisturizing			
		end
		
		if v.components.moisturelistener and not (v.components.inventoryitem and v.components.inventoryitem.owner) then
			v.components.moisturelistener:AddMoisture(0.5) -- MOISTURE_SPRINKLER_PERCENT_INCREASE_PER_SPRAY = 0.5

			local moisture = v.components.moisturelistener:GetMoisture() --/ TUNING.MOISTURE_MAX_WETNESS
			moisture = math.min(100,moisture + (0.5 / 100)) -- MOISTURE_SPRINKLER_PERCENT_INCREASE_PER_SPRAY = 0.5
			v.components.moisturelistener:Soak(moisture/100)
		end
	
		if v.components.moisture then
			v.components.moisture:DoDelta(0.1)		
		end
		
		if v.components.burnable and not (v.components.inventoryitem and v.components.inventoryitem.owner) then
			v.components.burnable:Extinguish()
		end
		
		if v.components.crop and v.components.crop.task then
		print(v)
			v.components.crop.growthpercent = v.components.crop.growthpercent + (0.001)
		end		

		if v.components.growable ~= nil then
			v.components.growable:ExtendGrowTime(-0.2)
		end
	
		if v then
			local a, b, c = v.Transform:GetWorldPosition()
			if inst.components.wateryprotection then
				inst.components.wateryprotection:SpreadProtectionAtPoint(a, b, c, 1)
			end
		end	

		if v.components.witherable and v.components.witherable:IsWithered() then
			v.components.witherable:ForceRejuvenate()
		end	
	end
	
	for GUID,v in pairs(inst.moisture_targets_old)do
		local still_affected = false
		for iGUID, i in pairs(inst.moisture_targets)do
			if GUID == iGUID then
				still_affected = true
				break
			end
		end
		if not still_affected then	
			if v.components.moisture then
				v.components.moisture.moisture_sources[inst.GUID] = nil
			end
		end
	end
end

local function onhit(inst, worker)
	if not inst:HasTag("burnt") then
		if not inst.sg:HasStateTag("busy") then
			inst.sg:GoToState("hit")
		end
	end
end

local function onhammered(inst, worker)
    if inst.components.burnable ~= nil and inst.components.burnable:IsBurning() then
        inst.components.burnable:Extinguish()
    end
    inst.components.lootdropper:DropLoot()
    local fx = SpawnPrefab("collapse_small")
    fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
    fx:SetMaterial("wood")
    inst:Remove()
end

local function OnDeplete(inst)
end

local function Fn()
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

	inst.entity:AddMiniMapEntity()
	inst.MiniMapEntity:SetPriority(5)
    inst.MiniMapEntity:SetIcon("sprinkler.png")

    inst:AddTag("structure")

	inst.AnimState:SetBank("sprinkler")
    inst.AnimState:SetBuild("sprinkler")
    inst.AnimState:PlayAnimation("idle_off")
    inst.AnimState:OverrideSymbol("swap_meter", "sprinkler_meter", 10)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst.on = false

	inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus

	inst:AddComponent("machine")
	inst.components.machine.turnonfn = TurnOn
	inst.components.machine.turnofffn = TurnOff
	inst.components.machine.caninteractfn = CanInteract
	inst.components.machine.cooldowntime = 0.5
	
	inst:AddComponent("fueled")
	inst.components.fueled:SetDepletedFn(OnFuelEmpty)
	inst.components.fueled.accepting = true
	inst.components.fueled:SetSections(10)
	inst.components.fueled.ontakefuelfn = ontakefuelfn
	inst.components.fueled:SetSectionCallback(OnFuelSectionChange)
	inst.components.fueled:InitializeFuelLevel(TUNING.SPRINKLER_MAX_FUEL_TIME)
	inst.components.fueled.bonusmult = TUNING.SPRINKLER_FUEL_BONUS_MULTIPLIER

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)
    inst.components.workable:SetOnWorkCallback(onhit)
    MakeSnowCovered(inst)
	
	inst:AddComponent("wateryprotection")
	inst.components.wateryprotection.extinguishheatpercent = TUNING.SPRINKLER_EXTINGUISH_HEAT_PERCENT
	inst.components.wateryprotection.temperaturereduction = TUNING.SPRINKLER_TEMP_REDUCTION
	inst.components.wateryprotection.witherprotectiontime = TUNING.SPRINKLER_PROTECTION_TIME
	inst.components.wateryprotection.addwetness = 0.01
	inst.components.wateryprotection.protection_dist = TUNING.SPRINKLER_PROTECTION_DIST
	inst.components.wateryprotection:AddIgnoreTag("player")
	inst.components.wateryprotection.onspreadprotectionfn = OnDeplete
	
	inst:SetStateGraph("SGsprinkler")

	inst.moisturizing = 2
	
	inst.UpdateSpray = UpdateSpray

	inst.OnSave = OnSave 
    inst.OnLoad = OnLoad
    inst.OnLoadPostPass = OnLoadPostPass
    inst.OnEntitySleep = OnEntitySleep

	inst:ListenForEvent("onbuilt", OnBuilt)
	
	MakeSnowCovered(inst, .01)

	inst.waterSpray = nil

	return inst
end

local function onhit(inst, dist)
	inst.SoundEmitter:PlaySound("dontstarve_DLC001/common/firesupressor_impact")
	SpawnPrefab("splash_snow_fx").Transform:SetPosition(inst:GetPosition():Get())	
	inst:Remove()
end

require "prefabutil"

return Prefab("g_sprinkler", Fn, assets, prefabs),
MakePlacer("g_sprinkler_placer", "sprinkler", "sprinkler", "idle_off")