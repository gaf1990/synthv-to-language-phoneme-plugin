SCRIPT_TITLE = "To Language Phonemes"

function getClientInfo()
    return {
        name = "To Language Phonemes",
        category = "Phoneme Converters",
        author = "Giuseppe Andrea Ferraro",
        versionNumber = 0,
        minEditorVersion = 0
    }
end

function main()
    local OS = determine_OS()
    local script_folder_name = determine_scriptFolder(OS)
    fileName = script_folder_name .. "\\" .. "it_morpher.log"
    log ("OS: " .. OS)

    local langCodes = { "IT" }

    local myForm = {
        title = "Choose Language",
        message = "Please choose language",
        buttons = "OkCancel",
        widgets = {
            {
                name = "cb1",
                type = "ComboBox",
                label = "Language",
                choices = { "Italian"},
                default = 0
            }
        }
    }

    local result = SV:showCustomDialog(myForm)

    if tostring(result.status) == "true" then
        local language = langCodes[result.answers.cb1 + 1]
        log ("Language: " .. language)

        log("Start processing rules ")
        ipaRules = loadIPARules(script_folder_name, language, OS)
        dreamRules = loadDreamRules(script_folder_name, language, OS);
        log("End processing rules ")

        log("Start processing notes ")
        local selection = SV:getMainEditor():getSelection()
        local selectedNotes = selection:getSelectedNotes()
        local scope = SV:getMainEditor():getCurrentGroup()
        local group = scope:getTarget()
        for i = 1, #selectedNotes do
            local note = selectedNotes[i]
            local lyric = note:getLyrics()
            if lyric ~= " " then
                local ipaLyric = convertToIPA(lyric)
                local dreamMap = convertToDream(ipaLyric)
                log("Lyric " .. lyric .. " --> IPA: ".. ipaLyric .. " --> Dream: " .. logElement(dreamMap))

                if dreamMap then
                    local durationPerSubNote = note:getDuration() / #dreamMap
                    local pitchPerSubNote = note:getPitch()
                    local startOnset = note:getOnset()
                    local index = note:getIndexInParent()
                    local n = 0
                    group:removeNote(index)
                    for _, entry in ipairs(dreamMap) do
                        local phonemes = entry[1]
                        local language = entry[2]
                        if language == nil then
                            language = "UNK"
                        end
                        local originalLyric = entry[3]
                        log("Apply " .. phonemes .. " to " .. originalLyric .. " with " .. language)

                        local newNote = SV:create("Note")
                        newNote:setPitch(pitchPerSubNote)
                        newNote:setLanguageOverride(getLanguageOverride(language))
                        newNote:setTimeRange(startOnset + durationPerSubNote*n, durationPerSubNote);
                        newNote:setLyrics("." .. phonemes)
                        group:addNote(newNote)
                        n = n + 1;
                    end
                end
            end
        end
    else
        SV:showMessageBox("File path", "Exit")
    end
    SV:finish()
end

function determine_OS()
    local hostinfo = SV:getHostInfo()
    return hostinfo.osType
end

function determine_scriptFolder(OS)
    if OS ~= "Windows" then
        local path = "/Library/Application Support/Dreamtonics/Synthesizer V Studio/scripts/"
        if folder_exists(path, OS) then
            return path
        end
    else
        local userProfile = os.getenv("USERPROFILE")
        if userProfile then
            local docfolder = userProfile .. "\\Documenti\\Dreamtonics\\Synthesizer V Studio\\scripts\\Utilities\\"
            if folder_exists(docfolder, OS) then
                return docfolder
            else
                docfolder = userProfile .. "\\OneDrive\\Documenti\\Dreamtonics\\Synthesizer V Studio\\scripts\\Utilities\\"
                if folder_exists(docfolder, OS) then
                    return docfolder
                else
                    return SV:showInputBox("Script path", "Cannot find automatically the script path. Please insert the full path here:", "Script path")
                end
            end
        else
            return SV:showInputBox("Script path", "Cannot find user profile. Please insert the full path here:", "Script path")
        end
    end
end



