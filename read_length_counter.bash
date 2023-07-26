#!/bin/bash

# Check if the user provided the directory path
if [ $# -eq 0 ]; then
  echo "Usage: $0 [-n <num_reads>] /path/to/directory"
  exit 1
fi

# Get the directory path from the command-line argument
directory=""
num_reads=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -n)
      if [[ "$2" =~ ^[0-9]+$ ]]; then
        num_reads=$2
        shift 2
      else
        echo "Invalid argument for -n. Please provide a positive integer." >&2
        exit 1
      fi
      ;;
    *)
      if [ -d "$1" ]; then
        directory="$1"
        shift
      else
        echo "Invalid argument: $1" >&2
        exit 1
      fi
      ;;
  esac
done

# Check if the directory is provided and exists
if [ -z "$directory" ]; then
  echo "Directory path is missing." >&2
  exit 1
fi

if [ ! -d "$directory" ]; then
  echo "Directory not found: $directory" >&2
  exit 1
fi

# Check if .fq.gz files are found in the specified directory
fqgz_files=("$directory"/*.fq.gz)
if [ ${#fqgz_files[@]} -eq 0 ]; then
  echo "No .fq.gz files found in the directory: $directory" >&2
  exit 1
fi

# Print the table header
echo -e "File\tRead Length\tFrequency"

# Process .fq.gz files in the specified directory
for input_file in "${fqgz_files[@]}"; do
  # Check if the file exists
  if [ ! -f "$input_file" ]; then
    echo "File not found: $input_file" >&2
    continue
  fi

  # Use zcat to read the compressed .fq.gz file and pipe it to awk for processing
  zcat "$input_file" | awk -v num_reads="$num_reads" -v file_name="$input_file" '{
    if(NR % 4 == 2) {
      lengthArr[length($0)]++
      processed_reads++
      if (num_reads > 0 && processed_reads >= num_reads) exit
    }
  }
  END {
    for (len in lengthArr) {
      printf "%s\t%s\t%s\n", file_name, len, lengthArr[len]
    }
  }'
done
