
-- Bundled by luabundle {"version":"1.7.0"}
local __bundle_require, __bundle_loaded, __bundle_register, __bundle_modules = (function(superRequire)
	local loadingPlaceholder = {[{}] = true}

	local register
	local modules = {}

	local require
	local loaded = {}

	register = function(name, body)
		if not modules[name] then
			modules[name] = body
		end
	end

	require = function(name)
		local loadedModule = loaded[name]

		if loadedModule then
			if loadedModule == loadingPlaceholder then
				return nil
			end
		else
			if not modules[name] then
				if not superRequire then
					local identifier = type(name) == 'string' and '"' .. name .. '"' or tostring(name)
					error('Tried to require ' .. identifier .. ', but no such module has been registered')
				else
					return superRequire(name)
				end
			end

			loaded[name] = loadingPlaceholder
			loadedModule = modules[name](require, loaded, register, modules)
			loaded[name] = loadedModule
		end

		return loadedModule
	end

	return require, loaded, register, modules
end)(require)
__bundle_register("__root", function(require, _LOADED, __bundle_register, __bundle_modules)
--- AUTO GENERATED FILE. DO NOT CHANGE!
local CharacterSheet = require("Game.Frosthaven.Component.FrosthavenCharacterSheet")


CharacterSheet.setup({
  perkPositions = {
  --[] Remove one [-2] card
  {81.99712292901398, 322.72622249902065},
  --[] Remove two [-1] cards
  {81.99712292901398, 297.0799374726736},
  --[][][] Replace one [-1] card with one [+0] "bless, [target] self or 1 ally" card
  {81.99712292901398, 271.43365244632673},
  {104.33904187432648, 271.43366560045524},
  {126.68096081963904, 271.43365244632673},
  --[][][]Replace one [+0] card with one [+2] "Add +1 [attack] if the top card of the monster attack modifier deck is revealed"
  {81.99712292901398, 194.89152007495932},
  {104.33904187432648, 194.89153322908783},
  {126.68096081963904, 194.89152007495932},
  --[][]Replace one [+0] card with one [+2] light-dark card
  {81.99712292901398, 67.55655586019793},
  {104.33904187432648, 67.55656901432644},
  --[][]Add one [+1] "Place this card in your active area. When you next place a rift, discard this card to place another rift within [range] 1 of it" rolling
  {81.99712292901398, 16.410920143679398},
  {104.33904187432648, 16.4109332978079},
  --[]Ignore scenario effects and add two [+1] cards
  {81.99712292901398, -110.9240978931831},
  --[]Whenever you long rest, you may read one unread [section] from the current scenario's "Section Links"
  {81.99712292901398, -161.98154609694592},
  --[|]Whenever you place a rift, you may perform "pull 1, [target] 1 ally or enemy, [range] 1" as if you occupied a hex containing a portal
  {81.99712292901398, -263.74371936449853},
  {81.99712292901398, -276.5713082022208},
  --[|]Whenever a deck is shuffled, you may set aside all revealed cards from that deck and place them back on top after shuffling
  {81.99712292901398, -365.68226765756293},
  {81.99712292901398, -378.5098564952852},
}
,
masteryPositions = {
  --[] For an entire scenario, reveal at least one card from an attack modifier deck or monster ability card deck each round
  {-337.6580600080819, -342.2846161957116},
  --[] Target 6 figures with an ability that targets figures occupying hexes containing rifts
  {-337.6580600080819, -418.70912036498686},
}

})

end)
__bundle_register("Game.Frosthaven.Component.FrosthavenCharacterSheet", function(require, _LOADED, __bundle_register, __bundle_modules)
local Ui = require("lib.Ui")
local TableUtil = require("lib.TableUtil")

local BaseCharacterSheet = require("Game.Engine.Component.BaseCharacterSheet")
local Checkmark = require("ui.element.Checkmark")
local Counter = require("ui.element.Counter")

local CharacterSheet = {}

---@class Frosthaven_CharacterSheet : CharacterSheet

---@shape Frosthaven_CharacterSheet_Data : CharacterSheet_Data
---@field resources Frosthaven_Supply
---@field masteries set<integer>

---@shape Frosthaven_CharacterSheet_Setup : CharacterSheet_Setup
---@field masteryPositions seb_Vector2[]

---@param setup Frosthaven_CharacterSheet_Setup
---@return Frosthaven_CharacterSheet
local function new(setup)
  local self = --[[---@type Frosthaven_CharacterSheet]] BaseCharacterSheet.create(setup)

  local this = {
    masteryPositions = setup.masteryPositions or {}
  }

  self.data.resources = {
    wood = 0,
    metal = 0,
    hide = 0,
    arrowvine = 0,
    axenut = 0,
    corpsecap = 0,
    flamefruit = 0,
    rockroot = 0,
    snowthistle = 0,
  }
  self.data.masteries = {}

  local superCreateUi = self.createUi
  function self.createUi(front, back)
    superCreateUi(front, back)

    this.initResourceCounters(front)
    this.initMasteries(front)
  end

  local superSaveCharacterData = self.saveCharacterData
  function self.saveCharacterData(character)
    character = superSaveCharacterData(character)

    character.masteries = TableUtil.setToList(self.data.masteries)
    character.resources = self.data.resources

    return character
  end

  local superLoadCharacterData = self.loadCharacterData
  function self.loadCharacterData(character)
    superLoadCharacterData(character)
    self.data.resources = character.resources or {}
    self.data.masteries = TableUtil.listToSet(character.masteries or {})
  end

  ---@param index integer
  function hasMastery(index)
    return self.data.masteries[index]
  end

  ---@param root seb_XmlUi_Panel
  function this.initResourceCounters(root)
    ---@param name
    ---@param offset seb_Vector2
    local function addSupplyPanel(name, offset)
      local counter = Counter.create({
        id = "resource_" .. name,
        value = self.data.resources[name] or 0,
        min = 0,
        size = 60,
        offset = offset,
        onValueChange = self.changeState(this.onResourceChanged),
      })

      root.addChild(counter.element)
    end

    local rows = {
      { y = 20,
        ---@type string[]
        resources = { "wood", "metal", "hide" }, },
      { y = -45,
        ---@type string[]
        resources = { "arrowvine", "axenut", "corpsecap" }, },
      { y = -100,
        ---@type string[]
        resources = { "flamefruit", "rockroot", "snowthistle" }, }
    }
    ---@type integer[]
    local columns = { -280, -150, -20 }

    for _, row in ipairs(rows) do
      for column, resource in ipairs(row.resources) do
        addSupplyPanel(resource, { columns[column], row.y })
      end
    end
  end

  ---@type UI_Counter_Handler
  this.onResourceChanged = function(_, value, element)
    local resource = Ui.getPart(element.id, "_(.*)")
    self.data.resources[resource] = value
  end

  ---@param front seb_XmlUi_Panel
  function this.initMasteries(front)
    local index = 1
    for _, position in ipairs(this.masteryPositions) do
      local mastery = Checkmark.create({
        id = "mastery_" .. index,
        value = self.data.masteries[index],
        offset = position,
        size = 20,
        onValueChange = self.changeState(this.onMasteryClicked),
      })
      index = index + 1

      front.addChild(mastery.element)
    end
  end

  ---@type UI_Checkmark_Handler
  this.onMasteryClicked = function(_, value, element)
    local mastery = Ui.getIndex(element.id, "_(.*)")
    self.data.masteries[mastery] = value
  end

  return self
end

---@param setup Frosthaven_CharacterSheet_Setup
---@return Frosthaven_CharacterSheet
function CharacterSheet.setup(setup)
  return new(setup)
end

return CharacterSheet

end)
__bundle_register("ui.element.Counter", function(require, _LOADED, __bundle_register, __bundle_modules)
local Ui = require("lib.Ui")
local XmlUi = require("lib.XmlUi")

local BaseElement = require("ui.element.BaseElement")

local Counter = {}
local this = {}

---@class UI_Counter : UI_Element

---@shape UI_Counter_Parameters : UI_Element_Parameters
---@field textSize nil | integer
---@field value integer
---@field onValueChange UI_Counter_Handler
---@field min nil | integer
---@field max nil | integer

---@alias UI_Counter_Handler fun(player: tts__Player, value: integer, element: UI_Counter)

---@shape __UI_Counter_Settings
---@field element UI_Counter
---@field onValueChange UI_Counter_Handler
---@field value integer
---@field min nil | integer
---@field max nil | integer

---@type table<string, __UI_Counter_Settings>
local elements = {}
local UiSettings = {
  colors = { "#FFFFFF00", "#00000070", "#000000B0" },
  font = "fonts/MarkaziGloom",
}

---@param params UI_Counter_Parameters
---@return UI_Counter
function Counter.create(params)
  local self = --[[---@type UI_Counter]] BaseElement(params)

  local root = self.element
  local fontSize = params.textSize or Ui.fontSize(params.size)
  local buttonSize = params.size / 2
  local buttonFontSize = Ui.fontSize(buttonSize)
  local margin = 0

  root.addInputField({
    id = self.elementId("input"),
    text = tostring(params.value),
    textAlignment = XmlUi.Alignment.MiddleCenter,
    characterValidation = "Integer",
    font = UiSettings.font,
    fontSize = fontSize,
    verticalOverflow = "Overflow",
    horizontalOverflow = "Overflow",
    width = params.size * 1.2, height = params.size,
    colors = UiSettings.colors,
    onEndEdit = self.handlerName("onCounterValueChanged"),
  })
  root.addButton({
    id = self.elementId("add"),
    offsetXY = { buttonSize + margin, 0 },
    width = buttonSize, height = buttonSize,
    text = "+",
    font = UiSettings.font,
    fontSize = buttonFontSize,
    verticalOverflow = "Overflow",
    resizeTextForBestFit = true,
    colors = UiSettings.colors,
    onClick = self.handlerName("onCounterAddClicked"),
  })
  root.addButton({
    id = self.elementId("remove"),
    offsetXY = { -(buttonSize + margin), 0 },
    width = buttonSize, height = buttonSize,
    text = "-",
    font = UiSettings.font,
    fontSize = buttonFontSize,
    resizeTextForBestFit = true,
    colors = UiSettings.colors,
    onClick = self.handlerName("onCounterRemoveClicked"),
  })

  elements[self.fullId] = {
    element = self,
    onValueChange = params.onValueChange,
    value = params.value,
    min = params.min,
    max = params.max,
  }

  ---@return integer
  function self.getValue()
    return elements[self.fullId].value
  end

  ---@param value integer
  function self.setValue(value)
    this.setValue(self.fullId, value)
  end

  return self
end

---@type UIElement_Callback
onCounterValueChanged = function(player, value, id)
  local actualValue = --[[---@not nil]] tonumber(value)
  local baseId = --[[---@type string]] id:match("^(.*)-input")
  local current = elements[baseId].value

  this.changeValue(player, baseId, actualValue - current)
end

---@type UIElement_Callback
onCounterAddClicked = function(player, _, id)
  local baseId = --[[---@type string]] id:match("^(.*)-add$")
  this.changeValue(player, baseId, 1)
end

---@type UIElement_Callback
onCounterRemoveClicked = function(player, _, id)
  local baseId = --[[---@type string]] id:match("^(.*)-remove$")
  this.changeValue(player, baseId, -1)
end

---@param id string
---@param diff integer
function this.getNewValue(id, diff)
  local settings = elements[id]
  local newValue = settings.value + diff

  if settings.min and newValue < settings.min then
    newValue = settings.min
  end

  if settings.max and newValue > settings.max then
    newValue = settings.max
  end

  return newValue
end

---@param id string
---@param diff integer
function this.changeValue(player, id, diff)
  local newValue = this.getNewValue(id, diff)
  local currentValue = elements[id].value

  if newValue ~= currentValue then
    local result = elements[id].onValueChange(player, newValue, elements[id].element)
    if result == nil or result == true then
      this.setValue(id, newValue)
    end
  end
end

---@param id string
---@param value integer
function this.setValue(id, value)
  elements[id].value = value
  elements[id].element.setAttribute("input", "text", value)
end

return Counter

end)
__bundle_register("ui.element.BaseElement", function(require, _LOADED, __bundle_register, __bundle_modules)
local Logger = require("lib.Logger")
local StringUtil = require("lib.StringUtil")
local Ui = require("lib.Ui")
local XmlUi = require("lib.XmlUi")

---@class UI_Element_static
---@overload fun(params: UI_Element_Parameters): UI_Element
local BaseElement = {}
local this = {}

---@class UI_Element
---@field id tts__UIElement_Id
---@field element seb_XmlUi_Element
---@field owner tts__Object

---@class UI_Tooltip_Parameter
---@field element UI_Tooltip
---@field value nil | string

---@class Offset_With_Alignment
---@field [1] tts__UIElement_Alignment
---@field [2] number
---@field [3] number
---@field [any] nil

---@class UI_Element_Parameters
---@field id string
---@field owner nil | GUID
---@field active nil | boolean
---@field width nil | integer
---@field height nil | integer
---@field size nil | integer
---@field offset nil | seb_Vector2 | Offset_With_Alignment
---@field tooltip nil | UI_Tooltip_Parameter
---@field background nil | seb_XmlUi_Color
---@field onMouseEnter nil | UI_BaseCallBack
---@field onMouseExit nil | UI_BaseCallBack

---@alias UI_BaseCallBack fun(player: tts__Player, element: UI_Element)

---@class __UI_Element_Settings
---@field element UI_Element
---@field tooltip nil | { element: UI_Tooltip, value: string }
---@field onMouseEnter nil | UI_BaseCallBack
---@field onMouseExit nil | UI_BaseCallBack

---@type table<string, __UI_Element_Settings>
local elements = {}

---@param params UI_Element_Parameters
local function new(params)
  assert(params.id, "Need an id to create a UI element.")

  local ttsSelf = self
  local self = --[[---@type UI_Element]] {}

  self.id = params.id
  self.fullId = (params.owner or "") .. "__" .. self.id
  if params.owner then
    self.owner = getObjectFromGUID(params.owner)
  else
    self.owner = ttsSelf
  end
  Logger.assert(self.owner, "Can not identify the owner %s of UI element %s", params.owner, params.id)

  ---@param subElement string
  ---@return string
  function self.elementId(subElement)
    return self.fullId .. "-" .. subElement
  end

  ---@param name string
  ---@return gloom_OptionName
  function self.handlerName(name)
    if self.owner ~= ttsSelf then
      local ownerId = ttsSelf == Global and "Global" or ttsSelf.getGUID()
      return ownerId .. "/" .. name
    end

    return name
  end

  ---@param active boolean
  function self.setActive(active)
    self.setAttribute("root", "active", active)
  end

  ---@param offset seb_Vector2
  function self.setOffset(offset)
    self.setAttribute("root", "offsetXY", offset[1] .. " " .. offset[2])
  end

  ---@param value nil | string
  function self.setTooltip(value)
    local tooltip = elements[self.fullId].tooltip
    Logger.assert(tooltip,
      "Tried to change tooltip for element '%s', but no UI element for it was defined.", self.fullId)

    ;
    ( --[[---@not nil]] tooltip).value = value
  end

  ---@param subElement string
  ---@param attribute string
  ---@param value string | number | boolean
  function self.setAttribute(subElement, attribute, value)
    local elementId = self.elementId(subElement)
    Logger.debug("Setting UI element %s: %s=%s", elementId, attribute, value)
    self.owner.UI.setAttribute(elementId, attribute, value)
  end

  ---@type nil | string
  local onMouseEnterFunction
  if params.tooltip or params.onMouseEnter then
    onMouseEnterFunction = self.handlerName("onMouseEnter")
  end

  ---@type nil | string
  local onMouseExitFunction
  if params.tooltip or params.onMouseExit then
    onMouseExitFunction = self.handlerName("onMouseExit")
  end

  ---@type nil | seb_Vector2
  local offsetXy = nil
  ---@type nil | tts__UIElement_Alignment
  local rectAlignment = nil

  if params.offset then
    if type(params.offset[1]) == "string" then
      local withOffset = --[[---@type Offset_With_Alignment]] params.offset
      offsetXy = { withOffset[2], withOffset[3] }
      rectAlignment = withOffset[1]
    else
      offsetXy = --[[---@not Offset_With_Alignment]] params.offset
    end
  end

  self.element = XmlUi.Factory.createPanel({
    id = self.elementId("root"),
    active = params.active,
    width = params.width or params.size,
    height = params.height or params.size,
    color = params.background,
    rectAlignment = rectAlignment,
    offsetXY = offsetXy,
    onMouseEnter = onMouseEnterFunction,
    onMouseExit = onMouseExitFunction,
  })

  elements[self.fullId] = {
    element = self,
    tooltip = params.tooltip,
    onMouseEnter = params.onMouseEnter,
    onMouseExit = params.onMouseExit,
  }

  return self
end

setmetatable(BaseElement, {
  ---@param params UI_Element_Parameters
  __call = function(_, params)
    return new(params)
  end
})

---@param id tts__UIElement_Id
---@return tts__UIElement_Id
function this.getBaseId(id)
  return Ui.getPart(id, "^(.*)-root$")
end

---@type UIElement_Callback
onMouseEnter = function(player, _, id)
  local baseId = this.getBaseId(id)
  local settings = elements[baseId]
  if settings.tooltip then
    local tooltip = --[[---@not nil]] settings.tooltip
    if StringUtil.isNotEmpty(tooltip.value) then
      tooltip.element.setActive(true)
      tooltip.element.setText(tooltip.value)
    end
  end

  if settings.onMouseEnter then
    settings.onMouseEnter(player, settings.element)
  end
end

---@type UIElement_Callback
onMouseExit = function(player, _, id)
  local baseId = this.getBaseId(id)
  local settings = elements[baseId]
  if settings.tooltip then
    local tooltip = --[[---@not nil]] settings.tooltip
    tooltip.element.setActive(false)
  end

  if settings.onMouseExit then
    settings.onMouseExit(player, settings.element)
  end
end

return BaseElement

end)
__bundle_register("lib.XmlUi", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiContainer = require("lib.xmlui.XmlUiContainer")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")

require("lib.xmlui.XmlUiAxisLayout")
require("lib.xmlui.XmlUiButton")
require("lib.xmlui.XmlUiCell")
require("lib.xmlui.XmlUiDefaults")
require("lib.xmlui.XmlUiDropdown")
require("lib.xmlui.XmlUiGridLayout")
require("lib.xmlui.XmlUiImage")
require("lib.xmlui.XmlUiInputField")
require("lib.xmlui.XmlUiOption")
require("lib.xmlui.XmlUiPanel")
require("lib.xmlui.XmlUiProgressBar")
require("lib.xmlui.XmlUiRow")
require("lib.xmlui.XmlUiScrollView")
require("lib.xmlui.XmlUiSlider")
require("lib.xmlui.XmlUiTableLayout")
require("lib.xmlui.XmlUiText")
require("lib.xmlui.XmlUiToggle")
require("lib.xmlui.XmlUiToggleButton")
require("lib.xmlui.XmlUiToggleGroup")

---@class seb_XmlUi : seb_XmlUi_Container

---@class seb_XmlUi_Static
---@overload fun(object: tts__Object): seb_XmlUi
local XmlUi = {}

XmlUi.Factory = XmlUiFactory

--- Values available for alignment attributes.
XmlUi.Alignment = {
  UpperLeft = "UpperLeft",
  UpperCenter = "UpperCenter",
  UpperRight = "UpperRight",
  MiddleLeft = "MiddleLeft",
  MiddleCenter = "MiddleCenter",
  MiddleRight = "MiddleRight",
  LowerLeft = "LowerLeft",
  LowerCenter = "LowerCenter",
  LowerRight = "LowerRight",
}

--- Values available for animation attributes.
XmlUi.Animation = {
  Show = {
    None = "None",
    Grow = "Grow",
    FadeIn = "FadeIn",
    SlideInLeft = "SlideIn_Left",
    SlideInRight = "SlideIn_Right",
    SlideInTop = "SlideIn_Top",
    SlideInBottom = "SlideIn_Bottom",
  },
  Hide = {
    None = "None",
    Shrink = "Shrink",
    FadeOut = "FadeOut",
    SlideOut_Left = "SlideOut_Left",
    SlideOutRight = "SlideOutRight",
    SlideOutTop = "SlideOut_Top",
    SlideOutBottom = "SlideOutBottom",
  },
}

--- Values available for fontStyle attributes.
XmlUi.FontStyle = {
  Bold = "Bold",
  BoldAndItalic = "BoldAndItalic",
  Italic = "Italic",
  Normal = "Normal",
}

XmlUi.GridLayout = {
  FixedColumnCount = "FixedColumnCount"
}

XmlUi.MouseEvent = {
  LeftClick = "-1",
  RightClick = "-2",
  MiddleClick = "-3",
  SingleTouch = "1",
  DoubleTouch = "2",
  TripleTouch = "3",
}

---@param object tts__Object
local function new(object)
  local self = --[[---@type seb_XmlUi]] XmlUiContainer()
  local boundObject = object
  local children = self._wrapChildren(boundObject.UI.getXmlTable())

  ---@type tts__UIAsset[]
  local assets = boundObject.UI.getCustomAssets()
  local assetsChanged = false

  ---@return tts__UIElement[]
  local function createXmlTable()
    return TableUtil.map(children, function(child) return child.getXmlElement() end)
  end

  ---@param childElements seb_XmlUi_Element[]
  ---@param elementId string
  local function findElementById(childElements, elementId)
    for _, element in pairs(childElements) do
      if element.getId() == elementId then
        return element
      end
      local inChild = findElementById(element.getChildren(), elementId)
      if inChild then
        return inChild
      end
    end
  end

  ---@param elementId tts__UIElement_Id
  ---@return nil | seb_XmlUi_Element
  function self.findElement(elementId)
    return findElementById(children, elementId)
  end

  function self.getChildren()
    return children
  end

  ---@param elementId string
  ---@param attribute string
  ---@param value string | number | boolean
  function self.setAttribute(elementId, attribute, value)
    boundObject.UI.setAttribute(elementId, attribute, value)
  end

  function self.clearElements()
    children = {}
  end

  ---@param element seb_XmlUi_Element
  function self.addChild(element)
    element.bindUi(self) -- TODO propagate to children

    for i, child in ipairs(children) do
      if element.getZIndex() < child.getZIndex() then
        table.insert(children, i, element)
        return
      end
    end

    table.insert(children, element)
  end

  ---@param elementId tts__UIElement_Id
  function self.show(elementId)
    boundObject.UI.show(elementId)
  end

  ---@param elementId tts__UIElement_Id
  function self.hide(elementId)
    boundObject.UI.hide(elementId)
  end

  function self.update()
    local xmlTable = createXmlTable()
    if TableUtil.isNotEmpty(xmlTable) then
      boundObject.UI.setXmlTable(xmlTable)
    end
  end

  ---@return boolean
  function self.updateUiAssets()
    if assetsChanged then
      boundObject.UI.setCustomAssets(assets)
      assetsChanged = false
      return true
    end

    return false
  end

  ---@param assetList tts__UIAsset[]
  function self.updateAssets(assetList)
    for _, asset in ipairs(assetList) do
      self.updateAsset(asset.name, asset.url)
    end
  end

  ---@param assetName string
  ---@param assetUrl URL
  function self.updateAsset(assetName, assetUrl)
    for _, asset in ipairs(assets) do
      if asset.name == assetName then
        if asset.url ~= assetUrl then
          asset.url = assetUrl
          assetsChanged = true
        end
        return
      end
    end

    table.insert(assets, { name = assetName, url = assetUrl, })
    assetsChanged = true
  end

  ---@param assetName string
  ---@return boolean
  function self.removeAsset(assetName)
    for i, asset in ipairs(assets) do
      if asset.name == assetName then
        assetsChanged = true
        table.remove(assets, i)
        return true
      end
    end

    return false
  end

  ---@param assetPattern string
  ---@return boolean
  function self.removeAssets(assetPattern)
    local changed = false
    for i = #assets, 1, -1 do
      local asset = assets[i]
      if asset.name:match(assetPattern) then
        table.remove(assets, i)
        changed = true
        assetsChanged = true
      end
    end

    return changed
  end

  ---@return tts__UIAsset[]
  function self.getAssets()
    return assets
  end

  ---@param assetName string
  ---@return boolean
  function self.hasAsset(assetName)
    for _, asset in ipairs(assets) do
      if asset.name == assetName then
        return true
      end
    end
    return false
  end

  return self
end

setmetatable(XmlUi, TableUtil.merge(getmetatable(XmlUiContainer), {
  ---@param object tts__Object
  __call = function(_, object)
    return new(object)
  end
}))

---@param object tts__Object
---@param assetName string
---@return boolean
function XmlUi.hasAsset(object, assetName)
  local assets = object.UI.getCustomAssets()

  for _, asset in ipairs(assets) do
    if asset.name == assetName then
      return true
    end
  end

  return false
end

return XmlUi

end)
__bundle_register("lib.xmlui.XmlUiToggleGroup", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_ToggleGroup : seb_XmlUi_Element

---@class seb_XmlUi_ToggleGroup_Static
---@overload fun(element: tts__UIToggleGroupElement): seb_XmlUi_ToggleGroup
local XmlUiToggleGroup = {}

local Attributes = {}

setmetatable(XmlUiToggleGroup, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIToggleGroupElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_ToggleGroup]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("ToggleGroup", XmlUiToggleGroup, Attributes)

return XmlUiToggleGroup

end)
__bundle_register("lib.xmlui.XmlUiElement", function(require, _LOADED, __bundle_register, __bundle_modules)
local Logger = require("lib.Logger")
local TableUtil = require("lib.TableUtil")
local XmlUiContainer = require("lib.xmlui.XmlUiContainer")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")

---@class seb_XmlUi_Element : seb_XmlUi_Container

---@class seb_XmlUi_Element_Static
---@overload fun(element: tts__UIElement): seb_XmlUi_Element
local XmlUiElement = {}

---@shape seb_XmlUi_Attributes
---@field id nil | string @A unique string used to identify the element from Lua scripting.
---@field active nil | boolean @Specifies whether or not this element and its children are visible and contribute to layout. Modifying this via script will not trigger animations.
---@field rectAlignment nil | tts__UIElement_Alignment @The element's anchor and pivot point, relative to its parent element.
---@field width nil | number @ 	The width of this element in pixels or as a percentage of the width of its parent.
---@field height nil | number @The height of this element in pixels or as a percentage of the height of its parent.
---@field position nil | seb_Vector3
---@field rotation nil | seb_Vector3
---@field scale nil | seb_Vector3
---@field offsetXY nil | seb_Vector2 @An offset to the position of this element, e.g. a value of -32 10 will cause this element to be 10 pixels up and 32 pixels to the left of where it would otherwise be.
---@field alignment nil | tts__UIElement_Alignment @Typographic alignment of the text within its bounding box.
---@field visibility nil | seb_XmlUi_VisibilityTarget | seb_XmlUi_VisibilityTarget[] @A list of visibility targets. An element is always treated as inactive to players not specified here.
---@field showAnimation nil | tts__UIElement_ShowAnimation @Animation to play when show() is called for the element.
---@field showAnimationDelay nil | number @Time in seconds to wait before playing this element's show animation. Useful for staggering the animations of multiple elements.
---@field hideAnimation nil | tts__UIElement_HideAnimation @Animation to play when hide() is called for the element.
---@field hideAnimationDelay nil | number @Time in seconds to wait before playing this element's hide animation. Useful for staggering the animations of multiple elements.
---@field animationDuration nil | number @Time in seconds that show/hide animations take to play.
---@field tooltip nil | string
---@field tooltipBackgroundColor nil | seb_XmlUi_Color
---@field tooltipBackgroundImage nil | tts__UIAssetName
---@field tooltipBorderColor nil | seb_XmlUi_Color
---@field tooltipBorderImage nil | tts__UIAssetName
---@field tooltipOffset nil | integer
---@field tooltipPosition nil | tts__UITooltipPosition
---@field tooltipTextColor nil | seb_XmlUi_Color
---@field onClick nil | seb_XmlUi_EventHandler
---@field onMouseDown nil | seb_XmlUi_EventHandler
---@field onMouseUp nil | seb_XmlUi_EventHandler
---@field onMouseEnter nil | seb_XmlUi_EventHandler
---@field onMouseExit nil | seb_XmlUi_EventHandler
---@field class nil | string | string[] @A list of classes. An element will inherit attributes from any of its classes defined in Defaults.
---@field color nil | seb_XmlUi_Color @Color of the text. Elements that also take an image color use textColor for this.
---@field font nil | tts__UIAssetName
---@field fontStyle nil | tts__UIElement_FontStyle @Typographic emphasis on the text.
---@field fontSize nil | number @Height of the text in pixels.
---@field shadow nil | tts__ColorShape @Defines the shadow color of this element.
---@field shadowDistance nil | seb_Vector2 @Defines the distance of the shadow for this element.
---@field outline nil | seb_XmlUi_Color @Defines the outline color of this element.
---@field outlineSize nil | seb_Vector2 @Defines the size of this elements outline.
---@field resizeTextForBestFit nil | boolean @If set then fontSize is ignored and the text will be sized to be as large as possible while still fitting within its bounding box.
---@field resizeTextMinSize nil | number @When resizeTextForBestFit is set, text will not be sized smaller than this.
---@field resizeTextMaxSize nil | number @When resizeTextForBestFit is set, text will not be sized larger than this.
---@field horizontalOverflow nil | tts__UITextElement_HorizontalOverflow @ Defines what happens when text extends beyond the left or right edges of its bounding box.
---@field verticalOverflow nil | tts__UITextElement_VerticalOverflow @Defines what happens when text extends beyond the top or bottom edges of its bounding box.
---@field allowDragging nil | boolean @Allows the element to be dragged around.
---@field restrictDraggingToParentBounds nil | boolean @If set, prevents the element from being dragged outside the bounding box of its parent.
---@field returnToOriginalPositionWhenReleased nil | boolean @If this is set to true, then the element will return to its original position when it is released.
---@field ignoreLayout nil | boolean @If this element ignores its parent's layout group behavior and treats it as a regular Panel. (This means it would obey regular position/size attributes.)
---@field minWidth nil | number @Elements will not be sized thinner than this.
---@field minHeight nil | number @Elements will not be sized shorter than this.
---@field preferredWidth nil | number @If there is space after minWidths are sized, then element widths are sized according to this.
---@field preferredHeight nil | number @If there is space after minHeights are sized, then element heights are sized according to this.
---@field flexibleWidth nil | number @If there is additional space after preferredWidths are sized, defines how much the element expands to fill the available horizontal space, relative to other elements.
---@field flexibleHeight nil | number @If there is additional space after preferredHeightss are sized, defines how much the element expands to fill the available vertical space, relative to other elements.
---@field zIndex nil | integer

---@type table<string, seb_XmlUi_AttributeType>
local Attributes = {
  -- General
  id = XmlUiFactory.AttributeType.string,
  class = XmlUiFactory.AttributeType.string,
  active = XmlUiFactory.AttributeType.boolean,
  visibility = XmlUiFactory.AttributeType.players,
  -- Text
  text = XmlUiFactory.AttributeType.string,
  alignment = XmlUiFactory.AttributeType.string,
  color = XmlUiFactory.AttributeType.color,
  font = XmlUiFactory.AttributeType.string,
  fontStyle = XmlUiFactory.AttributeType.string,
  fontSize = XmlUiFactory.AttributeType.integer,
  resizeTextForBestFit = XmlUiFactory.AttributeType.boolean,
  resizeTextMinSize = XmlUiFactory.AttributeType.integer,
  resizeTextMaxSize = XmlUiFactory.AttributeType.integer,
  horizontalOverflow = XmlUiFactory.AttributeType.string,
  verticalOverflow = XmlUiFactory.AttributeType.string,
  -- Appearance
  shadow = XmlUiFactory.AttributeType.color,
  shadowDistance = XmlUiFactory.AttributeType.vector2,
  outline = XmlUiFactory.AttributeType.color,
  outlineSize = XmlUiFactory.AttributeType.vector2,
  -- Layout
  ignoreLayout = XmlUiFactory.AttributeType.boolean,
  minWidth = XmlUiFactory.AttributeType.integer,
  minHeight = XmlUiFactory.AttributeType.integer,
  preferredWidth = XmlUiFactory.AttributeType.integer,
  preferredHeight = XmlUiFactory.AttributeType.integer,
  flexibleWidth = XmlUiFactory.AttributeType.integer,
  flexibleHeight = XmlUiFactory.AttributeType.integer,
  -- Position/Size
  position = XmlUiFactory.AttributeType.vector3,
  rotation = XmlUiFactory.AttributeType.vector3,
  scale = XmlUiFactory.AttributeType.vector3,
  rectAlignment = XmlUiFactory.AttributeType.string,
  width = XmlUiFactory.AttributeType.integer,
  height = XmlUiFactory.AttributeType.integer,
  offsetXY = XmlUiFactory.AttributeType.vector2,
  -- Dragging
  allowDragging = XmlUiFactory.AttributeType.boolean,
  restrictDraggingToParentBounds = XmlUiFactory.AttributeType.boolean,
  returnToOriginalPositionWhenReleased = XmlUiFactory.AttributeType.boolean,
  -- Animation
  showAnimation = XmlUiFactory.AttributeType.string,
  hideAnimation = XmlUiFactory.AttributeType.string,
  showAnimationDelay = XmlUiFactory.AttributeType.float,
  hideAnimationDelay = XmlUiFactory.AttributeType.float,
  animationDuration = XmlUiFactory.AttributeType.float,
  -- Tooltip
  tooltip = XmlUiFactory.AttributeType.string,
  tooltipBackgroundColor = XmlUiFactory.AttributeType.color,
  tooltipBackgroundImage = XmlUiFactory.AttributeType.string,
  tooltipBorderColor = XmlUiFactory.AttributeType.color,
  tooltipBorderImage = XmlUiFactory.AttributeType.string,
  tooltipOffset = XmlUiFactory.AttributeType.integer,
  tooltipPosition = XmlUiFactory.AttributeType.string,
  tooltipTextColor = XmlUiFactory.AttributeType.color,
  -- Event
  onClick = XmlUiFactory.AttributeType.handler,
  onMouseEnter = XmlUiFactory.AttributeType.handler,
  onMouseExit = XmlUiFactory.AttributeType.handler,
  onMouseDown = XmlUiFactory.AttributeType.handler,
  onMouseUp = XmlUiFactory.AttributeType.handler,
  -- Custom
  zIndex = XmlUiFactory.AttributeType.integer,
}

setmetatable(XmlUiElement, TableUtil.merge(getmetatable(XmlUiContainer), {
  ---@param element tts__UIElement
  __call = function(_, element)
    local self = --[[---@type seb_XmlUi_Element]] XmlUiContainer()
    local boundElement = element
    ---@type nil | seb_XmlUi
    local boundUi

    local children = self._wrapChildren( --[[---@type tts__UIElement[] ]] element.children)

    ---@param childElements seb_XmlUi_Element[]
    ---@param elementId string
    local function findElementById(childElements, elementId)
      for _, element in pairs(childElements) do
        if element.getId() == elementId then
          return element
        end
        local inChild = findElementById(element.getChildren(), elementId)
        if inChild then
          return inChild
        end
      end
    end

    ---@param name string
    ---@return nil | string | number | boolean
    local function getAttribute(name)
      if boundElement.attributes then
        return ( --[[---@type table<string, nil | string | number | boolean>]] boundElement.attributes)[name]
      end
      return nil
    end

    ---@param handler fun(ui: seb_XmlUi, id: tts__UIElement_Id): void
    local function onBoundId(handler)
      local id = self.getId()
      if boundUi and id then
        handler( --[[---@not nil]] boundUi, --[[---@not nil]] id)
      else
        Logger.debug("Not bound")
      end
    end

    ---@param name string
    ---@param value tts__UIAttributeValue
    function self.setAttribute(name, value)
      if not boundElement.attributes then
        ( --[[---@type table<string, any>]] boundElement).attributes = {}
      end
      ( --[[---@type table<string, any>]] boundElement.attributes)[name] = value

      onBoundId(function(ui, id)
        ui.setAttribute(id, name, value)
      end)
    end

    ---@param name string
    ----@return number | string | boolean
    function self.getAttribute(name)
      if boundElement.attributes then
        local attributes = --[[---@type table<string, tts__UIAttributeValue>]] boundElement.attributes
        return attributes[name]
      end
    end

    ---@return nil | string
    function self.getId()
      return --[[---@type nil | string]] getAttribute("id")
    end

    ---@param ui seb_XmlUi
    function self.bindUi(ui)
      boundUi = ui
    end

    ---@param uiElement seb_XmlUi_Element
    function self.addChild(uiElement)
      table.insert(children, uiElement)
    end

    ---@param elementId tts__UIElement_Id
    ---@return nil | seb_XmlUi_Element
    function self.findElement(elementId)
      return findElementById(children, elementId)
    end

    ---@return seb_XmlUi_Element[]
    function self.getChildren()
      return children
    end

    ---@param child number
    ---@return seb_XmlUi_Element
    function self.getChild(child)
      return children[child]
    end

    function self.clearElements()
      children = {}
    end

    ---@return tts__UIElement
    function self.getXmlElement()
      -- the type cast is obviously bogus, but I didn't find another clear way to get rid of the wrong type error
      local unwrappedElement = --[[---@type tts__UILayoutElement]] boundElement
      unwrappedElement.children = TableUtil.map(children, function(c)
        return c.getXmlElement()
      end)
      return unwrappedElement
    end

    function self.show()
      onBoundId(function(ui, id)
        ui.show(id)
      end)
    end

    function self.hide()
      onBoundId(function(ui, id)
        ui.hide(id)
      end)
    end

    ---@return integer
    function self.getZIndex()
      local attribute = self.getAttribute("zIndex")
      if not attribute then
        return 0
      end
      return --[[---@not nil]] tonumber( --[[---@type string]] attribute)
    end

    ---@param value number
    function self.setWidth(value)
      self.setAttribute("width", value)
    end

    ---@param value number
    function self.setHeight(value)
      self.setAttribute("height", value)
    end

    ---@param value string
    function self.setTooltip(value)
      self.setAttribute("tooltip", value)
    end

    ---@param value seb_XmlUi_Color
    function self.setTooltipBackgroundColor(value)
      self.setAttribute("tooltipBackgroundColor", XmlUiFactory.Converter.toColor(value))
    end

    ---@param value seb_XmlUi_Color
    function self.setTooltipBorderColor(value)
      self.setAttribute("tooltipBorderColor", XmlUiFactory.Converter.toColor(value))
    end

    ---@param value seb_XmlUi_Color
    function self.setTooltipTextColor(value)
      self.setAttribute("tooltipTextColor", XmlUiFactory.Converter.toColor(value))
    end

    ---@return tts__UIElement_Tag
    function self.getType()
      return boundElement.tag
    end

    return self
  end
}))

XmlUiFactory.register(nil, XmlUiElement, Attributes)

return XmlUiElement

end)
__bundle_register("lib.xmlui.XmlUiFactory", function(require, _LOADED, __bundle_register, __bundle_modules)
local Logger = require("lib.Logger")
local Math = require("lib.Math")
local TableUtil = require("lib.TableUtil")

local XmlUiFactory = {}

---@alias seb_XmlUi_FactoryMethod fun(element: tts__UIElement): seb_XmlUi_Element

---@shape seb_XmlUi_Factory
---@field Attributes table<string, seb_XmlUi_AttributeType>
---@field Method seb_XmlUi_FactoryMethod

---@type table<string, seb_XmlUi_Factory>
local ElementFactory = {}
local DefaultFactoryName = "__default__"

---@alias seb_XmlUi_AttributeType 'boolean' | 'string' | 'integer' | 'float' | 'floats' | 'handler' | 'color' | 'colorBlock' | 'padding' | 'players' | 'vector2' | 'vector3' | 'vector4'

XmlUiFactory.AttributeType = {
    boolean = "boolean",
    string = "string",
    integer = "integer",
    float = "float",
    floats = "floats",
    handler = "handler",
    color = "color",
    colorBlock = "colorBlock",
    padding = "padding",
    players = "players",
    vector2 = "vector2",
    vector3 = "vector3",
    vector4 = "vector4",
}

---@overload fun(value: tts__UIAttributeValue, separator: string): string
---@param value tts__UIAttributeValue
---@param separator string
---@param multiple number
---@return string
local function toConcatenatedString(value, separator, multiple)
    multiple = multiple or 1

    local values = --[[---@type tts__UIAttributeValue]] {}
    if type(value) ~= "table" then
        for _ = 1, multiple do
            table.insert(values, value)
        end
    else
        values = value
    end

    return table.concat( --[[---@type string[] ]] values, separator)
end

---@return nil | string
local function toList(value)
    return toConcatenatedString(value, " ")
end

---@param value seb_XmlUi_Color
---@return string
local function toColor(value)
    if type(value) == "string" then
        return --[[---@type string]] value
    end

    ---@type tts__NumColorShape
    local numColor
    if ( --[[---@type tts__CharColorShape]] value).r ~= nil then
        local charColor = --[[---@type tts__CharColorShape]] value
        numColor = { charColor.r, charColor.g, charColor.b, charColor.a }
    else
        numColor = --[[---@type tts__NumColorShape]] value
    end

    for i, v in ipairs(numColor) do
        if v > 1 then
            numColor[i] = Math.round(v / 255, 2)
        end
    end

    if numColor[4] ~= nil then
        return string.format("rgba(%s,%s,%s,%s)", numColor[1], numColor[2], numColor[3], numColor[4])
    else
        return string.format("rgb(%s,%s,%s)", numColor[1], numColor[2], numColor[3])
    end
end

---@param value seb_XmlUi_ColorBlock
---@return string
local function toColorBlock(value)
    return table.concat(TableUtil.map(value, toColor), "|")
end

---@param value seb_XmlUi_Padding
---@return string
local function toPadding(value)
    if type(value) == "number" then
        return toList({ value, value, value, value })
    end

    if value.l ~= nil then
        local charPadding = --[[---@type seb_XmlUi_Padding_Char]] value
        return toList({ charPadding.l, charPadding.r, charPadding.t, charPadding.b })
    end

    if value.h ~= nil then
        local charPadding = --[[---@type seb_XmlUi_Padding_AxisChar]] value
        return toList({ charPadding.h, charPadding.h, charPadding.v, charPadding.v })
    end

    return toList(value)
end

---@param value nil | seb_XmlUi_EventHandler
---@return string
local function toHandlerFunction(value)
    if type(value) == "table" then
        local asTable = --[[---@type seb_XmlUi_ObjectEventHandler]] value
        return asTable[1].getGUID() .. "/" .. asTable[2]
    end
    return --[[---@type string]] value
end

---@return string
local function toPlayerColors(value)
    return toConcatenatedString(value, "|")
end

---@param value tts__UIAttributeValue
---@return tts__UIAttributeValue
local function identity(value)
    return value
end

XmlUiFactory.Converter = {
    toColor = toColor,
}

---@type table<seb_XmlUi_AttributeType, fun(value: tts__UIAttributeValue): tts__UIAttributeValue>
local AttributeTypeMapper = {
    [XmlUiFactory.AttributeType.string] = identity,
    [XmlUiFactory.AttributeType.integer] = identity,
    [XmlUiFactory.AttributeType.float] = identity,
    [XmlUiFactory.AttributeType.floats] = toList,
    [XmlUiFactory.AttributeType.boolean] = identity,
    [XmlUiFactory.AttributeType.handler] = toHandlerFunction,
    [XmlUiFactory.AttributeType.color] = toColor,
    [XmlUiFactory.AttributeType.colorBlock] = toColorBlock,
    [XmlUiFactory.AttributeType.padding] = toPadding,
    [XmlUiFactory.AttributeType.players] = toPlayerColors,
    [XmlUiFactory.AttributeType.vector2] = toList,
    [XmlUiFactory.AttributeType.vector3] = toList,
    [XmlUiFactory.AttributeType.vector4] = toList,
}

---@param tag string
---@param constructor seb_XmlUi_FactoryMethod
---@param attributes table<string, seb_XmlUi_AttributeType>
function XmlUiFactory.register(tag, constructor, attributes)
    local factory = {
        Method = constructor,
        Attributes = attributes,
    }
    if tag then
        ElementFactory[tag] = factory
    else
        ElementFactory[DefaultFactoryName] = factory
    end
end

---@param element table
---@param attributes seb_XmlUi_Attributes
---@param name string
---@param mapper fun(value: any): any
local function copyAttribute(element, attributes, name, mapper)
    local value = attributes[name]
    if value ~= nil then
        if mapper then
            value = mapper(value)
        end
        ( --[[---@not nil]] element.attributes)[name] = value
    end
end

---@param element table
---@param attributes seb_XmlUi_Attributes
---@param availableAttributes table<string, seb_XmlUi_AttributeType>
local function copyAttributes(element, attributes, availableAttributes)
    for attribute, attributeType in pairs(availableAttributes) do
        copyAttribute(element, attributes, attribute, AttributeTypeMapper[attributeType])
    end
end

---@param element tts__UIElement
---@return seb_XmlUi_Element
function XmlUiFactory.wrapElement(element)
    local factory = ElementFactory[element.tag]
    if factory then
        return factory.Method(element)
    end

    Logger.verbose("No factory found for element of type %s. Using default one.", element.tag)
    return ElementFactory[DefaultFactoryName].Method(element)
    --uiElement.bindUi(self) -- TODO !!!
end

---@param tag tts__UIElement_Tag
---@param attributes nil | seb_XmlUi_Attributes
---@return seb_XmlUi_Element
function XmlUiFactory.createElement(tag, attributes)
    local theAttributes = attributes or {}
    ---@type tts__UIElement
    local ttsElement = {
        tag = tag,
        attributes = --[[---@type table<string, tts__UIAttributeValue>]] {},
        children = {}
    }
    copyAttributes(ttsElement, theAttributes, ElementFactory[DefaultFactoryName].Attributes)
    copyAttributes(ttsElement, theAttributes, ElementFactory[tag].Attributes)

    if theAttributes.value then
        ttsElement.value = theAttributes.value
    end

    for name, value in pairs(theAttributes) do
        if name ~= "value" and value ~= nil and ttsElement.attributes[name] == nil then
            Logger.warn("Unmapped attribute '%s'!", name)
        end
    end

    return ElementFactory[tag].Method(ttsElement)
end

---@param attributes seb_XmlUi_ButtonAttributes
---@return seb_XmlUi_Button
function XmlUiFactory.createButton(attributes)
    return --[[---@type seb_XmlUi_Button]] XmlUiFactory.createElement("Button", attributes)
end

---@overload fun(): seb_XmlUi_Cell
---@param attributes seb_XmlUi_CellAttributes
---@return seb_XmlUi_Cell
function XmlUiFactory.createCell(attributes)
    return --[[---@type seb_XmlUi_Cell]] XmlUiFactory.createElement("Cell", attributes)
end

---@param attributes seb_XmlUi_DropdownAttributes
---@return seb_XmlUi_Dropdown
function XmlUiFactory.createDropdown(attributes)
    return --[[---@type seb_XmlUi_Dropdown]] XmlUiFactory.createElement("Dropdown", attributes)
end

---@param attributes seb_XmlUi_GridLayoutAttributes
---@return seb_XmlUi_GridLayout
function XmlUiFactory.createGridLayout(attributes)
    return --[[---@type seb_XmlUi_GridLayout]] XmlUiFactory.createElement("GridLayout", attributes)
end

---@param attributes seb_XmlUi_AxisLayoutAttributes
---@return seb_XmlUi_AxisLayout
function XmlUiFactory.createHorizontalLayout(attributes)
    return --[[---@type seb_XmlUi_AxisLayout]] XmlUiFactory.createElement("HorizontalLayout", attributes)
end

---@overload fun(): seb_XmlUi_ScrollView
---@param attributes seb_XmlUi_ScrollViewAttributes
---@return seb_XmlUi_ScrollView
function XmlUiFactory.createHorizontalScrollView(attributes)
    return --[[---@type seb_XmlUi_ScrollView]] XmlUiFactory.createElement("HorizontalScrollView", attributes)
end

---@param attributes seb_XmlUi_ImageAttributes
---@return seb_XmlUi_Image
function XmlUiFactory.createImage(attributes)
    return --[[---@type seb_XmlUi_Image]] XmlUiFactory.createElement("Image", attributes)
end

---@param attributes seb_XmlUi_InputFieldAttributes
---@return seb_XmlUi_InputField
function XmlUiFactory.createInputField(attributes)
    return --[[---@type seb_XmlUi_InputField]] XmlUiFactory.createElement("InputField", attributes)
end

---@param attributes seb_XmlUi_OptionAttributes
---@return seb_XmlUi_Option
function XmlUiFactory.createOption(attributes)
    return --[[---@type seb_XmlUi_Option]] XmlUiFactory.createElement("Option", attributes)
end

---@param attributes seb_XmlUi_PanelAttributes
---@return seb_XmlUi_Panel
function XmlUiFactory.createPanel(attributes)
    return --[[---@type seb_XmlUi_Panel]] XmlUiFactory.createElement("Panel", attributes)
end

---@overload fun(): seb_XmlUi_Row
---@param attributes seb_XmlUi_RowAttributes
---@return seb_XmlUi_Row
function XmlUiFactory.createRow(attributes)
    return --[[---@type seb_XmlUi_Row]] XmlUiFactory.createElement("Row", attributes)
end

---@param attributes seb_XmlUi_TableLayoutAttributes
---@return seb_XmlUi_TableLayout
function XmlUiFactory.createTableLayout(attributes)
    return --[[---@type seb_XmlUi_TableLayout]] XmlUiFactory.createElement("TableLayout", attributes)
end

---@param attributes seb_XmlUi_TextAttributes
---@return seb_XmlUi_Text
function XmlUiFactory.createText(attributes)
    return --[[---@type seb_XmlUi_Text]] XmlUiFactory.createElement("Text", attributes)
end

---@param attributes seb_XmlUi_ToggleAttributes
---@return seb_XmlUi_Toggle
function XmlUiFactory.createToggle(attributes)
    return --[[---@type seb_XmlUi_Toggle]] XmlUiFactory.createElement("Toggle", attributes)
end

---@param attributes seb_XmlUi_AxisLayoutAttributes
---@return seb_XmlUi_AxisLayout
function XmlUiFactory.createVerticalLayout(attributes)
    return --[[---@type seb_XmlUi_AxisLayout]] XmlUiFactory.createElement("VerticalLayout", attributes)
end

---@overload fun(): seb_XmlUi_ScrollView
---@param attributes seb_XmlUi_ScrollViewAttributes
---@return seb_XmlUi_ScrollView
function XmlUiFactory.createVerticalScrollView(attributes)
    return --[[---@type seb_XmlUi_ScrollView]] XmlUiFactory.createElement("VerticalScrollView", attributes)
end

return XmlUiFactory

end)
__bundle_register("lib.TableUtil", function(require, _LOADED, __bundle_register, __bundle_modules)
local GeTableUtils = require("ge_tts.TableUtils")
local StringUtil = require("lib.StringUtil")

local TableUtil = {}

---@return number
function TableUtil.length(tab)
  local len = 0
  for _, _ in TableUtil.pairs(tab) do
    len = len + 1
  end
  return len
end

--- Variant of pairs that also works for nil values.
---@generic K, V
---@param tab nil | table<K, V>
---@return fun(tab: table<K, V>):K, V
function TableUtil.pairs(tab)
  if tab then
    return pairs(--[[---@not nil]]tab)
  end
  return pairs(--[[---@type table<K,V>]]{})
end

--- Variant of ipairs that also works for nil values.
---@generic V
---@param tab nil | V[]
---@return fun(tab: V[]): number, V
function TableUtil.ipairs(tab)
  if tab then
    return ipairs(--[[---@not nil]]tab)
  end
  return ipairs(--[[---@type V[] ]]{})
end

---@generic K, V
---@param tab table<K, V>
---@return K[]
function TableUtil.keys(tab)
  local keys = {}
  for key, _ in TableUtil.pairs(tab) do
    table.insert(keys, key)
  end
  return keys
end

---@generic K, V
---@param tab nil | table<K, V>
---@return V[]
function TableUtil.values(tab)
  local values = {}

  for _, value in TableUtil.pairs(tab) do
    table.insert(values, value)
  end

  return values
end

---@generic K, V
---@param table table<K, V>
---@param key K
---@param default V
---@return V
function TableUtil.getOrElse(table, key, default)
  local value = table[key]
  if not value then
    value = default
    table[key] = value
  end

  return table[key]
end

--- Checks whether a table is empty. A nil value is also considered an empty table.
---@param tab nil | table
---@return boolean
function TableUtil.isEmpty(tab)
  return not tab or not next(--[[---@not nil]]tab)
end

--- Checks whether a table is not empty. A nil value is always considered an empty table.
---@param tab nil | table
---@return boolean
function TableUtil.isNotEmpty(tab)
  return not TableUtil.isEmpty(tab)
end

---@param a table
---@param b table
---@return boolean
function TableUtil.areEqual(a, b)
  if TableUtil.length(a) ~= TableUtil.length(b) then
    return false
  end

  for key, value in pairs(a) do
    if type(value) == "table" then
      if not TableUtil.areEqual(value, b[key]) then
        return false
      end
    else
      if b[key] == nil or value ~= b[key] then
        return false
      end
    end
  end

  return true
end

--- Returns `true`, if any of the elements of the table satisfies the condition `func`.
---@overload fun<V>(tab: V[], func: fun(value: V): boolean): boolean
---@overload fun<K, V>(tab: table<K,V>, func: fun(value: V, key: K): boolean): boolean
function TableUtil.any(tab, func)
  for key, value in pairs(tab) do
    if func(value, key) then
      return true
    end
  end

  return false
end

--- Returns `true`, if all of the elements of the table satisfies the condition `func`.
---@overload fun<V>(tab: V[], func: fun(value: V): boolean): boolean
---@overload fun<K, V>(tab: table<K,V>, func: fun(value: V, key: K): boolean): boolean
function TableUtil.all(tab, func)
  for key, value in pairs(tab) do
    if not func(value, key) then
      return false
    end
  end

  return true
end

--- Returns `true`, if none of the elements of the table satisfies the condition `func`.
---@overload fun<V>(tab: V[], func: fun(value: V): boolean): boolean
---@overload fun<K, V>(tab: table<K,V>, func: fun(value: V, key: K): boolean): boolean
function TableUtil.none(tab, func)
  return not TableUtil.any(tab, func)
end

---@overload fun<V>(tab: V[], value: V): boolean
---@overload fun<V>(tab: V[], value: V, comparator: fun(a: V, b: V): boolean): boolean
---@overload fun<K, V>(tab: table<K, V>, value: V): boolean
---@overload fun<K, V>(tab: table<K, V>, value: V, comparator: fun(a: V, b: V): boolean): boolean
function TableUtil.contains(tab, value, comparator)
  if not tab then
    return false
  end

  comparator = comparator or function(a, b) return a == b end
  for _, v in pairs(tab) do
    if comparator(v, value) then
      return true
    end
  end
  return false
end

---@generic K, V
---@param tab table<K,V>
---@param key K
---@return boolean
function TableUtil.containsKey(tab, key)
  return tab[key] ~= nil
end

---@generic V
---@param tab V[]
function TableUtil.shuffle(tab)
  for i = #tab, 2, -1 do
    local j = math.random(1, i)
    tab[i], tab[j] = tab[j], tab[i]
  end
end

---@generic V
---@param tab V[]
---@return V
function TableUtil.getRandom(tab)
  return tab[math.random(TableUtil.length(tab))]
end

---@generic K, V
---@param tab table<K, V> | V[]
---@param value V
---@return nil | K
function TableUtil.find(tab, value)
  return GeTableUtils.find(tab, value)
end

---@overload fun<V, MappedV>(tab: V[], func: fun(value: V, key: number): MappedV): MappedV[]
---@generic K, V, MappedV
---@param tab table<K, V>
---@param func fun(value: V, key: K): MappedV
---@return table<K, MappedV>
function TableUtil.map(tab, func)
  return GeTableUtils.map(tab, func)
end

---@overload fun<R, K, V: R>(tab: table<K, V>, func: fun(memo: R, value: V, key: K): R): nil | R
---@generic K, V, R
---@param tab table<K, V>
---@param initial R
---@param func fun(memo: R, value: V, key: K): R
---@return R
function TableUtil.reduce(tab, initial, func)
  return GeTableUtils.reduce(tab, initial, func)
end

---@overload fun(finish: integer): integer[]
---@param start integer
---@param finish integer
---@return integer[]
function TableUtil.range(start, finish)
  if not finish then
    finish = start
    start = 1
  end

  local range = {}
  for i = start, finish do
    table.insert(range, i)
  end

  return range
end

---@overload fun<V>(arr: std__Packed<V>, start: number): std__Packed<V>
---@overload fun<V>(arr: V[], start: number): V[]
---@generic V
---@param arr V[]
---@param start number
---@param finish number
---@return V[]
function TableUtil.slice(arr, start, finish)
  return GeTableUtils.range(arr, start, finish)
end

---@generic V
---@param arr V[]
---@param shift integer
---@return V[]
function TableUtil.shift(arr, shift)
  local shifted = --[[---@type V[] ]] {}
  local length = #arr

  for i = 1, length do
    local shiftedPosition = (i + shift) % length
    if shiftedPosition == 0 then
      shiftedPosition = length
    end
    shifted[i] = arr[shiftedPosition]
  end

  return shifted
end

---@overload fun<V>(arr: V[], func: fun(value: V, index: number): boolean): V[]
---@generic K, V
---@param tab table<K, V>
---@param func fun(value: V, key: K): any
---@return table<K, V>
function TableUtil.filter(tab, func)
  return GeTableUtils.select(tab, func)
end

---@overload fun<T>(...: T): T
---@vararg table
---@return table
function TableUtil.merge(...)
  return GeTableUtils.merge(...)
end

-- k: [ 1, 2, 3]
-- k:

---@generic K, V
---@param a table<K, V>
---@param b table<K, V>
function TableUtil.combine(a, b)
  for k, v in pairs(b) do
    if not a[k] then
      a[k] = v
    else
      if type(v) == "table" then
        if GeTableUtils.isArray(v) then
        else
          TableUtil.combine(a[k], v)
        end
      end
    end
  end
end

---@generic V
---@param first V[]
---@param second V[]
---@return V[]
function TableUtil.append(first, second)
  local result = {}

  for _, v in ipairs(first) do
    table.insert(result, v)
  end

  for _, v in ipairs(second) do
    table.insert(result, v)
  end

  return result
end

---@overload fun<T>(tab: T): T
---@generic T
---@param tab T
---@param recursive boolean @Default false
---@return T
function TableUtil.copy(tab, recursive)
  return GeTableUtils.copy(tab, recursive)
end

---@overload fun<T>(tab: T): T
---@generic T
---@param tab T
---@return T
function TableUtil.deepCopy(tab)
  return GeTableUtils.copy(tab, true)
end

---@generic T
---@param tab T
---@return nil | T
function TableUtil.emptyToNil(tab)
  if TableUtil.isEmpty(tab) then
    return nil
  end
  return tab
end

---@generic K, V
---@param tab table<K,V>
---@param key K
---@return V
function TableUtil.removeKey(tab, key)
  local element = tab[key]
  tab[key] = nil
  return element
end

---@generic V
---@param tab V[]
---@param value V
---@return nil | V
function TableUtil.removeValue(tab, value)
  local index = -1
  for i, v in ipairs(tab) do
    if v == value then
      index = i
      break
    end
  end
  if index > 0 then
    return table.remove(tab, index)
  end
  return nil
end

---@generic V
---@param tab V[]
---@param matcher fun(element: V): boolean
function TableUtil.removeElements(tab, matcher)
  for i = #tab, 1, -1 do
    if matcher(tab[i]) then
      table.remove(tab, i)
    end
  end
end

---@generic T
---@param tab T[]
---@param attributeName string
---@return T[]
function TableUtil.sortByAttribute(tab, attributeName)
  return table.sort(tab, function(l, r)
    return l[attributeName] < r[attributeName]
  end)
end

---@generic K
---@param list K[]
---@return set<K>
function TableUtil.listToSet(list)
  ---@type set<K>
  local set = {}
  for _, value in ipairs(list) do
    set[value] = true
  end

  return set
end

---@generic K
---@param set table<K,boolean>
---@return K[]
function TableUtil.setToList(set)
  ---@type K[]
  local list = {}
  for entry, value in pairs(set) do
    if value then
      table.insert(list, entry)
    end
  end

  return list
end

local TYPE_STRINGIFIERS = {
  ['nil'] = function(_) return 'nil' end,
  boolean = function(v) return tostring(v) end,
  number = function(v) return tostring(v) end,
  string = function(v) return "'" .. v .. "'" end,
  userdata = function(_) return 'userdata' end,
  ['function'] = function(_) return 'function' end,
  thread = function(_) return 'thread' end,
  table = function(v) return tostring(v) end,
}

--- Taken from ge_tts.TableUtils with changed signature.
---@overload fun(tab: table): string
---@overload fun(tab: table, exclude: string[]): string
---@param tab table
---@param exclude string[]
---@param depth number
---@return string
function TableUtil.dump(tab, exclude, depth)
  exclude = exclude or {}
  depth = depth or 1

  local isVector = TableUtil.length(tab) == 3 and tab.x ~= nil and tab.y ~= nil and tab.z ~= nil

  local indentation = string.rep('  ', depth)
  local str = '{'

  ---@type table<number, nil | boolean>
  local ordered_keys = {}

  for i, v in ipairs(--[[---@type any[] ]] tab) do
    ordered_keys[i] = true
    str = str .. '\n' .. indentation .. '[' .. i .. '] = '

    if type(v) == 'table' then
      str = str .. TableUtil.dump(v, exclude, depth + 1) .. ','
    else
      str = str .. TYPE_STRINGIFIERS[type(v)](v) .. ','
    end
  end

  for k, v in pairs(tab) do
    if not ordered_keys[--[[---@type number]] k] and not TableUtil.containsKey(exclude, k) then
      local keyEntry
      if type(k) == "string" and StringUtil.isIdentifier(k) then
        keyEntry = k
      else
        keyEntry = '[' .. TYPE_STRINGIFIERS[type(k)](k) .. ']'
      end

      if isVector then
        str = str .. ' '
      else
        str = str .. '\n' .. indentation
      end
      str = str .. keyEntry .. ' = '

      if type(v) == 'table' then
        str = str .. TableUtil.dump(v, exclude, depth + 1) .. ','
      else
        str = str .. TYPE_STRINGIFIERS[type(v)](v) .. ','
      end
    end
  end

  if isVector then
    str = str .. ' }'
  else
    str = str .. '\n' .. string.rep('  ', depth - 1) .. '}'
  end

  return str
end

return TableUtil

end)
__bundle_register("lib.StringUtil", function(require, _LOADED, __bundle_register, __bundle_modules)
local Base64 = require("ge_tts.Base64")

local StringUtil = {}

---@type set<string>
local LuaKeywords = {
  ["and"] = true,
  ["break"] = true,
  ["do"] = true,
  ["else"] = true,
  ["elseif"] = true,
  ["end"] = true,
  ["false"] = true,
  ["for"] = true,
  ["function"] = true,
  ["if"] = true,
  ["in"] = true,
  ["local"] = true,
  ["nil"] = true,
  ["not"] = true,
  ["or"] = true,
  ["repeat"] = true,
  ["return"] = true,
  ["then"] = true,
  ["true"] = true,
  ["until"] = true,
  ["while"] = true,
}

---@param value nil | string
---@return boolean
function StringUtil.isEmpty(value)
  return value == nil or value == ""
end

---@param value nil | string
---@return boolean
function StringUtil.isNotEmpty(value)
  return not StringUtil.isEmpty(value)
end

---@overload fun(input: string, pattern: string): string
---@param input string
---@param pattern string
---@param replacement string
---@return string
function StringUtil.replace(input, pattern, replacement)
  local r, _ = input:gsub(pattern, replacement or "")
  return r
end

---@overload fun(text: string, separator: string): string[]
---@param text nil | string
---@param separators string[]
---@return string[]
function StringUtil.split(text, separators)
  if not text then
    return {}
  end

  if type(separators) == "string" then
    separators = { --[[---@type string]] separators }
  end

  local parts = {}
  local separatorExpression = "[^" .. table.concat(separators, "") .. "]+"
  for part in string.gmatch(text, separatorExpression) do
    table.insert(parts, part)
  end
  return parts
end

---@param input string
---@param count integer
---@param padValue string
function StringUtil.lpad(input, count, padValue)
  for _ = input:len(), count - 1 do
    input = padValue .. input
  end
  return input
end

--- Replaces whitespace at the start and end of the string.
---@param text string
---@return string
function StringUtil.strip(text)
  return StringUtil.replace(StringUtil.replace(text, "^%s+"), "%s+$")
end

---@param text string
---@return string
function StringUtil.capitalize(text)
  local first = text:sub(1, 1):upper()
  return first .. text:sub(2)
end

---@param text string
---@return string
function StringUtil.capitalizeWords(text)
  local words = StringUtil.split(text, " ")
  for i = 1, #words do
    words[i] = StringUtil.capitalize(words[i])
  end
  return table.concat(words, " ")
end

---@param text string
---@return string
function StringUtil.escapePattern(text)
  local escaped, _ = text:gsub("([-+()%[%]])", "%%%1")
  return escaped
end

---@param text string
---@return number[]
function StringUtil.bytes(text)
  local bytes = --[[---@type number[] ]] {}

  for i = 1, #text do
    table.insert(bytes, text:byte(i))
  end

  return bytes
end

function StringUtil.chars(bytes)
  local text = ""

  for _, byte in pairs(bytes) do
    text = text .. string.char(byte)
  end

  return text
end

---@param text any
---@return boolean
function StringUtil.isGuid(text)
  return type(text) == "string"
      and text:find("^[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]$") ~= nil
end

---@param text string
---@return boolean
function StringUtil.isBase64(text)
  return text:find("^[a-zA-Z0-9+/]+=?=?$") ~= nil
end

---@param text string
---@return boolean
function StringUtil.isKeyword(text)
  return LuaKeywords[text]
end

---@param text string
---@return boolean
function StringUtil.isIdentifier(text)
  return not StringUtil.isKeyword(text) and text:find("^[_a-zA-Z][_a-zA-Z0-9]*$") ~= nil
end

---@param value string
---@return string
function StringUtil.encodeBase64(value)
  return Base64.encode(StringUtil.bytes(value))
end

---@param value string
---@return string
function StringUtil.decodeBase64(value)
  return StringUtil.chars(Base64.decode(value))
end

---@param value string
---@param others string[]
---@param maxDistance number
---@return nil | string
function StringUtil.findNearest(value, others, maxDistance)
  local minDistance, otherValue

  for _, other in ipairs(others) do
    local distance = StringUtil.distance(value, other)
    if not minDistance or minDistance > distance then
      minDistance = distance
      otherValue = other
    end
  end

  if minDistance and minDistance > maxDistance then
    return nil
  end
  return otherValue
end

---@param first string
---@param second string
---@return number
function StringUtil.distance(first, second)
  local firstLength, secondLength = #first, #second

  if firstLength == 0 then
    return secondLength
  end
  if secondLength == 0 then
    return firstLength
  end
  if first == second then
    return 0
  end

  local firstBytes = StringUtil.bytes(first)
  local secondBytes = StringUtil.bytes(second)

  local matrix = --[[---@type number[][] ]] {}
  for i = 0, firstLength do
    matrix[i] = { [0] = i }
  end
  for j = 0, secondLength do
    matrix[0][j] = j
  end

  for i = 1, firstLength do
    for j = 1, secondLength do
      if firstBytes[i] == secondBytes[j] then
        matrix[i][j] = matrix[i - 1][j - 1]
      else
        matrix[i][j] = math.min(matrix[i - 1][j] + 1,
          matrix[i][j - 1] + 1,
          matrix[i - 1][j - 1] + 1)
      end
    end
  end

  return matrix[firstLength][secondLength]
end

return StringUtil

end)
__bundle_register("ge_tts.Base64", function(require, _LOADED, __bundle_register, __bundle_modules)
require("ge_tts.License")

-- Base64 implementation originally based on https://github.com/iskolbin/lbase64 (public domain),
-- but modified for simplicity, TTS and to work with number[] buffers, rather than strings.

local TableUtils = require("ge_tts.TableUtils")

---@class ge_tts__Base64
local Base64 = {}

local extract = bit32.extract

local PAD_KEY = 64

---@overload fun(char62: string, char63: string): table<number, number>
---@overload fun(char62: string): table<number, number>
---@overload fun(): table<number, number>
---@param char62 string
---@param char63 string
---@param charPad string
---@return table<number, number>
function Base64.encodingMap(char62, char63, charPad)
    ---@type table<number, number>
    local encodingTable = {}

    for b64code, char in pairs({
        [0] = 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
        'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y',
        'Z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2',
        '3', '4', '5', '6', '7', '8', '9', char62 or '+', char63 or '/', charPad or '='
    }) do
        encodingTable[b64code] = char:byte()
    end

    return encodingTable
end

---@overload fun(char62: string, char63: string): table<number, number>
---@overload fun(char62: string): table<number, number>
---@overload fun(): table<number, number>
---@param char62 string
---@param char63 string
---@param charPad string
---@return table<number, number>
function Base64.decodingMap(char62, char63, charPad)
    return TableUtils.invert(Base64.encodingMap(char62, char63, charPad))
end

local DEFAULT_ENCODING_MAP = Base64.encodingMap()
local DEFAULT_DECODING_MAP = Base64.decodingMap()

---@overload fun(buffer: number[], pad: boolean): string
---@overload fun(buffer: number[]): string
---@param buffer number[]
---@param pad boolean
---@param map table<number, number>
---@return string
function Base64.encode(buffer, pad, map)
    pad = pad == nil or pad
    map = map or DEFAULT_ENCODING_MAP

    ---@type string[]
    local components = {}
    local index = 1
    local length = #buffer
    local lastComponentSize = length % 3

    for offset = 1, length - lastComponentSize, 3 do
        local a, b, c = --[[---@not nil, nil, nil]] table.unpack(buffer, offset, offset + 2)
        local v = a * 0x10000 + b * 0x100 + c

        components[index] = string.char(map[extract(v, 18, 6)], map[extract(v, 12, 6)], map[extract(v, 6, 6)], map[extract(v, 0, 6)])
        index = index + 1
    end

    if lastComponentSize == 2 then
        local a, b = --[[---@not nil, nil]] table.unpack(buffer, length - 1, length)
        local v = a * 0x10000 + b * 0x100

        components[index] = string.char(map[extract(v, 18, 6)], map[extract(v, 12, 6)], map[extract(v, 6, 6)]) .. (pad and string.char(map[PAD_KEY]) or '')
    elseif lastComponentSize == 1 then
        local v = buffer[length] * 0x10000

        components[index] = string.char(map[extract(v, 18, 6)], map[extract(v, 12, 6)]) .. (pad and string.char(map[PAD_KEY], map[PAD_KEY]) or '')
    end

    return table.concat(components)
end

---@overload fun(b64: string): number[]
---@param b64 string
---@param map table<number, number>
---@return number[]
function Base64.decode(b64, map)
    map = map or DEFAULT_DECODING_MAP

    ---@type number[]
    local buffer = {}
    local offset = 1

    local length = #b64

    if map[--[[---@not nil]] b64:sub(-2, -2):byte()] == PAD_KEY then
        length = length - 2
    elseif map[--[[---@not nil]] b64:sub(-1, -1):byte()] == PAD_KEY then
        length = length - 1
    end

    local lastBlockSize = length % 4
    local fullBlockEnd = length - lastBlockSize

    for i = 1, fullBlockEnd, 4 do
        local a, b, c, d = --[[---@not nil, nil, nil, nil]] b64:byte(i, i + 3)

        local v = map[a] * 0x40000 + map[b] * 0x1000 + map[c] * 0x40 + map[d]

        buffer[offset] = extract(v, 16, 8)
        buffer[offset + 1] = extract(v, 8, 8)
        buffer[offset + 2] = extract(v, 0, 8)

        offset = offset + 3
    end


    if lastBlockSize == 3 then
        local a, b, c = --[[---@not nil, nil, nil]] b64:byte(fullBlockEnd + 1, fullBlockEnd + 3)
        local v = map[a] * 0x40000 + map[b] * 0x1000 + map[c] * 0x40

        buffer[offset] = extract(v, 16, 8)
        buffer[offset + 1] = extract(v, 8, 8)
    elseif lastBlockSize == 2 then
        local a, b = --[[---@not nil, nil]] b64:byte(fullBlockEnd + 1, fullBlockEnd + 2)
        local v = map[a] * 0x40000 + map[b] * 0x1000

        buffer[offset] = extract(v, 16, 8)
    end

    return buffer
end

return Base64

end)
__bundle_register("ge_tts.TableUtils", function(require, _LOADED, __bundle_register, __bundle_modules)
-- Omitted to prevent cyclic require:
-- require('ge.tts/License')

-- This module operates on tables that contain only positive consecutive integer keys starting at 1 (i.e. a plain array), as well as tables which contain no
-- array component. Behavior is undefined for tables that contain a key for [1] as well as non-consecutive integer or non-integer keys.

---@generic T
---@param length number
---@return fun(arr: std__Packed<T>, i: number): nil | (number, T)
local function fixedLengthIterator(length)
    ---@type fun(arr: std__Packed<T>, i: number): nil | (number, T)
    return function(arr, i)
        i = i + 1
        if i <= length then
            return i, arr[i]
        end
    end
end

---@overload fun<V, A : std__Packed<V>>(arr: A): (fun(arr: A, i: number): number, V), V[], 0
---@overload fun<V>(arr: V[]): (fun(arr: V[], i: number): number, V), V[], 0
---@generic K, V
---@param tab table<K, V>
---@return (fun(tab: table<K, V>, k: K): nil | (K, V)), table<K, V>, K
local function iterate(tab)
    local fixedLength = (--[[---@type std__Packed<any>]] tab).n

    if type(fixedLength) == 'number' and fixedLength >= 0 then
        return --[[---@type fun(tab: table<K, V>, k: K): nil | (K, V)]] fixedLengthIterator(fixedLength), tab, --[[---@type K]] 0
    elseif tab[--[[---@type K]] 1] ~= nil then
        return --[[---@type (fun(tab: table<K, V>, k: K): nil | (K, V)), table<K, V>, K]] ipairs(--[[---@type V[] ]] tab)
    else
        return pairs(tab)
    end
end

---@class ge_tts__TableUtils
local TableUtils = {}

--- Returns true if TableUtils will interpret the table as an array i.e. if tab[1] ~= nil or
--- type(tab.n) == 'number'.
---
--- If tab is an array, and it's passed to a TableUtils function that iterates over tab calling a callback, the
--- iteration over keys is guaranteed to take place in sequential order (à la ipairs).
---
--- In the case of type(tab.n) == 'number', tab.n will be treated as the length of the array and TableUtils will
--- continue iterating over "holes" (nil values) up to this length.
---@overload fun<V>(tab: V[]): true
---@overload fun<V>(tab: std__Packed<V>): true
---@overload fun<V>(tab: table<boolean, V>): false
---@overload fun<V>(tab: table<string, V>): false
---@overload fun<V>(tab: table<table, V>): false
---@overload fun<V>(tab: table<userdata, V>): false
---@param tab table
---@return boolean
function TableUtils.isArray(tab)
    return tab[1] ~= nil or type((--[[---@type std__Packed<any>]] tab).n) == 'number'
end

--- Returns the length of arr and a boolean indicating whether arr is a std__Packed<V>.
---@generic V
---@param arr V[] | std__Packed<V>
---@return number, boolean
function TableUtils.arrayLength(arr)
    local fixedLength = (--[[---@type std__Packed<V>]] arr).n
    local isFixed = type(fixedLength) == 'number'
    return isFixed and fixedLength or #arr, isFixed
end

---@overload fun<V, MappedV>(tab: V[], func: fun(value: V, key: number): MappedV): MappedV[]
---@generic K, V, MappedV
---@param tab table<K, V>
---@param func fun(value: V, key: K): MappedV
---@return table<K, MappedV>
function TableUtils.map(tab, func)
    ---@type table<K, MappedV>
    local mapped = {}

    for k, v in iterate(tab)  do
        mapped[k] = func(v, k)
    end

    return mapped
end

---@generic K, V
---@param tab table<K, V>
---@return table<V, K>
function TableUtils.invert(tab)
    ---@type table<V, K>
    local inverted = {}

    for k, v in pairs(tab) do
        inverted[v] = k
    end

    return inverted
end

---@generic K, V, RemappedK
---@param tab table<K, V>
---@param func fun(value: V, key: K): RemappedK
---@return table<RemappedK, V>
function TableUtils.remap(tab, func)
    ---@type table<RemappedK, V>
    local remapped = {}

    for k, v in iterate(tab) do
        remapped[func(v, k)] = v
    end

    return remapped
end

---@overload fun<V>(arr: V[], func: fun(value: V, index: number): boolean): V[]
---@generic K, V
---@param tab table<K, V>
---@param func fun(value: V, key: K): boolean
---@return table<K, V>
function TableUtils.select(tab, func)
    ---@type table<K, V>
    local selected = {}

    if TableUtils.isArray(tab) then
        local i = 0

        for k, v in iterate(tab) do
            if func(v, k) then
                i = i + 1
                (--[[---@type V[] ]] selected)[i] = v
            end
        end
    else
        for k, v in pairs(tab) do
            if func(v, k) then
                selected[k] = v
            end
        end
    end

    return selected
end

---@overload fun<V>(arr: V[], func: fun(value: V, index: number): boolean): V[]
---@generic K, V
---@param tab table<K, V>
---@param func fun(value: V, key: K): boolean
---@return table<K, V>
function TableUtils.reject(tab, func)
    return TableUtils.select(tab, function(v, k) return not func(v, k) end)
end

---@overload fun<R, K, V: R>(tab: table<K, V>, func: fun(memo: R, value: V, key: K): R): nil | R
---@generic K, V, R
---@param tab table<K, V>
---@param initial R
---@param func fun(memo: R, value: V, key: K): R
---@return R
function TableUtils.reduce(tab, initial, func)
    local iterator, _, initialK = iterate(tab)

    ---@type R
    local memo

    ---@type fun(memo: R, value: V, key: K): R
    local reducer

    if func then
        memo = initial
        reducer = func
    else
        local control, value = iterator(tab, initialK)

        if control == nil then
            -- Overload may return nil
            return --[[---@type any]] nil
        end

        initialK = --[[---@not nil]] control
        memo = --[[---@type R]] value
        reducer = --[[---@type fun(memo: R, value: V, key: K): R]] initial
    end

    if not func then
        initialK = --[[---@type K]] memo
    end

    for k, v in iterator, tab, initialK do
        memo = reducer(memo, v, k)
    end

    return memo
end

---@generic K, V
---@param tab table<K, V>
---@param value any
---@return nil | K
function TableUtils.find(tab, value)
    for k, v in iterate(tab) do
        if v == value then
            return k
        end
    end

    return nil
end

---@generic K, V
---@param tab table<K, V>
---@param func fun(value: V, key: K): boolean
---@return (nil, nil) | (V, K)
function TableUtils.detect(tab, func)
    for k, v in iterate(tab) do
        if func(v, k) then
            return v, k
        end
    end

    return nil, nil
end

---@overload fun<T>(tab: T): T
---@generic T
---@param tab T
---@param recursive boolean
---@return T
function TableUtils.copy(tab, recursive)
    ---@type table
    local copied = {}

    for k, v in pairs(--[[---@type table]] tab) do
        copied[k] = (recursive and type(v) == 'table' and
            TableUtils.copy(--[[---@type table]] v, true)
        ) or v
    end

    return --[[---@type T]] copied
end

---@overload fun<V>(arr: V[], ...: V[]): void
---@overload fun<V>(arr: std__Packed<V>, ...: V[] | std__Packed<V>): void
---@generic K, V
---@param tab table<K, V>
---@vararg table<K, V>
---@return void
function TableUtils.inject(tab, ...)
    local otherTables = { ... }

    if TableUtils.isArray(tab) then
        local arr = --[[---@type V[] | std__Packed<V>]] tab
        local i, isFixed = TableUtils.arrayLength(arr)

        for _, t in ipairs(otherTables) do
            for _, v in iterate(--[[---@type V[] ]] t) do
                i = i + 1
                arr[i] = v
            end
        end

        if isFixed then
            (--[[---@type std__Packed<V>]] tab).n = i
        end
    else
        for _, t in ipairs(otherTables) do
            for k, v in pairs(t) do
                tab[k] = v
            end
        end
    end
end

---@overload fun<T>(...: T): T
---@vararg table
---@return table
function TableUtils.merge(...)
    local merged = {}
    TableUtils.inject(merged, ...)
    return merged
end

---@overload fun<V>(arrays: std__Packed<V>[]): std__Packed<V>, number
---@generic V
---@param arrays V[][]
---@return V[], number
function TableUtils.flatten(arrays)
    ---@type V[]
    local flattened = {}
    local i = 0

    for _, array in ipairs(arrays) do
        for _, v in iterate(array) do
            i = i + 1
            flattened[i] = v
        end
    end


    if i > 0 and type((--[[---@type std__Packed<V[]>]] arrays[1]).n) == 'number' then
        (--[[---@type std__Packed<V>]] flattened).n = i
    end

    return flattened, i
end

---@generic K, V
---@param tab table<K, V>
---@return K[]
function TableUtils.keys(tab)
    ---@type K[]
    local keys = {}

    for k, _ in pairs(tab) do
        table.insert(keys, k)
    end

    return keys
end

---@overload fun<V>(arr: std__Packed<V>): std__Packed<V>
---@generic K, V
---@param tab table<K, V>
---@return V[], number
function TableUtils.values(tab)
    ---@type V[]
    local values = {}
    local i = 0

    for _, v in iterate(tab) do
        i = i + 1
        values[i] = v
    end

    if type((--[[---@type std__Packed<V>]] tab).n) == 'number' then
        (--[[---@type std__Packed<V>]] values).n = i
    end

    return values, i
end

---@param tab table
---@return number
function TableUtils.count(tab)
    local count = 0

    for _, _ in pairs(tab) do
        count = count + 1
    end

    return count
end

---@overload fun<V>(arr: std__Packed<V>): std__Packed<V>
---@generic V
---@param arr V[]
---@return V[]
function TableUtils.reverse(arr)
    ---@type V[]
    local reversed = {}

    local length, isFixed = TableUtils.arrayLength(arr)
    local j = 1

    for i = length, 1, -1 do
        reversed[j] = arr[i]
        j = j + 1
    end

    if isFixed then
        (--[[---@type std__Packed<V>]] reversed).n = length
    end

    return reversed
end

---@overload fun<V>(arr: std__Packed<V>, start: number): std__Packed<V>
---@overload fun<V>(arr: V[], start: number): V[]
---@generic V
---@param arr V[]
---@param start number
---@param finish number
---@return V[]
function TableUtils.range(arr, start, finish)
    ---@type V[]
    local range = {}

    for i in fixedLengthIterator(finish or TableUtils.arrayLength(arr)), arr, start - 1 do
        range[i - start + 1] = arr[i]
    end

    if type((--[[---@type std__Packed<V>]] arr).n) == 'number' then
        (--[[---@type std__Packed<V>]] range).n = finish - start + 1
    end

    return range
end

---@overload fun<V>(arr: std__Packed<V>): std__Packed<V>
---@generic V
---@param arr V[]
---@return V[], number
function TableUtils.unique(arr)
    ---@type V[]
    local unique = {}
    local i = 0

    for _, value in ipairs(arr) do
        if not TableUtils.find(unique, value) then
            i = i + 1
            unique[i] = value
        end
    end

    return unique, i
end

local TYPE_STRINGIFIERS = {
    ['nil'] = function(_) return 'nil' end,
    boolean = function(v) return tostring(v) end,
    number = function(v) return tostring(v) end,
    string = function(v) return "'" .. v .. "'" end,
    userdata = function(_) return 'userdata' end,
    ['function'] = function(_) return 'function' end,
    thread = function(_) return 'thread' end,
    table = function(v) return tostring(v) end,
}

---@overload fun(tab: table): string
---@overload fun(tab: table, recursive: boolean): string
---@param tab table
---@param recursive boolean
---@param depth number
---@return string
function TableUtils.dump(tab, recursive, depth)
    depth = depth or 1

    local indentation = string.rep('  ', depth)
    local str = '{'

    ---@type table<number, nil | boolean>
    local ordered_keys = {}

    for i, v in ipairs(--[[---@type any[] ]] tab) do
        ordered_keys[i] = true
        str = str .. '\n' .. indentation .. '[' .. i .. '] = '

        if recursive and type(v) == 'table' then
            str = str .. TableUtils.dump(v, true, depth + 1) .. ','
        else
            local a = TYPE_STRINGIFIERS['nil']
            str = str .. TYPE_STRINGIFIERS[type(v)](v) .. ','
        end
    end

    for k, v in pairs(tab) do
        if not ordered_keys[--[[---@type number]] k] then
            str = str .. '\n' .. indentation .. '[' .. TYPE_STRINGIFIERS[type(k)](k) .. '] = '

            if recursive and type(v) == 'table' then
                str = str .. TableUtils.dump(v, true, depth + 1) .. ','
            else
                str = str .. TYPE_STRINGIFIERS[type(v)](v) .. ','
            end
        end
    end

    str = str .. '\n' .. string.rep('  ', depth - 1) .. '}'

    return str
end

return TableUtils

end)
__bundle_register("ge_tts.License", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtils = require("ge_tts.TableUtils")

-- This license applies to ge_tts. Do *not* assume it extends to the mod!
---@type table<string, nil | string>
local licenses = {
    ge_tts = [[Copyright (c) 2019 Benjamin Dobell, Glass Echidna

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]],
}

local License = {}

---@param library string
---@param license string
---@return boolean
function License.add(library, license)
    if licenses[library] then
        return false
    end

    licenses[library] = license
    return true
end

---@param library string
---@return nil | string
function License.get(library)
    return licenses[library]
end

---@return string[]
function License.getLibraries()
    return TableUtils.keys(licenses)
end

return License

end)
__bundle_register("lib.Math", function(require, _LOADED, __bundle_register, __bundle_modules)
local Math = {}

--- Same as Math.roundUp()
---@param value number
---@param decimalPlaces? number @Defaults to 0.
---@return number
function Math.round(value, decimalPlaces)
  return Math.roundUp(value, decimalPlaces)
end

---@param value number
---@param decimalPlaces? number @Defaults to 0.
---@return number
function Math.roundUp(value, decimalPlaces)
  if decimalPlaces and decimalPlaces > 0 then
    local multiple = 10 ^ decimalPlaces
    return math.floor(value * multiple + 0.5) / multiple
  end

  return math.floor(value + 0.5)
end

---@param value number
---@param decimalPlaces? number @Defaults to 0.
---@return number
function Math.roundDown(value, decimalPlaces)
  if decimalPlaces and decimalPlaces > 0 then
    local multiple = 10 ^ decimalPlaces
    return math.ceil(value * multiple + 0.5) / multiple
  end

  return math.ceil(value - 0.5)
end

---@param value number
---@param min number
---@param max number
function Math.clamp(value, min, max)
  if value < min then
    return min
  end

  if value > max then
    return max
  end

  return value
end

---@param tab number[]
---@return number
function Math.sum(tab)
  local total = 0
  for _, v in ipairs(tab) do
    total = total + v
  end

  return total
end

---@param tab number[]
---@return number
function Math.average(tab)
  local total = Math.sum(tab)
  return total / #tab
end

return Math

end)
__bundle_register("lib.Logger", function(require, _LOADED, __bundle_register, __bundle_modules)
local Logger = require("sebaestschjin-tts.Logger")

return Logger

end)
__bundle_register("sebaestschjin-tts.Logger", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtils = require("ge_tts.TableUtils")
local GeLogger = require("ge_tts.Logger")

---@class seb_Logger : ge_tts__Logger

---@class seb_Logger_static
---@overload fun(): seb_Logger
local Logger = {}

Logger.ERROR = GeLogger.ERROR
Logger.WARNING = GeLogger.WARNING
Logger.INFO = GeLogger.INFO
Logger.DEBUG = GeLogger.DEBUG
Logger.VERBOSE = GeLogger.VERBOSE

---@type table<number, string>
local levelPrefixes = {
  [GeLogger.ERROR] = 'ERROR: ',
  [GeLogger.WARNING] = 'WARNING: ',
  [GeLogger.INFO] = 'INFO: ',
  [GeLogger.DEBUG] = 'DEBUG: ',
  [GeLogger.VERBOSE] = 'VERBOSE: ',
}

---@type table<ge_tts__Logger_LogLevel, string>
local levelColors = {
  [GeLogger.ERROR] = 'Red',
  [GeLogger.WARNING] = 'Yellow',
  [GeLogger.INFO] = 'Blue',
}

--- Logger instances registered on other objects.
---@type GUID[]
local objectLoggers = {}

setmetatable(Logger, TableUtils.merge(getmetatable(GeLogger), {
  __call = function()
    local self = GeLogger()

    ---@param message string
        ---@param level ge_tts__Logger_LogLevel
    function self.log(message, level)
      printToAll(levelPrefixes[level] .. message, levelColors[level])
    end

    return self
  end,
  __index = GeLogger,
}))

local logger = Logger()

local function buildMessage(...)
  local args = table.pack(...)
  for i = 1, args.n do
    args[i] = logString(args[i])
  end

  local success, result = pcall(function()
    return string.format(table.unpack(args))
  end)

  if success then
    return result
  end

  return table.unpack(args)
end

---@param functionName string
local function notifyObjectLoggers(functionName, parameter)
  if self == Global then
    for i = #objectLoggers, 1, -1 do
      local objectLogger = objectLoggers[i]
      local obj = getObjectFromGUID(objectLogger)
      if obj then
        (--[[---@not nil]] obj).call(functionName, parameter)
      else
        table.remove(objectLoggers, i)
      end
    end
  end
end

---@param level ge_tts__Logger_LogLevel
function Logger.setLevel(level)
  logger.setFilterLevel(level)
  notifyObjectLoggers("__set_logger_level", level)
end

function Logger.error(...)
  if logger.getFilterLevel() >= GeLogger.ERROR then
    logger.log(buildMessage(...), GeLogger.ERROR)
  end
end

function Logger.warn(...)
  if logger.getFilterLevel() >= GeLogger.WARNING then
    logger.log(buildMessage(...), GeLogger.WARNING)
  end
end

function Logger.info(...)
  if logger.getFilterLevel() >= GeLogger.INFO then
    logger.log(buildMessage(...), GeLogger.INFO)
  end
end

function Logger.debug(...)
  if logger.getFilterLevel() >= GeLogger.DEBUG then
    logger.log(buildMessage(...), GeLogger.DEBUG)
  end
end

function Logger.verbose(...)
  if logger.getFilterLevel() >= GeLogger.VERBOSE then
    logger.log(buildMessage(...), GeLogger.VERBOSE)
  end
end

function Logger.assert(value, ...)
  if not value then
    logger.assert(value, buildMessage(...))
  end
end

if self == Global then
  ---@param guid GUID
  _G.__register_object_logger = function(guid)
    table.insert(objectLoggers, guid)
  end
  _G.__logger_exists = true
else
  if Global.getVar("__logger_exists") then
    Global.call("__register_object_logger", self.getGUID())
  end
  _G.__set_logger_level = function(level)
    Logger.setLevel(level)
  end
end

return Logger

end)
__bundle_register("ge_tts.Logger", function(require, _LOADED, __bundle_register, __bundle_modules)
require("ge_tts.License")

---@class ge_tts__Logger

---@class ge_tts__static_Logger
---@overload fun(): ge_tts__Logger
local Logger = {}

Logger.ERROR = 1
Logger.WARNING = 2
Logger.INFO = 3
Logger.DEBUG = 4
Logger.VERBOSE = 5

---@alias ge_tts__Logger_LogLevel 1 | 2 | 3 | 4 | 5

---@type table<ge_tts__Logger_LogLevel, string>
local levelPrefixes = {
    [Logger.ERROR] = 'ERROR: ',
    [Logger.WARNING] = 'WARNING: ',
    [Logger.INFO] = '',
    [Logger.DEBUG] = '',
    [Logger.VERBOSE] = '',
}

---@type ge_tts__Logger_LogLevel
local defaultLogLevel = Logger.DEBUG

setmetatable(Logger, {
    __call = function()
        local self = --[[---@type ge_tts__Logger]] {}

        ---@type ge_tts__Logger_LogLevel
        local filterLevel = Logger.INFO

        ---@return ge_tts__Logger_LogLevel
        function self.getFilterLevel()
            return filterLevel
        end

        ---@param level ge_tts__Logger_LogLevel | `Logger.ERROR` | `Logger.WARNING` | `Logger.INFO` | `Logger.DEBUG` | `Logger.VERBOSE`
        function self.setFilterLevel(level)
            filterLevel = level
        end

        ---@overload fun(message: string): void
        ---@param message string
        ---@param level ge_tts__Logger_LogLevel | `Logger.ERROR` | `Logger.WARNING` | `Logger.INFO` | `Logger.DEBUG` | `Logger.VERBOSE`
        function self.log(message, level)
            level = level or defaultLogLevel
            if level <= filterLevel then
                print(levelPrefixes[level] .. message)
            end
        end

        ---
        ---If value is false, logs message at level Logger.ERROR and then calls Lua's in-built error(message).
        ---
        ---@param value any
        ---@param message string
        function self.assert(value, message)
            if not value then
                self.log(message, Logger.ERROR)
                error(message, 2)
            end
        end

        return self
    end
})

local defaultLogger = Logger()

---@param logger ge_tts__Logger
function Logger.setDefaultLogger(logger)
    defaultLogger = logger
end

function Logger.getDefaultLogger()
    return defaultLogger
end

---
---When calling log() without specifying a log level, messages will log at the provided log level.
---
---@param level ge_tts__Logger_LogLevel | `Logger.ERROR` | `Logger.WARNING` | `Logger.INFO` | `Logger.DEBUG` | `Logger.VERBOSE`
function Logger.setDefaultLogLevel(level)
    defaultLogLevel = level
end

---
---Returns the default log level.
---
---@return ge_tts__Logger_LogLevel
function Logger.getDefaultLogLevel()
    return defaultLogLevel
end

---
---Logs a message at the specified log level. If level is omitted, the default log level will be used.
---
---@overload fun(message: string): void
---@param message string
---@param level ge_tts__Logger_LogLevel | `Logger.ERROR` | `Logger.WARNING` | `Logger.INFO` | `Logger.DEBUG` | `Logger.VERBOSE`
function Logger.log(message, level)
    level = level or defaultLogLevel
    defaultLogger.log(message, level)
end

---
---If value is false, logs message at level Logger.ERROR using the default logger, and then calls Lua's error(message).
---
---@param value any
---@param message string
function Logger.assert(value, message)
    if not value then
        defaultLogger.log(message, Logger.ERROR)
        error(message, 2)
    end
end

return Logger

end)
__bundle_register("lib.xmlui.XmlUiContainer", function(require, _LOADED, __bundle_register, __bundle_modules)
local Logger = require("lib.Logger")
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")

---@class seb_XmlUi_Container

---@class seb_XmlUi_Container_Static
---@overload fun(): seb_XmlUi_Container
local XmlUiContainer = {}

setmetatable(XmlUiContainer, {
  __call = function(_)
    local self = --[[---@type seb_XmlUi_Container]] {}

    ---@param unwrappedElements nil | tts__UIElement[]
    ---@return seb_XmlUi_Element[]
    function self._wrapChildren(unwrappedElements)
      local elements = --[[---@type seb_XmlUi_Element[] ]] {}
      for _, element in TableUtil.ipairs( --[[---@type tts__UIElement[] ]] unwrappedElements) do
        local uiElement = XmlUiFactory.wrapElement(element)
        table.insert(elements, uiElement)
      end
      return elements
    end

    ---@param _ seb_XmlUi_Element
    function self.addChild(_)
      Logger.error("Not implemented exception!")
    end

    ---@param _ number
    ---@return seb_XmlUi_Element
    function self.getChild(_)
      Logger.error("Not implemented exception!")
      return --[[---@type seb_XmlUi_Element]] nil
    end

    function self.clearElements()
      Logger.error("Not implemented exception!")
    end

    ---@generic E: seb_XmlUi_Element
    ---@param element E
    ---@return E
    local function addToChildren(element)
      self.addChild(element)
      return element
    end

    ---@param attributes seb_XmlUi_ButtonAttributes
    ---@return seb_XmlUi_Button
    function self.addButton(attributes)
      return addToChildren(XmlUiFactory.createButton(attributes))
    end

    ---@param attributes seb_XmlUi_DropdownAttributes
    ---@return seb_XmlUi_Dropdown
    function self.addDropdown(attributes)
      return addToChildren(XmlUiFactory.createDropdown(attributes))
    end

    ---@param attributes seb_XmlUi_GridLayoutAttributes
    ---@return seb_XmlUi_GridLayout
    function self.addGridLayout(attributes)
      return addToChildren(XmlUiFactory.createGridLayout(attributes))
    end

    ---@overload fun(): seb_XmlUi_AxisLayout
    ---@param attributes seb_XmlUi_AxisLayoutAttributes
    ---@return seb_XmlUi_AxisLayout
    function self.addHorizontalLayout(attributes)
      return addToChildren(XmlUiFactory.createHorizontalLayout(attributes))
    end

    ---@param attributes seb_XmlUi_ScrollViewAttributes
    ---@return seb_XmlUi_ScrollView
    function self.addHorizontalScrollView(attributes)
      return addToChildren(XmlUiFactory.createHorizontalScrollView(attributes))
    end

    ---@param attributes seb_XmlUi_ImageAttributes
    ---@return seb_XmlUi_Image
    function self.addImage(attributes)
      return addToChildren(XmlUiFactory.createImage(attributes))
    end

    ---@param attributes seb_XmlUi_InputFieldAttributes
    ---@return seb_XmlUi_InputField
    function self.addInputField(attributes)
      return addToChildren(XmlUiFactory.createInputField(attributes))
    end

    ---@overload fun(): seb_XmlUi_Panel
    ---@param attributes seb_XmlUi_PanelAttributes
    ---@return seb_XmlUi_Panel
    function self.addPanel(attributes)
      return addToChildren(XmlUiFactory.createPanel(attributes))
    end

    ---@param attributes seb_XmlUi_TableLayoutAttributes
    ---@return seb_XmlUi_TableLayout
    function self.addTableLayout(attributes)
      return addToChildren(XmlUiFactory.createTableLayout(attributes))
    end

    ---@overload fun(): seb_XmlUi_Text
    ---@param attributes seb_XmlUi_TextAttributes
    ---@return seb_XmlUi_Text
    function self.addText(attributes)
      return addToChildren(XmlUiFactory.createText(attributes))
    end

    ---@param attributes seb_XmlUi_ToggleAttributes
    ---@return seb_XmlUi_Toggle
    function self.addToggle(attributes)
      return addToChildren(XmlUiFactory.createToggle(attributes))
    end

    ---@overload fun(): seb_XmlUi_AxisLayout
    ---@param attributes seb_XmlUi_AxisLayoutAttributes
    ---@return seb_XmlUi_AxisLayout
    function self.addVerticalLayout(attributes)
      return addToChildren(XmlUiFactory.createVerticalLayout(attributes))
    end

    ---@param attributes seb_XmlUi_ScrollViewAttributes
    ---@return seb_XmlUi_ScrollView
    function self.addVerticalScrollView(attributes)
      return addToChildren(XmlUiFactory.createVerticalScrollView(attributes))
    end

    return self
  end
})

return XmlUiContainer

end)
__bundle_register("lib.xmlui.XmlUiToggleButton", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_ToggleButton : seb_XmlUi_Element

---@class seb_XmlUi_ToggleButton_Static
---@overload fun(element: tts__UIToggleButtonElement): seb_XmlUi_ToggleButton
local XmlUiToggleButton = {}

local Attributes = {}

setmetatable(XmlUiToggleButton, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIToggleButtonElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_ToggleButton]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("ToggleButton", XmlUiToggleButton, Attributes)

return XmlUiToggleButton

end)
__bundle_register("lib.xmlui.XmlUiToggle", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiElement = require("lib.xmlui.XmlUiElement")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")

---@class seb_XmlUi_Toggle : seb_XmlUi_Element

---@class seb_XmlUi_Toggle_Static
---@overload fun(element: tts__UIToggleElement): seb_XmlUi_Toggle
local XmlUiToggle = {}

---@shape seb_XmlUi_ToggleAttributes : seb_XmlUi_Attributes
---@field onValueChanged nil | seb_XmlUi_EventHandler
---@field isOn nil | boolean
---@field [any] nil @All other fields are invalid

local Attributes = {
    isOn = XmlUiFactory.AttributeType.boolean,
    onValueChanged = XmlUiFactory.AttributeType.handler,
}

setmetatable(XmlUiToggle, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIToggleElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Toggle]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Toggle", XmlUiToggle, Attributes)

return XmlUiToggle

end)
__bundle_register("lib.xmlui.XmlUiText", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Text : seb_XmlUi_Element

---@class seb_XmlUi_Text_Static
---@overload fun(element: tts__UITextElement): seb_XmlUi_Text
local XmlUiText = {}

---@shape seb_XmlUi_TextAttributes : seb_XmlUi_Attributes
---@field text nil | string
---@field value nil | string
---@field [any] nil @All other fields are invalid

local Attributes = {}

setmetatable(XmlUiText, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UITextElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Text]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Text", XmlUiText, Attributes)

return XmlUiText

end)
__bundle_register("lib.xmlui.XmlUiTableLayout", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_TableLayout : seb_XmlUi_Element

---@class seb_XmlUi_TableLayout_Static
---@overload fun(element: tts__UITableLayoutElement): seb_XmlUi_TableLayout
local XmlUiTableLayout = {}

---@shape seb_XmlUi_TableLayoutAttributes : seb_XmlUi_Attributes
---@field columnWidths nil | number[]
---@field padding nil | seb_XmlUi_Padding
---@field rowBackgroundColor nil | seb_XmlUi_Color | 'clear'
---@field rowBackgroundImage nil | tts__UIAssetName
---@field cellBackgroundColor nil | seb_XmlUi_Color | 'clear'
---@field cellBackgroundImage nil | tts__UIAssetName
---@field cellPadding nil | seb_XmlUi_Padding
---@field autoCalculateHeight nil | boolean
---@field [any] nil @All other fields are invalid

local Attributes = {
    autoCalculateHeight = XmlUiFactory.AttributeType.boolean,
    cellBackgroundColor = XmlUiFactory.AttributeType.color,
    cellBackgroundImage = XmlUiFactory.AttributeType.string,
    cellPadding = XmlUiFactory.AttributeType.padding,
    columnWidths = XmlUiFactory.AttributeType.floats,
    padding = XmlUiFactory.AttributeType.padding,
    rowBackgroundColor = XmlUiFactory.AttributeType.color,
    rowBackgroundImage = XmlUiFactory.AttributeType.string,
}

setmetatable(XmlUiTableLayout, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UITableLayoutElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_TableLayout]] XmlUiElement(element)

        ---@overload fun(): seb_XmlUi_Row
        ---@param attributes seb_XmlUi_RowAttributes
        ---@return seb_XmlUi_Row
        function self.addRow(attributes)
            local row = XmlUiFactory.createRow(attributes)
            self.addChild(row)
            return row
        end

        return self
    end
}))

