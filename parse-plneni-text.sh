#!/usr/bin/bash

data="/home/tereza/plneni.csv"
group_data="/home/tereza/plneni/group_plneni.awk"

s=$(date -Idate)
e=$(date -Idate)

declare -A scale
declare -A big_task
declare -A big_task_dur
only_print=false
with_date=false
automate=false

while getopts "s:e:t:E:v:dapl:" o; do
  case "${o}" in
  s)
    s=$(date -Idate -d "-$OPTARG days")
    ;;
  e)
    e=$(date -Idate -d "-$OPTARG days ")
    ;;
  t)
    t="$OPTARG"
    ;;
  v)
    v="$OPTARG"
    ;;
  E)
    E="$OPTARG"
    ;;
  d)
    with_date=true
    ;;
  a)
    automate=true
    with_date=true
    ;;
  p)
    only_print=true
    ;;
  l)
    limit="$OPTARG"
    ;;
  *) ;;

  esac
done
shift $((OPTIND - 1))

wpf() {
escaped="$(echo "$1" | sed 's/[^[:print:]]//g')"
escaped="$1"
echo $escaped
  xclip -se c <<< "$escaped"

  if  $automate ; then
    xdotool mousemove 1146 440
    sleep 1
    if [[ $2 -gt 0 ]]; then
    printf -v myString '%*s' "$2"
    tab=$(printf '%s' "${myString// /Tab }")
    xdotool key $tab
    sleep 1
    fi
    xdotool key ctrl+a ctrl+v
    sleep 2
  else
    python3 /home/tereza/plneni/listener.py v 2>/dev/null
  fi

}
process() {

  if  $automate ; then
    xdotool mousemove --sync 78 629
    xdotool click 1
    sleep 1.5
  fi

  dat="$1"
  line="$(echo "$2" | sed -z 's;\s*$;;g')"
  dur=$3

  mr=" · Merge requests"
  is=" · Issue"
  an="\/ "
  gi=" · GitLab"
  now=$(date -Idate)

  getProject() {
    echo "$line" | grep -o -P "(?<=$an)[^/]*(?=$gi)"
  }

  if [[ $(grep -e "$mr" <<<"$line") ]]; then
    project="$(getProject)"
    task="Code review - $(grep -o -P "^.*(?=$mr)" <<<"$line")"
    task=$(echo "$task" | sed "s;(!;($project!;")
    issue="Code review"
  elif [[ $(grep -e "$is" <<<"$line") ]]; then
    issue=$(grep -o -P "^.*(?=$is)" <<<"$line")
    project="$(getProject)"
    task=$(echo "$issue" | sed "s;(#;($project#;")
  else
    project=projectNotFound
    issue=$line
    task=$issue
  fi
  time=$dur
  echo "$dat" "$time" "$task" "$project"
  if [[ -n ${scale[$dat]} ]]; then
    new_time=$(echo "scale=4;$dur*${scale[$day]}" | bc | awk '{printf "%.4f", $0}')
    echo "New time: $new_time"
    time=$new_time
  fi

$only_print && return
  if [[ -n $limit ]]; then
    if (( $(echo "$time < $limit" | bc -l) )); then
      big_task[$dat]+="${task}
"
      big_task_dur[$dat]=$(echo "scale=4;$time+${big_task_dur[$dat]:=0}" | bc)
      return
    fi
  fi
  time=$(echo $time | tr "." ",")
  if [[ -n $with_date ]]; then
    wpf "$(date -d "$(echo $dat | sed 's/[^[:print:]]//g')" "+%d.%m.%Y")"
  fi
  wpf "$time" 2
  wpf "$task" 12
  if $automate ; then
    sleep 0.5
    xdotool key BackSpace Tab
    # rr=$(python3 /home/tereza/plneni/listener.py ř 2>/dev/null)
    # [[ $rr == "é" ]] && xdotool key Tab Return
    sleep 0.5
    xdotool key Return
    sleep 0.5
#    read -p "Press enter to continue" <&1
  fi
}

dat=$($group_data -v "s=$s" -v "e=$e" -v "t=$t" -v "E=$E" -v "v=$v" $data | sort -t ";" -k 1 -n)
prod=$($group_data -v "s=$s" -v "e=$e" -v "t=a" $data | sort -t ";" -k 1 -n)

echo "$dat"
echo
echo "$prod"
echo

shopt -s lastpipe
echo "$prod" | while read -r x; do
  day="$(cut -d ";" -f1 <<<"$x")"
  pt="$(cut -d ";" -f3 <<<"$x")"
  echo $x
  echo "Productive time: $pt"
  read -p "Total time: " tt <&1
  if [[ -n $tt ]]; then
    pp=$(echo "scale=4; ($pt/$tt)*100" | bc)
    echo "Productivity: $pp%"
    read -p "Desired productivity: " p <&1
    [[ -n $p ]] && scale[$day]=$(echo "scale=4;($tt*($p/100))/$pt" | bc) && echo "Scale: ${scale[$day]}"
  fi
done

$automate && read -p "Press whatever to start automatic plnění úkolů. " <&1
echo
echo "$dat" | while read -r x; do
  process "$(cut -d ";" -f1 <<<"$x")" "$(cut -d ";" -f2 <<<"$x")" "$(cut -d ";" -f3 <<<"$x")"
done
echo
for x in "${!big_task_dur[@]}"; do
  process "$x" "${big_task[$x]}" "$(echo ${big_task_dur[$x]} | awk '{printf "%.4f", $0}')"
done


