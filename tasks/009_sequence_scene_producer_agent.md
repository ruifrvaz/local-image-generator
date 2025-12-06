# Custom Copilot Agent: Sequence Scene Producer

**Status:** Completed  
**Created:** 2025-12-04  
**Completed:** 2025-12-06

## Description

Create a custom GitHub Copilot agent called `sequence-scene-producer` that generates multiple sequenced scene prompts from a story description. The agent takes a high-level narrative concept and produces a series of related prompts that form a visual sequence, compatible with `generate_sequence.sh`.

Similar to `scene-producer` but outputs multiple prompt files that maintain visual consistency across frames (same characters, style, setting) while depicting different moments in the narrative.

## Acceptance Criteria

- [x] Create `.github/agents/sequence-scene-producer.md` agent definition
- [x] Agent accepts story/narrative descriptions with `--model`, `--name`, and `--frames` flags
- [x] Agent accepts optional `--arc` flag for user-defined narrative structure (else creative freedom)
- [x] Agent outputs multiple prompt files in correct format (`positive:`/`negative:`)
- [x] Agent understands model-specific syntax (illustrious, photorealistic, sdxl)
- [x] Prompts maintain visual consistency across the sequence:
  - Same character descriptions (consistency elements section)
  - Same art style/quality tags
  - Same lighting/atmosphere (unless story dictates change)
- [x] Shot type vocabulary maps to model-specific prompt syntax
- [x] Agent creates sequence folder with `mkdir -p ~/images/prompts/sequences/{name}/`
- [x] Files named: `NNN_descriptive-name.txt`
- [x] Agent creates `README.md` in sequence folder with:
  - Narrative summary
  - Bash commands to generate sequence for each model type
  - Recommended `--prefix`, `--suffix`, `--negative` flags
  - Seed strategy recommendation (`--fixed-seed` when character consistency critical)
- [x] Shared negative prompt per model (no per-frame overrides)
- [x] Default frame count: 5 (valid range: 3-15)
- [x] Output compatible with `generate_sequence.sh --sequence {name}`
- [x] **QC: Test run** - Generate a 7-frame test sequence using the agent
- [x] **QC: Dry run validation** - Run `generate_sequence.sh --sequence {name} --dry-run` to verify compatibility

## Notes

- Build on `scene-producer.md` patterns for model-specific syntax
- Add consistency elements section for character/setting descriptions
- Include shot type vocabulary (establishing, wide, medium, close-up, POV)
- Narrative pacing: user provides `--arc` or agent has creative freedom
- Agent should explain the sequence breakdown before generating files
- **File naming examples:**
  - Location-based: `001_coffee_shop.txt`, `002_park_bench.txt`, `003_apartment.txt`
  - Action-based: `001_characters_meet.txt`, `002_argument.txt`, `003_reconciliation.txt`
  - Mixed: `001_office_introduction.txt`, `002_elevator_tension.txt`, `003_rooftop_resolution.txt`
- **Agent output format:** Use templates/placeholders, not hardcoded examples
- **File naming convention:**
  - Pattern: `NNN_{location|action|descriptor}.txt`
  - Location-based: `NNN_{location}.txt`
  - Action-based: `NNN_{action}.txt`
  - Mixed: `NNN_{location}_{action}.txt`