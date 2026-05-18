cat << 'EOF' > ~/.git-fix
#!/bin/bash
# Find all conflicted submodules (marked with 'UU' in git status)
submodules=$(git status --porcelain | grep '^UU' | awk '{print $2}')

if [ -z "$submodules" ]; then
    echo "No conflicted submodules found!"
    exit 0
fi

echo "Found conflicts in submodules: $submodules"
echo "Forcing them to match the upstream branch..."

# Reset them to MERGE_HEAD or FETCH_HEAD depending on what's active
if git rev-parse MERGE_HEAD >/dev/null 2>&1; then
    TARGET="MERGE_HEAD"
else
    TARGET="FETCH_HEAD"
fi

git checkout $TARGET -- $submodules
git add $submodules

echo "Done! Submodules fixed. You can now commit or continue your merge."
EOF

# Make the script executable
chmod +x ~/.git-fix

# Add a simple alias to your Zsh profile (default for Mac)
echo "alias git-fix='~/.git-fix'" >> ~/.zshrc
source ~/.zshrc