local credits = setmetatable({}, {__index = _G})

function credits:init(script)
    -- add a divider for other
    script.root:divider("Other")

    -- add credits to the menu
    script:add(
        script.root:list("Credits", {}, "Credits for the script"),
        "credits"
    )

    -- add resources divider
    script.credits:divider("Resources")

    -- add root-cause to the menu
    script.credits:hyperlink("Root-Cause", "https://github.com/root-cause/v-decompiled-scripts", "Provided updated decomiled scripts for latest patch (1.64) which is where most of the globals used in this script came from")

    -- add unknowncheats to the menu
    script.credits:hyperlink("UnknownCheats", "https://www.unknowncheats.me/forum/grand-theft-auto-v/500059-globals-locals-discussion-read-page-1-a-5.html", "Has a bunch of other useful globals and locals that didn\'t get around to finding myself")

    -- add docs.fivem to the menu
    script.credits:hyperlink("FiveM docs", "https://docs.fivem.net/docs/game-references/", "Has a list of all the controls (used for afk functionality) and blip ids used in the script")

    -- add nativedb
    script.credits:hyperlink("NativeDB", "https://nativedb.dotindustries.dev/natives", "Provided an enormous list of natives that were used in the script")

    -- add a divider for other
    script.credits:divider("Other")

    -- add heist control credit
    script.credits:hyperlink("IceDoomfist#0001", "https://github.com/IceDoomfist/Stand-Heist-Control", "Most of the features in heists recovery menu are from Heist Control")

    -- add a divider for discord
    script.credits:divider("Discord", "discord")

    -- add discord link to the menu
    script.credits:hyperlink("Discord", "https://discord.gg/bx8WEZQa49", "Join the discord to report bugs")

    -- add developer to the menu
    script.credits:hyperlink("Mr.Robot#1019", "https://github.com/4d72526f626f74/Stand-Recovery", "Script Developer")
end

return credits