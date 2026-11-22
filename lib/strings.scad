// Reading numbers and lists out of text settings, so a Customizer field can hold a whole layout.
// Use:  use <../../lib/strings.scad>
//
// OpenSCAD has no string slicing or number parsing; these work with ord()/chr() and plain list comprehensions,
// the same in OpenSCAD 2021.01 and in the browser engine.
//
//   str_nums("33, 33 ,33")                 -> [33, 33, 33]       (spaces, commas, semicolons and % are separators)
//   str_groups("33,33,33 / 50,50 / 100")   -> [[33, 33, 33], [50, 50], [100]]     ("/" or "|" between groups)
//   str_num("-12.5")                       -> -12.5              (undef if it is not a number)

// the part of s from index a up to (not including) b
function str_sub(s, a, b) = b <= a ? "" : chr([for (i=[max(0, a):1:min(len(s), b) - 1]) ord(s[i])]);
// s cut at every character that appears in seps (empty pieces are kept)
function str_split(s, seps=",") = let(
    cut = [for (i=[0:1:len(s) - 1]) if (len(search(s[i], seps)) > 0) i],
    b = concat([-1], cut, [len(s)]))
    [for (k=[0:1:len(b) - 2]) str_sub(s, b[k] + 1, b[k + 1])];
// s without leading and trailing spaces
function str_trim(s) = let(k = [for (i=[0:1:len(s) - 1]) if (s[i] != " " && s[i] != "\t") i])
    len(k) == 0 ? "" : str_sub(s, k[0], k[len(k) - 1] + 1);
function _str_digit(c) = let(o = ord(c)) o >= 48 && o <= 57 ? o - 48 : undef;
// a decimal number ("12", "-3.5", "+0.25", "40%"), or undef
function str_num(s) = let(
    t = str_trim(s), c = [for (ch=t) if (ch != "%") ch],
    neg = len(c) > 0 && c[0] == "-", sg = len(c) > 0 && (c[0] == "-" || c[0] == "+") ? 1 : 0,
    d = [for (i=[sg:1:len(c) - 1]) c[i]],
    dots = [for (i=[0:1:len(d) - 1]) if (d[i] == ".") i],
    p = len(dots) > 0 ? dots[0] : len(d),
    v = [for (ch=d) if (ch != ".") _str_digit(ch)],
    ok = len(v) > 0 && len(dots) <= 1 && len([for (x=v) if (is_undef(x)) 1]) == 0)
    !ok ? undef : (neg ? -1 : 1)*(
        (p == 0 ? 0 : [for (i=[0:1:p - 1]) v[i]*pow(10, p - 1 - i)]*[for (i=[0:1:p - 1]) 1]) +
        (len(v) - p <= 0 ? 0 : [for (j=[p:1:len(v) - 1]) v[j]*pow(10, p - 1 - j)]*[for (j=[p:1:len(v) - 1]) 1]));
// all numbers in s (anything that is not a number is skipped)
function str_nums(s, seps=", ;\t") = [for (w=str_split(s, seps)) let(x = str_num(w)) if (!is_undef(x)) x];
// groups of numbers: "33,33,33 / 50,50 / 100"; empty groups are skipped
function str_groups(s, gseps="/|", seps=", ;\t") = [for (g=str_split(s, gseps)) let(n = str_nums(g, seps)) if (len(n) > 0) n];
