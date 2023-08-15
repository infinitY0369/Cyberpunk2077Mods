import json
import os
import re
import shutil
import subprocess
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

CURRENT_DIR = None
MOD_NAME = None

INCLUDE_DIR = None
CLEAN_DIR = None

FORMAT_DIR = None
CLANG_EXT = None

OUT_PATH = None


class Cpp:
    @classmethod
    def clang_format(cls):
        print("Formatting C++ files...")

        style_path = os.path.join(CURRENT_DIR, ".clang-format")
        if not os.path.exists(style_path):
            print("Could not find clang format config at " + style_path)
            return

        print("Found clang format config at " + style_path)

        for dir in FORMAT_DIR:
            for root, _, files in os.walk(os.path.join(CURRENT_DIR, dir)):
                for file in files:
                    if any(file.endswith(ext) for ext in CLANG_EXT):
                        subprocess.run(["clang-format", "-i", os.path.join(root, file), f"-style=file:{style_path}", "-fallback-style=none"])
        print("Done formatting C++ files")


class Lua:
    @staticmethod
    def remove_comment(code):
        # Remove block comments
        code = re.sub(r"\n?[\t| ]*--\[\[.*?\]\][\t| ]*", "", code, flags=re.DOTALL)

        # Remove single-line comments
        code = re.sub(r"\n?[\t| ]*--.*", "", code)

        return code


class Zip:
    @classmethod
    def pack(cls, lua_rm_cmt=False, json_minify=False):
        with ZipFile(OUT_PATH, "w") as zip_file:
            for dir_info in INCLUDE_DIR:
                src, ext, arc = cls.extract_dir_info(dir_info)
                for root, _, files in os.walk(os.path.join(CURRENT_DIR, src)):
                    for file in files:
                        if not ext or file.endswith(ext):
                            file_path = os.path.join(root, file)
                            arc_name = os.path.join(arc, file) if arc else os.path.relpath(file_path, CURRENT_DIR)
                            cls.pack_file(zip_file, file_path, arc_name, lua_rm_cmt, json_minify)

    @staticmethod
    def extract_dir_info(dir_info):
        if isinstance(dir_info, dict):
            return dir_info.get("src"), dir_info.get("ext"), dir_info.get("arc")
        return dir_info, None, None

    @staticmethod
    def pack_file(zip_file, file_path, arc_name, lua_rm_cmt, json_minify):
        with open(file_path, "rb") as file:
            file_content = file.read()
            if lua_rm_cmt and file_path.endswith(".lua"):
                file_content = Lua.remove_comment(file_content.decode()).encode()
            elif json_minify and file_path.endswith(".json"):
                file_content = json.dumps(json.loads(file_content.decode()), separators=(",", ":"))
            info = ZipInfo(arc_name, (2048, 10, 12, 0, 0, 0))
            zip_file.writestr(info, file_content, compress_type=ZIP_DEFLATED, compresslevel=9)


def clean():
    for dir_name in CLEAN_DIR:
        remove_dir = os.path.join(CURRENT_DIR, dir_name)
        print(f'Removed "{remove_dir}"')
        shutil.rmtree(remove_dir)
