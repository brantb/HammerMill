local ADDON_NAME, ns = ...

LoadAddOn("LibBagUtils-1.0")
local LBU = LibStub("LibBagUtils-1.0")
local MILL = 51005
local MILLNAME, _, MILLICON = GetSpellInfo(MILL)

-- Set up slash command
--[[SLASH_MASSMILL1, SLASH_MASSMILL2 = '/massmill', '/mm'
local function SlashHandler(args, editbox)
	print('Success!')
end
SlashCmdList["MASSMILL"] = SlashHandler
]]--

-- These were yanked from Panda
local herbIds = {2447, 765, 2449, 785, 2450, 2452, 3820, 2453, 3369, 3355, 3356, 3357, 
		3818, 3821, 3358, 3819, 4625, 8831, 8836, 8838, 8845, 8839, 8846,
		13464, 13463, 13465, 13466, 13467, 22785, 22786, 22787, 22789, 22790, 
		22791, 22792, 22793, 36901, 36903, 36904, 36905, 36906, 36907, 37921, 39970,
		36901, 36903, 36904, 36905, 36906, 36907, 37921, 39970, 52983, 52984, 52985, 
		52986, 52987, 52988};

local Inventory = {}
do
	local isDirty = true
	local function Update()
		list = {}
		for i,hid in ipairs(herbIds) do	
			for bag, slot in LBU:Iterate("BAGS", hid) do
				local _, stackSize, isLocked = GetContainerItemInfo(bag, slot)
				if not isLocked then 
					local itemName = GetItemInfo(hid)
					table.insert(list, { hid = hid, slot = slot, bag = bag, qty = stackSize })
				end
			end		
		end
		isDirty = false
	end
	function Inventory.getMillable()
		if isDirty then
			Update()
		end
		for idx,item in ipairs(list) do
			if item and item.qty >= 5 then
				return item.bag, item.slot
			end
		end
	end
	function Inventory.setDirty()
		isDirty = true
		list = nil
	end
end

-------------------
-- SETUP
-------------------
-- Create a secure action button
local button = CreateFrame("Button", "mmb", UIParent, "SecureActionButtonTemplate")
button:SetAttribute("type", "macro")
button:SetScript("PreClick", function(self, btn, isDown)
	local bag, slot = Inventory.getMillable()
	if bag and slot then
		local macroText = "/cast "..MILLNAME.."\n/use "..bag.." "..slot
		-- TODO: Make sure no milling action is in progress!
		self:SetAttribute("macrotext", macroText)
	else
		print("Nothing to mill!")
		self:SetAttribute("macrotext", "")
	end
end)
button:Hide()
-- Register for events
button:RegisterEvent("BAG_UPDATE")
button:SetScript("OnEvent", function(self, event)
	if event == "BAG_UPDATE" then
		Inventory.setDirty()
	end
end)
