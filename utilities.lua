utils = {}

utils.linspace = function(minimum, maximum, resolution) 
    local range = maximum - minimum
    local step_size = range / resolution
    local t_linspace = {}
    for i=1, resolution do
        table.insert(t_linspace, i * step_size)
    end
    return t_linspace
end