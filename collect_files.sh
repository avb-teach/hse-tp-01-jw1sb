#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir> [--max_depth DEPTH]"
    exit 1
fi

input_dir="$1"
output_dir="$2"
max_depth=""

if [ "$#" -ge 3 ] && [ "$3" == "--max_depth" ]; then
    if [ -z "$4" ]; then
        echo "Error: --max_depth requires a depth value"
        exit 1
    fi
    max_depth="$4"
fi

mkdir -p "$output_dir"

python3 -c "
import os
import sys
from shutil import copyfile

input_dir = sys.argv[1]
output_dir = sys.argv[2]
max_depth = sys.argv[3] if len(sys.argv) > 3 else None

file_counters = {}

def collect_files(current_dir, current_depth):
    if max_depth is not None and current_depth > int(max_depth):
        return

    for item in os.listdir(current_dir):
        item_path = os.path.join(current_dir, item)
        if os.path.isdir(item_path):
            collect_files(item_path, current_depth + 1)
        else:
            base, ext = os.path.splitext(item)
            new_filename = item

            if new_filename in file_counters:
                file_counters[new_filename] += 1
                new_filename = f'{base}_{file_counters[new_filename]}{ext}'
            else:
                file_counters[new_filename] = 0

            output_path = os.path.join(output_dir, new_filename)
            copyfile(item_path, output_path)

collect_files(input_dir, 0)
" "$input_dir" "$output_dir" "$max_depth"