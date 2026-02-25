import maya.cmds as cmds
import pymel.core as pm
import maya.mel as mel
import glob
import json
import os
import sys
from collections import OrderedDict
import maya.OpenMaya as OM
import math as math
from functools import partial
import subprocess


class validationTool:
    btnList = {
    "btn_01":None, 
    "btn_02":None, 
    "btn_03":None, 
    "btn_04":None, 
    "btn_05":None, 
    "btn_06":None,
    "btn_07":None,
    "btn_08":None, 
    }
    btnList = OrderedDict(sorted(btnList.items()))
    # /Library/Frameworks/Python.framework/Versions/3.10/bin
    pythonpath = ""
    texturefolder = ""
    mode = None
    
    resultField = None
        
    ##///////////////////////////////////////////////////KeyFrameCheck//////////////////////////////////////////////////////
    def checkKeyFrames(self):
        animCurves  = cmds.ls(type = ["animCurveTU","animCurveTA","animCurveTL"])
        if len(animCurves) != 0:
            return animCurves
        else:
            return True
    ##///////////////////////////////////////////////////KeyFrameCheck//////////////////////////////////////////////////////
    
    
    ##/////////////////////////////////////////////////// Layer Check //////////////////////////////////////////////////////
    def checkLayers(self):
        layers = cmds.ls(type = 'displayLayer')
        ## minimum length of layers is 1, becuase default layer always exists.
        if len(layers) > 1:
            return layers
        else:
            return True
    ##/////////////////////////////////////////////////// Layer Check //////////////////////////////////////////////////////


    ##/////////////////////////////////////////////////// Transform Check //////////////////////////////////////////////////////
    def checkTransform(self, objs):
        wrongPositionObjs = {}
        objects = objs

        for obj in objects:
            wrongValues = []
            tx = cmds.getAttr(obj + ".tx")
            if tx != 0.0:
                wrongValues.append("transform X")
            ty = cmds.getAttr(obj + ".ty")
            if ty != 0.0:
                wrongValues.append("transform Y")
            tz = cmds.getAttr(obj + ".tz")
            if tz != 0.0:
                wrongValues.append("transform Z")

            rx = cmds.getAttr(obj + ".rx")
            if rx != 0.0:
                wrongValues.append("rotation X")
            ry = cmds.getAttr(obj + ".ry")
            if ry != 0.0:
                wrongValues.append("rotation Y")
            rz = cmds.getAttr(obj + ".rz")
            if rz != 0.0:
                wrongValues.append("rotation Z")

            sx = cmds.getAttr(obj + ".sx")
            if sx != 1.0:
                wrongValues.append("scale X")
            sy = cmds.getAttr(obj + ".sy")
            if sy != 1.0:
                wrongValues.append("scale Y")
            sz = cmds.getAttr(obj + ".sz")
            if sz != 1.0:
                wrongValues.append("scale Z")

            if len(wrongValues) != 0:
                wrongPositionObjs[obj] = wrongValues

        if len(wrongPositionObjs) != 0:
            return wrongPositionObjs 
        else:
            return True
    ##/////////////////////////////////////////////////// Transform Check //////////////////////////////////////////////////////
    
    
    ##///////////////////////////////////////////////// Materiak Check /////////////////////////////////////////////////////
    def checkUnusedMaterials(self, objs):
        # Needs to be changed for Avatar/Clothing differences
        unUsedMaterials = []
        objectsWithHistory = []
        HistoryIsClear = False
        results = {}

        sgs = cmds.ls(type = 'shadingEngine')
        for sg in sgs:
            if not cmds.sets(sg, q=True):
                if str(sg) != 'initialParticleSE' and str(sg) != 'initialShadingGroup':
                    unUsedMaterials.append(sg)

        for obj in objs:
            cmds.select(d=True)
            cmds.select(obj)
            historylist = cmds.bakePartialHistory(query=True, ppt=True)
            if len(historylist) > 1:
                objectsWithHistory.append(obj)



        if len(objectsWithHistory) == 0 and len(unUsedMaterials) == 0:
            return True
        else:
            if len(unUsedMaterials) > 0:
                results["01_mat"] = unUsedMaterials
            if len(objectsWithHistory) > 0:
                results["05_history"] = objectsWithHistory
            return results

    ##///////////////////////////////////////////////// Materiak Check /////////////////////////////////////////////////////
    
    
    ##///////////////////////////////////////////////// Attachment Check ///////////////////////////////////////////////////
    def checkAttachmentPoints(self):
        attpoints = cmds.ls("*_Att")
        
        if len(attpoints) == 0:
            cmds.confirmDialog( title='AttachmentPoints check', message= "No attachment points are found in the scene.", dismissString='OK' )
        else:
            wrongNames = []
            wrongPositions = []
            result = []
            
            for point in attpoints:
                parentnode = pm.listRelatives(point, p=True )[0]
                if point == "FaceFront_Att":
                    if parentnode != "Head":
                        wrongPositions.append([point, parentnode, "Head"])
                elif point == "Hat_Att":
                    if parentnode != "Head":
                        wrongPositions.append([point, parentnode, "Head"])
                elif point == "Hair_Att":
                    if parentnode != "Head":
                        wrongPositions.append([point, parentnode, "Head"])
                elif point == "FaceCenter_Att":
                    if parentnode != "Head":
                        wrongPositions.append([point, parentnode, "Head"])
                elif point == "LeftGrip_Att":
                    if parentnode != "LeftHand":
                        wrongPositions.append([point, parentnode, "LeftHand"])
                elif point == "LeftShoulder_Att":
                    if parentnode != "LeftUpperArm":
                        wrongPositions.append([point, parentnode, "LeftUpperArm"])
                elif point == "RightGrip_Att":
                    if parentnode != "RightHand":
                        wrongPositions.append([point, parentnode, "RightHand"])
                elif point == "RightShoulder_Att":
                    if parentnode != "RightUpperArm":
                        wrongPositions.append([point, parentnode, "RightUpperArm"])
                elif point == "BodyFront_Att":
                    if parentnode != "UpperTorso":
                        wrongPositions.append([point, parentnode, "UpperTorso"])
                elif point == "BodyBack_Att":
                    if parentnode != "UpperTorso":
                        wrongPositions.append([point, parentnode, "UpperTorso"])
                elif point == "LeftCollar_Att":
                    if parentnode != "UpperTorso":
                        wrongPositions.append([point, parentnode, "UpperTorso"])
                elif point == "Neck_Att":
                    if parentnode != "UpperTorso":
                        wrongPositions.append([point, parentnode, "UpperTorso"])
                elif point == "RightCollar_Att":
                    if parentnode != "UpperTorso":
                        wrongPositions.append([point, parentnode, "UpperTorso"])
                elif point == "LeftFoot_Att":
                    if parentnode != "LeftFoot":
                        wrongPositions.append([point, parentnode, "LeftFoot"])
                elif point == "RightFoot_Att":
                    if parentnode != "RightFoot":
                        wrongPositions.append([point, parentnode, "RightFoot"])
                elif point == "WaistFront_Att":
                    if parentnode != "LowerTorso":
                        wrongPositions.append([point, parentnode, "LowerTorso"])
                elif point == "WaistBack_Att":
                    if parentnode != "LowerTorso":
                        wrongPositions.append([point, parentnode, "LowerTorso"])
                elif point == "WaistCenter_Att":
                    if  parentnode != "LowerTorso":
                        wrongPositions.append([point, parentnode, "LowerTorso"])
                elif point == "Root_Att":
                    if parentnode != "Root":
                        wrongPositions.append([point, parentnode, "Root"])
                else:
                    wrongNames.append([point, parentnode])
        
        if len(wrongPositions) == 0 and len(wrongNames) == 0:
            return True
        else:
            return [wrongPositions, wrongNames]
    ##///////////////////////////////////////////////// Attachment Check ////////////////////////////////////////////////////
    
    
    ##///////////////////////////////////////////////// Naming Convention Check /////////////////////////////////////////////
    def getFiles(self):
        dir = cmds.fileDialog2(fileMode = 3)
        if dir != None:
            files = os.listdir(dir[0])
            filelist = {".png" : [], ".ma":[], ".fbx":[], ".psd":[], "unknown":[]}
        
        
            for f in files:
                if f.endswith(".png"):
                    filelist[".png"].append(f)
                elif f.endswith(".ma"):
                    filelist[".ma"].append(f)
                elif f.endswith(".fbx"):
                    filelist[".fbx"].append(f)
                elif f.endswith(".psd"):
                    filelist[".psd"].append(f)
                ##Enable this line to check other file types.
                ##else:
                    ##filelist["unknown"].append(f)
            return filelist
        else:
            return None

    
    def checkFilename(self, name, ext):
        if ext == ".png":
            if name.startswith("TXT_LCL_"):
                n = name.split("TXT_LCL_")[1]
                if "_ALB" in n:
                    geoname = n.split("_ALB")[0]                    
                    suffix = n.split("_ALB")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_ALB" + suffix + ext:
                        return (True, name)                        
                    else:
                        return (False, name)
                elif "_NOR" in n :
                    geoname = n.split("_NOR")[0]
                    suffix = n.split("_NOR")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_NOR" + suffix + ext:
                        return (True, name)
                    else:
                        return (False, name)
                elif "_MET" in n :
                    geoname = n.split("_MET")[0]
                    suffix = n.split("_MET")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_MET" + suffix + ext:
                        return (True, name)
                    else:
                        return (False, name)
                elif "_RGH" in n:
                    geoname = n.split("_RGH")[0]
                    suffix = n.split("_RGH")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_RGH" + suffix + ext:
                       return (True, name)
                    else:
                       return (False, name)
                else:
                    return (False, name)
            else:
                return (False, name)
    
        elif ext == ".ma":
            if name.startswith("LCL_"):
                return (True, name)
            else:
                return (False, name)
        elif ext == ".psd":
            if name.startswith("TXT_LCL_"):
                n = name.split("TXT_LCL_")[1]
                if "_ALB" in n:
                    geoname = n.split("_ALB")[0]
                    suffix = n.split("_ALB")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_ALB" + suffix + ext:
                        return (True, name)
                    else:
                        return (False, name)
                elif "_NOR" in n:
                    geoname = n.split("_NOR")[0]
                    suffix = n.split("_NOR")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_NOR" + suffix + ext:
                        return (True, name)
                    else:
                        return (False, name)
                elif "_MET" in n:
                    geoname = n.split("_MET")[0]
                    suffix = n.split("_MET")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_MET" + suffix + ext:
                        return (True, name)
                    else:
                        return (False, name)
                elif "_RGH" in n:
                    geoname = n.split("_RGH")[0]
                    suffix = n.split("_RGH")[1].split(ext)[0]
                    if name == "TXT_LCL_" + geoname + "_RGH" + suffix + ext:
                        return (True, name)
                    else:
                        return (False, name)
                else:
                    return (False, name)
            else:
                return(False,name)
        elif ext == ".fbx":
            if name.startswith("LCL_"):
                return (True, name)
            else:
                return (False, name)
    
    
    def checkNamingConvention(self):        
        files = self.getFiles()
        
        if files != None:
            wrongnamefiles = []
            correctnamefiles =[]
            
            
            for key in files:
                if len(files) > 0:
                    for i in files[key]:
                        result = self.checkFilename(i,key)
                        if result[0] != True:
                            wrongnamefiles.append(i)
                        else:
                            correctnamefiles.append(i)
            
            
            if len(wrongnamefiles) > 0:
                return wrongnamefiles
            else:
                return True
    ##///////////////////////////////////////////////// Naming Convention Check /////////////////////////////////////////////


    def checkImageFormat(self):
        # filelist = r"-option "
        # path_Python = self.pythonpath

        pythonPath = self.checkPythonPath()
        self.getPath(pythonPath)

        fullPath =  ""
        if os.name == "posix":
            fullPath = cmds.internalVar(usd=True)
            fullPath = fullPath.replace("scripts/", "prefs/scripts/ValidationTool/CheckImageData.py")
        if os.name == "nt":
            fullPath = cmds.internalVar(usd=True)
            fullPath = fullPath.replace("scripts/", r"prefs/scripts/ValidationTool/CheckImageData.py")
            fullPath = fullPath.replace("/", "\\")

        checkImageScript = glob.glob(fullPath)
        if len(checkImageScript) == 1 and pythonPath != False:
            scriptpath = checkImageScript[0]
            # if self.texturefolder == ""
            dir = self.texturefolder
            # dir = pm.fileDialog2(fileMode = 3, cap = "Select the texture folder")[0]
            # self.texturefolder = dir

            command = self.pythonpath + ' ' + scriptpath + " " + dir

            proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            stdout_data, stderr_data = proc.communicate()
            if len(stderr_data) == 0:
                text = stdout_data.decode('utf-8')
                result = text.split(";")


                resultFiles = {}
                filename = None
                colorDepth = None
                size = None
                for i in range(len(result)):
                    if result[i] != "":
                        if result[i].endswith(".png"):
                            filename =  result[i]
                        elif result[i].endswith("bit"):
                            colorDepth = int(result[i].split("bit")[0])
                        else:
                            size = (int(result[i].split(":")[0]), int(result[i].split(":")[1]))
                        resultFiles[filename] = [size, colorDepth]

                message_name = ""
                message_colorDepth = ""
                message_size = ""
                

                for i in resultFiles:
                    filename = i[:-4]
                    if "TXT_" in filename:
                        pass
                    elif "TXT_LCL_" in filename:
                        pass
                    else:
                        message_name += "The namingconvention of %s is different." % i + "\n"


                    num = resultFiles[i][0][0]
                    if (num > 0) and (num & (num - 1 )) == 0:
                        if 256 <= num <= 1024:
                            if "TXT_LCL_" in filename:
                                if num != resultFiles[i][0][1]:
                                    message_size += "The size of %s is %s px." % (i,  resultFiles[i][0]) + "\n"
                            else:
                                if num == 1024:
                                    if num != resultFiles[i][0][1]:
                                        message_size += "The size of %s is %s px." % (i,  resultFiles[i][0]) + "\n"
                                else:
                                    message_size += "The size of %s is %s px." % (i,  resultFiles[i][0]) + "\n"                   
                        else:
                            message_size += "The size of %s is %s px." % (i,  resultFiles[i][0]) + "\n"
                    else:
                        message_size += "The size of %s is %s px." % (i,  resultFiles[i][0]) + "\n"

                    
                    if filename.endswith("_ALB") or filename.endswith("_NOR"):
                        if resultFiles[i][1] != 24:
                            print(resultFiles[i][1])
                            message_colorDepth += "The color depth of %s is %s." % (i, str(resultFiles[i][1])) + "\n"
                    elif filename.endswith("_MET") or filename.endswith("_RGH"):
                        if resultFiles[i][1] != 8:
                            print(resultFiles[i][1])
                            message_colorDepth += "The color depth of %s is %s."% (i, str(resultFiles[i][1])) + "\n"
                    else:
                        message_name += "The namingconvention of %s is different." % i + "\n"
                

            
                message_result = ""
                if len(message_name) != 0:
                    message_result += "Naming Convention Errors\n"
                    message_result += message_name + "\n"
                if len(message_colorDepth) != 0:
                    message_result += "Color Depth Errors\n"
                    message_result += message_colorDepth + "\n"
                if len(message_size) != 0:
                    message_result += "Size Errors\n"
                    message_result += message_size + "\n"
                

                if len(message_result) == 0:
                    return True
                else:
                    return message_result
                    # pm.confirmDialog( title='Image format check', message= message_result, dismissString='OK' )
            else:
                if stderr_data == "ModuleNotFoundError: No module named 'PIL'":
                    message_result = "Pillow module is not found on the machine."
                else:
                    message_result = "An error is occured during image format check.\n Texture directory or Python directory may not be selected correctly."
                return message_result
        else:
            message = "There is no checkImageScript.py in folder. Please make sure if 'checkImageScript.py' is copied correctly."
            return message
            # cmds.confirmDialog( title='Image format check', message= message, dismissString='Ok' )


    
    
    ##///////////////////////////////////////////////// Intersection Check //////////////////////////////////////////////////
    def selectMesh(self, mode):
        # if mode == 'inner':
        #     pm.select("*_InnerCageShape.f[*]")
        #     raysource= pm.ls(sl=True)
        #     cloth = raysource[0].split("_InnerCage")[0]
            
        # if mode == 'outer':
        #     cloth = pm.ls("*_OuterCage")[0].split("_OuterCage")[0]
        #     pm.select(cloth + "Shape.f[*]")
        #     raysource= pm.ls(sl=True)
        # return raysource

        if mode == 'inner':
            innerCage = cmds.ls("*_InnerCage")
            innerCageShape = cmds.listRelatives(innerCage, shapes=True)
            if "_Shape" in innerCageShape:
                cmds.rename(innerCageShape, innerCageShape.replace("_Shape", "Shape"))
            cmds.select("*_InnerCageShape.f[*]")
            raysource= pm.ls(sl=True)
            
        if mode == 'outer':
            cloth = cmds.ls("*_OuterCage")[0].split("_OuterCage")[0]
            clothShape = cmds.listRelatives(cloth, shapes=True)[0]
            if "_Shape" in clothShape:
                cmds.rename(clothShape, clothShape.replace("_Shape", "Shape"))
            
            cmds.select(str(cloth) + "Shape.f[*]")
            raysource= pm.ls(sl=True)
        return raysource


    def getcenterFace(self, polyfaces):
        centerlist = []
        for face in polyfaces:
            if len(face) > 1:
                for f in face:
                    pt = f.__apimfn__().center(OM.MSpace.kWorld)
                    centerPoint = pm.datatypes.Point(pt)
                    centerlist.append((f, centerPoint))
            else:
                pt = face.__apimfn__().center(OM.MSpace.kWorld)
                centerPoint = pm.datatypes.Point(pt)
                centerlist.append((face,centerPoint))
                
        return centerlist
    
    def rayIntersect(self, collisionmesh, point, direction):
    	sList = OM.MSelectionList()
    	sList.add(collisionmesh)
    
    	item = OM.MDagPath()
    	sList.getDagPath(0, item)
    	item.extendToShape()
    
    	fnMesh = OM.MFnMesh(item)
    
    	raySource = OM.MFloatPoint(point[0], point[1], point[2], 1.0)
    	rayDir = OM.MFloatVector(direction[0], direction[1], direction[2])
    	faceIds = None
    	triIds = None
    	idsSorted = False
    	testBothDirections = False
    	worldSpace = OM.MSpace.kWorld
    	maxParam = 999999
    	accelParams = None
    	sortHits = True
    	hitPoints = OM.MFloatPointArray()
    	hitRayParams = OM.MFloatArray()
    	hitFaces = OM.MIntArray()
    	hitTris = None
    	hitBarys1 = None
    	hitBarys2 = None
    	tolerance = 0.001
    	
    	hit = fnMesh.allIntersections(raySource, rayDir, faceIds, triIds, idsSorted, worldSpace, maxParam, testBothDirections, accelParams, sortHits, hitPoints, hitRayParams, hitFaces, hitTris, hitBarys1, hitBarys2, tolerance)
    	
    	result = int(math.fmod(len(hitFaces), 2))
    	
    
    	OM.MGlobal.clearSelectionList()
    	
    	if result == 1:
    		for i in range(hitPoints.length()):
    			hitFPoint = hitPoints[i]
    			hitPoint = (hitFPoint.x, hitFPoint.y, hitFPoint.z)
    		return [result, hitPoint, hitFaces]
    		
    	else:
    		return result
    		
    		
    def getDistance(self, origin, target):
        rayPtX = origin[0]
        rayPtY = origin[1]
        rayPtZ = origin[2]
        
        hitPtX = target[0]
        hitPtY = target[1] 
        hitPtZ = target[2]
         
        distance = math.sqrt(math.pow((hitPtX - rayPtX),2)+ math.pow((hitPtY - rayPtY),2) + math.pow((hitPtZ - rayPtZ),2))
        return distance
     
     
    def getClosestFaces(self, clothmesh, hitfaces):
        sList = OM.MSelectionList()
        sList.add(clothmesh)
        closestPolygonList = []
        
        item = OM.MDagPath()
        sList.getDagPath(0, item)
        item.extendToShape()
        
        targetFn = OM.MFnMesh(item)
        
        centerpositionList = self.getcenterFace(hitfaces)
        
        for face in centerpositionList:
            locPos = OM.MPoint(face[1][0],face[1][1],face[1][2])
             
            closestPoint = OM.MPoint()
            
            mutil = OM.MScriptUtil()
            intPtr = mutil.asIntPtr()
            targetFn.getClosestPoint(locPos,closestPoint,OM.MSpace.kWorld,intPtr)
            closestPolygonId = OM.MScriptUtil(intPtr).asInt()
            closestPolygonList.append(closestPolygonId)
            # pm.select(clothmesh + ".f[%i]" % closestPolygonId, add=True)
        
        return closestPolygonList
    
    
    def checkClothIntersection(self, mode, threshold, clothGeo, outerCageGeo): 
            # innercage = pm.ls("*_InnerCage")[0]
            # outercage = pm.ls("*_OuterCage")[0]
            # cloth = pm.ls("*_OuterCage")[0].split("_OuterCage")[0]



            # outerCage = cmds.ls("*_OuterCage")[0]
            # innerCage = cmds.ls("*_InnerCage")[0]

            # innercage = innerCageGeo
            outercage = outerCageGeo
            cloth = clothGeo


            raysource = self.selectMesh(mode)
            centerPtlist = self.getcenterFace(raysource)
            hitfaces = []
            
            pm.select(d=True)
            
            for pt in centerPtlist:
                if mode == 'inner':
                    collisionMesh = cloth
                if mode == 'outer':
                    collisionMesh = outercage
                result = self.rayIntersect(collisionMesh, pt[1], pt[0].getNormal())   
                if result != 0:
                    distance = self.getDistance(pt[1], result[1])
                    if distance < threshold:
                        hitfaces.append(pt[0])
                
            
            closestPolygonList = self.getClosestFaces(cloth, hitfaces)
            
            return closestPolygonList
    ##///////////////////////////////////////////////// Intersection Check //////////////////////////////////////////////////
    




    ##///////////////////////////////////////////////// UV Coordinates Check ////////////////////////////////////////////////
    def uvCheck(self, wrongUVs):
        
        if wrongUVs == None:
            wrongUVs = []
            jsonFile = "PATH FOR JASON FILE"
            if len(glob.glob(jsonFile)) != 0:
                with open(jsonFile) as f:
                    rawjsondata = json.load(f)
            
            
            cage = cmds.ls("Cage")
            cages = cmds.listRelatives(cage)
            if len(cages) == 2:
                for cage in cages:
                    vtx = cmds.ls(cage + ".vtx[*]", fl=True)
              
                    for v in vtx:
                        uvs = cmds.polyListComponentConversion(v, fv=True, tuv= True)
                        for uv in cmds.ls(uvs, fl =True):
                            num = uv.split(".map")[-1][1:-1]
                            currentUV = set(cmds.polyEditUV(uv, query=True))
                            refUV = set(rawjsondata[num])
                            if currentUV != refUV :
                                wrongUVs.append(uv)
                if len(wrongUVs) != 0:
                    result = False
                else:
                    result = True
            else:
                result = False
                
            
            return (result, wrongUVs)
        else:
            jsonFile = "PATH FOR JASON FILE"
            if len(glob.glob(jsonFile)) != 0:
                with open(jsonFile) as f:
                    rawjsondata = json.load(f)
            
            
            for uv in wrongUVs:
                num = uv.split(".map")[-1][1:-1]
                uPos = rawjsondata[num][0]
                vPos = rawjsondata[num][1]
                cmds.polyEditUV(uv, r=False, u= uPos, v = vPos)
                
            

    ##///////////////////////////////////////////////// UV Coordinates Check ////////////////////////////////////////////////
    
    
    ##///////////////////////////////////////////////// Main Check functions ////////////////////////////////////////////////
    def check(self, btnList, resultField, texturefolderTextField, *args):
        geo = []
        # checkMode = cmds.radioButtonGrp(mode, query = True, sl=True)
        checkMode = 2
        closestPolygonList_outer = None
        closestPolygonList_inner = None

        pythonPathTxt = self.checkPythonPath()
        if pythonPathTxt != False:
            self.getPath(pythonPathTxt)
            ImageCheckingisActive = True
        else:
            ImageCheckingisActive = False
        
        cloth = None
        if checkMode == 2:
            outerCage = pm.ls("*_OuterCage")
            if len(outerCage) == 1:
                geo = cmds.ls(outerCage[0].split("_OuterCage")[0])
            elif len(outerCage) == 2:
                geo = []
                for cage in outerCage:
                    geo.append(cmds.ls(cage.split("_OuterCage")[0])[0])
            else:
                geo = []
        else:
            geo = cmds.ls("*_Geo", type="transform")

        
        if len(outerCage) != 0:
            cloth = outerCage[0].split("_OuterCage")[0]
            message =  ""
            keyframeResult = self.checkKeyFrames()
            layerResult = self.checkLayers()
            transformResult = self.checkTransform(geo)
            materialResult = self.checkUnusedMaterials(geo)
            attachmentResult = self.checkAttachmentPoints()

            if self.texturefolder == "":
                confirmmessage = "Texture folder path has not been set.\n Would you like to check image format too?"
                result = cmds.confirmDialog(title='Validation Tool', message= confirmmessage, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
                if result == "Yes":
                    self.getTextureDirectory(texturefolderTextField)

            if ImageCheckingisActive == True and self.texturefolder != "":
                imageformatResult = self.checkImageFormat()
            else:
                imageformatResult = False
            # fileNamingResult = self.checkNamingConvention()
            # uvCheckResult = self.uvCheck(None)[0]

            if checkMode == 2:
                outerCage = cmds.ls("*_OuterCage")
                innerCage = cmds.ls("*_InnerCage")
                if len(outerCage) == 1:
                    outerCage = cmds.ls("*_OuterCage")[0]
                    innerCage = cmds.ls("*_InnerCage")[0]
                    cloth = outerCage.split("_OuterCage")[0]
                    closestPolygonList_outer = self.checkClothIntersection('outer', 0.009, cloth, outerCage)
                    closestPolygonList_inner = self.checkClothIntersection('inner', 0.009, cloth, innerCage)
                    closestPolygonLists = [closestPolygonList_outer, closestPolygonList_inner]
                elif len(outerCage) == 2:
                    closestPolygonList_outer = []
                    closestPolygonList_inner = []
                    outerCage = cmds.ls("*_OuterCage")
                    innerCage = cmds.ls("*_InnerCage")

                    if "right" in outerCage[0].lower():
                        OuterCage_right = outerCage[0]
                        if "left" in outerCage[1].lower():
                            OuterCage_left = outerCage[1]
                    elif "left" in outerCage[0].lower():
                        OuterCage_left = outerCage[0]
                        if "right" in outerCage[1].lower():
                            OuterCage_right = outerCage[1]
                    else:
                        print("Number of outer cage isn't match.")
                

                    if "right" in innerCage[0].lower():
                        InnerCage_right = innerCage[0]
                        if "left" in innerCage[1].lower():
                            InnerCage_left = innerCage[1]
                    elif "left" in innerCage[0].lower():
                        InnerCage_left = innerCage[0]
                        if "right" in innerCage[1].lower():
                            InnerCage_right = innerCage[1]
                    else:
                        print("Number of inner cage isn't match.")
                
                    cloth_right = OuterCage_right.split("_OuterCage")[0]
                    cloth_left = OuterCage_left.split("_OuterCage")[0]

                    closestPolygonList_outer_right = self.checkClothIntersection('outer', 0.009, cloth_right, OuterCage_right)
                    closestPolygonList_inner_right = self.checkClothIntersection('inner', 0.009, cloth_right, InnerCage_right)
                    closestPolygonList_outer_left = self.checkClothIntersection('outer', 0.009, cloth_left, OuterCage_left)
                    closestPolygonList_inner_left = self.checkClothIntersection('inner', 0.009, cloth_left, InnerCage_left)
                    closestPolygonLists = [closestPolygonList_outer_right, closestPolygonList_inner_right, closestPolygonList_outer_left, closestPolygonList_inner_left]



            # clothIntersectionResult_outer, closestPolygonList_outer = self.checkClothIntersection('outer', 0.009)
            # clothIntersectionResult_inner, closestPolygonList_inner = self.checkClothIntersection('inner', 0.009)

            # cloth = pm.ls("*_OuterCage")[0].split("_OuterCage")[0]
            # for i in closestPolygonList_outer:
            #     pm.select(cloth + ".f[%i]" % i, add=True)
            # for i in closestPolygonList_inner:
            #     pm.select(cloth + ".f[%i]" % i, add=True)

            if layerResult == True:
                # message += "Layers\n"
                # message += "No layers.\n"
                cmds.button(btnList["btn_01"], e = True, bgc = [0.0, 1.0, 0.02])
            else:
                message += "Layers\n"
                message += "There are more than 1 layer.\n"
                cmds.button(btnList["btn_01"], e = True, bgc = [1.0, 1.0, 0.02])
            
            if transformResult == True:
                cmds.button(btnList["btn_02"], e = True, bgc = [0.0, 1.0, 0.02])
            else:
                message = "Following object has transform values.\n"
                for k in transformResult:
                    text = k + "\n"
                    message += text
                    for r in transformResult[k]:
                        text = r + "\n"
                        message += text
                    message += "\n"
                cmds.button(btnList["btn_02"], e = True, bgc = [1.0, 1.0, 0.02])
                
            if materialResult == True:
                cmds.button(btnList["btn_03"], e = True, bgc = [0.0, 1.0, 0.02])
            else:
                for result in materialResult:
                    if result == "01_mat":
                        message +=  "\n"
                        message += "Unused materials\n"
                        for mat in materialResult["01_mat"]:
                            message += str(mat)
                            message += "\n"
                    if result == "05_history":
                        message +=  "\n"
                        message += "History\n"
                        message += "There are construction histories on following geometries.\n"
                        for obj in materialResult["05_history"]:
                            text = obj + "\n"
                            message += text
                        message += "\n"
                cmds.button(btnList["btn_03"], e = True, bgc = [1.0, 1.0, 0.02])
                
            if keyframeResult == True:
                # message +=  "\n"
                # message += "Key frames\n"
                # message += "No key frames on the assets.\n"
                cmds.button(btnList["btn_04"], e = True, bgc = [0.0, 1.0, 0.02])
            else:
                message +=  "\n"
                message += "Key frames\n"
                for animCurve in keyframeResult:
                    txt = str(animCurve) + " has keyframes."
                    message += txt
                    message += "\n"
                cmds.button(btnList["btn_04"], e = True, bgc = [1.0, 1.0, 0.02])
                
            if attachmentResult == True:
                # message +=  "\n"
                # message += "Attachment points\n"
                # message += "Attachment points are correct.\n"
                cmds.button(btnList["btn_05"], e = True, bgc = [0.0, 1.0, 0.02])
            else:
                message += "\n"
                message += "Attachment points\n"
                for wrongpos in attachmentResult[0]:
                    txt =  str(wrongpos[0]) + " should be at " +  str(wrongpos[2])
                    message += txt
                    message += "\n"
                for wrongname in attachmentResult[1]:
                    message += "Naming convention is different at following points.\n"
                    message += str(wrongname[0])
                    message += "\n"
                cmds.button(btnList["btn_05"], e = True, bgc = [1.0, 1.0, 0.02])
                        
            # if checkMode == 2:
            #     if len(closestPolygonList_inner) == 0 and len(closestPolygonList_outer) == 0 :
            #         cmds.button(btnList["btn_06"], e = True, bgc = [0.0, 1.0, 0.02])
            #     if len(closestPolygonList_inner) != 0 or len(closestPolygonList_outer) != 0 :
            #         message += "\n"
            #         message += "Cloth intersection\n"
            #         message += "There are intersections between cloth mesh and cage mesh."
            #         message += "\n"
            # else:
            #     cmds.button(btnList["btn_06"], e = True, bgc = [0.0, 1.0, 0.02])
            
            if imageformatResult == True:
                # message += "\n"
                # message += "Image format check\n"
                # message += "Texture format is correct."
                # message += "\n"
                cmds.button(btnList["btn_08"], e = True, bgc = [0.0, 1.0, 0.02])
            elif imageformatResult == False:
                message += "\n"
                message += "Image format check\n"
                message += "Texture folder path is not set. Image check was skipped."
                cmds.button(btnList["btn_08"], e = True, bgc = [0.4, 0.4, 0.4])
            else:
                message += "\n"
                message += "Image format check\n"
                message += imageformatResult
                message += "\n"
                cmds.button(btnList["btn_08"], e = True, bgc = [1.0, 1.0, 0.02])
            
            # if uvCheckResult == True:
            #     cmds.button(btnList["btn_07"], e = True, bgc = [0.0, 1.0, 0.02])
            # else:
            #     cmds.button(btnList["btn_07"], e = True, bgc = [0.0, 1.0, 0.02])

            if checkMode == 2:
                if len(closestPolygonLists) == 2:
                    closestPolygonList_outer = closestPolygonLists[0]
                    closestPolygonList_inner = closestPolygonLists[1]
                    if len(closestPolygonList_inner) == 0 and len(closestPolygonList_outer) == 0:
                        cmds.button(btnList["btn_06"], e = True, bgc = [0.0, 1.0, 0.02])
                        cmds.button(btnList["btn_07"], e = True, bgc = [0.0, 1.0, 0.02])
                    if len(closestPolygonList_outer) != 0:
                        cloth = outerCage.split("_OuterCage")[0]
                        cmds.button(btnList["btn_06"], e = True, bgc = [1.0, 1.0, 0.02])
                        for i in closestPolygonList_outer:
                            pm.select(cloth + ".f[%i]" % i, add=True)
                    if len(closestPolygonList_inner) != 0:
                        cloth = innerCage.split("_InnerCage")[0]
                        cmds.button(btnList["btn_07"], e = True, bgc = [1.0, 1.0, 0.02])
                        for i in closestPolygonList_inner:
                            pm.select(cloth + ".f[%i]" % i, add=True)


                if len(closestPolygonLists) == 4:
                    closestPolygonList_outer_right = closestPolygonLists[0]
                    closestPolygonList_inner_right = closestPolygonLists[1]
                    closestPolygonList_outer_left = closestPolygonLists[0]
                    closestPolygonList_inner_left = closestPolygonLists[1]

                    if len(closestPolygonList_outer_right) == 0 and len(closestPolygonList_inner_right) == 0 and len(closestPolygonList_outer_left) == 0 and len(closestPolygonList_inner_left):
                        cmds.button(btnList["btn_06"], e = True, bgc = [0.0, 1.0, 0.02])

                    if len(closestPolygonList_outer_right) != 0:
                        cloth_right = OuterCage_right.split("_OuterCage")[0]
                        cmds.button(btnList["btn_06"], e = True, bgc = [1.0, 1.0, 0.02])
                        for i in closestPolygonList_outer_right:
                            pm.select(cloth_right + ".f[%i]" % i, add=True)
                        
                    if len(closestPolygonList_inner_right) != 0:
                        cloth_right = OuterCage_right.split("_OuterCage")[0]
                        cmds.button(btnList["btn_07"], e = True, bgc = [1.0, 1.0, 0.02])
                        for i in closestPolygonList_inner_right:
                            pm.select(cloth_right + ".f[%i]" % i, add=True)
                    
                    if len(closestPolygonList_outer_left) != 0:
                        cloth_left = OuterCage_left.split("_OuterCage")[0]
                        cmds.button(btnList["btn_07"], e = True, bgc = [1.0, 1.0, 0.02])
                        for i in closestPolygonList_outer_left:
                            pm.select(cloth_left + ".f[%i]" % i, add=True)
                    
                    if len(closestPolygonList_inner_left) != 0:
                        cloth_left = OuterCage_left.split("_OuterCage")[0]
                        cmds.button(btnList["btn_07"], e = True, bgc = [1.0, 1.0, 0.02])
                        for i in closestPolygonList_inner_left:
                            pm.select(cloth_left + ".f[%i]" % i, add=True) 

                        # len(closestPolygonList_outer_left) != 0 or len(closestPolygonList_inner_left):
                        # cloth_right = OuterCage_right.split("_OuterCage")[0]
                        # cmds.button(btnList["btn_06"], e = True, bgc = [1.0, 1.0, 0.02])
                        # for i in closestPolygonList_outer_right:
                        #     pm.select(cloth_right + ".f[%i]" % i, add=True)
                        # for i in closestPolygonList_inner_right:
                        #     pm.select(cloth_right + ".f[%i]" % i, add=True)
                        # cloth_left = OuterCage_left.split("_OuterCage")[0]
                        # for i in closestPolygonList_outer_left:
                        #     pm.select(cloth_left + ".f[%i]" % i, add=True)
                        # for i in closestPolygonList_inner_left:
                        #     pm.select(cloth_left + ".f[%i]" % i, add=True)


            ##OUT PUT MESSAGE HERE
            self.changeText(resultField, message)
            confirmMessage = "Validation process is finished\n Please check details in results tab."
            cmds.confirmDialog( title='Validation Tool', message= confirmMessage, dismissString='OK' )
        else:
            cmds.confirmDialog( title='Validation Tool', message= "Cloth object is not found in the scene.", dismissString='OK' )
    ##///////////////////////////////////////////////// Main Check functions ////////////////////////////////////////////////


        
    ##/////////////////////////////////////////////////////// Fix Key Frames ////////////////////////////////////////////////
    def fixKeyFrames(self, btnList, *args):
        keyframeResult = self.checkKeyFrames()
        if keyframeResult == True:
            message = "No keyframe is found on the asset."
            cmds.confirmDialog( title='Keyframe check', message= message, dismissString='OK' )
            cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
        else:
            message ="Key frames are found. Would you like to delete them?"
            result =  cmds.confirmDialog( title='Key frame check', message= message, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
            if result == "Yes":
                cmds.delete(keyframeResult)
                cmds.confirmDialog( title='Keyframe check', message= "Key frames are deleted. ", dismissString='OK' )
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
    ##/////////////////////////////////////////////////////// Fix Key Frames ////////////////////////////////////////////////



    ##/////////////////////////////////////////////////////// Fix Layers ////////////////////////////////////////////////////
    def fixLayers(self, btnList, *args):
        layerResult = self.checkLayers()
        if layerResult  == True:
            message ="No extra layers are found in this scene."
            cmds.confirmDialog( title='Layer check', message= message, dismissString='OK' )
            cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
        else:
            message ="Layers are found. Would you like to delete them?"
            result =  cmds.confirmDialog( title='Layer check', message= message, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
            if result == "Yes":
                for l in layerResult:
                    if l != "defaultLayer":
                        cmds.delete(l)
                cmds.confirmDialog( title='Layer check', message= "Layers are deleted.", dismissString='OK' )
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
    ##/////////////////////////////////////////////////////// Fix Layers ////////////////////////////////////////////////////

    ##/////////////////////////////////////////////////////// Fix Transform ////////////////////////////////////////////////////
    def fixTransform(self, btnList, mode, resultField, *args):
        # checkmode = cmds.radioButtonGrp(mode, query = True, sl=True)
        checkmode = 2
        objs = []
        if checkmode == 1:
            objs = cmds.ls("*Geo", type="transform")
        elif checkmode == 2:
            outerCage = pm.ls("*_OuterCage")
            if len(outerCage) == 1:
                objs = cmds.ls(outerCage[0].split("_OuterCage")[0])
            elif len(outerCage) == 2:
                for cage in outerCage:
                    objs.append(cmds.ls(cage.split("_OuterCage")[0])[0])
            else:
                objs = []

        if len(objs) != 0:
            transformResult = self.checkTransform(objs)
            if transformResult == True:
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                message = "Transform is ok."
                cmds.confirmDialog( title='Transform check', message= message, dismissString='OK' )
            else:
                cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                message = "Following object has transform values.\n"
                # print(len(transformResult))
                for k in transformResult:
                    text = k + "\n"
                    message += text
                    for r in transformResult[k]:
                        text = r + "\n"
                        message += text
                    message += "\n"
                self.changeText(resultField,message)
                message = "Some objects have transform values. Please Check reults tab for details."
                cmds.confirmDialog( title='Transform check', message= message, dismissString='OK' )
        else:
            cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
            message = "Geometries are not found.\n Make sure the selected check mode is correct for your asset."
            cmds.confirmDialog( title='Transform check', message= message, dismissString='OK' )
    ##/////////////////////////////////////////////////////// Fix Transform ////////////////////////////////////////////////////


    ##///////////////////////////////////////////////// Fix attachment point ////////////////////////////////////////////////////
    def fixAttachmentPoints(self, btnList, *args):
        result = self.checkAttachmentPoints()
        if result == True:
            message ="Attachment point is good."
            cmds.confirmDialog( title='Attachment point check', message= message, dismissString='OK' )
            cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
        else:
            message = ""
            for attachPoint in result[0]:
                cmds.parent(attachPoint[0], attachPoint[2])
            if len(result[1]) != 0:
                message += "Naming convention is different at following points.\n"
                for attachPoint in result[1]:
                    message += str(attachPoint[0])
                    message += "\n"
                cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                cmds.confirmDialog(title='Attachment point check', message= message, dismissString='OK' )
            result = self.checkAttachmentPoints()
            if result == True:
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
    ##///////////////////////////////////////////////// Fix attachment point ////////////////////////////////////////////////////
    
    
    ##///////////////////////////////////////////////// Fix Intersections////////////////////////////////////////////////////
    def fixIntersections(self, btnList, *args):
        cloth = None
        outerCage = cmds.ls("*_OuterCage")
        innerCage = cmds.ls("*_InnerCage")
        isChecked = False

        if len(outerCage) == 1:
            outerCage = cmds.ls("*_OuterCage")[0]
            innerCage = cmds.ls("*_InnerCage")[0]
            cloth = outerCage.split("_OuterCage")[0]
            closestPolygonList_outer = self.checkClothIntersection('outer', 0.009, cloth, outerCage, innerCage)
            closestPolygonList_inner = self.checkClothIntersection('inner', 0.009, cloth, outerCage, innerCage)
            closestPolygonLists = [closestPolygonList_outer, closestPolygonList_inner]
            isChecked = True
        elif len(outerCage) == 2:
            closestPolygonList_outer = []
            closestPolygonList_inner = []
            outerCage = cmds.ls("*_OuterCage")
            innerCage = cmds.ls("*_InnerCage")

            if "right" in outerCage[0].lower():
                OuterCage_right = outerCage[0]
                if "left" in outerCage[1].lower():
                    OuterCage_left = outerCage[1]
            elif "left" in outerCage[0].lower():
                OuterCage_left = outerCage[0]
                if "right" in outerCage[1].lower():
                    OuterCage_right = outerCage[1]
            else:
                print("Number of outer cage does not match.")
            
            if "right" in innerCage[0].lower():
                InnerCage_right = innerCage[0]
                if "left" in innerCage[1].lower():
                    InnerCage_left = innerCage[1]
            elif "left" in innerCage[0].lower():
                InnerCage_left = innerCage[0]
                if "right" in innerCage[1].lower():
                    InnerCage_right = innerCage[1]
            else:
                print("Number of inner cage does not match.")
            
            cloth_right = OuterCage_right.split("_OuterCage")[0]
            cloth_left = OuterCage_left.split("_OuterCage")[0]

            closestPolygonList_outer_right = self.checkClothIntersection('outer', 0.009, cloth_right, OuterCage_right, InnerCage_right)
            closestPolygonList_inner_right = self.checkClothIntersection('inner', 0.009, cloth_right, OuterCage_right, OuterCage_right)
            closestPolygonList_outer_left = self.checkClothIntersection('outer', 0.009, cloth_left, OuterCage_right, InnerCage_right)
            closestPolygonList_inner_left = self.checkClothIntersection('inner', 0.009, cloth_left, OuterCage_right, OuterCage_right)
            closestPolygonLists = [closestPolygonList_outer_right, closestPolygonList_inner_right, closestPolygonList_outer_left, closestPolygonList_inner_left]
            isChecked = True
        else:
            message = "Cage geometry was not found in the scene.\n"
            cmds.confirmDialog(title='Cloth intersection', message= message, dismissString='OK' )
            cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])



        if isChecked == True:
            if len(closestPolygonList_inner) == 0 and len(closestPolygonList_outer) == 0 :
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
            elif len(closestPolygonList_inner) != 0 or len(closestPolygonList_outer) != 0 :
                message = "Cloth intersection\n"
                message += "There are intersections between cloth mesh and cage mesh.\n"
                cmds.confirmDialog(title='Cloth intersection', message= message, dismissString='OK' )
                cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])

    
            if len(closestPolygonLists) == 2:
                closestPolygonList_outer = closestPolygonLists[0]
                closestPolygonList_inner = closestPolygonLists[1]
                if len(closestPolygonList_inner) == 0 and len(closestPolygonList_outer) == 0 :
                    cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                elif len(closestPolygonList_outer) != 0 or len(closestPolygonList_inner) != 0:
                    cloth = outerCage.split("_OuterCage")[0]
                    cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                    for i in closestPolygonList_outer:
                        pm.select(cloth + ".f[%i]" % i, add=True)
                    for i in closestPolygonList_inner:
                        pm.select(cloth + ".f[%i]" % i, add=True)
            if len(closestPolygonLists) == 4:
                closestPolygonList_outer_right = closestPolygonLists[0]
                closestPolygonList_inner_right = closestPolygonLists[1]
                closestPolygonList_outer_left = closestPolygonLists[0]
                closestPolygonList_inner_left = closestPolygonLists[1]
                if len(closestPolygonList_outer_right) == 0 and len(closestPolygonList_inner_right) == 0 and len(closestPolygonList_outer_left) == 0 and len(closestPolygonList_inner_left):
                    cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                elif len(closestPolygonList_outer_right) != 0 or len(closestPolygonList_inner_right) != 0 or len(closestPolygonList_outer_left) != 0 or len(closestPolygonList_inner_left):
                    cloth_right = OuterCage_right.split("_OuterCage")[0]
                    cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                    for i in closestPolygonList_outer_right:
                        pm.select(cloth_right + ".f[%i]" % i, add=True)
                    for i in closestPolygonList_inner_right:
                        pm.select(cloth_right + ".f[%i]" % i, add=True)
                    cloth_left = OuterCage_left.split("_OuterCage")[0]
                    for i in closestPolygonList_outer_left:
                        pm.select(cloth_left + ".f[%i]" % i, add=True)
                    for i in closestPolygonList_inner_left:
                        pm.select(cloth_left + ".f[%i]" % i, add=True)
    ##///////////////////////////////////////////////// Fix Intersections////////////////////////////////////////////////////
    

    ##///////////////////////////////////////////////// Fix Intersections__Outer////////////////////////////////////////////////////
    def fixIntersections_Outer(self, btnList, *args):
        cloth = None
        outerCage = cmds.ls("*_OuterCage")
        isChecked = False
        cmds.select(d=True)

        if len(outerCage) == 1:
            outerCage = cmds.ls("*_OuterCage")[0]
            cloth = outerCage.split("_OuterCage")[0]
            closestPolygonList_outer = self.checkClothIntersection('outer', 0.009, cloth, outerCage)
            closestPolygonLists = [closestPolygonList_outer]
            isChecked = True
        elif len(outerCage) == 2:
            closestPolygonList_outer = []
            outerCage = cmds.ls("*_OuterCage")

            if "right" in outerCage[0].lower():
                OuterCage_right = outerCage[0]
                if "left" in outerCage[1].lower():
                    OuterCage_left = outerCage[1]
            elif "left" in outerCage[0].lower():
                OuterCage_left = outerCage[0]
                if "right" in outerCage[1].lower():
                    OuterCage_right = outerCage[1]
            else:
                print("Number of outer cage does not match.")
            
            cloth_right = OuterCage_right.split("_OuterCage")[0]
            cloth_left = OuterCage_left.split("_OuterCage")[0]

            closestPolygonList_outer_right = self.checkClothIntersection('outer', 0.009, cloth_right, OuterCage_right)
            closestPolygonList_outer_left = self.checkClothIntersection('outer', 0.009, cloth_left, OuterCage_right)
            closestPolygonLists = [closestPolygonList_outer_right, closestPolygonList_outer_left]
            isChecked = True
        else:
            message = "Cage geometry was not found in the scene.\n"
            cmds.confirmDialog(title='Cloth intersection', message= message, dismissString='OK' )
            cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])



        if isChecked == True:
            if len(closestPolygonLists) == 1:
                closestPolygonList_outer = closestPolygonLists[0]
                if len(closestPolygonList_outer) != 0:
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are intersections between cloth mesh and OuterCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )
                    cloth = outerCage.split("_OuterCage")[0]
                    cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                    for i in closestPolygonList_outer:
                        cmds.select(cloth + ".f[%i]" % i, add=True)
                else:
                    cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are no intersections between cloth mesh and OuterCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )

            if len(closestPolygonLists) == 2:
                closestPolygonList_outer_right = closestPolygonLists[0]
                closestPolygonList_outer_left = closestPolygonLists[1]
                if len(closestPolygonList_outer_right) == 0 and len(closestPolygonList_outer_left) == 0:
                    cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are no intersections between cloth mesh and OuterCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )
                elif len(closestPolygonList_outer_right) != 0 or len(closestPolygonList_outer_left) != 0:
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are intersections between cloth mesh and OuterCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )
                    cloth_right = OuterCage_right.split("_OuterCage")[0]
                    cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                    for i in closestPolygonList_outer_right:
                        cmds.select(cloth_right + ".f[%i]" % i, add=True)
                    cloth_left = OuterCage_left.split("_OuterCage")[0]
                    for i in closestPolygonList_outer_left:
                        cmds.select(cloth_left + ".f[%i]" % i, add=True)
   ##///////////////////////////////////////////////// Fix Intersections__Outer////////////////////////////////////////////////////


   ##///////////////////////////////////////////////// Fix Intersections_Inner////////////////////////////////////////////////////
    def fixIntersections_Inner(self, btnList, *args):
        cloth = None
        innerCage = cmds.ls("*_InnerCage")
        isChecked = False
        cmds.select(d=True)

        if len(innerCage) == 1:
            innerCage = cmds.ls("*_InnerCage")[0]
            cloth = innerCage.split("_InnerCage")[0]
            closestPolygonList_inner = self.checkClothIntersection('inner', 0.009, cloth, innerCage)
            closestPolygonLists = [closestPolygonList_inner]
            isChecked = True
        elif len(innerCage) == 2:
            closestPolygonList_inner = []
            innerCage = cmds.ls("*_InnerCage")
            
            if "right" in innerCage[0].lower():
                InnerCage_right = innerCage[0]
                if "left" in innerCage[1].lower():
                    InnerCage_left = innerCage[1]
            elif "left" in innerCage[0].lower():
                InnerCage_left = innerCage[0]
                if "right" in innerCage[1].lower():
                    InnerCage_right = innerCage[1]
            else:
                print("Number of inner cage does not match.")
            
            cloth_right = InnerCage_right.split("_InnerCage")[0]
            cloth_left = InnerCage_left.split("_InnerCage")[0]

            closestPolygonList_inner_right = self.checkClothIntersection('inner', 0.009, cloth_right, innerCage)
            closestPolygonList_inner_left = self.checkClothIntersection('inner', 0.009, cloth_left, innerCage)
            closestPolygonLists = [closestPolygonList_inner_right, closestPolygonList_inner_left]
            isChecked = True
        else:
            message = "Cage geometry was not found in the scene.\n"
            cmds.confirmDialog(title='Cloth intersection', message= message, dismissString='OK' )
            cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])



        if isChecked == True:
            if len(closestPolygonLists) == 1:
                closestPolygonList_outer = closestPolygonLists[0]
                if len(closestPolygonList_outer) != 0:
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are intersections between cloth mesh and InnerCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )
                    cloth = innerCage.split("_InnerCage")[0]
                    cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                    for i in closestPolygonList_outer:
                        cmds.select(cloth + ".f[%i]" % i, add=True)
                else:
                    cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are no intersections between cloth mesh and InnerCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )

            if len(closestPolygonLists) == 2:
                closestPolygonList_inner_right = closestPolygonLists[0]
                closestPolygonList_inner_left = closestPolygonLists[1]
                if len(closestPolygonList_inner_right) == 0 and len(closestPolygonList_inner_left) == 0:
                    cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are no intersections between cloth mesh and InnerCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )
                elif len(closestPolygonList_inner_right) != 0 or len(closestPolygonList_inner_left) != 0:
                    confirmmessage = "Cloth intersection\n"
                    confirmmessage += "There are intersections between cloth mesh and InnerCage.\n"
                    cmds.confirmDialog(title='Cloth intersection', message= confirmmessage, dismissString='OK' )
                    cloth_right = InnerCage_right.split("_InnerCage")[0]
                    cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
                    for i in closestPolygonList_inner_right:
                        cmds.select(cloth_right + ".f[%i]" % i, add=True)
                    cloth_left = InnerCage_left.split("_InnerCage")[0]
                    for i in closestPolygonList_inner_left:
                        cmds.select(cloth_left + ".f[%i]" % i, add=True)

    ##///////////////////////////////////////////////// Fix Intersections_Inner////////////////////////////////////////////////////





    ##///////////////////////////////////////////////// Fix UV Coordinates ////////////////////////////////////////////////////
    def fixUVCoordinates(self, btnList, *args):
        uvCheckResult, wrongPositions = self.uvCheck(None)
        if uvCheckResult == True:
             cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
             print("uvfixed")
        else:
            uvCheckResult, wrongPositions = self.uvCheck(wrongPositions)
            if uvCheckResult == True:
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
                print("uvfixed")
    ##///////////////////////////////////////////////// Fix UV Coordinates ////////////////////////////////////////////////////
    
    
    
    ##///////////////////////////////////////////////// Fix Materials  //////////////////////////////////////////////////////
    def fixMaterials(self, btnList, mode, *args):
        # checkmode = cmds.radioButtonGrp(mode, query = True, sl=True)
        checkmode = 2
        objs = []
        if checkmode == 1:
            objs = cmds.ls("*_Geo", type="transform")
        elif checkmode == 2:
            outerCage = pm.ls("*_OuterCage")
            if len(outerCage) == 1:
                objs = cmds.ls(outerCage[0].split("_OuterCage")[0])
            else:
                objs = []
        message = ""
        unusedMaterial = False
        constructionHistory = False
        results = self.checkUnusedMaterials(objs)

        if results == True:
            message +=  "\n"
            message += "Unused materials or errant data check\n"
            message += "No unused materials or errant data on geometries.\n"
            cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
        else:
            cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])               
            for result in results:
                        if result == "01_mat":
                            unusedMaterial = True
                        if result == "05_history":
                            constructionHistory = True
            if unusedMaterial == True:
                message = ""
                for material in results["01_mat"]:
                    message = message + str(material) + "\n"
            if constructionHistory == True:
                message = ""
                for history in results["05_history"]:
                    message = message + str(history) + "\n"
            message = message + "\n" + "These materials are not in use. Would you like to delete them?"
            result =  cmds.confirmDialog( title='Unused materials errant data check', message= message, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
            if result == 'Yes':
                cmds.confirmDialog( title='Unused materials errant data check', message= "Unused materials are deleted", dismissString='OK' )
                mel.eval('MLdeleteUnused')
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])

    ##///////////////////////////////////////////////// Fix Materials  //////////////////////////////////////////////////////        
    


    ##/////////////////////////////////////////////////////// Fix ImageFormat ////////////////////////////////////////////////////
    def fixImageFormat(self, btnList, resultField, textfiled, *args):
        message = ""
        texturefolderIsSet = False
        confirmmessage = "Would you like to change the texture folder path?"
        result =  cmds.confirmDialog( title='Image format check', message= confirmmessage, button=['Yes','No'], defaultButton='Yes', cancelButton='No', dismissString='No' )
        if result == "Yes":
            self.getTextureDirectory(textfiled)
        
        if self.texturefolder == "":
            path = self.getTextureDirectory(textfiled)
            if path != None:
                texturefolderIsSet = True
        else:
            texturefolderIsSet = True

        if texturefolderIsSet == True:
            result = self.checkImageFormat()
            if result == True:
                message += "\n"
                message += "Image format check\n"
                message += "Texture format is correct."
                message += "\n"
                self.changeText(resultField, message)
                cmds.button(btnList, e = True, bgc = [0.0, 1.0, 0.02])
            else:
                message += "\n"
                message += "Image format check\n"
                message += result
                message += "\n"
                self.changeText(resultField, message)
                cmds.button(btnList, e = True, bgc = [1.0, 1.0, 0.02])
            cmds.confirmDialog(title='Validation Tool', message = message, dismissString='OK' )
    ##/////////////////////////////////////////////////////// Fix ImageFormat ////////////////////////////////////////////////////
    
    ##///////////////////////////////////////////////// Fix Materials  //////////////////////////////////////////////////////

    def getPath(self, pathTxt):
        f = open(pathTxt, "r")
        pythonpath = f.read()
        if os.name == 'nt':
            self.pythonpath = pythonpath.rstrip('\n')
            # self.pythonpath = pythonpath.replace("/", "\\")
        else:
            self.pythonpath = pythonpath

    def rePath(self, *args):
        if os.name == "posix":
            rawdirpath = pm.fileDialog2(fileMode = 3, cap = "Set Python directory")
            if rawdirpath != None:
                self.pythonpath = rawdirpath[0]
                self.pythonpath = self.pythonpath + "/bin/python3"
                userScriptDirectoryPath = cmds.internalVar(usd=True)
                fullPathToPythonPathText = userScriptDirectoryPath.replace("scripts/", "prefs/scripts/ValidationTool/pythonpath.txt")
                with open(fullPathToPythonPathText, "w") as f:
                    f.write(self.pythonpath)
        if os.name == "nt":
            rawdirpath = pm.fileDialog2(fileMode = 3, cap = "Set Python directory")
            if rawdirpath != None:
                self.pythonpath = rawdirpath[0] + "\\python.exe"
                userScriptDirectoryPath = cmds.internalVar(usd=True)
                userScriptDirectoryPath = userScriptDirectoryPath.replace("scripts/", r"prefs/scripts/ValidationTool/pythonpath.txt")
                fullPathToPythonPathText = userScriptDirectoryPath.replace("/", "\\")
                with open(fullPathToPythonPathText, "w") as f:
                    f.write(self.pythonpath)


    ##///////////////////////////////////////////////// Fix Materials  //////////////////////////////////////////////////////   
    
    def output(self, btnList, *args):
        file = "pythonpath.txt"
        cur_dir = os.getcwd()
        # print(self.pythonpath)
        cmds.button(btnList, e=True, bgc=[0.0, 1.0, 0.02])

    def checkPythonPath(self):
        ##UGC version has a different path for pythonpath.text 
        fullPathToPythonPathText = ""
        isPythonPath  = False
        userScriptDirectoryPath = cmds.internalVar(usd=True)
        if os.name == "nt":
            userScriptDirectoryPath = userScriptDirectoryPath.replace("scripts/", r"prefs\scripts\ValidationTool\pythonpath.txt")
            fullPathToPythonPathText = userScriptDirectoryPath.replace("/", "\\")
        if os.name == "posix":
            fullPathToPythonPathText = userScriptDirectoryPath.replace("scripts/", "prefs/scripts/ValidationTool/pythonpath.txt")
        pythonpathTXT = glob.glob(fullPathToPythonPathText)
        if len(pythonpathTXT) == 1:
            return pythonpathTXT[0]
        else:
            return False

    def createButton(self, *args):
        for path in sys.path:
            if path.endswith("prefs/scripts"):
                iconpath = path.replace("scripts", "icons")
                iconpath = iconpath + r"/robloxValidationTool.png"
        
        SHELF_NAME = "ValidationTool"
        gShelfTopLevel = mel.eval("$tmpVar=$gShelfTopLevel")
        shelves = cmds.tabLayout(gShelfTopLevel, query=1, ca=1)
        if SHELF_NAME in shelves:
            cmds.deleteUI(SHELF_NAME)
        
        cmds.shelfLayout(SHELF_NAME, parent=gShelfTopLevel)
        # cmds.shelfButton( annotation='Validation Tool', enableCommandRepeat = True, enable = True, width = 35, height = 35, manage = True, visible = True, preventOverride = False, enableBackground = False, label = 'Validation Tool', image1= "pythonFamily.png", command='validationTool()')
        cmds.shelfButton('validationTool', 
            enableCommandRepeat = True, 
            enable = True, 
            width = 35, 
            height = 35, 
            manage = True, 
            visible = True, 
            preventOverride = False, 
            enableBackground = False, 
            align = 'center', 
            labelOffset = 0, 
            font = 'boldLabelFont', 
            overlayLabelColor = (0.878431, 1, 1), 
            overlayLabelBackColor = (0, 0, 0, 0.5), 
            style = 'iconOnly', 
            marginWidth = 1, 
            marginHeight = 1, 
            commandRepeatable = True, 
            flat = True,
            annotation = 'Validate LC Assets',
            label = 'Validation Tool',
            image1 = iconpath,
            # image = iconPath + 'robloxPrint.png',
            # image1 = iconPath + 'robloxPrint.png',
            # command='validationTool()',
            command = 'import ValidationTool\nValidationTool.validationTool()',
            sourceType = 'python',
            parent = SHELF_NAME)

    def changeText(self, resultField, message):
        cmds.scrollField(resultField, e=True, text = message)

    def getTextureDirectory(self, textfiled, *args):
        dir = pm.fileDialog2(fileMode = 3, cap = "Select the texture folder")
        if dir != None:
            path = dir[0]
            cmds.textFieldButtonGrp(textfiled, e=True, text=path)
            self.texturefolder = path
        
        return dir


    def __init__(self):
        if cmds.window("validationToolWindow", exists = True):
            cmds.deleteUI("validationToolWindow")
        if os.name == "nt":
            validationToolWindow = cmds.window('validationToolWindow', title="Validation Tool", iconName='BTD', widthHeight=(240,390), titleBar=True, minimizeButton=True, maximizeButton=True, sizeable= False)
        if os.name == "posix":
            validationToolWindow = cmds.window('validationToolWindow', title="Validation Tool", iconName='BTD', widthHeight=(240,390), titleBar=True, minimizeButton=True, maximizeButton=True, sizeable= True )
            cmds.window('validationToolWindow', e=True, sizeable= False )
        cmds.columnLayout(adjustableColumn=False)

        columnMain = cmds.columnLayout()
        form = cmds.formLayout(p=columnMain)
        tabs = cmds.tabLayout(innerMarginWidth=10, innerMarginHeight=10)
        cmds.formLayout(form,edit=True,attachForm=((tabs, 'top', 0), (tabs, 'left', 0), (tabs, 'bottom', 0), (tabs, 'right', 0)) )

        child3 = cmds.rowColumnLayout(numberOfColumns=1)
        cmds.text("Validation Results")
        self.resultField = cmds.scrollField(editable=False, wordWrap=True, text='Validation results will be output here.', width = 350, height = 500)
        cmds.setParent( '..' )

        child1 = cmds.rowColumnLayout(numberOfColumns=1, cal=[1, "center"])
        # Curretnly disabled
        # cmds.text("Select asset type")
        # self.mode = cmds.radioButtonGrp( label='Mode', labelArray2=['Avatar', 'LC'], numberOfRadioButtons=2)
        self.mode = 'LC'
        # Texturefolder = cmds.textField()
        # cmds.textField(Texturefolder, edit=True)
        # cmds.button( label='Left', align='left' )
        cmds.text("Texture folder path for image format check")
        texturefolderTextField = cmds.textFieldButtonGrp(text='', buttonLabel='Set texture folder', height = 25, width = 350, rat = [1, "both", 0], cal=[1, "left"], ed=False)
        cmds.textFieldButtonGrp(texturefolderTextField, e=True, bc=partial(self.getTextureDirectory, texturefolderTextField))
        cmds.text("Run all check points")
        cmds.button( label='Check Assets', command = partial(self.check, self.btnList, self.resultField, texturefolderTextField), height = 50, width = 350, bgc = [0.1, 0.5, 1.0], align = 'center')
        cmds.text("Check each points")
        
        for b in self.btnList:
            self.btnList[b] = cmds.button()
            if b == "btn_01":
                labelName = "Layers check"
                command = partial(self.fixLayers, self.btnList[b])
            if b == "btn_02":
                labelName = "Transform check"
                command = partial(self.fixTransform, self.btnList[b], self.mode, self.resultField)
            if b == "btn_03":
                labelName = "Unused Materials check"
                command = partial(self.fixMaterials, self.btnList[b])
            if b == "btn_04":
                labelName = "Keyframe check"
                command = partial(self.fixKeyFrames, self.btnList[b])
            if b == "btn_05":
                labelName = "Attachment position and name check"
                command = partial(self.fixAttachmentPoints, self.btnList[b])
            if b == "btn_06":
                labelName = "Cloth intersections check (Outer Cage)"
                command = partial(self.fixIntersections_Outer, self.btnList[b])
            if b == "btn_07":
                labelName = "Cloth intersections check (Inner Cage)"
                command = partial(self.fixIntersections_Inner, self.btnList[b])
            if b == "btn_08":
                labelName = "Image format"
                command = partial(self.fixImageFormat, self.btnList[b], self.resultField, texturefolderTextField)

            cmds.button(self.btnList[b], e=True, label=labelName, command = command, height = 50, align = 'center', bgc = [0.4, 0.4, 0.4])
        
        cmds.text("Create Shortcut in Maya Shelf")
        cmds.button(label="Create shortcut button on Maya shelf.", command = partial(self.createButton), height = 40, align = 'center', bgc = [0.4, 0.4, 0.4])
        cmds.text("\nVersion 1.0 ( Build 2022.9.6.a )         Roblox")
        cmds.text("")
        cmds.setParent( '..' )

        cmds.tabLayout( tabs, edit=True, tabLabel=((child1, 'Check assets'),(child3, 'Results')) , height= 20, width = 200 , moveTab = [1, 2])
        
        cmds.showWindow(validationToolWindow)

validationTool()