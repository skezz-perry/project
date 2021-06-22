script_name("helper-for-mia (v2.0)")
script_author("Joachim von Ribbentrop")
script_version("0.1.8")

require "deps" {
	"fyp:mimgui",
	"donhomka:mimgui-addons"
}

-- require
local vkeys = require "vkeys" 
local rkeys = require "rkeys"
local imgui, ffi = require "mimgui", require "ffi"
local mimgui_addons = require "mimgui-addons"
local new, str = imgui.new, ffi.string
local faicons = require "fa-icons"
local font_flag = require("moonloader").font_flag 
local encoding = require "encoding"
local memory = require "memory"
local xconf = require "xconf"
local gauth = require "gauth" 
local https = require "ssl.https"
local wm = require('lib.windows.message')
lsampev, sampev = pcall(require, "lib.samp.events")
encoding.default = "CP1251"
u8 = encoding.UTF8
imgui.HotKey = mimgui_addons.HotKey

-- !require

-- global value 
local update_log = {
	{["0.1.8"] = {"Добавлен прерыватель исполнения команд (клавиша X)."}},
	{["0.1.5"] = {"В тестовом режиме добавлено быстрое меню (клавиша Z)."}},
	{["0.1.4"] = {"В тестовом режиме добавлена база данных (в блоке 'Панель управления').", "Улучшена система определения параметров в биндере."}},
	{["0.1.2"] = {"Добавлена возможность редактировать системные команды и создавать новые вариации.", "В настройках добавлена возможность кастомизировать цвет интерфейса и префикса чата."}},
	{["0.1.0"] = {"Добавлена статистика действий пользователя (/helper_stats).", "Добавлен список последних гос.новостей (/goverment_news).", "Добавлены дополнительные тэги для биндера.", "Добавлены дублирующие NRP-команды (/ncuff и т.д.)"}},
	{["0.0.9"] = {"Добавлен менеджер аккаунтов.", "Добавлена возможность проверки правильности написания слов (/speller)."}},
	{["0.0.6"] = {"Окончательно исправлена ошибка при разделении длинных строк."}},
	{["0.0.5"] = {"Добавлен список дешёвых АЗС с построением маршрута до них (/fuel)."}},
	{["0.0.4"] = {"Добавлен CamHack (c + 1).", "Улучшен разделитель строк по пробелам, теперь не кикает из игры."}},
	{["0.0.3"] = {"Добавлена возможность печатать при прицеливании (правый ctrl)."}},
	{["0.0.2"] = {"Добавлена система авто-обновлений."}}, 
	{["0.0.1"] = {"Начало разработки..."}}
} 
 
local fontSuspect4 = renderCreateFont("Tahoma", 6, font_flag.BOLD + font_flag.SHADOW)

local t_vehicle_name = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BFInjection", "Hunter",
	"Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie", "Stallion", "Rumpo",
	"RCBandit", "Romero","Packer", "Monster", "Admiral", "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
	"Yankee", "Caddy", "Solair", "Berkley`sRCVan", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RCBaron", "RCRaider", "Glendale", "Oceanic", "Sanchez", "Sparrow",
	"Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage",
	"Dozer", "Maverick", "News Chopper", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
	"Boxvillde", "Benson", "Mesa", "RCGoblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "SuperGT", "Elegant", "Journey", "Bike",
	"Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "hydra", "FCR-900", "NRG-500", "HPV1000",
	"Cement Truck", "Tow Truck", "Fortune", "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan", "Blade", "Freight",
	"Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada",
	"Yosemite", "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RCTiger", "Flash", "Tahoma", "Savanna", "Bandito",
	"FreightFlat", "StreakCarriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400", "NewsVan",
	"Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "FreightBox", "Trailer", "Andromada", "Dodo", "RCCam", "Launch", "Police Car", "Police Car",
	"Police Car", "Police Ranger", "Picador", "SWAT", "Alpha", "Phoenix", "GlendaleShit", "SadlerShit", "Luggage A", "Luggage B", "Stairs", "Boxville", "Tiller",
	"Utility Trailer"
}

local t_vehicle_type_name = {"Автомобиль", "Мотоцикл", "Вертолёт", "Самолёт", "Прицеп", "Лодка", "Другое", "Поезд", "Велосипед"}
local tf_vehicle_type_name = {
	{"автомобиля", "мотоцикла", "вертолёта", "самолёта", "прицепа", "лодки", "", "поезда", "велосипеда"},
	{"автомобилем", "мотоциклом", "вертолётом", "самолётом", "прицепом", "лодкой", "поездом", "велосипедом"} 
}

local t_vehicle_speed = {43, 40, 51, 30, 36, 45, 30, 41, 27, 43, 36, 61, 46, 30, 29, 53, 42, 30, 32, 41, 40, 42, 38, 27, 37,
	54, 48, 45, 43, 55, 51, 36, 26, 30, 46, 0, 41, 43, 39, 46, 37, 21, 38, 35, 30, 45, 60, 35, 30, 52, 0, 53, 43, 16, 33, 43,
	29, 26, 43, 37, 48, 43, 30, 29, 14, 13, 40, 39, 40, 34, 43, 30, 34, 29, 41, 48, 69, 51, 32, 38, 51, 20, 43, 34, 18, 27,
	17, 47, 40, 38, 43, 41, 39, 49, 59, 49, 45, 48, 29, 34, 39, 8, 58, 59, 48, 38, 49, 46, 29, 21, 27, 40, 36, 45, 33, 39, 43,
	43, 45, 75, 75, 43, 48, 41, 36, 44, 43, 41, 48, 41, 16, 19, 30, 46, 46, 43, 47, -1, -1, 27, 41, 56, 45, 41, 41, 40, 41,
	39, 37, 42, 40, 43, 33, 64, 39, 43, 30, 30, 43, 49, 46, 42, 49, 39, 24, 45, 44, 49, 40, -1, -1, 25, 22, 30, 30, 43, 43, 75,
	36, 43, 42, 42, 37, 23, 0, 42, 38, 45, 29, 45, 0, 0, 75, 52, 17, 32, 48, 48, 48, 44, 41, 30, 47, 47, 40, 41, 0, 0, 0, 29, 0, 0
}

local t_vehicle_type = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 1, 1, 1, 1, 1, 1, 1,
	3, 1, 1, 1, 1, 6, 1, 1, 1, 1, 5, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 6, 3, 2, 8, 5, 1, 6, 6, 6, 1,
	1, 1, 1, 1, 4, 2, 2, 2, 7, 7, 1, 1, 2, 3, 1, 7, 6, 6, 1, 1, 4, 1, 1, 1, 1, 9, 1, 1, 6, 1,
	1, 3, 3, 1, 1, 1, 1, 6, 1, 1, 1, 3, 1, 1, 1, 7, 1, 1, 1, 1, 1, 1, 1, 9, 9, 4, 4, 4, 1, 1, 1,
	1, 1, 4, 4, 2, 2, 2, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 1, 1,
	1, 3, 1, 1, 1, 1, 4, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 7, 1, 1, 1, 1, 8, 8, 7, 1, 1, 1, 1, 1, 4,
	1, 1, 1, 2, 1, 1, 5, 1, 2, 1, 1, 1, 7, 5, 4, 4, 7, 6, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 5, 5, 5, 1, 5, 5
}

local fraction_color = {
	[4278190335] = {"Министерство внутренних дел"},
	[4291624704] = {"Правительство"},
	[4294927872] = {"ТВ-Радио"},
	[301989887] = {"Безработные"},
	[4278220149] = {"Russian Mafia"},
	[4288230246] = {"La Cosa Nostra"},
	[4278229248] = {"Grove Street"},
	[4291559679] = {"The Ballas"},
	[4284901119] = {"The Rifa"},
	[4294927974] = {"Министерство здравоохранения"},
	[4288243251] = {"Министерство обороны"},
	[4290445312] = {"Yakuza"},
	[4278242559] = {"Varios Los Aztecas"},
	[4294954240] = {"Los Santos Vagos"}
}

local configuration_directory = "moonloader//config//Helper for MIA (v2.0)"
if not doesDirectoryExist(configuration_directory) then createDirectory(configuration_directory) end

local configuration_main = {}
local configuration_main1 = xconf.new(string.format("%s//Main settings.json", configuration_directory))
if configuration_main1 then
	configuration_main1:set_template({
		information = {
			name = u8"Joachim von Ribbentrop",
			rang = u8"Captain",
			fraction = u8"LVSD",
			number = u8"005558",
			sex = false,
			rtag = u8"",
			ftag = u8""
		},
		settings = {
			mask_timer = true,
			aid_timer = true,
			ad_blocker = true,
			passport_check = true,
			stroboscopes = true,
			new_radio = true,
			auto_buy_mandh = true, 
			small_acting_out = true,
			weapon_acting_out = true,
			auto_weapon_acting_out = true,
			obtaining_weapons = true,
			delay_between_deaths = 10,
			chase_message = true,
			patrol_assistant = true,
			user_rang = true, 
			script_color = "{67BEF8}",
			t_script_color = 0xBA67BEF8,
			line_break_by_space = true,
			customization = false
		},
		modification = { 
			id_postfix_after_nickname = true
		},
		quick_menu = {
			[1] = {title = "CUFF", callback = "command_cuff"},
			[2] = {title = "HOLD", callback = "command_hold"},
			[3] = {title = "PUTPL", callback = "command_putpl"},
			[4] = {title = "RIGHTS", callback = "command_rights"},
			[5] = {title = "ARREST", callback = "command_arrest"},
			[6] = {title = "SEARCH", callback = "command_search"}
		},
		quick_criminal_code = {
			insubordination = {stars = 4, reason = u8"31.2 УК"},
			refusal_to_pay = {stars = 3, reason = u8"25.1 УК"},
			attack = {stars = 4, reason = u8"2.3 УК"}
		}, 
		obtaining_weapons = {
			[1] = {status = false, name = u8("Баллистический щит")},
			[2] = {status = false, name = u8("Полицейская дубинка")},
			[3] = {status = false, name = u8("Пистолет с глушителем")},
			[4] = {status = false, name = u8("Бронежилет")},
			[5] = {status = false, name = u8("Маска")},
			[6] = {status = false, name = u8("Desert Eagle")},
			[7] = {status = false, name = u8("Пистолет-пулемёт MP5")},
			[8] = {status = false, name = u8("Штурмовая винтовка M4")},
			[9] = {status = false, name = u8("Дробовик")},
			[10] = {status = false, name = u8("Дымовые шашки")},
			[11] = {status = false, name = u8("Снайперская винтовка")},
			[12] = {status = false, name = u8("АК-47")}
		},
		small_acting_out = {
			[1] = {status = true, name = u8("Отыгровка при использовании аптечки")},
			[2] = {status = true, name = u8("Отыгровка при использовании маски")},
			[3] = {status = true, name = u8("Отыгровка при использовании рации")},
			[4] = {status = true, name = u8("Отыгровка при открытии дверей в ПД и офисе ФБР")},
			[5] = {status = true, name = u8("Отыгровка при открытии шлагбаума")}
		},
		weapon_acting_out = {
			[1] = {status = false, name = u8"skip_weapon_555", take = u8"", away = u8""},
			[2] = {status = false, name = u8("Клюшка для гольфа"), take = u8"", away = u8""},
			[3] = {status = false, name = u8("Полицейская дубинка"), take = u8"", away = u8""},
			[4] = {status = false, name = u8("Нож"), take = u8"", away = u8""},
			[5] = {status = false, name = u8("Бейсбольная бита"), take = u8"", away = u8""},
			[6] = {status = false, name = u8("Лопата"), take = u8"", away = u8""},
			[7] = {status = false, name = u8("Кий"), take = u8"", away = u8""},
			[8] = {status = false, name = u8("Катана"), take = u8"", away = u8""},
			[9] = {status = false, name = u8("Бензопила"), take = u8"", away = u8""},
			[10] = {status = false, name = u8("Двухсторонний дилдо"), take = u8"", away = u8""},
			[11] = {status = false, name = u8("Дилдо"), take = u8"", away = u8""},
			[12] = {status = false, name = u8("Вибратор"), take = u8"", away = u8""},
			[13] = {status = false, name = u8("Серебряный вибратор"), take = u8"", away = u8""},
			[14] = {status = false, name = u8("Букет цветов"), take = u8"", away = u8""},
			[15] = {status = false, name = u8("Трость"), take = u8"", away = u8""}, 
			[16] = {status = false, name = u8("Граната"), take = u8"", away = u8""},
			[17] = {status = false, name = u8("Слезоточивый газ"), take = u8"", away = u8""},
			[18] = {status = false, name = u8("Коктейль молотова"), take = u8"", away = u8""},
			[19] = {status = false, name = u8"weapon_skip_new", take = u8"", away = u8""},
			[20] = {status = false, name = u8"maybe_not_add_nil_weapon", take = u8"", away = u8""},
			[21] = {status = false, name = u8"fuck_weapon", take = u8"", away = u8""},
			[22] = {status = false, name = u8("Пистолет 9мм"), take = u8"", away = u8""},
			[23] = {status = false, name = u8("Пистолет с глушителем"), take = u8"", away = u8""},
			[24] = {status = true, name = u8("Desert Eagle"), take = u8("схатившись правой рукой за пистолет, вытащил его из кобуры."), away = u8("убрал пистолет обратно в кобуру, попутно застягнув её.")},
			[25] = {status = true, name = u8("Обычный дробовик"), take = u8("взявшись за ремень дробовика, снял его с плеча и взял в руки."), away = u8("повесил дробовик обратно на плечо, придерживая его за ремень.")},
			[26] = {status = false, name = u8("Обрез"), take = u8"", away = u8""},
			[27] = {status = false, name = u8("Combar shotgun"), take = u8"", away = u8""},
			[28] = {status = false, name = u8("Узи"), take = u8"", away = u8""},
			[29] = {status = true, name = u8("MP-5"), take = u8("скинул пистолет-пулемёт MP-5 с плеча и взял его в руки."), away = u8("повесил пистолет-пулемёт MP-5 обратно на плечо.")},
			[30] = {status = false, name = u8("Автомат Калашникова"), take = u8"", away = u8""},
			[31] = {status = false, name = u8("Винтовка М4"), take = u8"", away = u8""},
			[32] = {status = false, name = u8("Tec-9"), take = u8"", away = u8""},
			[33] = {status = false, name = u8("Охотничье ружьё"), take = u8"", away = u8""},
			[34] = {status = false, name = u8("Снайперская винтовка"), take = u8"", away = u8""}, 
			[35] = {status = false, name = u8("РПГ"), take = u8"", away = u8""},
			[36] = {status = false, name = u8("Ракетный комплекс"), take = u8"", away = u8""},
			[37] = {status = false, name = u8("Огнемёт"), take = u8"", away = u8""},
			[38] = {status = false, name = u8("Миниган"), take = u8"", away = u8""},
			[39] = {status = false, name = u8("Сумка с тротилом"), take = u8"", away = u8""}, 
			[40] = {status = false, name = u8("Детонатор к сумке"), take = u8"", away = u8""},
			[41] = {status = false, name = u8("Баллончик с краской"), take = u8"", away = u8""}, 
			[42] = {status = false, name = u8("Огнетушитель"), take = u8"", away = u8""},
			[43] = {status = false, name = u8("Фотоаппарат"), take = u8"", away = u8""},
			[44] = {status = false, name = u8("Прибор ночного видения"), take = u8"", away = u8""},
			[45] = {status = false, name = u8("Тепловизор"), take = u8"", away = u8""},
			[46] = {status = false, name = u8("Парашют"), take = u8"", away = u8""}
		},
		improved_dialogues = { 
			[1] = {status = true, name = u8("Диалог списка лидеров (/leaders)")},
			[2] = {status = true, name = u8("Диалог списка сотрудников (/find)")},
			[3] = {status = true, name = u8("Диалог списка розыскиваемых (/wanted)")},
			[4] = {status = true, name = u8("Диалог службы точного времени (/c 60)")},
			[5] = {status = true, name = u8("Диалог информации о АЗС (/fuel)")},
		},
		system_commands = {
			[1] = {name = "mh", status = true, callback = "command_mh", variations = {}, description = u8("Открывает основное меню.")},
			[2] = {name = "r", status = true, callback = "command_r", variations = {}, description = u8("Отправляет сообщение в рацию.")},
			[3] = {name = "f", status = true, callback = "command_f", variations = {}, description = u8("Отправляет сообщение в общую волну.")},
			[4] = {name = "rn", status = true, callback = "command_rn", variations = {}, description = u8("Отправляет NRP-сообщение в рацию.")},
			[5] = {name = "fn", status = true, callback = "command_fn", variations = {}, description = u8("Отправляет NRP-сообщение в общую волну.")},
			[6] = {name = "rep", status = true, callback = "command_rep", variations = {}, description = u8("Отправляет сообщение в репорт.")},
			[7] = {name = "uk", status = true, callback = "command_uk", variations = {}, description = u8("Открывает уголовный кодекс.")},
			[8] = {name = "ak", status = true, callback = "command_ak", variations = {}, description = u8("Открывает кодекс о административных правонарушениях.")},
			[9] = {name = "code", status = true, callback = "command_code", variations = {}, description = u8("Открывает список ten-кодов.")},
			[10] = {name = "sw", status = true, callback = "command_sw", variations = {}, description = u8("Изменяет ID погоды.")},
			[11] = {name = "st", status = true, callback = "command_st", variations = {}, description = u8("Изменяет игровое время.")},
			[12] = {name = "sskin", status = true, callback = "command_sskin", variations = {}, description = u8("Устанавливает виртуальный скин.")},
			[13] = {name = "history", status = true, callback = "command_history", variations = {}, description = u8("Проверяет историю изменения ников.")},
			[14] = {name = "lsms", status = true, callback = "command_lsms", variations = {}, description = u8("Отправляет SMS на последний номер.")},
			[15] = {name = "gov", status = true, callback = "command_gov", variations = {}, description = u8("Отправляет сообщение в гос.новости.")},
			[16] = {name = "addbl", status = true, callback = "command_addbl", variations = {}, description = u8("Добавляет человека в чёрный список (SMS).")},
			[17] = {name = "delbl", status = true, callback = "command_delbl", variations = {}, description = u8("Удаляет человека из чёрного списка (SMS).")},
			[18] = {name = "pay", status = true, callback = "command_pay", variations = {}, description = u8("Передаёт игроку некоторую сумму денег.")},
			[19] = {name = "users", status = true, callback = "command_users", variations = {}, description = u8("Открывает список пользователей (неактуально).")},
			[20] = {name = "rkinfo", status = true, callback = "command_rkinfo", variations = {}, description = u8("Выводит информацию о RK.")},
			[21] = {name = "sms", status = true, callback = "command_sms", variations = {}, description = u8("Отправляет SMS-сообщение игроку.")},
			[22] = {name = "open", status = true, callback = "command_open", variations = {}, description = u8("Открывает шлагбаум.")},
			[23] = {name = "rec", status = true, callback = "command_rec", variations = {}, description = u8("Обычный реконнект.")}, 
			[24] = {name = "recn", status = true, callback = "command_recn", variations = {}, description = u8("Реконнект со сменой ника.")},
			[25] = {name = "recd", status = true, callback = "command_recd", variations = {}, description = u8("Реконнект со сменой IP-адреса.")},
			[26] = {name = "rtag", status = true, callback = "command_rtag", variations = {}, description = u8("Открывает список радио тегов.")},
			[27] = {name = "strobes", status = true, callback = "command_strobes", variations = {}, description = u8("Активирует стробоскопы.")},
			[28] = {name = "lserver", status = true, callback = "command_lserver", variations = {}, description = u8("Открывает список избранных серверов.")},
			[29] = {name = "savepass", status = true, callback = "command_savepass", variations = {}, description = u8("Сохраняет пароль в менеджере аккаунтов.")},
			[30] = {name = "suspect", status = true, callback = "command_suspect", variations = {}, description = u8("Отображает информацию о подозреваемом.")},
			[31] = {name = "infred", status = true, callback = "command_infred", variations = {}, description = u8("Включает инфрокрасный режим.")},
			[32] = {name = "nigvis", status = true, callback = "command_nigvis", variations = {}, description = u8("Включает режим ночного виденья.")},
			[33] = {name = "gate", status = true, callback = "command_gate", variations = {}, description = u8("Открывает ворота.")},
			[34] = {name = "c", status = true, callback = "command_call", variations = {}, description = u8("Использование телефона.")},
			[35] = {name = "pull", status = true, callback = "command_pull", variations = {
				male = {
					[1] = {
						u8"/me подойдя к подозреваемому, толкнул его, тем самым скинув с байка.",
						u8"$wait 1500",
						u8"/pull {1}"
					},
					[2] = {
						u8"/me выхватил дубинку с тактического пояса и нанёс сильный удар по стеклу.",
						u8"$wait 1500",
						u8"/me открыл автомобильную дверь, схватился за одежду подозреваемого и вытащил его на землю.",
						u8"$wait 1000",
						u8"/pull {1}" 
					}
				},
				female = {
					[1] = {
						u8"/me подойдя к подозреваемому, толкнула его, тем самым скинув с байка.",
						u8"$wait 1500",
						u8"/pull {1}" 
					},
					[2] = {
						u8"/me выхватила дубинку с тактического пояса и нанесла сильный удар по стеклу.",
						u8"$wait 1500",
						u8"/me открыла автомобильную дверь, схватилась за одежду подозреваемого и вытащила его на землю.",
						u8"$wait 1000",
						u8"/pull {1}"
					}
				}
			}, description = u8("Вытаскивает игрока из автомобиля.")},
			[36] = {name = "cuff", status = true, callback = "command_cuff", variations = {
				male = {
					[1] = {
						u8("/me завёл руки нарушителя за спину, после чего растягнул чехол для наручников."),
						u8("$wait 1500"),
						u8("/me достав наручники из чехла, застегнул их на запястьях преступника."),
						u8("$wait 1000"),
						u8("/cuff {1}")
					},
					[2] = {
						u8("/me удерживая подозреваемого, растягнул один из чехлов на тактическом поясе."),
						u8("$wait 1500"),
						u8("/me достал из чехла наручники и надел их на запастья подозреваемого."),
						u8("$wait 1000"),
						u8("/cuff {1}")
					}
				},
				female = {
					[1] = {
						u8("/me завела руки нарушителя за спину, после чего растягнула чехол для наручников."),
						u8("$wait 1500"),
						u8("/me достав наручники из чехла, застегнула их на запястьях преступника."),
						u8("$wait 1000"),
						u8("/cuff {1}") 
					},
					[2] = {
						u8("/me удерживая подозреваемого, растягнула один из чехлов на тактическом поясе."),
						u8("$wait 1500"),
						u8("/me достала из чехла наручники и надела их на запастья подозреваемого."),
						u8("$wait 1000"),
						u8("/cuff {1}")
					}
				}
			}, description = u8("Одевает наручники с RP-отыгровками.")},
			[37] = {name = "uncuff", status = true, callback = "command_uncuff", variations = {
				male = {
					[1] = {
						u8("/do На запястьях $rpname.{1} находятся наручники."),
						u8("$wait 1500"),
						u8("/me из чехла, что находился на поясе, достал ключ и провернул его в замке наручников."),
						u8("$wait 1000"),
						u8("/uncuff {1}."),
						u8("$wait 1500"),
						u8("/me убрал наручники и специальный ключ по своим чехлам на поясе.")
					}
				},
				female = {
					[1] = {
						u8("/do На запястьях $rpname.{1} находятся наручники."),
						u8("$wait 1500"),
						u8("/me из чехла, что находился на поясе, достала ключ и провернула его в замке наручников."),
						u8("$wait 1000"),
						u8("/uncuff {1}."),
						u8("$wait 1500"),
						u8("/me убрала наручники и специальный ключ по своим чехлам на поясе.")
					}
				}
			}, description = u8("Снимает наручники с RP-отыгровками.")},
			[38] = {name = "arrest", status = true, callback = "command_arrest", variations = {
				male = {
					[1] = {
						u8("/me снял рацию с плеча, поднёс её ко рту и что-то произнёс."),
						u8("$wait 1500"),
						u8("/do Из департамента вышли два офицера и забрали подозреваемого с собой."),
						u8("$wait 1000"),
						u8("/arrest {1}"),
						u8("$wait 1000"),
						u8("/r Подозреваемый по делу #00{1} был отправлен под арест в областную тюрьму.")
					},
					[2] = {
						u8("/me снял тангету с плеча, зажал кнопку PTT и передал информацию о подозреваемом диспетчеру."),
						u8("$wait 1500"),
						u8("/do Из департамента вышли два офицера и забрали подозреваемого с собой."),
						u8("$wait 1000"),
						u8("/arrest {1}"),
						u8("$wait 1000"),
						u8("/r Подозреваемый по делу #00{1} был отправлен под арест в областную тюрьму.")
					}
				},
				female = {
					[1] = {
						u8("/me сняла рацию с плеча, поднесла её ко рту и что-то произнесла."),
						u8("$wait 1500"),
						u8("/do Из департамента вышли два офицера и забрали подозреваемого с собой."),
						u8("$wait 1000"),
						u8("/arrest {1}"),
						u8("$wait 1000"),
						u8("/r Подозреваемый по делу #00{1} был отправлен под арест в областную тюрьму.")
					},
					[2] = {
						u8("/me сняла тангету с плеча, зажала кнопку PTT и передала информацию о подозреваемом диспетчеру."),
						u8("$wait 1500"),
						u8("/do Из департамента вышли два офицера и забрали подозреваемого с собой."),
						u8("$wait 1000"),
						u8("/arrest {1}"),
						u8("$wait 1000"),
						u8("/r Подозреваемый по делу #00{1} был отправлен под арест в областную тюрьму.")
					}
				}
			}, description = u8("Передаёт подозреваемого под арест с RP-отыгровками.")},  
			[39] = {name = "su", status = true, callback = "command_su", variations = {
				male = {
					[1] = {
						u8("/me сняв тангету с плеча, передал диспетчеру информацию о подозреваемом."),
						u8("$wait 1000"),
						u8("/su {1} {2} {3}")
					},
					[2] = {
						u8("/me снял тангету с плеча, зажал кнопку PTT и передал информацию о подозреваемом диспетчеру."),
						u8("$wait 1000"),
						u8("/su {1} {2} {3}")
					}
				}, 
				female = {
					[1] = {
						u8("/me сняв тангету с плеча, передала диспетчеру информацию о подозреваемом."),
						u8("$wait 1000"),
						u8("/su {1} {2} {3}")
					},
					[2] = {
						u8("/me сняла тангету с плеча, зажала кнопку PTT и передала информацию о подозреваемом диспетчеру."),
						u8("$wait 1000"),
						u8("/su {1} {2} {3}")
					}
				}
			}, description = u8("Объявляет подозреваемого в розыск с RP-отыгровками.")},
			[40] = {name = "skip", status = true, callback = "command_skip", variations = {
				male = {
					[1] = {
						u8("/me из внутреннего кармана достал планшет и включил его."), u8("$wait 1500"),
						u8("/me зашёл в одно из приложений и оформил временный пропуск на имя $rpname.{1}."), u8("$wait 1000"),
						u8("/skip {1}"), u8("$wait 1500"),
						u8("/me потушил экран планшета и убрал его обратно."), u8("$wait 1500"),
						u8("/r Оформил временный пропуск в здания министерства на имя $rpname.{1}.")
					}
				},
				female = {
					[1] = {
						u8("/me из внутреннего кармана достала планшет и включила его."), u8("$wait 1500"),
						u8("/me зашла в одно из приложений и оформила временный пропуск на имя $rpname.{1}."), u8("$wait 1000"),
						u8("/skip {1}"), u8("$wait 1500"),
						u8("/me потушила экран планшета и убрала его обратно."), u8("$wait 1500"),
						u8("/r Оформила временный пропуск в здания министерства на имя $rpname.{1}.")
					}
				}
			}, description = u8("Выписывает временный пропуск игроку с RP-отыгровками.")},
			[41] = {name = "clear", status = true, callback = "command_clear", variations = {
				male = {
					[1] = {
						u8("/me из внутреннего кармана достал планшет и включил его."), 
						u8("$wait 1500"),
						u8("/me зашёл в одно из приложений и нашёл личное дело $rpname.{1}."), 
						u8("$wait 1500"),
						u8("/me пролистал страницу в самый низ, заполнил небольшую форму и аннулировал розыск."), 
						u8("$wait 1000"),
						u8("/clear {1}"), 
						u8("$wait 1500"),
						u8("/me потушил экран планшета и убрал его обратно."), 
						u8("$wait 1500"),
						u8("/f Подозреваемый по делу #00{1} более не числится в федеральном розыске."),
						u8("$wait 1000"),
						u8("/f Причина: {2}.")
					}
				},
				female = {
					[1] = {
						u8("/me из внутреннего кармана достала планшет и включила его."), 
						u8("$wait 1500"),
						u8("/me зашла в одно из приложений и нашла личное дело $rpname.{1}."), 
						u8("$wait 1500"),
						u8("/me пролистала страницу в самый низ, заполнила небольшую форму и аннулировала розыск."), 
						u8("$wait 1000"),
						u8("/clear {1}"),
						u8("$wait 1500"),
						u8("/me потушила экран планшета и убрала его обратно."), 
						u8("$wait 1500"),
						u8("/f Подозреваемый по делу #00{1} более не числится в федеральном розыске."), 
						u8("$wait 1000"),
						u8("/f Причина: {2}.")
					}
				}
			}, description = u8("Удаляет игрока из федерального розыска с RP-отыгровками.")},
			[42] = {name = "hold", status = true, callback = "command_hold", variations = {
				male = {
					[1] = {
						u8("/me заломав руку подозреваемого, повёл его за собой."),
						u8("$wait 1000"),
						u8("/hold {1}")
					},
					[2] = {
						u8("/me крепко схватил подозреваемого и потащил его за собой."),
						u8("$wait 1000"),
						u8("/hold {1}")
					}
				},
				female = {
					[1] = {
						u8("/me заломав руку подозреваемого, повела его за собой."),
						u8("$wait 1000"),
						u8("/hold {1}")
					},
					[2] = {
						u8("/me крепко схватила подозреваемого и потащила его за собой."),
						u8("$wait 1000"),
						u8("/hold {1}")
					}
				}
			}, description = u8("Принудительно тащит игрока за собой с RP-отыгровкой.")},
			[43] = {name = "ticket", status = true, callback = "command_ticket", variations = {
				male = {
					[1] = {
						u8("/me достал блокнот, ручку и начал записывать информацию о нарушении."),
						u8("$wait 1500"),
						u8("/me заполнив всю информацию о нарушении, передал бланк нарушителю."),
						u8("$wait 1000"),
						u8("/ticket {1} {2} {3}"),
						u8("$wait 1500"),
						u8("/me убрал блокнот и ручку обратно во внутренний карман.")
					}
				},
				female = {
					[1] = {
						u8("/me достала блокнот, ручку и начала записывать информацию о нарушении."),
						u8("$wait 1500"),
						u8("/me заполнив всю информацию о нарушении, передала бланк нарушителю."),
						u8("$wait 1000"),
						u8("/ticket {1} {2} {3}"),
						u8("$wait 1500"),
						u8("/me убрала блокнот и ручку обратно во внутренний карман.")
					}
				}
			}, description = u8("Выписывает штрафную квитанцию с RP-отыгровками.")},
			[44] = {name = "takelic", status = true, callback = "command_takelic", variations = {
				male = {
					[1] = {
						u8("/me достал планшет, зашёл в одно из приложений и нашёл нужный транспорт."),
						u8("$wait 1500"),
						u8("/me получил информацию о текущем водителе и отправил запрос на изъятие лицензии."),
						u8("$wait 1000"),
						u8("/takelic {1} {2}."),
						u8("$wait 1500"),
						u8("/me потушил экран и убрал планшет обратно.")
					}
				},
				female = {
					[1] = {
						u8("/me достала планшет, зашла в одно из приложений и нашла нужный транспорт."),
						u8("$wait 1500"),
						u8("/me получила информацию о текущем водителе и отправила запрос на изъятие лицензии."),
						u8("$wait 1000"),
						u8("/takelic {1} {2}."),
						u8("$wait 1500"),
						u8("/me потушила экран и убрала планшет обратно.")
					}
				}
			}, description = u8("Изымает лицензию на вождение с RP-отыгровками.")},
			[45] = {name = "putpl", status = true, callback = "command_putpl", variations = {
				male = {
					[1] = {
						u8("/me подведя подозреваемого к автомобилю, открыл дверь и посадил его туда."),
						u8("$wait 1000"),
						u8("/putpl {1}")
					},
					[2] = {
						u8("/me удерживая подозреваемого, свободной рукой открыл дверь в патрульном автомобиле."),
						u8("$wait 1500"),
						u8("/me пригнул голову подозреваемого и усадил его в машину, закрыл за ним дверь."),
						u8("$wait 1000"),
						u8("/putpl {1}")
					}
				},
				female = {
					[1] = {
						u8("/me подведя подозреваемого к автомобилю, открыла дверь и посадила его туда."),
						u8("$wait 1000"),
						u8("/putpl {1}")
					},
					[2] = {
						u8("/me удерживая подозреваемого, свободной рукой открыла дверь в патрульном автомобиле."),
						u8("$wait 1500"),
						u8("/me пригнула голову подозреваемого и усадила его в машину, закрыла за ним дверь."),
						u8("$wait 1000"),
						u8("/putpl {1}")
					}
				}
			}, description = u8("Усаживает подозреваемого в автомобиль с RP-отыгровками.")},
			[46] = {name = "rights", status = true, callback = "command_rights", variations = {
				male = {
					[1] = {
						u8("Вы имеете право хранить молчание. "),
						u8("$wait 1500"),
						u8("Всё, что вы скажете, может и будет использовано против вас в суде. "),
						u8("$wait 1500"),
						u8("Ваш адвокат может присутствовать при допросе. "),
						u8("$wait 1500"),
						u8("Если вы не можете оплатить услуги адвоката, он будет предоставлен вам государством."),
						u8("$wait 1500"),
						u8("Если вы не гражданин, то вы можете связаться с консулом своей страны, прежде чем отвечать на любые вопросы."),
						u8("$wait 1500"),
						u8("Всё ли вам понятно?")
					}
				},
				female = {
					[1] = {
						u8("Вы имеете право хранить молчание. "),
						u8("$wait 1500"),
						u8("Всё, что вы скажете, может и будет использовано против вас в суде. "),
						u8("$wait 1500"),
						u8("Ваш адвокат может присутствовать при допросе. "),
						u8("$wait 1500"),
						u8("Если вы не можете оплатить услуги адвоката, он будет предоставлен вам государством."),
						u8("$wait 1500"),
						u8("Если вы не гражданин, то вы можете связаться с консулом своей страны, прежде чем отвечать на любые вопросы."),
						u8("$wait 1500"),
						u8("Всё ли вам понятно?")
					}
				}
			}, description = u8("Зачитывает задержанному права.")},
			[47] = {name = "search", status = true, callback = "command_search", variations = {
				male = {
					[1] = {
						u8("/me из внутреннего кармана достал белые, латекстные перчатки и надел их на руки."),
						u8("$wait 1500"),
						u8("/me осмотривает все карманы, возможные места хранение запрещённых веществ и предметов."),
						u8("$wait 1000"),
						u8("/search {1}")
					}
				},
				female = {
					[1] = {
						u8("/me из внутреннего кармана достала белые, латекстные перчатки и надела их на руки."),
						u8("$wait 1500"),
						u8("/me осмотривает все карманы, возможные места хранение запрещённых веществ и предметов."),
						u8("$wait 1000"),
						u8("/search {1}")
					}
				}
			}, description = u8("Производит поверхностный обыск с RP-отыгровками.")},
			[48] = {name = "hack", status = true, callback = "command_hack", variations = {
				male = {
					[1] = {
						u8("/do На плечах висит рюкзак в котором лежит балончик с заморозкой."),
						u8("$wait 1500"),
						u8("/me скинув рюкзак с плеч, открыл его и достал балончик."),
						u8("$wait 1500"),
						u8("/me закрыл рюкзак и повесил его на плечи."),
						u8("$wait 1500"),
						u8("/me встряхнув балончик, распылил содержимое на дверной замок."),
						u8("$wait 1500"),
						u8("/do Под действием содержимого балончика замок промёрз и стал хрупок."),
						u8("$wait 1500"),
						u8("/me снял дубинку с поясного держателя и, размахнувшись, ударил тыльной частью по замку."),
						u8("$wait 1000"),
						u8("/hack {1}")
					}
				},
				female = {
					[1] = {
						u8("/do На плечах висит рюкзак в котором лежит балончик с заморозкой."),
						u8("$wait 1500"),
						u8("/me скинув рюкзак с плеч, открыла его и достал балончик."),
						u8("$wait 1500"),
						u8("/me закрыла рюкзак и повесила его на плечи."),
						u8("$wait 1500"),
						u8("/me встряхнув балончик, распылила содержимое на дверной замок."),
						u8("$wait 1500"),
						u8("/do Под действием содержимого балончика замок промёрз и стал хрупок."),
						u8("$wait 1500"),
						u8("/me сняла дубинку с поясного держателя и, размахнувшись, ударила тыльной частью по замку."),
						u8("$wait 1000"),
						u8("/hack {1}")
					}
				}
			}, description = u8("Взламывает дверь дома с RP-отыгровками.")},
			[49] = {name = "invite", status = true, callback = "command_invite", variations = {
				male = {
					[1] = {
						u8("/me из внутреннего кармана достал планшет, включил его и зашёл в одно из приложений."),
						u8("$wait 1500"),
						u8("/me заполнил небольшую форму и добавил новое личное дело под номером #00{1}."),
						u8("$wait 1500"),
						u8("/me потушил экран планшета и убрал его обратно."),
						u8("$wait 1500"),
						u8("/me достал ключ от шкафчика под номером #00{1} и передал его $rpname.{1}."),
						u8("$wait 1000"),
						u8("/invite {1}")
					}
				},
				female = {
					[1] = {
						u8("/me из внутреннего кармана достала планшет, включила его и зашла в одно из приложений."),
						u8("$wait 1500"),
						u8("/me заполнила небольшую форму и добавила новое личное дело под номером #00{1}."),
						u8("$wait 1500"),
						u8("/me потушила экран планшета и убрала его обратно."),
						u8("$wait 1500"),
						u8("/me достала ключ от шкафчика под номером #00{1} и передала его $rpname.{1}."),
						u8("$wait 1000"),
						u8("/invite {1}")
					}
				}
			}, description = u8("Принимает игрока в организацию с RP-отыгровками.")},
			[50] = {name = "uninvite", status = true, callback = "command_uninvite", variations = {
				male = {
					[1] = {
						u8("/me из внутреннего кармана достал планшет, включил его и зашёл в одно из приложений."),
						u8("$wait 1500"),
						u8("/me нашёл личное дело под номером #00{1} и удалил его."),
						u8("$wait 1000"),
						u8("/uninvite {1} {2}"),
						u8("$wait 1500"),
						u8("/me потушил экран планшета и убрал его обратно."),
						u8("$wait 1000"),
						u8("/f Контракт с сотрудником $rpname.{1} расторгнут по причине: {2}.")
					}
				},
				female = {
					[1] = {
						u8("/me из внутреннего кармана достала планшет, включила его и зашла в одно из приложений."),
						u8("$wait 1500"),
						u8("/me нашла личное дело под номером #00{1} и удалила его."),
						u8("$wait 1000"),
						u8("/uninvite {1} {2}"),
						u8("$wait 1500"),
						u8("/me потушила экран планшета и убрала его обратно."),
						u8("$wait 1000"),
						u8("/f Контракт с сотрудником $rpname.{1} расторгнут по причине: {2}.")
					}
				}
			}, description = u8("Увольняет игрока из организации с RP-отыгровками.")},
			[51] = {name = "rang", status = true, callback = "command_rang", variations = {
				male = {
					[1] = {
						u8("/me из внутреннего кармана достал планшет, включил его и зашёл в одно из приложений."),
						u8("$wait 1500"),
						u8("/me нашёл личное дело под номером #00{1} и изменил значение должности."),
						u8("$wait 1000"),
						u8("/rang {1} {2}"),
						u8("$wait 1500"),
						u8("/me потушил экран планшета и убрал его обратно.")
					}
				},
				female = {
					[1] = {
						u8("/me из внутреннего кармана достала планшет, включила его и зашла в одно из приложений."),
						u8("$wait 1500"),
						u8("/me нашла личное дело под номером #00{1} и изменила значение должности."),
						u8("$wait 1000"),
						u8("/rang {1} {2}"),
						u8("$wait 1500"),
						u8("/me потушила экран планшета и убрала его обратно.")
					}
				}
			}, description = u8("Изменяет должность игрока с RP-отыгровками.")},
			[52] = {name = "changeskin", status = true, callback = "command_changeskin", variations = {
				male = {
					[1] = {
						u8("/me достал ключ от шкафчика под номером #00{1} и передал его $rpname.{1}."),
						u8("$wait 1000"),
						u8("/changeskin {1}")
					}
				},
				female = {
					[1] = {
						u8("/me достала ключ от шкафчика под номером #00{1} и передала его $rpname.{1}."),
						u8("$wait 1000"),
						u8("/changeskin {1}")
					}
				}
			}, description = u8("Изменяет внешний вид игрока с RP-отыгровками.")},
			[53] = {name = "ud", status = true, callback = "command_ud", variations = {
				male = {
					[1] = {
						u8("/me достал удостоверение, раскрыл его и показал человеку напротив."),
						u8("$wait 1500"),
						u8("/do В удостоверении указано подразделение: {fraction}."),
						u8("$wait 1000"),
						u8("/do Личная информация: {rang} {name} [#{number}]."),
						u8("$wait 1500"),
						u8("/me закрыл удостоверение и убрал его обратно.")
					}
				},
				female = {
					[1] = {
						u8("/me достала удостоверение, раскрыла его и показала человеку напротив."),
						u8("$wait 1500"),
						u8("/do В удостоверении указано подразделение: {fraction}."),
						u8("$wait 1000"),
						u8("/do Личная информация: {rang} {name} [#{number}]."),
						u8("$wait 1500"),
						u8("/me закрыла удостоверение и убрала его обратно.")
					}
				} 
			}, description = u8("Показывает удостоверение с RP-отыгровками.")},
			[54] = {name = "pas", status = true, callback = "command_pas", variations = {
				male = {
					[1] = {
						u8("{greeting}, я {rang} {fraction} {name}."),
						u8("$wait 1500"),
						u8("/do На груди висит значок с личным номером [#{number}]."),
						u8("$wait 1500"),
						u8("Будьте любезны, предъявите документы, удостоверяющие вашу личность.")
					}
				},
				female = {
					[1] = {
						u8("{greeting}, я {rang} {fraction} {name}."),
						u8("$wait 1500"),
						u8("/do На груди висит значок с личным номером [#{number}]."),
						u8("$wait 1500"),
						u8("Будьте любезны, предъявите документы, удостоверяющие вашу личность.")
					}
				}
			}, description = u8("Запрашивает документы с RP-отыгровками.")},
			[55] = {name = u8"мегафон", status = true, callback = "command_megafon", variations = {}, description = u8("Отправляет требование ближайшему водителю Т/С остановится.")},
			[56] = {name = "drop_all", status = true, callback = "command_drop_all", variations = {}, description = u8("Быстро выбрасывает всё оружие.")},
			[57] = {name = "patrol", status = true, callback = "command_patrol", variations = {}, description = u8("Начинает патрулирование и открывает патрульное меню.")},
			[58] = {name = "fuel", status = true, callback = "command_fuel", variations = {}, description = u8("Отображает список АЗС.")},
			[59] = {name = "speller", status = true, callback = "command_speller", variations = {}, description = u8("Проверяет правильность написания слов.")},
			[60] = {name = "savepass", status = true, callback = "command_savepass", variations = {}, description = u8("Сохраняет пароль в менеджере аккаунтов.")},
			[61] = {name = "helper_stats", status = true, callback = "command_helper_stats", variations = {}, description = u8("Статистика действий пользователя.")},
			[62] = {name = "goverment_news", status = true, callback = "command_goverment_news", variations = {}, description = u8("Лог последних гос.новостей.")},
		},
		blacklist = {
			Joachim_Ribbentrop = false
		},
		customization = {}
	})
	
	local result = configuration_main1:get()
	if result then configuration_main = result else configuration_main = configuration_main1["template"] end
    -- configuration_main1:close()  
