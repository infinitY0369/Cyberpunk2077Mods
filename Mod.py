import json
import os
import re
import shutil
import subprocess
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

CURRENT_DIR: Path
MOD_NAME: str


class Cpp:
    __CLANG_EXT = [".cpp", ".hpp", ".h"]

    @classmethod
    def format(cls, dir_list: list[Path], style_path: Path):
        print("Formatting C++ files...")

        if not style_path.exists():
            print("Could not find clang format config at " + style_path.__str__())
            return

        print("Found clang format config at " + style_path.__str__())

        for dir in dir_list:
            for file in dir.rglob("*"):
                if file.is_dir():
                    continue

                if any(file.suffix == ext for ext in cls.__CLANG_EXT):
                    subprocess.run(["clang-format", "-i", file, f"-style=file:{style_path}", "-fallback-style=none"])

        print("Done formatting C++ files")


class Lua:
    @staticmethod
    def delete_comments(code):
        # Remove block comments
        code = re.sub(r"[\t| ]*--\[\[.*\]\][\t| ]*", "", code, flags=re.DOTALL)

        # Remove single-line comments
        code = re.sub(r"(?m)^[\t| ]*--.*\n", "", code)  # Line with only comments
        code = re.sub(r"[\t| ]*--.*", "", code)  # Comments next to the code

        return code


class Zip:
    def __init__(self, dir_info_list: list[str | dict[str, str | Path | None]], out_path: Path, cwd: Path | None = None) -> None:
        self.__dir_info_list = dir_info_list
        self.__out_path = out_path
        self.__cwd = cwd or CURRENT_DIR

        self.min_all(False)

    def min_all(self, value: bool):
        self.__delete_lua_comments = value
        self.__minify_json = value

        return self

    def delete_lua_comments(self):
        self.__delete_lua_comments = True

        return self

    def minify_json(self):
        self.__minify_json = True

        return self

    def create(self):
        with ZipFile(self.__out_path, "w") as zip_file:
            self.__zip_file = zip_file
            self.__pack()

    def __pack(self):
        for dir_info in self.__dir_info_list:
            src, arc, rel, ext = self.__extract_dir_info(dir_info)

            for file in self.__cwd.joinpath(src).rglob("*"):
                if file.is_dir():
                    continue

                if ext and file.suffix != ext:
                    continue

                arc_name = Path(arc).joinpath(file.name).__str__() if arc else file.relative_to(rel or self.__cwd).__str__()

                file_data = self.__process_file_data(file)

                zip_info = ZipInfo(arc_name, (2048, 10, 12, 0, 0, 0))
                self.__zip_file.writestr(zip_info, file_data, compress_type=ZIP_DEFLATED, compresslevel=9)

    def __extract_dir_info(self, dir_info: str | dict[str, str | Path | None]) -> tuple[str | Path, str | Path | None, str | Path | None, str | None]:
        if isinstance(dir_info, dict):
            src = dir_info.get("src")

            if src is None:
                raise ValueError()

            arc = dir_info.get("arc")
            rel = dir_info.get("rel")
            ext: str | None = dir_info.get("ext")  # type: ignore

            return src, arc, rel, ext

        return dir_info, None, None, None

    def __process_file_data(self, file: Path):
        file_data = file.read_bytes()

        match file.suffix:
            case ".lua":
                if self.__delete_lua_comments:
                    return Lua.delete_comments(file_data.decode()).encode()
            case ".json":
                if self.__minify_json:
                    return json.dumps(json.loads(file_data.decode()), separators=(",", ":"))

        return file_data


class Archive:
    DIST_REL_DIR = Path("archive\\pc\\mod")
    GAME_BASE_DIR = Path(os.getenv("ProgramFiles(x86)")).joinpath("GOG Galaxy\\Games\\Cyberpunk 2077")  # type: ignore
    CONTENT_DIR = GAME_BASE_DIR.joinpath("archive\\pc\\content")
    EP1_DIR = GAME_BASE_DIR.joinpath("archive\\pc\\ep1")

    @classmethod
    def pack(cls, input_dir: Path, out_dir: Path, cwd: Path | None = None) -> Path:
        out_dir.mkdir(exist_ok=True, parents=True)
        subprocess.run(["WolvenKit.CLI.exe", "pack", input_dir, "--outpath", out_dir], cwd=cwd, stdout=subprocess.DEVNULL)

        out_file_path = out_dir.joinpath(input_dir.name + ".archive")

        if not out_file_path.exists():
            raise FileNotFoundError()

        return out_file_path

    @classmethod
    def extract_raw_file(cls, raw_file_path: Path, out_dir: Path, cwd: Path | None = None, overwrite: bool = False) -> Path:
        out_file_path = out_dir.joinpath(raw_file_path)

        if not overwrite and out_file_path.exists():
            return out_file_path

        out_dir.mkdir(parents=True, exist_ok=True)
        subprocess.run(
            [
                "WolvenKit.CLI.exe",
                "extract",
                cls.CONTENT_DIR,
                cls.EP1_DIR,
                "--gamepath",
                cls.GAME_BASE_DIR,
                "--outpath",
                out_dir,
                "--pattern",
                raw_file_path,
            ],
            cwd=cwd,
            stdout=subprocess.DEVNULL,
        )

        if not out_file_path.exists():
            raise FileNotFoundError()

        return out_file_path

    @classmethod
    def serialize_cr2w(cls, raw_file_path: Path, out_dir: Path, cwd: Path | None = None, overwrite: bool = False):
        out_file_path = out_dir.joinpath(raw_file_path.name + ".json")

        if not overwrite and out_file_path.exists():
            return out_file_path

        out_dir.mkdir(exist_ok=True, parents=True)
        subprocess.run(["WolvenKit.CLI.exe", "convert", "serialize", raw_file_path, "--outpath", out_dir], cwd=cwd, stdout=subprocess.DEVNULL)

        if not out_file_path.exists():
            raise FileNotFoundError()

        return out_file_path

    @classmethod
    def deserialize_cr2w(cls, serialized_file_path: Path, out_dir: Path, cwd: Path | None = None, overwrite: bool = False):
        out_file_path = out_dir.joinpath(serialized_file_path.stem)

        if not overwrite and out_file_path.exists():
            return out_file_path

        out_dir.mkdir(exist_ok=True, parents=True)
        subprocess.run(["WolvenKit.CLI.exe", "convert", "deserialize", serialized_file_path, "--outpath", out_dir], cwd=cwd, stdout=subprocess.DEVNULL)

        if not out_file_path.exists():
            raise FileNotFoundError()

        return out_file_path


def clean(dir_list: list[Path]):
    for dir in dir_list:
        if not dir.exists():
            continue

        if dir.is_file():
            dir.unlink()
        else:
            shutil.rmtree(dir)

        print(f'Removed "{dir.__str__()}"')


def to_snake_case(string):
    string = re.sub(r"\s", "", string)
    string = re.sub("(.)([A-Z][a-z]+)", r"\1_\2", string)
    return re.sub("([a-z0-9])([A-Z])", r"\1_\2", string).lower()
