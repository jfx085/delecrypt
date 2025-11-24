# delecrypt

The script uses the AES-256 algorithm (Advanced Encryption Standard with a 256-bit key).

The script generates a completely random encryption key (KEY) and initialization vector (IV) using openssl rand.
It uses this key to encrypt the noise file.
The key is NEVER saved or displayed.
Once the script finishes running, the key is discarded from system memory, making the encrypted file permanently inaccessible.

What the Code Does in 4 Steps
The code transforms each file within the TRASH folder (or the folder defined by the TARGET variable) through a sequence of operations:

1. Secure Wipe (Shred)

Command: shred -n 5 -z -u "$file"

Action: It overwrites the original file content 5 times with random data, and once with zeros (-z). This securely erases the original content from the disk, ensuring it cannot be recovered by data recovery software.

The script then uses the -u (unlink) option to delete the original file.

2. Noise Encryption (AES-256)

Command: openssl enc -aes-256-cbc...

Action: It creates a new temporary random noise file (/dev/urandom) of 1MB.

It encrypts this noise file using the AES-256 one-time key. The result is a file full of useless cryptographic junk that no longer contains the original data.

3. Name Obfuscation (File)

Action: The encrypted noise file is renamed to a completely random 16-character name ($FINAL_NAME).

Extension: The fixed extension .jfx085 is added to make it difficult to identify its purpose.

4. Name Obfuscation (Folder)

Action: After processing all files, the script goes through all subfolders of the TRASH, renaming them also to random 16-character names. This removes any context that might have been provided by the original directory structure.
