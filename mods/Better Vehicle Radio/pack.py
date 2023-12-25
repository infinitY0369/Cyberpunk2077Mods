import shutil
import sys
from pathlib import Path

from scripts.disable_blips import DisableBlips
from scripts.disable_news import DisableNews
from scripts.fix_ncart import FixNCART
from scripts.radio_metadata import RadioMetadata

sys.path.append(Path(__file__).parents[2].__str__())
import mod

mod.CURRENT_DIR = Path(__file__).parent
mod.MOD_NAME = mod.CURRENT_DIR.name


PREFIX = mod.to_snake_case(mod.MOD_NAME) + "_"

if __name__ == "__main__":
    dist_dir = mod.CURRENT_DIR.joinpath("dist")
    metadata_rel_path = Path("bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\better_vehicle_radio\\data\\metadata.json")
    work_dir = mod.CURRENT_DIR.joinpath(".tmp")

    dist_dir.mkdir(parents=True, exist_ok=True)

    # Main
    RadioMetadata.create(mod.CURRENT_DIR.joinpath(".tmp"), mod.CURRENT_DIR.joinpath(metadata_rel_path))

    mod.INCLUDE_DIR = ["bin"]
    mod.OUT_PATH = dist_dir.joinpath(f"{mod.MOD_NAME} - Main.zip")

    mod.Zip.pack(lua_rm_cmt=True, json_minify=True)

    # Disable blips
    DisableBlips.create(work_dir)

    mod.INCLUDE_DIR = [{"src": work_dir, "arc": mod.Archive.ARCHIVE_DIST_REL_DIR, "ext": ".archive"}]
    mod.OUT_PATH = dist_dir.joinpath(f"{mod.MOD_NAME} - Disable blips.zip")

    mod.Archive.pack(work_dir.relative_to(mod.CURRENT_DIR), PREFIX + "disable_blips", work_dir)
    mod.Zip.pack()
    shutil.rmtree(work_dir)

    # Disable news
    DisableNews.create(work_dir)

    mod.INCLUDE_DIR = [{"src": work_dir, "arc": mod.Archive.ARCHIVE_DIST_REL_DIR, "ext": ".archive"}]
    mod.OUT_PATH = dist_dir.joinpath(f"{mod.MOD_NAME} - Disable news.zip")

    mod.Archive.pack(work_dir.relative_to(mod.CURRENT_DIR), PREFIX + "disable_news", work_dir)
    mod.Zip.pack()
    shutil.rmtree(work_dir)

    # Fix NCART
    FixNCART.create(work_dir)

    mod.INCLUDE_DIR = [
        {"src": work_dir, "arc": mod.Archive.ARCHIVE_DIST_REL_DIR, "ext": ".archive"},
        work_dir.relative_to(mod.CURRENT_DIR).joinpath("bin"),
    ]
    mod.OUT_PATH = dist_dir.joinpath(f"{mod.MOD_NAME} - Fix NCART.zip")

    mod.Archive.pack(work_dir.relative_to(mod.CURRENT_DIR), PREFIX + "fix_ncart", work_dir)
    mod.Zip.pack(work_dir, json_minify=True)
    shutil.rmtree(work_dir)

    # Disable blips & Fix NCART
    DisableBlips.create(work_dir)
    FixNCART.create(work_dir)

    mod.INCLUDE_DIR = [
        {"src": work_dir, "arc": mod.Archive.ARCHIVE_DIST_REL_DIR, "ext": ".archive"},
        work_dir.relative_to(mod.CURRENT_DIR).joinpath("bin"),
    ]
    mod.OUT_PATH = dist_dir.joinpath(f"{mod.MOD_NAME} - Disable blips & Fix NCART.zip")

    mod.Archive.pack(work_dir.relative_to(mod.CURRENT_DIR), PREFIX + "disable_blips_and_fix_ncart", work_dir)
    mod.Zip.pack(work_dir, json_minify=True)
    shutil.rmtree(work_dir)
