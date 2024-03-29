import std/[
  strformat,
  times,
  options,
  os
]

import nimja/parser

import nimidirectory/packages

const
  packagesURL = "https://raw.githubusercontent.com/nim-lang/packages/master/packages.json"

let
  buildTime = $now().utc

proc homePage(): string =
  compileTemplateFile(getScriptDir() / "templates" / "home.nimja")

proc aboutPage(): string =
  compileTemplateFile(getScriptDir() / "templates" / "about.nimja")

proc packagePage(package: Package): string =
  compileTemplateFile(getScriptDir() / "templates" / "package.nimja")

proc main() =
  let
    packagesJson = getPackagesJson(packagesURL)
    jsContent = readFile(getCurrentDir() / "public" / "js" / "app.js")
    patchedJs = &"const packages = {packagesJson}\n{jsContent}"
    publicDir = getCurrentDir() / "public" 
    packageDir = getCurrentDir() / "public" / "pkg"

  var packages = parsePackagesJson(packagesJson)

  writeFile(publicDir / "js" / "app.js", patchedJs)
  writeFile(publicDir / "index.html", homePage())
  writeFile(publicDir / "about.html", aboutPage())

  putEnv("GIT_TERMINAL_PROMPT", "0")

  createDir(publicDir / "pkg")

  for package in packages.mitems:
    if package.kind != Alias:
      echo fmt"Processing `{package.name}`..."
      processPackage(package)
      writeFile(packageDir / package.name & ".html", packagePage(package))

when isMainModule:
  main()
