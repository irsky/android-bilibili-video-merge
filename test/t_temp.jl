#=
function escape_for_regex(s::AbstractString)
    return replace(s, r"([\\.^\$*+?()[\]{}|])" => s"\\\1")
end

=#

function escape_for_regex(s::AbstractString)
    return replace(s, r"([\\.^\$*+?()[\]{}|])" => s"\\\1")
end

function efr(s::AbstractString)
    return replace(s, r"([\\.^\$*+?()[\]{}|])" => s"\\\1")
end

path = "/Users/npc/Documents/code/android-bilibili-video-merge/bilibili的$(efr(raw"\\d"))视频缓存文件/1606328203/c_1619898984/16/"
BILI_DIR = escape_for_regex("bilibili的\\\\d视频缓存文件")
rg = Regex(raw".*/" * BILI_DIR * raw"/\d+/c_\d+/\d+/")
occursin(rg, path) |> print


begin
# 假设你的字符串 s 含有需要字面匹配的部分
s = "bilibili的.\\d.视频缓存文件"
#rg = Regex(r".*/\\Q" * s * r"\\E/\d+/c_\d+/\d+/")
re = Regex(raw".*/\Q" * s * raw"\E/\\d+/c_\\d+/\\d+/")
end




begin
var = "file(1).mp4"
var2 = "file(2).mp4"
escaped = escape_for_regex(var2)
re = Regex(raw" " * escaped * raw"$")
@info re
occursin(re, "some file(2).mp4") |> print
end




var_raw = raw"\\d"
var_str = "\\d"
re_raw = Regex("\\Q$var_raw\\E")
re_str = Regex("\\Q$var_str\\E")

