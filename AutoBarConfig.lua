--
-- AutoBarConfig
--
-- Config options in the standard place
--

-- http://muffinmangames.com
--
local _, AB = ...

local types = AB.types	---@class ABTypes
local code = AB.code	---@class ABCode

local AutoBar = AutoBar

local L = AutoBarGlobalDataObject.locale
local _
local UI = AB.UITK
AB.AutoBarConfig = {}

local ABC = AB.AutoBarConfig
ABC.Debug = {} --table to store stuff related to the Debug Frame


ABC.main_panel_category = nil
ABC.debug_frame_category = nil

ABC.main_panel = CreateFrame( "Frame", "AutoBarConfig", UIParent );
ABC.main_panel.name = "AutoBar";

if InterfaceOptions_AddCategory then
	InterfaceOptions_AddCategory(ABC.main_panel)
else
	local layout
	ABC.main_panel_category, layout = _G.Settings.RegisterCanvasLayoutCategory(ABC.main_panel, ABC.main_panel.name)
	_G.Settings.RegisterAddOnCategory(ABC.main_panel_category)
end

-- Categories panel
local max_categories_in_list = 29

local function update_visible_categories()


end


ABC.categories_panel = CreateFrame( "Frame", "AutoBarConfig_Categories", ABC.main_panel, BackdropTemplateMixin and "BackdropTemplate");
ABC.categories_panel.name = "Custom Categories";
ABC.categories_panel.parent = ABC.main_panel.name;
ABC.categories_panel:SetBackdrop({
	bgFile = "Interface/ChatFrame/ChatFrameBackground",
	tile = false,
	insets = { left = 3, right = 3, top = 3, bottom = 3 },
})
ABC.categories_panel:SetBackdropColor(0.1, 0.1, 0.15, 0.9);
ABC.categories_panel:EnableMouse(true)
ABC.categories_panel:EnableMouseWheel(true)
ABC.categories_panel:SetScript("OnMouseWheel", function(self, p_delta)
	local s_min, s_max = ABC.category_slider:GetMinMaxValues()
	local val = ABC.category_slider:GetValue()
	local new_value = Clamp(val - (p_delta * 3), s_min, s_max)
	ABC.category_slider:SetValue(new_value)
end)
--InterfaceOptions_AddCategory(ABC.categories_panel);


ABC.category_slider = UI.create_slider(ABC.categories_panel, {min = 1, max = max_categories_in_list});

ABC.categories_panel.buttonlist = {}

for i = 1, max_categories_in_list do
	local b = CreateFrame("Button", nil, ABC.categories_panel, BackdropTemplateMixin and "BackdropTemplate");
	b:SetSize(180, 16)
	if(i == 1) then
		b:SetPoint("TOPLEFT", 6, -6)
	else
		b:SetPoint("TOPLEFT", ABC.categories_panel.buttonlist[i-1], "BOTTOMLEFT", 0, -2)
	end
	b:SetBackdrop({bgFile = "Interface/ChatFrame/ChatFrameBackground", tile = false})
	b:SetBackdropColor(0, 0.7, 0, 1)
	b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	ABC.categories_panel.buttonlist[i] = b

end

ABC.category_slider.my_button_up:SetPoint("TOPLEFT", ABC.categories_panel.buttonlist[1], "TOPRIGHT", 5, 0)
local height = (max_categories_in_list - 2) * 16 + (max_categories_in_list * 2)
ABC.category_slider:SetSize(20, height);


ABC.category_slider:SetScript("OnValueChanged", function (self, value)
	update_visible_categories()
end)






local AceGUI = LibStub("AceGUI-3.0")


ABC.DebugFrame = AceGUI:Create("BlizOptionsGroup")
ABC.DebugFrame:SetName("Debug", "AutoBar")
ABC.DebugFrame:SetLayout("Fill")


if InterfaceOptions_AddCategory then
	InterfaceOptions_AddCategory(ABC.DebugFrame.frame)
else
	local layout
	ABC.debug_frame_category, layout = _G.Settings.RegisterCanvasLayoutSubcategory(ABC.main_panel_category, ABC.DebugFrame.frame, ABC.DebugFrame.frame.name)
	_G.Settings.RegisterAddOnCategory(ABC.debug_frame_category)
end

--local function print_map_ids()
--local res = "";
--	for i = 1, 4000 do
--		local map_info = C_Map.GetMapInfo(i);
--		if(map_info) then
--			res = res .. "|n" .. tostring(i) .. "   " .. map_info.name;
--		end
--	end
--
--	return res;
--end

local function find_nameless_categories()

	local nameless = ""
	for key in pairs(AutoBarCategoryList) do
		if(AutoBarGlobalDataObject.locale[key] == nil) then
			nameless = nameless .. "|n" .. key
		end
	end

	return nameless
end


local function find_nameless_buttons()

	local nameless = ""
	for key in pairs(AutoBar.Class) do
		if(AutoBarGlobalDataObject.locale[key] == nil) then
			nameless = nameless .. "|n" .. key
		end
	end

	return nameless
end

local function set_nameless_category_text(p_widget)

	local edit_box_cat = p_widget:GetUserData("edit_box_cat")
	edit_box_cat:SetText(find_nameless_categories())

	local edit_box_btn = p_widget:GetUserData("edit_box_btn")
	edit_box_btn:SetText(find_nameless_buttons())

--	edit_box:SetText(print_map_ids())

end



-- function that draws the widgets for the first tab
local function DrawGroupNamelessCategories(container)

	local button = AceGUI:Create("Button")
	button:SetText("Find Nameless Categories/Buttons")
	button:SetWidth(200)
	button:SetCallback("OnClick", set_nameless_category_text)
	container:AddChild(button)

	local edit_box_cat = AceGUI:Create("MultiLineEditBox")
	edit_box_cat:SetNumLines(15)
	edit_box_cat:SetFullWidth(true)
	edit_box_cat:DisableButton(true)
	edit_box_cat:SetLabel(nil)
	container:AddChild(edit_box_cat)

	local edit_box_btn = AceGUI:Create("MultiLineEditBox")
	edit_box_btn:SetNumLines(15)
	edit_box_btn:SetFullWidth(true)
	edit_box_btn:DisableButton(true)
	edit_box_btn:SetLabel('')
	container:AddChild(edit_box_btn)

	button:SetUserData("edit_box_cat", edit_box_cat)
	button:SetUserData("edit_box_btn", edit_box_btn)
end



-- function that draws the widgets for the second tab
local function DrawGroupWarnings(container)


	local edit_box = AceGUI:Create("MultiLineEditBox")
	edit_box:SetNumLines(28)
	edit_box:SetFullWidth(true)
	edit_box:DisableButton(true)
	edit_box:SetLabel("")
	container:AddChild(edit_box)

	edit_box:SetText(code.get_warning_log_string())

end

-- Callback function for OnGroupSelected
local function SelectGroup(container, event, group)
   container:ReleaseChildren()
   if group == "tab1" then
      DrawGroupNamelessCategories(container)
   elseif group == "tab2" then
      DrawGroupWarnings(container)
   end
end

local tab =  AceGUI:Create("TabGroup")
tab:SetLayout("Flow")
-- Setup which tabs to show
tab:SetTabs({{text="Nameless Categories", value="tab1"}, {text="Warnings", value="tab2"}})
-- Register callback
tab:SetCallback("OnGroupSelected", SelectGroup)
-- Set initial Tab (this will fire the OnGroupSelected callback)
tab:SelectTab("tab1")

-- add to the frame container
ABC.DebugFrame:AddChild(tab)