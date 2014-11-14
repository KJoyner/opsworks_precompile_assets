# opsworks_precompile_assets-cookbook

This chef cookbook will create a shared assets directory if it is not already created, link to this
shared assets directory from the current release and then run the rake precompile step.

## Supported Platforms

Any Opsworks system.

## Usage

### opsworks_precompile_assets::default

Include `opsworks_precompile_assets` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[opsworks_precompile_assets::default]"
  ]
}
```

## License and Authors

Author:: kjoyner (<kjoyner>)