XmlUiFactory.register("TableLayout", XmlUiTableLayout, Attributes)

return XmlUiTableLayout

end)
__bundle_register("lib.xmlui.XmlUiSlider", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Slider : seb_XmlUi_Element

---@class seb_XmlUi_Slider_Static
---@overload fun(element: tts__UISliderElement): seb_XmlUi_Slider
local XmlUiSlider = {}

local Attributes = {}

setmetatable(XmlUiSlider, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UISliderElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Slider]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Slider", XmlUiSlider, Attributes)

return XmlUiSlider

end)
__bundle_register("lib.xmlui.XmlUiScrollView", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_ScrollView : seb_XmlUi_Element

---@class seb_XmlUi_ScrollView_Static
---@overload fun(element: tts__UIScrollViewElement): seb_XmlUi_ScrollView
local XmlUiScrollView = {}

---@shape seb_XmlUi_ScrollViewAttributes : seb_XmlUi_Attributes
---@field scrollbarBackgroundColor nil | seb_XmlUi_Color
---@field scrollbarColors nil | seb_XmlUi_ColorBlock
---@field scrollSensitivity nil | number
---@field [any] nil @All other fields are invalid

local Attributes = {
  scrollbarBackgroundColor = XmlUiFactory.AttributeType.color,
  scrollbarColors = XmlUiFactory.AttributeType.colorBlock,
  scrollSensitivity = XmlUiFactory.AttributeType.float,
}

setmetatable(XmlUiScrollView, TableUtil.merge(getmetatable(XmlUiElement), {
  ---@param element tts__UIScrollViewElement
  __call = function(_, element)
    local self = --[[---@type seb_XmlUi_ScrollView]] XmlUiElement(element)

    return self
  end
}))

XmlUiFactory.register("HorizontalScrollView", XmlUiScrollView, Attributes)
XmlUiFactory.register("VerticalScrollView", XmlUiScrollView, Attributes)

return XmlUiScrollView

end)
__bundle_register("lib.xmlui.XmlUiRow", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Row : seb_XmlUi_Element

---@class seb_XmlUi_Row_Static
---@overload fun(element: tts__UIRowElement): seb_XmlUi_Row
local XmlUiRow = {}

---@shape seb_XmlUi_RowAttributes : seb_XmlUi_Attributes
---@field dontUseTableRowBackground nil | boolean
---@field image nil | tts__UIAssetName
---@field [any] nil @All other fields are invalid

local RowAttributes = {
    dontUseTableRowBackground = XmlUiFactory.AttributeType.boolean,
    image = XmlUiFactory.AttributeType.string,
}

setmetatable(XmlUiRow, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIRowElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Row]] XmlUiElement(element)

        local super_addChild = self.addChild

        ---@overload fun(): seb_XmlUi_Cell
        ---@param attributes seb_XmlUi_CellAttributes
        ---@return seb_XmlUi_Cell
        function self.addCell(attributes)
            local cell = XmlUiFactory.createCell(attributes)
            self.addChild(cell)
            return cell
        end

        ---@param uiElement seb_XmlUi_Element
        function self.addChild(uiElement)
            if uiElement.getType() ~= "Cell" then
                local cell = XmlUiFactory.createCell()
                cell.addChild(uiElement)
                super_addChild(cell)
            else
                super_addChild(uiElement)
            end
        end

        return self
    end
}))

