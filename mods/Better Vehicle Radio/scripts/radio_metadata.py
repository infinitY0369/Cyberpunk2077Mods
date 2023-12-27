import json
import sys
from pathlib import Path

sys.path.append(Path(__file__).parents[3].__str__())
import Mod


class RadioMetadata:
    __STATION_MAP = [
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

    def __init__(self, out_path: Path, cwd: Path, metadata: dict | None = None) -> None:
        self.__out_path = out_path
        self.__cwd = cwd
        self.__cooked_metadata = metadata or self.__get_cooked_metadata()
        self.__onscreens_final = self.__get_onscreens_final()

    def create(self):
        out_metadata = {}
        out_metadata["radioStations"] = []

        for station in self.__STATION_MAP:
            station_primary_key = station["primaryKey"]
            station_secondary_key = self.__get_secondary_key(station_primary_key)
            station_event_name = station["evt"]

            station_data = {
                "primaryKey": station_primary_key,
                "secondaryKey": station_secondary_key,
                "stationEventName": station_event_name,
                "tracks": [],
            }

            if station_event_name == "radio_station_05_pop":
                station_event_name = station_event_name + "_completed_sq017"

            for entry in self.__cooked_metadata["Data"]["RootChunk"]["entries"]:
                if entry["Data"]["$type"] != "audioRadioStationMetadata":
                    continue

                if entry["Data"]["name"]["$value"] != station_event_name:
                    continue

                for track in entry["Data"]["tracks"]:
                    track_event_name = track["$value"]

                    track_metadata = self.__get_track_metadata(track_event_name)

                    track_is_streaming_friendly = track_metadata["isStreamingFriendly"]
                    track_primary_key = int(track_metadata["primaryLocKey"])
                    track_secondary_key = self.__get_secondary_key(track_primary_key)

                    track_data = {
                        "isStreamingFriendly": track_is_streaming_friendly,
                        "primaryKey": track_primary_key,
                        "secondaryKey": track_secondary_key,
                        "trackEventName": track_event_name,
                    }

                    station_data["tracks"].append(track_data)

            out_metadata["radioStations"].append(station_data)

        self.__out_path.parent.mkdir(parents=True, exist_ok=True)
        self.__out_path.write_text(json.dumps(out_metadata, indent=4) + "\n", "utf-8")

    def __get_cooked_metadata(self) -> dict:
        raw_path = Path("base\\sound\\metadata\\cooked_metadata.audio_metadata")
        cooked_metadata = self.__get_serialized_data(raw_path)

        return cooked_metadata

    def __get_onscreens_final(self) -> dict:
        raw_path = Path("base\\localization\\en-us\\onscreens\\onscreens_final.json")
        onscreens_final = self.__get_serialized_data(raw_path)

        return onscreens_final

    def __get_serialized_data(self, raw_path: Path):
        archive_dir = self.__cwd.joinpath("archive")
        raw_file_path = Mod.Archive.extract_raw_file(raw_path, archive_dir, self.__cwd)

        raw_dir = self.__cwd.joinpath("raw")
        serialized_file_path = Mod.Archive.serialize_cr2w(raw_file_path, raw_dir.joinpath(raw_file_path.parent.relative_to(archive_dir)), self.__cwd)

        serialized_data = json.loads(serialized_file_path.read_text("utf-8"))

        return serialized_data

    def __get_secondary_key(self, primary_key: int) -> str:
        for entry in self.__onscreens_final["Data"]["RootChunk"]["root"]["Data"]["entries"]:
            if int(entry["primaryKey"]) != primary_key:
                continue

            return entry["secondaryKey"]

        raise ValueError()

    def __get_track_metadata(self, track_event_name: str) -> dict:
        for entry in self.__cooked_metadata["Data"]["RootChunk"]["entries"]:
            if entry["Data"]["$type"] != "audioRadioTracksMetadata":
                continue

            for track in entry["Data"]["radioTracks"]:
                if track["trackEventName"]["$value"] != track_event_name:
                    continue

                return track

        raise ValueError()


if __name__ == "__main__":
    mod_root_dir = Path(__file__).parents[1]
    metadata_path = mod_root_dir.joinpath("bin\\x64\\plugins\\cyber_engine_tweaks\\mods\\better_vehicle_radio\\data\\metadata.json")

    RadioMetadata(metadata_path, mod_root_dir.joinpath(".tmp")).create()
