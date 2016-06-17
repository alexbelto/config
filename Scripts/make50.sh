#!/bin/bash

file=$1

clang -ggdb3 -O0 -std=c11 -Wall -Werror    $file.c  -lcs50 -lm -o $file
