#!/bin/bash

git fetch origin --tags > /dev/null

LAST_TAG=`git describe --abbrev=0 --tags`

COMMITS=`git log --pretty=oneline --reverse $LAST_TAG..origin/master | grep "Merge pull" | cut -c 1-7`

echo "# Changelog"
echo "\n"
echo "| PR   | Description | JIRA    |"
echo "| ---: | :---------- | :------ |"

while read -r hash; do

    msg=`git rev-list --format=%B --max-count=1 $hash | sed -n 4p`
    jira=`git rev-list --format=%B --max-count=2 $hash | egrep -o 'JIRA [A-Z]{3,6}-\d+$'`

    if [ -z "$jira" ]
    then
        jira='n/a'
    else
        ticket_number=${jira#"JIRA "}
        jira="[$ticket_number](https://talkdesk.atlassian.net/browse/$ticket_number)"
    fi

    pr_number=`git rev-list --format=%B --max-count=1 $hash | sed -n 2p | egrep -o '#\d+'`

    echo "| $pr_number | $msg | $jira |"

done <<< "$COMMITS"

