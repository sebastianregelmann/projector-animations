# Configs

Raspberry Pi Login Data:
host: projectorpi.local
user: projector
passwort: passwort

# Make executable
chmod +x ProjectorAnimation.arm64
./ProjectorAnimation.arm64


# Folder Structure

root/
├── Executable/
│  
├── Config/
│   ├── Config.json
│
├── Animations
    ├── Animation_1
    │   ├── 001.png
    │   ├── 002.png
    │   ├── ....png
    ├── DefaultImage_1
    │   ├── Image.png
    │
    ├── Animation_2
    │   ├── 001.png
    │   ├── 002.png
    │   ├── ....png
    ├── DefaultImage_2
        ├── Image.png
