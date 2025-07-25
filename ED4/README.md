🔐 ED4 – Universal File Encryption Utility
ED4 is a layered, terminal-based encryption/decryption tool written entirely in Bash. It uses a unique, multi-layered encoding algorithm driven by file permission entropy and offers smooth handling of encrypted files across formats, including text, HTML, PDFs, and more.




✨ Features
🔐 Four-Layer Encryption Stack

Layer 1: ASCII Byte Shift (based on file permission sum)

Layer 2: Reverse + Rotate Hex Streams

Layer 3: NXR4 Nibble Swap Algorithm

Layer 4: Base64 Encoding + Custom Block Shifting

🔑 Secure Decryption with embedded key header

📄 Smart File Viewer (terminal for .txt, .sh, .enc, browser for .pdf, .html)

🧠 Permission-Based Encryption Keying

📝 Action Logging (encdec.log)

💻 Pure Bash – No dependencies apart from core Linux tools

🚀 Installation
bash
Copy
Edit
git clone https://github.com/yourusername/ed4-encryption.git
cd ed4-encryption
chmod +x ed4.sh
./ed4.sh
✅ Works on most Unix-like systems with bash, xxd, awk, base64, and firefox or xdg-open.

📦 Usage
Once you run the script, you’ll see:

markdown
Copy
Edit
1. 🔐 ENCRYPT FILE
2. 🔑 DECRYPT FILE
3. 📄 VIEW FILE
4. 🔍 VIEW LOGS
5. ❌ EXIT
🔐 Encrypt a File
Accepts any file type.

Calculates a unique shift from file permissions (e.g., chmod 755 myfile → 7+5+5 = 17).

Applies 4 transformation layers and outputs a .enc file.

🔑 Decrypt a File
Reads the embedded header to restore the original file accurately.

Outputs a .dec version of the original file.

📄 View File
Smart detection based on file extension:

Text files shown in-terminal.

PDFs/HTML opened in browser.

Others handled via xdg-open.

🔍 View Logs
View a full activity log (encdec.log) with timestamps and step records.

🔐 Encryption Stack Details
Layer	Description	Method
1	ASCII Byte Shift	Binary-safe, xxd+awk based, uses chmod-derived shift
2	Reverse+Rotate	Hex reversed in-place, then piped back
3	NXR4 Algorithm	Bytewise nibble swapping (high ↔ low bits) via awk
4	Base64 + 4-block rotation	Encoded string sliced, reordered, and rejoined

🧪 Example
bash
Copy
Edit
$ ./ed4.sh
# Choose option 1
Enter file path to encrypt: secret.pdf
Encrypted: secret.pdf.enc ✅

# Then decrypt later
Choose option 2
Enter .enc file to decrypt: secret.pdf.enc
Decrypted: secret.pdf.dec ✅
📁 Project Structure
bash
Copy
Edit
.
├── ed4.sh              # Main script
├── encdec.log          # Log file (auto-generated)
└── .enc_meta/          # (Unused placeholder directory)
⚠️ Requirements
bash

xxd

awk

base64

firefox or xdg-open or chromium

📜 License
MIT License. Feel free to fork, contribute, and improve.

🙌 Credits
Developed by LIKHIL & CO

Banner art and encryption logic crafted with ❤️ in the terminal.

