# Sequence Generation Script

**Priority:** 1  
**Status:** Not Started  
**Created:** 2025-12-02

## Description

Create a script that processes multiple prompt files in sequence to generate a series of related images depicting a narrative or scene progression. The script should maintain visual consistency across frames while allowing scene/action changes.

**Example use case:** A person moving on a street → walking inside a store → going to the counter → asking for a drink

## Acceptance Criteria

- [ ] Script reads multiple prompt files from a designated folder or accepts a list of files
- [ ] Processes prompts in order (sorted by filename or explicit ordering)
- [ ] Generates images sequentially, saving to a single timestamped "sequence" folder
- [ ] Each output includes frame number and original prompt filename
- [ ] Supports shared parameters across sequence (model, seed base, style consistency)
- [ ] Optional: seed incrementing or fixed seed for style consistency
- [ ] Optional: shared negative prompt or style prefix applied to all frames
- [ ] Outputs a manifest/index file listing all frames with their prompts

## Notes

- Consider using consistent character/style LoRA across all frames
- May want to support "base prompt" that gets prepended to each scene prompt
- Could integrate with existing `generate.sh` or be standalone
- Folder structure idea: `prompts/sequences/sequence_name/001_scene.txt, 002_scene.txt, ...`
- Output structure: `outputs/sequences/YYYYMMDD_HHMMSS_sequence_name/frame_001.png, frame_002.png, ...`
