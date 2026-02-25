import sys
import os
import maya.cmds as cmds

fullPathToScriptFolder = None
userScriptDirectoryPath = cmds.internalVar(usd=True)
fullPathToScriptFolder = userScriptDirectoryPath.replace("scripts/", r"prefs/scripts/ValidationTool/")

if os.name == "nt":
    fullPathToScriptFolder = fullPathToScriptFolder.replace("/", "\\")
sys.path.insert(0,fullPathToScriptFolder)
from core import validationTool