function loadIPARules(folder, language, OS)
    local ipaRules = {}
    local separator = OS == "Windows" and "\\" or "/"
    local filePath = folder .. "languages" .. separator .. language .. ".dic"
    local file = io.open(filePath, "r")
    log ("Open IPA rule file " .. filePath)

    if file then
        local ruleType, ruleSymbol, excludedSymbol = "", "", ""
        for line in file:lines() do
            if line:sub(1, 2) == "//" then
                local heading = line:sub(3):gsub("^%s*(.-)%s*$", "%1")
                local parts = split(heading, " ")
                ruleType = parts[1]
                local symbolParts = split(parts[2], ",")
                ruleSymbol = symbolParts[1]
                excludedSymbol = symbolParts[2]
            elseif #line > 0 then
                local ruleElements = {}
                for element in line:gsub("%s+", ""):gmatch("[^,]+") do
                    table.insert(ruleElements, element)
                end
                local ipaRule = {
                    ruleType = ruleType,
                    sourcePattern = ruleElements[1],
                    targetPattern = ruleElements[2],
                    ruleSymbol = ruleSymbol,
                    excludedSymbol = excludedSymbol,
                    excludedPattern = ruleElements[3] and { ruleElements[3]:match("[^|]+") } or {}
                }
                table.insert(ipaRules, ipaRule)
            end
        end
        file:close()
    else
        error("Error loading rules file: " .. tostring(filePath))
    end
    return ipaRules
end

function loadDreamRules(folder,language,OS)

    local dreamRules = {}
    local separator = OS == "Windows" and "\\" or "/"
    local filePath = folder .. "languages" .. separator .. language .. "-dream.dic"
    local file = io.open(filePath, "r")
    log ("Open dream rule file " .. filePath)

    if file then
        local ruleType, ruleSymbol, excludedSymbol = "", "", ""
        for line in file:lines() do
            local dreamRule = {}
            local ruleElement = {}

            for part in line:gmatch("([^,]+)") do
                table.insert(ruleElement, part)
            end

            dreamRule.original = ruleElement[1]

            -- Separa le lingue e i simboli
            local languages = ruleElement[2]
            local languageMaps = {}

            -- Dividi per linguaggio e simbolo
            for l in languages:gmatch("[^|]+") do
                local symbol, lang = l:match("([^:]+):([^:]+)")
                if symbol and lang then
                    languageMaps[lang] = symbol
                end
            end

            dreamRule.languages = languageMaps
            table.insert(dreamRules, dreamRule)
        end
    end
    return dreamRules
end


function convertToIPA(lyric)
    local lyricTrans = lyric;
    for _, ipaRule in ipairs(ipaRules) do
        if string.match(lyric, ipaRule.sourcePattern) then
            local currentTargetPattern = ipaRule.targetPattern
            local currentRuleType = ipaRule.ruleType
            if checkExcludedPattern(lyric, ipaRule.excludedPattern) then
                currentTargetPattern = string.gsub(ipaRule.targetPattern, ipaRule.ruleSymbol, ipaRule.excludedSymbol)
                currentRuleType = ipaRule.ruleType .. "_ECC"
            end
            -- Sostituisci la parola con il pattern di destinazione
            lyricTrans = string.gsub(lyricTrans, ipaRule.sourcePattern, currentTargetPattern)
        end
    end
    return lyricTrans
end


function checkExcludedPattern(word, excludedPattern)
    if excludedPattern ~= nil then
        for _, pattern in ipairs(excludedPattern) do
            if string.match(word, pattern) then
                return true
            end
        end
    end
    return false
end


function utf8_char_length(first_byte)
    if first_byte >= 0 and first_byte <= 127 then
        return 1 -- 1 byte
    elseif first_byte >= 192 and first_byte <= 223 then
        return 2 -- 2 byte
    elseif first_byte >= 224 and first_byte <= 239 then
        return 3 -- 3 byte
    elseif first_byte >= 240 and first_byte <= 247 then
        return 4 -- 4 byte
    else
        return 1 -- carattere non valido, considerato 1 byte
    end
end

