import std/dom


proc set_dark_mode() {.exportc.} =
  if window.localStorage.getItem("theme") == "dark":
    document.body.classList.add("dark-theme")
  else:
    document.body.classList.remove("dark-theme")

proc toggle_dark_mode() {.exportc.} =
  if window.localStorage.getItem("theme") == "dark":
    window.localStorage.setItem("theme", "light")
  else:
    window.localStorage.setItem("theme", "dark")

  setDarkMode()
