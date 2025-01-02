
-- Don't touch me
PerformHttpRequest('https://raw.githubusercontent.com/99wpx/ggwpx-version/refs/heads/main/versions.json', function(_, res)
    local resName = GetCurrentResourceName()  
    local resPrefix = "^3["..resName.."]^"   

    print("^3-------------------- GGWPx - Version Check --------------------")
    print(resPrefix.."1 Checking for updates...^7") 

    if not res then 
        print(resPrefix.."1 Failed to check for updates^7") 
        return 
    end

    local result = json.decode(res)  
    local currentVersion = GetResourceMetadata(resName, 'version', 0)
    local latestVersion = result[resName]

    if currentVersion ~= latestVersion then
        print(resPrefix.."1 New version ^3"..latestVersion.."^1 of the script is available^7")
        print(resPrefix.."1 You are currently using version ^3"..currentVersion.."^7")
        print(resPrefix.."1 You can download it from ^3https://github.com/99wpx^7")
        print(resPrefix.."1 Join discord ^3https://discord.gg/Q6AbZgkJFq^7")
    else
        print(resPrefix.."2 You have the latest version of the script: ^3"..currentVersion.."^7")
        print(resPrefix.."2 Join discord ^3https://discord.gg/Q6AbZgkJFq^7")  
    end

    print("^3-------------------- GGWPx - Version Check --------------------^7")  
end)
