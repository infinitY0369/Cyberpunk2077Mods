import json
import sys
from pathlib import Path

sys.path.append(Path(__file__).parents[3].__str__())
import mod


class DisableBlips:
    ARCHIVE_PATH = {"cooked_metadata.audio_metadata": Path("base\\sound\\metadata\\cooked_metadata.audio_metadata")}

    @classmethod
    def create(cls, work_dir: Path):
        cooked_metadata, cooked_metadata_json_path = mod.Archive.get_json_data_from_cr2w(
            cls.ARCHIVE_PATH["cooked_metadata.audio_metadata"], work_dir
        )

        for entry in cooked_metadata["Data"]["RootChunk"]["entries"]:
            if entry["Data"]["$type"] == "audioRadioStationMetadata":
                entry["Data"]["blips"].clear()

        cooked_metadata_json_path.write_text(json.dumps(cooked_metadata), "utf-8")
