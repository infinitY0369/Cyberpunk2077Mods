import json
import os
import re
import shutil
import subprocess
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

CURRENT_DIR: Path
MOD_NAME: str

INCLUDE_DIR: list[str | dict[str, str]]
CLEAN_DIR: list[Path]

FORMAT_DIR: list[str]
CLANG_EXT: list[str]

OUT_PATH: Path


def to_snake_case(string):
    string = re.sub(r"\s", "", string)
    string = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", string)
    return re.sub("([a-z0-9])([A-Z])", r"\1_\2", string).lower()


class Cpp:
    @classmethod
    def clang_format(cls):
        print("Formatting C++ files...")

        style_path = CURRENT_DIR.joinpath(".clang-format")
        if not style_path.exists():
            print("Could not find clang format config at " + style_path.__str__())
            return

        print("Found clang format config at " + style_path.__str__())

        for dir in FORMAT_DIR:
            for file in CURRENT_DIR.joinpath(dir).rglob("*"):
                if file.is_dir():
                    continue

                if any(file.suffix == ext for ext in CLANG_EXT):
                    subprocess.run(["clang-format", "-i", file, f"-style=file:{style_path}", "-fallback-style=none"])

        print("Done formatting C++ files")


class Lua:
    @staticmethod
    def remove_comment(code):
        # Remove block comments
        code = re.sub(r"[\t| ]*--\[\[.*\]\][\t| ]*", "", code, flags=re.DOTALL)

        # Remove single-line comments
        code = re.sub(r"(?m)^[\t| ]*--.*\n", "", code)  # Line with only comments
        code = re.sub(r"[\t| ]*--.*", "", code)  # Comments next to the code

        return code


class Zip:
    @classmethod
    def pack(cls, relative_dir: Path = None, lua_rm_cmt=False, json_minify=False):
        with ZipFile(OUT_PATH, "w") as zip_file:
            for dir_info in INCLUDE_DIR:
                src, ext, arc = cls.extract_dir_info(dir_info)
                for file in CURRENT_DIR.joinpath(src).rglob("*"):
                    if file.is_dir():
                        continue

                    if ext and file.suffix != ext:
                        continue

                    arc_name = Path(arc).joinpath(file.name) if arc else file.relative_to(relative_dir or CURRENT_DIR)
                    cls.pack_file(zip_file, file, arc_name.__str__(), lua_rm_cmt, json_minify)

    @staticmethod
    def extract_dir_info(dir_info: str | dict[str, str]):
        if isinstance(dir_info, dict):
            return dir_info.get("src"), dir_info.get("ext"), dir_info.get("arc")
        return dir_info, None, None

    @staticmethod
    def pack_file(zip_file: ZipFile, file_path: Path, arc_name: str, lua_rm_cmt: bool, json_minify: bool):
        file_data = file_path.read_bytes()

        match file_path.suffix:
            case ".lua":
                if lua_rm_cmt:
                    file_data = Lua.remove_comment(file_data.decode()).encode()
            case ".json":
                if json_minify:
                    file_data = json.dumps(json.loads(file_data.decode()), separators=(",", ":"))

        zip_info = ZipInfo(arc_name, (2048, 10, 12, 0, 0, 0))
        zip_file.writestr(zip_info, file_data, compress_type=ZIP_DEFLATED, compresslevel=9)


class Archive:
    ARCHIVE_DIST_REL_DIR = Path("archive\\pc\\mod")
    GAME_BASE_DIR = Path(os.getenv("ProgramFiles(x86)")).joinpath("GOG Galaxy\\Games\\Cyberpunk 2077")
    ARCHIVE_CONTENT_DIR = GAME_BASE_DIR.joinpath("archive\\pc\\content")
    ARCHIVE_EP1_DIR = GAME_BASE_DIR.joinpath("archive\\pc\\ep1")

    @classmethod
    def pack(cls, base_rel_dir: Path, out_name: str, out_dir: Path):
        absolute_base_dir = CURRENT_DIR.joinpath(base_rel_dir)
        raw_dir = absolute_base_dir.joinpath("raw")
        archive_base_dir = absolute_base_dir.joinpath("archive")
        archive_path = archive_base_dir.joinpath(out_name)

        clean_archive_dir = False

        if raw_dir.exists():
            if not archive_base_dir.exists():
                clean_archive_dir = True

            for file in raw_dir.rglob("*"):
                if file.is_dir():
                    continue

                if not file.suffix == ".json":
                    continue

                cr2w_out_path = archive_path.joinpath(file.parent.relative_to(raw_dir))
                cls.deserialize_cr2w_to_json(file, cr2w_out_path, absolute_base_dir)

        out_dir.mkdir(exist_ok=True, parents=True)
        subprocess.run(["WolvenKit.CLI.exe", "pack", archive_path, "--outpath", out_dir], cwd=absolute_base_dir)

        if clean_archive_dir:
            shutil.rmtree(archive_base_dir)

    @classmethod
    def get_json_data_from_cr2w(cls, archive_rel_path: Path, base_dir: Path, overwrite: bool = True):
        archive_dir = base_dir.joinpath("archive")
        raw_dir = base_dir.joinpath("raw")

        raw_out_dir = raw_dir.joinpath(archive_rel_path.parent)
        json_out_path = raw_out_dir.joinpath(archive_rel_path.name + ".json")

        if overwrite or not json_out_path.exists():
            cls.extract_raw_file(archive_rel_path, archive_dir, base_dir)
            cls.serialize_cr2w_to_json(archive_dir.joinpath(archive_rel_path), raw_out_dir, base_dir)

        json_data: dict = json.loads(json_out_path.read_text("utf-8"))

        if archive_dir.exists():
            shutil.rmtree(archive_dir)

        return json_data, json_out_path

    @classmethod
    def extract_raw_file(cls, file_path: Path, out_path: Path, cwd=None):
        out_path.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            ["WolvenKit.CLI.exe", "extract", cls.ARCHIVE_CONTENT_DIR, cls.ARCHIVE_EP1_DIR, "--outpath", out_path, "--pattern", file_path],
            cwd=cwd,
        )

    @classmethod
    def deserialize_cr2w_to_json(cls, file_path: Path, out_path: Path, cwd=None):
        out_path.mkdir(exist_ok=True, parents=True)
        subprocess.run(
            ["WolvenKit.CLI.exe", "convert", "deserialize", file_path, "--outpath", out_path],
            cwd=cwd,
        )

    @classmethod
    def serialize_cr2w_to_json(cls, file_path: Path, out_path: Path, cwd=None):
        out_path.mkdir(exist_ok=True, parents=True)
        subprocess.run(
            ["WolvenKit.CLI.exe", "convert", "serialize", file_path, "--outpath", out_path],
            cwd=cwd,
        )


def clean():
    for dir in CLEAN_DIR:
        print(f'Removed "{dir.__str__()}"')
        shutil.rmtree(dir)
