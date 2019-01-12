local Attendance = NastrandirRaidTools:NewModule("Attendance")

--[[
Attendance = {
    raids = {
        [20181219] = {
            name = "Uldir",
            date = 20181219,
            start = 1915,
            end = 2245
        }
    },
    states = {
        ["Im Raid"] = {
            CountIn = true,
            LogMessages = {
                Enter = "<Main> tritt dem Raid bei.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> verlässt den Raid."
            }
        },
        ["Ersatzbank"] = {
            CountIn = true,
            LogMessages = {
                Enter = "<Main> geht auf die Ersatzbank.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> verlässt die Ersatzbank."
            }
        },
        ["Abgemeldet"] = {
            CountIn = true,
            LogMessages = {
                Enter = "<Main> ist jetzt abgemeldet.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> ist jetzt nicht mehr abgemeldet.",
            }
        },
        ["Fehlt"] = {
            CountIn = true,
            LogMessages = {
                Enter = "<Main> fehlt.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> fehlt jetzt nicht mehr.
            }
        },
        ["Frei"] = {
            CountIn = true,
            LogMessages = {
                Enter = "<Main> hat jetzt frei.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> hat jetzt nicht mehr frei.",
            }
        }
        ["Urlaub"] = {
            CountIn = false, -- Don't take care of this raid
            LogMessages = {
                Enter = "<Main> ist jetzt im Urlaub.",
                CharacterSwap = "<Main> hat auf <Character> umgeloggt.",
                Leave = "<Main> ist jetzt nicht mehr im Urlaub."
            }
        }
    },
    analytics = {
        ["Teilgenommen"] = {
            states = {
                "Im Raid",
                "Ersatzbank",
                "Frei"
            },
            colors = {
                {
                    value = 0,
                    color = {1, 0, 0}
                }
                {
                    value = 0.5,
                    color = {1, 1, 0}
                }
                {
                    value = 1,
                    color = {0, 1, 0}
                }
            }
        },
        ["Im Raid"] = {
            "Im Raid",
        },
        ["Abgemeldet"] = {
            "Abgemeldet"
        },
        ["Fehlt"] = {
            "Fehlt"
        }
    },
    participation = {
        [20181219] = {
            {
                -- Entered raid
                member = "Shielddux-20181219-1223",
                time = 1915,
                state = "In Raid"
            },
            {
                -- Swapped to an alt
                member = "Shielddux-20181219-1227"
                time = 1930,
                state = "In Raid"
            }
        }
    }
}
]]

function Attendance:Initialize()
end

function Attendance:OnEnable()
    print("Adding Attendance menu entry")
    NastrandirRaidTools:AddMenu({
        {
            text = "Attendance",
            priority = 1,
            onClick = function(button, mouseButton)
                Attendance:ShowRaidList()
            end
        }
    })
end

function Attendance:ShowRaidList()

end

function Attendance:ShowRaidLog(raid_id)

end
