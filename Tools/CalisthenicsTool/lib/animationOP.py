import os
import sys
import bpy

class globalVariables():
    animationIsPlaying = False
    curentAnim = ""
    originalAvatar = None
    originalStart = None
    originalEnd = None
    importedAnim = None
    importedAction = None


class PlayAnimationOP(bpy.types.Operator,globalVariables):
    bl_idname = "mesh.playanimation"
    bl_label = "playAnimation"
    bl_description = "Play Animation"

    anim_data_local = None
    
    animType: bpy.props.StringProperty(name = 'text', default = 'Walk')
    
    def showMessageBox(self, message):
        def draw(self, context):
            for line in message:
                self.layout.label(text=line)
                
        bpy.context.window_manager.popup_menu(draw, title="Apply Test Animation", icon = "INFO")
    


    def checkRigType(self, avatarObj):
        avatararmature = bpy.context.scene.objects[avatarObj.name]
        blenderRig = False
        
        for bone in avatararmature.data.bones:
            if bone.head_local[1] > bone.tail_local[1]:
                blenderRig = True
        
        return blenderRig


    def checkRigType_2(self, avatrObj):
        armature = bpy.context.scene.objects[avatrObj.name]
        boneIsDirectingDown = True
        checkboneList = ["LeftLowerArm", "RightLowerArm", "LeftLowerLeg","RightLowerLeg"]

        posebones = armature.pose.bones
        upBones = []
        for pb in posebones:
            if pb.name in checkboneList:
                tail_height = 0.0
                head_height = 0.0
                
                rotx, roty, rotz = armature.rotation_euler
                if rotx != 0.0:
                    tail_height = pb.tail[1]
                    head_height = pb.head[1]
                else:
                    tail_height = pb.tail[2]
                    head_height = pb.head[2]
 
                if tail_height > head_height:
                    upBones.append(pb.name)
        
        if len(upBones) == 4:
            boneIsDirectingDown = False
                
        return boneIsDirectingDown
    

    
    def validateArmature(self, avatarObj):
        try:
            avatararmature = bpy.context.scene.objects[avatarObj.name]
            boneList = ["Root", "HumanoidRootNode", "LowerTorso", "UpperTorso", "Head", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand", "LeftUpperLeg","LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot"]
            boneNum = 0
            orphanBones = []

            for bone in avatararmature.data.bones:
                if bone.name in boneList:
                    boneNum += 1
                else:
                    orphanBones.append(bone.name)

            if boneNum != len(boneList):
                return False
            else:
                return True
        except:
            return False

    


    def attachConstraints(self, arm1, arm2):
        armature = arm1
        importedAnimation = arm2


        pbs = armature.pose.bones

        outBoneList = ["Root", "HumanoidRootNode"]

        for pb in pbs:
            if len(pb.constraints.items()) != 0:
                for constraint in pb.constraints.items():
                    crc = constraint[1]
                    if constraint[0] == "Copy Location":
                        try:
                            target_pb = importedAnimation.pose.bones[pb.name]
                            crc.target = importedAnimation
                            crc.subtarget = target_pb.bone.name
                            crc.use_x = False
                            crc.use_y = False
                        except:
                            pass
                    if constraint[0] == "Copy Rotation":
                        try:
                            target_pb = importedAnimation.pose.bones[pb.name]
                            crc.target = importedAnimation
                            crc.subtarget = target_pb.bone.name
                        except:
                            pass

            else:
                if pb.name not in outBoneList:
                    if pb.name == "LowerTorso":
                        try:
                            target_pb = importedAnimation.pose.bones[pb.name]
                            crc = pb.constraints.new('COPY_LOCATION')
                            crc.target = importedAnimation
                            crc.subtarget = target_pb.bone.name
                            crc.use_x = False
                            crc.use_y = False
                        except:
                            pass
                    try:
                        target_pb = importedAnimation.pose.bones[pb.name]
                        crc = pb.constraints.new('COPY_ROTATION')
                        crc.target = importedAnimation
                        crc.subtarget = target_pb.bone.name
                    except:
                        pass


    def resetAnim(self, globalVariables, avatarObj):
        ##Revert current frame to 1
        bpy.context.scene.frame_current = 1
        ##Stop currently running animation
        bpy.ops.screen.animation_cancel()

        if bpy.context.active_object != None:
            if bpy.context.active_object.mode != "OBJECT":
                bpy.ops.object.mode_set(mode='OBJECT')
                
                
        armature = avatarObj
        target = None
        pbs = armature.pose.bones
        for pb in pbs:
            if len(pb.constraints.items()) != 0:
                for constraint in pb.constraints.items():
                    crc = constraint[1]
                    if crc.target != None:
                        target = crc.target
        
        if target != None:
            target_to_delete = bpy.data.objects[target.name]
            bpy.data.objects.remove(target_to_delete, do_unlink=True)
        

        ##Deleting unused data
        orphanArmature = [arm for arm in bpy.data.armatures if arm.users == 0]
        for arm in orphanArmature:
            bpy.data.armatures.remove(arm)
        if globalVariables.importedAction != None:
            bpy.data.actions.remove(globalVariables.importedAction)
            globalVariables.importedAction = None

        
        bpy.types.Scene.playMoveAnim = False
        bpy.types.Scene.playWalkAnim = False
        bpy.types.Scene.playRunAnim = False
        bpy.types.Scene.playIdleAnim = False

        
        globalVariables.animationIsPlaying = False



    def playAnim(self, avatarObj, boneFacesDown, globalVariables):
        dirpath = os.path.dirname(os.path.realpath(__file__))
        animName  = self.animType
        globalVariables.currentAnim = animName
        fbxPath = ""

        if animName == "MoveAnimation":
            if boneFacesDown == True:
                fbxPath = os.path.join(dirpath, "MoveAnim_B_7.fbx")
            else:
                fbxPath = os.path.join(dirpath, "MoveAnim_2.fbx")
            startNum = 2
            endNum = 660
            bpy.types.Scene.playMoveAnim = True
            bpy.types.Scene.playWalkAnim = False
            bpy.types.Scene.playRunAnim  = False
            bpy.types.Scene.playIdleAnim = False
        if animName == "WalkAnimation":
            if boneFacesDown == True:
                fbxPath = os.path.join(dirpath, "WalkAnim_B_4.fbx")
                startNum = 3
                endNum = 19
            else:
                fbxPath = os.path.join(dirpath, "WalkAnim_2.fbx")
                startNum = 2
                endNum = 17
            bpy.types.Scene.playMoveAnim = False
            bpy.types.Scene.playWalkAnim = True
            bpy.types.Scene.playRunAnim  = False
            bpy.types.Scene.playIdleAnim = False
        if animName == "RunAnimation":
            if boneFacesDown == True:
                fbxPath = os.path.join(dirpath, "RunAnim_B_5.fbx")
                startNum = 3
                endNum = 17
            else:
                fbxPath = os.path.join(dirpath, "RunAnim_2.fbx")
                startNum = 2
                endNum = 17
            bpy.types.Scene.playMoveAnim = False
            bpy.types.Scene.playWalkAnim = False
            bpy.types.Scene.playRunAnim  = True
            bpy.types.Scene.playIdleAnim = False
        if animName == "IdleAnimation":
            if boneFacesDown == True:
                fbxPath = os.path.join(dirpath, "IdleAnim_B_5.fbx")
            else:
                fbxPath = os.path.join(dirpath, "IdleAnim_2.fbx")
            startNum = 2
            endNum = 242
            bpy.types.Scene.playMoveAnim = False
            bpy.types.Scene.playWalkAnim = False
            bpy.types.Scene.playRunAnim  = False
            bpy.types.Scene.playIdleAnim = True


        bpy.ops.import_scene.fbx(filepath=fbxPath)

        arm1 = bpy.data.objects[avatarObj.name]
        arm2 = bpy.data.objects[animName]

        globalVariables.importedArmature = arm2.name
        globalVariables.importedAction = arm2.animation_data.action

        self.attachConstraints(arm1, arm2)

        arm2.hide_set(True)

        globalVariables.originalStart = bpy.context.scene.frame_start
        globalVariables.originalEnd = bpy.context.scene.frame_end
        globalVariables.animationIsPlaying = True
        bpy.context.scene.frame_start = startNum
        bpy.context.scene.frame_end = endNum
        bpy.context.scene.frame_current = 1

        bpy.ops.screen.animation_play()

    def execute(self, context):
        avatarObj = bpy.context.scene.Armature


        if globalVariables.animationIsPlaying:
            self.resetAnim(globalVariables, avatarObj)

        if avatarObj != None:
            IsAvatar = self.validateArmature(avatarObj)
            boneFacesDown = self.checkRigType_2(avatarObj)
            if IsAvatar == True:
                avatarObj.select_set(True)
                self.playAnim(avatarObj, boneFacesDown, globalVariables)
            else:
                self.showMessageBox(["Selected armature seems to have different rig."])
        else:
            self.showMessageBox(["Select one layered clothing amature node."])
        return{"FINISHED"}




class DeleteAnimOP(bpy.types.Operator, globalVariables):
    bl_idname = "mesh.deleteanim"
    bl_label = "deleteAnimation"
    bl_description = "Stop Animation"


    def deleteConstraints(self, avatarObj):
        armature = avatarObj
        pbs = armature.pose.bones
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


    
    def deleteAnim(self, globalVariables):
        ##Revert current frame to 1
        bpy.context.scene.frame_current = 1
        ##Stop currently running animation
        bpy.ops.screen.animation_cancel()
        


        bpy.types.Scene.playMoveAnim = False
        bpy.types.Scene.playWalkAnim = False
        bpy.types.Scene.playRunAnim = False
        bpy.types.Scene.playIdleAnim = False


        bpy.context.scene.frame_start = globalVariables.originalStart
        bpy.context.scene.frame_end = globalVariables.originalEnd

        avatarObj = bpy.context.scene.Armature
        self.deleteConstraints(avatarObj)




        ##Deleting unused data
        orphanArmature = [arm for arm in bpy.data.armatures if arm.users == 0]
        for arm in orphanArmature:
            bpy.data.armatures.remove(arm)
        if globalVariables.importedAction != None:
            bpy.data.actions.remove(globalVariables.importedAction)
            globalVariables.importedAction = None
        globalVariables.animationIsPlaying = False

    def execute(self, context):
        self.deleteAnim(globalVariables)
        return{"FINISHED"}
