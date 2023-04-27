const options = {
    includeScore: false,
    keys: [
        {
            name: "name",
            weight: 0.6
        },
        {
            name: "description",
            weight: 0.2
        },
        {
            name: "tags",
            weight: 0.2
        }
    ],
    threshold: 0.3,
    ignoreLocation: true
}
const fuse = new Fuse(packages, options)
let results

window.addEventListener("DOMContentLoaded", function() {
    results = document.getElementById("search_results")
})

function set_dark_mode() {
    if (window.localStorage.getItem("theme") == "dark")
        document.body.classList.add("dark-theme")
    else {
        document.body.classList.remove("dark-theme")
    }
}

function toggle_dark_mode() {
    if (window.localStorage.getItem("theme") == "dark") {
        window.localStorage.setItem("theme", "light")
    } else {
        window.localStorage.setItem("theme", "dark")
    }
    set_dark_mode()
}

function do_search(input) {
    if (input.length === 0) {
        return
    }

    const result = fuse.search(input)

    for (const item of result) {
        const package = item.item
        const packageHtml = `
            <div class="box box-pkg rounded p-3" stars="">
                <h3 class="lh-1 display-1 mb-2"><a href="/pkg/${package.name}.html">${package.name}</a></h3>
                <p class="mb-0 pb-0" style="height:1.2em;overflow:hidden;">${package.description}</p>
                <ul class="package-box-meta-foot mt-1">
                    <li>
                    <svg width="16" height="16" viewBox="0 0 16 16" style="display:inline-block;vertical-align:text-bottom"><path fill-rule="evenodd" d="M2 2.5A2.5 2.5 0 014.5 0h8.75a.75.75 0 01.75.75v12.5a.75.75 0 01-.75.75h-2.5a.75.75 0 110-1.5h1.75v-2h-8a1 1 0 00-.714 1.7.75.75 0 01-1.072 1.05A2.495 2.495 0 012 11.5v-9zm10.5-1V9h-8c-.356 0-.694.074-1 .208V2.5a1 1 0 011-1h8zM5 12.25v3.25a.25.25 0 00.4.2l1.45-1.087a.25.25 0 01.3 0L8.6 15.7a.25.25 0 00.4-.2v-3.25a.25.25 0 00-.25-.25h-3.5a.25.25 0 00-.25.25z"></path></svg>
                    <a href="${package.url}">Repository</a>
                    </li>
                    <li class="text-gray">
                    <svg width="16" height="16" viewBox="0 0 16 16" style="display:inline-block;vertical-align:text-bottom"><path fill-rule="evenodd" d="M8.75.75a.75.75 0 00-1.5 0V2h-.984c-.305 0-.604.08-.869.23l-1.288.737A.25.25 0 013.984 3H1.75a.75.75 0 000 1.5h.428L.066 9.192a.75.75 0 00.154.838l.53-.53-.53.53v.001l.002.002.002.002.006.006.016.015.045.04a3.514 3.514 0 00.686.45A4.492 4.492 0 003 11c.88 0 1.556-.22 2.023-.454a3.515 3.515 0 00.686-.45l.045-.04.016-.015.006-.006.002-.002.001-.002L5.25 9.5l.53.53a.75.75 0 00.154-.838L3.822 4.5h.162c.305 0 .604-.08.869-.23l1.289-.737a.25.25 0 01.124-.033h.984V13h-2.5a.75.75 0 000 1.5h6.5a.75.75 0 000-1.5h-2.5V3.5h.984a.25.25 0 01.124.033l1.29.736c.264.152.563.231.868.231h.162l-2.112 4.692a.75.75 0 00.154.838l.53-.53-.53.53v.001l.002.002.002.002.006.006.016.015.045.04a3.517 3.517 0 00.686.45A4.492 4.492 0 0013 11c.88 0 1.556-.22 2.023-.454a3.512 3.512 0 00.686-.45l.045-.04.01-.01.006-.005.006-.006.002-.002.001-.002-.529-.531.53.53a.75.75 0 00.154-.838L13.823 4.5h.427a.75.75 0 000-1.5h-2.234a.25.25 0 01-.124-.033l-1.29-.736A1.75 1.75 0 009.735 2H8.75V.75zM1.695 9.227c.285.135.718.273 1.305.273s1.02-.138 1.305-.273L3 6.327l-1.305 2.9zm10 0c.285.135.718.273 1.305.273s1.02-.138 1.305-.273L13 6.327l-1.305 2.9z"></path></svg>
                    ${package.license}
                    </li>
                </ul>
            </div>
        `
        const packageElement = document.createElement("div")
        packageElement.classList.add("col-lg-4", "col-md-6")
        packageElement.innerHTML = packageHtml
        results.appendChild(packageElement)
    }
}

function on_suggest(suggest) {
    results.innerHTML = ""
    document.getElementById("search").value = suggest
    do_search(suggest)
}

let timer = null

function on_search() {
    if (timer) {
        window.clearTimeout(timer)
    }
    timer = window.setTimeout(function() {
        timer = null
        results.innerHTML = ""

        const input = document.getElementById("search").value
        do_search(input)
    }, 500)
}
