
module Tail

function tail(start::Float64)
    elapsed = time() - start
    @info "总共耗时 $(round(elapsed, digits=2)) 秒"
end

end