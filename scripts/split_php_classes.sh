#!/bin/bash

input_file="$1"

filename=$(basename "$input_file" .php)

output_dir="models/php/generated/$filename"

mkdir -p "$output_dir"

rm -rf "$output_dir"/*

awk '/^class /,/^}/' "$input_file" | awk -v output_dir="$output_dir" -v filename="$filename" '
    BEGIN {
        file_count = 0;
    }
    /^class / {
        if (file_count > 0) {
            close(output_file);
        }
        class_name = $2;
        output_file = output_dir "/" class_name ".php";
        file_count++;
    }
    {
        print >> output_file;
    }
    END {
        if (file_count > 0) {
            close(output_file);
        }
    }
'

# add <?php, namespace,  use
for file in "$output_dir"/*.php; do
    namespace=$(echo "$filename" | perl -pe 's/(^|-|_)([a-z])/\U$2/g')
    {
        echo "<?php"
        echo "namespace RmqModels\\$namespace;"
        echo "use stdClass;"
        cat "$file"
    } > "$file.tmp"
    mv "$file.tmp" "$file"
    perl -pi -e 's/\$obj->\{\047(\w+)\047\}/\$obj?->\{\047$1\047\} ?? null/g' "$file"
done

npm run format "$output_dir"
echo "Config files succesefully generated"
