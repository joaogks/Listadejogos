-- Runs inside DaVinci Resolve: Workspace > Scripts > Cartoon Jazz - Import and Render Batch.
-- Builds timelines through Resolve's native media pool API.

local root = [[D:\BLACK AND WHITE CARTOON\remotion-cartoon-jazz]]
local output_root = root .. [[\outputs]]
local project_name = "Cartoon Jazz - Ten Video Batch"
local slugs = {
    "01-old-school-cartoons-jazz-2-hour-cozy-noir",
    "02-vintage-cartoon-jazz-cafe-rainy-night",
    "03-old-cartoons-after-dark-slow-sax",
    "04-owls-old-school-cartoon-jazz-club",
    "05-old-school-cartoon-jazz-mellow-clarinet",
    "06-coffee-before-the-final-reel",
    "07-lights-out-band-still-playing-noir",
    "08-the-projector-hummed-along",
    "09-old-school-cartoon-ragtime",
    "10-the-owls-last-encore",
}
local status_path = output_root .. [[\resolve-batch-status.txt]]

local function report(message)
    local line = os.date("%Y-%m-%d %H:%M:%S") .. "  " .. message
    print(line)
    local file = assert(io.open(status_path, "a"))
    file:write(line, "\n")
    file:close()
end

local function require_result(value, message)
    if not value then error(message, 2) end
    return value
end

local function has_items(items)
    return items and next(items) ~= nil
end

local function existing_project(project_manager)
    local current = project_manager:GetCurrentProject()
    if current and current:GetName() == project_name then return current end

    local list = project_manager:GetProjectListInCurrentFolder() or {}
    for key, value in pairs(list) do
        if key == project_name or value == project_name then
            if current then project_manager:SaveProject() end
            return require_result(project_manager:LoadProject(project_name), "Falha ao abrir o projeto de lote.")
        end
    end

    if current and current:GetTimelineCount() == 0 then
        local folder = current:GetMediaPool():GetRootFolder()
        if not has_items(folder:GetClipList()) and not has_items(folder:GetSubFolderList()) then
            require_result(current:SetName(project_name), "Falha ao renomear o projeto vazio.")
            return current
        end
    end

    if current then require_result(project_manager:SaveProject(), "Falha ao salvar o projeto aberto.") end
    return require_result(project_manager:CreateProject(project_name), "Falha ao criar o projeto de lote.")
end

local function timeline_named(project, name)
    for index = 1, project:GetTimelineCount() do
        local timeline = project:GetTimelineByIndex(index)
        if timeline and timeline:GetName() == name then return timeline end
    end
    return nil
end

