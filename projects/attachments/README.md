# Attachment plates

Interchangeable mounting plates for every project in this repo, from [`lib/attach.scad`](../../lib/README.md#attachment-plates).
Any project with sockets in its back takes any of these plates.

**Print this first:** the test coupon has one socket, so you can check the slide fit on your printer before
printing a whole project. Open `attachments_configurator.html` to pick a type and size and download the STLs.

| Setting | Options |
|---|---|
| `attach_type` | wall, keyhole, skadis, hook, magnet, stand, flat |
| `attach_size` | S 30×30, M 45×40, L 60×50 mm |
| per type | screw and head size, magnet size, hook gap, stand angle and depth |

How it locks: put the plate's tabs into the socket's lower windows, then slide it up by a quarter of its length.
The tabs go under the lip. Push the key into the gap below. To remove, pry the key out and slide the plate back down.

Files: `attachments.scad` (model), `attachments_print/` (coupon upside down, plate, key), `attachments_configurator.html`,
`attachments_9eee3bd.zip` (bundle with lib).

Skådis sizes (5 × 15 mm slots, 40 mm pitch, 5 mm board) are community measurements, not published by IKEA.
Check them against your board.
