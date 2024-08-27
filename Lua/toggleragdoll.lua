
	--how long it takes to cancel the ragdoll after a movement key is pressed (0.1 means you need to hold WASD for 0.1 to cancel ragdoll)
local RagdollTimeout = 0.1

local IsRagdolling = false
local IsWaitingRelease = false
local RagdollRelease = -1

LuaUserData.MakeFieldAccessible(LuaUserData.RegisterTypeBarotrauma("Character"), "keys") 
LuaUserData.MakeFieldAccessible(LuaUserData.RegisterTypeBarotrauma("Key"), "inputType")

Hook.Patch("Barotrauma.Character", "ControlLocalPlayer", {
    "System.Single", "Barotrauma.Camera", "System.Boolean"
},
function (instance, ptable)

	if 
			RagdollTimeout ~= 0 
		and IsRagdolling 
		and ragdoll_movement_pressed(instance) 
	then
	
        if 
			IsWaitingRelease 
		then
		
            if 
				Game.GameScreen.GameTime - RagdollRelease > RagdollTimeout 
			then
                IsRagdolling = false
                IsWaitingRelease = false
            end
			
        else 
            IsWaitingRelease = true
            RagdollRelease = Game.GameScreen.GameTime
        end
		
    else
        IsWaitingRelease = false
    end


	for key, _ in instance.keys do
	
        if 
			key.inputType == InputType.Ragdoll 
		then
            if 
				IsRagdolling 
			then
                if 
					key.Hit 
				then
                    IsRagdolling = false
                else
                    key.Held = true
                end
				
			elseif 
				key.Hit 
			then
				IsRagdolling = true
			end
			
        end
		
    end 
	
end, Hook.HookMethodType.After)

function ragdoll_movement_pressed(character)
    return character.IsKeyDown(InputType.Left) or character.IsKeyDown(InputType.Right) or character.IsKeyDown(InputType.Up) or character.IsKeyDown(InputType.Down)
end