local function read_plan(slug)
    local path = output_root .. "\\" .. slug .. "\\resolve\\resolve-api-plan.tsv"
    local file = require_result(io.open(path, "rb"), "Plano ausente: " .. path)
    local rows = {}
    for line in file:lines() do
        local kind, source, offset, start_frame, duration, track, name =
            line:match("^([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t([^\t]+)\t(.*)$")
        require_result(kind, "Linha invalida no plano: " .. slug)
        rows[#rows + 1] = {
            kind = kind, source = source, offset = tonumber(offset), start_frame = tonumber(start_frame),
            duration = tonumber(duration), track = tonumber(track), name = name,
        }
    end
    file:close()
    require_result(#rows > 50, "Plano incompleto: " .. slug)
    return rows
end

local function timeline_complete(timeline, rows)
    if not timeline then return false end
    local duration = 0
    for _, row in ipairs(rows) do duration = math.max(duration, row.offset + row.duration) end
    if timeline:GetEndFrame() - timeline:GetStartFrame() < duration - 1 then return false end
    local items = 0
    for _, track_type in ipairs({"video", "audio"}) do
        for index = 1, timeline:GetTrackCount(track_type) do
            items = items + #(timeline:GetItemListInTrack(track_type, index) or {})
        end
    end
    return items >= #rows
end

local function build_timeline(project, slug, rows, media_cache)
    local pool = project:GetMediaPool()
    local old = timeline_named(project, slug)
    if timeline_complete(old, rows) then
        report("Timeline pronta: " .. slug)
        return old
    end
    if old then
        require_result(pool:DeleteTimelines({old}), "Falha ao remover timeline incompleta: " .. slug)
    end
    local timeline = require_result(pool:CreateEmptyTimeline(slug), "Falha ao criar timeline: " .. slug)
    require_result(project:SetCurrentTimeline(timeline), "Falha ao ativar timeline: " .. slug)
    require_result(timeline:SetStartTimecode("00:00:00:00"), "Falha ao definir timecode inicial: " .. slug)
    while timeline:GetTrackCount("video") < 4 do
        require_result(timeline:AddTrack("video"), "Falha ao criar pista de video: " .. slug)
    end
    while timeline:GetTrackCount("audio") < 1 do
        require_result(timeline:AddTrack("audio"), "Falha ao criar pista de audio: " .. slug)
    end
    report("Montando " .. slug .. ": " .. tostring(#rows) .. " itens.")
    for index, row in ipairs(rows) do
        local item = media_cache[row.source]
        if not item then
            local imported
            if row.kind == "fade" then
                imported = pool:ImportMedia({{
                    FilePath = row.source, StartIndex = 0, EndIndex = row.duration - 1,
                }})
            else
                imported = pool:ImportMedia({row.source})
            end
            item = require_result(imported and imported[1], "Falha ao importar midia: " .. row.source)
            media_cache[row.source] = item
        end
        local placed = pool:AppendToTimeline({{
            mediaPoolItem = item,
            startFrame = row.start_frame,
            endFrame = row.start_frame + row.duration - 1,
            mediaType = row.kind == "audio" and 2 or 1,
            trackIndex = row.track,
            recordFrame = row.offset,
        }})
        require_result(placed and placed[1], "Falha ao posicionar item " .. tostring(index) .. " (" .. row.name .. ")")
        if row.kind == "video" then placed[1]:SetProperty("Scaling", 2) end
        if index % 15 == 0 then report("  " .. slug .. ": " .. tostring(index) .. "/" .. tostring(#rows)) end
    end
    require_result(timeline_complete(timeline, rows), "Timeline incompleta: " .. slug)
    report("Timeline pronta: " .. slug)
    return timeline
end

local function choose_h264(project)
    local render_format
    for key, value in pairs(project:GetRenderFormats() or {}) do
        if tostring(key):lower() == "mp4" or tostring(value):lower() == "mp4" then
            render_format = key
            break
        end
    end
    require_result(render_format, "O Resolve nao oferece formato MP4.")

    local codec
    for key, value in pairs(project:GetRenderCodecs(render_format) or {}) do
        if tostring(key):lower():find("h.264", 1, true) or tostring(value):lower() == "h264" then
            codec = value
            break
        end
    end
    require_result(codec, "O Resolve nao oferece H.264 para MP4.")
    require_result(project:SetCurrentRenderFormatAndCodec(render_format, codec), "Falha ao selecionar MP4/H.264.")
    return render_format, codec
end

local function run()
    local status = assert(io.open(status_path, "w"))
    status:close()
    report("Iniciando montagem de 10 timelines no Resolve.")

    for _, slug in ipairs(slugs) do
        local mix_path = output_root .. "\\" .. slug .. "\\resolve\\jazz-mix.m4a"
        local file = require_result(io.open(mix_path, "rb"), "Mix de audio ausente: " .. mix_path)
        file:close()
    end

    local app = resolve or (type(Resolve) == "function" and Resolve())
    require_result(app, "Script sem acesso ao Resolve. Execute pelo menu Workspace > Scripts.")
    local project_manager = require_result(app:GetProjectManager(), "Project Manager indisponivel.")
    local project = existing_project(project_manager)
    report("Projeto: " .. project:GetName())
    if project:GetTimelineCount() == 0 then
        require_result(project:SetSetting("timelineFrameRate", "30"), "Falha ao ajustar projeto para 30 fps.")
        require_result(project:SetSetting("timelineResolutionWidth", "1920"), "Falha ao ajustar largura do projeto.")
        require_result(project:SetSetting("timelineResolutionHeight", "1080"), "Falha ao ajustar altura do projeto.")
    end

    local timelines = {}
    local media_cache = {}
    for _, slug in ipairs(slugs) do
        timelines[slug] = build_timeline(project, slug, read_plan(slug), media_cache)
    end

    app:OpenPage("deliver")
    local render_format, codec = choose_h264(project)
    report("Formato: " .. tostring(render_format) .. "/" .. tostring(codec))
    if project:GetCurrentRenderMode() ~= 1 then
        require_result(project:SetCurrentRenderMode(1), "Falha ao selecionar render de timeline inteira.")
    end

    for _, slug in ipairs(slugs) do
        local timeline = timelines[slug]
        require_result(project:SetCurrentTimeline(timeline), "Falha ao ativar: " .. slug)

        local target_dir = output_root .. "\\" .. slug .. [[\davinci]]
        os.execute('mkdir "' .. target_dir .. '" >nul 2>nul')
        require_result(project:SetRenderSettings({
            TargetDir = target_dir,
            CustomName = slug,
            SelectAllFrames = 1,
            ExportVideo = 1,
            ExportAudio = 1,
            FormatWidth = 1920,
            FormatHeight = 1080,
            FrameRate = 30,
            AudioCodec = "aac",
            AudioSampleRate = 48000,
            ReplaceExistingFilesInPlace = 1,
        }), "Falha nas opcoes de render: " .. slug)
        local job_id = require_result(project:AddRenderJob(), "Falha ao colocar na fila: " .. slug)
        report("Na fila: " .. slug .. " (" .. tostring(job_id) .. ")")
    end

    require_result(project_manager:SaveProject(), "Falha ao salvar o projeto de lote.")
    require_result(project:StartRendering(), "Falha ao iniciar a fila de render.")
    report("Render iniciado no DaVinci Resolve.")
end

local ok, error_message = pcall(run)
if not ok then
    local file = io.open(status_path, "a")
    if file then
        file:write(os.date("%Y-%m-%d %H:%M:%S"), "  ERRO: ", tostring(error_message), "\n")
        file:close()
    end
    print("Cartoon Jazz: " .. tostring(error_message))
end