XmlUiFactory.register("Row", XmlUiRow, RowAttributes)

end)
__bundle_register("lib.xmlui.XmlUiProgressBar", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_ProgressBar : seb_XmlUi_Element

---@class seb_XmlUi_ProgressBar_Static
---@overload fun(element: tts__UIProgressBarElement): seb_XmlUi_ProgressBar
local XmlUiProgressBar = {}

local Attributes = {}

setmetatable(XmlUiProgressBar, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIProgressBarElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_ProgressBar]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("ProgressBar", XmlUiProgressBar, Attributes)

return XmlUiProgressBar

end)
__bundle_register("lib.xmlui.XmlUiPanel", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Panel : seb_XmlUi_Element

---@class seb_XmlUi_Panel_Static
---@overload fun(element: tts__UIPanelElement): seb_XmlUi_Panel
local XmlUiPanel = {}

---@shape seb_XmlUi_PanelAttributes : seb_XmlUi_Attributes
---@field padding nil | seb_XmlUi_Padding
---@field [any] nil @All other fields are invalid

local Attributes = {
    padding = XmlUiFactory.AttributeType.padding,
}

setmetatable(XmlUiPanel, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIPanelElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Panel]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Panel", XmlUiPanel, Attributes)

return XmlUiPanel

end)
__bundle_register("lib.xmlui.XmlUiOption", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Option : seb_XmlUi_Element

---@class seb_XmlUi_Option_Static
---@overload fun(element: tts__UIOptionElement): seb_XmlUi_Option
local XmlUiOption = {}

---@shape seb_XmlUi_OptionAttributes : seb_XmlUi_Attributes
---@field value number | string
---@field selected nil | boolean
---@field [any] nil @All other fields are invalid

local OptionAttributes = {
    selected = XmlUiFactory.AttributeType.boolean,
}

setmetatable(XmlUiOption, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIOptionElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Option]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Option", XmlUiOption, OptionAttributes)

end)
__bundle_register("lib.xmlui.XmlUiInputField", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_InputField : seb_XmlUi_Element

---@class seb_XmlUi_InputField_Static
---@overload fun(element: tts__UIInputFieldElement): seb_XmlUi_InputField
local XmlUiInputField = {}

---@shape seb_XmlUi_InputFieldAttributes : seb_XmlUi_Attributes
---@field text nil | string
---@field lineType nil | "SingleLine" | "MultiLineSubmit" | "MultiLineNewLine"
---@field placeholder nil | string
---@field textAlignment nil | tts__UIElement_Alignment
---@field characterValidation nil | "None" | "Integer" | "Decimal" | "Alphanumeric" | "Name" | "EmailAddress"
---@field colors nil | seb_XmlUi_ColorBlock
---@field onEndEdit nil | seb_XmlUi_EventHandler
---@field onValueChanged nil | seb_XmlUi_EventHandler
---@field [any] nil @All other fields are invalid

local Attributes = {
  text = XmlUiFactory.AttributeType.string,
  lineType = XmlUiFactory.AttributeType.string,
  placeholder = XmlUiFactory.AttributeType.string,
  characterValidation = XmlUiFactory.AttributeType.string,
  textAlignment = XmlUiFactory.AttributeType.string,
  colors = XmlUiFactory.AttributeType.colorBlock,
  onEndEdit = XmlUiFactory.AttributeType.handler,
  onValueChanged = XmlUiFactory.AttributeType.handler,
  navigation = XmlUiFactory.AttributeType.string,
  selectOnDown = XmlUiFactory.AttributeType.string,
  selectOnUp = XmlUiFactory.AttributeType.string,
}

setmetatable(XmlUiInputField, TableUtil.merge(getmetatable(XmlUiElement), {
  ---@param element tts__UIInputFieldElement
  __call = function(_, element)
    local self = --[[---@type seb_XmlUi_InputField]] XmlUiElement(element)

    return self
  end
}))

XmlUiFactory.register("InputField", XmlUiInputField, Attributes)

return XmlUiInputField

end)
__bundle_register("lib.xmlui.XmlUiImage", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Image : seb_XmlUi_Element

---@class seb_XmlUi_Image_Static
---@overload fun(element: tts__UIImageElement): seb_XmlUi_Image
local XmlUiImage = {}

---@shape seb_XmlUi_ImageAttributes : seb_XmlUi_Attributes
---@field image URL
---@field preserveAspect nil | boolean
---@field [any] nil @All other fields are invalid

local Attributes = {
    image = XmlUiFactory.AttributeType.string,
    preserveAspect = XmlUiFactory.AttributeType.boolean,
}

setmetatable(XmlUiImage, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIImageElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Image]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Image", XmlUiImage, Attributes)

return XmlUiImage

end)
__bundle_register("lib.xmlui.XmlUiGridLayout", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_GridLayout : seb_XmlUi_Element

---@class seb_XmlUi_GridLayout_Static
---@overload fun(element: tts__UIGridLayoutElement): seb_XmlUi_GridLayout
local XmlUiGridLayout = {}

---@shape seb_XmlUi_GridLayoutAttributes : seb_XmlUi_Attributes
---@field padding nil | seb_XmlUi_Padding @Default {0, 0, 0, 0}
---@field spacing nil | seb_XmlUi_Size @Default {0, 0}
---@field cellSize nil | seb_XmlUi_Size @Default {100, 100}
---@field startCorner nil | tts__UIElement_Alignment_Corner @Default "UpperLeft"
---@field startAxis nil | tts__UIElement_Alignment_Axis @Default "Horizontal"
---@field childAlignment nil | tts__UIElement_Alignment @Default "UpperLeft"
---@field constraint nil | tts__UIGridLayoutElement_Constraint @Default "Flexible"
---@field constraintCount nil | number @Default 2
---@field [any] nil @All other fields are invalid


local Attributes = {
    cellSize = XmlUiFactory.AttributeType.vector2,
    constraint = XmlUiFactory.AttributeType.string,
    constraintCount = XmlUiFactory.AttributeType.integer,
    spacing = XmlUiFactory.AttributeType.vector2,
    startAxis = XmlUiFactory.AttributeType.string,
    startCorner = XmlUiFactory.AttributeType.string,
}

setmetatable(XmlUiGridLayout, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIGridLayoutElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_GridLayout]] XmlUiElement(element)

        ---@param value tts__UIGridLayoutElement_Constraint
        function self.setConstraint(value)
            self.setAttribute("constraint", value)
        end

        ---@param value number
        function self.setConstraintCount(value)
            self.setAttribute("constraintCount", value)
        end

        return self
    end
}))

