#!/bin/sh
python aspiro.py $1

destination=${2:-.}

wget -c -i dlList.txt -P $destination
sudo rm dlList.txt

#echo $destination
