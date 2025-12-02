using Glob: glob
using Dates: now
import Folds
using JSON

include(joinpath(@__DIR__, "header.jl"))
include("tail.jl")
using .Header
using .Tail


const fmap = Folds.map
# 所有的目标文件夹, 第二层的全数字文件夹

const BILIBILI_CACHE_DIR = let
    path = joinpath(BASE_DIR, "default-bilibilivideo-cachefiles")
    # path = ""
    while !isdir(path)
        @info "输入'exit()'退出任务, 不是目录, 请输入bilibili的视频缓存文件夹路径: "
        path = readline(stdin)
        if path == "exit()"
            error("用户没有给到bilibili视频缓存文件夹所在路径, 任务退出")
        end
    end
    path
end

paths = glob(MATCH_PATH_FOR_SHELLSTYLE, BILIBILI_CACHE_DIR)

"""
合并音频和视频文件
# 这里还有个事情  就是如果cover.jpg 存在就作为封面合入. 如果不存在 那就把视频的第一帧作为封面
"""
function merge_audio_video(videofile::File, audiofile::File, outputdir::Dir, coverfile::File, metainfofile::File)
    if !isfile(pull_path(coverfile))
        # 这里如果没有这个封面文件,  那就把视频的第一帧作为封面, 用ffmpeg 分步命令
        @warn "$(pull_path(coverfile)) 不存在, 将抽取视频第一帧作为封面预览图"
        push_path!(coverfile, joinpath(OUTPUT_TUMP_DIR, "cover_$(now()).jpg"))
        command = `ffmpeg -i $(pull_path(videofile)) -frames:v 1 $(pull_path(coverfile))`
        run(command)
    end

    # 解析jsonfile的数据作为元信息
    data = Dict(JSON.parsefile(pull_path(metainfofile)))
    entrygets = [
        ("title", data["title"]),
        ("artist", data["owner_name"]),
        ("description", string("downloaded_bytes: $(data["downloaded_bytes"])\t", 
            "total_time_milli: $(data["total_time_milli"])\t", 
            "quality_pithy_description: $(data["quality_pithy_description"])"))
    ]
    outputfile = joinpath(pull_path(outputdir), "output_$(entrygets[1][2])_$(now()).mp4")
    command = `ffmpeg 
        -i $(pull_path(videofile)) 
        -i $(pull_path(audiofile)) 
        -i $(pull_path(coverfile))
        -c:v copy 
        -c:a aac
        -map 0:v:0
        -map 1:a:0
        -map 2:v:0
        -disposition:v:1 attached_pic
        -metadata "$(entrygets[1][1])"="$(entrygets[1][2])"
        -metadata "$(entrygets[2][1])"="$(entrygets[2][2])"
        -metadata "$(entrygets[3][1])"="$(entrygets[3][2])"
        -strict experimental $outputfile
        `
    run(command)
end
 
res = fmap(paths) do path
    cover_file = File(joinpath(dirname(path), COVER_FILE_NAME))
    # @info cover_file
    videofile = File(joinpath(path, PART_VIDEO_NAME))
    audiofile = File(joinpath(path, PART_AUDIO_NAME))
    metainfofile = File(joinpath(dirname(path), JSON_FILE_NAME))
    if isfile(pull_path(audiofile)) && isfile(pull_path(videofile))
        merge_audio_video(videofile, audiofile, Dir(OUTPUT_PATH), cover_file, metainfofile)
    else
        @warn "$(pull_path(audiofile)) or $(pull_path(videofile))  不存在, 该视频合成已经取消"
    end
end


Tail.tail(Header.start)










