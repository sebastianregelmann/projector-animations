# Make executable
```chmod +x ProjectorAnimation.arm64```

```./ProjectorAnimation.arm64```


# Folder Structure
```
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
```
# Config Settings
## MQTT Settings
```
    "MQTT-Config": {
        "IP": "192.168.188.105",
        "PORT": "9001",
        "CLIENT-ID": "user_1",
        "USER": "user",
        "PASSWORD": "password",
        "PROTOCOL": "ws"
    },

```

## Animation Settings
* Settings for MQTT-Message that cancles running animation and displays an Image
```
    "MQTT-ANIMATION-CANCEL": [
        {
            "SUBSCRIBE": "transit/drive/stop",
            "PAYLOAD": "\"command\":\"stop\"",
            "DEFAULT-IMAGE": "Animations/Default_Black"
        }
    ],
```

* Settings for MQTT-MEssage that loops a animation
```
    "MQTT-ANIMATION-LOOP": [
        {
            "SUBSCRIBE": "transit/update/status",
            "PAYLOAD": "\"angle\": -90",
            "IMAGES": "Animations/angle_-90",
            "ANIMATION-DURATION": 1
        },
    ]
```

* Settings for MQTT-Message that plays a specific number of times and cancels then
```
    "MQTT-ANIMATION-COUNT": [
        {
            "SUBSCRIBE": "system/status",
            "PAYLOAD": "Start Count",
            "IMAGES": "Animations/angle_0",
            "DEFAULT-IMAGE": "Animations/Default_Black",
            "ANIMATION-DURATION": 1.0,
            "ANIMATION-COUNT": 5
        }
    ]
```