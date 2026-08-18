devin-sdd-harness — split bootstrap, 5 parts, 51 files
sha256 of payload: de6ff16ac7c37bb5a178728e82f88f7bcb3d479002ba9ef17daa002604d7db8e

Paste part-01.sh, then part-02.sh, and so on IN ORDER, into the same terminal.
Each one tells you it stored its chunk. The last one extracts, verifies the
checksum and runs ./init.sh.

A part pasted out of order, or a truncated paste, fails loudly on the checksum
and clears the scratch file. Nothing half-written ever lands on disk.
