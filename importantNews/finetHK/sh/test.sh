#!/bin/bash

cat ../src/url.txt|while read line
do
    echo $line>>b.log
done

vim b.log|%s/\r//g>c.log
