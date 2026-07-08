--[[
================================================================================
UI
================================================================================
Client-side UI system for the texture editor. Organized into three folders:

  Components/   Reusable UI building blocks (panels, buttons, pickers, etc.).
                Depend only on Style — portable to other experiences.

  Style/        CSS-like styling system built on Roblox's StyleSheet API.
                Drives all visual properties via tags and rules. Portable.

  Handlers/     Experience-specific wiring between Components and the editor's
                tools, managers, and data. Not portable.


--------------------------------------------------------------------------------
PORTABILITY
--------------------------------------------------------------------------------
Components and Style can be lifted into another experience with no changes.
They have no dependencies outside of each other.

Handlers typically heavily depend on the manager, tool, and model-info
interfaces defined for IEC and must be adapted for any new experience.
The exception is ExampleUI, which is a portable template meant to show how to
build a UI handler using this Style system.


--------------------------------------------------------------------------------
USAGE
--------------------------------------------------------------------------------
BaseUI.lua is the entry point. It creates the shared StyleSheet instance and
owns the other handlers. All other handlers are created and managed by BaseUI.

Components are instantiated directly from handler code — each returns a frame or
instance via a constructor function. Styling is applied automatically once the
component's GUI instances are tagged (via StyleUtils.AddStyleTag) and linked to
the shared StyleSheet (via Style:LinkGui).

See Style/.README.lua for details on the styling system.
See Handlers/.README.lua for details on the handler architecture.

]]
