--[[
================================================================================
STYLE
================================================================================
CSS-like styling system for the texture editor UI. Components are tagged with
string identifiers, and the style manager applies GUI properties to those
tagged components via Roblox's StyleSheet API.

This allows component files to focus primarily on functionality and composition,
while all visual styling is handled in one place for easier maintenance.

For more information, also see: https://create.roblox.com/docs/ui/styling


--------------------------------------------------------------------------------
FILES
--------------------------------------------------------------------------------

StyleConsts.lua
  Constants used across the styling system and UI components:

    tags
      String constants for every tag that can be applied to a UI component
      (e.g. StyleConsts.tags.Panel). Use these instead of raw strings to
      avoid typos and enable refactoring.

    styleTokens
		  Design tokens for UI properties such as colors, spacing, radii, etc.

    fontTokens
      Pre-built Font + TextSize pairs for common text roles (title, body,
      button, etc.).

    icons / editorIcons / widgetIcons / regionIcons
      rbxassetid:// image IDs, organized by use:
        icons          - toolbar tool icons
        editorIcons    - per-model editor entry icons
        widgetIcons    - widget control group icons
        regionIcons    - body region icons

    uiImages
		  Image IDs for UI chrome (toggle states, opacity picker background).

    regionOrdering / modelDisplayName
      Metadata for body region ordering and display names specific to IEC
      creation.


StyleSheet.lua
  The style manager. Creates and owns the StyleSheet instance that drives
  visual styling. Pulls rules from StyleRules and theming from StyleThemes.

  Heavily uses the Roblox StyleSheet API:
  https://create.roblox.com/docs/ui/styling

  Key methods:
    Style.new()
		Creates the core stylesheet and both themes; calls GenerateRules
		internally.

    Style:LinkGui(screenGui)
		Attaches the stylesheet to a ScreenGui and wires up responsive theme
		switching.

    Style:Destroy()
		Cleans up the core stylesheet instance.


StyleRules.lua
  Contains tables of CSS-like style rules, organized into named tables by
  component for readability. Uses tags and values from StyleConsts, and theme
  tokens from StyleThemes.

  To add rules, either add to an existing table or create a new one, then add
  the new table to Style:GenerateRules() in StyleSheet.lua.

  Exports three rule sets used by StyleSheet:
    lowPriorityRules    — broad defaults
    standardRules       — component-specific rules
    highPriorityRules   — state overrides (e.g. button hover/selected states)


StyleThemes.lua
  Theme token definitions for mobile and desktop layouts. Theme tokens are
  string attribute keys set on StyleSheet instances at runtime, allowing rules
  to reference them via the ${token} syntax.

  If a property should be different between mobile and desktop, it should use a
  theme token. Add the theme token key to THEME_TOKENS, and then define the
  value for that token in all theme tables.


StyleUtils.lua
  Utility functions for working with the styling system.

  Key methods:
    StyleUtils.AddStyleTag(component, tag)
		Calls component:AddTag(tag) with a nil-guard and a descriptive warning.

    StyleUtils.RemoveStyleTag(component, tag)
		Calls component:RemoveTag(tag) with the same nil-guard.


--------------------------------------------------------------------------------
USAGE
--------------------------------------------------------------------------------
UI handlers may tag UI components, or components may tag themselves, via
StyleUtils and StyleConsts.tags. The style manager then applies the matching
rules automatically.

The StyleSheet instance is created once in a UI Manager and linked to each
ScreenGui via Style:LinkGui.

Example code:

    local Style = UI:WaitForChild("Style")
    local StyleConsts = require(Style:WaitForChild("StyleConsts"))
    local StyleUtils = require(Style:WaitForChild("StyleUtils"))

    -- Tag a component so style rules apply to it
    StyleUtils.AddStyleTag(myFrame, StyleConsts.tags.Panel)

    -- Remove a tag to change visual state
    StyleUtils.RemoveStyleTag(myButton, StyleConsts.tags.ButtonSelected)

]]
