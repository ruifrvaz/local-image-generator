# Move Prompt and Output Outside Project

**Status:** Completed  
**Created:** 2025-12-03  
**Completed:** 2025-12-03

## Description

Update generate.sh and any other relevant scripts to move prompt and output directories outside of the image-gen project folder. The new location should be an `images/` folder at the same level as the `image-gen/` folder.

**Current structure:**
```
~/image-gen/
├── prompts/
└── outputs/
```

**Target structure:**
```
~/images/
├── prompts/
└── outputs/
~/image-gen/
```

## Acceptance Criteria

- [x] Create `~/images/prompts/` and `~/images/outputs/` directories
- [x] Update `generate.sh` to use new paths
- [x] Update any other scripts referencing prompts/ or outputs/
- [x] Update documentation (README.md, QUICKSTART.md) with new paths
- [x] Update `.github/copilot-instructions.md` file structure diagram
- [x] Remove old prompts/ and outputs/ directories from project

## Notes

- Keeps generated content separate from code
- Makes git cleaner (no need to .gitignore large outputs)
- Consider using environment variable or config for path flexibility
