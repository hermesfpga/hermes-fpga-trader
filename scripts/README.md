# Scripts

## Usage

**`setup_project.tcl`**  
Recreate the Vivado project only. Use for quick testing.

**`setup_and_build_project.tcl`**  
Recreate the project, run synthesis, implementation, and generate bitstream.

## Structure

- `common.tcl` - Shared project setup logic
- `build_utils.tcl` - Build helper functions

Modify `common.tcl` for project changes; both scripts will use the updated logic.
