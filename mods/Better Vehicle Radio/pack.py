import os
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

current_path = os.path.abspath(__file__)
current_dir = os.path.dirname(current_path)
mod_name = os.path.basename(current_dir)
include_dir = ["archive", "bin", "r6"]
out_path = os.path.join(current_dir, f"{mod_name}.zip")

with ZipFile(out_path, "w") as zip_file:
    for dir_name in include_dir:
        dir_path = os.path.join(current_dir, dir_name)
        for root, _, files in os.walk(dir_path):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, current_dir)
                info = ZipInfo(arcname, (2048, 10, 12, 0, 0, 0))
                with open(file_path, "rb") as file:
                    zip_file.writestr(info, file.read(), compress_type=ZIP_DEFLATED, compresslevel=9)
