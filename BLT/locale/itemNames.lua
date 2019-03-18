-- Global table that holds the item names in the language of our client
BLT_ItemNames = {}

if GetLocale() == "deDE" then
    BLT_ItemNames = {
        [54589] = "Leuchtende Zwielichtschuppe",
        [50364] = "Sindragosas makelloser Fangzahn"
    }
elseif GetLocale() == "esES" or GetLocale() == "esMX" then
    BLT_ItemNames = {
        [54589] = "Escama Crepuscular resplandeciente",
        [50364] = "Colmillo impecable de Sindragosa"
    }
elseif GetLocale() == "frFR" then
    BLT_ItemNames = {
        [54589] = "Ecaille du Crépuscule luminescente",
        [50364] = "Croc parfait de Sindragosa"
    }
elseif GetLocale() == "itIT" then
    BLT_ItemNames = {
        [54589] = "Scaglia del Crepuscolo Brillante",
        [50364] = "Zanna Perfetta di Sindragosa"
    }
elseif GetLocale() == "ptBR" then
    BLT_ItemNames = {
        [54589] = "Escama Crepuscular Faiscante",
        [50364] = "Presa Impecável de Sindragosa"
    }
elseif GetLocale() == "ruRU" then
    BLT_ItemNames = {
        [54589] = "Светящаяся сумеречная чешуя",
        [50364] = "Безупречный клык Синдрагосы"
    }
elseif GetLocale() == "koKR" then
    BLT_ItemNames = {
        [54589] = "빛나는 황혼의 비늘",
        [50364] = "신드라고사의 완전무결한 송곳니"
    }
elseif GetLocale() == "zhCN" or GetLocale() == "zhTW" then
    BLT_ItemNames = {
        [54589] = "明亮暮光龙鳞",
        [50364] = "完美之牙"
    }
else
    BLT_ItemNames = {
        [54589] = "Glowing Twilight Scale",
        [50364] = "Sindragosa's Flawless Fang"
    }
end
