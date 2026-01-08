---
description: Add memory/instruction to CLAUDE.md
argument-hint: [instruction]
allowed-tools: Read, Edit, Write, AskUserQuestion
model: sonnet
---

You are helping the user add a memory or instruction to their CLAUDE.md file.

**Memory to add:** $ARGUMENTS

## Step 1: Choose Memory File

Use the AskUserQuestion tool to ask which memory file to update:

**Question:** "Which memory file should I update?"
**Header:** "Memory File"
**Options:**
1. **Project (CLAUDE.md)** - "Team-shared memory file, committed to git. Use for project-wide conventions and guidelines."
2. **Local (CLAUDE.local.md)** - "Personal project memory, auto-gitignored. Use for your own preferences in this project."
3. **User (~/.claude/CLAUDE.md)** - "Personal memory for all projects. Use for your general preferences across all work."

## Step 2: Read Existing Content

Based on the user's choice:
- If "Project": Read `CLAUDE.md` (or `./CLAUDE.md`)
- If "Local": Read `CLAUDE.local.md` (or `./CLAUDE.local.md`)
- If "User": Read `~/.claude/CLAUDE.md`

If the file doesn't exist, that's fine - you'll create it in Step 5.

## Step 3: Intelligent Analysis

Carefully analyze the existing content (if any) and the new memory. Determine:

1. **Is this a duplicate?**
   - Check for exact matches or very similar content
   - If duplicate, you'll skip adding it

2. **Is this related to existing content?**
   - Look for similar topics, categories, or themes
   - Identify which section/heading it belongs under

3. **What category does this belong to?**
   Common categories:
   - Code Style & Formatting
   - Architecture & Design Patterns
   - Database & Data Access
   - Testing & Quality
   - Error Handling & Logging
   - API Design
   - Performance & Optimization
   - Security
   - Git & Version Control
   - Dependencies & Tooling
   - Documentation

4. **Should this replace old guidance?**
   - If the new memory contradicts or supersedes existing content, update rather than add

## Step 4: Determine Action

Based on your analysis, decide:

- **SKIP**: If it's a duplicate of existing content
- **ADD**: If it's new and unique
- **MERGE**: If it's related and should be grouped with existing items
- **UPDATE**: If it replaces or enhances existing guidance

## Step 5: Apply Best Practices

Format the memory following these best practices:

1. **Use bullet points**: Start with `- ` for list items
2. **Be specific**: "Use 2-space indentation" not "Format code well"
3. **Be actionable**: Provide clear, concrete guidance
4. **Use headings**: Group related items under `## Category Name`
5. **Keep related items together**: Don't scatter similar content

**File Structure Template** (if creating new file):
```markdown
# Claude Instructions

## [Category 1]

- Instruction 1
- Instruction 2

## [Category 2]

- Instruction 3
```

## Step 6: Update the File

**If file doesn't exist:**
- Use Write tool to create it with proper structure

**If file exists:**
- Use Edit tool to update the specific section
- Add new headings if needed
- Maintain existing structure and formatting

**Important:**
- Preserve all existing content unless it's being updated/replaced
- Keep alphabetical or logical ordering of headings if present
- Maintain consistent formatting (bullet style, heading levels)

## Step 7: Report Summary

Tell the user what you did in a clear, concise message:

**Examples:**

✓ "Added new memory under **Code Style**: Use 2-space indentation for TypeScript files"

✓ "Merged with existing naming conventions in **Naming Conventions** section"

✓ "Skipped - this is already captured in CLAUDE.md line 23"

✓ "Updated **Testing** section to replace old guidance about test runners"

✓ "Created new CLAUDE.local.md with **Git** section for commit message preferences"

**Format:**
- Start with the action (Added/Merged/Skipped/Updated/Created)
- Include the category/section affected
- Briefly describe what was changed
- Reference line numbers if updating existing content

---

Remember: The goal is to keep CLAUDE.md clean, organized, and free of duplicates while making it easy to scan and understand.
