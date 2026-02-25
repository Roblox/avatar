bl_info = {
    "name": "Validation Tool",
    "author": "Roblox",
    "version": (1, 0),
    "blender": (3, 00, 0),
    "location": "Sidebar",
    "description": "Validates LC assets requirements for uploading",
    "warning": "",
    "wiki_url": "",
    "category": "Object",
}


import bpy
import os
import glob
import numpy as np
import mathutils
from mathutils.bvhtree import BVHTree
from bpy.props import *


class globalVariables():
    bl_idname = "mesh.globalvariables"
    bl_label = "Global Variables"
    
    wrongPositions_Attachment = []
    wrongNames_Attachment = []
    wrongTransformObjs = {}
    objectsWithKeys = []
    ResultMessage = "Hello World"
    clothingObjs = []
    version = "Version 1.0(Build 2022.9.7.a) Roblox"
    

def checkViewLayers():
    layerCheck = False
    for scene in bpy.data.scenes:
        if len(scene.view_layers) >= 2:
            for layer in scene.view_layers:
                layerCheck = False
        else:
            layerCheck = True
    return layerCheck

def deleteViewLayers():
    layerCheck = False
    for scene in bpy.data.scenes:
        if len(scene.view_layers) >= 2:
            for layer in scene.view_layers:
                if len(scene.view_layers) != 1 and layer.name != bpy.context.view_layer.name:
                    bpy.context.scene.view_layers.remove(layer)
            layerCheck = True
        else:
            layerCheck = True
    return layerCheck


def checkKeyframes():   
    objectsWithKeys = []
    
    objs =  bpy.context.scene.objects

    objectsWithKeys = []
    for obj in objs:
        if obj.animation_data != None:
            objectsWithKeys.append(obj)
    
    if len(objectsWithKeys) != 0:
        return  objectsWithKeys
    else:
        return  True


##Delete key frames -- based on the list from checkKeyFrames(). Remove keyframes from the object.
def deleteKeyFrames(objList):
    result = False
    if len(objList) != 0:
        for obj in objList:
            if obj.animation_data != 0:
                obj.animation_data_clear()
        for obj in objList:
            if obj.animation_data:
                result = False
            else:
                result = True
                
    return result


def checkAttachmentPoints():
    objs =  bpy.context.scene.objects

    wrongPositions = []
    wrongNames = []
    attachmentCheck = False

    for obj in objs:
        if obj.name.endswith("_Att") and obj.parent == bpy.data.objects["Armature"]:
            attachPoint = obj
            attachPoint_Name = obj.name
            parentBone = obj.parent_bone
            
            if attachPoint_Name == "FaceFront_Att":
                if parentBone != "Head":
                    wrongPositions.append([attachPoint, parentBone, "Head"])
            elif attachPoint_Name == "Hat_Att":
                if parentBone != "Head":
                    wrongPositions.append([attachPoint, parentBone, "Head"])
            elif attachPoint_Name == "Hair_Att":
                if parentBone != "Head":
                    wrongPositions.append([attachPoint, parentBone, "Head"])
            elif attachPoint_Name == "FaceCenter_Att":
                if parentBone != "Head":
                    wrongPositions.append([attachPoint, parentBone, "Head"])
            elif attachPoint_Name == "LeftGrip_Att":
                if parentBone != "LeftHand":
                    wrongPositions.append([attachPoint, parentBone, "LeftHand"])
            elif attachPoint_Name == "LeftShoulder_Att":
                if parentBone != "LeftUpperArm":
                    wrongPositions.append([attachPoint, parentBone, "LeftUpperArm"])
            elif attachPoint_Name == "RightGrip_Att":
                if parentBone != "RightHand":
                    wrongPositions.append([attachPoint, parentBone, "RightHand"])
            elif attachPoint_Name == "RightShoulder_Att":
                if parentBone != "RightUpperArm":
                    wrongPositions.append([attachPoint, parentBone, "RightUpperArm"])
            elif attachPoint_Name == "BodyFront_Att":
                if parentBone != "UpperTorso":
                    wrongPositions.append([attachPoint, parentBone, "UpperTorso"])
            elif attachPoint_Name == "BodyBack_Att":
                if parentBone != "UpperTorso":
                    wrongPositions.append([attachPoint, parentBone, "UpperTorso"])
            elif attachPoint_Name == "LeftCollar_Att":
                if parentBone != "UpperTorso":
                    wrongPositions.append([attachPoint, parentBone, "UpperTorso"])
            elif attachPoint_Name == "Neck_Att":
                if parentBone != "UpperTorso":
                    wrongPositions.append([attachPoint, parentBone, "UpperTorso"])
            elif attachPoint_Name == "RightCollar_Att":
                if parentBone != "UpperTorso":
                    wrongPositions.append([attachPoint, parentBone, "UpperTorso"])
            elif attachPoint_Name == "LeftFoot_Att":
                if parentBone != "LeftFoot":
                    wrongPositions.append([attachPoint, parentBone, "LeftFoot"])
            elif attachPoint_Name == "RightFoot_Att":
                if parentBone != "RightFoot":
                    wrongPositions.append([attachPoint, parentBone, "RightFoot"])
            elif attachPoint_Name == "WaistFront_Att":
                if parentBone != "LowerTorso":
                    wrongPositions.append([attachPoint, parentBone, "LowerTorso"])
            elif attachPoint_Name == "WaistBack_Att":
                if parentBone != "LowerTorso":
                    wrongPositions.append([attachPoint, parentBone, "LowerTorso"])
            elif attachPoint_Name == "WaistCenter_Att":
                if  parentBone != "LowerTorso":
                    wrongPositions.append([attachPoint, parentBone, "LowerTorso"])
            elif attachPoint_Name == "Root_Att":
                if parentBone != "Root":
                    wrongPositions.append([attachPoint, parentBone, "Root"])
            else:
                wrongNames.append([attachPoint, parentBone])

    result = []

    if len(wrongPositions) != 0 or len(wrongNames) != 0:
        return [wrongPositions, wrongNames]
    else:
        return True

