



abstract type PathStr end
struct FileStr <: PathStr path::String end
struct DirStr <: PathStr path::String end


function pathstr_create(fpath::FileStr)
    if isfile(fpath.path) return end
    dir = dirname(fpath.path)
    !ispath(dir) && mkpath(dir)    
    open(fpath.path, "w") do io end
end

function pathstr_create(dpath::DirStr)
    if ispath(dpath.path) return end
    mkpath(dpath.path)
end




