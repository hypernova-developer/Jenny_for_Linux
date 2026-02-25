#!/bin/bash

# --- CONFIGURATION (Auto-Detect) ---
SYNTAX_INCLUDE="$HOME/Tools/SyntaX"
GCC_PATH=$(which gcc)
GXX_PATH=$(which g++)
GFORTRAN_PATH=$(which gfortran)

# --- FUNCTIONS ---
show_version() {
    echo "---------------------------------------------------"
    echo "[CompileX Engine - Linux Native]"
    echo "Version: 1.0.1 \"Jenny Integrated Edition\""
    echo "Developer: hypernova-developer"
    echo "---------------------------------------------------"
}

do_clean() {
    echo "[CompileX] Initializing targeted cleanup..."
    if [ -f ".compilex_built" ]; then
        while read -r file; do
            if [ -f "$file" ]; then
                rm -f "$file" && echo "[CompileX] Deleted: $file"
            fi
        done < .compilex_built
        rm -f .compilex_built
        echo "[CompileX] Cleanup finished."
    else
        echo "[CompileX] No artifacts found."
    fi
}

# --- ARGUMENT HANDLING ---
if [ "$1" == "--version" ]; then show_version; exit 0; fi
if [ "$1" == "--clean" ]; then do_clean; exit 0; fi
if [ "$1" == "--log" ]; then
    [ -f "compilex_history.log" ] && cat compilex_history.log || echo "Log empty."
    exit 0
fi

if [ -z "$1" ]; then
    echo "[CompileX] Error: No input file."
    exit 1
fi

# --- CORE LOGIC ---
filename=$1
extension="${filename##*.}"
exe_name="${filename%.*}"

if [ ! -f "$filename" ]; then
    echo "[CompileX] Error: Source file '$filename' not found."
    exit 1
fi

case "$extension" in
    cpp) LANG="C++"; COMPILER=$GXX_PATH; FLAGS="-std=c++23 -O3 -s -I$SYNTAX_INCLUDE -o $exe_name" ;;
    c) LANG="C"; COMPILER=$GCC_PATH; FLAGS="-O3 -s -I$SYNTAX_INCLUDE -o $exe_name" ;;
    f90) LANG="Fortran"; COMPILER=$GFORTRAN_PATH; FLAGS="-O3 -o $exe_name" ;;
    *) echo "[CompileX] Unsupported extension: .$extension"; exit 1 ;;
esac

echo "[CompileX] Compiling $filename ($LANG)..."
$COMPILER $FLAGS "$filename"

if [ $? -eq 0 ]; then
    echo "---------------------------------------------------"
    echo "[CompileX] Success: Build complete."
    # Track built files for clean command
    grep -qX "$exe_name" .compilex_built 2>/dev/null || echo "$exe_name" >> .compilex_built
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Compiled $exe_name ($LANG)" >> compilex_history.log
    echo "[CompileX] Executing binary..."
    echo "---------------------------------------------------"
    ./"$exe_name"
    exit 0
else
    echo "---------------------------------------------------"
    echo "[CompileX] Error: Compilation failed."
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Failed: $filename ($LANG)" >> compilex_history.log
    exit 1
fi
