import json
import sys
from pathlib import Path

sys.path.append(Path(__file__).parents[3].__str__())
import mod


class FixNCART:
    ARCHIVE_PATH = {"cooked_metadata.audio_metadata": Path("base\\sound\\metadata\\cooked_metadata.audio_metadata")}

    @classmethod
    def create(cls, work_dir: Path):
        cooked_metadata, cooked_metadata_json_path = mod.Archive.get_json_data_from_cr2w(
            cls.ARCHIVE_PATH["cooked_metadata.audio_metadata"], work_dir, False
        )

        for entry in cooked_metadata["Data"]["RootChunk"]["entries"]:
            if entry["Data"]["$type"] == "audioRadioTracksMetadata":
                for track in entry["Data"]["radioTracks"]:
                    if track["isStreamingFriendly"] == 0:
                        track["isStreamingFriendly"] = 1

        cooked_metadata_json_path.write_text(json.dumps(cooked_metadata), "utf-8")

        metadata_rel_path = Path(
            "bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\better_vehicle_radio\\data\\metadata.json"
        )
        metadata = json.loads(Path(__file__).parents[1].joinpath(metadata_rel_path).read_text("utf-8"))

        for station in metadata["radioStations"]:
            for track in station["tracks"]:
                if track["isStreamingFriendly"] == 0:
                    track["isStreamingFriendly"] = 1

        metadata_out_path = work_dir.joinpath(metadata_rel_path)
        metadata_out_path.parent.mkdir(parents=True, exist_ok=True)
        metadata_out_path.write_text(json.dumps(metadata, indent=4), "utf-8")
