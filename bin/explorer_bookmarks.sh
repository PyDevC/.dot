#!/usr/bin/env bash

b_dir=("Documents" "Downloads" "Pictures" "Videos" "personal" "work")
bookmark_path="$HOME/.config/gtk-3.0/bookmarks"

echo "cleaning bookmarks..."
echo "" > $bookmark_path

for dir in ${b_dir[@]}; do
    bookmark="file:///home/$USER/$dir"
    echo "$bookmark"
    echo $bookmark >> $bookmark_path
done

echo "created bookmarks"
