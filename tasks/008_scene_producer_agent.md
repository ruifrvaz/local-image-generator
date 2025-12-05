# Custom Copilot Agent: Scene Producer

**Status:** Completed  
**Created:** 2025-12-03  
**Completed:** 2025-12-04

## Description

Create a custom GitHub Copilot agent called `scene-producer` that generates single SDXL image prompts from natural language scene descriptions. The agent transforms scene concepts into properly formatted prompt files with model-specific syntax.

## Acceptance Criteria

- [x] Create `.github/agents/scene-producer.md` agent definition
- [x] Agent accepts scene descriptions with `--model` and `--name` flags
- [x] Agent outputs prompt files in correct format (`positive:`/`negative:`)
- [x] Agent understands model-specific syntax:
  - `illustrious`: Danbooru tags, anime quality/negative defaults
  - `photorealistic`: Natural language, photo quality/negative defaults
  - `sdxl`: Generic SDXL syntax (default)
- [x] Agent auto-increments filenames (`NNN_descriptive-name.txt`)
- [x] Agent outputs files to `~/images/prompts/` directory
- [x] Per-model negative prompt defaults

## Implementation Notes

- Agent file: `.github/agents/scene-producer.md`
- Tools: `edit`, `runCommands` (for file listing and creation)
- Input format: `<scene description> --model <type> --name <filename>`
- Output format: `positive:` and `negative:` lines in text file
