# TaskProductivityTracking
This project helps with task productivity time tracking. It creates a csv file with the columns: `date;taskType(s|e|u);duration`. Parses the data and optionally passes them to another time tracking program or copies them to the clipboard.<br>
<br>
To start or end a task run script `plneni.sh` and input one of the following options to the prompt:
- `w` - takes title of the current focused open window and starts a new task with this title - if previous task was type start - automatically ends it with type `u`
- `p` - shows a list of previous tasks with option to chose one and starts time tracking on this task - if previous task was type start - automatically ends it with type `u`
- nothing - toggle task, if previous task was start, then adds end of the same task (type e) and otherwise (type s)<br>

To parse existing data and continualy copy then to the clipboard run script `parse-plneni-text.sh` with the following optional options:
- `s number` - specify start day in the history ex. `0` - today, `1` - yesterday
- `e number` - specify end day in the history ex. `0` - today, `1` - yesterday
- `l number` - ignore tasks shorter than limit - one big task is created at the end from these tasks
- `E regex` - parse only tasks matching this regex
- `v regex` - do not parse tasks matching this regex 
- `p` - only print parsed data without any automation and copying
- `a` - pass parsed data to another program by simulating keyboard presses and mouse clicks - this option is propably suitable only for my system
- `d` - if `p` was not passed - copy also the task date to the clipboard

<br>
Feel free to submit any feature requests or questions.
