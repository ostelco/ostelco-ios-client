# SPM

A wee package to facilitate running pre-build and post-build tasks with the Swift Package Manager rather than trying to bash our heads on `bash`. 

## Usage: 

`swift run SPM <command> <options>`

### Options 

| command | shortcut | Description |
| --- | --- | --- |
| `--postbuild` | `-post` | Runs post-build tasks if present |
| `--prebuild` | `-pre` | Runs pre-build tasks if present |
| `--production` | `-prod` | Runs setup for production if present, non-production if absent.
| `--sourceroot` | `-src` | Provides the git source root of the current project. Should be set as a string, ex. `-src="/path/to/srcroot/"`
| `--help`  | `-h` |  Display available options |


## Pre-Build Tasks 

- Inject secrets from appropriate prod or dev JSON file to appropriate plists 
- TODO: Generate code if certain files or folders have changed.

## Post-Build tasks

- Reset files with injected secrets so they don't get committed to git.
