using Glob: glob
using Dates: now, time
using Folds


#=
遍历出所有的文件路径
Glob.jl
=#

start = time()

const BASE_DIR = dirname(@__DIR__)
const BILIBILI_CACHE_DIR = joinpath(BASE_DIR, "bilibili的视频缓存文件")
const MATCH_PATH_FOR_SHELLSTYLE = "[0-9]*/c_[0-9]*/[0-9]*"
const PART_VIDEO_NAME = "video.m4s"
const PART_AUDIO_NAME = "audio.m4s"
const OUTPUT_FILE_NAME = "output.mp4"
const REGEX_C_NUM_DIR = r"^c_\d+$"
const REGEX_NUM_DIR = r"^\d+$"

# 输出视频目录
const OUTPUT_PATH = joinpath(BASE_DIR, "output")
# 日志目录
const LOG_PATH = joinpath(BASE_DIR, "log")
const NUM_THREADS = Threads.nthreads()

paths = glob(MATCH_PATH_FOR_SHELLSTYLE, BILIBILI_CACHE_DIR)
foreach(println, paths)

num_dir::String = ""

for path in paths
    part_path = splitpath(path)

end





elapsed = time() - start
@info "总共耗时 $(round(elapsed, digits=2)) 秒"









