#!/usr/bin/awk -f

BEGIN {FS = ";"}

{
    if (!($2 != "s" && split($1,a,"T") && a[1] >= s && a[1] <= e)) {
        next
    }
    d = a[1]
    if (length(E) > 0 && $3 !~ E) {
        next
    }
    if (length(v) > 0 && $3 ~ v) {
        next
    }
}

{switch (t) {
    case "a":
        r[d,";"]+=$4
        break
    case "i":
        r[";",$3]+=$4
        break
    default:
        r[d,";", $3]+=$4
        break
}}

END {
    y="\034$"
    for (comb in r) {
        printf("%s;%.4f\n",comb, r[comb])
    }
}
