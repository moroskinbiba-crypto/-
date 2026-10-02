# TOTK Explorer v3.2 — Assisted Coordinate Discovery

Target: Tears of the Kingdom 1.4.3 / TID `0100F2C0115B6000` / BID `277178B7DBA1B6D4`.

## Important change

This version does **not** pretend that a blind float scan can reliably identify Link's position.
It uses a one-time assisted calibration:

1. Open TOTK and note the current X Y Z shown by the in-game mini-map.
2. Create `sd:/switch/totk_explorer/calibration.txt` with one line:

```text
X Y Z
```

Optional tolerance:

```text
X Y Z 1.0
```

3. Open TOTK Explorer → Auto Discovery → Start.
4. Let the memory scan finish.
5. Walk Link and press X.
6. Jump/change elevation and press X.
7. The best remaining candidate is saved to `profile.txt`.

After that, Explorer reads the saved profile and exposes live X/Y/Z to Map and Nearby.

## Why this is more reliable

The initial search is constrained to the actual coordinate triplet the game is showing, instead of treating every plausible float triple in the heap as a coordinate candidate. Movement and elevation checks provide two more filters.

## Files

```text
sd:/switch/.overlays/TOTK-Explorer-v3.ovl
sd:/switch/totk_explorer/points.csv
sd:/switch/totk_explorer/calibration.txt
sd:/switch/totk_explorer/profile.txt   # created after discovery
```

`points.csv` is read-only map data. `profile.txt` stores the discovered heap offset and last coordinates.

## Current limits

- Coordinate discovery is version-specific and must be revalidated if the game Build ID changes.
- The overlay does not write game memory.
- Region names and completion flags are separate future data providers.
