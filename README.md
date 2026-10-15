# CUE to CDI Converter
A command-line utility to convert CUE-based disc images into the DiscJuggler format.

cue-2-cdi reads a CUE sheet together with its referenced track files and writes a matching `.cdi` file. It handles data discs, audio CDs, Video CDs, CD+G, and discs that mix data and audio tracks. It does not convert multi-session disc images to CDI (e.g., those commonly used with the SEGA Dreamcast).

Raw sectors are preserved byte-for-byte. Cooked Mode 1 sectors are expanded with their sync pattern, header, EDC, and ECC. Cooked Mode 2 sectors receive their missing sync pattern and header, retaining all 2336 source bytes.

Prebuilt binaries are available for Windows, Linux, and macOS. Each download is a single self-contained executable, so there is no runtime to install.

## Current Version
cue-2-cdi is currently at version 1.0.0.

## Changelog
- **Version 1.0.0** (2026-10-09)
    - Initial release.

## Supported Formats
The following CUE track modes are supported.

- MODE1/2352
- MODE1/2048
- MODE2/2352
- MODE2/2336
- CDI/2352
- CDI/2336
- CDG
- AUDIO

Track data can be stored in BINARY, MOTOROLA, or WAVE source files. WAVE must contain uncompressed 44,100 Hz, stereo, 16-bit PCM audio. Its final partial CD sector is padded with silence. MOTOROLA audio samples are byte-swapped. Data tracks in MOTOROLA files retain their original byte order.

Single-file and multi-file layouts are supported, including different sector sizes within one BINARY file. CUE text can use UTF-8, BOM-marked UTF-16, or Windows-1252. Track numbers must be consecutive, beginning with 01.

Embedded INDEX 00 pregaps, generated PREGAP directives, POSTGAP directives, and INDEX 02 through 99 are retained. A missing first-track pregap is generated to reach at least 150 sectors. An existing first-track pregap is not duplicated. A nonzero first INDEX 01 with no INDEX 00 treats the preceding file bytes as an embedded pregap. Later tracks receive only the gaps described by the CUE.

The converter carries CATALOG, ISRC, PRE, DCP, and 4CH into the CDI descriptor. SCMS audio uses 2448-byte sectors with generated P/Q subchannels, including alternating copy-control bits and catalog/ISRC frames. CDG input preserves its supplied 96-byte interleaved subchannels. Ordinary audio and data tracks use 2352-byte sectors.

TITLE, PERFORMER, SONGWRITER, COMPOSER, ARRANGER, and MESSAGE are encoded as CD-TEXT using ISO-8859-1. CDTEXTFILE preserves raw 18-byte packs, including other CD-TEXT encodings. An optional four-byte MMC CD-TEXT header is accepted. When CDTEXTFILE is present, its packs take precedence over text fields in the CUE. Invalid pack checksums are rejected.

## Usage
cue-2-cdi takes a CUE sheet as its input.

```
cue-2-cdi <input.cue> [output_dir]
```

The first argument is the path to the CUE sheet. The second argument is optional. When it is left out, a folder named `CDI` is created next to the input CUE sheet. When an output folder is given, the output is written directly into that folder. The output takes its name from the input CUE sheet, so `game.cue` produces `game.cdi`.

On Windows, you can also drag a CUE file from File Explorer and drop it onto `cue-2-cdi.exe`.

An existing output file is replaced only after the conversion completes successfully. Input files are never overwritten. Invalid input produces an error and a nonzero exit status.

## Example Usage
Convert a CUE sheet using the default output location.

```
cue-2-cdi "Disc.cue"
```

Choose an output folder.

```
cue-2-cdi "Disc.cue" "Z:\Converted"
```

## Legal and Licensing
cue-2-cdi is licensed under the GNU General Public License v3.0 (GPL-3.0).

Copyright 2026, Derek Pascarella (ateam).

For the full license text, see [LICENSE](LICENSE).

### Acknowledgments
CDI format research used the [libmirage CDI parser](https://github.com/cdemu/cdemu/blob/master/libmirage/images/image-cdi/parser.c), [Aaru DiscJuggler reader](https://github.com/aaru-dps/Aaru/tree/devel/Aaru.Images/DiscJuggler), [CDIrip](https://github.com/jozip/cdirip), and [Padus CDI reader API](https://download.imgburn.com/pfctoc.zip). CD-TEXT and subchannel behavior were checked against libburn, libmirage, cdrtools, and ECMA-394. External readers and their libraries are used for validation and are not bundled with the converter.
