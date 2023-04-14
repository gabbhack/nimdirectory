import std/[
  os,
  strformat,
  osproc,
  options,
  strutils,
  httpclient,
  htmlparser,
  xmltree,
  strtabs
]

import packages/docutils/highlite


import
  deser,
  deser_json,
  markdown


type
  PackageKind* = enum
    Usual
    Alias

  Package* = object
    name*: string
    readme*: Option[string]
    case kind* {.untagged.}: PackageKind
    of Alias:
      alias*: string
    of Usual:
      url*: Option[string]
      installMethod* {.renamed: "method".}: Option[string]
      tags* {.defaultValue.}: seq[string]
      description*: Option[string]
      license*: Option[string]
      web*: Option[string]
      docs*: Option[string]


makeDeserializable(Package, public=true)

const
  readmeNames = [
    "README.md",
    "readme.md",
    "README",
    "readme"
  ]


proc getPackagesJson*(url: string): string =
  let client = newHttpClient()
  result = client.getContent(url)

proc parsePackagesJson*(content: string): seq[Package] =
  result = typeof(result).fromJson(content)

proc clone*(url: string): Option[string] =
  let (output, exitCode) = execCmdEx(fmt"git clone {url}")

  if exitCode == 0:
    some url.strip(false, true, {'/'}).rsplit('/', maxsplit=2)[^1]
  else:
    echo fmt"Non-zero code from git. Output: `{output}`"
    none string

proc getReadme*(package: string): Option[string] =
  let packageDir = getCurrentDir() / package

  if dirExists(packageDir):
    for name in readmeNames:
      if fileExists(packageDir / name):
        result = some readFile(packageDir / name)
        break

proc highlightSyntax(source: string, lang: SourceLanguage): string =
  #[
MIT License

Copyright (c) 2022 Crystal Melting Dot

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
  ]#
  
  result = ""
  var tokenizer: GeneralTokenizer
  tokenizer.initGeneralTokenizer(source)

  template getSub(tk: GeneralTokenizer): string =
    substr(source, tokenizer.start, tokenizer.length + tokenizer.start - 1).multiReplace(
      ("<", "&lt;"),
      (">", "&gt;"),
      ("\"", "&quot;"),
      ("'", "&apos;"),
      ("&", "&amp;")
    )

  template mark(tk: GeneralTokenizer, cls: string): untyped =
    "<span class=\"" & cls & "\">" &
    tk.getSub() &
    "</span>"
  result.add "<div class=\"line\"><div class=\"line-content\">"
  while true:
    tokenizer.getNextToken(lang)

    case tokenizer.kind
    of gtEof: break
    of gtKeyword, gtProgram:
      result.add tokenizer.mark "kwd"
    of gtDecNumber, gtHexNumber, gtBinNumber, gtFloatNumber:
      result.add tokenizer.mark "num"
    of gtStringLit:
      result.add tokenizer.mark "str"
    of gtIdentifier:
      result.add tokenizer.mark "ide"
    of gtComment:
      result.add tokenizer.mark "com"
    of gtProgramOutput:
      result.add tokenizer.mark "out"
    of gtOperator:
      result.add tokenizer.mark "op"
    of gtWhitespace:
      for i in substr(source, tokenizer.start, tokenizer.length + tokenizer.start - 1):
        if i == '\n':
          result.add "</div></div><div class=\"line\"><div class=\"line-content\">"
        else:
          result.add i
    else:
      result.add substr(source, tokenizer.start, tokenizer.length + tokenizer.start - 1)
  result.add "</div></div>"

proc highlite*(parsed: var XmlNode) =
  #[
MIT License

Copyright (c) 2022 Crystal Melting Dot

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
  ]#
  for element in parsed.mitems:
    if element.kind != xnElement:
      continue
    case element.tag:
    of "pre":
      for code in element.mitems:
        if code.kind != xnElement: continue
        if code.tag != "code": continue
        if code.attrs == nil:
          code.attrs = newStringTable(modeCaseInsensitive)
        let lang = block:
          var s = code.attrs.getOrDefault("class", "")
          s.removePrefix("language-")

          getSourceLanguage(s)
        
        case lang
        of langNone:
          continue
        else:
          let source = code.innerText
          code.clear
          code.add newVerbatimText(highlightSyntax(source.strip(), lang))
    else:
      discard

proc getHtmlReadme*(package: string): Option[string] =
  let readme = getReadme(package)

  if readme.isSome:
    var readme = parseHtml(markdown(readme.get(), initGfmConfig()))
    for img in readme.findAll("img"):
      img.attrs["style"] = "max-width: 100%;"
    readme.highlite
    some $readme
  else:
    none string

proc processPackage*(package: var Package) =
  if package.installMethod.isSome:
    if package.installMethod.get() == "git" and package.url.isSome:
      let directory = clone(package.url.get())
      if directory.isSome:
        if directory.get().len != 0:
          package.readme = getHtmlReadme(directory.get())

          let dirToRemove = getCurrentDir() / directory.get()
          echo fmt"Removing dir `{dirToRemove}`"
          removeDir(dirToRemove)
        else:
          echo fmt"Package has invalid url: {package.url.get()}"
    else:
      echo "Package has non git install method or doesnt have url"
  else:
    echo "Package doesnt have install method"
