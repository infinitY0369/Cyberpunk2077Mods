import json
import sys
from pathlib import Path

from .radio_metadata import RadioMetadata

sys.path.append(Path(__file__).parents[3].__str__())
import Mod


class FixNCART:
    __mod_dir = Path(__file__).parents[1]
    __mod_name = Mod.to_snake_case(__mod_dir.name)
    __file_name = Path(__file__).stem

    def __init__(self, cwd: Path, metadata_path: Path | None = None, dist_dir: Path | None = None) -> None:
        self.__cwd = cwd
        self.__dist_dir = dist_dir or self.__cwd.joinpath("dist", "_".join([self.__mod_name, self.__file_name]))
        self.__metadata = self.__get_cooked_metadata(metadata_path)

    def create(self):
        for entry in self.__metadata["Data"]["RootChunk"]["entries"]:
            if entry["Data"]["$type"] != "audioRadioTracksMetadata":
                continue

            for track in entry["Data"]["radioTracks"]:
                if track["isStreamingFriendly"] != 0:
                    continue

                track["isStreamingFriendly"] = 1

        self.__metadata_serialized_out_path = self.__dist_dir.joinpath(self.__metadata_serialized_rel_path)
        self.__metadata_serialized_out_path.parent.mkdir(parents=True, exist_ok=True)
        self.__metadata_serialized_out_path.write_text(json.dumps(self.__metadata), "utf-8")

        return self

    def pack(self) -> tuple[Path, Path]:
        Mod.Archive.deserialize_cr2w(self.__metadata_serialized_out_path, self.__metadata_serialized_out_path.parent, self.__cwd)
        Mod.clean([self.__metadata_serialized_out_path])

        packed_file_path = Mod.Archive.pack(self.__dist_dir, self.__dist_dir, self.__cwd)

        metadata_rel_path = Path("bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\better_vehicle_radio\\data\\metadata.json")
        self.__metadata_out_path = self.__dist_dir.joinpath(metadata_rel_path)
        RadioMetadata(self.__metadata_out_path, self.__cwd, self.__metadata).create()

        return packed_file_path.parent.relative_to(self.__mod_dir), self.__metadata_out_path.parent.relative_to(self.__mod_dir)

    def __get_cooked_metadata(self, metadata_path: Path | None = None) -> dict:
        raw_path = Path("base\\sound\\metadata\\cooked_metadata.audio_metadata")

        archive_dir = self.__cwd.joinpath("archive")
        raw_dir = self.__cwd.joinpath("raw")

        if metadata_path:
            serialized_file_path = metadata_path
            self.__metadata_serialized_rel_path = metadata_path.relative_to(self.__dist_dir)
        else:
            raw_file_path = Mod.Archive.extract_raw_file(raw_path, archive_dir, self.__cwd)
            serialized_file_path = Mod.Archive.serialize_cr2w(raw_file_path, raw_dir.joinpath(raw_file_path.parent.relative_to(archive_dir)), self.__cwd)
            self.__metadata_serialized_rel_path = serialized_file_path.relative_to(raw_dir)

        cooked_metadata = json.loads(serialized_file_path.read_text("utf-8"))

        return cooked_metadata
