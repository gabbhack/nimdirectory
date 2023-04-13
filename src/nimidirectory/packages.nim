import std/[
  options,
  httpclient,
  sequtils
]

import deser, deser_json


type
  PackageKind = enum
    Usual
    Alias

  Package* = object
    name: string
    case kind {.untagged.}: PackageKind
    of Alias:
      alias: string
    of Usual:
      url: Option[string]
      installMethod {.renamed: "method".}: Option[string]
      tags {.defaultValue.}: seq[string]
      description: Option[string]
      license: Option[string]
      web: Option[string]
      docs: Option[string]


makeDeserializable(Package, public=true)


proc getPackages*(): seq[Package] =
  let
    client = newHttpClient()
    content = client.getContent("https://raw.githubusercontent.com/nim-lang/packages/master/packages.json")

  result = seq[Package].fromJson(content)
