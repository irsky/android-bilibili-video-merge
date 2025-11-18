using Glob: glob
using Dates: now, time

start = time()

const BASE_DIR = @__DIR__
const BILIBILI_CACHE_DIR = joinpath(BASE_DIR, "bilibili的视频缓存文件")
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


"""
return curr_path下面所有名称 符合正则参数的 文件夹
"""
function select_dirs(regular::Regex, curr_path::String)
    dirs = filter(isdir, glob("*", curr_path))
    dirs = filter(d -> occursin(regular, basename(d)), dirs)
    return map(dir -> basename(dir), dirs)
end

"""
"""
function create_if_not_exist(path::String)
    
end


# 合并音频和视频文件
merge_audio_video(readpath::String, output_path::String) = let
    audio_file = joinpath(readpath, PART_AUDIO_NAME)
    video_file = joinpath(readpath, PART_VIDEO_NAME)
    foreach([audio_file, video_file]) do f
        if !isfile(f)
            @error "文件不存在: $f"
            # 跳过的路径将写在日志文件里
            return false
        end
    end
    output_file = joinpath(output_path, OUTPUT_FILE_NAME)
    # 这里先要判断 有没有那个数字文件夹
    !ispath(output_path) && mkpath(output_path)
    # 再判断有没有数字文件夹下面那个output.mp4文件
    @info output_file
    if ispath(output_file)
        @warn "输出文件已存在 : $output_file, 将另外命名为 output_new_(时间).mp4"
        output_file = replace(output_file, r"\.mp4$" => string("_new_", now(), ".mp4"))
    end
    command = `ffmpeg -i $video_file -i $audio_file -c:v copy -c:a aac -strict experimental $output_file`
    read(command, String)
end


begin
    # 获取所有纯数字目录
    numeric_dirs_basename = select_dirs(REGEX_NUM_DIR, BILIBILI_CACHE_DIR)

    tasks = 1:length(numeric_dirs_basename)
    # 均分任务
    chunks = [tasks[i:NUM_THREADS:end] for i in 1:NUM_THREADS]
    thread_tasks = []

    for chunk in chunks
        # 遍历每个纯数字目录
        task = Threads.@spawn for (index, ndbi) in enumerate(chunk)
            here_path = joinpath(BILIBILI_CACHE_DIR, numeric_dirs_basename[ndbi])
            # 每次循环都回到初始路径 选择名称为纯数字的目录, c_dir, 数字文件夹
            c_dir_basename = first(select_dirs(REGEX_C_NUM_DIR, here_path))

            here_path = joinpath(here_path, c_dir_basename)
            small_num_dir_basename = first(select_dirs(REGEX_NUM_DIR, here_path))

            # 一步到位 直接进入最终的文件存放地
            here_path = joinpath(here_path, small_num_dir_basename)
            output_path = joinpath(OUTPUT_PATH, numeric_dirs_basename[ndbi])
            
            merge_audio_video(here_path, output_path)
            
            @info "当前处理目录: ", pwd()
            # index >= 1 && break
        end
        push!(thread_tasks, task)

    end

    # 等待完成
    for t in thread_tasks
        fetch(t)
    end

    # 20.32 秒
    # 46.88 秒
    # 4 个 27 秒
    # 6 个 20.38 秒

end

elapsed = time() - start
@info "总共耗时 $(round(elapsed, digits=2)) 秒"









