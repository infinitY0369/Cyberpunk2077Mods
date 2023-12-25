import json
import shutil
import sys
from pathlib import Path

sys.path.append(Path(__file__).parents[3].__str__())
import mod


class RadioMetadata:
    STATION_MAP = [
        {"primaryKey": 699, "evt": "radio_station_02_aggro_ind"},
        {"primaryKey": 700, "evt": "radio_station_03_elec_ind"},
        {"primaryKey": 701, "evt": "radio_station_04_hiphop"},
        {"primaryKey": 702, "evt": "radio_station_07_aggro_techno"},
        {"primaryKey": 704, "evt": "radio_station_09_downtempo"},
        {"primaryKey": 2122, "evt": "radio_station_01_att_rock"},
        {"primaryKey": 2123, "evt": "radio_station_05_pop"},
        {"primaryKey": 2124, "evt": "radio_station_10_latino"},
        {"primaryKey": 2125, "evt": "radio_station_11_metal"},
        {"primaryKey": 13224, "evt": "radio_station_06_minim_techno"},
        {"primaryKey": 45325, "evt": "radio_station_08_jazz"},
        {"primaryKey": 93677, "evt": "radio_station_12_growl_fm"},
        {"primaryKey": 93675, "evt": "radio_station_13_dark_star"},
        {"primaryKey": 93676, "evt": "radio_station_14_impulse_fm"},
    ]

    ARCHIVE_PATH = {
        "cooked_metadata.audio_metadata": Path("base\\sound\\metadata\\cooked_metadata.audio_metadata"),
        "onscreens_final.json": Path("base\\localization\\en-us\\onscreens\\onscreens_final.json"),
    }

    @classmethod
    def create(cls, work_dir: Path, out_path: Path):
        cooked_metadata, _ = mod.Archive.get_json_data_from_cr2w(
            cls.ARCHIVE_PATH["cooked_metadata.audio_metadata"], work_dir
        )
        onscreens_final, _ = mod.Archive.get_json_data_from_cr2w(cls.ARCHIVE_PATH["onscreens_final.json"], work_dir)

        shutil.rmtree(work_dir)

        out_metadata = {}
        out_metadata["radioStations"] = []

        for station in cls.STATION_MAP:
            station_primary_key = station["primaryKey"]
            station_secondary_key = cls.get_secondary_key(station_primary_key, onscreens_final)
            station_event_name = station["evt"]

            station_data = {
                "primaryKey": station_primary_key,
                "secondaryKey": station_secondary_key,
                "stationEventName": station_event_name,
                "tracks": [],
            }

            if station_event_name == "radio_station_05_pop":
                station_event_name = station_event_name + "_completed_sq017"

            for entry in cooked_metadata["Data"]["RootChunk"]["entries"]:
                if (
                    entry["Data"]["$type"] == "audioRadioStationMetadata"
                    and entry["Data"]["name"]["$value"] == station_event_name
                ):
                    for track in entry["Data"]["tracks"]:
                        track_event_name = track["$value"]
                        track_metadata = cls.get_track_metadata(track_event_name, cooked_metadata)
                        track_is_streaming_friendly = track_metadata["isStreamingFriendly"]
                        track_primary_key = int(track_metadata["primaryLocKey"])
                        track_secondary_key = cls.get_secondary_key(track_primary_key, onscreens_final)

                        track_data = {
                            "isStreamingFriendly": track_is_streaming_friendly,
                            "primaryKey": track_primary_key,
                            "secondaryKey": track_secondary_key,
                            "trackEventName": track_event_name,
                        }

                        station_data["tracks"].append(track_data)

            out_metadata["radioStations"].append(station_data)

        out_path.parent.mkdir(parents=True, exist_ok=True)
        out_path.write_text(json.dumps(out_metadata, indent=4) + "\n", "utf-8")

    @staticmethod
    def get_secondary_key(primary_key: int, onscreens_final: dict):
        for entry in onscreens_final["Data"]["RootChunk"]["root"]["Data"]["entries"]:
            if int(entry["primaryKey"]) == primary_key:
                return entry["secondaryKey"]

    @staticmethod
    def get_track_metadata(track_event_name: str, cooked_metadata: dict):
        for entry in cooked_metadata["Data"]["RootChunk"]["entries"]:
            if entry["Data"]["$type"] == "audioRadioTracksMetadata":
                for track in entry["Data"]["radioTracks"]:
                    if track["trackEventName"]["$value"] == track_event_name:
                        return track


if __name__ == "__main__":
    mod_dir = Path(__file__).parents[1]
    metadata_path = mod_dir.joinpath(
        "bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\better_vehicle_radio\\data\\metadata.json"
    )
    RadioMetadata.create(mod_dir.joinpath(".tmp"), metadata_path)
