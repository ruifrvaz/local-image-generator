# Sequence Generation Script

**Priority:** 1  
**Status:** Completed  
**Created:** 2025-12-02  
**Completed:** 2025-12-03

## Description

Create a script that processes multiple prompt files in sequence to generate a series of related images depicting a narrative or scene progression. The script should maintain visual consistency across frames while allowing scene/action changes.

**Example use case:** A person moving on a street → walking inside a store → going to the counter → asking for a drink

## Acceptance Criteria

- [x] Script reads multiple prompt files from a designated folder or accepts a list of files
- [x] Processes prompts in order (sorted by filename or explicit ordering)
- [x] Generates images sequentially, saving to a single timestamped "sequence" folder
- [x] Each output includes frame number and original prompt filename
- [x] Supports shared parameters across sequence (model, seed base, style consistency)
- [x] Optional: seed incrementing or fixed seed for style consistency
- [x] Optional: shared negative prompt or style prefix applied to all frames
- [x] Outputs a manifest/index file listing all frames with their prompts

## Implementation Notes

- Script: `scripts/generate_sequence.sh`
- Calls ComfyUI API directly (no `generate.sh` wrapper)
- Supports `--dry-run` to preview sequence without generating
- Supports `--prefix`, `--suffix` for style consistency
- Supports `--fixed-seed` for same seed across all frames
- Sequence prompts: `~/images/prompts/sequences/<name>/NNN_scene.txt`
- Output: `~/images/outputs/sequences/YYYYMMDD_HHMMSS_<name>/frame_NNN.png`

## Notes

- Consider using consistent character/style LoRA across all frames
- May want to support "base prompt" that gets prepended to each scene prompt
- Could integrate with existing `generate.sh` or be standalone
- Folder structure idea: `prompts/sequences/sequence_name/001_scene.txt, 002_scene.txt, ...`
- Output structure: `outputs/sequences/YYYYMMDD_HHMMSS_sequence_name/frame_001.png, frame_002.png, ...`
