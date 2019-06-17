local NastrandirRaidTools = LibStub("AceAddon-3.0"):NewAddon("NastrandirRaidTools", "AceConsole-3.0", "AceEvent-3.0")
_G["NastrandirRaidTools"] = NastrandirRaidTools


---------------------- Roles ----------------------
NastrandirRaidTools.role_types = {
    tank = "TANK",
    heal = "HEAL",
    ranged = "RANGED",
    melee = "MELEE",
    dps = "DPS",
    none = "NONE",
    damager = "DAMAGER",
    all = "ALL"
}

---------------------- Classes ----------------------
NastrandirRaidTools.classes = {
    [NastrandirRaidTools.role_types.all] = {
        DEATHKNIGHT = "Death Knight",
        DEMONHUNTER = "Demon Hunter",
        DRUID = "Druid",
        HUNTER = "Hunter",
        MAGE = "Mage",
        MONK = "Monk",
        PALADIN = "Paladin",
        PRIEST = "Priest",
        ROGUE = "Rogue",
        SHAMAN = "Shaman",
        WARLOCK = "Warlock",
        WARRIOR = "Warrior"
    },
    [NastrandirRaidTools.role_types.tank] = {
        DEATHKNIGHT = "Death Knight",
        DEMONHUNTER = "Demon Hunter",
        DRUID = "Druid",
        MONK = "Monk",
        PALADIN = "Paladin",
        WARRIOR = "Warrior"
    },
    [NastrandirRaidTools.role_types.heal] = {
        DRUID = "Druid",
        MONK = "Monk",
        PALADIN = "Paladin",
        PRIEST = "Priest",
        SHAMAN = "Shaman"
    },
    [NastrandirRaidTools.role_types.melee] = {
        DEATHKNIGHT = "Death Knight",
        DEMONHUNTER = "Demon Hunter",
        DRUID = "Druid",
        HUNTER = "Hunter",
        MONK = "Monk",
        PALADIN = "Paladin",
        ROGUE = "Rogue",
        SHAMAN = "Shaman",
        WARRIOR = "Warrior"
    },
    [NastrandirRaidTools.role_types.ranged] = {
        DRUID = "Druid",
        HUNTER = "Hunter",
        MAGE = "Mage",
        PRIEST = "Priest",
        SHAMAN = "Shaman",
        WARLOCK = "Warlock"
    }
}
NastrandirRaidTools.classes[NastrandirRaidTools.role_types.dps] = NastrandirRaidTools.classes[NastrandirRaidTools.role_types.all]
NastrandirRaidTools.classes[NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.classes[NastrandirRaidTools.role_types.all]
NastrandirRaidTools.classes[NastrandirRaidTools.role_types.none] = NastrandirRaidTools.classes[NastrandirRaidTools.role_types.all]

---------------------- Class roles ----------------------
NastrandirRaidTools.class_roles = {
    DEATHKNIGHT = {
        [NastrandirRaidTools.role_types.tank] = NastrandirRaidTools.role_types.tank,
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.tank,
            NastrandirRaidTools.role_types.melee
        }
    },
    DEMONHUNTER = {
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.tank,
            NastrandirRaidTools.role_types.melee
        }
    },
    DRUID = {
        [NastrandirRaidTools.role_types.tank] = NastrandirRaidTools.role_types.tank,
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.heal] = NastrandirRaidTools.role_types.heal,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.tank,
            NastrandirRaidTools.role_types.melee,
            NastrandirRaidTools.role_types.ranged,
            NastrandirRaidTools.role_types.heal
        }

    },
    HUNTER = {
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.melee,
            NastrandirRaidTools.role_types.ranged
        }
    },
    MAGE = {
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.ranged
        }
    },
    MONK = {
        [NastrandirRaidTools.role_types.tank] = NastrandirRaidTools.role_types.tank,
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.heal] = NastrandirRaidTools.role_types.heal,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.tank,
            NastrandirRaidTools.role_types.melee,
            NastrandirRaidTools.role_types.heal
        }
    },
    PALADIN = {
        [NastrandirRaidTools.role_types.tank] = NastrandirRaidTools.role_types.tank,
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.heal] = NastrandirRaidTools.role_types.heal,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.tank,
            NastrandirRaidTools.role_types.melee,
            NastrandirRaidTools.role_types.heal
        }
    },
    PRIEST = {
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.heal] = NastrandirRaidTools.role_types.heal,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.ranged,
            NastrandirRaidTools.role_types.heal
        }
    },
    ROGUE = {
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.melee
        }
    },
    SHAMAN = {
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.heal] = NastrandirRaidTools.role_types.heal,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.melee,
            NastrandirRaidTools.role_types.ranged,
            NastrandirRaidTools.role_types.heal
        }
    },
    WARLOCK = {
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.ranged,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.ranged
        }
    },
    WARRIOR = {
        [NastrandirRaidTools.role_types.tank] = NastrandirRaidTools.role_types.tank,
        [NastrandirRaidTools.role_types.damager] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.none] = NastrandirRaidTools.role_types.melee,
        [NastrandirRaidTools.role_types.all] = {
            NastrandirRaidTools.role_types.tank,
            NastrandirRaidTools.role_types.melee
        }
    }
}

---------------------- Class colors ----------------------
NastrandirRaidTools.class_colors = {
    ["DEATHKNIGHT"] = {
        background = {0.77, 0.12, 0.23, 1},
        foreground = {1, 1, 1, 1}
    },
    ["DEMONHUNTER"] = {
        background = {0.64, 0.19, 0.79, 1},
        foreground = {1, 1, 1, 1}
    },
    ["DRUID"] = {
        background = {1, 0.49, 0.04, 1},
        foreground = {1, 1, 1, 1}
    },
    ["HUNTER"] = {
        background = {0.67, 0.83, 0.45, 1},
        foreground = {1, 1, 1, 1}
    },
    ["MAGE"] = {
        background = {0.25, 0.78, 0.92, 1},
        foreground = {1, 1, 1, 1}
    },
    ["MONK"] = {
        background = {0, 1, 0.59, 1},
        foreground = {1, 1, 1, 1}
    },
    ["PALADIN"] = {
        background = {0.96, 0.55, 0.73, 1},
        foreground = {1, 1, 1, 1}
    },
    ["PRIEST"] = {
        background = {1, 1, 1, 1},
        foreground = {1, 1, 1, 1}
    },
    ["ROGUE"] = {
        background = {1, 0.96, 0.41, 1},
        foreground = {1, 1, 1, 1}
    },
    ["SHAMAN"] = {
        background = {0, 0.44, 0.87, 1},
        foreground = {1, 1, 1, 1}
    },
    ["WARLOCK"] = {
        background = {0.53, 0.53, 0.93, 1},
        foreground = {1, 1, 1, 1}
    },
    ["WARRIOR"] = {
        background = {0.78, 0.61, 0.43, 1},
        foreground = {1, 1, 1, 1}
    }
}