-- Funzione per convertire la stringa in DREAM
function convertToDream(lyric)
    local result = {}
    local i = 1

    while i <= #lyric do
        local first_byte = string.byte(lyric, i)
        local char_length = utf8_char_length(first_byte)
        local c = lyric:sub(i, i + char_length - 1)

        local found = false -- Variabile per verificare se abbiamo trovato una corrispondenza

        for _, dr in ipairs(dreamRules) do
            local original = dr.original
            if c == original then
                local language = getLanguage(dr.languages)
                local convertedChar = dr.languages[language]

                if convertedChar then
                    if #result > 0 and result[#result][2] == language then
                        -- Se l'ultima voce ha la stessa lingua, uniamo i caratteri
                        result[#result][1] = result[#result][1] .. " " .. convertedChar
                        result[#result][3] = result[#result][3] .. c
                    else
                        -- Aggiungiamo un nuovo elemento se la lingua è diversa
                        table.insert(result, {convertedChar, language, c})
                    end
                    found = true
                else
                    -- Se non c'è una conversione, possiamo decidere di non aggiungere nulla
                    if #result > 0 and result[#result][2] == nil then
                        result[#result][1] = result[#result][1] .. " " .. c -- Aggiungi il carattere originale
                        result[#result][3] = result[#result][3] .. c
                    else
                        table.insert(result, {c, nil, c}) -- Aggiungi il carattere originale con nil
                    end
                    found = true
                end
                break
            end
        end

        -- Se non abbiamo trovato alcuna corrispondenza, possiamo anche aggiungere il carattere originale
        if not found then
            if #result > 0 and result[#result][2] == nil then
                result[#result][1] = result[#result][1] .. c -- Uniamo carattere originale
                result[#result][3] = result[#result][3] .. c
            else
                table.insert(result, {c, nil, c}) -- Aggiungi il carattere originale con nil
            end
        end

        i = i + char_length
    end

    return #result > 0 and result or nil -- Restituisci la tabella o nil se vuota
end

function getLanguage(languages)
    local result = languages["CAN"]
    if result ~= nil then
        return "CAN"
    end

    result = languages["SPA"]
    if result ~= nil then
        return "SPA"
    end

    result = languages["ING"]
    if result ~= nil then
        return "ING"
    end

    result = languages["GIA"]
    if result ~= nil then
        return "GIA"
    end

    result = languages["MAN"]
    if result ~= nil then
        return "MAN"
    end

    return nil
end

function getLanguageOverride(language)
    if language == "CAN" then
        return "cantonese"
    end
    if language == "SPA" then
        return "spanish"
    end
    if language == "JAP" then
        return "japanese"
    end
    if language == "ENG" then
        return "english"
    end
    if language == "MAN" then
        return "mandarine"
    end
    return "japanese"
end

function logElement(t)
    local result = ""
    for key, value in pairs(t) do
        if type(value) == "table" then
            result = result .. key .. ": {"
            result = result .. logElement(value) .. "} "
        else
            result = result .. key .. ": " .. tostring(value) .. " "
        end
    end
    return result;
end

function log(msg)
    local fp = io.open(fileName, "a")
    local str = string.format("[%-6s%s] %s - %s\n",
            "Logger ", os.date(), "INFO ", msg)
    fp:write(str)
    fp:close()
end

function exists(file)
    local isok, errstr, errcode = os.rename(file, file)
    if isok == nil then
        if errcode == 13 then
            return true -- Permission denied, but it exists
        end
        return false
    end
    return true
end

function folder_exists(foldername, OS)
    if OS ~= "Windows" then
        if foldername:sub(-1) ~= "/" then foldername = foldername .. "/" end
    else
        if foldername:sub(-1) ~= "\\" then foldername = foldername .. "\\" end
    end
    return exists(foldername)
end

function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function file_is_writable(name)
    local f = io.open(name, "w")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end

function lines_from(file)
    if not file_exists(file) then return {} end
    local filelines = {}
    for line in io.lines(file) do
        filelines[#filelines + 1] = line
    end
    return filelines
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s" -- Se il separatore non è specificato, utilizza gli spazi
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end