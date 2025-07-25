<p align="center">
  <img src="https://readme-typing-svg.herokuapp.com?font=JetBrains+Mono&size=28&color=34ebd8&center=true&vCenter=true&width=900&height=100&lines=🔐+ED4+–+Universal+File+Encryption+Utility;Layered+Bash+Encryption+Made+Powerful;Secure+Anything:+Text,+PDF,+HTML,+etc."/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Bash-100%25-green?style=flat-square&logo=gnu-bash" />
  <img src="https://img.shields.io/github/license/likhil-pidugu/ED4?style=flat-square" />
  <img src="https://img.shields.io/github/stars/likhil-pidugu/ED4?style=flat-square" />
  <img src="https://img.shields.io/github/last-commit/likhil-pidugu/ED4?style=flat-square" />
</p>

---

## 🔥 Overview

**ED4** is a powerful, **multi-layered encryption/decryption utility** written entirely in Bash. It provides a stack of custom-built encryption algorithms based on file permission entropy and delivers universal file protection — from `.txt` and `.sh` to `.pdf` and `.html`.

No external libraries. No magic. Just pure Bash. 🧠

---

## ✨ Features

| Feature                                 | Description |
|----------------------------------------|-------------|
| 🔐 **Four-Layer Encryption Stack**     | Custom encryption pipeline |
| 🧠 **Permission-Based Keying**         | Uses file's chmod entropy |
| 📝 **Smart Logs**                      | Action logs with timestamps |
| 📄 **Smart File Viewer**               | Detects and opens text or browser-based files |
| 💻 **Zero Dependency**                 | Pure Bash + xxd + awk |
| 📦 **Compact Output**                  | Encrypted output in `.enc`, decrypted in `.dec` |

---

## 🔗 Encryption Stack

| Layer | Name                      | Description |
|-------|---------------------------|-------------|
| 1️⃣    | ASCII Byte Shift          | Uses chmod sum for byte rotation |
| 2️⃣    | Reverse + Rotate          | In-place hex manipulation |
| 3️⃣    | **NXR4** Nibble Swapping  | Custom algorithm swaps nibbles |
| 4️⃣    | Base64 + Block Rotation   | Final encoding & reordering |

> 🧪 Example: chmod `755 file` → shift = `7+5+5 = 17`

---

## 🚀 Installation

```bash
git clone https://github.com/likhil-pidugu/ED4.git
cd ED4
chmod +x ed4.sh
./ed4.sh
````

✅ Requires:

* `bash`
* `xxd`
* `awk`
* `base64`
* `xdg-open` or `firefox` or `chromium`

---

## 📦 Usage Menu

```text
1. 🔐 ENCRYPT FILE
2. 🔑 DECRYPT FILE
3. 📄 VIEW FILE
4. 🔍 VIEW LOGS
5. ❌ EXIT
```

### 🔐 Encrypt a File

* Input any file (`.txt`, `.pdf`, `.html`, etc.)
* Applies 4 encryption layers.
* Outputs a `.enc` file.

### 🔑 Decrypt a File

* Reads embedded metadata.
* Reverses all layers.
* Outputs `.dec` file.

### 📄 View File

* `.txt`, `.enc`, `.sh`: shown in terminal
* `.pdf`, `.html`, others: opened in browser or viewer

### 🔍 View Logs

* Shows `encdec.log` (auto-created if missing)
* Each action is timestamped

---

## 🧪 Live Demo

```bash
$ ./ed4.sh
🔐 Choose option 1
Enter file path to encrypt: secret.pdf
✅ Encrypted: secret.pdf.enc

🔑 Choose option 2
Enter .enc file to decrypt: secret.pdf.enc
✅ Decrypted: secret.pdf.dec
```

---

## 📁 Project Structure

.
├── ed4.sh              # Main encryption/decryption script
├── encdec.log          # Log file (auto-generated)
└── .enc_meta/          # (Reserved for future metadata)

---

## 📊 Real-Time Stats (Optional)

<!-- You can embed real-time GitHub stats if hosted -->

![Visitors](https://komarev.com/ghpvc/?username=likhil-pidugu\&label=Profile+Views)
![Lines of Code](https://img.shields.io/tokei/lines/github/likhil-pidugu/ED4)
![Languages](https://img.shields.io/github/languages/top/likhil-pidugu/ED4)

---

## 🧠 Philosophy

> *"Encrypt not just bytes, but behaviors. ED4 evolves based on permissions, so every file is uniquely protected."*
> — **LIKHIL & CO**

---

## 📜 License

Licensed under the [MIT License](LICENSE).
Feel free to fork, improve, and contribute to ED4.

---

## 🙌 Credits

* Developed with ❤️ by **LIKHIL & CO**
* Banner art: [readme-typing-svg](https://github.com/DenverCoder1/readme-typing-svg)
* Inspired by the power of the GNU/Linux terminal.

---

> 🌐 [View Project Repository](https://github.com/likhil-pidugu/ED4)

```

---

### ✅ Next Steps
- Save the above as `README.md`
- Replace `yourusername` with your GitHub username in clone links if needed
- Ensure `LICENSE` file is present (MIT) to avoid badge warnings
- Push your changes to GitHub

Would you like me to generate an HTML preview too or link up `gh-pages` for live README with animations and effects?
```