else print("Не удалось подгрузить основную конфигурацию (Код ошибки: #1).") end

local configuration_custom = {}
local configuration_custom1 = xconf.new(string.format("%s//Additional user settings.json", configuration_directory))
if configuration_custom1 then 
	configuration_custom1:set_template({
		standard = {}
	})
	local result = configuration_custom1:get()
	if result then configuration_custom = result else configuration_custom = configuration_custom1["template"] end
else print("Не удалось подгрузить дополнительную конфигурацию (Код ошибки: #2).") end

local configuration_manager = {}
local configuration_manager1 = xconf.new(string.format("%s//Account and server manager.json", configuration_directory))
if configuration_manager1 then 
	local result = configuration_manager1:get()
	if result then configuration_manager = result else configuration_manager = {} end
else print("Не удалось подгрузить конфигурацию менеджера аккаунтов и серверов (Код ошибки: #3).") end

local configuration_statistics = {}
local configuration_statistics1 = xconf.new(string.format("%s//User statistics.json", configuration_directory))
if configuration_statistics1 then 
	configuration_statistics1:set_template({
		commands = {},
		message = 0,
		time_using_aid_kits = 0,
		time_using_mask = 0,
		number_masks_used = 0,
		afk_time = 0
	})

	local result = configuration_statistics1:get()
	if result then configuration_statistics = result else configuration_statistics = configuration_statistics1["template"] end
else print("Не удалось подгрузить конфигурацию статистики (Код ошибки: #4).") end

local configuration_database = {}
local configuration_database1 = xconf.new(string.format("%s//Local database.json", configuration_directory))
if configuration_database1 then 
	configuration_database1:set_template({
		player = {},
		house = {},
		vehicle = {}
	})

	local result = configuration_database1:get()
	if result then configuration_database = result else configuration_database = configuration_database1["template"] end
else print("Не удалось подгрузить конфигурацию статистики (Код ошибки: #5).") end
-- !global value
 
-- local value
local global_profile = "standard"
local search_playerId
local invite_playerId
local invite_rang
local passport_check
local report_text
local patrol_code
local smart_suspect_id
local last_sms_number
local global_reconnect_status
local infrared_vision
local night_vision
local delay_between_deaths
local font_size = new.int(0)
local string_found = new.char[256]()
local string_name = new.char[256](configuration_main["information"]["name"])
local string_rang = new.char[256](configuration_main["information"]["rang"])
local string_fraction = new.char[256](configuration_main["information"]["fraction"])
local string_number = new.char[256](configuration_main["information"]["number"])
local string_rtag = new.char[256](configuration_main["information"]["rtag"])
local string_ftag = new.char[256](configuration_main["information"]["ftag"])
local show_main_menu = new.bool(false)
local show_smart_criminal_code = new.bool(false)
local show_smart_administrative_code = new.bool(false)
local show_setting_up_fast_suspect = new.bool(false)
local show_setting_patrol = new.bool(false)
local show_patrol_bar = new.bool(false)
local show_gas_station = new.bool(false)
local show_quick_menu = new.bool(false)
local show_editor_assistant = new.bool(false)
local navigation_page = 1
local setting_page = 1
local setting_take_weapon = false
local weapon_acting_out = {}
local aid_timer
local mask_timer
local t_delay_between_deaths = new.int(configuration_main["settings"]["delay_between_deaths"])
local binder_work_status = 1
local binder = {}
local user_slots_value = 15
local last_requirement = {}
local hotkey_id = {}
local criminal_code = {}
local administrative_code = {}
local smart_suspect_id
local smart_ticket_id
local lookup_table = {}
local lookup_table_a = {}
local list_users = {}
local need_to_purchase = {}
local b_stroboscopes = false
local quick_suspect = {}
local quick_report = {}
local last_suspect_parametrs = {}
local viewing_criminal_code = false
local viewing_administrative_code = false
local setting_up_fast_suspect = {}
local player_status = 0
local patrol_status = {}
local t_patrol_status = {}
local accept_the_offer
local imgui_patrol_list = new('const char* const [10]', {"L (Lincoln)", "A (Adam)", "M (Merry)", "C (Charley)", "D (David)", "H (Henry)", "ASD (Air Support Division)", "SUPERVISOR"})
local convert_patrol_list = {"L", "A", "M", "C", "D", "H", "ASD", "SUPERVISOR"}
local imgui_patrol_current = new.int(0)
local imgui_patrol_number = new.char[256]()
local imgui_custom_float = new.float(0)
local pricel
local flymode
local camera = {}
local player_serial
local t_gas_station = {}
local map_marker = {}
local last_on_send_value
local imgui_manager_ip = new.char[256]()
local imgui_manager_nickname = new.char[256]()
local imgui_manager_password = new.char[256]()
local imgui_manager_gauth = new.char[256]()
local imgui_manager_bool
local entered_password
local entered_to_save_password
local goverment_news = {}
local need_update_configuration
local targeting_player = -1
local imgui_custom_chat = new.char[256]()
local pause_start
local was_pause
local binder_sc = {}
local color_picker = configuration_main["customization"]["Button"] and new.float[3](configuration_main["customization"]["Button"]["r"], configuration_main["customization"]["Button"]["g"], configuration_main["customization"]["Button"]["b"]) or new.float[3]()
local string_database_player = new.char[256]()
local string_database_house = new.char[256]()
local lookup_database_player = {}
local lookup_database_house = {}
local found_house
local add_house_in_base
local add_player_to_base
local quick_menu_list = {}
local global_break_command
local global_command_handler
-- !local value

-- const 
local abbreviated_codes = {
	["cod 11"] = {"$m to DISP, занимаю маркировку $m, CODE 1-1, доступен.", function() patrol_status["status"] = 4 end},
	["cod 13"] = {"$m to DISP, завершаю патрулирование, освобождаю маркировку $m, CODE 1-3, недоступен.", function() patrol_status["status"]= 4 end},
	["cod 14"] = {"$m to DISP, доставляю подозреваемого в департамент, CODE 1-4, недоступен.", function() patrol_status["status"] = 4 end},
	["tf 55"] = {"$m to DISP, провожу траффик-стоп '55, CODE 4, нахожусь в районе $p, недоступен.", function() patrol_status["status"] = 4 end},
	["tf 66"] = {"$m to DISP, провожу траффик-стоп '66, CODE 3, нахожусь в районе $p, недоступен.", function() patrol_status["status"] = 3 end}, 
	["cod 0"] = {"$m to DISP, CODE 0, требуется срочная помощь в район $p, недоступен.", function() patrol_status["status"] = 0 end},
	["cod 1"] = {"$m to DISP, CODE 1, требуется помощь в район $p, недоступен.", function() patrol_status["status"] = 1 end}, 
	["s 99"] = {"$m to DISP, 10-99 по последней ситуации, CODE: 4, доступен.", function() patrol_status["status"] = 4 end}
}
local t_fuel_station = {
	[0] = {x = 1941.6208496094, y = -1769.3118896484, z = 13.640625},
	[1] = {x = 1000.4306640625, y = -937.40905761719, z = 42.328125},
	[2] = {x = 655.79522705078, y = -564.87713623047, z = 15.903906822205},
	[3] = {x = -2244.2521972656, y = -2560.7556152344, z = 31.488304138184},
	[4] = {x = -1606.1212158203, y = -2713.9748535156, z = 48.099872589111},
	[5] = {x = -2025.7088623047, y = 156.74633789063, z = 29.0390625},
	[6] = {x = -2410.0356445313, y = 976.25115966797, z = 45.425102233887},
	[7] = {x = -1675.8916015625, y = 412.89123535156, z = 6.7495198249817},
	[8] = {x = -1328.3719482422, y = 2677.5046386719, z = 49.629257202148},
	[9] = {x = -91.141693115234, y = -1169.1536865234, z = 1.9911493062973},
	[10] = {x = 1381.5281982422, y = 459.86477661133, z = 20.345203399658},
	[11] = {x = 612.16564941406, y = 1695.0120849609, z = 6.5607070922852},
	[12] = {x = -1471.1192626953, y = 1864.021484375, z = 32.202579498291},
	[13] = {x = 2202.7873535156, y = 2474.4704589844, z = 10.390445709229},
	[14] = {x = 2115.2702636719, y = 920.24621582031, z = 10.383306503296},
	[15] = {x = 2639.9272460938, y = 1106.2498779297, z = 10.390357971191},
	[16] = {x = 2147.9555664063, y = 2747.6809082031, z = 10.389307022095},
	[17] = {x = 1595.7800292969, y = 2199.4895019531, z = 10.382888793945},
	[18] = {x = -1530.6135253906, y = -1590.4718017578, z = 37.813919067383},
	[19] = {x = -220.83619689941, y = 2601.8581542969, z = 62.273105621338},
	[20] = {x = -214.10762023926, y = -277.92230224609, z = 0.99726545810699}
}
local maximum_number_of_characters = {["me"] = 90, ["do"] = 75, ["r"] = 80, ["f"] = 80, ["g"] = 80}
local lcons = {}
local w, h = getScreenResolution()
local imgui_script_name = u8"название забыли написать"
-- !const
 
 -- mimgui
 local function loadIconicFont(fontSize) 
	-- Load iconic font in merge mode
	local config = imgui.ImFontConfig()
	config.MergeMode = true
	config.PixelSnapH = true
	local iconRanges = new.ImWchar[3](faicons.min_range, faicons.max_range, 0)
	imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(faicons.get_font_data_base85(), fontSize, config, iconRanges)
end
 
imgui.OnInitialize(function() 
	local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
	
	imgui.GetIO().Fonts:Clear()
	imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. "\\tahomabd.ttf", 13, nil, glyph_ranges)
	font_size[0] = imgui.GetIO().Fonts.ConfigData.Data[0].SizePixels
	
	loadIconicFont(font_size[0])
	apply_custom_style()
	
	for index, value in pairs(configuration_main["weapon_acting_out"]) do
		if not string.find(value["name"], "weapon") then
			weapon_acting_out[index] = {
				take = new.char[256](value["take"]),
				away = new.char[256](value["away"])
			}
		end
	end
	
	for index, value in pairs(configuration_main["quick_menu"]) do
		quick_menu_list[index] = {
			title = value["title"],
			callback = function()
				_G[value["callback"]](targeting_player)
			end
		}
	end
end)

imgui.OnFrame(function() return show_quick_menu[0] end,
function()
	imgui.SetNextWindowBgAlpha(0.0)
	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), nil, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(400, 400))
	imgui.Begin("##quickmenu", nil, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoMove + imgui.WindowFlags.NoResize)
		
		displaying_quick_menu(quick_menu_list)
		
	imgui.End()
end)

imgui.OnFrame(function() return show_editor_assistant[0] end,
function()
	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(470, 500))
	imgui.Begin(string.format("%s##8", imgui_script_name), show_editor_assistant, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		local tags = {
			{"$name./number/", "Возращает nickname игрока по его ID.", "$name.100, $name.{1}, $name.{targeting} (примеры)"},
			{"$rpname./number/", "Возращает nickname игрока в RP-формате.", "$rpname.100, $rpname.{1}, $rpname.{targeting} (примеры)"},
			{"$wait", "Устанавливает задержку между строками (в мс).", "$wait 1000 (пример)"},
			{"$chat", "Отправляет сообщение пользователю.", "$chat Ты умер :( (пример)"},
			{"$script", "Активирует исполнение сценария.", "$script default, test, 1 (пример)"},
			{"$global", "Активирует исполнение функции.", "$global command_cuff, {targeting} (пример)"},
			{"{greeting}", "Приветствие в зависимости от времени суток.", greeting_depending_on_the_time()},
			{"{name}", "Ваше имя из конфигурации.", configuration_main["information"]["name"]},
			{"{rang}", "Ваша должность из конфигурации.", configuration_main["information"]["rang"]},
			{"{fraction}", "Ваше подразделение из конфигурации.", configuration_main["information"]["fraction"]},
			{"{number}", "Ваш номер из конфигурации.", configuration_main["information"]["number"]},
			{"{targeting}", "ID игрока, в которого вы целитесь.", targeting_player},
			{"{suspect}", "ID игрока, добавленного в быстрый розыск.", quick_suspect["playerId"] or "-1"},
			{"{date}", "Дата.", os.date("%d.%m.%Y")},
			{"{day}", "День месяца.", os.date("%d")},
			{"{month}", "Месяц.", os.date("%m")},
			{"{year}", "Год (2 цифры).", os.date("%y")},
			{"{year4}", "Год (4 цифры).", os.date("%Y")},
			{"{day_of_week}", "День недели (англ.)", os.date("%A")},
			{"{time}", "Время.", os.date("%H:%M:%S")},
			{"{hour}", "Час.", os.date("%H")},
			{"{minute}", "Минута.", os.date("%M")},
			{"{second}", "Секунда.", os.date("%S")}
		}
		 
		imgui.Columns(3)
		imgui.Separator()
		imgui.SetColumnWidth(-1, 20) imgui.CenterColumnText(u8"#") imgui.NextColumn()
		imgui.SetColumnWidth(-1, 140) imgui.CenterColumnText(u8"ТЭГ") imgui.NextColumn()
		imgui.SetColumnWidth(-1, 310) imgui.CenterColumnText(u8"ОПИСАНИЕ") imgui.NextColumn()
		imgui.Separator()
		
		for k, v in pairs(tags) do
			imgui.CenterColumnText(tostring(k)) imgui.NextColumn()
			if imgui.Button(v[1], imgui.ImVec2(120, 20)) then
				setClipboardText(v[1])
			end showHelpMarker(u8"Нажмите, чтобы скопировать.") imgui.NextColumn()
			imgui.Text(u8(v[2])) showHelpMarker(u8(string.format("Значение: %s", v[3]))) imgui.NextColumn()
		end
	
	imgui.End()
end)

imgui.OnFrame(function() return show_gas_station[0] end,
function(player)
	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(470, 500))
	imgui.Begin(string.format("%s##7", imgui_script_name), show_gas_station, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		imgui.Columns(5)
		imgui.Separator()
		imgui.SetColumnWidth(-1, 20) imgui.CenterColumnText(u8"#") imgui.NextColumn()
		imgui.SetColumnWidth(-1, 150) imgui.CenterColumnText(u8"НАЗВАНИЕ") imgui.NextColumn()
		imgui.SetColumnWidth(-1, 100) imgui.CenterColumnText(u8"СТОИМОСТЬ") imgui.NextColumn()
		imgui.SetColumnWidth(-1, 100) imgui.CenterColumnText(u8"ТОПЛИВО") imgui.NextColumn()
		imgui.SetColumnWidth(-1, 100) imgui.CenterColumnText(u8"РАССТОЯНИЕ") imgui.NextColumn()
		imgui.Separator()
		
		local x, y, z = getCharCoordinates(playerPed)
		for index, value in ipairs(t_gas_station) do
			local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, t_fuel_station[tonumber(value["id"])]["x"], t_fuel_station[tonumber(value["id"])]["y"], t_fuel_station[tonumber(value["id"])]["z"]))
			imgui.CenterColumnText(tostring(index)) imgui.NextColumn()
			if imgui.Button(u8(value["gas_station"]), imgui.ImVec2(130, 20)) then
				map_marker[#map_marker + 1] = {
					x = t_fuel_station[tonumber(value["id"])]["x"], 
					y = t_fuel_station[tonumber(value["id"])]["y"], 
					z = t_fuel_station[tonumber(value["id"])]["z"]
				} 
				chat(string.format("На вашем радаре отмечена {COLOR}%s{}, расстояние до неё {COLOR}%s{} м.", value["gas_station"], distance))
			end imgui.NextColumn()
			imgui.CenterColumnText(string.format("%s$", value["cost"])) imgui.NextColumn()
			imgui.CenterColumnText(string.format(u8"%s л", value["fuel"])) imgui.NextColumn()
			imgui.CenterColumnText(string.format(u8"%s м", distance)) imgui.NextColumn()
		end
	imgui.End()
end)

imgui.OnFrame(function() return show_patrol_bar[0] end,
function(player)
	imgui.SetNextWindowPos(imgui.ImVec2(40, h / 2), imgui.Cond.FirstUseEver)
	imgui.SetNextWindowSize(imgui.ImVec2(265, 92))
	imgui.Begin(string.format("%s##6", imgui_script_name), show_setting_patrol, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		player.HideCursor = not isKeyDown(VK_MBUTTON)
		
		local alltime = math.floor(os.clock() - patrol_status["clock"])
		imgui.CustomButton(u8"В ПАТРУЛЕ", imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(130, 20)) imgui.SameLine()
		imgui.Button(string.format(u8"%s:%s", math.floor(alltime / 60), math.fmod(alltime, 60)), imgui.ImVec2(100, 20))		
		
		local mark = string.format("%s-%s", patrol_status["mark"], patrol_status["number"])
		imgui.CustomButton(u8"МАРКИРОВКА ЮНИТА", imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(130, 20)) imgui.SameLine()
		imgui.Button(string.format("%s", mark), imgui.ImVec2(100, 20))

		local code = patrol_status["status"]
		imgui.CustomButton(u8"КОД-СТАТУС", imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(130, 20)) imgui.SameLine()
		imgui.Button(string.format("CODE %s", code), imgui.ImVec2(100, 20))
	imgui.End()
end)

imgui.OnFrame(function() return show_setting_patrol[0] end,
function()
	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(360, 135))
	imgui.Begin(string.format("%s##5", imgui_script_name), show_setting_patrol, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		imgui.CustomButton(u8"Маркировка юнита", imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(120, 20))  imgui.SameLine() 
		imgui.PushItemWidth(90)--45)
		if imgui.Combo("##combo", imgui_patrol_current, imgui_patrol_list, 8) then 
			t_patrol_status["mark"] = convert_patrol_list[imgui_patrol_current[0] + 1]
		end imgui.SameLine()
		if imgui.Button(u8"ОПРЕДЕЛИТЬ", imgui.ImVec2(110, 20)) then
			local mark, number = sampGetMarkCharByVehicle(playerPed)
			imgui_patrol_current[0] = number
			t_patrol_status["mark"] = mark
		end showHelpMarker(u8"Автоматически определит маркировку для вашего юнита.")
		
		imgui.CustomButton(u8"Номер юнита", imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(120, 20))  imgui.SameLine() 
		imgui.PushItemWidth(90)
		if imgui.InputTextWithHint("##unitnumber", u8"(1 - 99)", imgui_patrol_number, 10) then
			local number = tonumber(str(imgui_patrol_number))
			if not number or number < 0 or number > 99 then imgui_patrol_number = new.char[256]() end
			t_patrol_status["number"] = number
		end
		--.Button(string.format("%s##unit_number", t_patrol_status["number"] or ""), imgui.ImVec2(90, 20))
		imgui.SameLine()
		if imgui.Button(u8"СГЕНЕРИРОВАТЬ", imgui.ImVec2(110, 20)) then 
			local random = math.random(1, 100)
			imgui_patrol_number = new.char[256](tostring(random))
			t_patrol_status["number"] = random
		end showHelpMarker(u8"Сгенерирует уникальный номер юнита.")
		
		imgui.NewLine()
		
		if patrol_status["status"] then
			if t_patrol_status["mark"] == patrol_status["mark"] and t_patrol_status["number"] == patrol_status["number"] then
				imgui.SetCursorPosX(85)
				if imgui.Button(u8"ЗАВЕРШИТЬ ПАТРУЛИРОВАНИЕ") then
					command_r("cod 13")
					show_patrol_bar[0] = false
					patrol_status = {}
				end
			else
				imgui.SetCursorPosX(18)
				if imgui.Button(u8"ОБНОВИТЬ ДАННЫЕ") then
					command_r(string.format("$m to DISP, меняю маркировку с текущей на %s-%s, доступен.", t_patrol_status["mark"], t_patrol_status["number"]))
					patrol_status = {
						status = 4,
						mark = t_patrol_status["mark"],
						number = t_patrol_status["number"],
						clock = patrol_status["clock"]
					}
				end imgui.SameLine()
			
				if imgui.Button(u8"ЗАВЕРШИТЬ ПАТРУЛИРОВАНИЕ") then
					command_r("cod 13")
					show_patrol_bar[0] = false
					patrol_status = {}
				end
			end
		else
			imgui.SetCursorPosX(95)
			if imgui.Button(u8"НАЧАТЬ ПАТРУЛИРОВАНИЕ") then
				if t_patrol_status["mark"] and t_patrol_status["number"] then
					patrol_status = {
						status = 4,
						mark = t_patrol_status["mark"],
						number = t_patrol_status["number"],
						clock = os.clock()
					}
					show_patrol_bar[0] = true
					command_r("cod 11")
				else chat("Для начала необходимо указать маркировку и номер юнита.") end
			end
		end
	imgui.End()
end)

imgui.OnFrame(function() return show_setting_up_fast_suspect[0] end,
function()
	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(470, 170))
	imgui.Begin(string.format("%s##4", imgui_script_name), show_setting_up_fast_suspect, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		imgui.CenterText(u8(string.format("Статья выбранная для редактирования %s, количество звёзд %d.", u8:decode(setting_up_fast_suspect["reason"]), setting_up_fast_suspect["stars"])))
		imgui.CenterText(u8"Выберите нарушение, за которое будет выдан розыск с причиной выше.")
		imgui.NewLine()
		
		if imgui.Button(u8"Неподчинение сотруднику МЮ", imgui.ImVec2(450, 20)) then
			if setting_up_fast_suspect then
				configuration_main["quick_criminal_code"]["insubordination"] = setting_up_fast_suspect
				if not need_update_configuration then need_update_configuration = os.clock() end
				chat(string.format("Статья за неподчинение сотруднику МЮ изменена на %s, %s-й уровень розыска.", setting_up_fast_suspect["reason"], setting_up_fast_suspect["stars"]))
				show_setting_up_fast_suspect[0] = false
				return
			end
		end
		
		if imgui.Button(u8"Отказ от оплаты штрафа", imgui.ImVec2(450, 20)) then
			if setting_up_fast_suspect then
				configuration_main["quick_criminal_code"]["refusal_to_pay"] = setting_up_fast_suspect
				if not need_update_configuration then need_update_configuration = os.clock() end
				chat(string.format("Статья за отказ от оплаты штрафа изменена на %s, %s-й уровень розыска.", setting_up_fast_suspect["reason"], setting_up_fast_suspect["stars"]))
				show_setting_up_fast_suspect[0] = false
				return
			end
		end
		
		if imgui.Button(u8"Нападение на сотрудника МЮ", imgui.ImVec2(450, 20)) then
			if setting_up_fast_suspect then
				configuration_main["quick_criminal_code"]["attack"] = setting_up_fast_suspect
				if not need_update_configuration then need_update_configuration = os.clock() end
				chat(string.format("Статья за нападение на сотрудника МЮ изменена на %s, %s-й уровень розыска.", setting_up_fast_suspect["reason"], setting_up_fast_suspect["stars"]))
				show_setting_up_fast_suspect[0] = false
				return
			end
		end
	imgui.End()
end)

imgui.OnFrame(function() return show_smart_criminal_code[0] end,
function()
	if smart_suspect_id and not isPlayerConnected(smart_suspect_id) then 
		if not viewing_criminal_code then
			show_smart_criminal_code[0] = false 
			chat("Подозреваемый покинул игру.")
			return 
		end
	end

	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(570, 600))
	imgui.Begin(string.format("%s##2", imgui_script_name), show_smart_criminal_code, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		imgui.PushItemWidth(545)
		if imgui.InputTextWithHint("##criminal_code", u8"Введите статью или часть её содержания", string_found, 50) then
			lookup_table = {}
			for article, value in pairs(criminal_code) do
				lookup_table[article] = true
				local search = u8:decode(str(string_found))
				if string.match(tostring(article), search) or string.match(value["name"], search) then lookup_table[article] = false end
				if lookup_table[article] then
					for part, content in pairs(value["content"]) do
						if string.match(content["text"], search) then
							lookup_table[article] = false
						end
					end
				end
			end
		end
		
		for article, value in pairs(criminal_code) do
			if not lookup_table[article] then
				if imgui.TreeNodeStr(string.format(u8"Статья %s | %s", article, u8(value["name"]))) then
					imgui.Columns(3)
					imgui.Separator()
					imgui.SetColumnWidth(-1, 20) imgui.CenterColumnText(u8"#") imgui.NextColumn()
					imgui.SetColumnWidth(-1, 77) imgui.CenterColumnText(u8"ДЕЙСТВИЕ") imgui.NextColumn()
					imgui.SetColumnWidth(-1, 450) imgui.CenterColumnText(u8"ПОЯСНЕНИЕ") imgui.NextColumn()
					imgui.Separator()
					
					for part, content in pairs(value["content"]) do
						local output = string.len(content["text"]) > 60 and string.sub(content["text"], 0, 65) .. " .." or content["text"]
						imgui.CenterColumnText(tostring(part)) imgui.NextColumn()
						if imgui.Button(string.format("%s##%s%s", u8"РОЗЫСК", article, part)) then
							if content["stars"] > 0 then
								if not viewing_criminal_code then
									command_su(string.format("%s %s %s.%s УК", smart_suspect_id, content["stars"], article, part))
									smart_suspect_id = nil
								else
									setting_up_fast_suspect = {stars = content["stars"], reason = string.format(u8"%s.%s УК", article, part)}
									show_setting_up_fast_suspect[0] = not show_setting_up_fast_suspect[0]
								end
							end
						end imgui.NextColumn()
						imgui.Text(u8(output)) showHelpMarker(u8(string.format("Статья %s.%s УК\n%s-й уровень розыска\n%s", article, part, content["stars"], content["text"]))) imgui.NextColumn()
					end imgui.Columns(0) imgui.TreePop()
				end
			end
		end
	imgui.End()
end)

imgui.OnFrame(function() return show_smart_administrative_code[0] end,
function()
	if smart_ticket_id and not isPlayerConnected(smart_ticket_id) then
		if not viewing_administrative_code then
			show_smart_administrative_code_code[0] = false 
			chat("Нарушитель покинул игру.")
			return 
		end
	end

	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(570, 600))
	imgui.Begin(string.format("%s##2", imgui_script_name), show_smart_criminal_code, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		imgui.PushItemWidth(545)
		if imgui.InputTextWithHint("##administrative_code", u8"Введите статью или часть её содержания", string_found, 50) then
			lookup_table_a = {}
			for article, value in pairs(administrative_code) do
				lookup_table_a[article] = true
				local search = u8:decode(str(string_found))
				if string.match(tostring(article), search) or string.match(value["name"], search) then lookup_table[article] = false end
				if lookup_table_a[article] then
					for part, content in pairs(value["content"]) do
						if string.match(content["text"], search) then
							lookup_table_a[article] = false
						end
					end
				end
			end
		end
		
		for article, value in pairs(administrative_code) do
			if not lookup_table_a[article] then
				if imgui.TreeNodeStr(string.format(u8"Статья %s | %s", article, u8(value["name"]))) then
					imgui.Columns(3)
					imgui.Separator()
					imgui.SetColumnWidth(-1, 20) imgui.CenterColumnText(u8"#") imgui.NextColumn()
					imgui.SetColumnWidth(-1, 70) imgui.CenterColumnText(u8"ДЕЙСТВИЕ") imgui.NextColumn()
					imgui.SetColumnWidth(-1, 450) imgui.CenterColumnText(u8"ПОЯСНЕНИЕ") imgui.NextColumn()
					imgui.Separator()
					
					for part, content in pairs(value["content"]) do
						local output = string.len(content["text"]) > 60 and string.sub(content["text"], 0, 65) .. " .." or content["text"]
						local sanction, button_sanction
						if content["sanction"] == -1 then sanction, button_sanction = "Наказание непредусмотренно", "НЕТ"
						elseif content["sanction"] == -2 then sanction, button_sanction = "Изъятие лицензии на вождение", "ИЗЪЯТЬ"
						else sanction, button_sanction = string.format("Штраф $%s", content["sanction"]), "ШТРАФ" end
						imgui.CenterColumnText(tostring(part)) imgui.NextColumn()
						if imgui.Button(string.format("%s##%s%s", u8(button_sanction), article, part), imgui.ImVec2(52, 20)) then
							if not viewing_administrative_code then
								if content["sanction"] == -1 then --
								elseif content["sanction"] == -2 then command_takelic(string.format("%s %s.%s КоАП", smart_ticket_id, article, part))
								else command_ticket(string.format("%s %s %s.%s КоАП", smart_ticket_id, (content["sanction"] > 10000) and 10000 or content["sanction"], article, part)) end
								smart_ticket_id = nil
							end
						end imgui.NextColumn()
						imgui.Text(u8(output)) showHelpMarker(u8(string.format("Статья %s.%s УК\n%s\n%s", article, part, sanction, content["text"]))) imgui.NextColumn()
					end imgui.Columns(0) imgui.TreePop()
				end
			end
		end
	imgui.End()
end)

