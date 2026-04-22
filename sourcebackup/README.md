This folder has every distrubiutions working sources.list -- from when it was freshly installed, nothing was tampered with. If anything goes wrong with -r when you're trying to restore your old sources.list, because yours is now broken, copy the distrubiutions sources.list to /etc/apt/sources.list, so it is now fully restored.
Command to cp:
sudo cp /path/to/sources.list /etc/apt/sources.list

Use this for when something goes wrong.
