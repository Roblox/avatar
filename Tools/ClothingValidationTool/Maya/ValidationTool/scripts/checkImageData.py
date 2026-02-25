from PIL import Image
import os
import sys
from glob import glob


args = sys.argv
dir = args[1]

imagelist = []
for path, subdir ,files in  os.walk(dir):
    for name in files:
        if name.endswith(".png"):
            fullpath = os.path.join(path, name)
            if os.name == 'nt':
                fullpath = fullpath.replace("\\", "/")
            imagelist.append(fullpath)

for img in imagelist:
    with Image.open(img) as im:
        size = im.size
        mode = im.mode
        filename = img.split("/")[-1]
        if mode == "RGB":
            color = "24bit"
        elif mode == "L":
            color = "8bit"
        elif mode == "RGBA":
            color = "32bit"
        sys.stdout.write(str(filename) + ";" + str(size[0]) +":"+ str(size[1]) + ";" + color + ";")