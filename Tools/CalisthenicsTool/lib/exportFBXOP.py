import bpy
import os


from .attachaccOP import AttachTestAccessoryOP, DetachTestAccessoryOP


class ExportFBX_OP(bpy.types.Operator):
    bl_idname = "mesh.exportfbx"
    bl_label = "playAnimation"
    bl_description = "Export FBX file"


    def showMessageBox(self, message):
        def draw(self, context):
            for line in message:
                self.layout.label(text=line)
                
        bpy.context.window_manager.popup_menu(draw, title="Apply Test Animation", icon = "INFO")
    
    def execute(self, context):
        avatarObj = bpy.context.scene.Armature

        if context.scene.export_folder == "":
            self.showMessageBox(["Please select the export folder."])
            return {"FINISHED"}


        pbs = avatarObj.pose.bones
        target = None
        for pb in pbs:
            if len(pb.constraints.items()) != 0:
                for constraint in pb.constraints.items():
                    crc = constraint[1]
                    if crc.target != None:
                        target = crc.target
                    pb.constraints.remove(crc)
        
        if target != None:
            target_to_delete = bpy.data.objects[target.name]
            bpy.data.objects.remove(target_to_delete, do_unlink=True)
        bpy.context.scene.frame_current = 1

        bpy.types.Scene.playMoveAnim = False
        bpy.types.Scene.playWalkAnim = False
        bpy.types.Scene.playRunAnim = False
        bpy.types.Scene.playIdleAnim = False

        for ob in bpy.context.selected_objects:
            ob.select_set(False)
        Objs = bpy.data.objects
        for obj in Objs:
            if "_TestAcc" in obj.name:
                obj.select_set(True)
                target_to_delete = bpy.data.objects[obj.name]
                bpy.data.objects.remove(target_to_delete, do_unlink=True)

    
        
        if avatarObj.name != "":
            exportFileName = "Character_Model_Export"
            exported_file_path = context.scene.export_folder + "%s.fbx" % exportFileName


            scaleLength = bpy.context.scene.unit_settings.scale_length
            if scaleLength != 0.01:
                bpy.context.scene.unit_settings.scale_length = 0.01


            try:
                bpy.ops.export_scene.fbx(filepath=exported_file_path,
                                axis_forward="-Z",
                                axis_up="Y",
                                bake_anim =True,
                                object_types  = {'EMPTY','ARMATURE', 'MESH', 'OTHER'},
                                add_leaf_bones = False,
                                path_mode="COPY",
                                embed_textures=True,
                                use_custom_props=True,
                                use_active_collection=True,
                                bake_anim_use_all_bones=True,
                                bake_anim_use_nla_strips=True,
                                bake_anim_use_all_actions=True,
                                bake_anim_force_startend_keying=False,
                                bake_anim_simplify_factor = 0.0
                                )

                self.showMessageBox(["FBX is exported at %s " % exported_file_path])
                return {"FINISHED"}
            except:
                self.showMessageBox(["FBX was not exported."])
                return {"FINISHED"}
        else:
            self.showMessageBox(["Armature is not selected."])
            return {"FINISHED"}