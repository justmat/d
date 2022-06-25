-- destroy/distort/disintegrate
--
-- make audio sound worse
--

engine.name = 'D'
local alt = false
local page = 1

matrix = {}
for i = 1, 3 do
  matrix[i] = {
    sr = 0,
    bd = 0,
    sat = 0,
    co = 0,
    h = 0,
    l = 0,
    hs = 0
  }
end

local data = {}

data.param_ids = {
  "sample_rate",
  "bit_depth",
  "saturation",
  "crossover",
  "highbias",
  "lowbias",
  "hiss"
}

data.param_shorts = {
  "sr",
  "bd",
  "sat",
  "co",
  "hb",
  "lb",
  "hs"
}

data.bullshit = {}
data.bullshit.x = {
  0,
  35,
  75,
  5,
  32,
  60,
  82
}

data.bullshit.y = {
  30,
  33,
  28,
  60,
  55,
  62,
  50
}


command = ""
function build_command(n)
  command = command .. n
end


function process_command(n)
  if #n == 4 then
    if n == "2223" then
      params:set("sample_rate", 48000)
      params:set("bit_depth", 32)
    elseif n == "2232" then
      params:set("saturation", 5)
      params:set("crossover", 2000)
      params:set("highbias", 0.14)
      params:set("lowbias", 0.01)
      params:set("hiss", 0.001)
    elseif n == "2322" then
      for i = 1, 3 do
        params:set("sr" .. i, math.random(-100, 100))
        params:set("bd" .. i, math.random(-100, 100))
        params:set("sat" .. i, math.random(-100, 100))
        params:set("co" .. i, math.random(-100,100))
        params:set("hb" .. i, math.random(-100, 100))
        params:set("lb" .. i, math.random(-100, 100))
        params:set("hs" .. i, math.random(-100, 100))
      end
    elseif n == "3332" then
      page = 2
    elseif n == "3323" then
      page = 3
    elseif n == "3233" then
      page = 1
    end
  end
end


function init()
  local pcount = params.count + 1
  -- sample rate
  params:add_control("sample_rate", "sample rate", controlspec.new(2000, 48000, "exp", 1, 48000, '', 0.001, false))
  params:set_action("sample_rate", function(x) engine.srate(x) end)
  -- bit depth
  params:add_control("bit_depth", "bit depth", controlspec.new(1, 32, "lin", 0, 32, '', 0.01, false))
  params:set_action("bit_depth", function(x) engine.sdepth(x) end)
  -- tape sat
  params:add_control("saturation", "saturation", controlspec.new(10, 500, "exp", 1, 15, '', 0.01, false))
  params:set_action("saturation", function(x) engine.distAmount(x) end)
  -- crossover filter
  params:add_control("crossover", "crossover", controlspec.new(50, 10000, "lin", 10, 2000, '', 0.01, false))
  params:set_action("crossover", function(x) engine.crossover(x) end)
  -- bias
  params:add_control("highbias", "highbias", controlspec.new(0.001, 1, "lin", 0.001, 0.12, '', 0.01, false))
  params:set_action("highbias", function(x) engine.highbias(x) end)
  
  params:add_control("lowbias", "lowbias", controlspec.new(0.001, 1, "lin", 0.001, 0.04, '', 0.01, false))
  params:set_action("lowbias", function(x) engine.lowbias(x) end)
  -- tape hiss
  params:add_control("hiss", "hiss", controlspec.new(0, 10, "lin", 0.01, 0.001, '', 0.01, true))
  params:set_action("hiss", function(x) engine.hissAmount(x) end)
  -- control matrix
  for i = 1, 3 do
    params:add_number("sr" .. i, "sr" .. i, -100, 100, math.random(-100, 100))
    params:set_action("sr" .. i, function(v) matrix[i].sr = v end)

    params:add_number("bd" .. i, "bd" .. i, -100, 100, math.random(-100, 100))
    params:set_action("bd" .. i, function(v) matrix[i].bd = v end)
    
    params:add_number("sat" .. i, "sat" .. i,-100, 100, math.random(-100, 100))
    params:set_action("sat" .. i, function(v) matrix[i].sat = v end)

    params:add_number("co" .. i, "co" .. i, -100, 100, math.random(-100, 100))
    params:set_action("co" .. i, function(v) matrix[i].co = v end)

    params:add_number("hb" .. i, "hb" .. i, -100, 100, math.random(-100, 100))
    params:set_action("hb" .. i, function(v) matrix[i].h = v end)
    
    params:add_number("lb" .. i, "lb" .. i, -100, 100, math.random(-100, 100))
    params:set_action("lb" .. i, function(v) matrix[i].l = v end)

    params:add_number("hs" .. i, "hs" .. i, -100, 100, math.random(-100, 100))
    params:set_action("hs" .. i, function(v) matrix[i].hs = v end)
  end


  --for i = pcount, params.count do
    --params:hide(i)
  --end

  params:bang()

  local screen_metro = metro.init()
  screen_metro.time = 1/10
  screen_metro.event = function() redraw() end
  screen_metro:start()
end


