# Video Editing

First, get meta-information about the video clip by running `avprobe`.

## Command-line cutting

```
ffmpeg -i MVI_2010.MOV -ss 2 -t 21.5 -acodec copy -vcodec copy out.mov
```


## Blender

- Adjust "Resolution", "Frame rate" in the properties window
- Switch to "Video Editing" window layout
- In the "Video Sequence Editor", use "Add -> Movie" to import a clip
- Use proxies:
  - Enable "Proxy/Timecode" for the strip; set to 25%
  - In the video preview window properties (`N`), set Proxy render size to
    the same 25%
  - "Rebuild proxies and timecode indices"

### Speed

- "Add -> Effect Strip -> Speed"
- Disable "Stretch to input length" and "Use as speed"

### Export to Youtube

See [How can I upload blender videos to youtube?](https://blender.stackexchange.com/questions/24724/how-can-i-upload-blender-videos-to-youtube)

