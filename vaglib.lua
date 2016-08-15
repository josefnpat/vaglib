local vag = {}
-- Vector Arcade Graphics Library

local g = 0.0125

-- Start at top left, constrain to 1x1
vag._letters = {
  ['0'] = {1,0,1,1,0,1,0,0,1,0,0,1},
  ['1'] = {0.5,0,0.5,1},
  ['2'] = {0,0,1,0,1,0.5,0,0.5,0,1,1,1},
  ['3'] = {0,0,1,0,0.5,0.5,1,1,0,1},
  ['3'] = {0,0,1,0,1,0.5-g,0,0.5-g,0,0.5,1,0.5,1,1,0,1},
  ['4'] = {1,0.5,0,0.5,1,0,1,1},--alt
  ['4'] = {0,0,0,0.5,1-g,0.5,1-g,0,1,0,1,1},
  ['5'] = {1,0,0,0,0,0.5,1,0.5,1,1,0,1},
  ['6'] = {0,0,0,1,1,1,1,0.5,0,0.5},
  ['7'] = {0,0,1,0,1,1},
  ['8'] = {0,0.5,1,0.5,1,1,0,1,0,0,1,0,1,0.5},
  ['9'] = {1,0.5,0,0.5,0,0,1,0,1,1},
  ['A'] = {1,1,1,0.25,0.5,0,0,0.25,0,0.5-g,1-g,0.5-g,1-g,0.5,0,0.5,0,1},
  ['B'] = {0,0,1,0,1,0.25,0.5,0.5,1,0.75,1,1,0,1,0,0},
  ['C'] = {1,0,0,0,0,1,1,1},
  ['D'] = {0,0,0.5,0,1,0.25,1,0.75,0.5,1,0,1,0,0},
  ['E'] = {1,0,0,0,0,0.5-g,0.5,0.5-g,0.5,0.5,0,0.5,0,1,1,1},
  ['F'] = {1,0,0,0,0,0.5-g,0.5,0.5-g,0.5,0.5,0,0.5,0,1},
  ['G'] = {1,0,0,0,0,1,1,1,1,0.5,0.5,0.5},
  ['H'] = {g,0.5,g,0,0,0,0,1,g,1,g,0.5,1-g,0.5,1-g,1,1,1,1,0,1-g,0,1-g,0.5},
  ['I'] = {0.5,g,0,g,0,0,1,0,1,g,0.5,g,0.5,1-g,1,1-g,1,1,0,1,0,1-g,0.5,1-g},
  ['J'] = {1,0,1,1,0.25,1,0,0.75},
  ['K'] = {1,0,0.5,0.5-g,g,0.5-g,g,0,0,0,0,1,g,1,g,0.5,0.5,0.5,1,1},
  ['L'] = {0,0,0,1,1,1},
  ['M'] = {0,1,0,0,0.5,0.5,1,0,1,1},
  ['N'] = {0,1,0,0,1,1,1,0},
  ['O'] = {0,0,1,0,1,1,0,1,0,0},
  ['P'] = {0,1,0,0,1,0,1,0.5,0,0.5},
  ['Q'] = {0.5,0.5,0.75,0.75,1,0.5,1,0,0,0,0,1,0.5,1,0.75,0.75,1,1},
  ['R'] = {0,1,0,0,1,0,1,0.5,0,0.5,1,1},
  ['S'] = {1,0,0,0,0,0.5,1,0.5,1,1,0,1},
  ['T'] = {0.5,g,0,g,0,0,1,0,1,g,0.5,g,0.5,1},
  ['U'] = {0,0,0,1,1,1,1,0},
  ['V'] = {0,0,0.5,1,1,0},
  ['W'] = {0,0,0,1,0.5,0.5,1,1,1,0},
  ['X'] = {0,0,g,0,0.5-g,0.5-g,0.5+g,0.5-g,1-g,0,1,0,1,g,0.5+g,0.5-g,
    0.5+g,0.5+g,1,1-g,1,1,1-g,1,0.5+g,0.5+g,0.5-g,0.5+g,g,1,0,1,0,1-g,
    0.5-g,0.5+g,0.5-g,0.5-g,0,g,0,0,
  },
  ['Y'] = {0.5,1,0.5,0.5,0,g,0,0,g,0,0.5,0.5-g,0.5+g,0.5-g,1-g,0,1,0,1,g,
    0.5+g,0.5,0.5+g,1},
  ['Z'] = {0,0,1,0,0,1,1,1},
  ['N/A'] = {0,0,1,0,1,1,0,1,0,0,1,1,1,0,0,1}
}

function prep_shaders()
  local shine = require"shine"
  local crt = shine.crt()
  local gaussianblur = shine.gaussianblur()
  gaussianblur:set("sigma",0.75)
  local post_effect = gaussianblur:chain(crt)
  return post_effect
end

local post_effect

function vag.new(init)
  init = init or {}
  local self = {}
  self.draw = vag.draw
  self.update = vag.update
  self._fade = init.fade or 0.05
  self.setFade = vag.setFade
  self.getFade = vag.getFade
  self._line = {}
  self.line = vag.line

  self._printSubScale = init.printSubScale or 0.6
  self.getPrintSubScale = vag.getPrintSubScale
  self.setPrintSubScale = vag.setPrintSubScale

  self.print = vag.print

  self._shaders = (init.shaders==true or init.shaders==nil) and true or false
  if self._shaders == true then
    post_effect = prep_shaders()
  end
  return self
end

function vag:draw()
  local orig_color = {love.graphics.getColor()}
  local orig_line_width = love.graphics.getLineWidth()
  love.graphics.setLineWidth(2)

  local draw = function()
    for i,v in pairs(self._line) do
      love.graphics.setColor(255,255,255,v.dt/self._fade*255)
      love.graphics.line(unpack(v.points))
      local x
      for j,w in pairs(v.points) do
        if x == nil then
          x = w
        else
          love.graphics.circle("fill",x,w,2)
          x = nil
        end
      end
    end
  end

  if self._shaders == true then
    post_effect:draw(draw)
  else
    draw(self)
  end

  love.graphics.setColor(orig_color)
  love.graphics.setLineWidth(orig_line_width)
end

function vag:update(dt)
  for i,v in pairs(self._line) do
    v.dt = v.dt - dt
    if v.dt <= 0 then
      table.remove(self._line,i)
    end
  end
end

function vag:setFade(dt)
  self._fade = dt
end

function vag:getFade()
  return self._fade
end

function vag:line(...)
  local args = {...}
  table.insert(self._line,{
    dt=self._fade,
    points=args,
  })
end

function vag:setPrintSubScale(val)
  self._printSubScale = val
end

function vag:getPrintSubScale()
  return self._printSubScale
end

function vag:print(s,x,y,sx,sy)
  for si = 1,string.len(s) do
    local cx = nil
    local tmp = {}
    local target = string.upper(string.sub(s,si,si))
    if target ~= " " then
      local data = vag._letters[target] or vag._letters['N/A']
      for i,v in pairs(data) do
        if cx == nil then
          cx = v*sx*self._printSubScale+x+(si-1)*sx
        else
          local cy = v*sy+y
          table.insert(tmp,cx)
          table.insert(tmp,cy)
          cx = nil
        end
      end
      self:line(unpack(tmp))
    end
  end
end

return vag
