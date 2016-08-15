local vaglib = require "vaglib"
local vag = vaglib.new()--{shaders=false,fade=0.0001}

function draw_ship(x,y,r)
  local x1,y1 = rotate(24,0,r)
  local x2,y2 = rotate(-16,16,r)
  local x3,y3 = rotate(-8,0,r)
  local x4,y4 = rotate(-16,-16,r)
  vag:line(
    x+x1,y+y1,
    x+x2,y+y2,
    x+x3,y+y3,
    x+x4,y+y4,
    x+x1,y+y1)
end

local player = {
  v = 0,
  x = 400,
  y = 300,
  r = 0,
  lives = 3,
  draw = function(self)
    vag:print("SCORE 0123456789",4,4,24,24)
    vag:print("ABCDEFGHIJKL",32,100,64,64)
    vag:print("MNOPQRSTUVWX",32,174,64,64)
    vag:print("YZ1234567890",32,248,64,64)
    vag:print("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",32,322,24,24)
    vag:print("ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",32,356,12,12)
    vag:print("The quick brown fox jumps over the lazy doge",32,400,12,12)
    for i = 1,self.lives do
      draw_ship(32*i,64,-math.pi/2)
    end
    draw_ship(self.x,self.y,self.r)
  end,
}

function rotate(x,y,a)
  return x*math.cos(a) - y*math.sin(a),x*math.sin(a) + y*math.cos(a)
end

local asteroids = {}
for i = 1,10 do
  local asteroid = {
    x = math.random(0,love.graphics.getWidth()),
    y = math.random(0,love.graphics.getHeight()),
    vx = math.random(-100,100),
    vy = math.random(-100,100),
    r = 0,
    points = {},
    draw = function(self) --lol wtf
      local x
      local newline = {}
      for i,v in pairs(self.points) do
        if x == nil then
          x = v
        else
          local nx,ny = rotate(x,v,self.r)
          table.insert(newline,nx+self.x)
          table.insert(newline,ny+self.y)
          x = nil
        end
      end
      vag:line(unpack(newline))
    end,
  }
  local segments = math.random(8,12)
  local first
  for i = 1,segments do
    local x,y = rotate(math.random(16,32),0,math.pi*2/segments*i)
    table.insert(asteroid.points,x)
    table.insert(asteroid.points,y)
    if first == nil then
      first = {x=x,y=y}
    end
  end
  table.insert(asteroid.points,first.x)
  table.insert(asteroid.points,first.y)
  table.insert(asteroids,asteroid)
end

local bullets = {}

function love.draw()
  player:draw()
  for i,v in pairs(asteroids) do
    v:draw()
  end
  vag:draw()
end

function love.update(dt)

  for i,v in pairs(asteroids) do
    v.r = v.r + dt
    v.x = (v.x+v.vx*dt)%love.graphics.getWidth()
    v.y = (v.y+v.vy*dt)%love.graphics.getHeight()
  end

  local accel = 300
  local max_speed = 300
  if love.keyboard.isDown("w") then
    player.v = math.min(max_speed,player.v + accel*dt)
  end
  if love.keyboard.isDown("s") then
    player.v = math.max(-max_speed,player.v - accel*dt)
  end
  if love.keyboard.isDown("d") then
    player.r = player.r + math.pi*dt
  end
  if love.keyboard.isDown("a") then
    player.r = player.r - math.pi*dt
  end
  player.x = player.x + math.cos(player.r)*player.v*dt
  player.y = player.y + math.sin(player.r)*player.v*dt

  player.x = player.x % love.graphics.getWidth()
  player.y = player.y % love.graphics.getHeight()

  vag:update(dt)

end
