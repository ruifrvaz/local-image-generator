# Add Execution Count Option to generate.sh

**Status:** Completed  
**Created:** 2025-12-03  
**Completed:** 2025-12-03

## Description

Add a new `--count N` option to `generate.sh` that generates N images from the same prompt in a single command execution. Each image uses a different seed to produce variations of the same prompt.

Each iteration will:
- Use the same prompt and model
- Use a different random seed (unless seed is explicitly specified, in which case increment seed)
- Save to uniquely named files (image_001.png, image_002.png, etc.) in the same output folder
- Display progress (e.g., "Generating 3/5...")

## Acceptance Criteria

- [x] Add `--count N` option (default: 1)
- [x] Loop N times, submitting each generation request
- [x] Each iteration uses a unique seed (random if not specified, incremented if specified)
- [x] Output files named sequentially: `image_001.png`, `image_002.png`, etc.
- [x] Metadata files named correspondingly: `prompt_001.txt`, `prompt_002.txt`, etc.
- [x] Progress indicator shows current/total (e.g., "[3/5] Generating...")
- [x] All images saved in single timestamped output folder
- [x] Update script header documentation with new option

## Notes

- This is simpler than batch generation from multiple prompts (task 005 backlog)
- Single prompt, multiple outputs with different seeds
- Useful for generating variations to pick the best result
