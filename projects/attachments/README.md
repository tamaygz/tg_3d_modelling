# Attachment plates

Interchangeable mounting plates for every project in this repo, from [`lib/attach.scad`](../../lib/README.md#attachment-plates).
Any project with sockets in its back takes any of these plates.

**Print this first:** the test coupon has one socket, so you can check the snap fit on your printer before
printing a whole project. Open `attachments_configurator.html` to pick a type and size and download the STLs.

| Setting | Options |
|---|---|
| `attach_type` | wall, keyhole, skadis, hook, magnet, stand, flat, roof |
| `attach_size` | S 30×30, M 45×40, L 60×50 mm |
| per type | screw and head size, magnet size, hook gap, stand angle and depth, roof reach / angle / flange depth |

How it fits: push the plate straight into the socket until it clicks. To remove it, put a flat screwdriver in the
notch below the plate and lever it out. If it is too stiff or too loose on your printer, change `SNAP_B` (bump
height, default 0.8 mm) in `lib/attach.scad`.

Files: `attachments.scad` (model), `attachments_print/` (coupon upside down, plate), `attachments_configurator.html`,
`attachments_<rev>.zip` (bundle with lib).

Skådis sizes (5 × 15 mm slots, 40 mm pitch, 5 mm board) are community measurements, not published by IKEA.
Check them against your board.

Rebuild and check with `python3 tools/build.py attachments --test` (variants in `tests.txt`).
