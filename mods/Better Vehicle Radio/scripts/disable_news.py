import json
import sys
from pathlib import Path

sys.path.append(Path(__file__).parents[3].__str__())
import mod


class DisableNews:
    ARCHIVE_PATH = {"radio_content.questphase": Path("base\\media\\radio\\radio_content.questphase")}

    @classmethod
    def create(cls, work_dir: Path):
        radio_content, radio_content_json_path = mod.Archive.get_json_data_from_cr2w(
            cls.ARCHIVE_PATH["radio_content.questphase"], work_dir
        )

        radio_content["Data"]["RootChunk"]["graph"]["Data"]["nodes"].clear()

        radio_content_json_path.write_text(json.dumps(radio_content), "utf-8")
