-- Global tables that hold the item, talent as well as glyph names in the language of the client
BLT_ItemNames = {}
BLT_TalentNames = {}
BLT_GlyphNames = {}

if GetLocale() == "deDE" then
    BLT_ItemNames = {
        [54589] = "Leuchtende Zwielichtschuppe",
        [50364] = "Sindragosas makelloser Fangzahn",
    }
    BLT_TalentNames = {
        [51052] = "Antimagisches Feld",
        [55233] = "Vampirblut",
        [49016] = "Bösartigkeit",
        [61336] = "Überlebensinstinkte",
        [26983] = "Verbesserte Gelassenheit",
        [45438] = "Eisschollen",
        [66233] = "Unermüdlicher Verteidiger",
        [31821] = "Aurenbeherrschung",
        [498]   = "Heilige Pflicht",
        [64205] = "Heilige Opferung",
        [10278] = "Gunst des Hüters",
        [48788] = "Verbesserte Handauflegung",
        [47585] = "Dispersion",
        [47788] = "Schutzgeist",
        [33206] = "Aspiration",
        [10060] = "Aspiration",
        [57934] = "Schmutzige Tricks",
        [16190] = "Totem der Manaflut",
        [20608] = "Verbesserte Reinkarnation",
        [12975] = "Letztes Gefecht",
        [871]   = "Verbesserte Disziplinen"
    }
    BLT_GlyphNames = {
        [48788] = "Glyphe 'Handauflegung'",
        [6346]  = "Glyphe 'Letztes Gefecht'",
        [47585] = "Glyphe 'Dispersion'",
        [47788] = "Glyphe 'Schutzgeist'",
        [57934] = "Glyphe 'Schurkenhandel'",
        [12975] = "Glyphe 'Letztes Gefecht'",
        [871]   = "Glyphe 'Schildwall'"
    }
elseif GetLocale() == "esES" or GetLocale() == "esMX" then
    BLT_ItemNames = {
        [54589] = "Escama Crepuscular resplandeciente",
        [50364] = "Colmillo impecable de Sindragosa"
    }
    BLT_TalentNames = {
        [51052] = "Zona antimagia",
        [55233] = "Sangre vampírica",
        [49016] = "Histeria",
        [61336] = "Instintos de supervivencia",
        [26983] = "Tranquilidad mejorada",
        [45438] = "Témpanos de hielo",
        [66233] = "Defensor candente",
        [31821] = "Maestría en auras",
        [498]   = "Deber sagrado",
        [64205] = "Sacrificio divino",
        [10278] = "Favor del Guardián",
        [48788] = "Imposición de manos mejorada",
        [47585] = "Dispersión",
        [47788] = "Espíritu guardián",
        [33206] = "Aspiración",
        [10060] = "Aspiración",
        [57934] = "Artimañas",
        [16190] = "Tótem Marea de maná",
        [20608] = "Reencarnación mejorada",
        [12975] = "Última carga",
        [871]   = "Disciplinas mejoradas"
    }
    BLT_GlyphNames = {
        [48788] = "Glifo de Imposición de manos",
        [6346]  = "Glifo de Resguardo de miedo",
        [47585] = "Glifo de Dispersión",
        [47788] = "Glifo de Espíritu guardián",
        [57934] = "Glifo de Secretos del oficio",
        [12975] = "Glifo de Última carga",
        [871]   = "Glifo de Muro de escudo"
    }
elseif GetLocale() == "frFR" then
    BLT_ItemNames = {
        [54589] = "Ecaille du Crépuscule luminescente",
        [50364] = "Croc parfait de Sindragosa"
    }
    BLT_TalentNames = {
        [51052] = "Zone anti-magie",
        [55233] = "Sangre vampírica",
        [49016] = "Hystérie",
        [61336] = "Instincts de survie",
        [26983] = "Tranquillité améliorée	",
        [45438] = "Iceberg",
        [66233] = "Ardent défenseur",
        [31821] = "Maîtrise des auras",
        [498]   = "Devoir sacré",
        [64205] = "Sacrifice divin",
        [10278] = "Faveur du Gardien",
        [48788] = "Imposition des mains améliorée",
        [47585] = "Dispersion",
        [47788] = "Esprit gardien",
        [33206] = "Aspiration",
        [10060] = "Aspiration",
        [57934] = "Tours pendables",
        [16190] = "Totem de vague de mana",
        [20608] = "Réincarnation améliorée",
        [12975] = "Dernier rempart",
        [871]   = "Disciplines améliorées"
    }
    BLT_GlyphNames = {
        [48788] = "Glyphe d'imposition des mains",
        [6346]  = "Glyphe de gardien de peur",
        [47585] = "Glyphe de dispersion",
        [47788] = "Glyphe d'esprit gardien",
        [57934] = "Glyphe de ficelles du métier",
        [12975] = "Glyphe de dernier rempart",
        [871]   = "Glyphe de mur protecteur"
    }