XmlUiFactory.register("GridLayout", XmlUiGridLayout, Attributes)

return XmlUiGridLayout

end)
__bundle_register("lib.xmlui.XmlUiDropdown", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Dropdown : seb_XmlUi_Element

---@class seb_XmlUi_DropDown_Static
---@overload fun(element: tts__UIDropdownElement): seb_XmlUi_Dropdown
local XmlUiDropdown = {}

---@shape seb_XmlUi_DropdownAttributes : seb_XmlUi_Attributes
---@field arrowColor nil | seb_XmlUi_Color
---@field arrowImage nil | tts__UIAssetName
---@field checkColor nil | seb_XmlUi_Color
---@field checkImage nil | tts__UIAssetName
---@field dropdownBackgroundColor nil | seb_XmlUi_Color
---@field dropdownBackgroundImage nil | tts__UIAssetName
---@field image nil | tts__UIAssetName @The image used as the background for a closed dropdown.
---@field itemBackgroundColors nil | seb_XmlUi_ColorBlock
---@field itemHeight nil | number
---@field itemTextColor nil | seb_XmlUi_Color
---@field onValueChanged nil | seb_XmlUi_EventHandler
---@field scrollbarColors nil | seb_XmlUi_ColorBlock
---@field scrollbarImage nil | tts__UIAssetName
---@field scrollSensitivity nil | number
---@field textColor nil | seb_XmlUi_Color
---@field [any] nil @All other fields are invalid

local Attributes = {
  arrowColor = XmlUiFactory.AttributeType.color,
  arrowImage = XmlUiFactory.AttributeType.string,
  checkColor = XmlUiFactory.AttributeType.color,
  checkImage = XmlUiFactory.AttributeType.string,
  dropdownBackgroundColor = XmlUiFactory.AttributeType.color,
  dropdownBackgroundImage = XmlUiFactory.AttributeType.string,
  image = XmlUiFactory.AttributeType.string,
  itemBackgroundColors = XmlUiFactory.AttributeType.colorBlock,
  itemHeight = XmlUiFactory.AttributeType.integer,
  itemTextColor = XmlUiFactory.AttributeType.color,
  onValueChanged = XmlUiFactory.AttributeType.handler,
  scrollbarColors = XmlUiFactory.AttributeType.colorBlock,
  scrollbarImage = XmlUiFactory.AttributeType.string,
  scrollSensitivity = XmlUiFactory.AttributeType.float,
  textColor = XmlUiFactory.AttributeType.color,
}

setmetatable(XmlUiDropdown, TableUtil.merge(getmetatable(XmlUiElement), {
  ---@param element tts__UIDropdownElement
  __call = function(_, element)
    local self = --[[---@type seb_XmlUi_Dropdown]] XmlUiElement(element)

    ---@param attributes seb_XmlUi_OptionAttributes
    function self.addOption(attributes)
      local option = XmlUiFactory.createOption(attributes)
      self.addChild(option)
      return option
    end

    return self
  end
}))

XmlUiFactory.register("Dropdown", XmlUiDropdown, Attributes)

return XmlUiDropdown

end)
__bundle_register("lib.xmlui.XmlUiDefaults", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Defaults : seb_XmlUi_Element

---@class seb_XmlUi_Defaults_Static
---@overload fun(element: tts__UIDefaultsElement): seb_XmlUi_Defaults
local XmlUiDefaults = {}

local Attributes = {}

setmetatable(XmlUiDefaults, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIDefaultsElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Defaults]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Defaults", XmlUiDefaults, Attributes)

return XmlUiDefaults

end)
__bundle_register("lib.xmlui.XmlUiCell", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Cell : seb_XmlUi_Element

---@class seb_XmlUi_Cell_Static
---@overload fun(element: tts__UICellElement): seb_XmlUi_Cell
local XmlUiCell = {}

---@shape seb_XmlUi_CellAttributes : seb_XmlUi_Attributes
---@field columnSpan nil | integer @Default 1
---@field dontUseTableCellBackground nil |  boolean @Default false
---@field image nil | string
---@field overrideGlobalCellPadding nil | boolean @Default false
---@field padding nil | seb_XmlUi_Padding
---@field [any] nil @All other fields are invalid

local CellAttributes = {
    columnSpan = XmlUiFactory.AttributeType.integer,
    dontUseTableCellBackground = XmlUiFactory.AttributeType.boolean,
    image = XmlUiFactory.AttributeType.string,
    overrideGlobalCellPadding = XmlUiFactory.AttributeType.boolean,
    padding = XmlUiFactory.AttributeType.padding,
}

setmetatable(XmlUiCell, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UICellElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Cell]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Cell", XmlUiCell, CellAttributes)

end)
__bundle_register("lib.xmlui.XmlUiButton", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_Button : seb_XmlUi_Element

---@class seb_XmlUi_Button_Static
---@overload fun(element: tts__UIButtonElement): seb_XmlUi_Button
local XmlUiButton = {}

local Attributes = {
    colors = XmlUiFactory.AttributeType.colorBlock,
    textColor = XmlUiFactory.AttributeType.color,
}

---@shape seb_XmlUi_ButtonAttributes : seb_XmlUi_Attributes
---@field text nil | string
---@field value nil | string
---@field textColor nil | seb_XmlUi_Color
---@field colors nil | seb_XmlUi_ColorBlock
---@field [any] nil @All other fields are invalid

setmetatable(XmlUiButton, TableUtil.merge(getmetatable(XmlUiElement), {
    ---@param element tts__UIButtonElement
    __call = function(_, element)
        local self = --[[---@type seb_XmlUi_Button]] XmlUiElement(element)

        return self
    end
}))

XmlUiFactory.register("Button", XmlUiButton, Attributes)

return XmlUiButton

end)
__bundle_register("lib.xmlui.XmlUiAxisLayout", function(require, _LOADED, __bundle_register, __bundle_modules)
local TableUtil = require("lib.TableUtil")
local XmlUiFactory = require("lib.xmlui.XmlUiFactory")
local XmlUiElement = require("lib.xmlui.XmlUiElement")

---@class seb_XmlUi_AxisLayout : seb_XmlUi_Element

---@class seb_XmlUi_AxisLayout_Static
---@overload fun(element: tts__UIHorizontalLayoutElement | tts__UIVerticalLayoutElement): seb_XmlUi_AxisLayout
local XmlUiAxisLayout = {}

---@shape seb_XmlUi_AxisLayoutAttributes : seb_XmlUi_Attributes
---@field childAlignment nil | tts__UIElement_Alignment
---@field childForceExpandWidth nil | boolean
---@field childForceExpandHeight nil | boolean
---@field padding nil | seb_XmlUi_Padding
---@field spacing nil | integer
---@field [any] nil @All other fields are invalid

local Attributes = {
  childAlignment = XmlUiFactory.AttributeType.string,
  childForceExpandWidth = XmlUiFactory.AttributeType.boolean,
  childForceExpandHeight = XmlUiFactory.AttributeType.boolean,
  padding = XmlUiFactory.AttributeType.padding,
  spacing = XmlUiFactory.AttributeType.integer,
}

setmetatable(XmlUiAxisLayout, TableUtil.merge(getmetatable(XmlUiElement), {
  ---@param element tts__UIHorizontalLayoutElement | tts__UIVerticalLayoutElement
  __call = function(_, element)
    local self = --[[---@type seb_XmlUi_AxisLayout]] XmlUiElement(element)

    return self
  end
}))

XmlUiFactory.register("HorizontalLayout", XmlUiAxisLayout, Attributes)
XmlUiFactory.register("VerticalLayout", XmlUiAxisLayout, Attributes)

return XmlUiAxisLayout

end)
__bundle_register("lib.Ui", function(require, _LOADED, __bundle_register, __bundle_modules)
local Math = require("lib.Math")

---@class Lib_UI
local Ui = {}

Ui.MouseEvent = {
  LeftClick = "-1",
  RightClick = "-2",
  MiddleClick = "-3",
  SingleTouch = "1",
  DoubleTouch = "2",
  TripleTouch = "3",
}

---@param id tts__UIElement_Id
---@param player tts__Player
function Ui.showForPlayer(id, player)
  showForPlayer({ panel = id, color = player.color })
end

function Ui.setAttribute(id, attribute, value)
  self.UI.setAttribute(id, attribute, value)
end

---@param active boolean
function Ui.setActive(id, active)
  Ui.setAttribute(id, "active", active)
end

---@param text string | number
function Ui.setText(id, text)
  Ui.setAttribute(id, "text", text)
end

---@param image string
function Ui.setImage(id, image)
  Ui.setAttribute(id, "image", image)
end

---@param xml tts__UIElement[]
---@param id string
function Ui.findElement(xml, id)
  for _, element in ipairs(xml) do
    if element.attributes.id == id then
      return element
    end
  end

  for _, element in ipairs(xml) do
    if element.children then
      local found = Ui.findElement(element.children, id)
      if found then
        return found
      end
    end
  end
end

function Ui.isLoaded()
  return self.UI.getXml() ~= ""
end

---@param id string
---@param pattern string
---@return string
function Ui.getPart(id, pattern)
  local part = id:match(pattern)
  return part
end

---@param id string
---@param pattern string
---@return integer
function Ui.getIndex(id, pattern)
  return Ui.getIndexes(id, pattern)
end

---@param id string
---@param pattern string
---@return integer, integer...
function Ui.getIndexes(id, pattern)
  local parts = table.pack(id:match(pattern))

  for i, part in ipairs(parts) do
    parts[i] = tonumber(part)
  end

  return table.unpack(parts)
end

---@param size number
---@return integer
function Ui.fontSize(size)
  return Math.round(size * 0.7)
end

---@param colorHex string
---@param adjustment? integer
function Ui.adjustColor(colorHex, adjustment)
  local color = Color.fromHex(colorHex)
  adjustment = adjustment or 1

  color.r = (color.r + adjustment) / 2
  color.g = (color.g + adjustment) / 2
  color.b = (color.b + adjustment) / 2

  local asHex = color:toHex(true)
  return "#" .. asHex
end


return Ui

end)
__bundle_register("ui.element.Checkmark", function(require, _LOADED, __bundle_register, __bundle_modules)
local BaseElement = require("ui.element.BaseElement")

local Checkmark = {}
local this = {}

---@class UI_Checkmark : UI_Element

---@shape UI_Checkmark_Parameters : UI_Element_Parameters
---@field value nil | boolean
---@field onValueChange UI_Checkmark_Handler

---@alias UI_Checkmark_Handler fun(player: tts__Player, value: boolean, element: UI_Checkmark)

---@shape __UI_Checkmark_Settings
---@field element UI_Checkmark
---@field onValueChange UI_Checkmark_Handler
---@field value boolean

---@type table<string, __UI_Checkmark_Settings>
local elements = {}
local checkSymbol = "✗"

---@param params UI_Checkmark_Parameters
---@return UI_Checkmark
function Checkmark.create(params)
  local self = --[[---@type UI_Checkmark]] BaseElement(params)

  local root = self.element

  local panel = root.addPanel({
    id = self.elementId("panel"),
    width = params.size, height = params.size,
    onClick = self.handlerName("onCheckmarkClicked"),
  })
  panel.addText({
    id = self.elementId("text"),
    text = params.value and checkSymbol or "",
    fontSize = 2 * params.size - 10,
    width = 2 * params.size, height = 2 * params.size,
  })

  elements[self.fullId] = {
    element = self,
    value = params.value,
    onValueChange = params.onValueChange,
  }

  ---@param checked boolean
  function self.setChecked(checked)
    this.setChecked(self, checked)
  end

  ---@return boolean
  function self.isChecked()
    return elements[self.fullId].value
  end

  return self
end

---@type UIElement_Callback
onCheckmarkClicked = function(player, _, id)
  local baseId = --[[---@type string]] id:match("^(.*)-panel$")
  local element = elements[baseId].element

  local newValue = not element.isChecked()
  local result = elements[baseId].onValueChange(player, newValue, element)

  if result == nil or result == true then
    this.setChecked(element, newValue)
  end
end

---@param element UI_Checkmark
---@param active boolean
function this.setChecked(element, active)
  elements[element.fullId].value = active
  local newText = active and checkSymbol or ""
  element.setAttribute("text", "text", newText)
end

return Checkmark

end)
__bundle_register("Game.Engine.Component.BaseCharacterSheet", function(require, _LOADED, __bundle_register, __bundle_modules)
local Ui = require("lib.Ui")
local TableUtil = require("lib.TableUtil")
local XmlUi = require("lib.XmlUi")

local Checkmark = require("ui.element.Checkmark")
local Counter = require("ui.element.Counter")
local TextField = require("ui.element.TextField")
local Style = require("ui.GloomUiStyle")

---@class CharacterSheet_static
local CharacterSheet = {}
local ttsSelf = self

CharacterSheet.XPLevel = { 0, 45, 95, 150, 210, 275, 345, 420, 500 }
CharacterSheet.MaxLevel = 9

---@class CharacterSheet

---@shape CharacterSheet_Data
---@field name string
---@field xp integer
---@field gold integer
---@field level integer
---@field perks set<integer>
---@field checkmarks integer
---@field notes string
---@field notesBack string
---@field items string

---@shape CharacterSheet_Setup
---@field levelOffset
---@field perkPositions seb_Vector2[]

---@param setup CharacterSheet_Setup
---@return CharacterSheet
local function new(setup, _)
  local self = --[[---@type CharacterSheet]] {}

  ttsSelf.addTag("Character Sheet")

  local this = {
    ---@type seb_Vector2
    levelOffset = setup.levelOffset or { -251, 322 },
    ---@type integer
    levelDiff = 33,
    ---@type seb_Vector2
    perkOffset = { 107, 404 },
    perkDiff = { column = 23, row = -29, track = 100 },
    ---@type seb_Vector2[]
    perkPositions = setup.perkPositions,
  }
  local state = {
    ---@type boolean
    isDirty = true,
    ---@type string
    representation = "",
  }
  local ui = {
    ---@type UI_Checkmark[]
    levelCheckmarks = {},
    ---@type UI_Counter
    xpCounter = nil,
    ---@type UI_Counter
    goldCounter = nil,
  }

  ---@type CharacterSheet_Data
  self.data = {
    name = "",
    xp = 0,
    gold = 0,
    level = 1,
    perks = {},
    checkmarks = 0,
    notes = "",
    notesBack = "",
    items = "",
  }

  function onLoad(savedData)
    if savedData and savedData ~= "" then
      self.data = JSON.decode(savedData)
    end

    this.initUi()
  end

  function onSave()
    if state.isDirty then
      state.representation = JSON.encode(self.data)
      state.isDirty = false
    end

    return state.representation
  end

  ---@param character Campaign_Character
  function saveCharacterData(character)
    return self.saveCharacterData(character)
  end

  ---@param character Campaign_Character
  function loadCharacterData(character)
    self.loadCharacterData(character)
    ttsSelf.UI.setXml("")
    this.initUi()
  end

  function getCharacterName()
    return self.data.name
  end

  function getLevel()
    return self.data.level
  end

  function getXp()
    return self.data.xp
  end

  function changeXp(diff)
    local newValue = ui.xpCounter.getValue() + diff
    ui.xpCounter.setValue(newValue)
    self.data.xp = newValue
    this.saveNow()
  end

  function getGold()
    return self.data.gold
  end

  function changeGold(diff)
    local newValue = ui.goldCounter.getValue() + diff
    ui.goldCounter.setValue(newValue)
    self.data.gold = newValue
    this.saveNow()
  end

  ---@param front seb_XmlUi_Panel
  ---@param back seb_XmlUi_Panel
  function self.createUi(front, back)
    this.createUi(front, back)
  end

  ---@generic T
  ---@param f T
  ---@return T
  function self.changeState(f)
    local wrapper = function(...)
      local res = f(...)
      this.saveNow()
      return res
    end

    return wrapper
  end

  ---@param character Campaign_Character
  ---@return Campaign_Character
  function self.saveCharacterData(character)
    character.name = self.data.name
    character.level = self.data.level
    character.xp = self.data.xp
    character.gold = self.data.gold
    character.perks = TableUtil.setToList(self.data.perks)
    character.checkmarks = self.data.checkmarks
    character.notes = self.data.notes
    character.hiddenNotes = self.data.notesBack

    return character
  end

  ---@param character Campaign_Character
  function self.loadCharacterData(character)
    self.data.name = character.name or ""
    self.data.level = character.level or 1
    self.data.xp = character.xp or 0
    self.data.gold = character.gold or 0
    self.data.perks = TableUtil.listToSet(character.perks or {})
    self.data.checkmarks = character.checkmarks or 0
    self.data.notes = character.notes or ""
    self.data.notesBack = character.hiddenNotes or ""
    -- TODO items
  end

  function this.initUi()
    local xmlUi = XmlUi(ttsSelf)
    local front = xmlUi.addPanel({
      position = { 0, 0, -11 },
      rotation = { 0, 0, 180 },
      scale = { 0.2, 0.2, 0.2 },
    })

    local back = xmlUi.addPanel({
      position = { 0, 0, 1 },
      rotation = { 0, 180, 180 },
      scale = { 0.2, 0.2, 0.2 },
    })

    self.createUi(front, back)
    xmlUi.update()
  end

  ---@param front seb_XmlUi_Panel
  ---@param back seb_XmlUi_Panel
  function this.createUi(front, back)
    this.initNameField(front)
    this.initLevelCheckmarks(front)
    this.initPerkCheckmarks(front)
    this.initPerks(front)
    this.initGoldCounter(front)
    this.initExperienceCounter(front)
    this.initNotesFields(front, back)
  end

  ---@param root seb_XmlUi_Panel
  function this.initNameField(root)
    local name = TextField.create({
      id = "name",
      value = self.data.name,
      placeholder = "Name",
      width = 300, height = 40,
      offset = { -130, 365 },
      alignment = XmlUi.Alignment.MiddleCenter,
      onValueChange = this.changeData("name"),
    })
    root.addChild(name.element)
  end

  ---@param root seb_XmlUi_Panel
  function this.initLevelCheckmarks(root)
    local basePanel = root.addPanel({
      offsetXY = this.levelOffset,
      width = 1, height = 1,
    })

    for i = 1, CharacterSheet.MaxLevel do
      local offset = (i - 1) * this.levelDiff
      local levelCheckMark = Checkmark.create({
        id = "level_" .. i,
        size = 25,
        offset = { offset, 0 },
        value = self.data.level >= i,
        onValueChange = self.changeState(this.onChangeLevel),
      })
      table.insert(ui.levelCheckmarks, levelCheckMark)
      basePanel.addChild(levelCheckMark.element)
    end
  end

  ---@type UI_Checkmark_Handler
  this.onChangeLevel = function(_, value, element)
    local newLevel = Ui.getIndex(element.id, ("level_(.)"))
    if newLevel == 1 then
      return false
    end

    if not value then
      newLevel = newLevel - 1
    end

    for i = 2, CharacterSheet.MaxLevel do
      local active = i <= newLevel
      ui.levelCheckmarks[i].setChecked(active)
    end

    local newXp = CharacterSheet.XPLevel[newLevel]
    if newXp > self.data.xp then
      self.data.xp = newXp
      ui.xpCounter.setValue(newXp)
    end

    self.data.level = newLevel
  end

  ---@param root seb_XmlUi_Panel
  function this.initPerkCheckmarks(root)
    local index = 1
    for row = 1, 2 do
      for col = 1, 3 do
        local x = this.perkOffset[1] + (col - 1) * this.perkDiff.track
        local y = this.perkOffset[2] + (row - 1) * this.perkDiff.row

        local basePanel = root.addPanel({
          offsetXY = { x, y },
          width = 1, height = 1,
        })
        root.addChild(basePanel)

        for i = 1, 3 do
          local offset = (i - 1) * this.perkDiff.column
          local perkCheckMark = Checkmark.create({
            id = "perkCheckmark_" .. index,
            size = 20,
            offset = { offset, 0 },
            value = self.data.checkmarks >= index,
            onValueChange = self.changeState(this.onChangeCheckMark),
          })
          basePanel.addChild(perkCheckMark.element)

          index = index + 1
        end
      end
    end
  end

  ---@type UI_Checkmark_Handler
  this.onChangeCheckMark = function(_, value)
    local diff = value and 1 or -1
    self.data.checkmarks = self.data.checkmarks + diff
  end

  ---@param root seb_XmlUi_Panel
  function this.initExperienceCounter(root)
    ui.xpCounter = Counter.create({
      id = "xp",
      value = self.data.xp,
      min = 0,
      size = 140,
      fontSize = 80,
      offset = { -260, 160 },
      onValueChange = self.changeState(this.onChangeXp),
    })

    root.addChild(ui.xpCounter.element)
  end

  ---@param xpValue integer
  ---@return integer
  function this.getLevelFromXp(xpValue)
    for level, requiredXp in pairs(CharacterSheet.XPLevel) do
      if xpValue <= requiredXp then
        return level
      end
    end
  end

  ---@type UI_Counter_Handler
  this.onChangeXp = function(_, value)
    self.data.xp = value

    for i = 2, CharacterSheet.MaxLevel do
      local active = i <= self.data.level
      ui.levelCheckmarks[i].setChecked(active)
    end
  end

  ---@param root seb_XmlUi_Panel
  function this.initGoldCounter(root)
    ui.goldCounter = Counter.create({
      id = "gold",
      value = self.data.gold,
      min = 0,
      size = 140,
      fontSize = 80,
      offset = { -60, 160 },
      onValueChange = this.changeData("gold"),
    })

    root.addChild(ui.goldCounter.element)
  end

  ---@param front seb_XmlUi_Panel
  function this.initPerks(front)
    local index = 1
    for _, position in ipairs(this.perkPositions) do
      local perk = Checkmark.create({
        id = "perk_" .. index,
        value = self.data.perks[index],
        offset = position,
        size = 20,
        onValueChange = self.changeState(this.onPerkClicked),
      })
      index = index + 1

      front.addChild(perk.element)
    end
  end

  ---@type UI_Checkmark_Handler
  this.onPerkClicked = function(_, value, element)
    local perk = Ui.getIndex(element.id, "_(.*)")
    self.data.perks[perk] = value
  end

  ---@param front seb_XmlUi_Panel
  ---@param back seb_XmlUi_Panel
  function this.initNotesFields(front, back)
    local frontNotes = TextField.create({
      id = "notes",
      value = self.data.notes,
      width = 400, height = 110,
      offset = { -160, -220 },
      font = Style.Font.Default,
      textSize = 26,
      multiline = true,
      alignment = XmlUi.Alignment.UpperLeft,
      onValueChange = this.changeData("notes"),
    })
    front.addChild(frontNotes.element)

    local backNotes = TextField.create({
      id = "notesBack",
      placeholder = "Notes",
      value = self.data.notesBack,
      multiline = true,
      alignment = XmlUi.Alignment.UpperLeft,
      width = 750, height = 400,
      font = Style.Font.Default,
      textSize = 30,
      offset = { 0, 200 },
      onValueChange = this.changeData("notesBack"),
    })
    local itemNotes = TextField.create({
      id = "itemNotes",
      placeholder = "Items",
      value = self.data.items,
      multiline = true,
      alignment = XmlUi.Alignment.UpperLeft,
      width = 750, height = 450,
      font = Style.Font.Default,
      textSize = 30,
      offset = { 0, -220 },
      onValueChange = this.changeData("items"),
    })

    back.addChild(backNotes.element)
    back.addChild(itemNotes.element)
  end

  function this.saveNow()
    state.isDirty = true
  end

  ---@param name string
  function this.changeData(name)
    return self.changeState(function(_, value)
      self.data[name] = value
    end)
  end

  return self
end

---@param setup CharacterSheet_Setup
---@return CharacterSheet
function CharacterSheet.create(setup)
  return new(setup)
end

return CharacterSheet


end)
__bundle_register("ui.GloomUiStyle", function(require, _LOADED, __bundle_register, __bundle_modules)
local GloomUiStyle = {}

GloomUiStyle.Color = {
  Black = "#1F2021",
  Grey = "#5F6061",
  DarkGrey = "#282A2D",
  White = "#FFFFFF",
}

GloomUiStyle.Font = {
  --- The TTS default font
  Default = "default",
  Germania = "fonts/GermaniaOne",
  Markazi = "fonts/MarkaziGloom",
  Nyala = "fonts/Nyala",
  Pirata = "fonts/PirataOne",
}

return GloomUiStyle

end)
__bundle_register("ui.element.TextField", function(require, _LOADED, __bundle_register, __bundle_modules)
local Ui = require("lib.Ui")
local XmlUi = require("lib.XmlUi")

local BaseElement = require("ui.element.BaseElement")

local TextField = {}
local this = {}

---@class UI_TextField : UI_Element

---@class UI_TextField_Parameters : UI_Element_Parameters
---@field alignment nil | tts__UIElement_Alignment
---@field font nil | string
---@field fontStyle nil | tts__UIElement_FontStyle
---@field textSize nil | integer
---@field multiline nil | boolean
---@field onValueChange UI_TextField_Handler
---@field value string
---@field placeholder nil | string

---@alias UI_TextField_Handler fun(player: tts__Player, value: string, element: UI_TextField)

---@class __UI_TextField_Settings
---@field element UI_TextField
---@field onValueChange UI_TextField_Handler
---@field value string

---@type table<string, __UI_TextField_Settings>
local elements = {}
local UiSettings = {
  colors = { "#FFFFFF00", "#00000070", "#000000B0" },
  ---@type string
  font = "fonts/MarkaziGloom",
}

---@param params UI_TextField_Parameters
---@return UI_TextField
function TextField.create(params)
  local self = --[[---@type UI_TextField]] BaseElement(params)

  local root = self.element
  local fontSize = params.textSize or Ui.fontSize(params.height)

  root.addInputField({
    id = self.elementId("input"),
    text = params.value,
    textAlignment = params.alignment or XmlUi.Alignment.MiddleLeft,
    placeholder = params.placeholder or " ",
    lineType = params.multiline and "MultiLineNewLine" or "SingleLine",
    font = params.font or UiSettings.font,
    fontSize = fontSize,
    fontStyle = params.fontStyle,
    colors = UiSettings.colors,
    width = params.width,
    height = params.height,
    onEndEdit = self.handlerName("onTextFieldChanged"),
    verticalOverflow = "Overflow",
    navigation = params.navigation,
    selectOnUp = params.selectOnUp,
    selectOnDown = params.selectOnDown,
  })

  elements[self.fullId] = {
    element = self,
    value = params.value,
    onValueChange = params.onValueChange,
  }

  function self.setValue(value)
    self.setAttribute("input", "text", value)
  end

  return self
end

---@type UIElement_Callback
onTextFieldChanged = function(player, value, id)
  local baseId = Ui.getPart(id, "^(.*)-input$")
  local settings = elements[baseId]

  local result = settings.onValueChange(player, value, settings.element)
  if result == nil or result == true then
    elements[baseId].value = value
    settings.element.setAttribute("input", "text", value)
  end
end

return TextField

end)
return __bundle_require("__root")
