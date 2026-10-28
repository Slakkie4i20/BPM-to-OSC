# -*- mode: python ; coding: utf-8 -*-
# PyInstaller spec for the macOS app bundle, used by build_mac.sh

a = Analysis(
    ['main_gui.py'],
    pathex=[],
    binaries=[],
    datas=[],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['tkinter'],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='BPMtoOSC',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=False,
    console=False,  # --windowed
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.datas,
    strip=False,
    upx=False,
    upx_exclude=[],
    name='BPMtoOSC',
)
app = BUNDLE(
    coll,
    name='BPMtoOSC.app',
    icon=None,
    bundle_identifier='io.github.slakkie4i20.bpmtoosc',
    info_plist={
        'CFBundleName': 'BPMtoOSC',
        'CFBundleDisplayName': 'BPMtoOSC',
        'NSMicrophoneUsageDescription': 'BPMtoOSC listens to your audio input to detect the tempo.',
        'NSHighResolutionCapable': True,
        # Homebrew's Python and the compiled PyAudio / aubio modules require macOS 27
        'LSMinimumSystemVersion': '27.0',
    },
)
