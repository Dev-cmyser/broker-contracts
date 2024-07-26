#!/bin/bash

# Define directories and files
SRC_DIR="./src/configs"
OUT_DIR="./configs"

# Determine if the environment is 'production' or any other (default to 'dev')
ObjectForGen="arguments"
# Read environment-specific values from JSON files
QUEUES_FILE="${SRC_DIR}/queues.json"
EXCHANGES_FILE="${SRC_DIR}/exchanges.json"
ROUTING_KEYS_FILE="${SRC_DIR}/routingKeys.json"

# Create output directory if it doesn't exist
mkdir -p "${OUT_DIR}/ts"
mkdir -p "${OUT_DIR}/php"

# Generate TypeScript files
function generate_typescript {
  local config_env=$1
  local file_path=$2
  local object_name=$3
  local out_file="${OUT_DIR}/ts/${object_name}.ts"

  local postfix=""
  case "$file_path" in
    *queues.json) ;;
    *exchanges.json) ;;
    *routingKeys.json) ;;
    *) echo "Unknown file type for $file_path" ; exit 1 ;;
  esac

  echo "export const ${object_name} = {" > "${out_file}"

  jq -r --arg config_env "$config_env"  ' .[$config_env] | to_entries[] | "\(.key | ascii_upcase | gsub("-"; "_") | gsub(" "; "_")): '\''" + "\(.value)" + "'\''," ' "$file_path" >> "$out_file"

  echo "};" >> "${out_file}"
}

# Function to generate index.ts file
function generate_index_ts {
  local out_dir=$1
  echo "export * from './exchanges';" > "${out_dir}/ts/index.ts"
  echo "export * from './queues';" >> "${out_dir}/ts/index.ts"
  echo "export * from './routingKeys';" >> "${out_dir}/ts/index.ts"
}

function generate_php {
  local config_env=$1
  local file_path=$2
  local object_name=$3
  local out_file="${OUT_DIR}/php/${object_name}.php"

  local postfix=""
  case "$file_path" in
    *queues.json)  ;;
    *exchanges.json)  ;;
    *routingKeys.json)  ;;
    *) echo "Unknown file type for $file_path" ; exit 1 ;;
  esac

  echo "<?php" > "${out_file}"
  echo "" >> "${out_file}"
  echo "namespace RmqConfig;" >> "${out_file}"
  echo "" >> "${out_file}"
  echo "class ${object_name}" >> "${out_file}"
  echo "{" >> "${out_file}"

  # Corrected jq command to properly escape only the necessary characters and use single quotes around values
  jq -r --arg config_env "$config_env"  \
    '.[$config_env] | to_entries[] | "    const \( .key | ascii_upcase | gsub("-"; "_") | gsub(" "; "_") | gsub("[^A-Z0-9_]"; "") ) = '\''\(.value | gsub("\""; "\\\"") | gsub("\\\\"; "\\\\\\\\") )'\'';"' \
    "$file_path" >> "${out_file}"

  echo "}" >> "${out_file}"
  echo "?>" >> "${out_file}"
}

# Generate configurations for queues, exchanges, and routing keys
{
  generate_typescript "${ObjectForGen}" "${QUEUES_FILE}" "queues" &&
  generate_php "${ObjectForGen}" "${QUEUES_FILE}" "Queues" &&

  generate_typescript "${ObjectForGen}" "${EXCHANGES_FILE}" "exchanges" &&
  generate_php "${ObjectForGen}" "${EXCHANGES_FILE}" "Exchanges" &&

  generate_typescript "${ObjectForGen}" "${ROUTING_KEYS_FILE}" "routingKeys" &&
  generate_php "${ObjectForGen}" "${ROUTING_KEYS_FILE}" "RoutingKeys" &&

  generate_index_ts "$OUT_DIR"
} || {
  echo "Error: Failed to generate configuration files."
  exit 1
}

echo "Config files succesefully generated"
