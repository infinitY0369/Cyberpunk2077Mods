import json
import sys
from pathlib import Path

sys.path.append(Path(__file__).parents[3].__str__())
import Mod


class DisableNews:
    __mod_dir = Path(__file__).parents[1]
    __mod_name = Mod.to_snake_case(__mod_dir.name)
    __file_name = Path(__file__).stem

    def __init__(self, cwd: Path) -> None:
        self.__cwd = cwd
        self.__raw_dir = self.__cwd.joinpath("raw")
        self.__dist_dir = self.__cwd.joinpath("dist", "_".join([self.__mod_name, self.__file_name]))
        self.__radio_data = self.__get_radio_content()

    def create(self):
        self.__radio_data["Data"]["RootChunk"]["graph"]["Data"]["nodes"].clear()

        radio_data_serialized_rel_path = self.__radio_data_serialized_path.relative_to(self.__raw_dir)
        self.__radio_data_serialized_out_path = self.__dist_dir.joinpath(radio_data_serialized_rel_path)
        self.__radio_data_serialized_out_path.parent.mkdir(parents=True, exist_ok=True)
        self.__radio_data_serialized_out_path.write_text(json.dumps(self.__radio_data), "utf-8")

        return self

    def pack(self) -> Path:
        Mod.Archive.deserialize_cr2w(self.__radio_data_serialized_out_path, self.__radio_data_serialized_out_path.parent, self.__cwd)
        Mod.clean([self.__radio_data_serialized_out_path])

        packed_file_path = Mod.Archive.pack(self.__dist_dir, self.__dist_dir, self.__cwd)

        return packed_file_path.parent.relative_to(self.__mod_dir)

    def __get_radio_content(self) -> dict:
        raw_path = Path("base\\media\\radio\\radio_content.questphase")

        archive_dir = self.__cwd.joinpath("archive")
        raw_file_path = Mod.Archive.extract_raw_file(raw_path, archive_dir, self.__cwd)

        serialized_file_path = Mod.Archive.serialize_cr2w(raw_file_path, self.__raw_dir.joinpath(raw_file_path.parent.relative_to(archive_dir)), self.__cwd)

        cooked_metadata = json.loads(serialized_file_path.read_text("utf-8"))
        self.__radio_data_serialized_path = serialized_file_path

        return cooked_metadata
