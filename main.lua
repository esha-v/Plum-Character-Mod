local MyCharacterMod = RegisterMod("Plum Character Mod", 1)

local plumType = Isaac.GetPlayerTypeByName("Plum", false) 


function MyCharacterMod:GiveCostumesOnInit(player)
    
    if player:GetPlayerType() ~= plumType then
        return 
    end

end

MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyCharacterMod.GiveCostumesOnInit)


--------------------------------------------------------------------------------------------------


local game = Game()
local DAMAGE_REDUCTION = 0.6
local multiplier = 0.9
local timesRoomPlumSpawn = 0
local numPlums = 0
local SFXManager = SFXManager()

local Sound = {
    fluteSound = Isaac.GetSoundIdByName("flute2")
}


local Plum = {
    DAMAGE = -1.5,
    SPEED = -0.6,    
    TEARHEIGHT = 2,
    TEARFALLINGSPEED = 1,
    TEARRANGE=-100,
    MAXFIREDELAY = 1.5,
    LUCK = -2
    
}

function Plum:HandleStartingStats(player, flag)

    if player:GetPlayerType() ~= plumType then
        return 
    end

    if flag == CacheFlag.CACHE_DAMAGE then        
        player.Damage = player.Damage + Plum.DAMAGE
    end

    if flag == CacheFlag.CACHE_SPEED then        
        player.MoveSpeed = player.MoveSpeed + Plum.SPEED
    end

    if flag & flag == CacheFlag.CACHE_RANGE then        
        ---player.TearHeight = player.TearHeight - Plum.TEARHEIGHT
        ---player.TearFallingSpeed = player.TearFallingSpeed + Plum.TEARFALLINGSPEED
        player.TearRange = player.TearRange+Plum.TEARRANGE
    end

    
    if flag == CacheFlag.CACHE_FIREDELAY then        
        player.MaxFireDelay = player.MaxFireDelay + Plum.MAXFIREDELAY
    end

    if flag == CacheFlag.CACHE_LUCK then        
        player.Luck = player.Luck + Plum.LUCK
    end


    ---tear.CollisionDamage = player.Damage * multiplier

end

MyCharacterMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Plum.HandleStartingStats)


local plumsBean = Isaac.GetItemIdByName("Plum's Bean")

function MyCharacterMod:plumsBeanUse(item)

    local player = Isaac.GetPlayer()

    if Isaac.GetPlayer():GetPlayerType() ~= plumType then
        return 
    end

    local randNum = math.random(1,1000)
    local randNum2 = math.random(1,8)

    

    if randNum <= 350 then 
        SFXManager:Play(SoundEffect.SOUND_FLUTE, 25, 2, false, .7)
        for i=0,2,1
        do
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.FRUITY_PLUM, 0, Isaac.GetPlayer().Position, Vector(0,0), nil)
        end
    elseif randNum > 350 and randNum <= 800 then

        SFXManager:Play(SoundEffect.SOUND_FLUTE, 25, 2, false, 1)

        Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PLUM_FLUTE)

    elseif randNum>800 and randNum <= 925 then
        SFXManager:Play(SoundEffect.SOUND_FLUTE, 25, 2, false, .8)
        Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.FRUITY_PLUM, 0, Isaac.GetPlayer().Position, Vector(0,0), nil)
        timesRoomPlumSpawn = timesRoomPlumSpawn + 1
    else
        SFXManager:Play(SoundEffect.SOUND_FLUTE, 25, 2, false, 1.3)
        player:SetActiveCharge(8,ActiveSlot.SLOT_POCKET)
        
        if randNum2 <=4 then
            Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_PLUM_FLUTE)
        elseif randNum2 > 4 and randNum2 <=7 then
            for i=0,2,1
            do
                Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.FRUITY_PLUM, 0, Isaac.GetPlayer().Position, Vector(0,0), nil)
            end
        elseif randNum2 > 7 then
            Isaac.Spawn(EntityType.ENTITY_FAMILIAR, FamiliarVariant.FRUITY_PLUM, 0, Isaac.GetPlayer().Position, Vector(0,0), nil)
            timesRoomPlumSpawn = timesRoomPlumSpawn + 1
        end
    end

    ---Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD)

    return true
