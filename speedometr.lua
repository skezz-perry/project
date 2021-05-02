local font_flag = require("moonloader").font_flag
local lsampev, sampev = pcall(require, "lib.samp.events") 

local main_font = renderCreateFont("CALIBRI", 40, font_flag.BOLD)
local add_font = renderCreateFont("CALIBRI", 10, font_flag.BOLD)
local word_font = renderCreateFont("CALIBRI", 15, font_flag.BOLD)

local main_font_height = renderGetFontDrawHeight(main_font)

local vehicle_parametrs = { 
	vehicleId = false,
	fuel = 0,
	lights = false,
	alarm = false,
	sport = false,
	boot = false
}

local icolor = {
	{background = 0xFFEBEDEF, active = 0xFF85C1E9, another = 0xFF52BE80, desc = "Значение скорости"},
	{background = 0xFFEBEDEF, active = 0xFFCD5C5C, another = 0xFFFFFFFF, desc = "Количество HP"},
	{background = 0xFFEBEDEF, active = 0xFF148F77, another = 0xFFFFFFFF, desc = "Заполненность топливного бака"},
	{background = 0xFFFFFFFF, active = 0xFFF8C471, another = 0xFFFFFFFF, desc = "Индикатор состояния двигателя"},
	{background = 0xFFFFFFFF, active = 0xFFF8C471, another = 0xFFFFFFFF, desc = "Индикатор состояния фар"},
	{background = 0xFFFFFFFF, active = 0xFFF8C471, another = 0xFFFFFFFF, desc = "Индикатор состояния сигнализации"},
	{background = 0xFFFFFFFF, active = 0xFFE74C3C, another = 0xFFFFFFFF, desc = "Индикатор состояния дверей"},
	{background = 0xFFFFFFFF, active = 0xFFF8C471, another = 0xFFFFFFFF, desc = "Индикатор состояния багажника / капота"},
	{background = 0xFFFFFFFF, active = 0xFFE74C3C, another = 0xFFFFFFFF, desc = "Индикатор низкого уровня топлива"}
}

-- main
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	local cx, cy = 1742, 947
	
	sampRegisterChatCommand("sp_change", function()
		lua_thread.create(function()
			wait(100)
			chat("Переместите спидометр в желамое место и нажмите {F8C471}ЛКМ{ffffff}, чтобы сохранить местоположение.")
			sampSetCursorMode(2)
			while not wasKeyPressed(1) do wait(0) cx, cy = getCursorPos() end 
			sampSetCursorMode(0)
			
			rewrite("local cx, cy = (%d+), (%d+)", string.format("local cx, cy = %s, %s", cx, cy))
		end)
	end)
	 
	while true do wait(0)
		if isCharSittingInAnyCar(playerPed) then
			local vehicle = storeCarCharIsInNoSave(playerPed)
			if getDriverOfCar(vehicle) == playerPed then
				-- информация о автомобиле
				local result, vehicleId = sampGetVehicleIdByCarHandle(vehicle) -- ид
				if result then vehicle_parametrs.vehicleId = vehicleId end -- глобальный ид
				local speed = math.ceil(getCarSpeed(vehicle) * 2.02) -- скорость
				local health = getCarHealth(vehicle) - 250 -- хп
				local engine = isCarEngineOn(vehicle) -- двигатель
				local fuel = vehicle_parametrs.fuel -- топливо
				local color_fuel = ((fuel < 20) and (math.fmod(math.floor(os.clock()), 2) == 0)) and icolor[9]["active"] or icolor[9]["another"]
				
				-- линии-значения 
				render_circular_line_1({cx, cy}, {90, 105}, {145, 395}, {speed, 162}, {icolor[1]["background"], vehicle_parametrs["sport"] and icolor[1]["another"] or icolor[1]["active"]}) -- скорость
				render_circular_line_1({cx, cy}, {110, 125}, {160, 250}, {health, 750}, {icolor[2]["background"], icolor[2]["active"]}) -- хп
				render_circular_line_2({cx, cy}, {110, 125}, {296, 395}, {fuel, 150}, {icolor[3]["background"], icolor[3]["active"]}) -- топливо

				-- скорость
				local speed = tostring(speed)
				local fix = renderGetFontDrawTextLength(main_font, speed) / 2
				renderFontDrawText(main_font, tostring(speed), cx - fix, cy - main_font_height, 0xFFFFFFFF)
				renderFontDrawText(add_font, "KM/H", cx - 16, cy - 8, 0xFFFFFFFF)

				-- индикаторы (1я строка)
				render_figure_2D(cx - 35, cy + 40, 20, 15, engine and icolor[4]["active"] or icolor[4]["another"]) -- двигатель (обводка)
				renderFontDrawText(word_font, "E", cx - 40, cy + 28, icolor[4]["another"]) -- двигатель (буква)
				render_figure_2D(cx, cy + 40, 20, 15, vehicle_parametrs["lights"] and icolor[5]["active"] or icolor[5]["another"]) -- фары (обводка)
				renderFontDrawText(word_font, "L", cx - 4, cy + 28, icolor[5]["another"]) -- фары (буква)
				render_figure_2D(cx + 35, cy + 40, 20, 15, vehicle_parametrs["alarm"] and icolor[6]["active"] or icolor[6]["another"]) -- сигнализация (обводка)
				renderFontDrawText(word_font, "A", cx + 29, cy + 28, icolor[6]["another"]) -- сигнализация (буква)
				
				-- индикаторы (2я строка)
				render_figure_2D(cx - 35, cy + 75, 20, 15, vehicle_parametrs["doors"] and icolor[7]["active"] or icolor[7]["another"]) -- двери (обводка)
				renderFontDrawText(word_font, "D", cx - 41, cy + 63, icolor[7]["another"]) -- двери (буква)
				render_figure_2D(cx, cy + 75, 20, 15, vehicle_parametrs["boot"] and icolor[8]["active"] or icolor[8]["another"]) -- багажник / капот (обводка)
				renderFontDrawText(word_font, "B", cx - 5, cy + 63, icolor[8]["another"]) -- багажник / капот (обводка)
				render_figure_2D(cx + 35, cy + 75, 20, 15, color_fuel) -- топливо (обводка)
				renderFontDrawText(word_font, "F", cx + 30, cy + 63, color_fuel) -- топливо (буква)
			end
		end 
	end
