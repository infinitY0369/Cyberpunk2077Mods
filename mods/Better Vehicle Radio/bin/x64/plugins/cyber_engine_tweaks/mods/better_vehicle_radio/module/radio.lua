local radio             = {}

radio.data              = {
    radio_station_09_downtempo = { -- 88.9 パシフィック・ドリームス
        index                                      = 4,
        channel_name                               = "Gameplay-Devices-Radio-RadioStationDownTempo",

        mus_radio_09_downtempo_isometric_air       = 0x0000CE40, -- Quantum Lovers - Isometric Air
        mus_radio_09_downtempo_real_window         = 0x0000CE41, -- Quantum Lovers - Real Window
        mus_radio_09_downtempo_practical_heart     = 0x0000CE42, -- Quantum Lovers - Practical Heart
        mus_radio_09_downtempo_antagonistic        = 0x0000CE43, -- Pacific Avenue - Antagonistic
        mus_radio_09_downtempo_simple_pleasures    = 0x0000CE44, -- Jänsens - Simplepleasures
        mus_radio_09_downtempo_chodze              = 0x0000CE45, -- Muchomorr - Chodze
        mus_radio_09_downtempo_cyberpunk05         = 0x0000CE46, -- Lick Switch - Midnight Eye
        mus_radio_09_downtempo_cyberpunk06         = 0x0000CE47, -- Lick Switch - Blurred
        mus_radio_09_downtempo_cyberpunk08         = 0x0000CE48, -- Lick Switch - The Other Room
        mus_radio_09_downtempo_le_stessa_causa     = 0x0000CE49, -- Sonoris Causa - La Stessa Causa
        mus_radio_09_downtempo_dub_dub_mix_ambient = 0x0000CE4A, -- left unsaid - retrogenesis
        mus_radio_09_downtempo_miami_suicide       = 0x0000CE4B, -- Talk To Us - Miami Suicide
        mus_radio_09_downtempo_slippery_stabs      = 0x0000CE4C, -- Talk To Us - Slippery Stabs
        mus_radio_09_downtempo_ashes_and_diamonds  = 0x0000CE4D, -- WORMVIEW - Ashes and Diamonds
        mus_radio_09_downtempo_cdprojekt2_uferlos  = 0x0000CE4E, -- Mona Mitchell - Ice Maddox
        mus_radio_09_downtempo_demo4               = 0x0000CE4F, -- Flatlander Woman - Lithium
        mus_radio_09_downtempo_demo7               = 0x0000CE50  -- Flatlander Woman - Slag
    },
    radio_station_02_aggro_ind = {                               -- 89.3 ラジオ・ヴェクセルストロム
        index                                             = 0,
        channel_name                                      = "Gameplay-Devices-Radio-RadioStationAggroIndie",

        mus_radio_02_aggro_ind_resist_and_disorder        = 0x0000CE5D, -- The Cartesian Duelists - Resist and Disorder
        mus_radio_02_aggro_ind_kill_the_messenger         = 0x0000CE5E, -- The Cartesian Duelists - Kill the Messenger
        mus_radio_02_aggro_ind_makes_me_feel_better       = 0x0000CE5F, -- Slavoj McAllister - Makes Me Feel Better
        mus_radio_02_aggro_ind_dead_pilot                 = 0x0000CE60, -- Keine - Dead Pilot
        mus_radio_02_aggro_ind_comeclose                  = 0x0000CE61, -- Keine - Come Close
        mus_radio_02_aggro_ind_black_terminal_vox_upgrade = 0x0000CE62, -- Upgrade - Black Terminal
        mus_radio_02_aggro_ind_reaktion                   = 0x0000CE63, -- Alexei Brayko - Reaktion
        mus_radio_02_aggro_ind_with_her                   = 0x0000CE64, -- Ego Affliction - With Her
        mus_radio_02_aggro_ind_never_stop_me              = 0x0000CE65, -- Den of Degenerates - Never Stop Me
        mus_radio_02_aggro_ind_violence                   = 0x0000CE66, -- The Red Glare - Violence
        mus_radio_02_aggro_ind_pain                       = 0x0000CE67, -- The Red Glare - Pain
        mus_radio_02_aggro_ind_night_city_aliens          = 0x0000CE68, -- Homeschool Dropouts - Night City Aliens
        mus_radio_02_aggroind_cyber_caca                  = 0x0000CE69, -- Tainted Overlord - Selva Pulsátil,
        mus_radio_02_aggro_ind_cyber_tabla                = 0x0000CE6A, -- Tainted Overlord - A Caça
        mus_radio_02_aggro_ind_pig_dinner                 = 0x0001314F  -- N1v3Z - Pig Dinner
    },
    radio_station_08_jazz = {                                           -- 91.9 ロイヤルブルー・ラジオ
        index                                         = 10,
        channel_name                                  = "Gameplay-Devices-Radio-RadioStationJazz",

        mus_radio_08_jazz_black_satin_what_if_agharta = 0x0000D077, -- Miles Davis - Black Satin / What If / Agharta Prelude Dub
        mus_radio_08_jazz_bitches_brew                = 0x0000D078, -- Miles Davis - Bitches Brew
        mus_radio_08_jazz_generique                   = 0x0000D079, -- Miles Davis - Ascenseur pour l'échafaud - Générique
        mus_radio_08_jazz_impressions                 = 0x0000D07B, -- John Coltrane - Impressions
        mus_radio_08_jazz_solo_dancer                 = 0x0000D07C, -- Charles Mingus - The Black Saint and the Sinner Lady - Solo Dancer
        mus_radio_08_jazz_laura                       = 0x0000D07D, -- Dexter Gordon - Sophisticated Giant - Laura
        mus_radio_08_jazz_you_dont_know_what_love_is  = 0x0000D07E, -- You Don't Know What Love Is
        mus_radio_08_jazz_round_midnight              = 0x0000D07F, -- Thelonius Monk - 'Round Midnight
        mus_radio_08_jazz_dark_prince                 = 0x0000D080  -- John McLaughlin - Dark Prince
    },
    radio_station_03_elec_ind = {                                   -- 92.9 ナイトFM
        index                                = 1,
        channel_name                         = "Gameplay-Devices-Radio-RadioStationElectroIndie",

        mus_radio_03_elec_ind_dirty_roses    = 0x0000CE6F, -- Perilous Futur - Dirty Roses
        mus_radio_03_elec_ind_worlds         = 0x0000CE70, -- The Unresolved - Worlds
        mus_radio_03_elec_ind_x              = 0x0000CE71, -- The Unresolved - X
        mus_radio_03_elec_ind_maniak         = 0x0000CE72, -- Doctor Berserk - Maniak
        mus_radio_03_electind_be_machine     = 0x0000CE73, -- Generating Dependencies - Be Machine
        mus_radio_03_electind_cyberpunk07    = 0x0000CE74, -- Lick Switch - Like a Miracle
        mus_radio_03_elec_ind_run            = 0x0000CE75, -- Kings of Collapse - RUN
        mus_radio_03_elec_ind_ppgame05       = 0x0000CE76, -- Reviscerator - Glitched Revelation
        mus_radio_03_elec_ind_ppgame18       = 0x0000CE77, -- Reviscerator - Yellow Box
        mus_radio_03_elec_ind_killkill       = 0x0000CE78, -- The Bait - KILLKILL
        mus_radio_03_elec_ind_flying_heads   = 0x0000CE79, -- Ashes Potts - FLYINGHEAD
        mus_radio_03_electind_cyberpunk03_   = 0x0000CE7A, -- Yards of the Moon - Volcano the Sailor
        mus_radio_03_elect_ind_brain_damaged = 0x0000CE7B  -- Cyber Coorayber - Brain-Damaged
    },
    radio_station_06_minim_techno = {                      -- 95.2 サミズダート・ラジオ
        index                                      = 9,
        channel_name                               = "Gameplay-Devices-Radio-RadioStationMinimalTechno",

        mus_radio_06_minim_tech_pilling_in_my_head = 0x0000CEA0, -- Bara Nova - Pilling In My Head
        mus_radio_06_minim_tech_delirium2          = 0x0000CEA1, -- Bara Nova - Delirium 2
        mus_radio_06_minim_tech_harm_sweaty_pit    = 0x0000CEA2, -- Bara Nova - Harm Sweaty Pit
        mus_radio_06_minim_tech_my_lullaby_for_you = 0x0000CEA3, -- Bara Nova - My Lullaby For You
        mus_radio_06_minim_tech_surprise_me        = 0x0000CEA4  -- Bara Nova - Surprise Me, I'm Surprised Today
    },
    radio_station_11_metal = {                                   -- 96.1 リチュアルFM
        index                                = 8,
        channel_name                         = "Gameplay-Devices-Radio-RadioStationMetal",

        mus_radio_11_metal_finis             = 0x0000CEBD, -- V3RM1N - Finis
        mus_radio_11_metal_theaccursed       = 0x0000CEBE, -- Dread Soul - The Accursed
        mus_radio_11_metal_march30           = 0x0000CEBF, -- Bacillus - March 30
        mus_radio_11_metal_acid_breather     = 0x0000CEC0, -- Forlorn Scourge - Acid Breather
        mus_radio_11_metal_2                 = 0x0000CEC1, -- Nuclear Aura - Witches of the Harz Mountains
        mus_radio_11_metal_the_loop          = 0x0000CEC2, -- Weles - The Loop
        mus_radio_11_metal_scum              = 0x0000CEC3, -- Hysteria - Scum
        mus_radio_11_metal_fueled_by_poison  = 0x0000CEC4, -- Inferno Corps - Fueled By Poison
        mus_radio_11_metal_kevin             = 0x0000CEC5, -- Inferno Corps - Kevin
        mus_radio_11_metal_future_drags      = 0x0000CEC6, -- heXXXer - Future Drugs
        mus_radio_11_metal_zurawie           = 0x0000CEC7, -- Wydech - Żurawie
        mus_radio_11_metal_abandoned_land    = 0x0000CEC8, -- Fist of Satan - Abandoned Land
        mus_radio_11_metal_black_concrete    = 0x0000CEC9, -- Fist Of Satan - Black Concrete
        mus_radio_11_metal_i_wont_let_you_go = 0x0000CECA  -- Shattered Void - I Won't Let You Go
    },
    radio_station_05_pop = {                               -- 98.7 ボディヒート・ラジオ
        index                                         = 6,
        channel_name                                  = "Gameplay-Devices-Radio-RadioStationPop",

        mus_radio_05_pop_whos_ready                   = 0x0000CE54, -- IBDY - Who's Ready For Tomorrow
        mus_radio_05_pop_cirque_du_soleil             = 0x0000CE95, -- Neon Haze - Circus Minimus
        mus_radio_05_pop_major_crimes                 = 0x0000CE96, -- Window Weather - Major Crimes
        mus_radio_05_pop_night_city                   = 0x0000CE97, -- Artemis Delta - Night City
        mus_radio_05_pop_i_want_to_stay_at_your_house = 0x0000CE98, -- Hallie Coggins - I Want To Stay At Your House
        mus_radio_05_pop_hole_in_the_sun              = 0x0000CE99, -- Point Break Candy - Hole In The Sun
        mus_radio_05_pop_history                      = 0x0000CE9A, -- Trash Generation - History
        mus_radio_05_pop_ponpon_shit                  = 0x0000CE9B, -- Us Cracks - PonPon Shit
        mus_custom_radio_user_friendly                = 0x0000CE9C, -- Us Cracks feat. Kerry Eurodyne - User Friendly
        mus_custom_radio_off_the_leash                = 0x0000CE9D, -- Us Cracks - Off The Leash
        mus_radio_05_pop_crust_punk                   = 0x0000CE9E, -- IBDY - Crustpunk
        mus_radio_05_pop_heres_a_thought              = 0x0000CE9F, -- IBDY - Here's a Thought
        mus_radio_05_pop_4aem                         = 0x0000D075, -- Lizzy Wizzy - 4ÆM
        mus_radio_05_pop_delicate_weapon              = 0x0000D076, -- Lizzy Wizzy - Delicate Weapon
        mus_radio_05_pop_shygirl                      = 0x00013150  -- Clockwork Venus - BM
    },
    radio_station_04_hiphop = {                                     -- 101.9 ザ・ダージ
        index                                = 2,
        channel_name                         = "Gameplay-Devices-Radio-RadioStationHipHop",

        mus_radio_04_hiphop_the_god_machines = 0x0000CE80, -- Kill Trigger feat. Paul Senai, KaKow - The God Machines
        mus_radio_04_hiphop_blouses_blue     = 0x0000CE81, -- NC3 - Blouses Blue
        mus_radio_04_hiphop_problem_kids     = 0x0000CE82, -- Young Kenny - Problem Kids
        mus_radio_04_hiphop_bigger_man       = 0x0000CE83, -- Droox - Bigger Man
        mus_radio_04_hiphop_go_blaze         = 0x0000CE84, -- DNE feat. G'Natt - Go Blaze
        mus_radio_04_hiphop_dishonor         = 0x0000CE85, -- ICHIBANCHI - Dishonor
        mus_radio_04_hiphop_frost            = 0x0000CE86, -- Yamete - Frost
        mus_radio_04_hiphop_hs_bully         = 0x0000CE87, -- UMVN feat. Imp Ra - High School Bully
        mus_radio_04_hiphop_nbomdanalog      = 0x0000CE88, -- DAPxFLEM - Nbomdanalog
        mus_radio_04_hiphop_suicide          = 0x0000CE89, -- Code 137 - Suicide
        mus_radio_04_hiphop_day_of_dead      = 0x0000CE8A, -- HAPS - Day of Dead
        mus_radio_04_hiphop_bruzez           = 0x0000CE8B, -- Knixit - Bruzez
        mus_radio_04_hiphop_clip_boss        = 0x0000CE8C, -- Sugarcoob feat. ANAK KONDA - Clip Boss
        mus_radio_04_hiphop_plucku           = 0x0000CE8D, -- 3xB feat. Gun-Fu - PLUCK U
        mus_radio_04_hiphop_goodmorn         = 0x0000CE8E, -- Pazoozu - Hello Good Morning
        mus_radio_04_hiphop_run_the_block    = 0x0000CE8F, -- Bez Tatami feat. Gully Foyle - Run The Block
        mus_radio_04_hiphop_gr4ves           = 0x0000CE90, -- Kyubik - GR4VES
        mus_radio_04_hiphop_warning_shots    = 0x0000CE91, -- Laputan Machine - Warningshots
        mus_radio_04_hiphop_yugen_blakrok    = 0x0000CE92, -- Gorgon Madonna - Metamorphosis
        mus_radio_04_hiphop_no_save_point    = 0x0000CE93, -- Yankee and the Brave - No Save Point
        mus_radio_04_hiphop_ccc_flacko_loco  = 0x0000CE94, -- TELO$ - Flacko Loco
        mus_radio_04_hiphop_nose_bleed       = 0x0000D086, -- PeCero - Nose Bleed
        mus_radio_04_hiphop_ccc              = 0x0000D087  -- Cacimbo - CCC
    },
    radio_station_07_aggro_techno = {                      -- 103.5 ラジオPEBKAC
        index                                           = 3,
        channel_name                                    = "Gameplay-Devices-Radio-RadioStationAggroTechno",

        mus_radio_07_aggro_techno_bios                  = 0x0000CEA5, -- Error - BIOS
        mus_radio_07_aggro_techno_drained               = 0x0000CEA6, -- Sao Mai - Drained
        mus_radio_07_aggro_techno_subvert               = 0x0000CEA7, -- Spoon Eater - Subvert
        mus_radio_07_aggro_techno_follow_the_white_crow = 0x0000CEA8, -- Nablus - Follow The White Crow
        mus_radio_08_aggro_techno_fake_spook            = 0x0000CEA9, -- IOshrine - Fake Spook
        mus_radio_08_aggro_techno_move_dat              = 0x0000CEAA, -- [flesh]reactor - Move .dat
        mus_radio_07_aggro_techno_acid                  = 0x0000CEAC, -- Yards of the Moon - II0I Break
        mus_radio_07_aggro_techno_really_heavy_groove   = 0x0000CEAD, -- Retinal Scam - Across the Floor
        mus_radio_07_aggro_techno_stoczterdziescitrzy   = 0x0000CEAE, -- Retinal Scam - Gridflow
        mus_radio_07_aggro_techno_zero_acid             = 0x0000CEAF, -- Skin<>Drifter - Undertow Velocity
        mus_radio_07_aggro_techno_cdpmetal_vascular     = 0x0000CEB0, -- Tar Hawk - Vascular
        mus_radio_08_aggro_techno_cyberpunk02           = 0x0000CEB1, -- Tinnitus - On My Way To Hell
        mus_radio_07_aggro_techno_cannibalismus         = 0x0000D2AB, -- Bullet In The Head - CANNIBALISMUS
        mus_radio_07_aggro_techno_dark_retro            = 0x0000D2AC  -- Dukes of Azure - DARK RETRO
    },
    radio_station_10_latino = {                                       -- 106.9 30プリンシパレス
        index                                    = 7,
        channel_name                             = "Gameplay-Devices-Radio-RadioStationLatino",

        mus_radio_10_latino_bamo                 = 0x0000CEB2, -- Kartel Sonoro - Bamo
        mus_radio_10_latino_daggafrica           = 0x0000CEB3, -- Kartel Sonoro - Daggafrica
        mus_radio_10_latino_dinero               = 0x0000CEB4, -- 7 Facas - Dinero
        mus_radio_10_latino_serpant              = 0x0000CEB5, -- 7 Facas - Serpant
        mus_radio_10_latino_barrio               = 0x0000CEB6, -- Big Machete - Barrio
        mus_radio_10_latino_tatted_on_my_face    = 0x0000CEB7, -- Don Mara - Tatted On My Face
        mus_radio_10_latino_hood                 = 0x0000CEB8, -- ChickyChikas - Hood,
        mus_radio_10_latino_cumbia               = 0x0000CEB9, -- Papito Gringo - Muévelo / Cumbia
        mus_radio_10_latino_muertothrash         = 0x0000CEBA, -- FKxU - Muerto Thrash
        mus_radio_10_latino_only_son             = 0x0000CEBB, -- ChickyChickas - Only Son
        mus_radio_10_latino_westcoast_till_i_die = 0x0000CEBC  -- DJ CholoZ - Westcoast Til I Die
    },
    radio_station_01_att_rock = {                              -- 107.3 モロロック・ラジオ
        index                                          = 5,
        channel_name                                   = "Gameplay-Devices-Radio-RadioStationAttRock",

        mus_radio_01_att_rock_suffer_me                = 0x0000CE51, -- Brutus Backlash - SufferMe
        mus_radio_01_att_rock_heaven_ho                = 0x0000CE52, -- XerzeX - Heave Ho
        mus_radio_01_att_rock_i_will_follow            = 0x0000CE53, -- Beached Tarantula - I Will Follow
        mus_radio_01_attrock_likewise                  = 0x0000CE55, -- IBDY - LikeWise
        mus_radio_01_att_rock_friday_night_fire_night  = 0x0000CE56, -- The Rubicones - Friday Night Fire Fight
        mus_radio_01_att_rock_trauma                   = 0x0000CE57, -- The Rubicones - Trauma
        mus_radio_01_att_rock_mstr01                   = 0x0000CE58, -- Cutthroat - Sustain/Decay
        mus_radio_01_att_rock_never_fade_away          = 0x0000CE59, -- Samurai - Never Fade Away
        mus_radio_01_att_rock_black_dog                = 0x0000CE5A, -- Samurai - Black Dog
        mus_radio_01_att_rock_chippin_in               = 0x0000CE5B, -- Samurai - Chippin' In
        mus_radio_01_att_rock_the_ballad               = 0x0000CE5C, -- Samurai - The Ballad of Buck Ravers
        mus_radio_01_attrock_summer_of_2069            = 0x0000D06E, -- Blood And Ice - Summer of 2069
        mus_radio_01_att_rock_no_convenient_apocalypse = 0x0000D06F, -- Krushchev's Ghosts - No Convenient Apocalypse
        mus_radio_01_attrock_to_the_fullest            = 0x0000D071, -- Artificial Kids - To The Fullest
        mus_radio_01_attrock_so_it_goes                = 0x0000D072  -- Fingers and the Outlaws - So It Goes
    }
}

radio.station_order     = { 4, 0, 10, 1, 9, 8, 6, 2, 3, 7, 5 }
radio.ignore_track_list = { "index", "channel_name" }

---@return CName
function radio.get_current_station_name()
    return Game.GetMountedVehicle(Game.GetPlayer()):GetRadioReceiverStationName()
end

---@return string
function radio.get_current_station_evt()
    for station_evt, track_list in pairs(radio.data) do
        if track_list.channel_name == radio.get_current_station_name().value then
            return station_evt
        end
    end
end

---@return table
function radio.get_current_station_track_list()
    for _, track_list in pairs(radio.data) do
        if track_list.channel_name == radio.get_current_station_name().value then
            return track_list
        end
    end
end

---@return CName
function radio.get_current_track_name()
    return Game.GetMountedVehicle(Game.GetPlayer()):GetRadioReceiverTrackName()
end

---@return string
function radio.get_current_track_evt()
    for track_evt, track_hash_lo in pairs(radio.get_current_station_track_list()) do
        if track_hash_lo == radio.get_current_track_name().hash_lo then
            return track_evt
        end
    end
end

return radio
