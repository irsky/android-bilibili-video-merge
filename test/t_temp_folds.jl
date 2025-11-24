

using Glob: glob
using Dates: now, time
using Folds

start = time()

const BASE_DIR = dirname(@__DIR__)
const BILIBILI_CACHE_DIR = joinpath(BASE_DIR, "bilibili的视频缓存文件")
const PART_VIDEO_NAME = "video.m4s"
const PART_AUDIO_NAME = "audio.m4s"
const OUTPUT_FILE_NAME = "output.mp4"
const REGEX_C_NUM_DIR = r"^c_\d+$"
const REGEX_NUM_DIR = r"^\d+$"
const REGEX_PURPOSE_PATH = Regex("\\Q$BILIBILI_CACHE_DIR\\E/\\d+/c_\\d+/\\d+/")
# 输出视频目录
const OUTPUT_PATH = joinpath(BASE_DIR, "output")
# 日志目录
const LOG_PATH = joinpath(BASE_DIR, "log")
const NUM_THREADS = Threads.nthreads()



"""
return curr_path下面所有名称 符合正则参数的 文件夹
"""
function select_dirs(regular::Regex, curr_path::String)
    dirs = filter(isdir, glob("*", curr_path))
    dirs = filter(d -> occursin(regular, basename(d)), dirs)
    return map(dir -> basename(dir), dirs)
end


function cd_find_aimfile(num_dir_basename::String)::Tuple{String, String}
    here_path = joinpath(BILIBILI_CACHE_DIR, num_dir_basename)
    # 每次循环都回到初始路径 选择名称为纯数字的目录, c_dir, 数字文件夹
    c_dir_basename = first(select_dirs(REGEX_C_NUM_DIR, here_path))

    here_path = joinpath(here_path, c_dir_basename)
    small_num_dir_basename = first(select_dirs(REGEX_NUM_DIR, here_path))

    # 一步到位 直接进入最终的文件存放地
    readpath = joinpath(here_path, small_num_dir_basename)
    file1, file2 = map([PART_AUDIO_NAME, PART_VIDEO_NAME]) do fname
        path = joinpath(readpath, fname)
        if !isfile(path)
            error("文件不存在: $path" )
            # 跳过的路径将写在日志文件里
        end
        path
    end
    return (file1, file2)
end


"""
合并音频和视频文件
"""
function merge_audio_video(audiofile::String, videofile::String, outputpath::String)
    # 这里先要判断 有没有那个数字文件夹
    !ispath(outputpath) && mkpath(outputpath)
    outputfile = joinpath(outputpath, OUTPUT_FILE_NAME)
    # 再判断有没有数字文件夹下面那个output.mp4文件
    #@info outputfile
    if ispath(outputfile)
        #@warn "输出文件已存在 : $outputfile, 将另外命名为 output_new_(时间).mp4"
        outputfile = replace(outputfile, r"\.mp4$" => string("_new_", now(), ".mp4"))
    end
    command = `ffmpeg -i $videofile -i $audiofile -c:v copy -c:a aac -strict experimental $outputfile`
    #read(command, String)
    run(command)
end


begin
    # 获取所有纯数字目录
    numeric_dirs_basename = select_dirs(REGEX_NUM_DIR, BILIBILI_CACHE_DIR)
    res = Folds.map(numeric_dirs_basename) do ndb
        audiofile, videofile = cd_find_aimfile(ndb)
        output_path = joinpath(OUTPUT_PATH, ndb)
        merge_audio_video(audiofile, videofile, output_path)
        # @info "当前处理目录: ", pwd()
        # index >= 1 && break
    end

    # 20.32 秒
    # 46.88 秒
    # 4 个 27 秒
    # 6 个 20.38 秒
end


elapsed = time() - start
@info "总共耗时 $(round(elapsed, digits=2)) 秒"









