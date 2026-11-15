#!/usr/bin/env python3
"""Write the release notes for the web configurators (used by .github/workflows/configurators.yml).

    python3 tools/release_notes.py build/pages-src/projects.json --pages URL --repo-url URL --ref SHA > notes.md

projects.json comes from tools/make_pages.py. Prints Markdown: per project a link to its configurator on
GitHub Pages and links to its source (model, README, print files), plus the shared library and the commit.
"""
import argparse, json


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("projects_json")
    ap.add_argument("--pages", required=True, help="GitHub Pages base URL")
    ap.add_argument("--repo-url", required=True)
    ap.add_argument("--ref", required=True, help="commit the links point to")
    a = ap.parse_args()
    pages = a.pages.rstrip("/")
    tree = f"{a.repo_url}/tree/{a.ref}"
    blob = f"{a.repo_url}/blob/{a.ref}"
    out = ["Browser configurators for every project: change the parameters, preview in colour and export "
           "STL/3MF for a single part or the whole assembly. OpenSCAD runs in the browser; the pages contain "
           "the models, the shared library and the fonts.", "",
           "| Project | Configurator | Source |", "|---|---|---|"]
    for p in json.load(open(a.projects_json)):
        n = p["name"]
        src = (f"[model]({blob}/projects/{n}/{n}.scad) · [README]({blob}/projects/{n}/README.md) · "
               f"[print files]({tree}/projects/{n}/{n}_print) · [folder]({tree}/projects/{n})")
        out.append(f"| **{p['title']}** | [open configurator]({pages}/{p['page']}) | {src} |")
    out += ["", f"All pages: {pages}/", "",
            f"Shared library: [lib/]({tree}/lib) · built from commit [{a.ref[:7]}]({a.repo_url}/commit/{a.ref}).", "",
            "`configurators-site.zip` is an offline copy of the site; serve it with any static web server "
            "(for example `python3 -m http.server` in the unpacked folder), since browsers block the "
            "OpenSCAD worker on `file://` pages."]
    print("\n".join(out))


if __name__ == "__main__":
    main()