end

function MyCharacterMod:giveIsaacPlumsBean()
    if Isaac.GetPlayer():GetPlayerType() ~= plumType then
        return 
    end
    Isaac.GetPlayer():SetPocketActiveItem(plumsBean)
    Isaac.GetPlayer():AddCollectible(CollectibleType.COLLECTIBLE_FATE, 0, false) --- also give fate!
end

function MyCharacterMod:plumNewRoom()
    if Isaac.GetPlayer():GetPlayerType() ~= plumType then
        return 
    end
    local player = Isaac.GetPlayer()
    local sourceCollectibleID = plumsBean
    local collectibleRNG = player:GetCollectibleRNG(sourceCollectibleID)
    local itemConfig = Isaac.GetItemConfig():GetCollectible(sourceCollectibleID)
    local targetCount=0

    targetCount = targetCount+timesRoomPlumSpawn
    targetCount = targetCount + numPlums

    player:CheckFamiliar(FamiliarVariant.FRUITY_PLUM,targetCount,collectibleRNG,itemConfig)
        
end

function MyCharacterMod:resetPlumCount()
    if Isaac.GetPlayer():GetPlayerType() ~= plumType then
        return 
    end
    local player = Isaac.GetPlayer()
    local sourceCollectibleID = plumsBean
    local collectibleRNG = player:GetCollectibleRNG(sourceCollectibleID)
    local itemConfig = Isaac.GetItemConfig():GetCollectible(sourceCollectibleID)
    timesRoomPlumSpawn=0
    targetCount=0
    targetCount=0+numPlums
    player:CheckFamiliar(FamiliarVariant.FRUITY_PLUM,targetCount,collectibleRNG,itemConfig)

end

MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyCharacterMod.giveIsaacPlumsBean)
MyCharacterMod:AddCallback(ModCallbacks.MC_USE_ITEM, MyCharacterMod.plumsBeanUse, plumsBean)
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MyCharacterMod.plumNewRoom)
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, MyCharacterMod.resetPlumCount)
MyCharacterMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, MyCharacterMod.resetPlumCount)


MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, function(_, player)
    local player = Isaac.GetPlayer()
    local itemConfig = Isaac.GetItemConfig()

    if Isaac.GetPlayer():GetPlayerType() ~= plumType then
        return 
    end

    

    local itemConfigItem = itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_NEPTUNUS)
    player:RemoveCostume(itemConfigItem)
    local itemConfigItem = itemConfig:GetCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK)
    player:RemoveCostume(itemConfigItem)

    
    if (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_FRUITY_PLUM) > numPlums) then
        numPlums = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_FRUITY_PLUM)
    end
    


    local shootDir = player:GetAimDirection()

    local blacklistedCollectibles = {CollectibleType.COLLECTIBLE_EPIC_FETUS,
                                    CollectibleType.COLLECTIBLE_THE_LUDOVICO_TECHNIQUE, CollectibleType.COLLECTIBLE_MOMS_KNIFE, CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
                                    CollectibleType.COLLECTIBLE_SPIRIT_SWORD, CollectibleType.COLLECTIBLE_TECHNOLOGY} -- add more
    local function checkBlacklist(player)
        for _, collectible in ipairs(blacklistedCollectibles) do
            if player:HasCollectible(collectible) then
            return true
            end
        end

        return false
    end
    
    -- if EntityTear.Exists
    if not checkBlacklist(player) then

        if shootDir:Length() > 0.2 then
            if player:HasCollectible(CollectibleType.COLLECTIBLE_C_SECTION) then
                player:AddVelocity((-shootDir:Resized(0.1))*(player.ShotSpeed*2))
            else         
                player:AddVelocity((-shootDir:Resized(0.7))*(player.ShotSpeed*1.75)*(player.MoveSpeed*0.75))
            end
        end
    end

    ---player.AddPlayerFormCostume(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES)

end)
