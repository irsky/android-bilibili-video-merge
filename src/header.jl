module Header

export BASE_DIR
export PART_VIDEO_NAME
export PART_AUDIO_NAME
export JSON_FILE_NAME
export COVER_FILE_NAME
export OUTPUT_PATH
export OUTPUT_TUMP_DIR
export LOG_PATH
export MATCH_PATH_FOR_SHELLSTYLE
export BILIBILI_CACHE_DIR
export File, Dir, push_path!, pull_path


start = time()

const BASE_DIR = dirname(@__DIR__)
const PART_VIDEO_NAME = "video.m4s"
const PART_AUDIO_NAME = "audio.m4s"
const JSON_FILE_NAME = "entry.json"
const COVER_FILE_NAME = "cover.jpg"
# 输出视频目录

# 日志目录
const LOG_PATH = joinpath(BASE_DIR, "log")
const MATCH_PATH_FOR_SHELLSTYLE = "[0-9]*/c_[0-9]*/[0-9]*"


# 路径的创建 要限定范围  不能超出项目之外
# 这两个结构 应该要保证路径或文件有效性  只要创建就有效
# 比如更改了路径 那么就要自动确保路径有效
# 如果路径不存在 那么就创建

module Internal
mutable struct File 
    path::String
end
mutable struct Dir 
    path::String 
end
end

const File = Internal.File
const Dir = Internal.Dir

function push_path!(file::File, newpath::String)
    file.path = newpath
end

function push_path!(dir::Dir, newpath::String)
    dir.path = newpath
end

function pull_path(file::File)::String
    if isfile(file.path)
        @warn (file.path, "The file already exists. ")
    else 
        open(file.path, "w") do f end
    end
    return file.path
end

function pull_path(dir::Dir)::String
    if isdir(dir.path)
        @warn dir.path, "The directory already exists. "
    else
        mkpath(dir.path)
    end
    return dir.path
end



const OUTPUT_PATH = let 
    path = joinpath(BASE_DIR, "output")
    if !isdir(path)
        mkdir(path)
    end
    path
end
const OUTPUT_TUMP_DIR = joinpath(OUTPUT_PATH, "temp")


end




