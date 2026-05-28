# Deno hoisted-linker mis-nesting

With `nodeModulesLinker: "hoisted"`, Deno nests an `ajv` version under
`schema-utils` that violates `schema-utils`'s declared range, causing
`TypeError: Ajv is not a constructor`. npm resolves the same `package.json`
correctly.

## Reproduce

The issue is for an open PR, so please run `deno upgrade pr 34470` before reproducing.

TLDR: Run `bash repro.sh`

```bash
deno install

# desired range schema-utils declares for ajv:
jq -r .dependencies.ajv node_modules/schema-utils/package.json
# ^8.9.0

# version Deno actually nested under schema-utils:
jq -r .version node_modules/schema-utils/node_modules/ajv/package.json
# 6.15.0   <-- does not satisfy ^8.9.0

# ajv available at the top level (would satisfy ^8.9.0):
jq -r .version node_modules/ajv/package.json
# 8.20.0

# runtime consequence:
node -e 'require("schema-utils").validate({type:"object"},{},{name:"x"})'
# TypeError: Ajv is not a constructor
```
## Expected

`schema-utils@4.3.3` declares `ajv: "^8.9.0"` and `ajv@8.20.0` is at the top
level, so `schema-utils` should resolve `ajv` to 8.x (as npm does). Instead Deno
nests `ajv@6.15.0` under it.
