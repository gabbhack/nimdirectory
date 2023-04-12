import nimja/parser


proc homePage(): string =
  compileTemplateFile(getScriptDir() / "templates" / "home.nimja")

proc main() =
  writeFile(getCurrentDir() / "public" / "index.html", homePage())

when isMainModule:
  main()
