#!/bin/bash

if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <input_dir> <output_dir> [--max_depth DEPTH]" >&2
    exit 1
fi

input_dir="$1"
output_dir="$2"
max_depth=""

if [ ! -d "$input_dir" ]; then
    echo "Error: Input directory does not exist" >&2
    exit 1
fi

if [ "$#" -ge 4 ] && [ "$3" == "--max_depth" ]; then
    max_depth="$4"
elif [ "$#" -eq 3 ]; then
    echo "Error: --max_depth requires a depth value" >&2
    exit 1
fi

mkdir -p "$output_dir"

copy_files() {
    local src="$1"
    local dest="$2"
    local depth="$3"

    if [ -n "$max_depth" ] && [ "$depth" -gt "$max_depth" ]; then
        return
    fi

    for item in "$src"/*; do
        if [ -d "$item" ]; then
            copy_files "$item" "$dest" $((depth + 1))
        elif [ -f "$item" ]; then
            filename=$(basename "$item")
            counter=1
            new_filename="$filename"

            while [ -e "$dest/$new_filename" ]; do
                extension="${filename##*.}"
                base="${filename%.*}"
                if [[ "$base" != "$filename" ]]; then
                    new_filename="${base}_${counter}.${extension}"
                else
                    new_filename="${filename}_${counter}"
                fi
                ((counter++))
            done

            cp "$item" "$dest/$new_filename"
        fi
    done
}

copy_files "$input_dir" "$output_dir" 0

exit 0