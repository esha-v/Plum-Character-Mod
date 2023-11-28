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



function MyCharacterMod:HandleStartingStats(player, flag)
    if player:GetPlayerType() ~= plumType then
        return 
    end

    if flag == CacheFlag.CACHE_DAMAGE then
        
        player.Damage = player.Damage - DAMAGE_REDUCTION
    end

    if flag == CacheFlag.CACHE_FLYING then
        player.canFly = true
    end

end

MyCharacterMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MyCharacterMod.HandleStartingStats)


local plumsBean = Isaac.GetItemIdByName("Plum's Bean")

function MyCharacterMod:plumsBeanUse(item)

    if Isaac.GetPlayer():GetPlayerType() ~= plumType then
        return 
    end

    Isaac.GetPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_TAMMYS_HEAD)

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true
    }
end

function MyCharacterMod:giveIsaacPlumsBean()
    if Isaac.GetPlayer():GetPlayerType() ~= plumType then
        return 
    end
    Isaac.GetPlayer():SetPocketActiveItem(plumsBean)
    Isaac.GetPlayer():AddCollectible(CollectibleType.COLLECTIBLE_FATE, 0, false) --- also give fate!
end

MyCharacterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, MyCharacterMod.giveIsaacPlumsBean)
MyCharacterMod:AddCallback(ModCallbacks.MC_USE_ITEM, MyCharacterMod.plumsBeanUse, plumsBean)


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


    


    local shootDir = player:GetAimDirection()

    local blacklistedCollectibles = {CollectibleType.COLLECTIBLE_BRIMSTONE, CollectibleType.COLLECTIBLE_EPIC_FETUS,CollectibleType.COLLECTIBLE_C_SECTION,
                                    CollectibleType.COLLECTIBLE_THE_LUDOVICO_TECHNIQUE, CollectibleType.COLLECTIBLE_MOMS_KNIFE, CollectibleType.COLLECTIBLE_MONSTROS_LUNG,
                                    CollectibleType.COLLECTIBLE_SPIRIT_SWORD, CollectibleType.COLLECTIBLE_TECHNOLOGY, CollectibleType.COLLECTIBLE_TECH_X} -- add more
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
            player:AddVelocity((-shootDir:Resized(0.5))*(player.ShotSpeed*2))
        end
    end

    player.AddPlayerFormCostume(PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES)

end)
