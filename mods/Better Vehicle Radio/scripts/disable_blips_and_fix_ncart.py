import sys
from pathlib import Path

from .disable_blips import DisableBlips
from .fix_ncart import FixNCART

sys.path.append(Path(__file__).parents[3].__str__())
import Mod


class DisableBlipsAndFixNCART:
    __mod_dir = Path(__file__).parents[1]
    __mod_name = Mod.to_snake_case(__mod_dir.name)
    __file_name = Path(__file__).stem

    def __init__(self, cwd: Path) -> None:
        self.__cwd = cwd
        self.__dist_dir = self.__cwd.joinpath("dist", "_".join([self.__mod_name, self.__file_name]))

    def pack(self) -> tuple[Path, Path]:
        metadata_path = DisableBlips(self.__cwd, self.__dist_dir).create().get_out_metadata_path()
        out_dirs = FixNCART(self.__cwd, metadata_path, self.__dist_dir).create().pack()

        return out_dirs
