#!/bin/bash
# ============================================================
# Install "Convert to WebP" Finder Quick Action
# Right-click any image → Quick Actions → Convert to WebP
# Saves a resized (max 1920px), quality-80 WebP alongside the original
# ============================================================

set -e

echo ""
echo "=== Convert to WebP — Quick Action Installer ==="
echo ""

# ── 1. Homebrew ──────────────────────────────────────────────
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add Homebrew to PATH for Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || true
else
  echo "✓ Homebrew already installed"
fi

# ── 2. cwebp ─────────────────────────────────────────────────
if ! command -v cwebp &>/dev/null; then
  echo "Installing cwebp (Google WebP encoder)..."
  brew install webp
else
  echo "✓ cwebp already installed"
fi

# ── 3. Create workflow bundle ─────────────────────────────────
SERVICES_DIR="$HOME/Library/Services"
WORKFLOW_DIR="$SERVICES_DIR/Convert to WebP.workflow/Contents"
mkdir -p "$WORKFLOW_DIR"

echo "Creating workflow..."

# document.wflow
cat > "$WORKFLOW_DIR/document.wflow" << 'WFLOW_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>AMApplicationBuild</key>
	<string>521.1</string>
	<key>AMApplicationVersion</key>
	<string>2.10</string>
	<key>AMDocumentVersion</key>
	<string>2</string>
	<key>actions</key>
	<array>
		<dict>
			<key>action</key>
			<dict>
				<key>AMAccepts</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Optional</key>
					<true/>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.path</string>
					</array>
				</dict>
				<key>AMActionVersion</key>
				<string>2.0.3</string>
				<key>AMApplication</key>
				<array>
					<string>Automator</string>
				</array>
				<key>AMParameterProperties</key>
				<dict>
					<key>COMMAND_STRING</key>
					<dict/>
					<key>CheckedForUserDefaultShell</key>
					<dict/>
					<key>inputMethod</key>
					<dict/>
					<key>shell</key>
					<dict/>
					<key>source</key>
					<dict/>
				</dict>
				<key>AMProvides</key>
				<dict>
					<key>Container</key>
					<string>List</string>
					<key>Types</key>
					<array>
						<string>com.apple.cocoa.path</string>
					</array>
				</dict>
				<key>ActionBundlePath</key>
				<string>/System/Library/Automator/Run Shell Script.action</string>
				<key>ActionName</key>
				<string>Run Shell Script</string>
				<key>ActionParameters</key>
				<dict>
					<key>COMMAND_STRING</key>
					<string>export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
COUNT=0

for INPUT in "$@"; do
    DIR=$(dirname "$INPUT")
    BASE=$(basename "$INPUT")
    NAME="${BASE%.*}"
    OUTPUT="$DIR/${NAME}-web.webp"

    WIDTH=$(sips -g pixelWidth "$INPUT" 2>/dev/null | awk '/pixelWidth/{print $2}')
    HEIGHT=$(sips -g pixelHeight "$INPUT" 2>/dev/null | awk '/pixelHeight/{print $2}')

    if [ -n "$WIDTH" -a -n "$HEIGHT" -a "$WIDTH" -ge "$HEIGHT" -a "$WIDTH" -gt 1920 ]; then
        cwebp -q 80 -resize 1920 0 "$INPUT" -o "$OUTPUT" 2&gt;/dev/null
    elif [ -n "$WIDTH" -a -n "$HEIGHT" -a "$HEIGHT" -gt "$WIDTH" -a "$HEIGHT" -gt 1920 ]; then
        cwebp -q 80 -resize 0 1920 "$INPUT" -o "$OUTPUT" 2&gt;/dev/null
    else
        cwebp -q 80 "$INPUT" -o "$OUTPUT" 2&gt;/dev/null
    fi

    COUNT=$((COUNT + 1))
done

