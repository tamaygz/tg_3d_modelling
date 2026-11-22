# Marketing

Pictures and texts for sharing the project (MakerWorld, Printables, social posts).

- [`makerworld.md`](makerworld.md): the MakerWorld listing plan: research on similar models, title, tags,
  picture order, a ready-to-paste description, print profiles, licence and a launch checklist.
- [`showcase.3mf`](showcase.3mf): a Bambu Studio project with five plates (organizers, holders, attachment
  plates, pattern samples), built by `python3 tools/make_showcase_3mf.py`; open it in Bambu Studio, pick printer
  and filament, save: that is the print profile MakerWorld asks for.
- [`images/`](images): 1600 × 1200 (4:3) pictures, rendered from the current models by
  `python3 tools/make_marketing.py` (all) or `python3 tools/make_marketing.py <page>`
  (cover, evolution, compartments, patterns, attachments, configurator, family, showcase). Re-run it after a visible
  change to a model; the configurator page also needs Playwright.

| | |
|---|---|
| <img src="images/01_cover.png" alt="cover"> | <img src="images/02_evolution.png" alt="evolution"> |
| <img src="images/03_compartments.png" alt="compartments"> | <img src="images/04_patterns.png" alt="patterns"> |
| <img src="images/05_attachments.png" alt="attachments"> | <img src="images/06_configurator.png" alt="configurator"> |
| <img src="images/07_family.png" alt="family"> | <img src="images/08_showcase.png" alt="showcase plates"> |

Licence of everything here: [CC BY-NC-SA 4.0](../LICENSE).
