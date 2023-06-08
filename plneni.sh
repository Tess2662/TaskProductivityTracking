#!/usr/bin/bash
#
export PATH=$PATH:/home/tereza/.local/bin
f="/home/tereza/plneni.csv"
set -e
last_line=$(cat $f | awk 'END{print}')
res=$(zenity --title "Plnění úkolů" --entry --text "Poslední task:\n$last_line")
set +e
old_date=$(echo "$last_line" | cut -d ";" -f1)
typ=$(echo "$last_line" | cut -d ";" -f2)
name=$(echo "$last_line" | cut -d ";" -f3)
now=$(date -Iseconds)
diff=$(echo "scale=4; $(($(date -d $now +%s)-$(date -d $old_date +%s)))/3600" | bc | awk '{printf "%.4f", $0}')
set -e
if [[ $res == "l" ]]; then
        res=$(zenity --title "Přehled úkolů" --entry --text "$(tail -n 30 $f)")
        exit 0
fi
# will not be toggle (only new task, yes we could add notes to tasks but not now)
if [[ -n $res ]]; then
        if [[ $typ == "s" ]]; then
                # previous task ended with unknown reason
                echo "$now;u;$name;$diff" >> $f
                diff=0
        fi
        # next task will be starting task - not toggle
        typ="s"
fi
# this could be else after above condition
if [[ -z "$res" ]]; then
        if [[ $typ = "s" ]]; then
                typ="e"
        else
                typ="s"
        fi
# window name
elif [[ $res == "w" ]]; then
        # wait for zenity to hide
        sleep 0.05
        name=$(xdotool getwindowfocus getwindowname)
# previous tasks
elif [[ $res == "p" ]]; then
        # tasky=$(cat $f | awk -F";" '{print $3}' | sort | uniq | tail -n 20 | awk '{print NR" "$0}')
        tasky=$(cat $f | awk -F";" '!seen[$3]++' | awk -F ";" '{print $3}')
        echo "$tasky"
        # res=$(zenity --title  "Plnění úkolů" --entry --text "Poslední tasky:\n$tasky")
        res=$(echo "$tasky" | rofi -dmenu -matching fuzzy -i)
        # task=$(echo "$tasky" | grep -E '^\s*'$res | cut -d " " -f2-)
        # name=$task
        name=$res
else
        name=$res
fi
echo "$now;$typ;$name;$diff" >> $f