def checkTransform(clothingObjs):
    wrongPositionObjs = {}

    for clothingObj in clothingObjs: 
        wrongValues = []
        lx = clothingObj.location[0]
        if lx != 0.0000:
            wrongValues.append("location X")

        ly = clothingObj.location[1]
        if ly != 0.0000:
            wrongValues.append("location Y")

        lz = clothingObj.location[2]
        if lz != 0.0000:
            wrongValues.append("location Z")
            

        rx = clothingObj.rotation_euler[0]
        if rx != 0.0000:
            wrongValues.append("rotation X")

        ry = clothingObj.rotation_euler[1]
        if ry != 0.0000:
            wrongValues.append("rotation Y")

        rz = clothingObj.rotation_euler[2]
        if rz != 0.0000:
            wrongValues.append("rotation Z")
            
            
        sx = clothingObj.scale[0]
        if sx != 1.000:
            wrongValues.append("scale X")

        sy = clothingObj.scale[1]
        if sy != 1.000:
            wrongValues.append("scale Y")

        sz = clothingObj.scale[2]
        if sz != 1.000:
            wrongValues.append("scale Z")

        if len(wrongValues) != 0:
            wrongPositionObjs[clothingObj.name] = wrongValues
            print(clothingObj.name, wrongValues)
        
        
    if len(wrongPositionObjs) != 0:
        return wrongPositionObjs
    else:
        return True

def deleteTransform(wrongObjsList):
    failed = []
    if len(wrongObjsList)  != 0:
        for obj in wrongObjsList:
            clothingObj = bpy.data.objects[obj]
            clothingObj.select_set(True)
            bpy.context.view_layer.objects.active = clothingObj
            try:
                bpy.ops.object.transform_apply(location=True, rotation=True, scale=True)
            except:
                failed.appened(obj)
    if len(failed) == 0:
        return True
    else:
        return False


def checkUnusedData():
    unusedData = []

    datatypeList = [
                bpy.data.actions,
                bpy.data.armatures,
#                bpy.data.brushes,
                bpy.data.cache_files,
                bpy.data.cameras,
                bpy.data.collections,
                bpy.data.curves,
                bpy.data.fonts,
                bpy.data.grease_pencils,
                bpy.data.images,
                bpy.data.lattices,
                bpy.data.libraries,
                bpy.data.lightprobes,
                bpy.data.lights,
                bpy.data.linestyles,
                bpy.data.masks,
                bpy.data.materials,
                bpy.data.metaballs,
                bpy.data.meshes,
                bpy.data.movieclips,
                bpy.data.node_groups,
                bpy.data.objects,
                bpy.data.paint_curves,
                bpy.data.palettes,
                bpy.data.particles,
                bpy.data.scenes,
                bpy.data.screens,
                bpy.data.shape_keys,
                bpy.data.sounds,
                bpy.data.speakers,
#                bpy.data.texts,
                bpy.data.textures,
                bpy.data.volumes,
                bpy.data.window_managers,
                bpy.data.worlds,
                bpy.data.workspaces,]

    for datatype in datatypeList:
        for bpy_data_iter in datatype:
            if bpy_data_iter.users == bpy_data_iter.use_fake_user:
                unusedData.append(bpy_data_iter)
                print(bpy_data_iter)
    
    
    results = []
    if len(unusedData) == 0:
        return True
    else:
        return False
        
        


def relocateAttachPoints(wrongPositionsAttachment, wrongNamesAttachment):
    positionFix = False
    nameFix = False
    attachmentCheck = False
    
    if len(wrongPositionsAttachment) != 0:
        for attachPoint in wrongPositionsAttachment:
            attachPoint[0].parent_bone = attachPoint[2]
        positionFix = True
    else:
        positionFix = True
    
    if len(wrongNamesAttachment) != 0:
        for attachPoint in wrongNamesAttachment:
            print(attachPoint)
        nameFix = False
    else:
        nameFix = True
    
    if positionFix == True and  nameFix == True:
        attachmentCheck = True
    
    return attachmentCheck

def imageFormatCheck(dir):
    imageFormatCheck = False
    wrongSize = []
    wrongFormat = []
    if dir != None:
        path = dir.replace("\\", "\\")
        files = os.listdir(path)
        filelist = {".png" : []}    
    
        for f in files:
            if f.endswith(".png"):
                filelist[".png"].append(f)
        
        for f in filelist:
            for file in filelist[f]:
                fullpath = path + file
                bpy.ops.image.open(filepath=fullpath)
                name = file
                try:
                    img = bpy.data.images[name]
                    depth = img.depth
#                    print(depth)
                    if "_ALB" in name or "_NOR" in name:
                        if depth != 24:
                            wrongFormat.append(file)
                    elif "_MET" in name or "_RGH" in name:
                        if depth != 8:
                            wrongFormat.append(file)
                    else:
                        imageFormatCheck = False
                    
                    size = img.size[0]
                    if (size > 0) and (size & (size - 1 )) == 0:
                        if 256 <= size <= 1024:
                            if "TXT_LCL_" in file:
                                if size != img.size[1]:
                                    wrongSize.append(file)
                            else:
                                if size == 1024:
                                    if size != img.size[1]:
                                        wrongSize.append(file)
                                else:
                                    wrongSize.append(file)   
                        else:
                            wrongSize.append(file)
                    else:
                        wrongSize.append(file)
                except:
                    pass
        
        
        if len(wrongFormat) == 0 and len(wrongSize) == 0:
            return  True
        else:
            return [wrongFormat, wrongSize]

