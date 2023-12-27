import sys
from pathlib import Path

from scripts.disable_blips import DisableBlips
from scripts.disable_blips_and_fix_ncart import DisableBlipsAndFixNCART
from scripts.disable_news import DisableNews
from scripts.fix_ncart import FixNCART
from scripts.radio_metadata import RadioMetadata

sys.path.append(Path(__file__).parents[2].__str__())
import Mod

Mod.CURRENT_DIR = Path(__file__).parent
Mod.MOD_NAME = Mod.CURRENT_DIR.name


if __name__ == "__main__":
    PREFIX = Mod.to_snake_case(Mod.MOD_NAME) + "_"

    dist_dir = Mod.CURRENT_DIR.joinpath("dist")
    work_dir = Mod.CURRENT_DIR.joinpath(".tmp")

    dist_dir.mkdir(parents=True, exist_ok=True)

    # Main
    RadioMetadata(Mod.CURRENT_DIR.joinpath("bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\better_vehicle_radio\\data\\metadata.json"), work_dir).create()
    Mod.Zip(["bin"], dist_dir.joinpath(f"{Mod.MOD_NAME} - Main.zip")).delete_lua_comments().minify_json().create()

    # Disable blips
    src = DisableBlips(work_dir).create().pack()
    Mod.Zip([{"src": src, "arc": Mod.Archive.DIST_REL_DIR, "ext": ".archive"}], dist_dir.joinpath(f"{Mod.MOD_NAME} - Disable blips.zip")).create()

    # Disable news
    src = DisableNews(work_dir).create().pack()
    Mod.Zip([{"src": src, "arc": Mod.Archive.DIST_REL_DIR, "ext": ".archive"}], dist_dir.joinpath(f"{Mod.MOD_NAME} - Disable news.zip")).create()

    # Fix NCART
    src, bin = FixNCART(work_dir).create().pack()
    Mod.Zip(
        [{"src": src, "arc": Mod.Archive.DIST_REL_DIR, "ext": ".archive"}, {"src": bin, "rel": Mod.CURRENT_DIR.joinpath(src)}],
        dist_dir.joinpath(f"{Mod.MOD_NAME} - Fix NCART.zip"),
    ).minify_json().create()

    # Disable blips & Fix NCART
    src, bin = DisableBlipsAndFixNCART(work_dir).pack()
    Mod.Zip(
        [{"src": src, "arc": Mod.Archive.DIST_REL_DIR, "ext": ".archive"}, {"src": bin, "rel": Mod.CURRENT_DIR.joinpath(src)}],
        dist_dir.joinpath(f"{Mod.MOD_NAME} - Disable blips & Fix NCART.zip"),
    ).minify_json().create()

    Mod.clean([work_dir])
