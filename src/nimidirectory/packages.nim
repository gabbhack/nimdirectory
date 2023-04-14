import std/[
  options,
  httpclient
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


proc getPackagesJson*(url: string): string =
  let client = newHttpClient()
  result = client.getContent(url)

proc parsePackagesJson*(content: string): seq[Package] =
  result = typeof(result).fromJson(content)
