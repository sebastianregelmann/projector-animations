# Creae Venv
- python -m venv venv
- source ./venv/bin/activate

# Packages

## Raspberry 5:
- wget https://github.com/joan2937/lg/archive/master.zip
- unzip master.zip
- cd lg-master
- make
- sudo make install

- sudo apt install swig build-essential python3-dev
- sudo apt install python3-gpiozero (Only on Raspberry pi 5 -> before pip install - - RPi.GPIO Also small changes in Code depending GPIO) 
- pip install gpiozero
- pip install lgpio
- pip install paho-mqtt

# Start code
- cd src
- python ./Client.py