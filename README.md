# BPMtoOSC
Finally an easy, reliable and free way to keep the Resolume BPM in sync.
Just open the program, enter your resolume IP, set your audio input and hit start!

Since I was looking for something like this to avoid standing there the whole night smashing the spacebar and couldn't find anything samiliar, especially for free, I too matters into my own hands.
The app detects the beats per minute from an audio input and sending (custom) OSC commands to set the BPM-Counter inside Resolume (or any other LJ / VJ Software with OSC input).


If you want to change the OSC commands that are sent or any problems occur, edit or delete the
`%Appdata%\Roaming\BPMtoOSC\lastsession.ini` file.


<a href="url"><img src="https://user-images.githubusercontent.com/8715042/204784228-d0d6669f-5fe1-4689-aa9a-840369e1eebe.gif" align="center" width="500" ></a>


In case you want to edit the code yourself, make sure to use Python 3.9.13 and the package-versions defined in the requirements-windows.txt file (requirements.txt holds the macOS versions, see below).

The beat detection itself was inspired and relies on the work from [DrLuke](https://github.com/DrLuke/aubio-beat-osc).


## macOS

This is a macOS port of [d00mfish/BPM-to-OSC](https://github.com/d00mfish/BPM-to-OSC), licensed under the GPL-3.0 like the original (see `LICENSE`).
It is tested on Apple Silicon only (macOS 27, Python 3.11). Intel Macs and Windows are untested with these changes; the Windows code paths are kept behind platform checks.

### Setup

You need the Xcode Command Line Tools (PyAudio and aubio are compiled during the install) and [Homebrew](https://brew.sh).
Install in exactly this order:

```sh
xcode-select --install                     # skip if already installed
brew install python@3.11 portaudio

cd BPM-to-OSC
/opt/homebrew/bin/python3.11 -m venv .venv
.venv/bin/pip install numpy==1.26.4
CFLAGS="-I/opt/homebrew/include" LDFLAGS="-L/opt/homebrew/lib" .venv/bin/pip install PyAudio==0.2.14
CFLAGS="-Wno-error=incompatible-function-pointer-types" .venv/bin/pip install --no-build-isolation aubio==0.4.9
.venv/bin/pip install -r requirements.txt
```

Why it has to be done this way:
- **Python 3.11 from Homebrew:** wxPython needs a framework build of Python (Homebrew's is one), and the aubio build has only been tested with 3.11.
- **PyAudio** has no macOS wheels. It is built against Homebrew's PortAudio, which isn't on the compiler's default search path on Apple Silicon (`/opt/homebrew`).
- **aubio** has no wheels either. It has to be built against the numpy 1.x that is already installed (`--no-build-isolation`); otherwise pip builds it against numpy 2, which aubio 0.4.9 doesn't support. Current clang also rejects a const-only function pointer mismatch in aubio's `ufuncs.c`. The `CFLAGS` turn that error back into a warning; the mismatch is harmless.

Start the app with:

```sh
./run_mac.sh
```

(or `.venv/bin/python main_gui.py`). To check beat detection in the terminal only, run `.venv/bin/python beatfinder.py`.

### Config file

`~/Library/Application Support/BPMtoOSC/lastsession.ini`

It has the same content as on Windows. Edit it to change the OSC commands, or delete it to reset to the defaults.

### Microphone permission

The first time BPMtoOSC opens an audio input, macOS asks for microphone access for the app you launched it from (Terminal, iTerm, VS Code, ...).
If access is denied there is no error message: the level meter stays empty and no beats are detected.
To fix it, allow that app under **System Settings → Privacy & Security → Microphone** and restart it.

### Resolume

Enable OSC input in Resolume's preferences (OSC tab) and make sure its incoming port matches the port set in BPMtoOSC (default **7000**).
If Resolume runs on the same Mac, use `127.0.0.1` as the IP.

### Testing without Resolume

```sh
.venv/bin/python osc_listen.py            # default 127.0.0.1 7000, or: osc_listen.py <ip> <port>
```

This prints every OSC message BPMtoOSC sends and converts the tempo value back to BPM.
**Only run it while testing:** it binds the same port Resolume listens on, so only one of the two can receive the messages. Stop it with Ctrl+C before a show.
