This content may be out-of-date. For up-to-date resources on the Avatar Editor Service, see [Avatar Editor Service](https://create.roblox.com/docs/avatar/characters/avatar-editor-service).

# AvatarEditorInGame

A port of an older version of the App Avatar Editor made to work in game using the developer avatar editor APIs.
Documentation on these APIs can be found here:
https://developer.roblox.com/en-us/articles/avatar-editor-service

An example of this in a game is:
https://www.roblox.com/games/7248489399/Avatar-Editor-in-Game-demo

## Setup
Everything is in a single model (AvatarEditorInGameSetup.rbxm) that should be put in ServerScriptService. This model will install the Avatar Editor when the game is ran. It puts a server script AvatarEditorServer in ServerScriptService and a client script and Gui in StarterGui.

Alternatively a Rojo project is provided. This is to make it easier to track any bug fixes or updates to the project.
Install instructions for Rojo can be found here: https://github.com/rojo-rbx/rojo
To use this rojo project clone the repository and then use rojo build --output FileName.rbxlx

## Integrating the avatar editor
Take a look at how InGameStarterScript works. You can called PromptAllowInventoryReadAccess and require AvatarEditorManager in the same way in your code.
Then to show the avatar editor call AvatarEditorManager:showAvatarEditor()
Hiding the avatar editor is more complicated since you need to worry about calling PromptSaveAvatar. You should be able to modify the hideAvatarEditor function for your purposes though.

## Changing the theme
If you plan on using this in your game you may be interested in changing the theming of the avatar editor. Simple color modifcations can be made by editing the DarkTheme module in Modules/Common/. You may also wish to change the background used by the editor. To do this you can change the AvatarSceneNew in Assets.

## Config
There are some configs in AvatarEditorInGame/Modules/Configs/. IsCatalogEnabled is the most useful.
Some of the other configs are more of a tool to find code that has been changed in a certain way but turning them off wouldn't be useful.

