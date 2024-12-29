-- Gale's Character ID
local galeCharID = "S_Player_Gale_ad9af97d-75da-406a-ae13-7071c563f604"

-- Constants for statuses and passives
local GALE_GOON_MAGICALLERGY_UNLOCK_STATUS = "GALE_GOON_MAGICALLERGY_UNLOCK_STATUS"
local GALE_WILDMAGIC_PERMANENT_REMOVAL = "GALE_WILDMAGIC_PERMANENT_REMOVAL"
local GALE_BOMB_STATUSES = { "ORI_GALE_BOMB1", "ORI_GALE_BOMB2", "ORI_GALE_BOMB3" }
local GALE_WILDMAGIC_PASSIVE = "Gale_WildMagic"
local GOON_MAGICALLERGY_AURA = "GOON_MAGICALLERGY_AURA"

-- Function to check if any bomb status is active
local function isBombActive()
    for _, bombStatus in ipairs(GALE_BOMB_STATUSES) do
        if Osi.HasActiveStatus(galeCharID, bombStatus) == 1 then
            return true
        end
    end
    return false
end

-- Unified function to update Magic Allergy and Wild Magic
local function updateMagicAndWildMagic()
    if not galeCharID or galeCharID == "" then
        Ext.Utils.Print("[ERROR] Gale's character ID is not valid!")
        return
    end

    local permanentRemovalActive = Osi.HasActiveStatus(galeCharID, GALE_WILDMAGIC_PERMANENT_REMOVAL) == 1
    local hasBombStatus = isBombActive()

    -- Handle Magic Allergy and Wild Magic when permanent removal is active
    if permanentRemovalActive then
        -- Remove Magic Allergy
        if Osi.HasActiveStatus(galeCharID, GALE_GOON_MAGICALLERGY_UNLOCK_STATUS) == 1 then
            Osi.RemoveStatus(galeCharID, GALE_GOON_MAGICALLERGY_UNLOCK_STATUS)
            Ext.Utils.Print("[DEBUG] Magic Allergy removed due to permanent removal.")
        end

        -- Remove Wild Magic
        if Osi.HasPassive(galeCharID, GALE_WILDMAGIC_PASSIVE) == 1 then
            Osi.RemovePassive(galeCharID, GALE_WILDMAGIC_PASSIVE)
            Ext.Utils.Print("[DEBUG] Wild Magic removed due to permanent removal.")
        end
        return
    end

    -- Update Magic Allergy based on bomb status
    if hasBombStatus then
        if Osi.HasActiveStatus(galeCharID, GALE_GOON_MAGICALLERGY_UNLOCK_STATUS) == 0 then
            Osi.ApplyStatus(galeCharID, GALE_GOON_MAGICALLERGY_UNLOCK_STATUS, -1, 1)
            Ext.Utils.Print("[DEBUG] Magic Allergy applied.")
        end
    else
        if Osi.HasActiveStatus(galeCharID, GALE_GOON_MAGICALLERGY_UNLOCK_STATUS) == 1 then
            Osi.RemoveStatus(galeCharID, GALE_GOON_MAGICALLERGY_UNLOCK_STATUS)
            Ext.Utils.Print("[DEBUG] Magic Allergy removed.")
        end
    end

    -- Update Wild Magic based on bomb status
    if hasBombStatus then
        if Osi.HasPassive(galeCharID, GALE_WILDMAGIC_PASSIVE) == 0 then
            Osi.AddPassive(galeCharID, GALE_WILDMAGIC_PASSIVE)
            Ext.Utils.Print("[DEBUG] Wild Magic applied due to Bomb status.")
        end
    elseif Osi.HasPassive(galeCharID, GALE_WILDMAGIC_PASSIVE) == 1 then
        -- Make sure Wild Magic stays until Bomb3 is removed
        if not Osi.HasActiveStatus(galeCharID, "ORI_GALE_BOMB3") then
            Osi.RemovePassive(galeCharID, GALE_WILDMAGIC_PASSIVE)
            Ext.Utils.Print("[DEBUG] Wild Magic removed as no Bomb status is active.")
        end
    end
end

-- Listener for bomb status application
Ext.Osiris.RegisterListener("StatusApplied", 4, "after", function(target, status)
    if target == galeCharID then
        -- Check if the applied status is one of the bomb statuses
        for _, bombStatus in ipairs(GALE_BOMB_STATUSES) do
            if status == bombStatus then
                Ext.Utils.Print("[DEBUG] Bomb status applied: " .. status)
                updateMagicAndWildMagic()
                break
            end
        end
    end
end)


-- Handle Bomb3-specific removal
Ext.Osiris.RegisterListener("StatusRemoved", 4, "after", function(target, status)
    if target == galeCharID then
        Ext.Utils.Print("[DEBUG] Status removed: " .. status)

        -- Remove Wild Magic when Bomb3 is removed
        if status == "ORI_GALE_BOMB3" then
            Ext.Utils.Print("[DEBUG] Bomb3 status removed for Gale.")
            if Osi.HasPassive(galeCharID, GALE_WILDMAGIC_PASSIVE) == 1 then
                Osi.RemovePassive(galeCharID, GALE_WILDMAGIC_PASSIVE)
                Ext.Utils.Print("[DEBUG] Wild Magic removed due to Bomb3 removal.")
            end
        end

        -- Update Magic Allergy and Wild Magic
        updateMagicAndWildMagic()
    end
end)

