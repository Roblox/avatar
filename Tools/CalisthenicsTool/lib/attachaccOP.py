import bpy
import os
from pathlib import Path


class AttachTestAccessoryOP(bpy.types.Operator):
    bl_idname = "mesh.attachtestaccessory"
    bl_label = "playAnimation"
    bl_description = "Attach test accessories"
    

    accType: bpy.props.StringProperty(name = 'text', default = 'Normal')
    
    def importAccsessory(self, attachmentPointName):
        dirpath = os.path.dirname(os.path.realpath(__file__))
        fbxPath = ""

        accType  = self.accType

        if "BodyBack_Att" in attachmentPointName:
            fbxPath = os.path.join(dirpath, accType,"BodyBack.fbx")
            accName = "Wings_Acc"
            
        if "FaceFront_Att" in attachmentPointName:
            fbxPath = os.path.join(dirpath, accType,"FaceFront.fbx")
            accName = "Mask_Acc"
            
        if "Hair_Att" in attachmentPointName:
            fbxPath = os.path.join(dirpath, accType,"Hair.fbx")
            accName = "Hair_Acc"
            
        if "Hat_Att" in attachmentPointName:
            fbxPath = os.path.join(dirpath, accType,"Hat.fbx")
            accName = "Hat_Acc"
            
        if "WaistBack_Att" in attachmentPointName:
            fbxPath = os.path.join(dirpath, accType,"WaistBack.fbx")
            accName = "Tail_Acc"

        avatarObj = bpy.context.scene.Armature
        bpy.ops.import_scene.fbx(filepath=fbxPath)
        obj = bpy.context.selected_objects[0]
        obj.name = avatarObj.name + "_" + obj.name
        obj.name = obj.name.split(".")[-1].replace("_Acc", "_TestAcc")
        constraint = obj.constraints.new(type='COPY_TRANSFORMS')
        constraint.target = bpy.data.objects[attachmentPointName]


    
    def detachTestAccesory(self):
        for ob in bpy.context.selected_objects:
            ob.select_set(False)
        Objs = bpy.data.objects
        for obj in Objs:
            if obj.name.endswith("_TestAcc"):
                obj.select_set(True)
                bpy.ops.object.delete()
        bpy.ops.outliner.orphans_purge(num_deleted=0, do_local_ids=True, do_linked_ids=True, do_recursive=True)
    



    def execute(self, context):
        self.detachTestAccesory()
        avatarObj = bpy.context.scene.Armature
        attachmentPointNames = []
    
        AttList = ["BodyBack_Att", "FaceFront_Att", "Hair_Att", "Hat_Att", "WaistBack_Att"]
        Objs = bpy.data.objects[avatarObj.name].children
        for obj in Objs:
            objname = obj.name
            if "_Att" in objname and obj.parent == avatarObj:
                att = objname.split(".")[0]
                if att in AttList:
                    attachmentPointNames.append(objname)
        

        for attachmentPointName in attachmentPointNames:
            loaded  = self.importAccsessory(attachmentPointName)

        if self.accType == "Normal":
            bpy.types.Scene.normalAccAttached = True
            bpy.types.Scene.slenderAccAttached = False
        else:
            bpy.types.Scene.normalAccAttached = False
            bpy.types.Scene.slenderAccAttached = True
        
        return{"FINISHED"}



class DetachTestAccessoryOP(bpy.types.Operator):
    bl_idname = "mesh.detachtestaccessory"
    bl_label = "playAnimation"
    bl_description = "Detach test accessories"

    def detachTestAccesory(self):
        for ob in bpy.context.selected_objects:
            ob.select_set(False)
        Objs = bpy.data.objects
        for obj in Objs:
            if "_TestAcc" in obj.name:
                obj.select_set(True)
                target_to_delete = bpy.data.objects[obj.name]
                bpy.data.objects.remove(target_to_delete, do_unlink=True)
        bpy.ops.outliner.orphans_purge(num_deleted=0, do_local_ids=True, do_linked_ids=True, do_recursive=True)

    
    def execute(self, context):
        self.detachTestAccesory()
        bpy.types.Scene.normalAccAttached = False
        bpy.types.Scene.slenderAccAttached = False
        return {"FINISHED"}



