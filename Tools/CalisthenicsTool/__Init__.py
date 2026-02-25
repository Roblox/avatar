import bpy
from bpy.props import *
from bpy.types import (Panel,
                       Operator,
                       AddonPreferences,
                       PropertyGroup,
                       )
import os
import sys

# Append the dependencies directory to the path so we can access the bundled python modules
add_on_directory = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(add_on_directory, "lib"))


from .lib.animationOP import PlayAnimationOP, DeleteAnimOP
from .lib.attachaccOP import AttachTestAccessoryOP, DetachTestAccessoryOP
from .lib.exportFBXOP import ExportFBX_OP

bl_info = {
    "name": "Calisthenics Tool",
    "author": "Roblox",
    "description": "Assign sample animation to check if the mesh is skinned correcctly.",
    "blender": (3, 2, 0),
    "version": (2, 1, 0), 
    "location": "View3D",
    "warning": "",
    "category": "Import-Export",
}

class globalVariables():
    animationIsPlaying = False
    curentAnim = ""
    originalAvatar = None
    originalStart = None
    originalEnd = None



class RBX_Tools(bpy.types.Panel):
    """The Add-on UI rendered in the 3D viewport"""
    bl_space_type = 'VIEW_3D'
    bl_region_type = 'UI'
    bl_idname = "OBJECT_PT_CALISTHENICS_TOOL"
    bl_label = "Calisthenics Tool"
    bl_category = "Calisthenics Tool"

    build = "Build 10172023.A"


    bpy.types.Scene.Armature = PointerProperty(type=bpy.types.Object)
    bpy.types.Scene.export_folder = StringProperty(default = "   ", subtype='DIR_PATH')
    bpy.types.Scene.playWalkAnim = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.playRunAnim = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.playMoveAnim = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.playIdleAnim = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.normalAccAttached = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.slenderAccAttached = BoolProperty( name = "Boolean", description = "None")
    
    
        

    def draw(self, context):
        layout = self.layout
        scene = context.scene
        required_version = bl_info["blender"]
        if bpy.app.version < required_version:
            draw_blender_update_row(layout, required_version)
            return

        
        row = layout.row()
        row.label(text="Play check animations")
        row1 = layout.row()
        row1.prop_search(scene, "Armature", context.scene, "objects")
        
        
        row2 = layout.row()
        row2A = row2.split()
        if bpy.types.Scene.playWalkAnim == True:
            row2A.alert = True
        row2B = row2.split()
        if bpy.types.Scene.playRunAnim == True:
            row2B.alert = True
        row2C = row2.split()
        if bpy.types.Scene.playMoveAnim == True:
            row2C.alert = True
        row2D = row2.split()
        if bpy.types.Scene.playIdleAnim == True:
            row2D.alert = True
        
        
        op = row2A.operator("mesh.playanimation", text =  "Walk")
        op.animType = "WalkAnimation"
        op2 = row2B.operator("mesh.playanimation", text =  "Run")
        op2.animType = "RunAnimation"
        op3 = row2C.operator("mesh.playanimation", text =  "Move")
        op3.animType = "MoveAnimation"
        op4 = row2D.operator("mesh.playanimation", text =  "Idle")
        op4.animType = "IdleAnimation"
        
        
        row3 = layout.row()
        op5 = row3.operator("mesh.deleteanim", text =  "Stop Animation")


        row4 = layout.row()
        row4.label(text="Attach test accessories")
        row5 = layout.row()
        row5A = row5.split()
        if bpy.types.Scene.normalAccAttached == True:
            row5A.alert = True
        op6 = row5A.operator("mesh.attachtestaccessory", text =  "Normal Size")
        op6.accType = "Normal"
        row5B = row5.split()
        if bpy.types.Scene.slenderAccAttached == True:
            row5B.alert = True
        op7 = row5B.operator("mesh.attachtestaccessory", text =  "Slender Size")
        op7.accType = "Slender"
        row5C = row5.split()
        op7 = row5C.operator("mesh.detachtestaccessory", text =  "Detach Test Accessory")


        row6 = layout.row()
        row6.label(text="Export selected objects as FBX")

        row7 = layout.row()
        row7.prop(context.scene, "export_folder", text="Export Folder")
    
        row8 = layout.row()
        row8.operator("mesh.exportfbx", text = "Export Folder")

        row9 = layout.row()
        row9.label(text = "Roblox   %s  "  %  self.build )

classes = [PlayAnimationOP, DeleteAnimOP, AttachTestAccessoryOP, DetachTestAccessoryOP, ExportFBX_OP, RBX_Tools]



def register():
    for c in classes:
        bpy.utils.register_class(c)

def unregister():
    for c in classes:
        bpy.utils.unregister_class(c)

if __name__ == "__main__":
    register()
        
        
        