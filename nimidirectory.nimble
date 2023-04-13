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

task frontend, "Build frontend":
  exec "nim js -o:public/js/app.js -d:release -d:danger --gc:arc --panics:on src/app"