function enc(n, d)
  params:delta("sample_rate", d * util.linlin(-100, 100, 0, 1, matrix[n].sr))
  params:delta("bit_depth", d * util.linlin(-100, 100, 0, 1, matrix[n].bd))
  params:delta("saturation", d * util.linlin(-100, 100, 0, 1, matrix[n].sat))
  params:delta("crossover", d * util.linlin(-100, 100, 0, 1, matrix[n].co))
  params:delta("highbias", d * util.linlin(-100, 100, 0, 1, matrix[n].h))
  params:delta("lowbias", d * util.linlin(-100, 100, 0, 1, matrix[n].l))
  params:delta("hiss", d * util.linlin(-100, 100, 0, 1, matrix[n].hs))
end


function key(n, z)
  if n == 1 then alt = z == 1 and true or false end
  
  if alt then
    -- add key presses to a string 4 chars long
    if n == 2 and z == 1 then
      build_command("2")
    elseif n == 3 and z == 1 then
      build_command("3")
    end
  else
    process_command(command)
    command = ""
  end
end


function draw_matrix()
  screen.move(16, 5)
  screen.text("sr")
  screen.move(36, 5)
  screen.text("bd")
  screen.move(56, 5)
  screen.text("sat")
  screen.move(76, 5)
  screen.text("co")
  screen.move(96, 5)
  screen.text("hb")
  screen.move(116, 5)
  screen.text("lb")
  
  screen.move(0, 7)
  screen.line(127,7)
  screen.stroke()
  
  screen.move(3, 20)
  screen.text("1")
  screen.move(3, 35)
  screen.text("2")
  screen.move(3, 50)
  screen.text("3")
  
  screen.move(12, 7)
  screen.line(12, 64)
  screen.stroke()

  screen.move(16, 20)
  screen.text(params:get("sr1"))
  screen.move(36, 20)
  screen.text(params:get("bd1"))
  screen.move(56, 20)
  screen.text(params:get("sat1"))
  screen.move(76, 20)
  screen.text(params:get("co1"))
  screen.move(96, 20)
  screen.text(params:get("hb1"))
  screen.move(116, 20)
  screen.text(params:get("lb1"))
  
  screen.move(16, 35)
  screen.text(params:get("sr2"))
  screen.move(36, 35)
  screen.text(params:get("bd2"))
  screen.move(56, 35)
  screen.text(params:get("sat2"))
  screen.move(76, 35)
  screen.text(params:get("co2"))
  screen.move(96, 35)
  screen.text(params:get("hb2"))
  screen.move(116, 35)
  screen.text(params:get("lb2"))
  
  screen.move(16, 50)
  screen.text(params:get("sr3"))
  screen.move(36, 50)
  screen.text(params:get("bd3"))
  screen.move(56, 50)
  screen.text(params:get("sat3"))
  screen.move(76, 50)
  screen.text(params:get("co3"))
  screen.move(96, 50)
  screen.text(params:get("hb3"))
  screen.move(116, 50)
  screen.text(params:get("lb3"))
end


function draw_engine()
  screen.move(3, 5)
  screen.text("sample rate: " .. params:get("sample_rate"))
  screen.move(3, 15)
  screen.text("bit depth: ".. params:get("bit_depth"))
  screen.move(3, 25)
  screen.text("saturation: " .. params:get("saturation"))
  screen.move(3, 35)
  screen.text("crossover: " .. params:get("crossover"))
  screen.move(3, 45)
  screen.text("highbias: " .. params:get("highbias"))
  screen.move(3, 55)
  screen.text("lowbias: " .. params:get("lowbias"))
end


function get_size_level(p)
  -- p = parameter id
  -- returns table with font size and brightness level
  -- srsaths is a hack to make sample rate, saturation, and hiss larger in size
  local srsaths = false
  if p == "saturation" or p == "saturation" or p == "hiss" then
    srsaths = true
  end

  local mi, ma, va = params:get_range(p)[1], params:get_range(p)[2], params:get(p)
  local size, level = util.linlin(mi, ma, srsaths and 36 or 24, srsaths and 48 or 36, va), math.floor(util.linlin(mi, ma, 1, 16, va))
  local table = {size, level}
  return table
end


function draw_bullshit()
  for i = 1, 7 do
    screen.move(data.bullshit.x[i], data.bullshit.y[i])
    screen.font_face(math.random(1, 56))
    screen.font_size(get_size_level(data.param_ids[i])[1])
    screen.level(get_size_level(data.param_ids[i])[2])
    if i == 4 then
      screen.text_rotate(data.bullshit.x[i], data.bullshit.y[i], data.param_shorts[i], -15)
    elseif i == 7 then
      screen.text_rotate(data.bullshit.x[i], data.bullshit.y[i], data.param_shorts[i], 15)
    else
      screen.text(data.param_shorts[i])
    end
  end
end


function draw_command()
  screen.move(0, 0)
  screen.rect(0, 0, 127, 64)
  screen.level(1)
  screen.blend_mode(5)
  screen.fill()
  screen.stroke()
  
  screen.blend_mode(0)
  screen.font_face(14)
  screen.move(68, 60)
  screen.level(0)
  screen.font_size(64)
  screen.text_center(command)
  screen.move(64, 57)
  screen.level(16)
  screen.font_size(64)
  screen.text_center(command)
end


function redraw()
  screen.aa(0)
  screen.blend_mode(0)
  screen.clear()
  screen.level(16)
  screen.font_face(25)
  screen.font_size(6)
  screen.move(5, 5)
  if page == 1 then
    draw_bullshit()
  elseif page == 2 then
    draw_engine()
  elseif page == 3 then
    draw_matrix()
  end
  if alt then draw_command() end
  screen.update()
end