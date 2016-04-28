
Hero = class(Unit)
function Hero:ctor()
    self.idx = 0
end

function Hero:get_data()
    return {idx = self.idx}
end