def checkIntersection(cage, clothingGeoName):
    outerCage = None
    innerCage = None
    clothingObj = None
    
    intersectionCheck = True
    
    ##Scene must have "_OuterCage" and "InnerCage " object.

#    objs =  bpy.context.scene.objects
#    for obj in objs:
#        if obj.name.endswith("_OuterCage"):
#            outerCage = obj
#            
#        elif obj.name.endswith("_InnerCage"):
#            innerCage = obj


#    clothingGeoName = outerCage.name.split("_OuterCage")[0]
    outerCage = bpy.data.objects[clothingGeoName + "_OuterCage"]
    innerCage = bpy.data.objects[clothingGeoName + "_InnerCage"]
    clothingObj = bpy.data.objects[clothingGeoName]
    
    ##--Change deselection processs--##
    bpy.context.view_layer.objects.active = bpy.data.objects[clothingGeoName]
    bpy.ops.object.editmode_toggle()
    bpy.ops.mesh.select_all(action='DESELECT')
    bpy.ops.object.editmode_toggle()
            
    
    depsgraph_1 = bpy.context.evaluated_depsgraph_get()
    if cage == "outer":
        collision_Object = outerCage
    if cage == "inner":
        collision_Object = innerCage
    bvhtree_Out = BVHTree.FromObject(collision_Object, depsgraph_1)


    depsgraph = bpy.context.evaluated_depsgraph_get()
    clothing_Object = clothingObj
    bvhtree_Clothing = BVHTree.FromObject(clothing_Object, depsgraph)
    
    
    
    
    

    list = bvhtree_Out.overlap(bvhtree_Clothing)
   
    
    if len(list) != 0:
        return list
    else:
        return intersectionCheck



def ShowMessageBox(message):
    
    def draw(self, context):
        for line in message:
            self.layout.label(text=line)
            
    bpy.context.window_manager.popup_menu(draw, title="Validation Result", icon = "INFO")


def add_item(collection, itemname, message):
    item = collection.add()
    item.name = itemname
    item.type = itemname
    item.message = message

def remove_item(collection, itemname):
    for i in collection.keys():
        if i == itemname:
            collection.remove(collection.find(itemname))
    
    if len(collection) == 0:
        bpy.context.scene.checkResult_all = False
        

def getClothingObjs():
    outerCages = []
    clothingObjs = []
    objs =  bpy.context.scene.objects
    for obj in objs:
        if obj.name.endswith("_OuterCage"):
            outerCages.append(obj)
    
    if len(outerCages) >= 2:
        for cage in outerCages:
            clothingGeoName = cage.name.split("_OuterCage")[0]
            clothingObj = bpy.data.objects[clothingGeoName]
            clothingObjs.append(clothingObj)
    elif len(outerCages) == 1:
            clothingGeoName = outerCages[0].name.split("_OuterCage")[0]
            clothingObj = bpy.data.objects[clothingGeoName]
            clothingObjs.append(clothingObj)
    
    return clothingObjs
    


class CUSTOM_objectCollection(bpy.types.PropertyGroup):
    #name: StringProperty() -> Instantiated by default
    type: StringProperty()
    message: StringProperty()
    id: IntProperty()

class CUSTOM_OT_clearList(bpy.types.Operator):
    bl_idname = "custom.clear_list"
    bl_label = "Clear List"
    bl_description = "Close the error report panel"

    @classmethod
    def poll(cls, context):
        return bool(context.scene.custom)

    def invoke(self, context, event):
        return context.window_manager.invoke_confirm(self, event)

    def execute(self, context):
        if bool(context.scene.custom):
            context.scene.custom.clear()
            context.scene.checkResult_all = False
            self.report({'INFO'}, "All items removed")
        else:
            self.report({'INFO'}, "Nothing to remove")
        return{'FINISHED'}
    

class MATERIAL_UL_matslots_example(bpy.types.UIList):
    def draw_item(self, context, layout, data, item, icon, active_data, active_propname):
        layout.prop(item, "message", text= item.type, emboss=False, icon_value=icon)



