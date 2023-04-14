import std/[
  strformat
]

import nimja/parser

import nimidirectory/packages

const
  PackagesURL = "https://raw.githubusercontent.com/nim-lang/packages/master/packages.json"


proc homePage(): string =
  compileTemplateFile(getScriptDir() / "templates" / "home.nimja")

proc main() =
  let
    packagesJson = getPackagesJson(PackagesURL)
    # packages = parsePackagesJson(packagesJson)

  # Write json to file for js application
  let
    jsContent = readFile(getCurrentDir() / "public" / "js" / "app.js")
    patchedJs = fmt"const packages = {packagesJson}{jsContent}"
  writeFile(getCurrentDir() / "public" / "js" / "app.js", patchedJs)
  writeFile(getCurrentDir() / "public" / "index.html", homePage())

when isMainModule: 
  main()
