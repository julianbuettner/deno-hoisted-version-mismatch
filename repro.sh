#!/usr/bin/env bash
cd "$(dirname "$0")"

report() {
  # resolve ajv the way Node would, starting from schema-utils
  local resolved actual
  resolved=$(node -e 'console.log(require.resolve("ajv/package.json",{paths:["./node_modules/schema-utils"]}))' 2>/dev/null)
  actual=$( [ -n "$resolved" ] && jq -r .version "$resolved" || echo "none" )

  echo "  desired ajv (schema-utils): $(jq -r .dependencies.ajv node_modules/schema-utils/package.json)"
  echo "  actual  ajv (schema-utils): $actual"
  echo "  ajv at top level:           $(jq -r .version node_modules/ajv/package.json 2>/dev/null || echo none)"
  printf "  runtime:                    "
  node -e 'try{require("schema-utils").validate({type:"object"},{},{name:"x"});console.log("OK")}catch(e){console.log(e.name+": "+e.message)}'
}

echo "############################################################"
echo "# npm install  (works)"
echo "############################################################"
rm -rf node_modules deno.lock package-lock.json
npm install --silent --no-audit --no-fund
report

echo
echo "############################################################"
echo "# deno install  (broken)"
echo "############################################################"
rm -rf node_modules deno.lock package-lock.json
deno install >/dev/null 2>&1
report
