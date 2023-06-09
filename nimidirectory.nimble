# Package

version       = "0.1.0"
author        = "Gabben"
description   = "A new awesome nimble package directory"
license       = "GPLv3"
srcDir        = "src"
bin           = @["nimidirectory"]


# Dependencies

requires "nim >= 1.6.0"
requires "deser_json == 0.2.0"
requires "nimja == 0.8.7"
requires "markdown == 0.8.7"

task make, "Do the job":
  exec "nim r -d:ssl src/nimidirectory"
