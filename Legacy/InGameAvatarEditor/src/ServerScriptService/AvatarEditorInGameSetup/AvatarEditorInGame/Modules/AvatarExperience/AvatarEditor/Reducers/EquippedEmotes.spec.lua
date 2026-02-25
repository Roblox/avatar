return function()
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")

    local Modules = Players.LocalPlayer.PlayerGui.AvatarEditorInGame.Modules

	local Constants = require(Modules.AvatarExperience.Common.Constants)
    local EquippedEmotes = require(script.Parent.EquippedEmotes)

    local EMOTES_TYPE = Constants.AssetTypes.Emote

    -- Actions
    local ReceivedAvatarData = require(Modules.AvatarExperience.AvatarEditor.Actions.ReceivedAvatarData)
	local SetSelectedEmoteSlot = require(Modules.AvatarExperience.AvatarEditor.Actions.SetSelectedEmoteSlot)
    local ToggleEquipAsset = require(Modules.AvatarExperience.AvatarEditor.Actions.ToggleEquipAsset)

	it("should be unchanged by other actions", function()
		local oldState = EquippedEmotes(nil, {})
		local newState = EquippedEmotes(oldState, { type = "not a real action" })
		expect(oldState).to.equal(newState)
	end)

	describe("ReceivedAvatarData", function()
        it("should create emotes info from received avatar data", function()
            local avatarData = [[
                {
                    "scales": {},
                    "playerAvatarType": "R15",
                    "bodyColors": {},
                    "assets": [],
                    "defaultShirtApplied": false,
                    "defaultPantsApplied": false,
                    "emotes": [
                        {
                            "assetId": 2147616526,
                            "assetName": "Laugh",
                            "position": 1
                        },
                        {
                            "assetId": 2147617580,
                            "assetName": "Wave",
                            "position": 4
                        }
                    ]
                }
            ]]

            local dataTable = HttpService:JSONDecode(avatarData)

            local newState = EquippedEmotes(nil, ReceivedAvatarData(dataTable))
            expect(newState.slotInfo[1].assetId).to.equal("2147616526")
            expect(newState.slotInfo[4].assetId).to.equal("2147617580")
        end)
	end)

	describe("ToggleEquipAsset", function()
        it("should equip an Emote with ToggleEquipAsset", function()
            local newState = EquippedEmotes(nil, ToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[1].assetId).to.equal("333")
        end)

        it("should unequip an asset with ToggleEquipAsset", function()
            local newState = EquippedEmotes(nil, ToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[1].assetId).to.equal("333")

            newState = EquippedEmotes(newState, ToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[1]).never.to.be.ok()
        end)

        it("should not equip non Emotes with ToggleEquipAsset", function()
            local newState = EquippedEmotes(nil, ToggleEquipAsset("1", "333"))
            expect(newState.slotInfo[1]).never.to.be.ok()
        end)
    end)

    describe("SetSelectedEmoteSlot", function()
        it("should change selectedSlot with SetSelectedEmoteSlot", function()
            local newState = EquippedEmotes(nil, SetSelectedEmoteSlot(4))
            expect(newState.selectedSlot).to.equal(4)

            newState = EquippedEmotes(newState, SetSelectedEmoteSlot(2))
            expect(newState.selectedSlot).to.equal(2)
        end)
    end)

    describe("SetSelectedEmoteSlot and ToggleEquipAsset", function()
        it("should equip emote on selected slot", function()
            local newState = EquippedEmotes(nil, SetSelectedEmoteSlot(4))
            expect(newState.selectedSlot).to.equal(4)

            newState = EquippedEmotes(newState, ToggleEquipAsset(EMOTES_TYPE, "333"))
            expect(newState.slotInfo[4].assetId).to.equal("333")
        end)
    end)
end