imgui.OnFrame(function() return show_main_menu[0] end,
function()
	imgui.SetNextWindowPos(imgui.ImVec2(w / 2, h / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
	imgui.SetNextWindowSize(imgui.ImVec2(900, 500))
	imgui.Begin(string.format("%s##1", imgui_script_name), show_main_menu, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize)
		
		imgui.BeginChild("##navigation", imgui.ImVec2(165, 455))
			
			imgui.CenterText("HELPER FOR MIA")
			imgui.Center(42) imgui.Button(tostring(thisScript().version))
			
			imgui.NewLine() imgui.Separator() imgui.NewLine()
			
			if imgui.NavigationButton(u8"НОВОСТИ", faicons("NEWSPAPER_O")) then navigation_page = 1 end
			if imgui.NavigationButton(u8"ПАНЕЛЬ УПРАВЛЕНИЯ", faicons("TH_LARGE")) then navigation_page = 2 end
			if imgui.NavigationButton(u8"ПАНЕЛЬ ЛИДЕРА", faicons("PIE_CHART")) then navigation_page = 3 end
			if imgui.NavigationButton(u8"НАСТРОЙКИ", faicons("SLIDERS")) then navigation_page = 4 end
			if imgui.NavigationButton(u8"БИНДЕР", faicons("CODE")) then navigation_page = 5 end
			if imgui.NavigationButton(u8"МЕНЕДЖЕР АККАУНТОВ", faicons("ADDRESS_BOOK")) then navigation_page = 6 end
			
			imgui.NewLine() imgui.Separator() imgui.NewLine()
			
			if imgui.NavigationButton(u8"ПЕРЕЗАГРУЗИТЬ", faicons("REPEAT")) then thisScript():reload() end
			if imgui.NavigationButton(u8"ВЫКЛЮЧИТЬ", faicons("POWER_OFF")) then thisScript():unload() end
			
		imgui.EndChild() imgui.SameLine()

		imgui.BeginChild("##main", imgui.ImVec2(705, 455))
			if navigation_page == 1 then
				-- 40 95
				for index, value in ipairs(update_log) do
					for version, information in pairs(value) do
						imgui.SetCursorPosX(40) imgui.Button(version)
						for key, content in pairs(information) do
							imgui.SetCursorPosX(95)
							imgui.Text(u8(content))
						end
					end
				end
			elseif navigation_page == 2 then
				imgui.SetCursorPos(imgui.ImVec2(15, 15))
				imgui.BeginTitleChild(u8"ПОИСК В БАЗЕ ДАННЫХ ИГРОКОВ И НЕДВИЖИМОСТИ", imgui.ImVec2(670, 430)) -- 430
					if imgui.InputTextWithHint("##database_player_string", u8"Введите значение для поиска.", string_database_player, 30) then
						local value = str(string_database_player)
						lookup_database_player = {}
						
						for k, v in pairs(configuration_database["player"]) do
							if string.match(tostring(k), value) then 
								lookup_database_player[string.format("P %s", k)] = v
							else
								for i, n in pairs(v) do
									if i ~= "time" then
										if string.match(tostring(n), value) then
											lookup_database_player[string.format("P %s", k)] = v
										end
									end
								end
							end
						end
						
						for k, v in pairs(configuration_database["house"]) do
							if string.match(tostring(k), value) then 
								lookup_database_player[string.format("H%s", k)] = v
							else
								for i, n in pairs(v) do
									if i ~= "time" then
										if string.match(tostring(n), value) then
											lookup_database_player[string.format("H%s", k)] = v
										end
									end
								end
							end
						end
					end
					
					displaying_inline_sections(lookup_database_player)
				imgui.EndChild() -- imgui.NewLine() imgui.SetCursorPosX(15)
				
				--[[imgui.BeginTitleChild(u8"БАЗА ДАННЫХ НЕДВИЖИМОСТИ", imgui.ImVec2(670, 340))
					if imgui.InputTextWithHint("##database_house_string", u8"Введите значение для поиска.", string_database_house, 30) then
						local value = str(string_database_house)
						lookup_database_house = {}
						
						for k, v in pairs(configuration_database["house"]) do
							if string.match(tostring(k), value) then 
								lookup_database_house[k] = v
							else
								for i, n in pairs(v) do
									if i ~= "time" then
										if string.match(tostring(n), value) then
											lookup_database_house[k] = v
										end
									end
								end
							end
						end
					end
					
					displaying_inline_sections(lookup_database_house)
				imgui.EndChild()--]]
			elseif navigation_page == 4 then
				imgui.SetCursorPosX(90) if imgui.CustomButton(u8"ОСНОВНЫЕ НАСТРОЙКИ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 1 end imgui.SameLine()
				if imgui.CustomButton(u8"ПОЛУЧЕНИЕ ОРУЖИЯ НА СКЛАДЕ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 2 end imgui.SameLine()
				if imgui.CustomButton(u8"УЛУЧШЕННЫЕ ДИАЛОГИ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 3 end
				imgui.SetCursorPosX(85) if imgui.CustomButton(u8"RP-ОТЫГРОВКИ ОРУЖИЯ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 4 end imgui.SameLine() 
				if imgui.CustomButton(u8"RP-ОТЫГРОВКИ МЕЛКИХ ДЕЙСТВИЙ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 5 end imgui.SameLine()
				if imgui.CustomButton(u8"СИСТЕМНЫЕ КОМАНДЫ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 6 end
				imgui.SetCursorPosX(124) if imgui.CustomButton(u8"БЫСТРОЕ МЕНЮ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 7 end imgui.SameLine()
				if imgui.CustomButton(u8"КАСТОМИЗАЦИЯ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 8 end imgui.SameLine()
				if imgui.CustomButton(u8"ДОПОЛНИТЕЛЬНО", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 9 end imgui.SameLine()
				if imgui.CustomButton(u8"МОДИФИКАЦИИ", imgui.ImVec4(0.00, 0.00, 0.00, 0.00)) then setting_page = 10 end
				
				imgui.NewLine()
				
				if setting_page == 1 then
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ О СОТРУДНИКЕ", imgui.ImVec2(230, 230))
						imgui.PushItemWidth(210)
						imgui.InputTextWithHint("##NAME", u8"Имя и фамилия", string_name, 50)
						imgui.InputTextWithHint("##RANG", u8"Должность", string_rang, 50)
						imgui.InputTextWithHint("##FRACTION", u8"Организация", string_fraction, 50)
						imgui.InputTextWithHint("##NUMBER", u8"Личный номер", string_number, 50)
						imgui.InputTextWithHint("##RTAG", u8"Префикс в рацию", string_rtag, 50)
						imgui.InputTextWithHint("##FTAG", u8"Префикс в общую волну", string_ftag, 50)
						
						imgui.SetCursorPosY(200)
						
						if imgui.Button(u8"Сохранить и применить", imgui.ImVec2(210, 20)) then
							configuration_main["information"]["name"] = str(string_name)
							configuration_main["information"]["rang"] = str(string_rang)
							configuration_main["information"]["fraction"] = str(string_fraction)
							configuration_main["information"]["number"] = str(string_number)
							configuration_main["information"]["rtag"] = str(string_rtag)
							configuration_main["information"]["ftag"] = str(string_ftag)
							if not need_update_configuration then need_update_configuration = os.clock() end
						end showHelpMarker(u8"Сохраняет настройки информации о сотруднике.")
					imgui.EndChild() imgui.SameLine()
					
					imgui.BeginTitleChild(u8"ОСНОВНЫЕ БАЗОВЫЕ НАСТРОЙКИ", imgui.ImVec2(445, 230))
						imgui.ToggleButton(u8"Режим женских отыгровок", "information", "sex")
						imgui.ToggleButton(u8"Отключение объявлений от СМИ", "settings", "ad_blocker")
						imgui.ToggleButton(u8"Стробоскопы", "settings", "stroboscopes")
						imgui.ToggleButton(u8"Изменённая рация", "settings", "new_radio")
						imgui.ToggleButton(u8"Отыгровки оружия", "settings", "weapon_acting_out")
						imgui.ToggleButton(u8"Мелкие отыгровки", "settings", "small_acting_out")
						imgui.ToggleButton(u8"Автоматическая покупка масок и аптечек", "settings", "auto_buy_mandh")
						imgui.ToggleButton(u8"Автоматическое получение оружия", "settings", "obtaining_weapons")
						imgui.ToggleButton(u8"Автоматическая проверка документов", "settings", "passport_check")
					imgui.EndChild()
				elseif setting_page == 2 then
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"НАСТРОЙКА АВТО-ПОЛУЧЕНИЯ ОРУЖИЯ", imgui.ImVec2(300, 300))
						for index, value in ipairs(configuration_main["obtaining_weapons"]) do
							imgui.ToggleButton1(value["name"], "obtaining_weapons", index)
						end
					imgui.EndChild() imgui.SameLine()
					
					imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ", imgui.ImVec2(375, 85))
						imgui.Text(u8"С помощью данной функции вы можете получать оружие и")
						imgui.Text(u8"аммуницию автоматически при взятии соответсвующего")
						imgui.Text(u8"пикапа в департаменте, офисе ФБР или здании тюрьмы.")
					imgui.EndChild()
				elseif setting_page == 3 then
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"НАСТРОЙКА УЛУЧШЕННЫХ ДИАЛОГОВ", imgui.ImVec2(305, 135))
						for index, value in ipairs(configuration_main["improved_dialogues"]) do
							imgui.ToggleButton1(value["name"], "improved_dialogues", index)
						end
					imgui.EndChild() imgui.SameLine()
					
					imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ", imgui.ImVec2(370, 85))
						imgui.Text(u8"С помощью данной функции стандартные диалоги Advance")
						imgui.Text(u8"заменяются на улучшенные аналоги с более удобными")
						imgui.Text(u8"интерфейсами. Функционал диалогов не изменяется.")
					imgui.EndChild()
				elseif setting_page == 4 then
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"НАСТРОЙКА RP-ОТЫГРОВОК ОРУЖИЯ", imgui.ImVec2(680, 350))
						if imgui.Button(u8"Сохранить и применить") then
							for index, value in ipairs(configuration_main["weapon_acting_out"]) do
								if not string.find(value["name"], "weapon") then
									configuration_main["weapon_acting_out"][index]["take"] = str(weapon_acting_out[index]["take"])
									configuration_main["weapon_acting_out"][index]["away"] = str(weapon_acting_out[index]["away"])
									if not need_update_configuration then need_update_configuration = os.clock() end
								end
							end
						end imgui.SameLine()
						local button_name = setting_take_weapon and u8"Настройка отыгровок при скрытии оружия из рук" or u8"Настройка отыгровок при взятии оружия в руки"
						if imgui.Button(button_name) then
							setting_take_weapon = not setting_take_weapon
						end imgui.SameLine()
						imgui.ToggleButton(u8"Автоматические отыгровки", "settings", "auto_weapon_acting_out")
						showHelpMarker(u8"При включении этой функции отыгровки будут происходит автоматически. В ином случае отыгровка будет происходить в момент прицеливания.")
						
						imgui.NewLine()

						imgui.Columns(4)
						imgui.Separator()
						imgui.SetColumnWidth(-1, 50) imgui.CenterColumnText(faicons("POWER_OFF")) imgui.NextColumn()
						imgui.SetColumnWidth(-1, 30) imgui.CenterColumnText("#") imgui.NextColumn()
						imgui.SetColumnWidth(-1, 165) imgui.CenterColumnText(u8"Название") imgui.NextColumn()
						imgui.SetColumnWidth(-1, 425) imgui.CenterColumnText(setting_take_weapon and u8"Отыгровка при скрытии оружия из рук" or u8"Отыгровка при взятии оружия в руки") imgui.NextColumn()
						imgui.Separator()
						
						for index, value in ipairs(configuration_main["weapon_acting_out"]) do
							if not string.find(value["name"], "weapon") then
								imgui.ToggleButton1(value["name"], "weapon_acting_out", index) imgui.NextColumn()
								imgui.CenterColumnText(tostring(index)) imgui.NextColumn()
								imgui.CenterColumnText(value["name"]) imgui.NextColumn()
								imgui.PushItemWidth(405)
								if setting_take_weapon then
									imgui.InputTextWithHint(string.format("##a%s", value["name"]), u8"Отыгровка при скрытии оружия из рук", weapon_acting_out[index]["away"], 200)
								else
									imgui.InputTextWithHint(string.format("##t%s", value["name"]), u8"Отыгровка при взятии оружия в руки", weapon_acting_out[index]["take"], 200)
								end imgui.NextColumn()
							end
						end
					imgui.EndChild()
				elseif setting_page == 5 then
					imgui.SetCursorPosX(15) 
					imgui.BeginTitleChild(u8"НАСТРОЙКА RP-ОТЫГРОВОК", imgui.ImVec2(355, 140))
						for index, value in ipairs(configuration_main["small_acting_out"]) do
							imgui.ToggleButton1(value["name"], "small_acting_out", index)
						end
					imgui.EndChild() imgui.SameLine()
					
					imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ", imgui.ImVec2(320, 85))
						imgui.Text(u8"Данная функция отыгрывает мелкие действия.")
						imgui.Text(u8"Отыгровки можно изменить в одном из разделов.")
						imgui.Text(u8"Каждой отыгровке соответсвует своя команда.")
					imgui.EndChild()
				elseif setting_page == 6 then
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"НАСТРОЙКА И ОПИСАНИЕ СИСТЕМНЫХ КОМАНД", imgui.ImVec2(685, 355)) 
						imgui.Columns(4)
						imgui.Separator()
						imgui.SetColumnWidth(-1, 50) imgui.CenterColumnText(faicons("POWER_OFF")) imgui.NextColumn()
						imgui.SetColumnWidth(-1, 30) imgui.CenterColumnText(u8"#") imgui.NextColumn()
						imgui.SetColumnWidth(-1, 150) imgui.CenterColumnText(u8"Команда") imgui.NextColumn() 
						imgui.SetColumnWidth(-1, 440) imgui.CenterColumnText(u8"Описание") imgui.NextColumn()
						imgui.Separator()
						 
						for index, value in ipairs(configuration_main["system_commands"]) do
							if imgui.ToggleButton1(value["name"], "system_commands", index, true) then
								if configuration_main["system_commands"][index]["status"] then
									sampRegisterChatCommand(value["name"], _G[configuration_main["system_commands"][index]["callback"]])
								else sampUnregisterChatCommand(value["name"]) end
							end imgui.NextColumn()
							imgui.CenterColumnText(tostring(index)) imgui.NextColumn()
							if imgui.Button(string.format("/%s", value["name"]), imgui.ImVec2(130, 20)) then
								local found
								for k, v in pairs(configuration_main["quick_menu"]) do if v["title"] == string.upper(value["name"]) then found = k break end end
								if found then
									chat(string.format("Команда {COLOR}%s{}[%s] была исключена из быстрого меню.", string.upper(value["name"]), found))
									table.remove(configuration_main["quick_menu"], found)
								else
									chat(string.format("Команда {COLOR}%s{} была включена в быстрое меню.", string.upper(value["name"])))
									table.insert(configuration_main["quick_menu"], {
										title = string.upper(value["name"]),
										callback = value["callback"]
									})
								end
								
								quick_menu_list = {}
								
								for index, value in pairs(configuration_main["quick_menu"]) do
									quick_menu_list[index] = {
										title = value["title"],
										callback = function()
											_G[value["callback"]](targeting_player)
										end
									}
								end
								
								if not need_update_configuration then need_update_configuration = os.clock() end
							end showHelpMarker(u8"С помощью этой кнопки вы можете добавить команду в быстро меню, или же, если команда уже там есть, исключить её.") imgui.NextColumn()
							imgui.Text(value["description"]) imgui.NextColumn()
						end
					imgui.EndChild()
				elseif setting_page == 7 then 
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ", imgui.ImVec2(685, 355)) 
						imgui.Text(u8"На данный момент быстрое меню поддерживает только системные команды.")
						imgui.Text(u8"Добавить какую-либо команду в быстрое меню вы можете из соответствующего раздела в настройках.")
						imgui.Text(u8"Для этого вам нужно навести курсор на кнопку команды и нажать на неё.")
						
						imgui.NewLine()
						
						imgui.Text(u8"К тому же, в команду, что вы используйте в быстром меню, передаётся только ID игрока, на которого вы навелись.")
						imgui.Text(u8"Будьте внимательны, ведь не все команды поддерживают такой набор входных параметров.")

						imgui.NewLine()
						
						if imgui.Button(u8"Перейти в раздел системных команд") then
							setting_page = 6
						end
					imgui.EndChild()
				elseif setting_page == 8 then 
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"КАСТОМИЗАЦИЯ", imgui.ImVec2(365, 355)) -- 685
						imgui.PushItemWidth(275)
						if imgui.ColorPicker3("##TEST", color_picker) then
							if configuration_main["settings"]["customization"] then
								imgui.GetStyle().Colors[imgui.Col.ButtonActive] = imgui.ImVec4(color_picker[0], color_picker[1] + 0.1, color_picker[2] + 0.1, 0.93)
								imgui.GetStyle().Colors[imgui.Col.ButtonHovered] = imgui.ImVec4(color_picker[0], color_picker[1] + 0.1, color_picker[2] + 0.1, 0.89)
								imgui.GetStyle().Colors[imgui.Col.Button] = imgui.ImVec4(color_picker[0], color_picker[1], color_picker[2], 0.85)
								
								imgui.GetStyle().Colors[imgui.Col.HeaderActive] = imgui.ImVec4(color_picker[0], color_picker[1] + 0.1, color_picker[2] + 0.1, 0.93)
								imgui.GetStyle().Colors[imgui.Col.HeaderHovered] = imgui.ImVec4(color_picker[0], color_picker[1] + 0.1, color_picker[2] + 0.1, 0.89)
								imgui.GetStyle().Colors[imgui.Col.Header] = imgui.ImVec4(color_picker[0], color_picker[1], color_picker[2], 0.85)
								
								imgui.GetStyle().Colors[imgui.Col.SeparatorActive] = imgui.ImVec4(color_picker[0], color_picker[1] + 0.1, color_picker[2] + 0.1, 0.93)
								imgui.GetStyle().Colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(color_picker[0], color_picker[1] + 0.1, color_picker[2] + 0.1, 0.89)
								imgui.GetStyle().Colors[imgui.Col.Separator] = imgui.ImVec4(color_picker[0], color_picker[1], color_picker[2], 0.85)
								
								imgui.GetStyle().Colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(color_picker[0], color_picker[1] + 0.1, color_picker[2] + 0.1, 0.93)
								imgui.GetStyle().Colors[imgui.Col.SliderGrab] = imgui.ImVec4(color_picker[0], color_picker[1], color_picker[2], 0.85)
								
								configuration_main["customization"]["ButtonActive"] = {r = color_picker[0], g = color_picker[1] + 0.1, b = color_picker[2] + 0.1, a = 0.93}
								configuration_main["customization"]["ButtonHovered"] = {r = color_picker[0], g = color_picker[1] + 0.1, b = color_picker[2] + 0.1, a = 0.89}
								configuration_main["customization"]["Button"] = {r = color_picker[0], g = color_picker[1], b = color_picker[2], a = 0.85}
								
								configuration_main["customization"]["SeparatorActive"] = {r = color_picker[0], g = color_picker[1] + 0.1, b = color_picker[2] + 0.1, a = 0.93}
								configuration_main["customization"]["SeparatorHovered"] = {r = color_picker[0], g = color_picker[1] + 0.1, b = color_picker[2] + 0.1, a = 0.89}
								configuration_main["customization"]["Separator"] = {r = color_picker[0], g = color_picker[1], b = color_picker[2], a = 0.85}
								
								configuration_main["customization"]["HeaderActive"] = {r = color_picker[0], g = color_picker[1] + 0.1, b = color_picker[2] + 0.1, a = 0.93}
								configuration_main["customization"]["HeaderHovered"] = {r = color_picker[0], g = color_picker[1] + 0.1, b = color_picker[2] + 0.1, a = 0.89}
								configuration_main["customization"]["Header"] = {r = color_picker[0], g = color_picker[1], b = color_picker[2], a = 0.85}
								
								configuration_main["customization"]["SliderGrabActive"] = {r = color_picker[0], g = color_picker[1] + 0.1, b = color_picker[2] + 0.1, a = 0.93}
								configuration_main["customization"]["SliderGrab"] = {r = color_picker[0], g = color_picker[1], b = color_picker[2], a = 0.85}
								
								local r, g, b = color_picker[0] * 255, color_picker[1] * 255, color_picker[2] * 255
								local color = join_argb(255, r, g, b) -- argb_to_hex(join_argb(255, r, g, b)) 
								configuration_main["settings"]["script_color"] = string.format("{%s}", argb_to_hex(color))
								configuration_main["settings"]["t_script_color"] = tonumber(bit.tohex(color), 16)

								if not need_update_configuration then need_update_configuration = os.clock() end
							end
						end
					imgui.EndChild() imgui.SameLine()
					
					imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ И НАСТРОЙКА", imgui.ImVec2(310, 210))
						if imgui.ToggleButton(u8"Кастомизация", "settings", "customization") then
							apply_custom_style()
						end
						
						imgui.NewLine()
						
						imgui.Text(u8"Для активации включите переключатель сверху.")
						imgui.Text(u8"Вы в любой момент можете вернуться к обычному")
						imgui.Text(u8"интерфейсу просто отключив переключатель.")
						
						imgui.NewLine()
						
						imgui.Text(u8"Изменяя основной цвет, каждый элемент mimgui")
						imgui.Text(u8"и цвет префикса сообщений подстроится под него")
						imgui.Text(u8"и станет идентичным, не считая прозрачности,")
						imgui.Text(u8"которая будет своя для каждого элемента.")
					imgui.EndChild()
				elseif setting_page == 9 then
					imgui.SetCursorPosX(15)
					imgui.BeginTitleChild(u8"ДОПОЛНИТЕЛЬНЫЕ НАСТРОЙКИ", imgui.ImVec2(370, 140))
						imgui.PushItemWidth(155)
						if imgui.SliderInt(u8"Задержка, установленная для RK.", t_delay_between_deaths, 1, 30) then
							configuration_main["settings"]["delay_between_deaths"] = t_delay_between_deaths[0]
							if not need_update_configuration then need_update_configuration = os.clock() end
						end
						
						imgui.ToggleButton(u8"Сообщение в рацию при погоне (в т.ч. пешей погоне).", "settings", "chase_message")
						imgui.ToggleButton(u8"Патрульный ассистент.", "settings", "patrol_assistant")
						imgui.ToggleButton(u8"Отображение наименований рангов на пользователях.", "settings", "user_rang")
						imgui.ToggleButton(u8"Разрыв строки на месте пробела.", "settings", "line_break_by_space")
					imgui.EndChild() imgui.SameLine()
					
					imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ", imgui.ImVec2(305, 65))
						imgui.Text(u8"В данном разделе настраиваются незначительные")
						imgui.Text(u8"функции, потому он и вынесен в отдельный блок.")
					imgui.EndChild()
				else
					imgui.CenterText(u8"Будет доступно в ближайщих обновлениях.")
				end
			elseif navigation_page == 5 then
				imgui.SetCursorPos(imgui.ImVec2(15, 15))
				imgui.BeginTitleChild(u8"ДОПОЛНИТЕЛЬНЫЕ ВОЗМОЖНОСТИ | БИНДЕР", imgui.ImVec2(675, 430))
					if binder["index"] then
						imgui.CustomButton(string.format("ID: %s", binder["index"]), imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
						imgui.SameLine()
						imgui.PushItemWidth(118)
						imgui.InputTextWithHint("##input_command", u8"/команда", binder["command"], 20)
						showHelpMarker(u8"Введите команду, с помощью которой хотите активировать этот сценарий. Слеш (/) указывать не нужно.")
						imgui.SameLine()
						
						if imgui.CustomButton(u8"Сохранить", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							-- configuration_custom["global_profile"]
							if binder["index"] then
								local command_name = str(binder["command"])
								if command_name and string.match(command_name, "(%S+)") then
									local description = str(binder["description"])
									if description and string.match(description, "(%S+)") then
										if not configuration_custom[global_profile][binder["index"]] then configuration_custom[global_profile][binder["index"]] = {} end
										if not configuration_custom[global_profile][binder["index"]]["parametrs"] then configuration_custom[global_profile][binder["index"]]["parametrs"] = {} end
										configuration_custom[global_profile][binder["index"]]["content"] = {}
										local index = 1
										
										for line in string.gmatch(str(binder["content"]), "[^\n]+") do
											configuration_custom[global_profile][binder["index"]]["content"][index] = line
											index = index + 1
										end
										
										if binder["parametrs_amount"][0] > 0 then
											for index = 1, binder["parametrs_amount"][0] do
												local parametrs = str(binder["parametrs"][index]) and str(binder["parametrs"][index]) or u8(string.format("Параметр %s", parametrs))
												configuration_custom[global_profile][binder["index"]]["parametrs"][index] = parametrs
											end										
										end
										
										configuration_custom[global_profile][binder["index"]]["parametrs_amount"] = binder["parametrs_amount"][0]
										configuration_custom[global_profile][binder["index"]]["name"] = command_name
										configuration_custom[global_profile][binder["index"]]["description"] = description
										configuration_custom[global_profile][binder["index"]]["status"] = configuration_custom[global_profile][binder["index"]]["status"] or true
										
										chat("Все изменения были внесены в команду и успешно сохранены.")
										if not need_update_configuration then need_update_configuration = os.clock() end
									else chat("Описание команды должно содержать как минимум один символ.") end
								else chat("Название команды должно содержать как минимум один символ.") end
							else chat("Критическая ошибка #1.") end
						end showHelpMarker(u8"Нажмите, чтобы сохранить эту команду.") imgui.SameLine()
						
						if imgui.CustomButton(u8"Удалить", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							configuration_custom[global_profile][binder["index"]] = nil
							binder = {}
							if not need_update_configuration then need_update_configuration = os.clock() end
							return
						end showHelpMarker(u8"Нажмите, чтобы удалить эту команду.") imgui.SameLine()
						
						if imgui.CustomButton(u8"Очистить блок", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							binder["content"] = new.char[256]()
						end showHelpMarker(u8"Нажмите, чтобы очистить блок редактирования от текста.") imgui.SameLine()
						
						if imgui.CustomButton(u8"Закрыть редактор", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							binder = {}
							return
						end showHelpMarker(u8"Нажмите, чтобы закрыть редактор этой команды. Изменения не будут сохранены.") imgui.SameLine()
						
						if imgui.CustomButton(u8"Дополнительно##55", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							show_editor_assistant[0] = not show_editor_assistant[0]
						end showHelpMarker(u8"Нажмите, чтобы открыть информацию о тэгах и функциях.")
						
						imgui.SetCursorPos(imgui.ImVec2(5, 45))
						
						local sizeY = 337
						if imgui.TreeNodeStr(u8"Дополнительные настройки команды (описание и параметры).") then
							imgui.CustomButton(u8"Количество параметров:", imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
							showHelpMarker(u8"Эта настройка отвечает за количество необходимых для команды параметров. В блоке редактирования они вызываются как {/number/} (например {1}).")
							imgui.SameLine()
							imgui.PushItemWidth(85)
							if imgui.InputInt("##parametrs", binder["parametrs_amount"]) then
								if binder["parametrs_amount"][0] < 0 then binder["parametrs_amount"][0] = 0
								elseif binder["parametrs_amount"][0] > 3 then binder["parametrs_amount"][0] = 3 end
							end
							
							if binder["parametrs_amount"][0] > 0 then
								for index = 1, binder["parametrs_amount"][0] do
									if not binder["parametrs"][index] then binder["parametrs"][index] = new.char[256]() end
									imgui.PushItemWidth(150)
									imgui.InputTextWithHint(string.format("##parametrs_%s", index), u8(string.format("Название %sго параметра", index)), binder["parametrs"][index], 30)
									imgui.SameLine()
								end imgui.NewLine()
								
								sizeY = 259
							else sizeY = 285 end
							
							imgui.PushItemWidth(310)
							imgui.InputTextWithHint("##command_description", u8"Краткое описание команды", binder["description"], 80)
							
							
							imgui.TreePop()
						end imgui.NewLine()
						
						imgui.InputTextMultiline("##input_command_content", binder["content"], 9999, imgui.ImVec2(655, sizeY))
					elseif binder_sc["index"] then
						imgui.CustomButton(string.format("ID: %s", binder_sc["index"]), imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
						imgui.SameLine()
						imgui.Button(string.format("/%s", binder_sc["command"]), imgui.ImVec2(118, 20))
						imgui.SameLine()
						
						if imgui.CustomButton(u8"Сохранить", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							if configuration_main["system_commands"][binder_sc["index"]] then
								local male = configuration_main["information"]["sex"] and "female" or "male"
								configuration_main["system_commands"][binder_sc["index"]]["variations"][male][binder_sc["current_variations"]] = {}
								
								local index = 0
								
								for line in string.gmatch(str(binder_sc["content"]), "[^\n]+") do
									index = index + 1
									configuration_main["system_commands"][binder_sc["index"]]["variations"][male][binder_sc["current_variations"]][index] = line
								end
								
								chat("Все изменения были внесены в команду и успешно сохранены.")
								if not need_update_configuration then need_update_configuration = os.clock() end
							else chat("Критическая ошибка #1.") end
						end showHelpMarker(u8"Нажмите, чтобы сохранить эту вариацию команды.") imgui.SameLine()
					
						if imgui.CustomButton(u8"Удалить", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							local male = configuration_main["information"]["sex"] and "female" or "male"
							
							if #configuration_main["system_commands"][binder_sc["index"]]["variations"][male] > 1 then
								configuration_main["system_commands"][binder_sc["index"]]["variations"][male][binder_sc["current_variations"]] = nil
								binder_sc = {}
								if not need_update_configuration then need_update_configuration = os.clock() end
								return
							else chat("Невозможно удалить единственную вариацию команды.") end
						end showHelpMarker(u8"Нажмите, чтобы удалить эту вариацию команды.") imgui.SameLine()
					
						if imgui.CustomButton(u8"Очистить блок", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							binder_sc["content"] = new.char[9999]()
						end showHelpMarker(u8"Нажмите, чтобы очистить блок редактирования от текста.") imgui.SameLine() 
						
						if imgui.CustomButton(u8"Закрыть редактор", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							binder_sc = {}
							return
						end showHelpMarker(u8"Нажмите, чтобы закрыть редактор этой команды. Изменения не будут сохранены.") imgui.SameLine()
						
						if imgui.CustomButton(u8"Дополнительно##66", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then
							show_editor_assistant[0] = not show_editor_assistant[0]
						end showHelpMarker(u8"Нажмите, чтобы открыть информацию о тэгах и функциях.")
						
						imgui.SetCursorPos(imgui.ImVec2(5, 45))
						local sizeY = 337
						
						if imgui.TreeNodeStr(u8"Дополнительные настройки команды (вариации).") then
							imgui.CustomButton(u8"Количество вариаций:", imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
							showHelpMarker(u8"Эта настройка отвечает за количество возможных вариаций выполнения команды.")
							imgui.SameLine()
							imgui.PushItemWidth(85)
							if imgui.InputInt("##variations", binder_sc["variations_amount"]) then
								if binder_sc["variations_amount"][0] < 1 then binder_sc["variations_amount"][0] = 1
								elseif binder_sc["variations_amount"][0] > 5 then binder_sc["variations_amount"][0] = 5 end
							end
							
							for index = 1, binder_sc["variations_amount"][0] do
								if imgui.Button(string.format(u8"Вариация #%s", index), imgui.ImVec2(85, 20)) then
									local value = configuration_main["system_commands"][binder_sc["index"]]
									
									if value["variations"]["male"][index] then
										local content = "\n"
										for k, v in pairs(value["variations"]["male"][index]) do content = string.format("%s\n%s", content, v) end 
										local content = string.gsub(content, "\n\n", "")
										binder_sc["content"] = new.char[9999](content)
									else
										binder_sc["content"] = new.char[9999]()
									end
									
									binder_sc["current_variations"] = index
								end showHelpMarker(u8"Переключится к настройке этой вариации (изменения не будут сохранены).") imgui.SameLine()
							end imgui.NewLine()
							
							sizeY = 286
							imgui.TreePop()
						end imgui.NewLine()

						imgui.InputTextMultiline("##input_command_content", binder_sc["content"], 9999, imgui.ImVec2(655, sizeY))
					else
						if binder_work_status == 1 then
							imgui.SetCursorPosX(90)
							imgui.Button(u8"Пользовательские настройки") imgui.SameLine()
							if imgui.CustomButton(u8"Системные команды", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then binder_work_status = 2 end	imgui.SameLine()
							if imgui.CustomButton(u8"Отыгровки мелких действий", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then binder_work_status = 3 end
							
							imgui.Columns(5)
							imgui.Separator()
							imgui.SetColumnWidth(-1, 50) imgui.CenterColumnText(faicons("POWER_OFF")) imgui.NextColumn()
							imgui.SetColumnWidth(-1, 30) imgui.CenterColumnText(u8"#") imgui.NextColumn()
							imgui.SetColumnWidth(-1, 150) imgui.CenterColumnText(u8"Команда") imgui.NextColumn()
							imgui.SetColumnWidth(-1, 150) imgui.CenterColumnText(u8"Клавиши активации") imgui.NextColumn()
							imgui.SetColumnWidth(-1, 290) imgui.CenterColumnText(u8"Описание") imgui.NextColumn()
							imgui.Separator()
							
							for index = 1, user_slots_value do
								local index = tostring(index)
								if configuration_custom[global_profile][index] then
									local buffer = configuration_custom[global_profile][index]
									imgui.ToggleButton2(string.format(u8"##FFF%s", index), global_profile, index, true) imgui.NextColumn()
									imgui.CenterColumnText(tostring(index)) imgui.NextColumn()
									if imgui.Button(string.format(u8"/%s", buffer["name"]), imgui.ImVec2(130, 20)) then
										binder = {}
										binder["index"] = index
										binder["command"] = buffer["name"] and new.char[256](buffer["name"]) or new.char[256]()
										binder["parametrs_amount"] = buffer["parametrs_amount"] and new.int(buffer["parametrs_amount"]) or new.int(0)
										binder["description"] = buffer["description"] and new.char[256](buffer["description"]) or new.char[256]()
										binder["parametrs"] = {}
										
										if buffer["parametrs_amount"] > 0 then  
											for k, v in pairs(buffer["parametrs"]) do binder["parametrs"][k] = new.char[256](v) end
										end
										
										if buffer["content"] then
											for k, v in pairs(buffer["content"]) do
												if not binder["content"] then binder["content"] = v else binder["content"] = string.format("%s\n%s", binder["content"], v) end
											end 
										else binder["content"] = "" end
										
										binder["content"] = new.char[9999](binder["content"])
									end showHelpMarker(u8"Нажмите, чтобы редактировать данную команду.")
									imgui.NextColumn() 
									if type(buffer["key"]) == "table" then 
										if imgui.HotKey(string.format("##hk%s", index), configuration_custom[global_profile][index]["key"], 130) then
											if not rkeys.isHotKeyDefined(buffer["key"]["v"]) then
												hotkey_id = rkeys.registerHotKey(buffer["key"]["v"], true, function()
													command_handler(global_profile, index)
												end)
											end
										end
									else
										if imgui.CustomButton(string.format(u8"Добавить##%s", index), imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(130, 20)) then
											configuration_custom[global_profile][index]["key"] = {v = {}}
										end
									end imgui.NextColumn()
									
									local description = buffer["description"] and buffer["description"] or u8"Описание отсутствует"
									imgui.CustomButton(description, imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) imgui.NextColumn()
								else
									mimgui_addons.ToggleButton("##".. index, new.bool(true)) imgui.NextColumn()
									imgui.CenterColumnText(tostring(index)) imgui.NextColumn()
									if imgui.CustomButton(string.format(u8"Создать##%s", index), imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(130, 20)) then
										binder = {
											index = index,
											command = new.char[256](),
											parametrs_amount = new.int(0),
											parametrs = {},
											variations = 1,
											content = new.char[9999](),
											description = new.char[256]()
										}
									end	
									showHelpMarker(u8"Нажмите, чтобы создать новую команду.")
									imgui.NextColumn()
									imgui.CustomButton(u8"Недоступно", imgui.ImVec4(0.0, 0.0, 0.0, 0.0), imgui.ImVec2(130, 20)) imgui.NextColumn()
									imgui.CustomButton(u8"Свободный слот", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) imgui.NextColumn()
								end
							end
						elseif binder_work_status == 2 then
							imgui.SetCursorPosX(90)
							if imgui.CustomButton(u8"Пользовательские настройки", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then binder_work_status = 1 end	imgui.SameLine()
							imgui.Button(u8"Системные команды") imgui.SameLine()
							if imgui.CustomButton(u8"Отыгровки мелких действий", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then binder_work_status = 3 end
							
							imgui.Columns(4)
							imgui.Separator()
							imgui.SetColumnWidth(-1, 50) imgui.CenterColumnText(faicons("POWER_OFF")) imgui.NextColumn()
							imgui.SetColumnWidth(-1, 30) imgui.CenterColumnText(u8"#") imgui.NextColumn()
							imgui.SetColumnWidth(-1, 150) imgui.CenterColumnText(u8"Команда") imgui.NextColumn()
							imgui.SetColumnWidth(-1, 440) imgui.CenterColumnText(u8"Описание") imgui.NextColumn()
							imgui.Separator()
							
							for index, value in ipairs(configuration_main["system_commands"]) do
								if value["variations"]["male"] then
									if imgui.ToggleButton1(value["name"], "system_commands", index, true) then
										if configuration_main["system_commands"][index]["status"] then
											sampRegisterChatCommand(value["name"], _G[configuration_main["system_commands"][index]["callback"]])
										else sampUnregisterChatCommand(value["name"]) end
									end imgui.NextColumn()
									imgui.CenterColumnText(tostring(index)) imgui.NextColumn()
									if imgui.Button(string.format("/%s", value["name"]), imgui.ImVec2(130, 20)) then
										local male = configuration_main["information"]["sex"] and "female" or "male"
										binder_sc = {
											index = index,
											command = value["name"],
											variations_amount = new.int(#value["variations"][male]),
											current_variations = 1
										}
										
										local content = "\n"
										for k, v in pairs(value["variations"][male][1]) do content = string.format("%s\n%s", content, v) end 
										local content = string.gsub(content, "\n\n", "")
										binder_sc["content"] = new.char[9999](content)
									end
									showHelpMarker(u8"Нажмите, чтобы открыть редактор команды.")
									imgui.NextColumn()
									imgui.Text(value["description"]) imgui.NextColumn()
								end
							end
						elseif binder_work_status == 3 then
							imgui.SetCursorPosX(90)
							if imgui.CustomButton(u8"Пользовательские настройки", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then binder_work_status = 1 end	imgui.SameLine()
							if imgui.CustomButton(u8"Системные команды", imgui.ImVec4(0.0, 0.0, 0.0, 0.0)) then binder_work_status = 2 end imgui.SameLine()
							imgui.Button(u8"Отыгровки мелких действий")
							
							imgui.CenterText(u8"Будет доступно в ближайщих обновлениях.")
						end
					end
				imgui.EndChild()
			elseif navigation_page == 6 then
				imgui.SetCursorPos(imgui.ImVec2(15, 15))
				imgui.BeginTitleChild(u8"РЕДАКТОР", imgui.ImVec2(205, 155))
				
				imgui.PushItemWidth(155)
				imgui.InputTextWithHint("##ip-adress", u8"IP-адресс сервера", imgui_manager_ip, 30) imgui.SameLine()
				if imgui.Button(u8"+##1", imgui.ImVec2(20, 20)) then
					local ip, port = sampGetCurrentServerAddress()
					imgui_manager_ip = new.char[256](string.format("%s:%s", ip, port))
				end
				
				imgui.InputTextWithHint("##manager_name", u8"Nickname", imgui_manager_nickname, 30) imgui.SameLine()
				if imgui.Button(u8"+##2", imgui.ImVec2(20, 20)) then
					local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
					imgui_manager_nickname = new.char[256](sampGetPlayerName(playerId))
				end
				
				imgui.PushItemWidth(185)
				imgui.InputTextWithHint("##manager_password", u8"Пароль", imgui_manager_password, 30)
				imgui.InputTextWithHint("##manager_gauth", u8"GAuth-ключ", imgui_manager_gauth, 50)
				
				if imgui.Button(u8"Добавить аккаунт", imgui.ImVec2(185, 20)) then
					local ip_adress = str(imgui_manager_ip)
					local nickname = str(imgui_manager_nickname)
					local password =  str(imgui_manager_password)
					
					if string.match(ip_adress, "(%S+):(%d+)") then
						if string.match(nickname, "(%S+)") then
							if string.match(password, "(%S+)") then
								if not configuration_manager then configuration_manager = {} end
								if not configuration_manager[ip_adress] then configuration_manager[ip_adress] = {} end
								if not configuration_manager[ip_adress][nickname] then configuration_manager[ip_adress][nickname] = {} end
								
								local gauth = str(imgui_manager_gauth)
								if string.len(gauth) ~= 16 then gauth = "" end
								configuration_manager[ip_adress][nickname] = {
									password = u8(password),
									gauth = string.match(gauth, "(%S+)") and u8(gauth) or (configuration_manager[ip_adress][nickname]["gauth"] or nil)
								}
								if not need_update_configuration then need_update_configuration = os.clock() end
							else chat("Для добавления аккаунта необходимо ввести {COLOR}пароль{}.") end
						else chat("Для добавления аккаунта необходимо ввести {COLOR}nickname{} или выбрать текущий.") end
					else chat("IP-адресс сервера должен быть в формате {COLOR}IP:PORT{} (например: {COLOR}5.254.104.132:7777{}).") end
					-- configuration_manager
				end
				
				imgui.EndChild() imgui.SameLine()
				imgui.BeginTitleChild(u8"ИНФОРМАЦИЯ", imgui.ImVec2(460, 155))
					imgui.Text(u8"Ни в коем случае не передавайте файлы конфигурации сторонним лицам!")
					imgui.Text(u8"Данные о ваших аккаунтах хранятся в незашифрованным виде по причине")
					imgui.Text(u8"того, что исходный код открыт и расшифровывание не будет являться")
					imgui.Text(u8"какой-либо проблемой для злоумышленников.")
					imgui.NewLine()
					imgui.Text(u8"Данные не передаются куда-либо и хранятся только в файлах конфигурации.")
					imgui.Text(u8"Автор не несёт ответственность за сохранность ваших данных.")
				imgui.EndChild()
				
				imgui.NewLine()
				
				imgui.SetCursorPosX(15)
				imgui.BeginTitleChild(u8"МЕНЕДЖЕР АККАУНТОВ", imgui.ImVec2(675, 255))
					local index = 0
					for ip, accounts in pairs(configuration_manager) do
						for nickname, data in pairs(accounts) do
							index = index + 1
							imgui.BeginChild(string.format("##block_%s", index), imgui.ImVec2(330, 50))
								imgui.Text(string.format("%s | %s", nickname, ip))
								local clr = imgui.Col
								imgui.PushStyleColor(clr.Text, imgui.GetStyle().Colors[clr.ButtonHovered])
								imgui.Text(imgui_manager_bool and data["password"] or u8"ПАРОЛЬ СКРЫТ")
								imgui.SameLine()
								imgui.PopStyleColor(1)
								imgui.PushStyleColor(clr.Text, imgui.GetStyle().Colors[clr.ButtonActive])
								if data["gauth"] then
									imgui.Text(string.format(u8"КОД: %s", gauth.gencode(data["gauth"], math.floor(os.time() / 30))))
								else
									imgui.Text(u8"НЕДОСТУПНО")
								end
								imgui.PopStyleColor(1)
							imgui.EndChild() if math.fmod(index, 2) ~= 0 then imgui.SameLine() end
						end
					end
				imgui.EndChild()
			else imgui.CenterText(u8"Будет доступно в ближайщих обновлениях.")
				--[[imgui.InputTextWithHint("##icons", u8"Иконка", string_found, 50)
			
				for k, v in pairs(faicons) do
					if string.match(k, ffi.string(string_found)) then
						if imgui.Button(string.format("%s\n%s", v, k), imgui.ImVec2(300, 40)) then
							setClipboardText(k)
						end
					end
				end--]]
			end
		imgui.EndChild()
		
	imgui.End()
end)
-- !mimgui
 
-- main
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end
	
	print("\n\n")
	local start_time = os.clock()
	autoUpdate("https://raw.githubusercontent.com/skezz-perry/project/master/version_2", "https://raw.githubusercontent.com/skezz-perry/project/master/helper%20for%20mia%20(v2.0).lua")
	
	-- ивенты
	addEventHandler("onWindowMessage", function(msg, wparam, lparam)   
		if msg == wm.WM_KILLFOCUS then
			if not pause_start then pause_start = {os.clock(), 1} end
		elseif msg == wm.WM_SETFOCUS then
			if pause_start then
				if (pause_start[2] == 2 and not isPauseMenuActive()) or pause_start[2] == 1 then
					local difference = os.clock() - pause_start[1]
					configuration_statistics["afk_time"] = configuration_statistics["afk_time"] + difference
					if not need_update_configuration then need_update_configuration = os.clock() end
					pause_start = nil
					if difference > 5 then lua_thread.create(function() was_pause = true wait(1500) chat(string.format("Вы находились в AFK {COLOR}%d{} секунд(-ы).", difference)) was_pause = false end) end
				end
			end
		end
	
		if msg == 0x100 or msg == 0x101 then 
			if wparam == vkeys.VK_ESCAPE then
				if show_main_menu[0] or show_smart_criminal_code[0] or show_smart_administrative_code[0] or show_setting_patrol[0] or show_gas_station[0] or show_quick_menu[0] or show_editor_assistant[0] then
					if isKeyCheckAvailable() then
						consumeWindowMessage(true, false)
						if msg == 0x101 then 
							if show_setting_up_fast_suspect[0] or show_editor_assistant[0] then 
								show_setting_up_fast_suspect[0], show_editor_assistant[0] = false, false
							else
								show_main_menu[0], show_smart_criminal_code[0], show_smart_administrative_code[0], show_setting_patrol[0], show_gas_station[0], show_quick_menu[0] = false, false, false, false, false, false
							end
						end
					end
				else
					if not pause_start then
						if isPauseMenuActive() then
							pause_start = {os.clock(), 2}
						end
					else
						local difference = os.clock() - pause_start[1]
						configuration_statistics["afk_time"] = configuration_statistics["afk_time"] + difference
						if not need_update_configuration then need_update_configuration = os.clock() end
						pause_start = nil
						if difference > 5 then lua_thread.create(function() was_pause = true wait(1500) chat(string.format("Вы находились в AFK {COLOR}%d{} секунд(-ы).", difference)) was_pause = false end) end
					end
				end
			end
			
			if wparam == vkeys.VK_X then
				if isKeyCheckAvailable() then
					consumeWindowMessage(true, false)
					if msg == 0x101 then
						if global_command_handler then
							global_break_command = os.clock()
						end
					end
				end
			end
			
			if wparam == vkeys.VK_Z then
				if isKeyCheckAvailable() then
					consumeWindowMessage(true, false)
					if msg == 0x101 then 
						show_quick_menu[0] = not show_quick_menu[0]
					end
				end
			end
				
			if isKeyDown(VK_RBUTTON) then
				if isKeyCheckAvailable() then
					if wasKeyPressed(vkeys.VK_1) then
						consumeWindowMessage(true, false)
						sampSendChat("/eat")
					elseif wasKeyPressed(vkeys.VK_2) then
						consumeWindowMessage(true, false)
						sampSendChat("/open")
					elseif wasKeyPressed(vkeys.VK_3) then
						consumeWindowMessage(true, false)
						command_megafon()
					elseif wasKeyPressed(vkeys.VK_4) then
						consumeWindowMessage(true, false)
						if quick_report["playerId"] then
							command_rep(string.format("%s %s", quick_report["playerId"], quick_report["reason"]))
						end 
					elseif wasKeyPressed(vkeys.VK_5) then
						consumeWindowMessage(true, false)
						if quick_suspect["playerId"] then
							command_su(string.format("%s %s %s", quick_suspect["playerId"], quick_suspect["stars"], quick_suspect["reason"]))
						end
					elseif wasKeyPressed(vkeys.VK_H) then
						b_stroboscopes = not b_stroboscopes
					end
				end
			end
				
			if accept_the_offer then
				if wparam == vkeys.VK_Y then
					if isKeyCheckAvailable() then
						consumeWindowMessage(true, false)
						if msg == 0x101 then 
							if accept_the_offer == 1 then
								command_r("cod 14")
								accept_the_offer = nil
							end
						end
					end
				end
					
				if wparam == vkeys.VK_N then
					if isKeyCheckAvailable() then
						consumeWindowMessage(true, false)
						if msg == 0x101 then
							accept_the_offer = nil
						end
					end
				end
			end
				
			if wparam == vkeys.VK_1 then
				if isKeyCheckAvailable() then
					consumeWindowMessage(true, false)
					if msg == 0x101 then
						if isKeyDown(VK_C) then
							flymode = not flymode
							if flymode then
								lockPlayerControl(true)
								local x, y, z = getCharCoordinates(playerPed)
								camera = {
									origin = {x = x, y = y, z = z},
									angle = {y = 0.0, z = getCharHeading(playerPed)},
									speed = 1
								}
							else
								restoreCameraJumpcut()
								setCameraBehindPlayer()
								lockPlayerControl(false)
							end
						end
					end
				end
			end
		end
	end)

	-- калибровка генератора псевдослучайных чисел
	math.randomseed(os.time())
	
	-- регистрация системных команд 
	local total, successfully = 0, 0
	for index, value in pairs(configuration_main["system_commands"]) do
		if not sampIsChatCommandDefined(value["name"]) and value["status"] then 
			if value["callback"] and type(_G[value["callback"]]) == "function" then 
				sampRegisterChatCommand(value["name"], _G[value["callback"]])
				if value["variations"]["male"] then
					local command = string.format("n%s", value["name"])
					sampRegisterChatCommand(command, function(parametrs)
						if string.match(parametrs, "(%S+)") then
							sampSendChat(string.format("/%s %s", value["name"], parametrs))
						else chat_error(string.format("Введите необходимые параметры для /%s [параметры].", command)) end
					end)
				end
				successfully = successfully + 1
			end
		end total = total + 1
	end print(string.format("Во время инициализации было найдено %s системных команд, из них было зарегистрировано %s.", total, successfully))
	
	-- регистрация команд пользователя
	local total, successfully = 0, 0
	for index, value in pairs(configuration_custom[global_profile]) do
		if not sampIsChatCommandDefined(value["name"]) and value["status"] then 
			local command = u8:decode(value["name"])
			sampRegisterChatCommand(command, function(parametrs)
				lua_thread.create(function()
					command_handler(global_profile, index, parametrs)
				end)
			end)
			
			if value["key"] and value["key"]["v"] then
				hotkey_id[index] = rkeys.registerHotKey(value["key"]["v"], true, function()
					if isKeyCheckAvailable() then command_handler(global_profile, index, "") end
				end)
			end
			successfully = successfully + 1
		end total = total + 1
	end print(string.format("В том числе было найдено несколько пользовательских команд в числе %s, зарегистрировано было %s.", total, successfully))
	
	sampRegisterChatCommand("convert_telephone", function()
		if configuration_main["number"] then
			for player_name, player_number in pairs(configuration_main["number"]) do
				if not configuration_database["player"][player_name] then configuration_database["player"][player_name] = {} end
				configuration_database["player"][player_name]["telephone"] = player_number
				configuration_main["number"][player_name] = nil
			end
			
			chat("Данные были успешно конвертированы.")
			configuration_main["number"] = nil
			if not need_update_configuration then need_update_configuration = os.clock() end
		else chat("Вы уже конвертировали базу данных номеров.") end
	end)
	
	-- потекли потоки
	lua_thread.create(dynamic_time_update)
	lua_thread.create(render_player_text)
	lua_thread.create(t_weapon_acting_out)
	lua_thread.create(t_stroboscopes)
	lua_thread.create(patrol_assistant)
	-- lua_thread.create(house_founder)
	
	print(string.format("Общее время загрузки игрового помощника: %s\n\n", os.clock() - start_time))
	
	while true do wait(0) 
		if wasKeyPressed(vkeys.VK_RCONTROL) then
            if not isCharSittingInAnyCar(playerPed) then
                pricel = not pricel
            end
        end
		
        if pricel then memory.write(12 + 12006488, 2, 128, false) end
		
		if isKeyDown(VK_RBUTTON) then
			local result, char = getCharPlayerIsTargeting(playerHandle)
			if result then
				local result, player_id = sampGetPlayerIdByCharHandle(char)
				if result then
					if targeting_player ~= player_id then targeting_player = player_id end
				end
			end
		end
		
		if flymode then
			local mouseX, mouseY = getPcMouseMovement()
			local mouseX = mouseX / 4.0
			local mouseY = mouseY / 4.0
			
			camera["angle"]["z"] = camera["angle"]["z"] + mouseX
			camera["angle"]["y"] = camera["angle"]["y"] + mouseY
			
			if camera["angle"]["z"] > 360 then camera["angle"]["z"] = camera["angle"]["z"] - 360 end
			if camera["angle"]["z"] < 0 then camera["angle"]["z"] = camera["angle"]["z"] + 360 end
			if camera["angle"]["y"] > 89 then camera["angle"]["y"] = 89 end
			if camera["angle"]["y"] < -89 then camera["angle"]["y"] = -89 end 
			
			local currentZ = camera["angle"]["z"] + 180
			local currentY = camera["angle"]["y"] * -1
			
			local radianZ = math.rad(currentZ) 
			local radianY = math.rad(currentY)                   
			local sinusZ = math.sin(radianZ)
			local cosinusZ = math.cos(radianZ)      
			local sinusY = math.sin(radianY)
			local cosinusY = math.cos(radianY)  
			
			local sinusZ = sinusZ * cosinusY      
			local cosinusZ = cosinusZ * cosinusY 
			local sinusZ = sinusZ * 10.0     
			local cosinusZ = cosinusZ * 10.0       
			local sinusY = sinusY * 10.0                       
			local position_plX = camera["origin"]["x"] + sinusZ
			local position_plY = camera["origin"]["y"] + cosinusZ 
			local position_plZ = camera["origin"]["z"] + sinusY             
			local angle_plZ = camera["angle"]["z"] * -1.0
			
			if isKeyDown(VK_W) then      
				local radianZ = math.rad(camera["angle"]["z"]) 
				local radianY = math.rad(camera["angle"]["y"])                   
				local sinusZ = math.sin(radianZ)
				local cosinusZ = math.cos(radianZ)      
				local sinusY = math.sin(radianY)
				local cosinusY = math.cos(radianY)       
				local sinusZ = sinusZ * cosinusY      
				local cosinusZ = cosinusZ * cosinusY 
				local sinusZ = sinusZ * camera["speed"]     
				local cosinusZ = cosinusZ * camera["speed"]        
				local sinusY = sinusY * camera["speed"]  
				camera["origin"]["x"] = camera["origin"]["x"] + sinusZ 
				camera["origin"]["y"] = camera["origin"]["y"] + cosinusZ 
				camera["origin"]["z"] = camera["origin"]["z"] + sinusY      
				setFixedCameraPosition(camera["origin"]["x"], camera["origin"]["y"], camera["origin"]["z"], 0.0, 0.0, 0.0)      
			end 

			if isKeyDown(VK_S) then  
				local currentZ = camera["angle"]["z"] + 180.0
				local currentY = camera["angle"]["y"] * -1.0      
				local radianZ = math.rad(currentZ) 
				local radianY = math.rad(currentY)                   
				local sinusZ = math.sin(radianZ)
				local cosinusZ = math.cos(radianZ)      
				local sinusY = math.sin(radianY)
				local cosinusY = math.cos(radianY)       
				local sinusZ = sinusZ * cosinusY      
				local cosinusZ = cosinusZ * cosinusY 
				local sinusZ = sinusZ * camera["speed"]      
				local cosinusZ = cosinusZ * camera["speed"]       
				local sinusY = sinusY * camera["speed"]                       
				camera["origin"]["x"] = camera["origin"]["x"] + sinusZ 
				camera["origin"]["y"] = camera["origin"]["y"] + cosinusZ 
				camera["origin"]["z"] = camera["origin"]["z"] + sinusY      
				setFixedCameraPosition(camera["origin"]["x"], camera["origin"]["y"], camera["origin"]["z"], 0.0, 0.0, 0.0)
			end 
					  
			if isKeyDown(VK_A) then  
				local currentZ = camera["angle"]["z"] - 90.0
				local radianZ = math.rad(currentZ)
				local radianY = math.rad(camera["angle"]["y"])
				local sinusZ = math.sin(radianZ)
				local cosinusZ = math.cos(radianZ)
				local sinusZ = sinusZ * camera["speed"]
				local cosinusZ = cosinusZ * camera["speed"]
				camera["origin"]["x"] = camera["origin"]["x"] + sinusZ
				camera["origin"]["y"] = camera["origin"]["y"] + cosinusZ
				setFixedCameraPosition(camera["origin"]["x"], camera["origin"]["y"], camera["origin"]["z"], 0.0, 0.0, 0.0)
			end       

			if isKeyDown(VK_D) then  
				local currentZ = camera["angle"]["z"] + 90.0
				local radianZ = math.rad(currentZ)
				local radianY = math.rad(camera["angle"]["y"])
				local sinusZ = math.sin(radianZ)
				local cosinusZ = math.cos(radianZ)       
				local sinusZ = sinusZ * camera["speed"]
				local cosinusZ = cosinusZ * camera["speed"]
				camera["origin"]["x"] = camera["origin"]["x"] + sinusZ
				camera["origin"]["y"] = camera["origin"]["y"] + cosinusZ      
				setFixedCameraPosition(camera["origin"]["x"], camera["origin"]["y"], camera["origin"]["z"], 0.0, 0.0, 0.0)
			end 
					
			if isKeyDown(VK_SPACE) then
				camera["origin"]["z"] = camera["origin"]["z"] + camera["speed"]
				setFixedCameraPosition(camera["origin"]["x"], camera["origin"]["y"], camera["origin"]["z"], 0.0, 0.0, 0.0)
			end 

			if isKeyDown(VK_SHIFT) then  
				camera["origin"]["z"] = camera["origin"]["z"] - camera["speed"]
				setFixedCameraPosition(camera["origin"]["x"], camera["origin"]["y"], camera["origin"]["z"], 0.0, 0.0, 0.0)
			end
					
			local radianZ = math.rad(camera["angle"]["z"]) 
			local radianY = math.rad(camera["angle"]["y"])             
			local sinusZ = math.sin(radianZ)
			local cosinusZ = math.cos(radianZ)      
			local sinusY = math.sin(radianY)
			local cosinusY = math.cos(radianY)       
			local sinusZ = sinusZ * cosinusY      
			local cosinusZ = cosinusZ * cosinusY 
			local sinusZ = sinusZ * 1.0      
			local cosinusZ = cosinusZ * 1.0     
			local sinusY = sinusY * 1.0 
			local point_atX = camera["origin"]["x"] + sinusZ 
			local point_atY = camera["origin"]["y"] + cosinusZ 
			local point_atZ = camera["origin"]["z"] + sinusY

			pointCameraAtPoint(point_atX, point_atY, point_atZ, 2)

			if isKeyDown(187) then 
				camera["speed"] = camera["speed"] + 0.005
			end 
								   
			if isKeyDown(189) then 
				camera["speed"] = camera["speed"] - 0.005
				if camera["speed"] < 0.001 then camera["speed"] = 0.001 end
			end
		end
		
		if need_update_configuration then
			if os.clock() - need_update_configuration > 15 then
				configuration_main1:set(configuration_main)
				configuration_custom1:set(configuration_custom)
				configuration_manager1:set(configuration_manager)
				configuration_statistics1:set(configuration_statistics)
				configuration_database1:set(configuration_database)
				
				need_update_configuration = nil
			end
		end
	end
end
-- !main

-- thread
function house_founder()
	local type_pickup = {[1273] = {1, 0xFF17A589}, [19522] = {2, 0xFFE74C3C}, [19523] = {3, 0xFFF5B041}}
	
	local renderFont = renderCreateFont("tahoma", 8, font_flag.BOLD + font_flag.SHADOW)
	
	while true do wait(0)
		if not isCharInAnyCar(playerPed) then
			local x, y, z = getCharCoordinates(playerPed)
			for result, handle in pairs(getAllPickups()) do
				if doesPickupExist(handle) then
					local model = getPickupModel(handle)
					if type_pickup[model] then
						local px, py, pz = getPickupCoordinates(handle)
						local distance = getDistanceBetweenCoords3d(x, y, z, px, py, pz)
						if distance < 50 then
							local bool
							for index, value in ipairs(configuration_database["house"]) do
								if type(value) == "table" then
									if getDistanceBetweenCoords3d(px, py, pz, value["position"]["x"], value["position"]["y"], value["position"]["z"])  < 0.2 then
										local temp = os.date("%x", value["time"])
										if temp == os.date("%x") then bool = true end
									end
								end
							end
							
							if not bool then 
								if found_house then
									if isPointOnScreen(px, py, pz) then
										local sx1, sy1 = convert3DCoordsToScreen(x, y, z + 1)
										local sx2, sy2 = convert3DCoordsToScreen(px, py, pz)
										renderDrawLine(sx1, sy1, sx2, sy2, 2, type_pickup[1273][2])
									end
								end
								
								if add_house_in_base and add_house_in_base["bool"] then
									-- printStringNow("Wait for house be added to the base", 50)
									if os.clock() - add_house_in_base["clock"] > 0.5 then add_house_in_base = nil end
								else
									add_house_in_base = {bool = true, position = {x = px, y = py, z = pz}, clock = os.clock()}
									local id = sampGetPickupSampIdByHandle(handle)
									sampSendPickedUpPickup(id)
								end
							end
						elseif found_house then
							if isPointOnScreen(px, py, pz) then
								local bool
								for index, value in ipairs(configuration_database["house"]) do
									if type(value) == "table" then
										if getDistanceBetweenCoords3d(px, py, pz, value["position"]["x"], value["position"]["y"], value["position"]["z"])  < 0.2 then
											local temp = os.date("%x", value["time"])
											if temp == os.date("%x") then bool = true end 
										end
									end
								end
								if not bool then 
									local sx1, sy1 = convert3DCoordsToScreen(x, y, z + 1)
									local sx2, sy2 = convert3DCoordsToScreen(px, py, pz)
									renderDrawLine(sx1, sy1, sx2, sy2, 2, type_pickup[19523][2])
									renderFontDrawText(renderFont, string.format("%0.2f", distance), sx2, sy2, type_pickup[19523][2])
								end
							end
						end 
					end
				end
			end
		end
	end
end

function dynamic_time_update()
	while true do wait(0)
		if sampIsLocalPlayerSpawned() then
			if static_time then
				setTimeOfDay(static_time[1], static_time[2])
			else
				setTimeOfDay(os.date("%H"), os.date("%M"))
			end
		end
	end
end

function render_player_text()
	while true do wait(0)
		local is_vehicle = isCharInAnyCar(playerPed)
		local vehicle = is_vehicle and storeCarCharIsInNoSave(playerPed)
		local model = is_vehicle and getCarModel(vehicle)
		local step, step_vehicle = 0.1, 0.15
		
		if mask_timer then
			local alltime = 600 - math.floor(os.clock() - mask_timer)
			if is_vehicle then
				step_vehicle = step_vehicle - 0.1
				fX, fY, fZ = getOffsetFromCarInWorldCoords(vehicle, (t_vehicle_type[model - 399] == 2 or t_vehicle_type[model - 399] == 8) and 0.5 or 1.2, 0.0, step_vehicle)
			else
				step = step - 0.05
				fX, fY, fZ = getOffsetFromCharInWorldCoords(playerPed, 0.33, 0.0, step)
			end local x, y = convert3DCoordsToScreen(fX, fY, fZ)
			local text = string.format("{C22222}%d{e6e6fa} MINUTES {C22222}%d{e6e6fa} SECONDS", math.floor(alltime / 60), math.fmod(alltime, 60))
			renderFontDrawText(fontSuspect4, text, x, y, 0xFFFFFFFF) 
		end
		
		if aid_timer then
			if os.clock() - aid_timer < 5.5 then
				local fX, fY, fZ
				if is_vehicle then
					step_vehicle =  step_vehicle - 0.1
					fX, fY, fZ = getOffsetFromCarInWorldCoords(vehicle, (t_vehicle_type[model - 399] == 2 or t_vehicle_type[model - 399] == 8) and 0.5 or 1.2, 0.0, step_vehicle)
				else
					step = step - 0.05
					fX, fY, fZ = getOffsetFromCharInWorldCoords(playerPed, 0.33, 0.0, step)
				end local x, y = convert3DCoordsToScreen(fX, fY, fZ)
				local text = string.format("{e6e6fa}HEALME ANIMATION {C22222}%0.3f{e6e6fa} SECONDS", 5.5 - (os.clock() - aid_timer))
				renderFontDrawText(fontSuspect4, text, x, y, 0xFFFFFFFF)
			else aid_timer = nil end
		end
	end
end

function t_weapon_acting_out()
	local weapon_in_hand = 0
	
	while true do wait(0)
		if wasKeyPressed(vkeys["VK_RBUTTON"]) then
			if configuration_main["settings"]["weapon_acting_out"] then
				local current_weapon = getCurrentCharWeapon(playerPed)
				if weapon_in_hand ~= current_weapon then
					weapon_in_hand = current_weapon
					local buffer = configuration_main["weapon_acting_out"][weapon_in_hand]
					if buffer and buffer["status"] and buffer["take"] ~= "" then sampSendChat(string.format("/me %s", u8:decode(buffer["take"]))) end
						
					while getCurrentCharWeapon(playerPed) == weapon_in_hand do wait(0) end
						
					if buffer and buffer["status"] and buffer["away"] ~= "" then sampSendChat(string.format("/me %s", u8:decode(buffer["away"]))) wait(800) end
				end
			end
		else
			if configuration_main["settings"]["weapon_acting_out"] then
				if configuration_main["settings"]["auto_weapon_acting_out"] then
					local current_weapon = getCurrentCharWeapon(playerPed)
					if weapon_in_hand ~= current_weapon then
						weapon_in_hand = current_weapon
						local buffer = configuration_main["weapon_acting_out"][weapon_in_hand]
						if buffer and buffer["status"] and buffer["take"] ~= "" then sampSendChat(string.format("/me %s", u8:decode(buffer["take"]))) end
						
						wait(800)
						while getCurrentCharWeapon(playerPed) == weapon_in_hand do wait(0) end
						
						if buffer and buffer["status"] and buffer["away"] ~= "" then sampSendChat(string.format("/me %s", u8:decode(buffer["away"]))) wait(800) end
					end
				end
			end
		end
	end
end

function t_stroboscopes()
	while true do wait(0)
		if isCharInAnyCar(playerPed) and configuration_main["settings"]["stroboscopes"] then
			local car = storeCarCharIsInNoSave(playerPed)
			local driverPed = getDriverOfCar(car)

			if b_stroboscopes and playerPed == driverPed then

				local ptr = getCarPointer(car) + 1440
				forceCarLights(car, 2)
				wait(50)
				stroboscopes(7086336, ptr, 2, 0, 1, 3)

				while b_stroboscopes do
					wait(0)
						for i = 1, 12 do
							wait(100)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							wait(100)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							wait(100)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							wait(100)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
						end

						if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end

						for i = 1, 6 do
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 1, 3)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
							wait(300)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
						end

						if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end

						for i = 1, 3 do
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 1, 3)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(60)
							if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							wait(60)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(350)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							wait(60)
							if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(50)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							wait(50)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(100)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(100)
							if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							wait(100)
							stroboscopes(7086336, ptr, 2, 0, 0, 1)
							stroboscopes(7086336, ptr, 2, 0, 1, 0)
							wait(80)
							stroboscopes(7086336, ptr, 2, 0, 1, 1)
							stroboscopes(7086336, ptr, 2, 0, 0, 0)
							if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
						end

						if not b_stroboscopes or not isCharInAnyCar(playerPed) then break end
				end
			end
		end
	end
end

function patrol_assistant()
	local last_update_database = os.clock()

	while true do wait(0)
		local x, y, z = getCharCoordinates(playerPed)
		for index, value in pairs(map_marker) do
			if not value["marker"] then 
				map_marker[index]["marker"] = addBlipForCoord(value["x"], value["y"], value["z"])
				changeBlipColour(map_marker[index]["marker"], 0x28B463FF)
			end
			
			local distance = getDistanceBetweenCoords3d(x, y, z, value["x"], value["y"], value["z"])
			if distance < 25 then
				chat("Вы достигли точки назначения.")
				removeBlip(value["marker"])
				map_marker[index] = nil
			end
		end
		
		if add_player_to_base then
			for k, v in ipairs(add_player_to_base) do
				if isPlayerConnected(v[2]) then 
					local current_nickname = sampGetPlayerName(v[2])
					if current_nickname == v[1] then
						local color = sampGetPlayerColor(v[2])
						if color ~= 0 then
							if fraction_color[color] then
								if not configuration_database["player"][v[1]] then configuration_database["player"][v[1]] = {} end
								configuration_database["player"][v[1]]["organization"] = u8(fraction_color[color][1])
								-- configuration_database["player"][v[1]]["residence_in_country"] = sampGetPlayerScore(v[2])
								table.remove(add_player_to_base, k)
								if not need_update_configuration then need_update_configuration = os.clock() end
							else table.remove(add_player_to_base, k) end
						end
					else table.remove(add_player_to_base, k) end
				else table.remove(add_player_to_base, k) end
			end
		end
	end
end
-- !thread

-- callback
function command_mh()
	show_main_menu[0] = not show_main_menu[0]
end

function command_r(text)
	if not string.match(text, "(%S+)") then chat_error("Введите необходимые параметры для /r [текст].") return end
	local mark = string.format("%s-%s", patrol_status["mark"], patrol_status["number"]) -- sampGetMarkCharByVehicle(playerPed)
	for codes, value in pairs(abbreviated_codes) do
		if text == codes then text = string.gsub(text, codes, value[1]) end
	end
	local text = string.gsub(text, "$m", mark)
	local text = string.gsub(text, "$p", calculateZone())
	sampSendChat(string.format("/r %s %s", configuration_main["information"]["rtag"], text))
end

function command_f(text)
	if not string.match(text, "(%S+)") then chat_error("Введите необходимые параметры для /f [текст].") return end
	local mark = string.format("%s-%s", patrol_status["mark"], patrol_status["number"])
	for codes, value in pairs(abbreviated_codes) do
		if text == codes then text = string.gsub(text, codes, value[1]) end
	end
	local text = string.gsub(text, "$m", mark)
	local text = string.gsub(text, "$p", calculateZone())
	sampSendChat(string.format("/f %s %s", configuration_main["information"]["ftag"], text))
end

function command_rn(text)
	if not string.match(text, "(%S+)") then chat_error("Введите необходимые параметры для /rn [текст].") return end
	sampSendChat(string.format("/r (( %s ))", text))
end

function command_fn(text)
	if not string.match(text, "(%S+)") then chat_error("Введите необходимые параметры для /fn [текст].") return end
	sampSendChat(string.format("/f (( %s ))", text))
end

function command_rep(text)
	if not string.match(text, "(%S+)") then chat_error("Введите необходимые параметры для /rep [текст].") return end
	report_text = text
	sampSendChat("/mn")
end

function command_rtag()
	local text = "{e6e6fa}Код\t\t{00CC66}Маркировка{e6e6fa}, {FFCD00}местоположение{e6e6fa} и содержание."
	for index, value in pairs(abbreviated_codes) do
		text = string.format("%s\n{FFCD00}%s{e6e6fa}\t\t%s", text, index, value[1])
	end
	local text = string.gsub(text, "%$m", "{00CC66}" .. sampGetMarkCharByVehicle(playerPed) .. "{e6e6fa}")
	local text = string.gsub(text, "%$p", string.format("{FFCD00}%s{e6e6fa}", calculateZone())) 
	sampShowDialog(1005, "{FFCD00}Список радио-тэгов для рации", text, "Закрыть", "", 5)
end

function command_uk()
	viewing_criminal_code = true
	show_smart_criminal_code[0] = true
end

function command_ak()
	viewing_administrative_code = true
	show_smart_administrative_code[0] = true
end

--[[function command_code()
end--]]

function command_sw(id)
	if string.match(id, "(%d+)") then 
		local id = string.match(id, "(%d+)")
		if tonumber(id) > 0 and tonumber(id) <= 45 then
			forceWeatherNow(id)
			chat("Вы изменили игровую погоду на {COLOR}" .. id .. "{} ID.")
		else chat("ID погоды не должен быть больше 45 и меньше 1.") end
	else chat_error("Введите необходимые параметры для /sw [ид погоды].") end
end

function command_st(parametrs)
	if string.match(parametrs, "(%d+) (%d+)") then
		local hour, min = string.match(parametrs, "(%d+) (%d+)")
		if tonumber(hour) >= 0 and tonumber(hour) <= 23 and tonumber(min) >= 0 and tonumber(min) < 60 then
			patch_samp_time_set(true)
			static_time = {hour, min}
			chat("Вы изменили игровое время на {COLOR}" .. hour .. "{} часов, {COLOR}" .. min .. "{} минут.")
		else
			patch_samp_time_set(false)
			static_time = nil
			chat("Часы не должны быть больше 23 и меньше 0. Минуты не должны быть больше 59 и меньше 0.")
		end
	else
		if static_time then
			static_time = nil
			patch_samp_time_set(false)
			chat("Вы перешли к режиму {COLOR}динамического обновления времени{}.")
		else
			chat_error("Введите необходимые параметры для /st [часы] [минуты].")
		end
	end
end

function command_sskin(parametrs)
	if string.match(parametrs, "(%d+) (%d+)") then
		local id, skin, state = string.match(parametrs, "(%d+) (%d+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 200 then
				local BS = raknetNewBitStream()
				raknetBitStreamWriteInt32(BS, id)
				raknetBitStreamWriteInt32(BS, skin)
				raknetEmulRpcReceiveBitStream(153, BS)
				raknetDeleteBitStream(BS)
				local name = string.gsub(sampGetPlayerName(id),"_"," ")
				chat("Вы установили визуальный скин ({COLOR}" .. skin .. "{}) для игрока " .. name .. "[" .. id .. "].")
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу. Проверьте правильность введёного ID.") end
	elseif string.match(parametrs, "(%d+)") then
		local skin = string.match(parametrs, "(%d+)") 
		local result, id = sampGetPlayerIdByCharHandle(playerPed)
		if result then
			local BS = raknetNewBitStream()
			raknetBitStreamWriteInt32(BS, id)
			raknetBitStreamWriteInt32(BS, skin)
			raknetEmulRpcReceiveBitStream(153, BS)
			raknetDeleteBitStream(BS)
			chat("На Вашего персонажа был установлен визуальный скин {COLOR}" .. skin .. "{}.")
		else chat("Произошла ошибка при попытке выдачи скина.") end
	else chat_error("Введите необходимые параметры для /sskin [id игрока (необязательно)] [ид скина].") end 
end

function command_history(parametrs)
	if tonumber(parametrs) then
		sampSendChat(string.format("/history %s", sampGetPlayerName(parametrs)))
	elseif string.match(parametrs, "(%S+)") then
		sampSendChat(string.format("/history %s", parametrs))
	else chat_error("Введите необходимые параметры для /history [id игрока или никнейм]") end
end

function command_lsms(text)
	if string.match(text, "(%S+)") then
		if last_sms_number then
			command_sms(string.format("%d %s", last_sms_number, text))
		else chat("Ранее вам никто не отправлял SMS-сообщения.") end
	else chat_error("Введите необходимые параметры для /lsms [текст].") end
end

--[[function command_gov()
end--]]

function command_addbl(nickname)
	if string.match(nickname, "(%S+)") then
		if tonumber(nickname) then nickname = sampGetPlayerName(nickname) end
		if nickname then
			if not configuration_main["blacklist"][nickname] then
				configuration_main["blacklist"][nickname] = true
				if not need_update_configuration then need_update_configuration = os.clock() end
				chat(string.format("{COLOR}%s{} был добавлен в чёрный список. Сообщения и звонки более не будут вас беспокоить.", nickname))
			else chat("Данный игрок уже находится в чёрном списке.") end
		else chat("Данный игрок не подключён к серверу. Проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /addbl [никнейм или id игрока].") end
end

function command_delbl(nickname)
	if string.match(nickname, "(%S+)") then
		if tonumber(nickname) then nickname = sampGetPlayerName(nickname) end
		if nickname then
			if configuration_main["blacklist"][nickname] then
				configuration_main["blacklist"][nickname] = false
				if not need_update_configuration then need_update_configuration = os.clock() end
				chat(string.format("{COLOR}%s{} был вынесен из чёрного списка.", nickname))
			else chat("Данный игрок не находится в чёрном списке.") end
		else chat("Данный игрок не подключён к серверу. Проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /delbl [никнейм или id игрока].") end
end

function command_pay(parametrs)
	if string.match(parametrs, "(%d+) (%d+)") then
		local id, money = string.match(parametrs, "(%d+) (%d+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				if tonumber(money) < 200000 then
					lua_thread.create(function()
						while sampGetDistanceToPlayer(id) < 3 do
							if (tonumber(money) - 5000) <= 0 then
								sampSendChat(string.format("/pay %d %d", id, money))
								break
							else
								sampSendChat(string.format("/pay %d 5000", id, money))
								money = tonumber(money) - 5000
							end wait(4000)
						end
					end)
				else chat("Невозможно передать более 200.000$.") end
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу. Проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /pay [ид игрока] [сумма].") end
end

function command_users()
	chat("Данная команда более недоступна в связи с добавлением нового раздела в меню.")
end

function command_rkinfo()
	if not delay_between_deaths then chat("Информация станет доступна после первой смерти.") return end
	local alltime = configuration_main["settings"]["delay_between_deaths"] * 60 - math.floor(os.clock() - delay_between_deaths[2])
	local minute = math.floor(alltime / 60)
	local second = math.fmod(alltime, 60)
	if alltime > 0 and alltime < configuration_main["settings"]["delay_between_deaths"] * 60 then
		if tostring(calculateZone()) == tostring(delay_between_deaths[1]) then
			chat(string.format("[{ff5c33}WARN{}] Вы можете вернуться в район {ff5c33}%s{} через %s:%s ({COLOR}%d{} сек).", delay_between_deaths[1], minute, second, alltime))
		else
			chat(string.format("Вы можете вернуться в район {ff5c33}%s{} через %s:%s ({COLOR}%d{} сек).", delay_between_deaths[1], minute, second, alltime))
		end
	else chat(string.format("Время вышло и вы {00cc99}можете{} вернуться в район %s.", delay_between_deaths[1])) end
end

function command_sms(parametrs)
	if string.match(parametrs, "(%d+) (%S+)") then 
		local number, text = string.match(parametrs, "(%d+) (.+)")
		
		if isPlayerConnected(number) then
			local name = sampGetPlayerName(number)
			if configuration_database["player"][name] and configuration_database["player"][name]["telephone"] then
				number = configuration_database["player"][name]["telephone"]
			else 
				chat("Номер игрока не найден в базе данных.") 
				chat("Попробуйте конвертировать старую базу в новую при помощи команды {COLOR}/convert_telephone{}.")
				return
			end
		end
		
		if string.len(text) > 60 then
			local l1, l2 = line_break_by_space(text, 60)
			sampSendChat(string.format("/sms %d %s ..", number, l1))
			sampSendChat(string.format("/sms %d .. %s", number, l2))
		else
			sampSendChat(string.format("/sms %d %s", number, text))
		end
	else chat_error("Введите необходимые параметры для /sms [номер телефона или id игрока] [сообщение].") end
end

--[[function command_open()
end--]]

function command_rec(parametrs)
	if global_reconnect_status then
		chat("Невозможно переподключится к другому серверу пока идёт переподключение.")
		return
	end
	
	if string.match(parametrs, "(%d+)") then
		local delay = tonumber(parametrs)
		if delay > 0 and delay <= 60 then
			reconnect(delay)
		else chat("Задержка между переподключениями не должна быть менее 0 и более 60 секунд.") end
	else chat_error("Введите необходимые параметры для /rec [задержка].") end
end

function command_recn(parametrs)
	if global_reconnect_status then
		chat("Невозможно переподключится к другому серверу пока идёт переподключение.")
		return
	end

	if string.match(parametrs, "(%d+) (%S+)") then
		local delay, name = string.match(parametrs, "(%d+) (.+)")
		local delay = tonumber(delay)
		if delay > 0 and delay <= 60 then
			sampSetLocalPlayerName(name)
			reconnect(delay)
		else
			chat("Задержка между переподключениями не должна быть менее 0 и более 60 секунд.")
		end
	else
		chat_error("Введите необходимые параметры для /recn [задержка] [никнейм].")
	end
end

function command_recd(parametrs)
	if global_reconnect_status then
		chat("Невозможно переподключится к другому серверу пока идёт переподключение.")
		return
	end

	if string.match(parametrs, "(%S+) (%S+)") then
		local ip, name = string.match(parametrs, "(%S+) (%S+)")
		if string.match(ip, "(%S+):(%d+)") then
			sampSetLocalPlayerName(name)
			reconnect(1, ip)
		else
			chat("IP-адресс сервера должен быть в формате {COLOR}IP:PORT{} (например: {COLOR}5.254.104.132:7777{}).")
		end
	elseif string.match(parametrs, "(%S+)") then
		local ip = parametrs
		if string.match(ip, "(%S+):(%d+)") then
			sampSetLocalPlayerName(name)
			reconnect(1, ip)
		else
			chat("IP-адресс сервера должен быть в формате {COLOR}IP:PORT{} (например: {COLOR}5.254.104.132:7777{}).")
		end
	else
		chat_error("Введите необходимые параметры для /recd [IP-адресс сервера] [никнейм (необязательно)].")
	end
end

function command_strobes()
	b_stroboscopes = not b_stroboscopes
end

--[[function command_lserver()
end--]]

function command_savepass()
	if entered_to_save_password then
		local ip_adress = entered_to_save_password["ip_adress"]
		local nickname = entered_to_save_password["nickname"]
		local password = entered_to_save_password["password"]
		
		if not configuration_manager[ip_adress] then configuration_manager[ip_adress] = {} end
		if not configuration_manager[ip_adress][nickname] then configuration_manager[ip_adress][nickname] = {} end
		
		configuration_manager[ip_adress][nickname] = {
			password = password,
			gauth = configuration_manager[ip_adress][nickname]["gauth"]
		}
		if not need_update_configuration then need_update_configuration = os.clock() end
		chat("Вы успешено сохранили новые данные в менеджере аккаунтов.")
	else chat("В данный момент вы не можете обновить данные в менеджере аккаунтов. Ошибка #1.") end
end

--[[function command_suspect()
end--]]

function command_infred()
	if not night_vision then
		infrared_vision = not infrared_vision
		setInfraredVision(infrared_vision)
		chat("Вы изменили состояние отображения эффекта {COLOR}тепловизора{}.")
	else chat("Отключите отображение эффекта {COLOR}прибора ночного видения{}.") end
end

function command_nigvis()
	if not infrared_vision then
		night_vision = not night_vision
		setNightVision(night_vision)
		chat("Вы изменили состояние отображения эффекта {COLOR}прибора ночного виденья{}.")
	else chat("Отключите отображение эффекта {COLOR}тепловизора{}.") end
end

--[[function command_gate()
end--]]

function command_call(parametrs)
	if string.match(parametrs, "(%d+) 1") then
		local number = string.match(parametrs, "(%d+) 1")
		if isPlayerConnected(number) then
			local name = sampGetPlayerName(number)
			if configuration_database["player"][name] and configuration_database["player"][name]["telephone"] then
				sampSendChat(string.format("/c %s", configuration_database["player"][name]["telephone"]))
			else 
				chat("Номер игрока не найден в базе данных.") 
				chat("Попробуйте конвертировать старую базу в новую при помощи команды {COLOR}/convert_telephone{}.")
				return
			end
		else chat("Данный игрок не подключён к серверу. Проверьте правильность введёного ID.") end
	elseif string.match(parametrs, "(%d+)") then
		sampSendChat(string.format("/c %s", parametrs))
	else sampSendChat("/c") end
end

function command_pull(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 5 then
				local result, ped = sampGetCharHandleBySampPlayerId(id)
				if result then
					if isCharSittingInAnyCar(ped) then
						local model = getCarModel(storeCarCharIsInNoSave(ped)) - 399
						local male = configuration_main["information"]["sex"] and "female" or "male"
						local acting = configuration_main["system_commands"][35]["variations"][male]
						lua_thread.create(function()
							if t_vehicle_type[model] == 2 or t_vehicle_type[model] == 9 then
								local acting = acting[1]
								final_command_handler(acting, {id})
							else 
								local acting = acting[2]
								final_command_handler(acting, {id})
							end
						end)
					else chat("Данный игрок не находится в транспорте.") end
				end
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /pull [id игрока].") end
end

function command_cuff(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][36]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /cuff [id игрока].") end
end

function command_uncuff(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][37]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /uncuff [id игрока].") end
end

function command_arrest(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][38]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /arrest [id игрока].") end
end

function command_su(parametrs)
	if string.match(parametrs, "(%d+) (%d+) (%S+)") then
		local id, stars, reason = string.match(parametrs, "(%d+) (%d+) (.+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 66 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][39]["variations"][male]
					local acting = acting[math.random(1, #acting)] 
					final_command_handler(acting, {id, stars, reason})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	elseif string.match(parametrs, "(%d+)") then
		local id = string.match(parametrs, "(%d+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 66 then
				smart_suspect_id = id
				viewing_criminal_code = false
				show_smart_criminal_code[0] = true
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /su [id игрока] [кол-во звёзд] [причина].") end
end

function command_skip(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][40]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /skip [id игрока].") end
end

function command_clear(parametrs)
	if string.match(parametrs, "(%d+) (%S+)") then
		local id, reason = string.match(parametrs, "(%d+) (.+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 5 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][41]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id, reason})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /clear [id игрока] [причина].") end
end

function command_hold(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][42]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /hold [id игрока].") end
end

function command_ticket(parametrs)
	if string.match(parametrs, "(%d+) (%d+) (%S+)") then
		local id, money, reason = string.match(parametrs, "(%d+) (%d+) (.+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 5 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][43]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id, money, reason})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	elseif string.match(parametrs, "(%d+)") then
		local id = string.match(parametrs, "(%d+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 5 then
				smart_ticket_id = id
				viewing_administrative_code = false
				show_smart_administrative_code[0] = true
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /ticket [id игрока] [сумма] [причина].") end
end

function command_takelic(parametrs)
	if string.match(parametrs, "(%d+) (%S+)") then
		local id, reason = string.match(parametrs, "(%d+) (.+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 10 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][44]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id, reason})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /takelic [id игрока] [причина].") end
end

function command_putpl(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 5 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][45]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /putpl [id игрока].") end
end

function command_rights()
	lua_thread.create(function()
		local male = configuration_main["information"]["sex"] and "female" or "male"
		local acting = configuration_main["system_commands"][46]["variations"][male]
		local acting = acting[math.random(1, #acting)]
		final_command_handler(acting, {id})
	end)
end

function command_search(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][47]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
					search_playerId = id
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /search [id игрока].") end
end

function command_hack(id)
	if string.match(id, "(%d+)") then
		lua_thread.create(function()
			local male = configuration_main["information"]["sex"] and "female" or "male"
			local acting = configuration_main["system_commands"][48]["variations"][male]
			local acting = acting[math.random(1, #acting)]
			final_command_handler(acting, {id})
		end)
	else chat_error("Введите необходимые параметры для /hack [ид дома].") end
end

function command_invite(parametrs)
	if string.match(parametrs, "(%d+) (%d+)") then
		local id, rang = string.match(parametrs, "(%d+) (%d+)")
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 5 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][49]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id})
					invite_playerId, invite_rang = id, rang
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /invite [id игрока] [ранг].") end
end

function command_uninvite(parametrs)
	if string.match(parametrs, "(%d+) (%S+)") then
		local id, reason = string.match(parametrs, "(%d+) (.+)")
		if isPlayerConnected(id) then
			lua_thread.create(function()
				local male = configuration_main["information"]["sex"] and "female" or "male"
				local acting = configuration_main["system_commands"][50]["variations"][male]
				local acting = acting[math.random(1, #acting)]
				final_command_handler(acting, {id, reason})
			end)
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /uninvite [id игрока] [причина].") end
end

function command_rang(parametrs)
	if string.match(parametrs, "(%d+) [+?-]") then
		local id, rang = string.match(parametrs, "(%d+) (.+)")
		if isPlayerConnected(id) then
			lua_thread.create(function()
				local male = configuration_main["information"]["sex"] and "female" or "male"
				local acting = configuration_main["system_commands"][51]["variations"][male]
				local acting = acting[math.random(1, #acting)]
				final_command_handler(acting, {id, rang})
			end)
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /rang [id игрока] [+ или -].") end
end

function command_changeskin(id)
	if string.match(id, "(%d+)") then
		if isPlayerConnected(id) then
			if sampGetDistanceToPlayer(id) < 3 then
				lua_thread.create(function()
					local male = configuration_main["information"]["sex"] and "female" or "male"
					local acting = configuration_main["system_commands"][52]["variations"][male]
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id}) 
				end)
			else chat("Данный игрок находится слишком далеко от Вас.") end
		else chat("Данный игрок не подключён к серверу, проверьте правильность введёного ID.") end
	else chat_error("Введите необходимые параметры для /changeskin [id игрока].") end
end

function command_ud()
	lua_thread.create(function()
		local male = configuration_main["information"]["sex"] and "female" or "male"
		local acting = configuration_main["system_commands"][53]["variations"][male]
		local acting = acting[math.random(1, #acting)]
		final_command_handler(acting, {})
	end)
end

function command_pas()
	lua_thread.create(function()
		local male = configuration_main["information"]["sex"] and "female" or "male"
		local acting = configuration_main["system_commands"][54]["variations"][male]
		local acting = acting[math.random(1, #acting)]
		final_command_handler(acting, {})
		if configuration_main["settings"]["passport_check"] then passport_check = true end 
	end)
end
 
function command_megafon()
	lua_thread.create(function()
		local playerId, vehicleId = sampGetNearestDriver()
		if playerId then
			local normal_vehicleId = vehicleId - 399
			local nickname = sampGetPlayerName(playerId)
			sampSendChat(string.format("/m Внимание, водитель %s %s с госномером #SA-%s.", tf_vehicle_type_name[1][t_vehicle_type[normal_vehicleId]], t_vehicle_name[normal_vehicleId], playerId))
			wait(1500)
			sampSendChat("/m Немедленно остановите ваше транспортное средство и прижмитесь к обочине.") 
			if last_requirement["nickname"] == nickname then
				wait(1000)
				sampSendChat("/m В случае неподчинения будет открыт огонь по колёсам и обшивке транспорта.")
				if configuration_main["settings"]["chase_message"] then
					wait(1000)
					command_r(string.format("$m to DISP, веду погоню за %s %s с госномером #SA-%s. Находимся в районе %s, CODE: 3, недоступен.", tf_vehicle_type_name[2][t_vehicle_type[normal_vehicleId]], t_vehicle_name[normal_vehicleId], playerId, calculateZone()))
				end
			end last_requirement = {nickname = nickname, playerId = playerId}
			
			wait(100)
			chat(string.format("Чтобы объявить {%s}%s{}[%s] в розыск по статье {COLOR}%s{} нажмите сочетание клавиш ПКМ + 5.", sampGetColorByPlayerId(playerId), nickname, playerId, u8:decode(configuration_main["quick_criminal_code"]["insubordination"]["reason"])))
			quick_suspect = {playerId = playerId, clock = os.clock(), stars = configuration_main["quick_criminal_code"]["insubordination"]["stars"], reason = u8:decode(configuration_main["quick_criminal_code"]["insubordination"]["reason"])}
				
			chat(string.format("Чтобы отправить репорт на {%s}%s{}[%s] используйте сочетание клавиш ПКМ + 4.", sampGetColorByPlayerId(playerId), nickname, playerId))
			quick_report = {playerId = playerId, clock = os.clock(), reason = "последите пожалуйста, может оффнуться / суицид."}
		else sampSendChat("/m Немедленно остановите ваше транспортное средство и прижмитесь к обочине.") end
	end)
end

function command_drop_all() 
	drop_all = true
	sampSendChat("/drop")
end

function command_patrol()
	show_setting_patrol[0] = not show_setting_patrol[0]
end

function command_fuel()
	sampSendChat("/fuel")
end

function command_speller(text)
	if string.match(text, "(%S+)") then
		local url = string.format("https://speller.yandex.net/services/spellservice.json/checkText?text=%s", urlencode(u8(text)))
		local result = https.request(url)
		if result then
			local result = decodeJson(result)
			if #result > 0 then
				for k, v in pairs(result) do
					chat(string.format("%s. Ошибка в слове '{COLOR}%s{}', правильно: '{COLOR}%s{}'.", k, u8:decode(v["word"]), u8:decode(v["s"][1])))
				end
			else chat("Всё написано верно.") end
		else chat("Не удалось получить ответ на запрос.") end
	else chat_error("Введите необходимые параметры для /speller [слово или сочетание слов].") end
end

function command_goverment_news(parametrs)
	local index1, index2
	if string.match(parametrs, "(%d+) (%d+)") then index1, index2 = string.match(parametrs, "(%d+) (%d+)") end
	if index1 and index2 then 
		index1, index2 = tonumber(index1), tonumber(index2)
		if index2 - index1 < 0 or index2 - index1 > 10 then
			chat("Невозможно вывести заданный вами диапозон.")
			return
		end
	else
		index1 = #goverment_news - 10
		index2 = #goverment_news
	end
		
	local output = "{ffffff}Список пуст."
		
	for k = index2, index1, -1 do
		if goverment_news[k] then
			local value = goverment_news[k]["value"]
			output = string.format("%s\n\n#%s Новость от %s:", output, k, goverment_news[k]["nickname"])

			for i, v in pairs(value) do
				output = string.format("%s\n[{%s}%s{ffffff}] %s", output, goverment_news[k]["ok"] and "ff5c33" or "00cc99", os.date("%H:%M:%S", goverment_news[k]["time"]), v)
			end
				
			if k > 1 then
				local last_news, current_news = goverment_news[k - 1], goverment_news[k]
				local difference = (current_news["clock"] - last_news["clock"]) / 60
					
				if #last_news["value"] == 3 then
					if #current_news["value"] == 1 then
						if difference < 1 then
							output = string.format("%s\n{ff5c33}** {ffffff}Нарушен интервал (%0.2f из 1) между строками (3-1).", output, difference)
						end
					else
						if difference < 5 then
							output = string.format("%s\n{ff5c33}** {ffffff}Нарушен интервал (%0.2f из 5) между строками (3-3).", output, difference)
						end
					end
				else
					if difference < 3 then
						output = string.format("%s\n{ff5c33}** {ffffff}Нарушен интервал (%0.2f из 3) между строками (1-N).", output, difference)
					end
				end
			end
				
			if #value ~= 1 and #value ~= 3 then
				output = string.format("%s\n{ff5c33}** {ffffff}Отправлено недопустимое количество строк.", output)
			end
		end
	end 
		
	output = string.gsub(output, "{ffffff}Список пуст.\n\n", "{ffffff}")
	sampShowDialog(1, "{FFCD00}Последние гос. новости", output, "Закрыть", "", 0)
		
	--[[local max_index = #goverment_news
	if max_index > 0 then
		local difference = (os.clock() - goverment_news[max_index]["clock"]) / 60
			
		if #goverment_news[max_index]["value"] == 3 then
			local one = difference > 1 and "{00cc99}возможна" or "{ff5c33}невозможна"
			local three =  difference > 5 and "{00cc99}возможна" or "{ff5c33}невозможна"
			
			chat("Последняя новость содержала 3 строки.")
			chat(string.format("Отправка новости содержащей одну строку %s{}, трёх строк %s{}.", one, three))
		else
			local one = difference > 3 and "{00cc99}возможна" or "{ff5c33}невозможна"
			local three =  difference > 3 and "{00cc99}возможна" or "{ff5c33}невозможна"
			
			chat("Последняя новость содержала менее 3х строк.")
			chat(string.format("Отправка новости содержащей одну строку %s{}, трёх строк %s{}.", one, three))
		end
	end--]]
end
	
function command_helper_stats()
	local output = "Раздел\tПодраздел\tЗначение"
	
	output = string.format("%s\nПрочее\tОбщее время нахождения в AFK\t{00cc99}%d{ffffff} сек.", output, configuration_statistics["afk_time"])
	output = string.format("%s\nПрочее\tКоличество сообщений в чат\t{00cc99}%s{ffffff} сообщ.", output, configuration_statistics["message"])
	output = string.format("%s\nПрочее\tКоличество использованных масок\t{00cc99}%s{ffffff} шт.", output, math.floor(configuration_statistics["number_masks_used"]))
	output = string.format("%s\nПрочее\tКоличество использованных аптечек\t{00cc99}%s{ffffff} шт.", output, math.floor(configuration_statistics["time_using_aid_kits"] / 5.5))
	output = string.format("%s\nПрочее\tСуммарное время использования масок\t{00cc99}%s{ffffff} сек.", output, math.floor(configuration_statistics["time_using_mask"]))
	output = string.format("%s\nПрочее\tСуммарное время использования аптечек\t{00cc99}%s{ffffff} сек.", output, math.floor(configuration_statistics["time_using_aid_kits"]))
		
	local commands = {}
	local max_index = 0
	for k, v in pairs(configuration_statistics["commands"]) do
		max_index = max_index + 1
		commands[max_index] = {n = k, v = v}
	end
	table.sort(commands, function(a, b) return (a["v"] > b["v"]) end)
		
	for k, v in pairs(commands) do
		if v["v"] > 1 then output = string.format("%s\nКоманды\t/%s\t{00cc99}%s{ffffff} раз(-а)", output, v["n"], v["v"]) end
	end
		
	sampShowDialog(1, "{FFCD00}Статистика пользователя", output, "Закрыть", "", 5)
end
-- !callback

-- function 
function chat(...) 
    local output, input = string.format("%s|{CECECE}", configuration_main["settings"]["script_color"]), {...}
    for k, v in pairs(input) do
		if string.match(tostring(v), "{}") then v = string.gsub(tostring(v), "{}", "{CECECE}") end 
		output = string.format("%s %s", output, tostring(v)) 
	end sampAddChatMessage(string.gsub(output, "{COLOR}", configuration_main["settings"]["script_color"]), 0xFFFFFFFF)
end -- "{67BEF8}" 

function chat_error(text)
	if string.match(text, "{}") then text = string.gsub(text, "{}", "{CECECE}") end
	local text = string.gsub(text, "%[", string.format("[%s", configuration_main["settings"]["script_color"]))
	local text = string.gsub(text, "%]", "{CECECE}%]")
	sampAddChatMessage(("%s| {CECECE}%s"):format(configuration_main["settings"]["script_color"], string.gsub(tostring(text), "{COLOR}", configuration_main["settings"]["script_color"])), 0xFFFFFFFF)
end

function isPlayerConnected(id)
	local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
	return result and (sampIsPlayerConnected(id) or tonumber(id) == tonumber(playerId))
end

function sampGetDistanceToPlayer(id)
	local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
	if result and playerId == tonumber(id) then return 1 end
	if isPlayerConnected(id) then
		local getted, ped = sampGetCharHandleBySampPlayerId(id)
		if getted then
			local x1, y1, z1 = getCharCoordinates(playerPed)
			local x2, y2, z2 = getCharCoordinates(ped)
			return getDistanceBetweenCoords3d(x1, y1, z1, x2, y2, z2)
		end
	end return 4500
end

function sampGetPlayerName(id)
	return isPlayerConnected(id) and sampGetPlayerNickname(id)
end

function parameter_handler(input)
	local parametrs = {}
	for value in string.gmatch(input, "[^%s]+") do
		if string.match(value, "(%d+)") and string.match(value, "(%D+)") then
			if #parametrs > 0 then
				if string.match(parametrs[#parametrs], "(%d+)") and not string.match(parametrs[#parametrs], "(%D+)") then
					parametrs[#parametrs + 1] = value
				else
					parametrs[#parametrs] = string.format("%s %s", parametrs[#parametrs], value) 
				end
			else
				parametrs[1] = value
			end
		elseif string.match(value, "(%d+)") then
			parametrs[#parametrs + 1] = value
		elseif string.match(value, "(%S+)") then
			if #parametrs > 0 then
				if string.match(parametrs[#parametrs], "(%d+)") and not string.match(parametrs[#parametrs], "(%D+)") then
					parametrs[#parametrs + 1] = value
				else
					parametrs[#parametrs] = string.format("%s %s", parametrs[#parametrs], value) 
				end
			else
				parametrs[1] = value
			end
		end
	end return parametrs
end

function command_handler(profile, command, parametrs)
	if configuration_custom[profile] then
		if configuration_custom[profile][command] then
			local cloud = configuration_custom[profile][command]
			local parametr_block = {}
			
			if cloud["parametrs_amount"] > 0 then
				parametr_block = parameter_handler(parametrs)
				if not (parametr_block and #parametr_block == cloud["parametrs_amount"]) then
					local error_message = ("[%s]"):format(u8:decode(cloud["parametrs"][1]))
					if cloud["parametrs_amount"] > 1 then
						for index = 2, cloud["parametrs_amount"] do
							if cloud["parametrs"][index] then
								error_message = ("%s [%s]"):format(error_message, u8:decode(cloud["parametrs"][index]))
							else 
								error_message = ("%s [параметр %s]"):format(error_message, index)
							end
						end
					end
					chat_error(("Введите необходимые параметры для /%s %s."):format(cloud["name"], error_message))
					return
				end
			end
		
			final_command_handler(cloud["content"], parametr_block, profile, command)
			
		else chat_error(("Произошла ошибка [#2] при попытке выполнить команду [%s]."):format(command)) end
	else chat_error(("Произошла ошибка [#1] при попытке выполнить команду [%s]."):format(command)) end
end

function final_command_handler(array, parametrs_block, profile, command)
	global_command_handler = true
	for index, value in pairs(array) do
		local code = u8:decode(value)
		if string.match(code, "%$wait (%d+)") then
			local delay = tonumber(string.match(code, "%$wait (%d+)")) / 1000
			local start_time = os.clock()
			while os.clock() - start_time < delay do wait(0)
				if global_break_command then break end
			end
		elseif string.match(code, "%$chat (%S+)") then chat(string.match(code, "%$chat (%S+)"))
		elseif string.match(code, "%$script (%S+), (%S+), (%S+)") then
			local profile1, command1, parametrs1 = string.match(code, "%$script (.+), (.+), (.+)")
			if command1 == command then return end
			lua_thread.create(function() command_handler(profile1, command1, line_handler(parametrs1, parametr_block)) end)
		elseif string.match(code, "%$global (%S+), (%S+)") then
			local function1, parametrs1 = string.match(code, "%$global (%S+), (.+)")
			if not _G[function1] then return end
			_G[function1](parametrs1)
		else sampSendChat(line_handler(code, parametrs_block)) end
		
		if global_break_command then
			chat(string.format("Выполнение команды ({COLOR}%s{}) было приостановлено.", command or "системная команда"))
			global_break_command = nil
			break
		end
	end
	global_command_handler = nil
end

function line_handler(input, parametrs_block)
	local tags = {
		["{greeting}"] = greeting_depending_on_the_time(),
		["{name}"] = u8:decode(configuration_main["information"]["name"]),
		["{rang}"] = u8:decode(configuration_main["information"]["rang"]),
		["{fraction}"] = u8:decode(configuration_main["information"]["fraction"]),
		["{number}"] = u8:decode(configuration_main["information"]["number"]),
		["{targeting}"] = targeting_player,
		["{suspect}"] = quick_suspect["playerId"] or "-1",
		["{date}"] = os.date("%d.%m.%Y"),
		["{day}"] = os.date("%d"),
		["{month}"] = os.date("%m"),
		["{year}"] = os.date("%y"),
		["{year4}"] = os.date("%Y"),
		["{day_of_week}"] = os.date("%A"),
		["{time}"] = os.date("%H:%M:%S"),
		["{hour}"] = os.date("%H"),
		["{minute}"] = os.date("%M"),
		["{second}"] = os.date("%S"),
		["{last_number}"] = tostring(last_sms_number)
 	}

	for tag, value in pairs(tags) do
		if string.match(input, tag) then input = string.gsub(input, tag, value) end
	end
	
	for value in string.gmatch(input, "{(%d)}") do
		local index = tonumber(value)
		if index and parametrs_block[index] then input = string.gsub(input, ("{%d}"):format(index), parametrs_block[index]) end
	end 
	
	if string.match(input, "%$rpname%.(%d+)") then
		for value in string.gmatch(input, "%$rpname%.(%d+)") do
			local result = sampGetPlayerName(value)
			local player_name = result and string.gsub(result, "_", " ")
			input = string.gsub(input, string.format("$rpname.%d", value), tostring(player_name))
		end
	end
	
	if string.match(input, "%$name%.(%d+)") then
		for value in string.gmatch(input, "%$name%.(%d+)") do
			local result = sampGetPlayerName(value)
			local player_name = result and result or ""
			input = string.gsub(input, string.format("$name.%d", value), tostring(player_name))
		end
	end return input
end

function greeting_depending_on_the_time()
	local hour = tonumber(os.date("%H"))
	if hour > 3 and hour <= 12 then       return "Доброе утро"
	elseif hour > 12 and hour <= 18 then  return "Добрый день"
	elseif hour > 18 and hour <= 22 then  return "Добрый вечер"
	elseif hour > 22 and hour <= 3 then   return "Доброй ночи"
	else return "Здравствуйте" end
end

function sampGetMarkCharByVehicle(ped) -- "L (Lincoln)", "A (Adam)", "M (Merry)", "C (Charley)", "D (David)", "H (Henry)"
	if isCharSittingInAnyCar(ped) then
		local vehicle = storeCarCharIsInNoSave(ped)
			
		if doesVehicleExist(vehicle) then
			local model = getCarModel(vehicle)
				
			if model >= 596 and model <= 599 then
				local result, int = getNumberOfPassengers(vehicle)
				if result and int > 0 then
					for i = 0, getMaximumNumberOfPassengers(vehicle) do
						if i == 3 then
							passenger = getDriverOfCar(vehicle)
						else
							if not isCarPassengerSeatFree(vehicle, i) then
								passenger = getCharInCarPassengerSeat(vehicle, i)
							end
						end
							
						if passenger ~= ped and sampIsPoliceOfficerById(passenger) then
							return "A", 1
						end
					end
				end return "L", 0
			elseif model == 601 or model == 427 or model == 528 then
				return "C", 3
			elseif model == 415 then
				return "H", 5
			elseif model == 523 then
				return "M", 2
			end
		end
	end return "Unit", 0
end

function sampIsPoliceOfficerById(ped)
	local result, playerId = sampGetPlayerIdByCharHandle(ped)
	if result then
		if sampGetPlayerColor(playerId) == 4278190335 then
			return true
		elseif sampGetPlayerColor(playerId) == 2236962 then
			local skin = "-265-266-267-280-281-282-283-284-285-286-288-300-301-302-303-304-305-306-307-310-311-"
			return string.find(skin, "%-" .. getCharModel(ped) .. "%-")
		end
	end
end

function calculateZone(x, y, z)
	if x == nil then
		x, y, z = getCharCoordinates(playerPed)
	end
	
    local streets = {{"Avispa Country Club", -2667.810, -302.135, -28.831, -2646.400, -262.320, 71.169},
    {"Easter Bay Airport", -1315.420, -405.388, 15.406, -1264.400, -209.543, 25.406},
    {"Avispa Country Club", -2550.040, -355.493, 0.000, -2470.040, -318.493, 39.700},
    {"Easter Bay Airport", -1490.330, -209.543, 15.406, -1264.400, -148.388, 25.406},
    {"Garcia", -2395.140, -222.589, -5.3, -2354.090, -204.792, 200.000},
    {"Shady Cabin", -1632.830, -2263.440, -3.0, -1601.330, -2231.790, 200.000},
    {"East Los Santos", 2381.680, -1494.030, -89.084, 2421.030, -1454.350, 110.916},
    {"LVA Freight Depot", 1236.630, 1163.410, -89.084, 1277.050, 1203.280, 110.916},
    {"Blackfield Intersection", 1277.050, 1044.690, -89.084, 1315.350, 1087.630, 110.916},
    {"Avispa Country Club", -2470.040, -355.493, 0.000, -2270.040, -318.493, 46.100},
    {"Temple", 1252.330, -926.999, -89.084, 1357.000, -910.170, 110.916},
    {"Unity Station", 1692.620, -1971.800, -20.492, 1812.620, -1932.800, 79.508},
    {"LVA Freight Depot", 1315.350, 1044.690, -89.084, 1375.600, 1087.630, 110.916},
    {"Los Flores", 2581.730, -1454.350, -89.084, 2632.830, -1393.420, 110.916},
    {"Starfish Casino", 2437.390, 1858.100, -39.084, 2495.090, 1970.850, 60.916},
    {"Easter Bay Chemicals", -1132.820, -787.391, 0.000, -956.476, -768.027, 200.000},
    {"Downtown Los Santos", 1370.850, -1170.870, -89.084, 1463.900, -1130.850, 110.916},
    {"Esplanade East", -1620.300, 1176.520, -4.5, -1580.010, 1274.260, 200.000},
    {"Market Station", 787.461, -1410.930, -34.126, 866.009, -1310.210, 65.874},
    {"Linden Station", 2811.250, 1229.590, -39.594, 2861.250, 1407.590, 60.406},
    {"Montgomery Intersection", 1582.440, 347.457, 0.000, 1664.620, 401.750, 200.000},
    {"Frederick Bridge", 2759.250, 296.501, 0.000, 2774.250, 594.757, 200.000},
    {"Yellow Bell Station", 1377.480, 2600.430, -21.926, 1492.450, 2687.360, 78.074},
    {"Downtown Los Santos", 1507.510, -1385.210, 110.916, 1582.550, -1325.310, 335.916},
    {"Jefferson", 2185.330, -1210.740, -89.084, 2281.450, -1154.590, 110.916},
    {"Mulholland", 1318.130, -910.170, -89.084, 1357.000, -768.027, 110.916},
    {"Avispa Country Club", -2361.510, -417.199, 0.000, -2270.040, -355.493, 200.000},
    {"Jefferson", 1996.910, -1449.670, -89.084, 2056.860, -1350.720, 110.916},
    {"Julius Thruway West", 1236.630, 2142.860, -89.084, 1297.470, 2243.230, 110.916},
    {"Jefferson", 2124.660, -1494.030, -89.084, 2266.210, -1449.670, 110.916},
    {"Julius Thruway North", 1848.400, 2478.490, -89.084, 1938.800, 2553.490, 110.916},
    {"Rodeo", 422.680, -1570.200, -89.084, 466.223, -1406.050, 110.916},
    {"Cranberry Station", -2007.830, 56.306, 0.000, -1922.000, 224.782, 100.000},
    {"Downtown Los Santos", 1391.050, -1026.330, -89.084, 1463.900, -926.999, 110.916},
    {"Redsands West", 1704.590, 2243.230, -89.084, 1777.390, 2342.830, 110.916},
    {"Little Mexico", 1758.900, -1722.260, -89.084, 1812.620, -1577.590, 110.916},
    {"Blackfield Intersection", 1375.600, 823.228, -89.084, 1457.390, 919.447, 110.916},
    {"Los Santos International", 1974.630, -2394.330, -39.084, 2089.000, -2256.590, 60.916},
    {"Beacon Hill", -399.633, -1075.520, -1.489, -319.033, -977.516, 198.511},
    {"Rodeo", 334.503, -1501.950, -89.084, 422.680, -1406.050, 110.916},
    {"Richman", 225.165, -1369.620, -89.084, 334.503, -1292.070, 110.916},
    {"Downtown Los Santos", 1724.760, -1250.900, -89.084, 1812.620, -1150.870, 110.916},
    {"The Strip", 2027.400, 1703.230, -89.084, 2137.400, 1783.230, 110.916},
    {"Downtown Los Santos", 1378.330, -1130.850, -89.084, 1463.900, -1026.330, 110.916},
    {"Blackfield Intersection", 1197.390, 1044.690, -89.084, 1277.050, 1163.390, 110.916},
    {"Conference Center", 1073.220, -1842.270, -89.084, 1323.900, -1804.210, 110.916},
    {"Montgomery", 1451.400, 347.457, -6.1, 1582.440, 420.802, 200.000},
    {"Foster Valley", -2270.040, -430.276, -1.2, -2178.690, -324.114, 200.000},
    {"Blackfield Chapel", 1325.600, 596.349, -89.084, 1375.600, 795.010, 110.916},
    {"Los Santos International", 2051.630, -2597.260, -39.084, 2152.450, -2394.330, 60.916},
    {"Mulholland", 1096.470, -910.170, -89.084, 1169.130, -768.027, 110.916},
    {"Yellow Bell Gol Course", 1457.460, 2723.230, -89.084, 1534.560, 2863.230, 110.916},
    {"The Strip", 2027.400, 1783.230, -89.084, 2162.390, 1863.230, 110.916},
    {"Jefferson", 2056.860, -1210.740, -89.084, 2185.330, -1126.320, 110.916},
    {"Mulholland", 952.604, -937.184, -89.084, 1096.470, -860.619, 110.916},
    {"Aldea Malvada", -1372.140, 2498.520, 0.000, -1277.590, 2615.350, 200.000},
    {"Las Colinas", 2126.860, -1126.320, -89.084, 2185.330, -934.489, 110.916},
    {"Las Colinas", 1994.330, -1100.820, -89.084, 2056.860, -920.815, 110.916},
    {"Richman", 647.557, -954.662, -89.084, 768.694, -860.619, 110.916},
    {"LVA Freight Depot", 1277.050, 1087.630, -89.084, 1375.600, 1203.280, 110.916},
    {"Julius Thruway North", 1377.390, 2433.230, -89.084, 1534.560, 2507.230, 110.916},
    {"Willowfield", 2201.820, -2095.000, -89.084, 2324.000, -1989.900, 110.916},
    {"Julius Thruway North", 1704.590, 2342.830, -89.084, 1848.400, 2433.230, 110.916},
    {"Temple", 1252.330, -1130.850, -89.084, 1378.330, -1026.330, 110.916},
    {"Little Mexico", 1701.900, -1842.270, -89.084, 1812.620, -1722.260, 110.916},
    {"Queens", -2411.220, 373.539, 0.000, -2253.540, 458.411, 200.000},
    {"Las Venturas Airport", 1515.810, 1586.400, -12.500, 1729.950, 1714.560, 87.500},
    {"Richman", 225.165, -1292.070, -89.084, 466.223, -1235.070, 110.916},
    {"Temple", 1252.330, -1026.330, -89.084, 1391.050, -926.999, 110.916},
    {"East Los Santos", 2266.260, -1494.030, -89.084, 2381.680, -1372.040, 110.916},
    {"Julius Thruway East", 2623.180, 943.235, -89.084, 2749.900, 1055.960, 110.916},
    {"Willowfield", 2541.700, -1941.400, -89.084, 2703.580, -1852.870, 110.916},
    {"Las Colinas", 2056.860, -1126.320, -89.084, 2126.860, -920.815, 110.916},
    {"Julius Thruway East", 2625.160, 2202.760, -89.084, 2685.160, 2442.550, 110.916},
    {"Rodeo", 225.165, -1501.950, -89.084, 334.503, -1369.620, 110.916},
    {"Las Brujas", -365.167, 2123.010, -3.0, -208.570, 2217.680, 200.000},
    {"Julius Thruway East", 2536.430, 2442.550, -89.084, 2685.160, 2542.550, 110.916},
    {"Rodeo", 334.503, -1406.050, -89.084, 466.223, -1292.070, 110.916},
    {"Vinewood", 647.557, -1227.280, -89.084, 787.461, -1118.280, 110.916},
    {"Rodeo", 422.680, -1684.650, -89.084, 558.099, -1570.200, 110.916},
    {"Julius Thruway North", 2498.210, 2542.550, -89.084, 2685.160, 2626.550, 110.916},
    {"Downtown Los Santos", 1724.760, -1430.870, -89.084, 1812.620, -1250.900, 110.916},
    {"Rodeo", 225.165, -1684.650, -89.084, 312.803, -1501.950, 110.916},
    {"Jefferson", 2056.860, -1449.670, -89.084, 2266.210, -1372.040, 110.916},
    {"Hampton Barns", 603.035, 264.312, 0.000, 761.994, 366.572, 200.000},
    {"Temple", 1096.470, -1130.840, -89.084, 1252.330, -1026.330, 110.916},
    {"Kincaid Bridge", -1087.930, 855.370, -89.084, -961.950, 986.281, 110.916},
    {"Verona Beach", 1046.150, -1722.260, -89.084, 1161.520, -1577.590, 110.916},
    {"Commerce", 1323.900, -1722.260, -89.084, 1440.900, -1577.590, 110.916},
    {"Mulholland", 1357.000, -926.999, -89.084, 1463.900, -768.027, 110.916},
    {"Rodeo", 466.223, -1570.200, -89.084, 558.099, -1385.070, 110.916},
    {"Mulholland", 911.802, -860.619, -89.084, 1096.470, -768.027, 110.916},
    {"Mulholland", 768.694, -954.662, -89.084, 952.604, -860.619, 110.916},
    {"Julius Thruway South", 2377.390, 788.894, -89.084, 2537.390, 897.901, 110.916},
    {"Idlewood", 1812.620, -1852.870, -89.084, 1971.660, -1742.310, 110.916},
    {"Ocean Docks", 2089.000, -2394.330, -89.084, 2201.820, -2235.840, 110.916},
    {"Commerce", 1370.850, -1577.590, -89.084, 1463.900, -1384.950, 110.916},
    {"Julius Thruway North", 2121.400, 2508.230, -89.084, 2237.400, 2663.170, 110.916},
    {"Temple", 1096.470, -1026.330, -89.084, 1252.330, -910.170, 110.916},
    {"Glen Park", 1812.620, -1449.670, -89.084, 1996.910, -1350.720, 110.916},
    {"Easter Bay Airport", -1242.980, -50.096, 0.000, -1213.910, 578.396, 200.000},
    {"Martin Bridge", -222.179, 293.324, 0.000, -122.126, 476.465, 200.000},
    {"The Strip", 2106.700, 1863.230, -89.084, 2162.390, 2202.760, 110.916},
    {"Willowfield", 2541.700, -2059.230, -89.084, 2703.580, -1941.400, 110.916},
    {"Marina", 807.922, -1577.590, -89.084, 926.922, -1416.250, 110.916},
    {"Las Venturas Airport", 1457.370, 1143.210, -89.084, 1777.400, 1203.280, 110.916},
    {"Idlewood", 1812.620, -1742.310, -89.084, 1951.660, -1602.310, 110.916},
    {"Esplanade East", -1580.010, 1025.980, -6.1, -1499.890, 1274.260, 200.000},
    {"Downtown Los Santos", 1370.850, -1384.950, -89.084, 1463.900, -1170.870, 110.916},
    {"The Mako Span", 1664.620, 401.750, 0.000, 1785.140, 567.203, 200.000},
    {"Rodeo", 312.803, -1684.650, -89.084, 422.680, -1501.950, 110.916},
    {"Pershing Square", 1440.900, -1722.260, -89.084, 1583.500, -1577.590, 110.916},
    {"Mulholland", 687.802, -860.619, -89.084, 911.802, -768.027, 110.916},
    {"Gant Bridge", -2741.070, 1490.470, -6.1, -2616.400, 1659.680, 200.000},
    {"Las Colinas", 2185.330, -1154.590, -89.084, 2281.450, -934.489, 110.916},
    {"Mulholland", 1169.130, -910.170, -89.084, 1318.130, -768.027, 110.916},
    {"Julius Thruway North", 1938.800, 2508.230, -89.084, 2121.400, 2624.230, 110.916},
    {"Commerce", 1667.960, -1577.590, -89.084, 1812.620, -1430.870, 110.916},
    {"Rodeo", 72.648, -1544.170, -89.084, 225.165, -1404.970, 110.916},
    {"Roca Escalante", 2536.430, 2202.760, -89.084, 2625.160, 2442.550, 110.916},
    {"Rodeo", 72.648, -1684.650, -89.084, 225.165, -1544.170, 110.916},
    {"Market", 952.663, -1310.210, -89.084, 1072.660, -1130.850, 110.916},
    {"Las Colinas", 2632.740, -1135.040, -89.084, 2747.740, -945.035, 110.916},
    {"Mulholland", 861.085, -674.885, -89.084, 1156.550, -600.896, 110.916},
    {"King`s", -2253.540, 373.539, -9.1, -1993.280, 458.411, 200.000},
    {"Redsands East", 1848.400, 2342.830, -89.084, 2011.940, 2478.490, 110.916},
    {"Downtown", -1580.010, 744.267, -6.1, -1499.890, 1025.980, 200.000},
    {"Conference Center", 1046.150, -1804.210, -89.084, 1323.900, -1722.260, 110.916},
    {"Richman", 647.557, -1118.280, -89.084, 787.461, -954.662, 110.916},
    {"Ocean Flats", -2994.490, 277.411, -9.1, -2867.850, 458.411, 200.000},
    {"Greenglass College", 964.391, 930.890, -89.084, 1166.530, 1044.690, 110.916},
    {"Glen Park", 1812.620, -1100.820, -89.084, 1994.330, -973.380, 110.916},
    {"LVA Freight Depot", 1375.600, 919.447, -89.084, 1457.370, 1203.280, 110.916},
    {"Regular Tom", -405.770, 1712.860, -3.0, -276.719, 1892.750, 200.000},
    {"Verona Beach", 1161.520, -1722.260, -89.084, 1323.900, -1577.590, 110.916},
    {"East Los Santos", 2281.450, -1372.040, -89.084, 2381.680, -1135.040, 110.916},
    {"Caligula`s Palace", 2137.400, 1703.230, -89.084, 2437.390, 1783.230, 110.916},
    {"Idlewood", 1951.660, -1742.310, -89.084, 2124.660, -1602.310, 110.916},
    {"Pilgrim", 2624.400, 1383.230, -89.084, 2685.160, 1783.230, 110.916},
    {"Idlewood", 2124.660, -1742.310, -89.084, 2222.560, -1494.030, 110.916},
    {"Queens", -2533.040, 458.411, 0.000, -2329.310, 578.396, 200.000},
    {"Downtown", -1871.720, 1176.420, -4.5, -1620.300, 1274.260, 200.000},
    {"Commerce", 1583.500, -1722.260, -89.084, 1758.900, -1577.590, 110.916},
    {"East Los Santos", 2381.680, -1454.350, -89.084, 2462.130, -1135.040, 110.916},
    {"Marina", 647.712, -1577.590, -89.084, 807.922, -1416.250, 110.916},
    {"Richman", 72.648, -1404.970, -89.084, 225.165, -1235.070, 110.916},
    {"Vinewood", 647.712, -1416.250, -89.084, 787.461, -1227.280, 110.916},
    {"East Los Santos", 2222.560, -1628.530, -89.084, 2421.030, -1494.030, 110.916},
    {"Rodeo", 558.099, -1684.650, -89.084, 647.522, -1384.930, 110.916},
    {"Easter Tunnel", -1709.710, -833.034, -1.5, -1446.010, -730.118, 200.000},
    {"Rodeo", 466.223, -1385.070, -89.084, 647.522, -1235.070, 110.916},
    {"Redsands East", 1817.390, 2202.760, -89.084, 2011.940, 2342.830, 110.916},
    {"The Clown`s Pocket", 2162.390, 1783.230, -89.084, 2437.390, 1883.230, 110.916},
    {"Idlewood", 1971.660, -1852.870, -89.084, 2222.560, -1742.310, 110.916},
    {"Montgomery Intersection", 1546.650, 208.164, 0.000, 1745.830, 347.457, 200.000},
    {"Willowfield", 2089.000, -2235.840, -89.084, 2201.820, -1989.900, 110.916},
    {"Temple", 952.663, -1130.840, -89.084, 1096.470, -937.184, 110.916},
    {"Prickle Pine", 1848.400, 2553.490, -89.084, 1938.800, 2863.230, 110.916},
    {"Los Santos International", 1400.970, -2669.260, -39.084, 2189.820, -2597.260, 60.916},
    {"Garver Bridge", -1213.910, 950.022, -89.084, -1087.930, 1178.930, 110.916},
    {"Garver Bridge", -1339.890, 828.129, -89.084, -1213.910, 1057.040, 110.916},
    {"Kincaid Bridge", -1339.890, 599.218, -89.084, -1213.910, 828.129, 110.916},
    {"Kincaid Bridge", -1213.910, 721.111, -89.084, -1087.930, 950.022, 110.916},
    {"Verona Beach", 930.221, -2006.780, -89.084, 1073.220, -1804.210, 110.916},
    {"Verdant Bluffs", 1073.220, -2006.780, -89.084, 1249.620, -1842.270, 110.916},
    {"Vinewood", 787.461, -1130.840, -89.084, 952.604, -954.662, 110.916},
    {"Vinewood", 787.461, -1310.210, -89.084, 952.663, -1130.840, 110.916},
    {"Commerce", 1463.900, -1577.590, -89.084, 1667.960, -1430.870, 110.916},
    {"Market", 787.461, -1416.250, -89.084, 1072.660, -1310.210, 110.916},
    {"Rockshore West", 2377.390, 596.349, -89.084, 2537.390, 788.894, 110.916},
    {"Julius Thruway North", 2237.400, 2542.550, -89.084, 2498.210, 2663.170, 110.916},
    {"East Beach", 2632.830, -1668.130, -89.084, 2747.740, -1393.420, 110.916},
    {"Fallow Bridge", 434.341, 366.572, 0.000, 603.035, 555.680, 200.000},
    {"Willowfield", 2089.000, -1989.900, -89.084, 2324.000, -1852.870, 110.916},
    {"Chinatown", -2274.170, 578.396, -7.6, -2078.670, 744.170, 200.000},
    {"El Castillo del Diablo", -208.570, 2337.180, 0.000, 8.430, 2487.180, 200.000},
    {"Ocean Docks", 2324.000, -2145.100, -89.084, 2703.580, -2059.230, 110.916},
    {"Easter Bay Chemicals", -1132.820, -768.027, 0.000, -956.476, -578.118, 200.000},
    {"The Visage", 1817.390, 1703.230, -89.084, 2027.400, 1863.230, 110.916},
    {"Ocean Flats", -2994.490, -430.276, -1.2, -2831.890, -222.589, 200.000},
    {"Richman", 321.356, -860.619, -89.084, 687.802, -768.027, 110.916},
    {"Green Palms", 176.581, 1305.450, -3.0, 338.658, 1520.720, 200.000},
    {"Richman", 321.356, -768.027, -89.084, 700.794, -674.885, 110.916},
    {"Starfish Casino", 2162.390, 1883.230, -89.084, 2437.390, 2012.180, 110.916},
    {"East Beach", 2747.740, -1668.130, -89.084, 2959.350, -1498.620, 110.916},
    {"Jefferson", 2056.860, -1372.040, -89.084, 2281.450, -1210.740, 110.916},
    {"Downtown Los Santos", 1463.900, -1290.870, -89.084, 1724.760, -1150.870, 110.916},
    {"Downtown Los Santos", 1463.900, -1430.870, -89.084, 1724.760, -1290.870, 110.916},
    {"Garver Bridge", -1499.890, 696.442, -179.615, -1339.890, 925.353, 20.385},
    {"Julius Thruway South", 1457.390, 823.228, -89.084, 2377.390, 863.229, 110.916},
    {"East Los Santos", 2421.030, -1628.530, -89.084, 2632.830, -1454.350, 110.916},
    {"Greenglass College", 964.391, 1044.690, -89.084, 1197.390, 1203.220, 110.916},
    {"Las Colinas", 2747.740, -1120.040, -89.084, 2959.350, -945.035, 110.916},
    {"Mulholland", 737.573, -768.027, -89.084, 1142.290, -674.885, 110.916},
    {"Ocean Docks", 2201.820, -2730.880, -89.084, 2324.000, -2418.330, 110.916},
    {"East Los Santos", 2462.130, -1454.350, -89.084, 2581.730, -1135.040, 110.916},
    {"Ganton", 2222.560, -1722.330, -89.084, 2632.830, -1628.530, 110.916},
    {"Avispa Country Club", -2831.890, -430.276, -6.1, -2646.400, -222.589, 200.000},
    {"Willowfield", 1970.620, -2179.250, -89.084, 2089.000, -1852.870, 110.916},
    {"Esplanade North", -1982.320, 1274.260, -4.5, -1524.240, 1358.900, 200.000},
    {"The High Roller", 1817.390, 1283.230, -89.084, 2027.390, 1469.230, 110.916},
    {"Ocean Docks", 2201.820, -2418.330, -89.084, 2324.000, -2095.000, 110.916},
    {"Last Dime Motel", 1823.080, 596.349, -89.084, 1997.220, 823.228, 110.916},
    {"Bayside Marina", -2353.170, 2275.790, 0.000, -2153.170, 2475.790, 200.000},
    {"King`s", -2329.310, 458.411, -7.6, -1993.280, 578.396, 200.000},
    {"El Corona", 1692.620, -2179.250, -89.084, 1812.620, -1842.270, 110.916},
    {"Blackfield Chapel", 1375.600, 596.349, -89.084, 1558.090, 823.228, 110.916},
    {"The Pink Swan", 1817.390, 1083.230, -89.084, 2027.390, 1283.230, 110.916},
    {"Julius Thruway West", 1197.390, 1163.390, -89.084, 1236.630, 2243.230, 110.916},
    {"Los Flores", 2581.730, -1393.420, -89.084, 2747.740, -1135.040, 110.916},
    {"The Visage", 1817.390, 1863.230, -89.084, 2106.700, 2011.830, 110.916},
    {"Prickle Pine", 1938.800, 2624.230, -89.084, 2121.400, 2861.550, 110.916},
    {"Verona Beach", 851.449, -1804.210, -89.084, 1046.150, -1577.590, 110.916},
    {"Robada Intersection", -1119.010, 1178.930, -89.084, -862.025, 1351.450, 110.916},
    {"Linden Side", 2749.900, 943.235, -89.084, 2923.390, 1198.990, 110.916},
    {"Ocean Docks", 2703.580, -2302.330, -89.084, 2959.350, -2126.900, 110.916},
    {"Willowfield", 2324.000, -2059.230, -89.084, 2541.700, -1852.870, 110.916},
    {"King`s", -2411.220, 265.243, -9.1, -1993.280, 373.539, 200.000},
    {"Commerce", 1323.900, -1842.270, -89.084, 1701.900, -1722.260, 110.916},
    {"Mulholland", 1269.130, -768.027, -89.084, 1414.070, -452.425, 110.916},
    {"Marina", 647.712, -1804.210, -89.084, 851.449, -1577.590, 110.916},
    {"Battery Point", -2741.070, 1268.410, -4.5, -2533.040, 1490.470, 200.000},
    {"The Four Dragons Casino", 1817.390, 863.232, -89.084, 2027.390, 1083.230, 110.916},
    {"Blackfield", 964.391, 1203.220, -89.084, 1197.390, 1403.220, 110.916},
    {"Julius Thruway North", 1534.560, 2433.230, -89.084, 1848.400, 2583.230, 110.916},
    {"Yellow Bell Gol Course", 1117.400, 2723.230, -89.084, 1457.460, 2863.230, 110.916},
    {"Idlewood", 1812.620, -1602.310, -89.084, 2124.660, -1449.670, 110.916},
    {"Redsands West", 1297.470, 2142.860, -89.084, 1777.390, 2243.230, 110.916},
    {"Doherty", -2270.040, -324.114, -1.2, -1794.920, -222.589, 200.000},
    {"Hilltop Farm", 967.383, -450.390, -3.0, 1176.780, -217.900, 200.000},
    {"Las Barrancas", -926.130, 1398.730, -3.0, -719.234, 1634.690, 200.000},
    {"Pirates in Men`s Pants", 1817.390, 1469.230, -89.084, 2027.400, 1703.230, 110.916},
    {"City Hall", -2867.850, 277.411, -9.1, -2593.440, 458.411, 200.000},
    {"Avispa Country Club", -2646.400, -355.493, 0.000, -2270.040, -222.589, 200.000},
    {"The Strip", 2027.400, 863.229, -89.084, 2087.390, 1703.230, 110.916},
    {"Hashbury", -2593.440, -222.589, -1.0, -2411.220, 54.722, 200.000},
    {"Los Santos International", 1852.000, -2394.330, -89.084, 2089.000, -2179.250, 110.916},
    {"Whitewood Estates", 1098.310, 1726.220, -89.084, 1197.390, 2243.230, 110.916},
    {"Sherman Reservoir", -789.737, 1659.680, -89.084, -599.505, 1929.410, 110.916},
    {"El Corona", 1812.620, -2179.250, -89.084, 1970.620, -1852.870, 110.916},
    {"Downtown", -1700.010, 744.267, -6.1, -1580.010, 1176.520, 200.000},
    {"Foster Valley", -2178.690, -1250.970, 0.000, -1794.920, -1115.580, 200.000},
    {"Las Payasadas", -354.332, 2580.360, 2.0, -133.625, 2816.820, 200.000},
    {"Valle Ocultado", -936.668, 2611.440, 2.0, -715.961, 2847.900, 200.000},
    {"Blackfield Intersection", 1166.530, 795.010, -89.084, 1375.600, 1044.690, 110.916},
    {"Ganton", 2222.560, -1852.870, -89.084, 2632.830, -1722.330, 110.916},
    {"Easter Bay Airport", -1213.910, -730.118, 0.000, -1132.820, -50.096, 200.000},
    {"Redsands East", 1817.390, 2011.830, -89.084, 2106.700, 2202.760, 110.916},
    {"Esplanade East", -1499.890, 578.396, -79.615, -1339.890, 1274.260, 20.385},
    {"Caligula`s Palace", 2087.390, 1543.230, -89.084, 2437.390, 1703.230, 110.916},
    {"Royal Casino", 2087.390, 1383.230, -89.084, 2437.390, 1543.230, 110.916},
    {"Richman", 72.648, -1235.070, -89.084, 321.356, -1008.150, 110.916},
    {"Starfish Casino", 2437.390, 1783.230, -89.084, 2685.160, 2012.180, 110.916},
    {"Mulholland", 1281.130, -452.425, -89.084, 1641.130, -290.913, 110.916},
    {"Downtown", -1982.320, 744.170, -6.1, -1871.720, 1274.260, 200.000},
    {"Hankypanky Point", 2576.920, 62.158, 0.000, 2759.250, 385.503, 200.000},
    {"K.A.C.C. Military Fuels", 2498.210, 2626.550, -89.084, 2749.900, 2861.550, 110.916},
    {"Harry Gold Parkway", 1777.390, 863.232, -89.084, 1817.390, 2342.830, 110.916},
    {"Bayside Tunnel", -2290.190, 2548.290, -89.084, -1950.190, 2723.290, 110.916},
    {"Ocean Docks", 2324.000, -2302.330, -89.084, 2703.580, -2145.100, 110.916},
    {"Richman", 321.356, -1044.070, -89.084, 647.557, -860.619, 110.916},
    {"Randolph Industrial Estate", 1558.090, 596.349, -89.084, 1823.080, 823.235, 110.916},
    {"East Beach", 2632.830, -1852.870, -89.084, 2959.350, -1668.130, 110.916},
    {"Flint Water", -314.426, -753.874, -89.084, -106.339, -463.073, 110.916},
    {"Blueberry", 19.607, -404.136, 3.8, 349.607, -220.137, 200.000},
    {"Linden Station", 2749.900, 1198.990, -89.084, 2923.390, 1548.990, 110.916},
    {"Glen Park", 1812.620, -1350.720, -89.084, 2056.860, -1100.820, 110.916},
    {"Downtown", -1993.280, 265.243, -9.1, -1794.920, 578.396, 200.000},
    {"Redsands West", 1377.390, 2243.230, -89.084, 1704.590, 2433.230, 110.916},
    {"Richman", 321.356, -1235.070, -89.084, 647.522, -1044.070, 110.916},
    {"Gant Bridge", -2741.450, 1659.680, -6.1, -2616.400, 2175.150, 200.000},
    {"Lil` Probe Inn", -90.218, 1286.850, -3.0, 153.859, 1554.120, 200.000},
    {"Flint Intersection", -187.700, -1596.760, -89.084, 17.063, -1276.600, 110.916},
    {"Las Colinas", 2281.450, -1135.040, -89.084, 2632.740, -945.035, 110.916},
    {"Sobell Rail Yards", 2749.900, 1548.990, -89.084, 2923.390, 1937.250, 110.916},
    {"The Emerald Isle", 2011.940, 2202.760, -89.084, 2237.400, 2508.230, 110.916},
    {"El Castillo del Diablo", -208.570, 2123.010, -7.6, 114.033, 2337.180, 200.000},
    {"Santa Flora", -2741.070, 458.411, -7.6, -2533.040, 793.411, 200.000},
    {"Playa del Seville", 2703.580, -2126.900, -89.084, 2959.350, -1852.870, 110.916},
    {"Market", 926.922, -1577.590, -89.084, 1370.850, -1416.250, 110.916},
    {"Queens", -2593.440, 54.722, 0.000, -2411.220, 458.411, 200.000},
    {"Pilson Intersection", 1098.390, 2243.230, -89.084, 1377.390, 2507.230, 110.916},
    {"Spinybed", 2121.400, 2663.170, -89.084, 2498.210, 2861.550, 110.916},
    {"Pilgrim", 2437.390, 1383.230, -89.084, 2624.400, 1783.230, 110.916},
    {"Blackfield", 964.391, 1403.220, -89.084, 1197.390, 1726.220, 110.916},
    {"'The Big Ear'", -410.020, 1403.340, -3.0, -137.969, 1681.230, 200.000},
    {"Dillimore", 580.794, -674.885, -9.5, 861.085, -404.790, 200.000},
    {"El Quebrados", -1645.230, 2498.520, 0.000, -1372.140, 2777.850, 200.000},
    {"Esplanade North", -2533.040, 1358.900, -4.5, -1996.660, 1501.210, 200.000},
    {"Easter Bay Airport", -1499.890, -50.096, -1.0, -1242.980, 249.904, 200.000},
    {"Fisher`s Lagoon", 1916.990, -233.323, -100.000, 2131.720, 13.800, 200.000},
    {"Mulholland", 1414.070, -768.027, -89.084, 1667.610, -452.425, 110.916},
    {"East Beach", 2747.740, -1498.620, -89.084, 2959.350, -1120.040, 110.916},
    {"San Andreas Sound", 2450.390, 385.503, -100.000, 2759.250, 562.349, 200.000},
    {"Shady Creeks", -2030.120, -2174.890, -6.1, -1820.640, -1771.660, 200.000},
    {"Market", 1072.660, -1416.250, -89.084, 1370.850, -1130.850, 110.916},
    {"Rockshore West", 1997.220, 596.349, -89.084, 2377.390, 823.228, 110.916},
    {"Prickle Pine", 1534.560, 2583.230, -89.084, 1848.400, 2863.230, 110.916},
    {"Easter Basin", -1794.920, -50.096, -1.04, -1499.890, 249.904, 200.000},
    {"Leafy Hollow", -1166.970, -1856.030, 0.000, -815.624, -1602.070, 200.000},
    {"LVA Freight Depot", 1457.390, 863.229, -89.084, 1777.400, 1143.210, 110.916},
    {"Prickle Pine", 1117.400, 2507.230, -89.084, 1534.560, 2723.230, 110.916},
    {"Blueberry", 104.534, -220.137, 2.3, 349.607, 152.236, 200.000},
    {"El Castillo del Diablo", -464.515, 2217.680, 0.000, -208.570, 2580.360, 200.000},
    {"Downtown", -2078.670, 578.396, -7.6, -1499.890, 744.267, 200.000},
    {"Rockshore East", 2537.390, 676.549, -89.084, 2902.350, 943.235, 110.916},
    {"San Fierro Bay", -2616.400, 1501.210, -3.0, -1996.660, 1659.680, 200.000},
    {"Paradiso", -2741.070, 793.411, -6.1, -2533.040, 1268.410, 200.000},
    {"The Camel`s Toe", 2087.390, 1203.230, -89.084, 2640.400, 1383.230, 110.916},
    {"Old Venturas Strip", 2162.390, 2012.180, -89.084, 2685.160, 2202.760, 110.916},
    {"Juniper Hill", -2533.040, 578.396, -7.6, -2274.170, 968.369, 200.000},
    {"Juniper Hollow", -2533.040, 968.369, -6.1, -2274.170, 1358.900, 200.000},
    {"Roca Escalante", 2237.400, 2202.760, -89.084, 2536.430, 2542.550, 110.916},
    {"Julius Thruway East", 2685.160, 1055.960, -89.084, 2749.900, 2626.550, 110.916},
    {"Verona Beach", 647.712, -2173.290, -89.084, 930.221, -1804.210, 110.916},
    {"Foster Valley", -2178.690, -599.884, -1.2, -1794.920, -324.114, 200.000},
    {"Arco del Oeste", -901.129, 2221.860, 0.000, -592.090, 2571.970, 200.000},
    {"Fallen Tree", -792.254, -698.555, -5.3, -452.404, -380.043, 200.000},
    {"The Farm", -1209.670, -1317.100, 114.981, -908.161, -787.391, 251.981},
    {"The Sherman Dam", -968.772, 1929.410, -3.0, -481.126, 2155.260, 200.000},
    {"Esplanade North", -1996.660, 1358.900, -4.5, -1524.240, 1592.510, 200.000},
    {"Financial", -1871.720, 744.170, -6.1, -1701.300, 1176.420, 300.000},
    {"Garcia", -2411.220, -222.589, -1.14, -2173.040, 265.243, 200.000},
    {"Montgomery", 1119.510, 119.526, -3.0, 1451.400, 493.323, 200.000},
    {"Creek", 2749.900, 1937.250, -89.084, 2921.620, 2669.790, 110.916},
    {"Los Santos International", 1249.620, -2394.330, -89.084, 1852.000, -2179.250, 110.916},
    {"Santa Maria Beach", 72.648, -2173.290, -89.084, 342.648, -1684.650, 110.916},
    {"Mulholland Intersection", 1463.900, -1150.870, -89.084, 1812.620, -768.027, 110.916},
    {"Angel Pine", -2324.940, -2584.290, -6.1, -1964.220, -2212.110, 200.000},
    {"Verdant Meadows", 37.032, 2337.180, -3.0, 435.988, 2677.900, 200.000},
    {"Octane Springs", 338.658, 1228.510, 0.000, 664.308, 1655.050, 200.000},
    {"Come-A-Lot", 2087.390, 943.235, -89.084, 2623.180, 1203.230, 110.916},
    {"Redsands West", 1236.630, 1883.110, -89.084, 1777.390, 2142.860, 110.916},
    {"Santa Maria Beach", 342.648, -2173.290, -89.084, 647.712, -1684.650, 110.916},
    {"Verdant Bluffs", 1249.620, -2179.250, -89.084, 1692.620, -1842.270, 110.916},
    {"Las Venturas Airport", 1236.630, 1203.280, -89.084, 1457.370, 1883.110, 110.916},
    {"Flint Range", -594.191, -1648.550, 0.000, -187.700, -1276.600, 200.000},
    {"Verdant Bluffs", 930.221, -2488.420, -89.084, 1249.620, -2006.780, 110.916},
    {"Palomino Creek", 2160.220, -149.004, 0.000, 2576.920, 228.322, 200.000},
    {"Ocean Docks", 2373.770, -2697.090, -89.084, 2809.220, -2330.460, 110.916},
    {"Easter Bay Airport", -1213.910, -50.096, -4.5, -947.980, 578.396, 200.000},
    {"Whitewood Estates", 883.308, 1726.220, -89.084, 1098.310, 2507.230, 110.916},
    {"Calton Heights", -2274.170, 744.170, -6.1, -1982.320, 1358.900, 200.000},
    {"Easter Basin", -1794.920, 249.904, -9.1, -1242.980, 578.396, 200.000},
    {"Los Santos Inlet", -321.744, -2224.430, -89.084, 44.615, -1724.430, 110.916},
    {"Doherty", -2173.040, -222.589, -1.0, -1794.920, 265.243, 200.000},
    {"Mount Chiliad", -2178.690, -2189.910, -47.917, -2030.120, -1771.660, 576.083},
    {"Fort Carson", -376.233, 826.326, -3.0, 123.717, 1220.440, 200.000},
    {"Foster Valley", -2178.690, -1115.580, 0.000, -1794.920, -599.884, 200.000},
    {"Ocean Flats", -2994.490, -222.589, -1.0, -2593.440, 277.411, 200.000},
    {"Fern Ridge", 508.189, -139.259, 0.000, 1306.660, 119.526, 200.000},
    {"Bayside", -2741.070, 2175.150, 0.000, -2353.170, 2722.790, 200.000},
    {"Las Venturas Airport", 1457.370, 1203.280, -89.084, 1777.390, 1883.110, 110.916},
    {"Blueberry Acres", -319.676, -220.137, 0.000, 104.534, 293.324, 200.000},
    {"Palisades", -2994.490, 458.411, -6.1, -2741.070, 1339.610, 200.000},
    {"North Rock", 2285.370, -768.027, 0.000, 2770.590, -269.740, 200.000},
    {"Hunter Quarry", 337.244, 710.840, -115.239, 860.554, 1031.710, 203.761},
    {"Los Santos International", 1382.730, -2730.880, -89.084, 2201.820, -2394.330, 110.916},
    {"Missionary Hill", -2994.490, -811.276, 0.000, -2178.690, -430.276, 200.000},
    {"San Fierro Bay", -2616.400, 1659.680, -3.0, -1996.660, 2175.150, 200.000},
    {"Restricted Area", -91.586, 1655.050, -50.000, 421.234, 2123.010, 250.000},
    {"Mount Chiliad", -2997.470, -1115.580, -47.917, -2178.690, -971.913, 576.083},
    {"Mount Chiliad", -2178.690, -1771.660, -47.917, -1936.120, -1250.970, 576.083},
    {"Easter Bay Airport", -1794.920, -730.118, -3.0, -1213.910, -50.096, 200.000},
    {"The Panopticon", -947.980, -304.320, -1.1, -319.676, 327.071, 200.000},
    {"Shady Creeks", -1820.640, -2643.680, -8.0, -1226.780, -1771.660, 200.000}, 
    {"Back o Beyond", -1166.970, -2641.190, 0.000, -321.744, -1856.030, 200.000}, 
    {"Mount Chiliad", -2994.490, -2189.910, -47.917, -2178.690, -1115.580, 576.083},
    {"Tierra Robada", -1213.910, 596.349, -242.990, -480.539, 1659.680, 900.000},
    {"Flint County", -1213.910, -2892.970, -242.990, 44.615, -768.027, 900.000},
    {"Whetstone", -2997.470, -2892.970, -242.990, -1213.910, -1115.580, 900.000},
    {"Bone County", -480.539, 596.349, -242.990, 869.461, 2993.870, 900.000},
    {"Tierra Robada", -2997.470, 1659.680, -242.990, -480.539, 2993.870, 900.000},   
    {"San Fierro", -2997.470, -1115.580, -242.990, -1213.910, 1659.680, 900.000},
    {"Las Venturas", 869.461, 596.349, -242.990, 2997.060, 2993.870, 900.000},
    {"Red County", -1213.910, -768.027, -242.990, 2997.060, 596.349, 900.000}, 
    {"Los Santos", 44.615, -2892.970, -242.990, 2997.060, -768.027, 900.000}}
    for i, v in ipairs(streets) do
        if (x >= v[2]) and (y >= v[3]) and (z >= v[4]) and (x <= v[5]) and (y <= v[6]) and (z <= v[7]) then
            return v[1]
        end
    end
    return "Unknown"
end

function line_break_by_space(text, number, bool)
	if configuration_main["settings"]["line_break_by_space"] then
		local word_list = {}
		for word in string.gmatch(text, "[^%s]+") do
			word_list[#word_list + 1] = {word}
		end
		
		local line_list = {}
		local line_index = 1
		for index, value in pairs(word_list) do
			if not line_list[line_index] then 
				line_list[line_index] = {value[1]} 
			else
				local text = string.format("%s %s", line_list[line_index][1], value[1])
				if string.len(text) > number then
					line_index = line_index  + 1
					line_list[line_index] = {value[1], string.len(value[1])}
				else
					line_list[line_index] = {text, string.len(text)}
				end
			end
		end

		return line_list[1][1], line_list[2][1]
	else
		return string.sub(text, 0, number - 3), string.sub(text, number - 2, string.len(text)) 
	end
end

function patch_samp_time_set(enable)
	if enable and default == nil then
		default = readMemory(sampGetBase() + 0x9C0A0, 4, true)
		writeMemory(sampGetBase() + 0x9C0A0, 4, 0x000008C2, true)
	elseif enable == false and default then
		writeMemory(sampGetBase() + 0x9C0A0, 4, default, true)
		default = nil
	end 
end

function reconnect(delay, ip)
	if type(delay) == ("number") and ip == nil then
		lua_thread.create(function()
			local wdelay = delay * 1000
			sampDisconnectWithReason(1)
			local startTime = os.clock()
			global_reconnect_status = true
			while os.clock() - startTime < delay do wait(0) end
			global_reconnect_status = false
			sampSetGamestate(1)
		end)
	elseif type(delay) == ("number") and type(ip) == ("string") then
		lua_thread.create(function()
			if string.match(ip, "(%S+):(%d+)") then
				local ipadress, port = string.match(ip, "(.+):(%d+)")
				local port = tonumber(port)
				local wdelay = delay * 1000  
				local startTime = os.clock()
				global_reconnect_status = true
				while os.clock() - startTime < delay do wait(0) end
				global_reconnect_status = false
				sampConnectToServer(ipadress, port)
			end
		end)
	end
end

function sampGetColorByPlayerId(id)
	return argb_to_hex(sampGetPlayerColor(id))
end

function argb_to_hex(number)
    return bit.tohex(number, 6)
end

function apply_custom_style()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	local ImVec2 = imgui.ImVec2
     
	style.WindowBorderSize = 0.0
	
	style.WindowRounding         = 4.0
	style.WindowTitleAlign       = ImVec2(0.5, 0.5)
	style.FrameRounding          = 4.0
	style.ItemSpacing            = ImVec2(10, 5)
	style.ScrollbarSize          = 9
	style.ScrollbarRounding      = 0
	style.GrabMinSize            = 9.6
	style.GrabRounding           = 1.0
	style.WindowPadding          = ImVec2(10, 10)
	style.FramePadding           = ImVec2(5, 4)
	style.DisplayWindowPadding   = ImVec2(27, 27)
	style.DisplaySafeAreaPadding = ImVec2(5, 5)
	style.ButtonTextAlign        = ImVec2(0.5, 0.5)
	style.IndentSpacing          = 12.0
	style.Alpha                  = 1.0
	
	if configuration_main["settings"]["customization"] then
		for k, v in pairs(configuration_main["customization"]) do
			if v then colors[clr[k]] = ImVec4(v["r"], v["g"], v["b"], v["a"]) end
		end
	else
		colors[clr.Button]               = ImVec4(0.13, 0.75, 0.55, 0.40)
		colors[clr.ButtonHovered]        = ImVec4(0.13, 0.75, 0.75, 0.60)
		colors[clr.ButtonActive]         = ImVec4(0.13, 0.75, 1.00, 0.80)
		colors[clr.Header]               = ImVec4(0.13, 0.75, 0.55, 0.40)
		colors[clr.HeaderHovered]        = ImVec4(0.13, 0.75, 0.75, 0.60)
		colors[clr.HeaderActive]         = ImVec4(0.13, 0.75, 1.00, 0.80)
		colors[clr.Separator]            = ImVec4(0.13, 0.75, 0.55, 0.40)
		colors[clr.SeparatorHovered]     = ImVec4(0.13, 0.75, 0.75, 0.60)
		colors[clr.SeparatorActive]      = ImVec4(0.13, 0.75, 1.00, 0.80)
		colors[clr.SliderGrab]           = ImVec4(0.13, 0.75, 0.75, 0.80)
		colors[clr.SliderGrabActive]     = ImVec4(0.13, 0.75, 1.00, 0.80)
	end
	
	colors[clr.Text]                 = ImVec4(1.00, 1.00, 1.00, 1.00)
	colors[clr.TextDisabled]         = ImVec4(0.50, 0.50, 0.50, 1.00)
	colors[clr.WindowBg]             = ImVec4(0.06, 0.06, 0.06, 0.94)
	colors[clr.PopupBg]              = ImVec4(0.08, 0.08, 0.08, 0.94)
	colors[clr.Border]               = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.BorderShadow]         = ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg]              = ImVec4(0.44, 0.44, 0.44, 0.60)
	colors[clr.FrameBgHovered]       = ImVec4(0.57, 0.57, 0.57, 0.70)
	colors[clr.FrameBgActive]        = ImVec4(0.76, 0.76, 0.76, 0.80)
	colors[clr.TitleBg]              = ImVec4(0.04, 0.04, 0.04, 1.00)
	colors[clr.TitleBgActive]        = ImVec4(0.16, 0.16, 0.16, 1.00)
	colors[clr.TitleBgCollapsed]     = ImVec4(0.00, 0.00, 0.00, 0.60)
	colors[clr.CheckMark]            = ImVec4(0.13, 0.75, 0.55, 0.80)
	colors[clr.MenuBarBg]            = ImVec4(0.14, 0.14, 0.14, 1.00)
	colors[clr.ScrollbarBg]          = ImVec4(0.02, 0.02, 0.02, 0.53)
	colors[clr.ScrollbarGrab]        = ImVec4(0.31, 0.31, 0.31, 1.00)
	colors[clr.ScrollbarGrabHovered] = ImVec4(0.41, 0.41, 0.41, 1.00)
	colors[clr.ScrollbarGrabActive]  = ImVec4(0.51, 0.51, 0.51, 1.00)
	colors[clr.ResizeGrip]           = ImVec4(0.13, 0.75, 0.55, 0.40)
	colors[clr.ResizeGripHovered]    = ImVec4(0.13, 0.75, 0.75, 0.60)
	colors[clr.ResizeGripActive]     = ImVec4(0.13, 0.75, 1.00, 0.80)
	colors[clr.PlotLines]            = ImVec4(0.61, 0.61, 0.61, 1.00)
	colors[clr.PlotLinesHovered]     = ImVec4(1.00, 0.43, 0.35, 1.00)
	colors[clr.PlotHistogram]        = ImVec4(0.90, 0.70, 0.00, 1.00)
	colors[clr.PlotHistogramHovered] = ImVec4(1.00, 0.60, 0.00, 1.00)
	colors[clr.TextSelectedBg]       = ImVec4(0.26, 0.59, 0.98, 0.35)
end

function imgui.Center(x)
	imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - x / 2)
end

function imgui.CenterText(text)
    imgui.SetCursorPosX(imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(text).x / 2)
	imgui.Text(text)
end

function imgui.CenterColumn(x)
	imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - x / 2)
end

function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end

function imgui.CustomButton(name, color, size)
    local clr = imgui.Col
    imgui.PushStyleColor(clr.Button, color)
    --imgui.PushStyleColor(clr.ButtonHovered, colorHovered)
    --imgui.PushStyleColor(clr.ButtonActive, colorActive)
    if not size then size = imgui.ImVec2(0, 0) end
    local result = imgui.Button(name, size)
    imgui.PopStyleColor(1)
    return result
end

function imgui.NavigationButton(index, icon)
	local clr = imgui.Col
    imgui.PushStyleColor(clr.Button, imgui.ImVec4(0.0, 0.0, 0.0, 0.0))
	local result = imgui.Button(string.format("%s   %s", icon, index))
	imgui.PopStyleColor(1)
    return result
end

function imgui.ToggleButton(index, block, key)
	local result
	if mimgui_addons.ToggleButton(string.format("##%s", index), new.bool(configuration_main[block][key])) then
		configuration_main[block][key] = not configuration_main[block][key]
		result = true
		if not need_update_configuration then need_update_configuration = os.clock() end
	end imgui.SameLine() imgui.Text(index)
	return result
end

function imgui.ToggleButton1(index, block, key, bool)
	local result
	if mimgui_addons.ToggleButton(string.format("##%s", index), new.bool(configuration_main[block][key]["status"])) then
		configuration_main[block][key]["status"] = not configuration_main[block][key]["status"]
		result = true
		if not need_update_configuration then need_update_configuration = os.clock() end
	end if not bool then imgui.SameLine() imgui.Text(index) end
	return result
end

function imgui.ToggleButton2(index, block, key, bool)
	local result
	if mimgui_addons.ToggleButton(string.format("##%s", index), new.bool(configuration_custom[block][key]["status"])) then
		configuration_custom[block][key]["status"] = not configuration_custom[block][key]["status"]
		result = true
		if not need_update_configuration then need_update_configuration = os.clock() end
	end if not bool then imgui.SameLine() imgui.Text(index) end
	return result
end

function imgui.BeginTitleChild(str_id, size, color, offset)
    color = color or imgui.GetStyle().Colors[imgui.Col.Border]
    offset = offset or 30
    local DL = imgui.GetWindowDrawList()
    local posS = imgui.GetCursorScreenPos()
    local rounding = imgui.GetStyle().ChildRounding
    local title = str_id:gsub('##.+$', '')
    local sizeT = imgui.CalcTextSize(title)
    local padd = imgui.GetStyle().WindowPadding
    local bgColor = imgui.ColorConvertFloat4ToU32(imgui.GetStyle().Colors[imgui.Col.WindowBg])

    imgui.PushStyleColor(imgui.Col.ChildBg, imgui.ImVec4(0, 0, 0, 0))
    imgui.PushStyleColor(imgui.Col.Border, imgui.ImVec4(0, 0, 0, 0))
    imgui.BeginChild(str_id, size, true)
    imgui.Spacing()
    imgui.PopStyleColor(2)

    size.x = size.x == -1.0 and imgui.GetWindowWidth() or size.x
    size.y = size.y == -1.0 and imgui.GetWindowHeight() or size.y
    DL:AddRect(posS, imgui.ImVec2(posS.x + size.x, posS.y + size.y), imgui.ColorConvertFloat4ToU32(color), rounding, _, 1)
    DL:AddLine(imgui.ImVec2(posS.x + offset - 3, posS.y), imgui.ImVec2(posS.x + offset + sizeT.x + 3, posS.y), bgColor, 3)
    DL:AddText(imgui.ImVec2(posS.x + offset, posS.y - (sizeT.y / 2)), imgui.ColorConvertFloat4ToU32(color), title)
end

function showHelpMarker(text, delay)
    if imgui.IsItemHovered() then
        if go_hint == nil then go_hint = os.clock() + (delay and delay or 0.3) end
        local alpha = (os.clock() - go_hint) * 5 -- скорость появления
        if os.clock() >= go_hint then
            imgui.PushStyleVarFloat(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
                imgui.PushStyleColor(imgui.Col.PopupBg, imgui.GetStyle().Colors[imgui.Col.ButtonActive])
                    imgui.BeginTooltip()
                    imgui.PushTextWrapPos(450)
                    imgui.TextUnformatted(text)
                    if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then go_hint = nil end
                    imgui.PopTextWrapPos()
                    imgui.EndTooltip()
                imgui.PopStyleColor()
            imgui.PopStyleVar()
        end
    end
end

function isKeyCheckAvailable()
  if not isSampfuncsLoaded() then return not isPauseMenuActive() end
  local result = not isSampfuncsConsoleActive() and not isPauseMenuActive()
  if isSampLoaded() and isSampAvailable() then result = result and not sampIsChatInputActive() and not sampIsDialogActive() end
  return result
end

function sampGetPlayerIdByNickname(name)
	if type(name) == ("string") then
		for id = 0, 1000 do
			if isPlayerConnected(id) then
				local nick = sampGetPlayerName(id)
				if nick == name then return id end
			end
		end
	end
end

function sampGetNearestDriver()
	local output_player, output_vehicle
	local maximum_distance = 55

	if isCharSittingInAnyCar(playerPed) then
		local player_vehicle = storeCarCharIsInNoSave(playerPed)
		
		for result, ped in pairs(getAllChars()) do
			if doesCharExist(ped) and isCharOnScreen(ped) then
				if isCharSittingInAnyCar(ped) and not isCharInAnyPoliceVehicle(ped) then
					local vehicle = storeCarCharIsInNoSave(ped)
					if vehicle ~= player_vehicle then
						if getDriverOfCar(vehicle) == ped then
							local result, playerId = sampGetPlayerIdByCharHandle(ped)
							local distance = sampGetDistanceToPlayer(playerId)
							if distance < maximum_distance then
								maximum_distance = distance
								output_player, output_vehicle = playerId, getCarModel(vehicle)
							end
						end
					end
				end
			end
		end
	end 
	
	return output_player, output_vehicle
end

function stroboscopes(adress, ptr, _1, _2, _3, _4)
	if not isCharInAnyCar(playerPed) or isCharOnAnyBike(playerPed) then return end

	if not b_stroboscopes then
		forceCarLights(storeCarCharIsInNoSave(playerPed), 0)
		callMethod(7086336, ptr, 2, 0, 1, 3)
		callMethod(7086336, ptr, 2, 0, 0, 0)
		callMethod(7086336, ptr, 2, 0, 1, 0)
		markCarAsNoLongerNeeded(storeCarCharIsInNoSave(playerPed))
		return
	end
	
	callMethod(adress, ptr, _1, _2, _3, _4)
end

function getSerialNumber()
	local ffi = require("ffi")
	ffi.cdef[[
	int __stdcall GetVolumeInformationA(
		const char* lpRootPathName,
		char* lpVolumeNameBuffer,
		uint32_t nVolumeNameSize,
		uint32_t* lpVolumeSerialNumber,
		uint32_t* lpMaximumComponentLength,
		uint32_t* lpFileSystemFlags,
		char* lpFileSystemNameBuffer,
		uint32_t nFileSystemNameSize
	);
	]]
	local serial = ffi.new("unsigned long[1]", 0)
	ffi.C.GetVolumeInformationA(nil, nil, 0, serial, nil, nil, nil, 0)
	serial = serial[0]
	
	return serial
end

function urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str
end

function explode_argb(argb)
  local a = bit.band(bit.rshift(argb, 24), 0xFF)
  local r = bit.band(bit.rshift(argb, 16), 0xFF)
  local g = bit.band(bit.rshift(argb, 8), 0xFF)
  local b = bit.band(argb, 0xFF)
  return a, r, g, b
end

function join_argb(a, r, g, b)
  local argb = b  -- b
  argb = bit.bor(argb, bit.lshift(g, 8))  -- g
  argb = bit.bor(argb, bit.lshift(r, 16)) -- r
  argb = bit.bor(argb, bit.lshift(a, 24)) -- a
  return argb
end

function displaying_inline_sections(input, last)
	for k, v in pairs(input) do
		if k == "position" then
			imgui.Text(tostring(k)) imgui.SameLine(150)
			if imgui.Button(u8"Поставить метку") then
				map_marker[#map_marker + 1] = {x = v["x"], y = v["y"], z = v["z"]}
				local x, y, z = getCharCoordinates(playerPed)
				local distance = getDistanceBetweenCoords3d(x, y, z, v["x"], v["y"], v["z"])
				chat(string.format("На вашем радаре отмечен {COLOR}маркер{}, расстояние до него {COLOR}%s{} м.", math.floor(distance)))
			end
		elseif k == "time" then
			imgui.Text(tostring(k)) imgui.SameLine(150)
			if imgui.Button(os.date("%d.%m.%Y, %H:%M:%S", v)) then
				setClipboardText(os.date("%d.%m.%Y, %H:%M:%S", v))
			end
		else
			if type(v) == "table" then
				if imgui.TreeNodeStr(string.format(u8"Таблица '%s'", k)) then
					displaying_inline_sections(v, k)
					imgui.TreePop()
				end
			else
				imgui.Text(tostring(k)) imgui.SameLine(150)
				if imgui.Button(tostring(v)) then
					setClipboardText(tostring(v))
				end
			end
		end
	end
end

function displaying_quick_menu(input) -- original author DonHomka
	local style = imgui.GetStyle()
	local minimal_radius = 60.0
	local maximum_radius = 200.0
	local minimum_interact_radius = 20.0
	
	local DrawList = imgui.GetWindowDrawList()
	local IM_PI = 3.14159265358979323846
	local center = imgui.ImVec2(w / 2, h / 2)
	local drag_delta = imgui.ImVec2(imgui.GetIO().MousePos["x"] - center["x"], imgui.GetIO().MousePos["y"] - center["y"])
	local drag_distance2 = drag_delta["x"] * drag_delta["x"] + drag_delta["y"] * drag_delta["y"]
	local count = #input
		  
	DrawList:PushClipRectFullScreen()
	DrawList:PathArcTo(center, (minimal_radius + maximum_radius)*0.5, 0.0, IM_PI*2.0*0.98, 64)
	DrawList:PathStroke(0x4c010101, true, maximum_radius - minimal_radius)
		
	local input_arc_span = 2 * IM_PI / count
	local drag_angle = math.atan2(drag_delta["y"], drag_delta["x"])

	for index = 1, count do
		local input_label = input[index].title
		local inner_spacing = style["ItemInnerSpacing"]["x"] / minimal_radius / 2
		local input_inner_angle_minimum = input_arc_span * (index - 0.5 + inner_spacing)
		local input_inner_angle_maximum = input_arc_span * (index + 0.5 - inner_spacing)
		local input_outer_angle_minimum = input_arc_span * (index - 0.5 + inner_spacing * (minimal_radius / maximum_radius))
		local input_outer_angle_maximum = input_arc_span * (index + 0.5 - inner_spacing * (minimal_radius / maximum_radius))

		local hovered = false
		while (drag_angle - input_inner_angle_minimum) < 0.0 do
			drag_angle = drag_angle + 2.0 * IM_PI
		end
		
		while (drag_angle - input_inner_angle_minimum) > (2.0 * IM_PI) do
			drag_angle = drag_angle - 2.0 * IM_PI
		end
		
		if drag_distance2 >= (minimum_interact_radius * minimum_interact_radius) then
			if drag_angle >= input_inner_angle_minimum and drag_angle < input_inner_angle_maximum then
				hovered = true
			end
		end

		local arc_segments = (64 * input_arc_span / (2 * IM_PI)) + 1
		DrawList:PathArcTo(center, maximum_radius - style["ItemInnerSpacing"]["x"], input_outer_angle_minimum, input_outer_angle_maximum, arc_segments)
		DrawList:PathArcTo(center, minimal_radius + style["ItemInnerSpacing"]["x"], input_inner_angle_maximum, input_inner_angle_minimum, arc_segments)
		DrawList:PathFillConvex(hovered and configuration_main["settings"]["t_script_color"] or 0xFF232323)

		local text_size = imgui.CalcTextSize(input_label)
		local text_pos = imgui.ImVec2(
			center["x"] + math.cos((input_inner_angle_minimum + input_inner_angle_maximum) * 0.5) * (minimal_radius + maximum_radius) * 0.5 - text_size["x"] * 0.5 + 1,
			center["y"] + math.sin((input_inner_angle_minimum + input_inner_angle_maximum) * 0.5) * (minimal_radius + maximum_radius) * 0.5 - text_size["y"] * 0.5 + 1)
		DrawList:AddText(text_pos, 0xFFFFFFFF, input_label)

		if hovered then
			if imgui.IsMouseClicked(0) then
				input[index]["callback"]()
				return true
			end
		end
	end
	
	DrawList:PopClipRect()
end
-- !function  

-- event
function sampev.onServerMessage(color, text)
	if string.match(text, "(.+) %| Отправил%s(%S+)%[(%d+)%] %(тел%. (%d+)%)") then
		local ad, player_name, playerId, player_number = text:match('(.+) %| Отправил%s(%S+)%[(%d+)%] %(тел%. (%d+)%)')

		if not configuration_database["player"][player_name] then configuration_database["player"][player_name] = {} end
		configuration_database["player"][player_name]["telephone"] = player_number
		
		if not need_update_configuration then need_update_configuration = os.clock() end
		if configuration_main["settings"]["ad_blocker"] then print(text) return false end
	end  
	 
	if string.match(text, "  Объявление проверил сотрудник СМИ") then
		if configuration_main["settings"]["ad_blocker"] then print(text, "\n") return false end
	end

	if string.match(text, "SMS.[%s](.+)[%s].[%s]Отправитель.[%s](%S+)[%s].т.(%d+).") then
		local ftext, player_name, player_number = string.match(text, "SMS.[%s](.+)[%s].[%s]Отправитель.[%s](%S+)[%s].т.(%d+).") 

		if not configuration_database["player"][player_name] then configuration_database["player"][player_name] = {} end
		configuration_database["player"][player_name]["telephone"] = player_number
		
		last_sms_number = player_number
		if not need_update_configuration then need_update_configuration = os.clock() end
		if configuration_main["blacklist"][player_name] then return false end
	end
	
	if string.match(text, "Входящий[%s]звонок[%s].[%s]Номер.[%s](%d+)[%s]{FFCD00}.[%s]Вызывает[%s](.+)") then
		local player_number, player_name = text:match('Входящий[%s]звонок[%s].[%s]Номер.[%s](%d+)[%s]{FFCD00}.[%s]Вызывает[%s](.+)')

		if not configuration_database["player"][player_name] then configuration_database["player"][player_name] = {} end
		configuration_database["player"][player_name]["telephone"] = player_number
		
		if not need_update_configuration then need_update_configuration = os.clock() end
		if configuration_main["blacklist"][player_name] then return false end
	end

	if string.match(text, "SMS.[%s](.+)[%s].[%s]Получатель.[%s](%S+)[%s].т.(%d+).") then
		local ftext, player_name, player_number = string.match(text, "SMS.[%s](.+)[%s].[%s]Получатель.[%s](%S+)[%s].т.(%d+).")

		if not configuration_database["player"][player_name] then configuration_database["player"][player_name] = {} end
		configuration_database["player"][player_name]["telephone"] = player_number
		
		if not need_update_configuration then need_update_configuration = os.clock() end
	end
	
	if string.match(text, "Исходящий[%s]звонок[%s].[%s]Номер.[%s](%d+)[%s]{FFCD00}.[%s]Ожидание[%s]ответа[%s]от[%s](.+)...") then
		local player_number, player_name = string.match(text, "Исходящий[%s]звонок[%s].[%s]Номер.[%s](%d+)[%s]{FFCD00}.[%s]Ожидание[%s]ответа[%s]от[%s](.+)...")

		if not configuration_database["player"][player_name] then configuration_database["player"][player_name] = {} end
		configuration_database["player"][player_name]["telephone"] = player_number
		
		if not need_update_configuration then need_update_configuration = os.clock() end
	end
	
	if color == 869033727 and string.match(text, "[R]") then
		local rang, name, surname, id, ptext = string.match(text, "%[R%]%s(.+)%s(%S+)_(%S+)%[(%d+)%]:%s(.+)")
		local all_name = ("%s_%s"):format(name, surname)
		
		if configuration_main["settings"]["new_radio"] then
			if not list_users[all_name] then
				sampAddChatMessage(("[TAC-1] %s %s %s[%d]: %s"):format(rang, name, surname, id, ptext), 0x9ACD32)
			else
				sampAddChatMessage(("[TAC-1] %s %s%s %s{9ACD32}[%d]: %s"):format(rang, list_users[all_name]["color"], name, surname, id, ptext), 0x9ACD32)
			end
		else
			if not list_users[all_name] then
				sampAddChatMessage(("[R] %s %s %s[%d]: %s"):format(rang, name, surname, id, ptext), 0x33CC66) 
			else
				sampAddChatMessage(("[R] %s %s%s %s{33CC66}[%d]: %s"):format(rang, list_users[all_name]["color"], name, surname, id, ptext), 0x33CC66)
			end
		end return false
	end

	if color == 1721355519 and string.match(text, "[F]") then
		local rang, name, surname, id, ptext = string.match(text, "%[F%]%s(.+)%s(%S+)_(%S+)%[(%d+)%]:%s(.+)")
		local all_name = ("%s_%s"):format(name, surname)

		if configuration_main["settings"]["new_radio"] then
			if not list_users[all_name] then
				sampAddChatMessage(("[TAC-2] %s %s %s[%d]: %s"):format(rang, name, surname, id, ptext), 0x20B2AA)
			else
				sampAddChatMessage(("[TAC-2] %s %s%s %s{20B2AA}[%d]: %s"):format(rang, list_users[all_name]["color"], name, surname, id, ptext), 0x20B2AA)
			end
		else
			if not list_users[all_name] then
				sampAddChatMessage(("[F] %s %s %s[%d]: %s"):format(rang, name, surname, id, ptext), 0x6699CC)
			else
				sampAddChatMessage(("[F] %s %s%s %s{6699CC}[%d]: %s"):format(rang, list_users[all_name]["color"], name, surname, id, ptext), 0x6699CC)
			end
		end

		return false
	end

	if last_suspect_parametrs then
		if string.match(text, "Сейчас у игрока (%d) уровень розыска. Вы можете его увеличить на (%d)") then
			local lstars, nstars = string.match(text, "Сейчас у игрока (%d) уровень розыска. Вы можете его увеличить на (%d)")
			lua_thread.create(function()
				wait(1000)
				sampSendChat(string.format("/su %d %d %s", last_suspect_parametrs[1], nstars, last_suspect_parametrs[3]))
				last_suspect_parametrs = false
			end) return false
		end
		
		if string.match(text, "У этого игрока сейчас максимальный уровень розыска") then
			last_suspect_parametrs = false
			return true
		end
	end
	
	if string.match(text, "(.+) (%S+)%[(%d+)%] посадил (%S+)%[(%d+)%] в машину") then
		local officer_rang, officer_name, officer_id, suspect_name, suspect_id = string.match(text, "(.+) (%S+)%[(%d+)%] посадил (%S+)%[(%d+)%] в машину")
		local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
		if tonumber(playerId) == tonumber(officer_id) then
			chat("Если желаете объвить о том, что доставляете подозреваемого в департамент, нажмите {COLOR}Y{}.")
			accept_the_offer = 1
		end
	end
	
	if string.match(text, "(.+)[^%d](%d+)[^%d] был обнаружен в районе") then
		local nickname, playerId = string.match(text, "(.+)[^%d](%d+)[^%d] был обнаружен в районе")
		if isPlayerConnected(playerId) then
			chat(string.format("Чтобы объявить {%s}%s{}[%s] в розыск по статье {COLOR}%s{} нажмите сочетание клавиш ПКМ + 5.", sampGetColorByPlayerId(playerId), nickname, playerId, u8:decode(configuration_main["quick_criminal_code"]["insubordination"]["reason"])))
			quick_suspect = {playerId = playerId, clock = os.clock(), stars = configuration_main["quick_criminal_code"]["insubordination"]["stars"], reason = u8:decode(configuration_main["quick_criminal_code"]["insubordination"]["reason"])}
		end
	end
	
	if string.match(text, "Вы%sвыписали%s(.+)%sштраф%sв%sразмере%s(%d+)..%sПричина.%s(.+)") then
		local nickname, money, reason = string.match(text, "Вы%sвыписали%s(.+)%sштраф%sв%sразмере%s(%d+)..%sПричина.%s(.+)")
		local playerId = sampGetPlayerIdByNickname(nickname)
		if isPlayerConnected(playerId) then
			chat(string.format("Чтобы объявить {%s}%s{}[%s] в розыск по статье {COLOR}%s{} нажмите сочетание клавиш ПКМ + 5.", sampGetColorByPlayerId(playerId), nickname, playerId, u8:decode(configuration_main["quick_criminal_code"]["refusal_to_pay"]["reason"])))
			quick_suspect = {playerId = playerId, clock = os.clock(), stars = configuration_main["quick_criminal_code"]["refusal_to_pay"]["stars"], reason = u8:decode(configuration_main["quick_criminal_code"]["refusal_to_pay"]["reason"])}
		end
	end
	
	if string.match(text, "(.+)[%s+](.+)[%s+]изъял[%s+]у[%s+](.+)[%s+]патроны[%s+].(%d+)[%s+]шт..") then
		local rang, name, pname, bull = string.match(text, "(.+)[%s+](.+)[%s+]изъял[%s+]у[%s+](.+)[%s+]патроны[%s+].(%d+)[%s+]шт..")
		local _, id = sampGetPlayerIdByCharHandle(playerPed)
		if name == sampGetPlayerName(id) then
			lua_thread.create(function()
				wait(850)
				if not configuration_main["information"]["sex"] then
					sampSendChat("/me достал ZIP-пакет и чёрный маркер, открыл zip-пакет и сложил туда изъятые боеприпасы.")
					wait(1500); sampSendChat("/me закрыв zip-пакет, написал информацию на нём с помощью чёрного маркера, после убрал их обратно.")
				else
					sampSendChat("/me достала zip-пакет и чёрный маркер, открыла zip-пакет и сложила туда изъятые боеприпасы.")
					wait(1500); sampSendChat("/me закрыв zip-пакет, написала информацию на нём с помощью чёрного маркера, после убрала их обратно.")
				end
			end)
		end
	end
	
	if string.match(text, "(.+)[%s+](.+)[%s+]изъял[%s+]у[%s+](.+)[%s+](%d+)[%s+]г[%s+]наркотиков") then
		local rang, name, pname, drugs = string.match(text, "(.+)[%s+](.+)[%s+]изъял[%s+]у[%s+](.+)[%s+](%d+)[%s+]г[%s+]наркотиков")
		local _, id = sampGetPlayerIdByCharHandle(playerPed)
		if name == sampGetPlayerName(id) then
			lua_thread.create(function()
				wait(850)
				if not configuration_main["information"]["sex"] then
					sampSendChat("/me достал zip-пакет и чёрный маркер, затем раскрыл zip-пакет и положил туда изъятые неизвестнные в-ва.")
					wait(1500); sampSendChat("/me держа в левой руке маркер, правой рукой закрыл пакет и промаркировал его.")
					wait(1500); sampSendChat("/me убрал zip-пакет и чёрный маркер обратно.")
				else
					sampSendChat("/me достала zip-пакет и чёрный маркер, затем раскрыла zip-пакет и положила туда изъятые неизвестнные в-ва.")
					wait(1500); sampSendChat("/me держа в левой руке маркер, правой рукой закрыла пакет и промаркировала его.")
					wait(1500); sampSendChat("/me убрала zip-пакет и чёрный маркер обратно.")
				end
			end)
		end
	end
	
	if string.match(text, "Вы оглушили (%S+) на 15 секунд") then
		lua_thread.create(function() wait(150)
			if not configuration_main["information"]["sex"] then
				if getCurrentCharWeapon(playerPed) == 3 then
					local acting = {
						[1] = {u8("/me удерживая дубинку в руке, размахнулся и нанёс удар по нарушителю.")},
						[2] = {u8("/me снял дубинку с пояса и нанёс удар достаточной силы, чтобы оглушить подозреваемого.")}
					}
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id, stars, reason})
				else
					sampSendChat("/me выхватил тэйзер из держателя, навёлся на нарушителя и нажал на кнопку спуска.")
				end
			else
				if getCurrentCharWeapon(playerPed) == 3 then
					local acting = {
						[1] = {u8("/me удерживая дубинку в руке, размахнулась и нанесла удар по нарушителю.")},
						[2] = {u8("/me сняла дубинку с пояса и нанесла удар достаточной силы, чтобы оглушить подозреваемого.")}
					}
					local acting = acting[math.random(1, #acting)]
					final_command_handler(acting, {id, stars, reason})
				else
					sampSendChat("/me выхватила тэйзер из держателя, навелась на нарушителя и нажала на кнопку спуска.")
				end
			end
		end)
	end
	
	if invite_playerId then 
		if string.match(text, "(.+) принимает Ваше предложение") then 
			if tonumber(invite_rang) > 1 then
				lua_thread.create(function()
					for i = 2, tonumber(invite_rang) do
						sampSendChat(string.format("/rang %s +", invite_playerId))
						wait(900)
					end invite_playerId, invite_rang = nil, nil
				end)
			end
		end
	end
	
	if configuration_main["settings"]["aid_timer"] then
		if string.match(text, "Вы использовали аптечку. Здоровье пополнено на 60 единиц") then
			if not aid_timer then
				configuration_statistics["time_using_aid_kits"] = configuration_statistics["time_using_aid_kits"] + 5.5
				if not need_update_configuration then need_update_configuration = os.clock() end
				aid_timer = os.clock()
			end
		end
	end
	
	if configuration_main["settings"]["auto_buy_mandh"] then
		if string.match(text, "Сейчас[%s]у[%s]Вас[%s]аптечек:[%s]{33cc33}(%d)[%s]шт.") then
			local aid = tonumber(string.match(text, "Сейчас[%s]у[%s]Вас[%s]аптечек:[%s]{33cc33}(%d+)[%s]шт."))
			local aid = 5 - aid
			need_to_purchase["aid"] = aid
		end

		if string.match(text, "Сейчас[%s]у[%s]Вас[%s]масок:[%s]{33cc33}(%d)[%s]шт.") then
			local mask = tonumber(string.match(text, "Сейчас[%s]у[%s]Вас[%s]масок:[%s]{33cc33}(%d+)[%s]шт."))
			local mask = 3 - mask
			need_to_purchase["mask"] = mask
		end
	end
	
	if string.match(text, "Гос%. новости: (%S+)%[(%d+)%]: (.+)") then
		local nickname, player_id, t_text = string.match(text, "Гос%. новости: (%S+)%[(%d+)%]: (.+)") 
		if #goverment_news > 0 then
			local max_index = #goverment_news
			if goverment_news[max_index]["nickname"] == nickname then
				if os.clock() - goverment_news[max_index]["clock"] < 4 then
					goverment_news[max_index]["clock"], goverment_news[max_index]["time"] = os.clock(), os.time()
					table.insert(goverment_news[max_index]["value"], t_text)
				else
					goverment_news[max_index + 1] = {nickname = nickname, value = {t_text}, clock = os.clock(), time = os.time(), ok = was_pause}
				end
			else
				goverment_news[max_index + 1] = {nickname = nickname, value = {t_text}, clock = os.clock(), time = os.time(), ok = was_pause}
			end
		else
			goverment_news[1] = {nickname = nickname, value = {t_text}, clock = os.clock(), time = os.time(), ok = was_pause}
		end
	end
	
	if string.match(text, "(.+) (%S+)%[(%d+)%] объявил (%S+)%[(%d+)%] в розыск %[(%d+)%/6], причина: (.+)") then
		local rang, officer_nickname, officer_id, suspect_nickname, suspect_id, wanted, reason = string.match(text, "(.+) (%S+)%[(%d+)%] объявил (%S+)%[(%d+)%] в розыск %[(%d+)%/6], причина: (.+)")
		if not configuration_database["player"][suspect_nickname] then configuration_database["player"][suspect_nickname] = {} end
		if not configuration_database["player"][suspect_nickname]["wanted_log"] then configuration_database["player"][suspect_nickname]["wanted_log"] = {} end
		
		table.insert(configuration_database["player"][suspect_nickname]["wanted_log"], {
			officer_rang = rang,
			officer_nickname = officer_nickname,
			suspect_nickname = suspect_nickname, 
			wanted = tonumber(wanted), 
			reason = u8(reason),
			time = os.time(),
			ok = was_pause
		})
		
		if not need_update_configuration then need_update_configuration = os.clock() end
	end
	
	if string.match(text, "Вы объявили (%S+)%[(%d+)%] в розыск%. Причина: (.+)%. Текущий уровень розыска (%d+)") then
		local suspect_nickname, suspect_id, reason, wanted = string.match(text, "Вы объявили (%S+)%[(%d+)%] в розыск%. Причина: (.+)%. Текущий уровень розыска (%d+)")
		local result, officer_id = sampGetPlayerIdByCharHandle(playerPed)
		local officer_nickname = sampGetPlayerName(officer_id)
		if not configuration_database["player"][suspect_nickname] then configuration_database["player"][suspect_nickname] = {} end
		if not configuration_database["player"][suspect_nickname]["wanted_log"] then configuration_database["player"][suspect_nickname]["wanted_log"] = {} end
		
		table.insert(configuration_database["player"][suspect_nickname]["wanted_log"], {
			officer_rang = rang,
			officer_nickname = officer_nickname,
			suspect_nickname = suspect_nickname,
			wanted = 0,
			time = os.time(),
			ok = was_pause
		})
		
		if not need_update_configuration then need_update_configuration = os.clock() end
	end
	
	if string.match(text, "(.+) (%S+)%[(%d+)%] снял розыск у (%S+)%[(%d+)%]") then
		local rang, officer_nickname, officer_id, suspect_nickname, suspect_id = string.match(text, "(.+) (%S+)%[(%d+)%] снял розыск у (%S+)%[(%d+)%]")
		if not configuration_database["player"][suspect_nickname] then configuration_database["player"][suspect_nickname] = {} end
		if not configuration_database["player"][suspect_nickname]["wanted_log"] then configuration_database["player"][suspect_nickname]["wanted_log"] = {} end
		
		table.insert(configuration_database["player"][suspect_nickname]["wanted_log"], {
			officer_rang = rang,
			officer_nickname = officer_nickname,
			suspect_nickname = suspect_nickname,
			wanted = 0,
			time = os.time(),
			ok = was_pause
		})
		
		if not need_update_configuration then need_update_configuration = os.clock() end
	end
	
	if configuration_main["modification"]["id_postfix_after_nickname"] then
		if string.match(text, "(%a+)_(%a+)") then
			if not (string.match(text, "(%a+)_(%a+)%)%[(%d+)%]") or string.match(text, "(%a+)_(%a+)%[(%d+)%]")) then
				for name, surname in text:gmatch("(%a+)_(%a+)") do
					local allname = string.format("%s_%s", name, surname)
					local id = sampGetPlayerIdByNickname(allname)
				
					if id and isPlayerConnected(id) then
						if not string.match(text, allname .. "%[(%d+)%]") then
							text = text:gsub(allname, string.format("%s[%s]", allname, id))
						end
					end
				end return {color, text}
			end
		end
	end
end

function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
	if add_house_in_base and add_house_in_base["bool"] then
		if string.match(title, "Дом на аукционе") or string.match(title, "Дом свободен") then
			if string.match(text, "Тип:[\t]+(.+)\nНомер[%s]дома:[\t]+(%d+)\n\nВместимость:[\t]+(%d+)[%s]чел.\nСтоимость:[\t]+(%d+)%$\nЕжедневная[%s]квартплата:[\t]+от[%s](%d+)%$") then
				local house, number, capacity, price, rent =
				string.match(text, "Тип:[\t]+(.+)\nНомер[%s]дома:[\t]+(%d+)\n\nВместимость:[\t]+(%d+)[%s]чел.\nСтоимость:[\t]+(%d+)%$\nЕжедневная[%s]квартплата:[\t]+от[%s](%d+)%$")
				
				local found = false
				for k, v in pairs(configuration_database["house"]) do if v["id"] == tonumber(number) then found = k end end
				if found then
					configuration_database["house"][found] = {id = tonumber(number), house = u8(house), capacity = tonumber(capacity), price = tonumber(price), rent = tonumber(rent), position = add_house_in_base.position, time = os.time()}
				else
					table.insert(configuration_database["house"], {id = tonumber(number), house = u8(house), capacity = tonumber(capacity), price = tonumber(price), rent = tonumber(rent), position = add_house_in_base.position, time = os.time()})
				end
				
				if found_house then chat_error(string.format("Мы нашли свободный домик [#%s], это не такой успех, но всё же!", number)) end
				if not need_update_configuration then need_update_configuration = os.clock() end
				
				add_house_in_base = nil
				return false
			end
		end
		
		if string.match(title, "Дом занят") then
			if string.match(text, "Владелец:[\t]+{33CCFF}(%S+)\n\n{FFFFFF}Тип:[\t]+(.+)\nНомер[%s]дома:[\t]+(%d+)\nВместимость:[\t]+(%d+)[%s]чел.\nСтоимость:[\t]+(%d+)%$\nЕжедневная[%s]квартплата:[\t]+от[%s](%d+)%$") then
				local owner, house, number, capacity, price, rent =
				string.match(text, "Владелец:[\t]+{33CCFF}(%S+)\n\n{FFFFFF}Тип:[\t]+(.+)\nНомер[%s]дома:[\t]+(%d+)\nВместимость:[\t]+(%d+)[%s]чел.\nСтоимость:[\t]+(%d+)%$\nЕжедневная[%s]квартплата:[\t]+от[%s](%d+)%$")
				
				local found = false
				for k, v in pairs(configuration_database["house"]) do if v.id == tonumber(number) then found = k end end
				if found then
					configuration_database["house"][found] = {id = tonumber(number), owner = owner, house = u8(house), capacity = tonumber(capacity), price = tonumber(price), rent = tonumber(rent), position = add_house_in_base.position, time = os.time()}
				else
					table.insert(configuration_database["house"], {id = tonumber(number), owner = owner, house = u8(house), capacity = tonumber(capacity), price = tonumber(price), rent = tonumber(rent), position = add_house_in_base.position, time = os.time()})
				end
				
				if found_house then chat_error(string.format("Мы нашли домик [#%s], которым владеет %s, это успех!", number, owner)) end
				if not need_update_configuration then need_update_configuration = os.clock() end
				
				add_house_in_base = nil
				return false
			end
		end 
	end

	if report_text then
		if string.find(title, "Меню игрока") then 
			if string.find(text, "6. Связь с администрацией") then
				sampSendDialogResponse(dialogId, 1, 5, -1)
				return false
			else
				report_text = nil
				chat("Произошла ошибка при попытке отправить сообщение администрации.")
				return false
			end
		end

		if string.find(title,"Связь с администрацией") then
			sampSendDialogResponse(dialogId, 1, 0, report_text) 
			report_text = nil
			return false
		end
	end
	
	if drop_all then
		if string.find(title, "Какое оружие выбросить?") then
			sampSendDialogResponse(dialogId, 1, 0, -1)
			drop_all = false
			return false
		end
	end
	
	if configuration_main["settings"]["obtaining_weapons"] then
		if dialogId == 175 then
			if string.find(title, "Тюрьма") or string.find(title, "ФБР") or string.find(title, "Управление полиции") then
				for index = 1, 12 do
					if configuration_main["obtaining_weapons"][index]["status"] then
						sampSendDialogResponse(dialogId, 1, index - 1, -1)
					end
				end
			end
		end

		if dialogId == 175 then return false end
	end
	
	
	if configuration_main["settings"]["auto_buy_mandh"] then
		if string.find(title, "Покупка аптечек") then
			if need_to_purchase["aid"] > 0 then
				sampSendDialogResponse(dialogId, 1, need_to_purchase["aid"] - 1, -1)
				sampSendDialogResponse(dialogId, 0, -1, -1)
				sampSendChat("/buy")
				return false
			end
		end

		if string.find(title, "Покупка масок") then
			if need_to_purchase["mask"] > 0 then
				sampSendDialogResponse(dialogId, 1, need_to_purchase["mask"] - 1, -1)
				sampSendDialogResponse(dialogId, 0, -1, -1)
				sampSendChat("/buy")
				return false
			end
		end
	end
	
	if configuration_main["improved_dialogues"][1]["status"] then
		if string.find(title, "Лидеры") then
			local output = "{e6e6fa}Имя\t{e6e6fa}Организация\t{e6e6fa}Должность\t{e6e6fa}Статус\n"
			local total, online = 0, 0
			
			for line in string.gmatch(text, "[^\n]+") do
				if not string.match(line, "Имя") then
					local nickname, position, fraction, status = string.match(line, "(.+)\t(.+)\t(.+)\t(.+)")
					local playerId = sampGetPlayerIdByNickname(nickname)
					if not playerId then output = string.format("%s{696969}%s\t{696969}%s\t{696969}%s\t{ff5c33}Оффлайн\n", output, nickname, position, fraction)
					else 
						online = online + 1
						output = string.format(string.format("%s{%s}%s\t%s\t%s\t{00cc99}Онлайн\n", output, sampGetColorByPlayerId(playerId), nickname, position, fraction)) 
					end total = total + 1
				end
			end
			
			local caption = string.format("{e6e6fa}Всего лидеров {FFCD00}%d чел. {00CC66}(онлайн %d)", total, online)
			return {dialogId, style, caption, button1, button2, output}
		end
	end -- leaders
	
	if configuration_main["improved_dialogues"][2]["status"] then
		if string.find(title, "В подразделении") or string.find(title, "В организации") then
			local output = "{e6e6fa}Имя\t{e6e6fa}Ранг и должность\t{e6e6fa}Телефон\t{e6e6fa}Дополнительно"
			
			for line in string.gmatch(text, "[^\n]+") do
				if string.match(line, "(%d+)%. (%S+)%[(%d+)%]\t(%d+) ранг. (.+)\t(%d+)\t(.+)") then
					local id, nickname, playerId, rang_number, rang_name, number, status = string.match(line, "(%d+)%. (%S+)%[(%d+)%]\t(%d+) ранг%. (.+)\t(%d+)\t(.+)")
					output = string.format("%s\n%s. %s[%s]{%s}**\t%s ранг. %s\t%s\t{ff5c33}%s", output, id, nickname, playerId, sampGetColorByPlayerId(playerId), rang_number, rang_name, number, status)
				elseif string.match(line, "(%d+)%. (%S+)%[(%d+)%]\t(%d+) ранг. (.+)\t(%d+)\t") then
					local id, nickname, playerId, rang_number, rang_name, number = string.match(line, "(%d+)%. (%S+)%[(%d+)%]\t(%d+) ранг%. (.+)\t(%d+)\t")
					output = string.format("%s\n%s. %s[%s]{%s}**\t%s ранг. %s\t%s\t{00cc99}Онлайн", output, id, nickname, playerId, sampGetColorByPlayerId(playerId), rang_number, rang_name, number) 
				end
			end
			
			return {dialogId, style, title, button1, button2, output}
		end

		if string.find(title, "{FFCD00}Информация о сотруднике") then
			local hours_today, minutes_today = string.match(text, "Время в игре сегодня: {aa80ff}(%d+) ч (%d+) мин")
			local afk_hours_today, afk_minutes_today = string.match(text, "AFK сегодня: {FF7000}(%d+) ч (%d+) мин")
			local hours_yesterday, minutes_yesterday = string.match(text, "Время в игре вчера: {aa80ff}(%d+) ч (%d+) мин")
			local afk_hours_yesterday, afk_minutes_yesterday = string.match(text, "AFK вчера: {FF7000}(%d+) ч (%d+) мин")
			
			local clean_online_today = (hours_today * 60 + minutes_today) - (afk_hours_today * 60 + afk_minutes_today)
			local clean_online_yesterday = (hours_yesterday * 60 + minutes_yesterday) - (afk_hours_yesterday * 60 + afk_minutes_yesterday)
			
			local text = string.format("%s\n{ffffff}Чистый онлайн: {6495ED}%d ч %d мин\n{ffffff}Чистый онлайн вчера: {6495ED}%d ч %d мин", 
			text, math.floor(clean_online_today / 60), math.fmod(clean_online_today, 60), math.floor(clean_online_yesterday / 60), math.fmod(clean_online_yesterday, 60))
			return {dialogId, style, title, button1, button2, text}
		end
	end -- find
	
	if configuration_main["improved_dialogues"][3]["status"] then
		if string.find(title, "Список разыскиваемых") then
			local list_for_sort, max_index, line_index = {}, 0, 0
		
			for line in string.gmatch(text, "[^\n]+") do
				line_index = line_index + 1
				if string.match(line, "(%S+)[%s].id[%s](%d+).	(%d+)	 (%d+)") then
					local nickname, playerId, stars, distance = string.match(line, "(%S+)[%s].id[%s](%d+).	(%d+)	 (%d+)")
					max_index = max_index + 1
					list_for_sort[max_index] = {index = line_index, distance = tonumber(distance), line = string.format("{%s}%s{e6e6fa} (id %d)\t%d\t{00cc99}%s м", sampGetColorByPlayerId(playerId), nickname, playerId, stars, distance)}
				elseif string.match(line, "(%S+)[%s].id[%s](%d+).	(%d+)	Недоступно") then
					local nickname, playerId, stars = string.match(line, "(%S+)[%s].id[%s](%d+).	(%d+)	Недоступно")
					max_index = max_index + 1
					list_for_sort[max_index] = {index = line_index, distance = 7777, line = string.format("{%s}%s{e6e6fa} (id %d)\t%d\t{ff5c33}Недоступно", sampGetColorByPlayerId(playerId), nickname, playerId, stars)}
				end
			end
			
			-- table.sort(list_for_sort, function(a, b) return a["distance"] < b["distance"] end)
			local output = "{e6e6fa}Имя\t{e6e6fa}Уровень розыска\t{e6e6fa}Дистанция"
			for k, v in pairs(list_for_sort) do output = string.format("%s\n%s", output, v["line"]) end
		
			return {dialogId, style, title, button1, button2, output}
		end
	end -- wanted
	
	if configuration_main["improved_dialogues"][4]["status"] then
		if dialogId == 176 and string.find(title, "Точное время") then
			local hours_today, minutes_today = string.match(text, "Время в игре сегодня:\t+{ffcc00}(%d+) ч (%d+) мин")
			local afk_hours_today, afk_minutes_today = string.match(text, "AFK за сегодня:\t+{FF7000}(%d+) ч (%d+) мин")
			local hours_yesterday, minutes_yesterday = string.match(text, "Время в игре вчера:\t+{ffcc00}(%d+) ч (%d+) мин")
			local afk_hours_yesterday, afk_minutes_yesterday = string.match(text, "AFK за вчера:\t+{FF7000}(%d+) ч (%d+) мин")
			
			local clean_online_today = (hours_today * 60 + minutes_today) - (afk_hours_today * 60 + afk_minutes_today)
			local clean_online_yesterday = (hours_yesterday * 60 + minutes_yesterday) - (afk_hours_yesterday * 60 + afk_minutes_yesterday)
			
			local text = string.format("%s\n{ffffff}Чистый онлайн:\t\t{6495ED}%d ч %d мин\n{ffffff}Чистый онлайн вчера:\t{6495ED}%d ч %d мин", 
			text, math.floor(clean_online_today / 60), math.fmod(clean_online_today, 60), math.floor(clean_online_yesterday / 60), math.fmod(clean_online_yesterday, 60))
			return {dialogId, style, title, button1, button2, text}
		end
	end -- c 60
	
	if configuration_main["improved_dialogues"][5]["status"] then
		if dialogId == 0 and string.match(title, "Заправочные станции") then
			local fuel_station = {}
			for line in string.gmatch(text, "[^\n]+") do
				if string.match(line, "(%d+)\t+(%d+)%$\t+(%d+) л\t+(.+)") then
					local id, cost, fuel, gas_station = string.match(line, "(%d+)\t+(%d+)%$\t+(%d+) л\t+(.+)")
					fuel_station[#fuel_station + 1] = {id = id, cost = tonumber(cost), fuel = tonumber(fuel), gas_station = gas_station}
				end
			end
			
			table.sort(fuel_station, function(a, b) return (a["cost"] < b["cost"]) end)
			
			t_gas_station = fuel_station
			show_gas_station[0] = not show_gas_station[0]
			
			--[[local output = "Название\tСтоимость за 1 литр\tКоличество топлива\tДистанция"
			local x, y, z = getCharCoordinates(playerPed)
			for index, value in pairs(fuel_station) do
				local distance = math.floor(getDistanceBetweenCoords3d(x, y, z, t_fuel_station[tonumber(value["id"])]["x"], t_fuel_station[tonumber(value["id"])]["y"], t_fuel_station[tonumber(value["id"])]["z"]))
				output = string.format("%s\n%s\t{FFCD00}%s$\t{00CC66}%s л\t%s м", output, value["gas_station"], value["cost"], value["fuel"], distance)
			end
			return {dialogId, 5, title, button1, button2, output}--]]
			return false
		end
	end
	
	if string.find(title, "Паспорт") then
		local match = "{%S+}Имя:\t+{%S+}(%S+)\n{%S+}Проживание в стране %(лет%):\t+{%S+}(%S+)\n{%S+}Пол:\t+(%S+)\nСемейное положение:\t+(.+)\nПроживание:\t+{%S+}(.+)\n{%S+}Работа: \t+(.+)\nОрганизация:\t+(.+)\nПодразделение:\t+(.+)\nТелефон:\t+{%S+}(%S+)\n{%S+}Уровень розыска:\t+{%S+}(%S+)\n{%S+}Законопослушность:\t+{%S+}(%S+)"
		
		if string.match(text, match) then
			local nickname, residence_in_country, male, marital_status, accommodation, job, organization, department, telephone, wanted, law_abidingness = string.match(text, match)
			
			if not configuration_database["player"][nickname] then configuration_database["player"][nickname] = {} end
			
			configuration_database["player"][nickname]["residence_in_country"] = tonumber(residence_in_country)
			configuration_database["player"][nickname]["male"] = u8(male)
			configuration_database["player"][nickname]["marital_status"] = u8(marital_status)
			configuration_database["player"][nickname]["accommodation"] = u8(accommodation)
			configuration_database["player"][nickname]["job"] = u8(job)
			configuration_database["player"][nickname]["organization"] = u8(organization)
			configuration_database["player"][nickname]["department"] = u8(department)
			configuration_database["player"][nickname]["telephone"] = u8(telephone)
			configuration_database["player"][nickname]["wanted"] = tonumber(wanted)
			configuration_database["player"][nickname]["law_abidingness"] = tonumber(law_abidingness)
			configuration_database["player"][nickname]["time"] = os.time()
			
			if not need_update_configuration then need_update_configuration = os.clock() end
			
			if passport_check then
				if configuration_main["settings"]["passport_check"] then
					lua_thread.create(function()
						if not configuration_main["information"]["sex"] then
							sampSendChat("/me внимательно изучил паспортные данные и передал информацию диспетчеру.")
						else
							sampSendChat("/me внимательно изучила паспортные данные и передала информацию диспетчеру.")
						end

						if tonumber(wanted) > 0 then
							wait(1500); sampSendChat("/todo Получив информацию от диспетчера*Вы находитесь в федеральном розыске.")
							wait(1000); sampSendChat("Вам необходимо проехать со мной в ближайщий полицейский департамент.")
						else
							wait(1500); sampSendChat("/todo Получив информацию от диспетчера и вернув паспорт*С документами всё хорошо.")
						end
					end)
				end
				sampSendDialogResponse(dialogId, 1, 0, 0) 
				passport_check = false
				return false
			end
		end
	end 
	
	if string.match(title, "Авторизация") then
		entered_password = dialogId
		if not string.match(text, "Неверный пароль") and not string.match(text, "PIN") then
			local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
			if result then
				local nickname = sampGetPlayerName(playerId)
				local ip, port = sampGetCurrentServerAddress()
				local ip_adress = string.format("%s:%s", ip, port)
				if configuration_manager[ip_adress] and configuration_manager[ip_adress][nickname] then
					local password = configuration_manager[ip_adress][nickname]["password"]
					sampSendDialogResponse(dialogId, 1, 1, password)
					return false
				end
			end
		end
	end
	
	if string.match(title, "Код с приложения") and dialogId == 88 then
		local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
		if result then
			local nickname = sampGetPlayerName(playerId)
			local ip, port = sampGetCurrentServerAddress()
			local ip_adress = string.format("%s:%s", ip, port)
			if configuration_manager[ip_adress] and configuration_manager[ip_adress][nickname] then
				local seckey = configuration_manager[ip_adress][nickname]["gauth"]
				if seckey then
					local g = gauth.gencode(seckey, math.floor(os.time() / 30))
					sampSendDialogResponse(dialogId, 1, 1, g)
					return false
				end
			end
		end
	end
end
 
function sampev.onSendChat(text) 
	configuration_statistics["message"] = configuration_statistics["message"] + 1
	if not need_update_configuration then need_update_configuration = os.clock() end

	if string.len(text) > 90 then
		local l1, l2 = line_break_by_space(text, 87) 
		sampSendChat(string.format("%s ..", l1))
		sampSendChat(string.format(".. %s", l2))
		return false  
	end 
end
 
function sampev.onSendCommand(parametrs)  
	local command, value
	if string.match(parametrs, "/(%S+)[%s](.+)") then command, value = string.match(parametrs, "/(%S+)[%s](.+)") else command = string.match(parametrs, "/(%S+)") end

	if not configuration_statistics["commands"][command] then 
		configuration_statistics["commands"][command] = 1
		if not need_update_configuration then need_update_configuration = os.clock() end
	else
		configuration_statistics["commands"][command] = configuration_statistics["commands"][command] + 1
		if not need_update_configuration then need_update_configuration = os.clock() end
	end

	if maximum_number_of_characters[command] then
		if maximum_number_of_characters[command] < string.len(value) then
			if not last_on_send_value then 
				last_on_send_value = value 
			else
				if last_on_send_value == value then 
					return false 
				else
					last_on_send_value = value
				end
			end
		
			if command == "me" then
				local l1, l2 = line_break_by_space(value, maximum_number_of_characters[command] - 3) 
				sampSendChat(string.format("/me %s ..", l1))
				sampSendChat(string.format("/do .. %s", l2)) 
			elseif command == "r" or command == "f" then
				if string.match(value, "%(%(%s(.+)%s%)%)") then
					local value = string.match(value, "%(%(%s(.+)%s%)%)")
					local l1, l2 = line_break_by_space(value, maximum_number_of_characters[command] - 10)
					sampSendChat(string.format("/%s (( %s .. ))", command, l1))
					sampSendChat(string.format("/%s (( .. %s ))", command, l2)) 
				else 
					local l1, l2 = line_break_by_space(value, maximum_number_of_characters[command] - 3) 
					sampSendChat(string.format("/%s %s ..", command, l1))
					sampSendChat(string.format("/%s .. %s", command, l2))
				end
			else 
				local l1, l2 = line_break_by_space(value, maximum_number_of_characters[command] - 3) 
				sampSendChat(string.format("/%s %s ..", command, l1))
				sampSendChat(string.format("/%s .. %s", command, l2))
			end return false 
		end
	end
	
	if command == "su" then
		local id, stars, reason = string.match(parametrs, "(%d+) (%d+) (.+)")
		last_suspect_parametrs = {id, stars, reason}
	end
end

function sampev.onSendDeathNotification(reason, playerId)
	if reason then
		delay_between_deaths = {calculateZone(), os.clock()}
		if playerId then
			print(("Вы были убиты игроком {%s}%s{e6e6fa}[%s] в %s:%s."):format(sampGetColorByPlayerId(playerId), sampGetPlayerName(playerId), playerId, os.date("%H"), os.date("%M")))
		else print("Вы были убиты сервером или игроком, который покинул игру.") end
	end 
end

function sampev.onSetPlayerColor(playerId, color)
	if configuration_main["settings"]["mask_timer"] then
		local result, id = sampGetPlayerIdByCharHandle(playerPed)
		if playerId == id then
			if color == 572662272 then
				configuration_statistics["number_masks_used"] = configuration_statistics["number_masks_used"] + 1
				if not need_update_configuration then need_update_configuration = os.clock() end
				mask_timer = os.clock()
			else
				if mask_timer then
					configuration_statistics["time_using_mask"] = configuration_statistics["time_using_mask"] + (os.clock() - mask_timer)
					if not need_update_configuration then need_update_configuration = os.clock() end
					mask_timer = nil 
				end
			end
		end
	end
end 

function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
	if isPlayerConnected(playerId) then 
		local nickname = sampGetPlayerName(playerId)
		if sampGetDistanceToPlayer(playerId) <= 35 and sampGetPlayerColor(playerId) ~= 2236962 then
			if quick_suspect["playerId"] ~= playerId or (quick_suspect["playerId"] == playerId and (os.clock() - quick_suspect["clock"]) / 60 > 2) then
				chat(string.format("Чтобы объявить {%s}%s{}[%s] в розыск по статье {COLOR}%s{} нажмите сочетание клавиш ПКМ + 5.", sampGetColorByPlayerId(playerId), nickname, playerId, u8:decode(configuration_main["quick_criminal_code"]["attack"]["reason"])))
				quick_suspect = {playerId = playerId, clock = os.clock(), stars = configuration_main["quick_criminal_code"]["attack"]["stars"], reason = u8:decode(configuration_main["quick_criminal_code"]["attack"]["reason"])}
				
				chat(string.format("Чтобы отправить репорт на {%s}%s{}[%s] используйте сочетание клавиш ПКМ + 4.", sampGetColorByPlayerId(playerId), nickname, playerId))
				quick_report = {playerId = playerId, clock = os.clock(), reason = "dm"}
			end
		end
	end
end

function sampev.onSendDialogResponse(dialogId, button, listItem, input)
	if entered_password then
		if dialogId == entered_password then
			local result, playerId = sampGetPlayerIdByCharHandle(playerPed)
			if result then
				local nickname = sampGetPlayerName(playerId)
				local ip, port = sampGetCurrentServerAddress()
				local ip_adress = string.format("%s:%s", ip, port)
			
				if not (configuration_manager[ip_adress] and configuration_manager[ip_adress][nickname]) then
					entered_to_save_password = {ip_adress = ip_adress, nickname = nickname, password = input}
					chat("Для того, чтобы сохранить данный аккаунт в менеджере аккаунтов введите команду {COLOR}/savepass{}.")
				else
					if string.match(sampGetDialogText(), "Неверный пароль") then
						entered_to_save_password = {ip_adress = ip_adress, nickname = nickname, password = input}
						chat("Для того, чтобы сохранить данный аккаунт в менеджере аккаунтов введите команду {COLOR}/savepass{}.")
					end
				end
			end
			entered_password = nil
		end
	end
end

function sampev.onPlayerJoin(playerId, color, isNpc, nickname)
	if not add_player_to_base then add_player_to_base = {} end
	add_player_to_base[#add_player_to_base + 1] = {nickname, playerId, os.clock()}
end

function onScriptTerminate(script, bool)
	if thisScript() == script then
		if configuration_main1 then
			local result, index = configuration_main1:set(configuration_main)
			local result, index = configuration_custom1:set(configuration_custom)
			local result, index = configuration_manager1:set(configuration_manager)
			local result, index = configuration_statistics1:set(configuration_statistics)
			local result, index = configuration_database1:set(configuration_database)
			configuration_main1:close() 
			configuration_custom1:close()
			configuration_manager1:close()
			configuration_statistics1:close()
			configuration_database1:close()
			
			for index, value in pairs(map_marker) do if value["marker"] then removeBlip(value["marker"]) end end
		end
	end
end
-- !event

-- https
function attempToGetFileAndDir()
	local start_time = os.clock()
	local url = "https://raw.githubusercontent.com/skezz-perry/files/master/epk"
	local response = https.request(url)
	if response and not string.match(response, "500: Internal Server Error") then
		local uk = u8:decode(string.match(response, "uk = {(.+)}"))
		local ak = u8:decode(string.match(response, "ak = {(.+)}"))
		
		for line in string.gmatch(uk, "[^\n]+") do
			if string.match(line, "(.+) | (%d+).(%d+) УК | (.+)") then
				local stars, article, part, text = string.match(line, "(.+) | (%d+).(%d+) УК | (.+)")
				if not criminal_code[tonumber(article)] then criminal_code[tonumber(article)] = {name = "", content = {}} end
				criminal_code[tonumber(article)]["content"][tonumber(part)] = {text = text, stars = tonumber(stars)} 
			elseif string.match(line, "СТАТЬЯ[%s](%d+)[%s]|[%s](.+)") then
				local article, name = string.match(line, "СТАТЬЯ[%s](.+)[%s]|[%s](.+)")
				if not criminal_code[tonumber(article)] then criminal_code[tonumber(article)] = {name = name, content = {}} end
			end
		end
		
		for line in string.gmatch(ak, "[^\n]+") do
			if string.match(line, "(.+) | (%d+).(%d+) КоАП | (.+)") then
				local sanction, article, part, text = string.match(line, "(.+) | (%d+).(%d+) КоАП | (.+)")
				if not administrative_code[tonumber(article)] then administrative_code[tonumber(article)] = {name = "", content = {}} end
				administrative_code[tonumber(article)]["content"][tonumber(part)] = {text = text, sanction = tonumber(sanction)} 
			elseif string.match(line, "СТАТЬЯ[%s](%d+)[%s]|[%s](.+)") then
				local article, name = string.match(line, "СТАТЬЯ[%s](.+)[%s]|[%s](.+)")
				if not administrative_code[tonumber(article)] then administrative_code[tonumber(article)] = {name = name, content = {}} end
			end
		end
		
		print(string.format("Были подгружены списки УК и КоАП. Затрачено времени: %s.", os.clock() - start_time))
	else print("Произошла ошибка при попытке получить информацию о УК и КоАП.") end
end

function getUsers()
	local start_time = os.clock()
	local _result, id = sampGetPlayerIdByCharHandle(playerPed)
	local player_name = sampGetPlayerNickname(id)
	player_serial = tostring(getSerialNumber())
	local normal_serial = false

	local result = https.request("https://raw.githubusercontent.com/skezz-perry/project/master/users")
	if not string.match(result, "500: Internal Server Error") then
		local result = decodeJson(result)

		if result and type(result) == "table" then
			list_users = result
			for index, value in pairs(result) do
				for user_serial in string.gmatch(value["serialNumber"], "[^,%s]+") do
					if user_serial == player_serial then
						user_slots_value = tonumber(value["user_slots_value"])
						player_status = tonumber(value["rangNumber"])
						normal_serial = true
						
						local day = math.floor((value["subscription"] - os.time()) / 3600 / 24)
						if day > 0 then
							local date = os.date("%d.%m.%Y", value["subscription"])
							chat(("Вы авторизовались как %sпользователь{}, ваш профиль верифицирован до {COLOR}%s{} ({COLOR}%s{} дней)."):format(value["color"], date, day))
						else
							chat("Верификация вашего профиля истекла, обратитесь к разработчику для её продления.")
						end
					end 
				end
			end
			print(string.format("Список пользователей был подгружен за %s.", os.clock() - start_time))
		else chat("Произошла ошибка при попытке получить информацию о пользователях. Код ошибки: #2.") end
	else chat("Произошла ошибка при попытке получить информацию о пользователях. Код ошибки: #1.") end
end

function autoUpdate(versionUrl, updateUrl)
	local versionPath = string.format("%s\\%s-version.json", getWorkingDirectory(), thisScript().name)
	if doesFileExist(versionPath) then os.remove(versionPath) end

	local version = https.request(versionUrl) 
	if version and not string.match(version, "500: Internal Server Error") then
		local version_info = decodeJson(version)
		if version_info["latest"] == thisScript().version then
			chat("Игровой помощник был успешно запущен. Вы используйте актуальную версию скрипта.")
			getUsers()
			attempToGetFileAndDir()
		else
			local file = https.request(updateUrl)
			if file then
				chat("Игровой помощник был автоматически обновлён до новейшей версии. Подробнее на главной странице.")
				local file_text = u8:decode(file)
				local file = io.open(thisScript().path, "w")
				file:write(file_text)
				file:close() 
			else chat("Произошла ошибка при попытке обновления игрового помощника. Код ошибки: #2.") end
		end
	else chat("Произошла ошибка при попытке обновления игрового помощника. Код ошибки: #1.") end
end
-- !https