elseif GetLocale() == "ruRU" then
    BLT_ItemNames = {
        [54589] = "Светящаяся сумеречная чешуя",
        [50364] = "Безупречный клык Синдрагосы"
    }
    BLT_TalentNames = {
        [51052] = "Зона антимагии",
        [55233] = "Кровь вампира",
        [49016] = "Истерия",
        [61336] = "Инстинкты выживания",
        [26983] = "Улучшенное спокойствие",
        [45438] = "Айсберг",
        [66233] = "Ревностный защитник",
        [31821] = "Мастер аур",
        [498]   = "Священный долг",
        [64205] = "Священная жертва",
        [10278] = "Помощь стража",
        [48788] = "Улучшенное возложение рук",
        [47585] = "Слияние с Тьмой",
        [47788] = "Оберегающий дух",
        [33206] = "Стремление",
        [10060] = "Стремление",
        [57934] = "Грязные трюки",
        [16190] = "Тотем прилива маны",
        [20608] = "Улучшенное перерождение",
        [12975] = "Ни шагу назад",
        [871]   = "Отработанные навыки"
    }
    BLT_GlyphNames = {
        [48788] = "Символ возложения рук",
        [6346]  = "Символ защиты от страха",
        [47585] = "Символ слияния с Тьмой",
        [47788] = "Символ оберегающего духа",
        [57934] = "Символ маленьких хитростей",
        [12975] = "Символ отчаянной защиты",
        [871]   = "Символ глухой обороны"
    }
elseif GetLocale() == "zhCN" or GetLocale() == "zhTW" then
    BLT_ItemNames = {
        [54589] = "明亮暮光龙鳞",
        [50364] = "完美之牙"
    }
    BLT_TalentNames = {
        [51052] = "反魔法领域",
        [55233] = "吸血鬼之血",
        [49016] = "狂乱",
        [61336] = "生存本能",
        [26983] = "强化宁静",
        [45438] = "浮冰",
        [66233] = "炽热防御者",
        [31821] = "光环掌握",
        [498]   = "神圣使命",
        [64205] = "神圣牺牲",
        [10278] = "守护者的宠爱",
        [48788] = "强化圣疗术",
        [47585] = "消散",
        [47788] = "守护之魂",
        [33206] = "渴望",
        [10060] = "渴望",
        [57934] = "恶毒诡计",
        [16190] = "法力之潮图腾",
        [20608] = "强化复生",
        [12975] = "破釜沉舟",
        [871]   = "强化戒律"
    }
    BLT_GlyphNames = {
        [48788] = "圣疗雕文",
        [6346]  = "防护恐惧结界雕文",
        [47585] = "消散雕文",
        [47788] = "守护之魂雕文",
        [57934] = "嫁祸诀窍雕文",
        [12975] = "被烧毁的雕文",
        [871]   = "盾墙雕文"
    }
else
    BLT_ItemNames = {
        [54589] = "Glowing Twilight Scale",
        [50364] = "Sindragosa's Flawless Fang",
    }
    BLT_TalentNames = {
        [51052] = "Anti-Magic Zone",
        [55233] = "Vampiric Blood",
        [49016] = "Hysteria",
        [61336] = "Survival Instincts",
        [26983] = "Improved Tranquility",
        [45438] = "Ice Floes",
        [66233] = "Ardent Defender",
        [31821] = "Aura Mastery",
        [498]   = "Sacred Duty",
        [64205] = "Divine Sacrifice",
        [10278] = "Guardian's Favor",
        [48788] = "Improved Lay on Hands",
        [47585] = "Dispersion",
        [47788] = "Guardian Spirit",
        [33206] = "Aspiration",
        [10060] = "Aspiration",
        [57934] = "Filthy Tricks",
        [16190] = "Mana Tide Totem",
        [20608] = "Improved Reincarnation",
        [12975] = "Last Stand",
        [871]   = "Improved Disciplines"
    }
    BLT_GlyphNames = {
        [48788] = "Glyph of Lay on Hands",
        [6346]  = "Glyph of Fear Ward",
        [47585] = "Glyph of Dispersion",
        [47788] = "Glyph of Guardian Spirit",
        [57934] = "Glyph of Tricks of the Trade",
        [12975] = "Glyph of Last Stand",
        [871]   = "Glyph of Shield Wall"
    }
end
