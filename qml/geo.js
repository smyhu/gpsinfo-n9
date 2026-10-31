// Formatting helpers for coordinates and units.
// Copyright (c) 2026 smyhu. MIT License.
.pragma library

function dms(v) {
    var a = Math.abs(v)
    var d = Math.floor(a)
    var mf = (a - d) * 60
    var m = Math.floor(mf)
    var s = (mf - m) * 60
    if (s >= 59.95) { s = 0; m += 1 }
    if (m >= 60) { m = 0; d += 1 }
    return d + "° " + m + "′ " + s.toFixed(1) + "″"
}

// hemisphere letters are passed in (translated by the caller)
function coord(v, notation, pos, neg) {
    if (notation == "decimal")
        return v.toFixed(6) + "°"
    return dms(v) + " " + (v < 0 ? neg : pos)
}

function plain(v) { return v.toFixed(6) }

// metres between two points (small distances, equirectangular)
function dx(lon, lon0, lat0) { return (lon - lon0) * 111320 * Math.cos(lat0 * Math.PI / 180) }
function dy(lat, lat0) { return (lat - lat0) * 110540 }

function length(m, units) {
    if (units == "imperial") return (m * 3.28084).toFixed(m * 3.28084 < 100 ? 1 : 0) + " ft"
    return m.toFixed(m < 100 ? 1 : 0) + " m"
}
