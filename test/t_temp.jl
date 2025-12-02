module Header

module File
module Internal
    export File
    mutable struct File
        path::String
    end
end #Internal

module Constructor
import ..Internal
function File(path_str::String)
    obj = Internal.File(path_str)
    return obj
end
end #Constructor

using .Internal
export File

end #File


end  #Header



using .Header

f = File("some")










