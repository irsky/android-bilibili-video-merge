

const BASE_DIR = dirname(@__DIR__)
const BILIBILI_CACHE_DIR = joinpath(BASE_DIR, "bilibili的视频缓存文件")
const REGEX_PURPOSE_PATH = Regex("\\Q$BILIBILI_CACHE_DIR\\E/\\d+/c_\\d+/\\d+/*")




begin
count = 0
aim_dirs = Vector{String}()
for (index, (root, dirs, files)) in enumerate(walkdir(BILIBILI_CACHE_DIR))
    @info index

    for d in dirs
        path  = joinpath(root, d)
        if occursin(REGEX_PURPOSE_PATH, path)
            count += 1
            # println(path)
            push!(aim_dirs, path)
        end
    end

    # for f in files
    #     path = joinpath(root, f)
    #     println(path)
    # end

end
@show count
end

for d in aim_dirs
    @info d
end


