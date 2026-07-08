--[[
================================================================================
HANDLERS
================================================================================
UI handlers for the editor. Each handler is responsible for creating one or more
ScreenGuis and wiring up UI components to tool and manager logic.

These handlers are specific to this reference experience*. They depend on the
manager, tool, and model-info interfaces defined here and will not import
cleanly into other experiences without adapting those dependencies.

BaseUI.lua is the top-level handler that creates the shared StyleSheet instance
and sets up shared context for the other handlers. The other handlers are
organized by tool or feature, and are created and owned by BaseUI.

* Except ExampleUI.lua, which is a portable template showing how to use the Style
system and components.
]]
