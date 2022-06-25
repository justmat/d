-- screen stuff for d
--
--


local d = {}

d.param_ids = {
  "sample_rate",
  "bit_depth",
  "saturation",
  "crossover",
  "highbias",
  "lowbias",
  "hiss"
}

d.param_shorts = {
  "sr",
  "bd",
  "sat",
  "co",
  "hb",
  "lb",
  "hs"
}

d.bullshit = {}
d.bullshit.x = {
  0,
  35,
  75,
  5,
  32,
  60,
  82
}

d.bullshit.y = {
  30,
  33,
  28,
  60,
  55,
  62,
  50
}


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


function d.draw_matrix()
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


function d.draw_engine()
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



function d.draw_bullshit()
  for i = 1, 7 do
    screen.move(d.bullshit.x[i], d.bullshit.y[i])
    screen.font_face(math.random(1, 56))
    screen.font_size(get_size_level(d.param_ids[i])[1])
    screen.level(get_size_level(d.param_ids[i])[2])
    if i == 4 then
      screen.text_rotate(d.bullshit.x[i], d.bullshit.y[i], d.param_shorts[i], -15)
    elseif i == 7 then
      screen.text_rotate(d.bullshit.x[i], d.bullshit.y[i], d.param_shorts[i], 15)
    else
      screen.text(d.param_shorts[i])
    end
  end
end


function d.draw_command()
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

return d
