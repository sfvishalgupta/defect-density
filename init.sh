path=$(pwd)
cd $path/$1 && git stash -u -q && git checkout $2 -q && git pull origin $2 -q 
echo $1
for week in {1..52}; do
    if [[ $week -lt $(date +%V) ]]; then
        weeknum=$((week+1))
        if [[ $week -lt 9 ]]; then
            weeknum="0$weeknum"
        fi
        sum=0
        from=$(python3 -c "import datetime;year = datetime.date.today().year;first_day = datetime.date(year, 1, 1);first_monday = first_day + datetime.timedelta(days=(7 - first_day.weekday()) % 7);start_date = first_monday + datetime.timedelta(days=($week-1)*7);print(start_date)")
        to=$(python3 -c "import datetime;year = datetime.date.today().year;first_day = datetime.date(year, 1, 1);first_monday = first_day + datetime.timedelta(days=(7 - first_day.weekday()) % 7);start_date = first_monday + datetime.timedelta(days=($week-1)*7);end_date = start_date + datetime.timedelta(days=6);print(end_date)")
        initcommit=$(cd $path/$1 && git rev-list --since="$from" --reverse $2 | head -1 )
        lastcommit=$(cd $path/$1 && git rev-list -n 1 --before="$to" $2)
        if [[ -n "$initcommit" && -n "$lastcommit" && "$initcommit" != "$lastcommit" ]]; then
            cd $path/$1 && npx cloc --git-diff-rel $initcommit $lastcommit --diff-timeout 30 --ignore-whitespace --exclude-lang JSON,Markdown --out=tmp.json --quiet --json
            if [ -f "$path/$1/tmp.json" ]; then
                sum=$((sum+ $(jq '.SUM.modified.code' $path/$1/tmp.json)))
                sum=$((sum+ $(jq '.SUM.added.code' $path/$1/tmp.json)))
                sum=$((sum+ $(jq '.SUM.removed.code' $path/$1/tmp.json)))
            fi
        fi
        echo "Week$weeknum ($from == $to) Total:- $sum"
    fi
done
# bash dd.sh bm-saas-control-plane-api main