# AetherOS ISO Upload Instructions

This guide explains how to prepare and upload AetherOS ISO images to GitHub Releases and optional external mirrors.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Preparing the ISO](#preparing-the-iso)
3. [Uploading to GitHub Releases](#uploading-to-github-releases)
4. [Optional External Mirrors](#optional-external-mirrors)
5. [Best Practices](#best-practices)

---

## Prerequisites

### Required Tools

```bash
# Install xz-utils for compression
sudo apt install xz-utils

# Install GitHub CLI (optional, but recommended)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
  sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### Access Requirements

- Write access to the Aether_OS repository
- GitHub Personal Access Token with `repo` scope (for releases)
- Approximately 6GB free disk space (for ISO + compressed ISO)

---

## Preparing the ISO

### Step 1: Build the ISO

```bash
# Clone the repository
git clone https://github.com/Anamitra-Sarkar/Aether_OS.git
cd Aether_OS

# Build the ISO
sudo ./build/build.sh

# Output will be in: build/artifacts/aetheros.iso
```

### Step 2: Compress the ISO

Compress with xz for maximum compression:

```bash
cd build/artifacts

# Compress with xz (uses all CPU cores)
xz -T0 -z -9 aetheros.iso

# This creates: aetheros.iso.xz
# Expected compression: ~3.2GB -> ~2.8GB
```

**Compression options explained:**
- `-T0`: Use all available CPU cores
- `-z`: Compress (default)
- `-9`: Maximum compression level (slower but smaller)

### Step 3: Generate Checksum

Create SHA256 checksum for verification:

```bash
# Generate checksum
sha256sum aetheros.iso.xz > aetheros.iso.xz.sha256

# Verify it was created correctly
cat aetheros.iso.xz.sha256
```

The checksum file should look like:
```
a1b2c3d4e5f6... aetheros.iso.xz
```

### Step 4: Test the Compressed ISO

Before uploading, verify the compressed ISO works:

```bash
# Extract to a temporary location
xz -d -k aetheros.iso.xz  # -k keeps the original

# Verify checksum
sha256sum -c aetheros.iso.xz.sha256

# Optional: Test boot in QEMU
cd ../..
./tests/boot-qemu.sh build/artifacts/aetheros.iso
```

---

## Uploading to GitHub Releases

### Method 1: Using GitHub Web Interface (Easy)

1. **Go to Releases**
   - Navigate to: https://github.com/Anamitra-Sarkar/Aether_OS/releases
   - Click "Draft a new release"

2. **Create Release**
   - **Tag**: `v2.1` (or appropriate version)
   - **Title**: `AetherOS v2.1 - Security Evolution`
   - **Description**: Use the release notes from `V2.1-RELEASE-NOTES.md`

3. **Upload Assets**
   - Drag and drop `aetheros.iso.xz`
   - Drag and drop `aetheros.iso.xz.sha256`
   - Wait for uploads to complete (may take 10-20 minutes)

4. **Publish**
   - Check "Set as the latest release"
   - Click "Publish release"

### Method 2: Using GitHub CLI (Recommended)

```bash
# Authenticate (first time only)
gh auth login

# Create and upload release
gh release create v2.1 \
  --title "AetherOS v2.1 - Security Evolution" \
  --notes-file V2.1-RELEASE-NOTES.md \
  build/artifacts/aetheros.iso.xz \
  build/artifacts/aetheros.iso.xz.sha256

# Set as latest release
gh release edit v2.1 --latest
```

### Method 3: Using GitHub API

```bash
# Set variables
GITHUB_TOKEN="your_token_here"
REPO="Anamitra-Sarkar/Aether_OS"
TAG="v2.1"
RELEASE_NAME="AetherOS v2.1 - Security Evolution"

# Create release
RELEASE_ID=$(curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"tag_name\":\"$TAG\",\"name\":\"$RELEASE_NAME\",\"draft\":false}" \
  "https://api.github.com/repos/$REPO/releases" | jq -r '.id')

# Upload ISO
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: application/x-xz" \
  --data-binary @build/artifacts/aetheros.iso.xz \
  "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=aetheros.iso.xz"

# Upload checksum
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Content-Type: text/plain" \
  --data-binary @build/artifacts/aetheros.iso.xz.sha256 \
  "https://uploads.github.com/repos/$REPO/releases/$RELEASE_ID/assets?name=aetheros.iso.xz.sha256"
```

---

## Optional External Mirrors

### Archive.org (Long-term Preservation)

Archive.org is perfect for long-term preservation and doesn't require payment.

#### Setup

1. **Create Account**
   - Go to: https://archive.org/account/signup
   - Create a free account

2. **Upload ISO**
   - Click "Upload" in the top-right
   - Create a new item
   - **Identifier**: `aetheros-v2.1-iso` (must be unique)
   - **Title**: `AetherOS v2.1 - Security Evolution ISO`
   - **Description**: Copy from release notes
   - **Subject Tags**: `linux, ubuntu, kde, operating-system, desktop`
   - **Language**: English
   - **License**: Apache-2.0

3. **Upload Files**
   - Upload `aetheros.iso.xz`
   - Upload `aetheros.iso.xz.sha256`
   - Upload `README.md` for context

4. **Publish**
   - Click "Upload and Create Item"
   - Wait for processing (may take hours)

5. **Get Download URL**
   - Once processed: `https://archive.org/download/aetheros-v2.1-iso/aetheros.iso.xz`

#### Using Archive.org CLI (ia)

```bash
# Install Internet Archive CLI
pip install internetarchive

# Configure (first time only)
ia configure

# Upload
ia upload aetheros-v2.1-iso \
  build/artifacts/aetheros.iso.xz \
  build/artifacts/aetheros.iso.xz.sha256 \
  --metadata="title:AetherOS v2.1 - Security Evolution ISO" \
  --metadata="description:Beautiful Ubuntu-based desktop distribution" \
  --metadata="subject:linux;ubuntu;kde;operating-system" \
  --metadata="licenseurl:http://www.apache.org/licenses/LICENSE-2.0"
```

### SourceForge (Fast Global CDN)

SourceForge provides fast downloads worldwide with no cost.

#### Setup

1. **Create Project**
   - Go to: https://sourceforge.net/create
   - Create a new project named "aetheros"

2. **Setup Project**
   - Project details: AetherOS description
   - License: Apache-2.0
   - Categories: Desktop Environments, Operating Systems

3. **Upload via Web**
   - Go to "Files" tab
   - Create folder structure: `aetheros/v2.1/`
   - Upload `aetheros.iso.xz`
   - Upload `aetheros.iso.xz.sha256`
   - Set as default download

4. **Download URL**
   - `https://sourceforge.net/projects/aetheros/files/v2.1/aetheros.iso.xz/download`

#### Using rsync (Faster for Large Files)

```bash
# Upload via rsync (requires SSH key setup)
rsync -avP -e ssh \
  build/artifacts/aetheros.iso.xz \
  build/artifacts/aetheros.iso.xz.sha256 \
  YOUR_USERNAME@frs.sourceforge.net:/home/frs/project/aetheros/v2.1/
```

---

## Best Practices

### Checklist Before Upload

- [ ] ISO builds successfully
- [ ] ISO tested in QEMU
- [ ] Compressed with xz
- [ ] Checksum generated and verified
- [ ] Release notes prepared
- [ ] Version number updated in documentation
- [ ] README updated with new version

### Version Naming

Use semantic versioning:
- Major releases: `v2.0`, `v3.0`
- Minor releases: `v2.1`, `v2.2`
- Patches: `v2.1.1`, `v2.1.2`

### Release Notes Template

```markdown
# AetherOS vX.Y - Codename

**Release Date**: Month Day, Year
**Base**: Ubuntu 24.04 LTS
**Desktop**: KDE Plasma

## 🎉 What's New

- Feature 1
- Feature 2
- Feature 3

## 🐛 Bug Fixes

- Fix 1
- Fix 2

## 📦 Download

- **File**: `aetheros.iso.xz`
- **Size**: ~X.X GB (compressed)
- **Checksum**: `aetheros.iso.xz.sha256`

## 💻 System Requirements

- **Minimum**: 4GB RAM, 20GB disk space
- **Recommended**: 8GB RAM, 30GB disk space

## 📝 Installation

1. Download ISO and checksum
2. Verify: `sha256sum -c aetheros.iso.xz.sha256`
3. Extract: `xz -d aetheros.iso.xz`
4. Create bootable USB with Balena Etcher or Ventoy
5. Boot and install

## 🔗 Links

- [Documentation](https://github.com/Anamitra-Sarkar/Aether_OS/tree/main/docs)
- [Troubleshooting](docs/troubleshooting.md)
- [Report Issues](https://github.com/Anamitra-Sarkar/Aether_OS/issues)
```

### Security Considerations

1. **Always generate and publish checksums**
   - Users should verify before installation
   - Protects against corrupted or tampered downloads

2. **Sign releases (optional but recommended)**
   ```bash
   # Generate GPG signature
   gpg --detach-sign --armor aetheros.iso.xz
   
   # Creates: aetheros.iso.xz.asc
   # Upload this alongside the ISO
   ```

3. **Verify uploads**
   - Download from each mirror
   - Verify checksums match
   - Test boot on different hardware

### Mirror Maintenance

- Update all mirrors when releasing new versions
- Keep at least 2 previous versions available
- Document mirror URLs in README
- Test mirror availability quarterly

### Automation (Future)

Consider automating uploads with GitHub Actions:

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4
      - name: Build ISO
        run: sudo ./build/build.sh
      - name: Compress
        run: |
          cd build/artifacts
          xz -T0 -z -9 aetheros.iso
          sha256sum aetheros.iso.xz > aetheros.iso.xz.sha256
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            build/artifacts/aetheros.iso.xz
            build/artifacts/aetheros.iso.xz.sha256
```

---

## Troubleshooting

### ISO Too Large for GitHub

GitHub has a 2GB file size limit. Our compressed ISO (~2.8GB) exceeds this.

**Solutions:**
1. Use GitHub Releases (supports up to 50GB)
2. Use Git LFS (but it's not free for large files)
3. Use external mirrors (Archive.org, SourceForge)

### Slow Upload Speeds

- Use `rsync` for SourceForge (resume capability)
- Use `gh` CLI for GitHub (automatic retry)
- Upload during off-peak hours

### Checksum Mismatch

If users report checksum mismatches:
1. Re-download from mirror
2. Generate checksum locally
3. Compare with original
4. If different, remove and re-upload

---

## Support

For questions or issues with uploads:
- Open an issue: https://github.com/Anamitra-Sarkar/Aether_OS/issues
- Tag as: `infrastructure`, `release`

---

*Last Updated: December 2024*