if [ "$COUNT" -gt 0 ]; then
    osascript -e "display notification \"Converted $COUNT image(s) to WebP\" with title \"Convert to WebP\""
fi</string>
					<key>CheckedForUserDefaultShell</key>
					<true/>
					<key>inputMethod</key>
					<integer>1</integer>
					<key>shell</key>
					<string>/bin/bash</string>
					<key>source</key>
					<string></string>
				</dict>
				<key>BundleIdentifier</key>
				<string>com.apple.RunShellScript</string>
				<key>CFBundleVersion</key>
				<string>2.0.3</string>
				<key>CanShowSelectedItemsWhenRun</key>
				<false/>
				<key>CanShowWhenRun</key>
				<true/>
				<key>Category</key>
				<array>
					<string>AMCategoryUtilities</string>
				</array>
				<key>Class Name</key>
				<string>RunShellScriptAction</string>
				<key>InputUUID</key>
				<string>A1B2C3D4-E5F6-7890-ABCD-EF1234567890</string>
				<key>Keywords</key>
				<array>
					<string>Shell</string>
					<string>Script</string>
					<string>Command</string>
					<string>Run</string>
					<string>Unix</string>
				</array>
				<key>OutputUUID</key>
				<string>B2C3D4E5-F6A7-8901-BCDE-F12345678901</string>
				<key>UUID</key>
				<string>C3D4E5F6-A7B8-9012-CDEF-123456789012</string>
				<key>UnlocalizedApplications</key>
				<array>
					<string>Automator</string>
				</array>
				<key>arguments</key>
				<dict>
					<key>0</key>
					<dict>
						<key>default value</key>
						<integer>0</integer>
						<key>name</key>
						<string>inputMethod</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>0</string>
					</dict>
					<key>1</key>
					<dict>
						<key>default value</key>
						<string></string>
						<key>name</key>
						<string>source</string>
						<key>required</key>
						<string>0</string>
						<key>type</key>
						<string>0</string>
						<key>uuid</key>
						<string>1</string>
					</dict>
				</dict>
				<key>isViewVisible</key>
				<true/>
				<key>location</key>
				<string>309.000000:256.000000</string>
				<key>nibPath</key>
				<string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
			</dict>
			<key>isViewVisible</key>
			<true/>
		</dict>
	</array>
	<key>connectors</key>
	<dict/>
	<key>workflowMetaData</key>
	<dict>
		<key>serviceInputTypeIdentifier</key>
		<string>com.apple.Automator.fileSystemObject.image</string>
		<key>serviceOutputTypeIdentifier</key>
		<string>com.apple.Automator.nothing</string>
		<key>serviceProcessesInput</key>
		<integer>0</integer>
		<key>workflowTypeIdentifier</key>
		<string>com.apple.Automator.servicesMenu</string>
	</dict>
</dict>
</plist>
WFLOW_EOF

# Info.plist
cat > "$WORKFLOW_DIR/Info.plist" << 'INFO_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>NSServices</key>
	<array>
		<dict>
			<key>NSBackgroundColorName</key>
			<string>background</string>
			<key>NSIconName</key>
			<string>NSActionTemplate</string>
			<key>NSMenuItem</key>
			<dict>
				<key>default</key>
				<string>Convert to WebP</string>
			</dict>
			<key>NSMessage</key>
			<string>runWorkflowAsService</string>
			<key>NSSendFileTypes</key>
			<array>
				<string>public.image</string>
			</array>
		</dict>
	</array>
</dict>
</plist>
INFO_EOF

# ── 4. Register with macOS ────────────────────────────────────
echo "Registering Quick Action..."
/System/Library/CoreServices/pbs -flush
killall Finder 2>/dev/null || true

echo ""
echo "✅ Done! Right-click any image in Finder"
echo "   → Quick Actions → Convert to WebP"
echo ""
echo "   Output: a '-web.webp' file in the same folder"
echo "   (max 1920px on longest side, quality 80)"
echo ""
