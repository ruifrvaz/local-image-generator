# Custom Copilot Agent: Sequence Scene Producer

**Status:** Not Started  
**Created:** 2025-12-04

## Description

Create a custom GitHub Copilot agent called `sequence-scene-producer` that generates multiple sequenced scene prompts from a story description. The agent takes a high-level narrative concept and produces a series of related prompts that form a visual sequence, compatible with `generate_sequence.sh`.

Similar to `scene-producer` but outputs multiple prompt files that maintain visual consistency across frames (same characters, style, setting) while depicting different moments in the narrative.

## Acceptance Criteria

- [ ] Create `.github/agents/sequence-scene-producer.md` agent definition
- [ ] Agent accepts story/narrative descriptions with `--model`, `--name`, and `--frames` flags
- [ ] Agent outputs multiple prompt files in correct format (`positive:`/`negative:`)
- [ ] Agent understands model-specific syntax (illustrious, photorealistic, sdxl)
- [ ] Prompts maintain visual consistency across the sequence:
  - Same character descriptions
  - Same art style/quality tags
  - Same lighting/atmosphere (unless story dictates change)
- [ ] Agent creates sequence folder: `~/images/prompts/sequences/{name}/`
- [ ] Files named sequentially: `001_scene.txt`, `002_scene.txt`, etc.
- [ ] Per-model negative prompt defaults
- [ ] Output compatible with `generate_sequence.sh --sequence {name}`

## Notes

- Build on `scene-producer.md` patterns for model-specific syntax
- Add consistency elements section for character/setting descriptions
- Include shot type vocabulary (establishing, wide, medium, close-up, POV)
- Consider pacing: opening → development → climax → resolution
- Agent should explain the sequence breakdown before generating files