class ValidationToolMainPanel(bpy.types.Panel, globalVariables):
    bl_label = "Validation Tool"
    bl_idname = "OBJECT_PT_Validation"
    bl_space_type = 'VIEW_3D'
    bl_category = "LC Validation Tool"
    bl_region_type = 'UI'
    
    
    bpy.types.Scene.texture_folder = StringProperty(default = "", subtype='DIR_PATH')
    bpy.types.Scene.checkResult_Layers = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_AttachPonits = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_Transform = BoolProperty(name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_UnusedData = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_KeyFrames = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_FileNames = BoolProperty( name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_ImageFormat = BoolProperty(name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_Intersection_Outer = BoolProperty(name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_Intersection_Inner = BoolProperty(name = "Boolean", description = "None")
    bpy.types.Scene.checkResult_all = BoolProperty( name = "Boolean", description = "None")

    def initSceneProperties(scn):
        scn.checkResult_Layers = True
        scn.checkResult_Transform = True
        scn.checkResult_UnusedData = True
        scn.checkResult_KeyFrames = True
        scn.checkResult_AttachPonits = True
        scn.checkResult_Intersection_Outer = True
        scn.checkResult_Intersection_Inner = True
        scn.checkResult_ImageFormat = True
        scn.checkResult_all  = False
        return


    def draw(self, context):
        scn = context.scene
        layout = self.layout
        
        obj = context.object

        layout.prop(context.scene, "texture_folder", text="Texture Folder")

        row = layout.row()
        row.label(text="Run all check points")
        
        row1 = layout.row()
        row1.operator("mesh.initialcheck", text =  "Check Assets")
        
        
        row2 = layout.row()
        row2.label(text="Check or fix each check points")
        
        row3 = layout.row()
        if scn.checkResult_Layers == True:
            row3.alert = False
        else:
            row3.alert = True
        row3.operator("mesh.fixlayer", text =  " View layer check")
        
        row4 = layout.row()
        if scn.checkResult_Transform == True:
            row4.alert = False
        else:
            row4.alert = True
        row4.operator("mesh.transform", text =  "Transform check")
        
        row5 = layout.row()
        if scn.checkResult_UnusedData == True:
            row5.alert = False
        else:
            row5.alert = True
        row5.operator("mesh.fixunuseddata", text =  "Unused material check")
        
        row6 = layout.row()
        if scn.checkResult_KeyFrames == True:
            row6.alert = False
        else:
            row6.alert = True
        row6.operator("mesh.fixkeyframes", text =  "Keyframe check")
                
        
        row7 = layout.row()
        if scn.checkResult_AttachPonits == True:
            row7.alert = False
        else:
            row7.alert = True
        row7.operator("mesh.fixattachmentpoints", text =  "Attachment position and name check")
        
        
        row8 = layout.row()
        if scn.checkResult_Intersection_Outer == True:
            row8.alert = False
        else:
            row8.alert = True
        row8.operator("mesh.fixintersectionsouter", text =  "Cloth intersection check (OuterCage)")

        row9 = layout.row()
        if scn.checkResult_Intersection_Inner == True:
            row9.alert = False
        else:
            row9.alert = True
        row9.operator("mesh.fixintersectionsinner", text =  "Cloth intersection check (InnerCage)")
        

        row10 = layout.row()
        if scn.checkResult_ImageFormat == True:
            row10.alert = False
        else:
            row10.alert = True
        row10.operator("mesh.fiximageformat", text =  "Image format")

            
        if scn.checkResult_all == True:
            layout.template_list("MATERIAL_UL_matslots_example", "", scn, "custom", scn, "custom_index")
            
            row = layout.row()
            row.operator("custom.clear_list", text = "Clear and hide result box.")
        

        row11 = layout.row()
        row11.label(text= globalVariables.version)
        


class ConfirmBox_Layer(bpy.types.Operator, ValidationToolMainPanel):
    bl_idname = "wm.confirmboxlayer"
    bl_label =  "Layer Check"


    def execute(self, context):
        scn = context.scene
        result = deleteViewLayers()
        if result == True:
            scn.checkResult_Layers = True
            remove_item(scn.custom, "Layer")
        else:
            scn.checkResult_Layers = False
        return {'FINISHED'}
    
    def draw(self, context):
        msg = ["There are more than 1 layers.", "Would you like to delete them?"]
        for line in msg:
            self.layout.label(text= line)

    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self)
        
class Fix_Layer(bpy.types.Operator, ValidationToolMainPanel):
    bl_idname = "mesh.fixlayer"
    bl_label = "Layer Fix"
    bl_description = "<Check if there are extra view layers>\nIf more than 1 view layer, It'll delete extra view layers except current active layer"
    
    def execute(self, context):
        scn = context.scene
        result = checkViewLayers()
        if result == True:
            message = ["Layer is ok."]
            ShowMessageBox(message)
            scn.checkResult_Layers = True
            remove_item(scn.custom, "Layer")
        else:
            scn.checkResult_Layers = False
            bpy.ops.wm.confirmboxlayer("INVOKE_DEFAULT")
        return {"FINISHED"}

class ConfirmBox_Transform(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "wm.confirmboxtransform"
    bl_label =  "Transform check"

    def execute(self, context):
        bpy.ops.object.mode_set(mode='OBJECT')
        scn = context.scene
        result = deleteTransform(globalVariables.wrongTransformObjs)
        if result == True:
            scn.checkResult_Transform = True
            remove_item(scn.custom, "Transform")
        else:
            scn.checkResult_Transform = False
        return {'FINISHED'}
    
    def draw(self, context):
        msg = ["Clothing geometries have values.", "Would you like to freeze the objects?", "[Note] This may change rigging result"]
        for line in msg:
            self.layout.label(text= line)

    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self)


class Fix_Transform(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "mesh.transform"
    bl_label = "Transform Fix"
    bl_description = "<Check if clothing geometries has a transform values>\n If Location, Rotation is NOT 0.0, and Scale is NOT 1.0\nThis button will try to fix it"
    
    def execute(self, context):
        scn = context.scene
        globalVariables.clothingObjs = getClothingObjs()
        if len(globalVariables.clothingObjs) != 0:
            result = checkTransform(globalVariables.clothingObjs)
            if result == True:
                message = ["Transform is ok."]
                ShowMessageBox(message)
                scn.checkResult_Transform = True
            else:
                globalVariables.wrongTransformObjs = result
                bpy.ops.wm.confirmboxtransform("INVOKE_DEFAULT")
                scn.checkResult_Transform = False
            return {"FINISHED"}
        else:
            confirmmessage = ["There is no cloth geometry in the scene."]
            ShowMessageBox(confirmmessage)
            return {"FINISHED"}



class ConfirmBox_KeyFrame(bpy.types.Operator, ValidationToolMainPanel):
    bl_idname = "wm.confirmboxkeyframe"
    bl_label =  "Keyframe Check"

    def execute(self, context):
        scn = context.scene
        result = deleteKeyFrames(globalVariables.objectsWithKeys)      
        bpy.data.orphans_purge()
        if result == True:
            scn.checkResult_KeyFrames = True
            remove_item(scn.custom, "KeyFrame")
        else:
            scn.checkResult_KeyFrames = False
              
        return {'FINISHED'}
    
    def draw(self, context):
        msg = ["There are keyframes in this scene. Would you like to delete them?"]
        for line in msg:
            self.layout.label(text= line)

    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self)



class Fix_KeyFrames(bpy.types.Operator, ValidationToolMainPanel):
    bl_idname = "mesh.fixkeyframes"
    bl_label = "KeyFrame Fix"
    bl_description = "<Check if clothing geometries has a Keyframes>\nIf there is a keyframe on geometry, This button will report as an error, and try to remove keyframes"
    
    def execute(self, context):
        scn = context.scene
        globalVariables.clothingObjs = getClothingObjs()
        if len(globalVariables.clothingObjs) != 0:
            result = checkKeyframes()
            if result == True:
                message = ["Keyframe is ok."]
                ShowMessageBox(message)
                scn.checkResult_KeyFrames = True
                remove_item(scn.custom, "KeyFrame")
            else:
                globalVariables.objectsWithKeys = result
                scn.checkResult_KeyFrames = False
                bpy.ops.wm.confirmboxkeyframe("INVOKE_DEFAULT")
            return {"FINISHED"}
        else:
            confirmmessage = ["There is no cloth geometry in the scene."]
            ShowMessageBox(confirmmessage)
            return {"FINISHED"}


class ConfirmBox_AttachmentPoints(bpy.types.Operator, ValidationToolMainPanel):
    bl_idname = "wm.confirmboxattpt"
    bl_label =  "Attachment point Check"


    def execute(self, context):
        scn = context.scene
        # result = deleteKeyFrames(globalVariables.objectsWithKeys)
        if len(globalVariables.wrongPositions_Attachment) != 0:
            result = relocateAttachPoints(globalVariables.wrongPositions_Attachment, globalVariables.wrongNames_Attachment)
        else:
            if len(globalVariables.wrongPositions_Attachment) == 0 and len(globalVariables.wrongNames_Attachment) == 0:
                result = True
                remove_item(scn.custom, "AttPoint_Position")
                remove_item(scn.custom, "AttPoint_Name")
            else:
                result = False 
        if result == True:
            scn.checkResult_AttachPonits = True
            remove_item(scn.custom, "AttPoint_Position")
            remove_item(scn.custom, "AttPoint_Name")
        else:
            scn.checkResult_AttachPonits = False
              
        return {'FINISHED'}
    
    def draw(self, context):
        message = []
        if len(globalVariables.wrongPositions_Attachment) != 0:
            message.append("There are wrong position attachment. Would you like to fix positions?")
            for att in globalVariables.wrongPositions_Attachment:
                message.append(att[0].name)
            message.append(" ")
                
        if len(globalVariables.wrongNames_Attachment) != 0:
            message.append("There are wrong name attachment. Please check follwing attachment name.")
            for att in globalVariables.wrongNames_Attachment:
                message.append(att[0].name)
            message.append(" ")

        for line in message:
            self.layout.label(text= line)

    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self)


class Fix_AttachmentPoints(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "mesh.fixattachmentpoints"
    bl_label = "Attachmentpoints Fix"
    bl_description = "<Check attachment points parent bone and naming convention>\nIf any points have a wrong parent bone,this will re-parent attachment point to the correct bone.\nIf the naming convention was different, this will report as an error"
    
    def execute(self, context):
        scn = context.scene
        globalVariables.clothingObjs = getClothingObjs()
        if len(globalVariables.clothingObjs) != 0:
            result = checkAttachmentPoints()
            if result == True:
                message = ["Attachment points are ok."]
                ShowMessageBox(message)
                remove_item(scn.custom, "AttPoint_Position")
                remove_item(scn.custom, "AttPoint_Name")
                scn.checkResult_AttachPonits = True
            else:
                globalVariables.wrongPositions_Attachment = result[0] 
                globalVariables.wrongNames_Attachment = result[1]
                scn.checkResult_AttachPonits = False
                bpy.ops.wm.confirmboxattpt("INVOKE_DEFAULT")
            return {"FINISHED"}
        else:
            confirmmessage = ["There is no cloth geometry in the scene."]
            ShowMessageBox(confirmmessage)
            return {"FINISHED"}


class ConfirmBox_UnusedData(bpy.types.Operator, ValidationToolMainPanel):
    bl_idname = "wm.confirmboxunuseddata"
    bl_label =  "Errant Data"

    def execute(self, context):
        print("Unused")
        scn = context.scene
        bpy.ops.object.mode_set(mode='OBJECT')
        bpy.data.orphans_purge()
        result = checkUnusedData()
        if result == True:
            remove_item(scn.custom, "Unused")
            scn.checkResult_UnusedData = True
        else:
            message = "There are still unused data. Check Orphan data list."
            add_item(scn.custom, "Unused", message)
            scn.checkResult_UnusedData = False
        return {'FINISHED'}
    
    def draw(self, context):
        msg = ["There are unused item in this scene.", "Would you like to delete them?"]
        for line in msg:
            self.layout.label(text= line)

    def invoke(self, context, event):
        return context.window_manager.invoke_props_dialog(self)

class Fix_UnusedData(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "mesh.fixunuseddata"
    bl_label = "UnusedData Fix"
    bl_description = "<Check the unused materials and textures>\nIf there are any unsed materials or textures in this scene,\nthis button will try to delete them"
    
    def execute(self, context):
        scn = context.scene
        results = checkUnusedData()
        if results == True:
            remove_item(scn.custom, "Unused")
            message = ["No unused data"]
            ShowMessageBox(message)
            scn.checkResult_UnusedData = True
        else:
            bpy.ops.wm.confirmboxunuseddata("INVOKE_DEFAULT")
            scn.checkResult_UnusedData = False
        return {"FINISHED"}

class Fix_ImageFormat(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "mesh.fiximageformat"
    bl_label = "ImageFormat Fix"
    bl_description = "<Check if texture files meet the image format requirement>\nThis will check texture size, bit depth."
    
    def execute(self, context):
        scn = context.scene
        path = context.scene.texture_folder
        if len(path) != 0:
            imageformatResults = imageFormatCheck(path)
            remove_item(scn.custom, "ColorDepth")
            remove_item(scn.custom, "ImageSize")
            if imageformatResults == True:
                message = ["Texture format is ok."]
                ShowMessageBox(message)
                scn.checkResult_ImageFormat = True
            else:
                message = ["Following image files does not meet image format."]
                scn.checkResult_ImageFormat = False
                wrongColor = imageformatResults[0]
                wrongSize = imageformatResults[1]
                if len(wrongColor) != 0:
                    message.append("COLOR DEPTH ERRORS")
                    for f in wrongColor:
                        message.append(f)
                        add_item(scn.custom, "ColorDepth", f)
                    message.append(" ")
                    
                if len(wrongSize) != 0:
                    message.append("SIZE ERRORS")
                    for f in wrongSize:
                        message.append(f)
                        add_item(scn.custom, "ImageSize", f)
                    message.append(" ")
                scn.checkResult_all = True
                ShowMessageBox(message)
        else:
            message = ["Please select the texture folder."]
            ShowMessageBox(message)
        
        return {"FINISHED"}

class Fix_InterSections_Outer(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "mesh.fixintersectionsouter"
    bl_label = "Intersection Fix Outer"
    bl_description = "<Check intersections between clothing geometry and cage>\nIf there are possible interesections, It will be indicated as a selected face in 3D viewport"
    
    def execute(self, context):
        bpy.ops.object.mode_set(mode='OBJECT')
        # bpy.context.view_layer.objects.active = None
        scn = context.scene
        globalVariables.clothingObjs = getClothingObjs()

        if len(globalVariables.clothingObjs) != 0:
            clothingObjects = globalVariables.clothingObjs
            if len(clothingObjects) == 2:
                clothingGeoName_0 = getClothingObjs()[0].name
                clothing_Object_0 = bpy.data.objects[clothingGeoName_0]
                
                outerResult_0 = checkIntersection("outer", clothingGeoName_0)
                clothingGeoName_1 = getClothingObjs()[1].name

                clothing_Object_1 = bpy.data.objects[clothingGeoName_1]
                
                outerResult_1 = checkIntersection("outer", clothingGeoName_1)
                
                clothinglist = [clothingGeoName_0, clothingGeoName_1]
                
                
                if outerResult_0 == True and outerResult_1 == True:
                    scn.checkResult_Intersection_Outer = True
                    message = ["No intersections were found between geometry and OuterCage."]
                    ShowMessageBox(message)

                if outerResult_0 != True:
                    for f in outerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Outer = False
                
                if outerResult_1 != True:
                    for f in outerResult_1:
                        clothing_Object_1.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Outer = False
                        
                        
                    bpy.ops.object.select_all(action='DESELECT')
                    for i in clothinglist:
                        clothingObj = bpy.data.objects[i]
                        clothingObj.select_set(True)
                        bpy.context.view_layer.objects.active = bpy.data.objects[i]
                    bpy.ops.object.editmode_toggle()
                    message = ["Possible intersections were found. Please check the selected faces."]
                    ShowMessageBox(message)
                    scn.checkResult_Intersection_Outer = False
                    
            if len(clothingObjects) == 1:
                clothingGeoName_0 = getClothingObjs()[0].name
                clothing_Object_0 = bpy.data.objects[clothingGeoName_0]
                
                outerResult_0 = checkIntersection("outer", clothingGeoName_0)
                
                clothinglist = [clothingGeoName_0]

                if outerResult_0 == True:
                    scn.checkResult_IntersectionOuter = True
                    message = ["No intersections were found."]
                    ShowMessageBox(message)
                else:
                    for f in outerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                        
                    bpy.ops.object.select_all(action='DESELECT')
                    for i in clothinglist:
                        clothingObj = bpy.data.objects[i]
                        clothingObj.select_set(True)
                        bpy.context.view_layer.objects.active = bpy.data.objects[i]
                    bpy.ops.object.editmode_toggle()
                    message = ["Possible intersections were found. Please check the selected faces."]
                    ShowMessageBox(message)
                    scn.checkResult_Intersection_Outer = False
            

            return {"FINISHED"}
        else:
            confirmmessage = ["There is no cloth geometry in the scene"]
            ShowMessageBox(confirmmessage)
            return{"FINISHED"}



class Fix_InterSections_Inner(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "mesh.fixintersectionsinner"
    bl_label = "Intersection Fix Inner"
    bl_description = "<Check intersections between clothing geometry and cage>\nIf there are possible interesections, It will be indicated as a selected face in 3D viewport"
    
    def execute(self, context):
        bpy.ops.object.mode_set(mode='OBJECT')
        # bpy.context.view_layer.objects.active = None
        scn = context.scene
        globalVariables.clothingObjs = getClothingObjs()

        if len(globalVariables.clothingObjs) != 0:
            clothingObjects = globalVariables.clothingObjs
            if len(clothingObjects) == 2:
                clothingGeoName_0 = getClothingObjs()[0].name
                clothing_Object_0 = bpy.data.objects[clothingGeoName_0]
                
                innerResult_0 = checkIntersection("inner", clothingGeoName_0)
                
                clothingGeoName_1 = getClothingObjs()[1].name
                clothing_Object_1 = bpy.data.objects[clothingGeoName_1]
                
                innerResult_1 = checkIntersection("inner", clothingGeoName_1)
                
                clothinglist = [clothingGeoName_0, clothingGeoName_1]
                
                
                if innerResult_0 == True and innerResult_1 == True:
                    scn.checkResult_Intersection_Inner = True
                    message = ["No intersections were found."]
                    ShowMessageBox(message)
                else:
                    for f in innerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                    for f in innerResult_1:
                        clothing_Object_1.data.polygons[f[1]].select = True
                        
                        
                    bpy.ops.object.select_all(action='DESELECT')
                    for i in clothinglist:
                        clothingObj = bpy.data.objects[i]
                        clothingObj.select_set(True)
                        bpy.context.view_layer.objects.active = bpy.data.objects[i]
                    bpy.ops.object.editmode_toggle()
                    message = ["Possible intersections were found. Please check the selected faces."]
                    ShowMessageBox(message)
                    scn.checkResult_Intersection_Inner = False
                    
            if len(clothingObjects) == 1:
                clothingGeoName_0 = getClothingObjs()[0].name
                clothing_Object_0 = bpy.data.objects[clothingGeoName_0]
                
                innerResult_0 = checkIntersection("inner", clothingGeoName_0)
                
                clothinglist = [clothingGeoName_0]
                
                if innerResult_0 == True:
                    scn.checkResult_IntersectionInner = True
                    message = ["No intersections were found."]
                    ShowMessageBox(message)
                else:
                    for f in innerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                        
                    bpy.ops.object.select_all(action='DESELECT')
                    for i in clothinglist:
                        clothingObj = bpy.data.objects[i]
                        clothingObj.select_set(True)
                        bpy.context.view_layer.objects.active = bpy.data.objects[i]
                    bpy.ops.object.editmode_toggle()
                    message = ["Possible intersections were found. Please check the selected faces."]
                    ShowMessageBox(message)
                    scn.checkResult_Intersection_Inner = False
            

            return {"FINISHED"}
        else:
            confirmmessage = ["There is no cloth geometry in the scene"]
            ShowMessageBox(confirmmessage)
            return{"FINISHED"}


class InitialCheck(bpy.types.Operator, ValidationToolMainPanel, globalVariables):
    bl_idname = "mesh.initialcheck"
    bl_label = "Initial Check"
    bl_description = "Run through all check processes"
        
    def execute(self, context):
        if bool(context.scene.custom):
            context.scene.custom.clear()
        
#        if len(globalVariables.clothingObjs) == 0:
        try:
            bpy.ops.object.mode_set(mode='OBJECT')
        except:
            pass
#        bpy.ops.object.mode_set(mode='OBJECT')
        scn = context.scene
        objs =  bpy.context.scene.objects
        path = context.scene.texture_folder
        globalVariables.clothingObjs = getClothingObjs()
        if len(globalVariables.clothingObjs) != 0:
            bpy.context.view_layer.objects.active = globalVariables.clothingObjs[0]
            
            
    #        bpy.context.view_layer.objects.active = None
            ##Check Layers
            layerResult = checkViewLayers()
            if layerResult == True:
                scn.checkResult_Layers = True
            else:
                message = "There are more than 1 layer."
                add_item(scn.custom, "Layer", message)
                scn.checkResult_Layers = False
            scn.checkResult_all = True
            
            ##Check KeyFrames
            keyframeResult = checkKeyframes()
            if keyframeResult == True:
                scn.checkResult_KeyFrames = True
            else:
                for f in keyframeResult:
                    add_item(scn.custom, "KeyFrame", f.name)
                scn.checkResult_KeyFrames = False

            ##Check Transform
            transformresult = checkTransform(globalVariables.clothingObjs)
            if transformresult == True:
                scn.checkResult_Transform = True
            else:
                for f in transformresult:
                    for i in transformresult[f]:
                        message = str(f) + ":" + str(i)
                        add_item(scn.custom, "Transform", message)
                globalVariables.wrongTransformObjs = transformresult
                scn.checkResult_Transform = False
            
            ##Check Unused data
            unUsedDataresults = checkUnusedData()
            
            if unUsedDataresults == True:
                scn.checkResult_UnusedData = True
            else:
                message = "There are unused / errant data."
                add_item(scn.custom, "Unused", message)
                scn.checkResult_UnusedData = False

            
            ##Check Attachpoints
            attachmentPointresults = checkAttachmentPoints()
            if attachmentPointresults == True:
                scn.checkResult_AttachPonits = True
            else:
                scn.checkResult_AttachPonits = False
                globalVariables.wrongPositions_Attachment = attachmentPointresults[0] 
                globalVariables.wrongNames_Attachment = attachmentPointresults[1]

                if len(globalVariables.wrongPositions_Attachment) != 0:
                    # message.append("ATTACHMENT POSITION ERRORS")
                    for att in globalVariables.wrongPositions_Attachment:
                        # message.append(att[0].name)
                        add_item(scn.custom, "AttPoint_Position", att[0].name)
                    # message.append(" ")
                    
                if len(globalVariables.wrongNames_Attachment) != 0:
                    # message.append("ATTACHMENT NAME ERRORS") 
                    for att in globalVariables.wrongNames_Attachment:
                        # message.append(att[0].name)
                        add_item(scn.custom, "AttPoint_Name", att[0].name)
                    # message.append(" ")
            

            ##Check Image format        
            if len(path) != 0:
                imageformatResults = imageFormatCheck(path)
                if imageformatResults == True:
                    scn.checkResult_ImageFormat = True
                else:
                    scn.checkResult_ImageFormat = False
                    wrongColor = imageformatResults[0]
                    wrongSize = imageformatResults[1]

                    if len(wrongColor) != 0:
                        # message.append("COLOR DEPTH ERRORS")
                        for f in wrongColor:
                            add_item(scn.custom, "ColorDepth", f)
                            # message.append(f)
                        # message.append(" ")
                        
                    if len(wrongSize) != 0:
                        # message.append("SIZE ERRORS")
                        for f in wrongSize:
                            add_item(scn.custom, "ImageSize", f)
                        # message.append(" ")
            else:
                scn.checkResult_ImageFormat = True

            
            ##Check Intersections
            ##Multiple object
            clothingObjects = globalVariables.clothingObjs
            
            if len(clothingObjects) == 2:
                clothingGeoName_0 = getClothingObjs()[0].name
                clothing_Object_0 = bpy.data.objects[clothingGeoName_0]
                
                outerResult_0 = checkIntersection("outer", clothingGeoName_0)
                innerResult_0 = checkIntersection("inner", clothingGeoName_0)
                
                clothingGeoName_1 = getClothingObjs()[1].name
                clothing_Object_1 = bpy.data.objects[clothingGeoName_1]
                
                outerResult_1 = checkIntersection("outer", clothingGeoName_1)
                innerResult_1 = checkIntersection("inner", clothingGeoName_1)
                
                clothinglist = [clothingGeoName_0, clothingGeoName_1]
                
                
                if outerResult_0 == True and outerResult_1 == True:
                    scn.checkResult_Intersection_Outer = True
                
                if innerResult_0 == True and innerResult_1 == True:
                    scn.checkResult_Intersection_Inner = True
                

                if outerResult_0 != True:
                    for f in outerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Outer = False

                if outerResult_1 != True:
                    for f in outerResult_1:
                        clothing_Object_1.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Outer = False

                if innerResult_0 != True:
                    for f in innerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Inner = False

                if innerResult_1 != True:
                    for f in innerResult_1:
                        clothing_Object_1.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Inner = False
                        
                        
                    bpy.ops.object.select_all(action='DESELECT')
                    for i in clothinglist:
                        clothingObj = bpy.data.objects[i]
                        clothingObj.select_set(True)
                        bpy.context.view_layer.objects.active = bpy.data.objects[i]
                    bpy.ops.object.editmode_toggle()
                    message = ["Possible intersections were found. Please check the selected faces."]
                    ShowMessageBox(message)
                    scn.checkResult_Intersection_Inner = False
                    
            if len(clothingObjects) == 1:
                clothingGeoName_0 = getClothingObjs()[0].name
                clothing_Object_0 = bpy.data.objects[clothingGeoName_0]
                
                outerResult_0 = checkIntersection("outer", clothingGeoName_0)
                innerResult_0 = checkIntersection("inner", clothingGeoName_0)
                
                clothinglist = [clothingGeoName_0]
                
                
                if outerResult_0 == True:
                    scn.checkResult_Intersection_Outer = True
                else:
                    for f in outerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Outer = False

                if innerResult_0 == True:
                    scn.checkResult_Intersection_Inner = True
                else:
                    for f in innerResult_0:
                        clothing_Object_0.data.polygons[f[1]].select = True
                    scn.checkResult_Intersection_Inner = False
                        
                    bpy.ops.object.select_all(action='DESELECT')
                    for i in clothinglist:
                        clothingObj = bpy.data.objects[i]
                        clothingObj.select_set(True)
                        bpy.context.view_layer.objects.active = bpy.data.objects[i]
                        
                    bpy.ops.object.editmode_toggle()
                    message = "Check the selected polygons in the viewport."
                    add_item(scn.custom, "Intersection", message)
                    scn.checkResult_Intersection_Inner = False
                
            
            
            if len(scn.custom) == 0:
                scn.checkResult_all = False
            else:
                scn.checkResult_all = True
                return {"FINISHED"}
        else:
            scn.checkResult_all = True
            confmessage = ["There is no cloth geometry in the scene."]
            ShowMessageBox(confmessage)
            return {"FINISHED"}
            


classes = [
    CUSTOM_objectCollection,
    CUSTOM_OT_clearList,
    MATERIAL_UL_matslots_example,
    ValidationToolMainPanel,
    InitialCheck,
    ConfirmBox_Layer,
    Fix_Layer,
    ConfirmBox_Transform,
    Fix_Transform,
    ConfirmBox_KeyFrame,
    Fix_KeyFrames,
    ConfirmBox_AttachmentPoints,
    Fix_AttachmentPoints,
    Fix_ImageFormat,
    ConfirmBox_UnusedData,
    Fix_UnusedData,
    Fix_InterSections_Outer,
    Fix_InterSections_Inner
]


def register():
    for c in classes:
        bpy.utils.register_class(c)
    
    bpy.types.Scene.custom = CollectionProperty(type=CUSTOM_objectCollection)
    bpy.types.Scene.custom_index = IntProperty(default = 5)
#    ValidationToolMainPanel.initSceneProperties(bpy.types.Scene)
    
    

def unregister():
    for c in classes:
        bpy.utils.unregister_class(c)
    
    del bpy.types.Scene.custom
    del bpy.types.Scene.custom_index

if __name__ == "__main__":
    register()