end

-- function
function chat(...)
	local input, output = {...}, "**{ffffff}"
	for k, v in pairs(input) do output = string.format("%s %s", output, v) end
	sampAddChatMessage(output, 0xFF52BE80)
end

function rewrite(sought, necessary)
	local file = io.open(thisScript().path, "r")
	local text = file:read("*a"):gsub(sought, necessary)
	file:close()
	local file = io.open(thisScript().path, "w")
	file:write(text)
	file:close()
end

function render_figure_2D(x, y, points, radius, color) -- blast.hk/threads/13380/post-344806
    local step = math.pi * 2 / points
    local render_start, render_end = {}, {}
    for i = 0, math.pi * 2, step do
        render_start[1] = radius * math.cos(i) + x
        render_start[2] = radius * math.sin(i) + y
        render_end[1] = radius * math.cos(i + step) + x
        render_end[2] = radius * math.sin(i + step) + y
        renderDrawLine(render_start[1], render_start[2], render_end[1], render_end[2], 1, color)
    end
end

function render_circular_line_1(center, radius, range, value, color)
	local value_angle = range[1] + ((range[2] - range[1]) / 100) * (value[1] * 100 / value[2])
	for angle = range[1], range[2] do
		local cos_radian = math.cos(math.rad(angle))
		local sin_radian = math.sin(math.rad(angle))
		if angle > value_angle then
			local x1 = center[1] + (radius[1] + 3) * cos_radian
			local y1 = center[2] + (radius[1] + 3) * sin_radian
			local x2 = center[1] + (radius[2] - 3) * cos_radian
			local y2 = center[2] + (radius[2] - 3) * sin_radian
			renderDrawLine(x1, y1, x2, y2, 3, color[1])
		else
			local x1 = center[1] + radius[1] * cos_radian
			local y1 = center[2] + radius[1] * sin_radian
			local x2 = center[1] + radius[2] * cos_radian
			local y2 = center[2] + radius[2] * sin_radian
			renderDrawLine(x1, y1, x2, y2, 3, color[2])
		end
	end
end

function render_circular_line_2(center, radius, range, value, color)
	local value_angle = range[1] + ((range[2] - range[1]) / 100) * (100 - (value[1] * 100 / value[2]))
	for angle = range[2], range[1], -1 do
		local cos_radian = math.cos(math.rad(angle))
		local sin_radian = math.sin(math.rad(angle))
		if angle < value_angle then 
			local x1 = center[1] + (radius[1] + 3) * cos_radian
			local y1 = center[2] + (radius[1] + 3) * sin_radian
			local x2 = center[1] + (radius[2] - 3) * cos_radian
			local y2 = center[2] + (radius[2] - 3) * sin_radian
			renderDrawLine(x1, y1, x2, y2, 3, color[1])
		else
			local x1 = center[1] + radius[1] * cos_radian
			local y1 = center[2] + radius[1] * sin_radian
			local x2 = center[1] + radius[2] * cos_radian
			local y2 = center[2] + radius[2] * sin_radian
			renderDrawLine(x1, y1, x2, y2, 3, color[2])
		end
	end
end

-- events
function sampev.onSetVehicleParamsEx(vehicleId, parametrs, doors, windows)
	if vehicle_parametrs.vehicleId and vehicle_parametrs.vehicleId == vehicleId then
		vehicle_parametrs["lights"] = (parametrs["lights"] == 1)
		vehicle_parametrs["doors"] = (parametrs["doors"]  == 1)
		vehicle_parametrs["boot"] = (parametrs["boot"] == 1) or (parametrs["bonnet"] == 1)
	end
end

function sampev.onTextDrawSetString(id, text)
	if string.match(text, "Fuel_(%d+)__") then 
		vehicle_parametrs["fuel"] = tonumber(string.match(text, "Fuel_(%d+)__"))
		vehicle_parametrs["alarm"] = string.match(text, "~p~S")
		vehicle_parametrs["sport"] = string.match(text, "~y~Sport")
		return {id, ""}
	end
end