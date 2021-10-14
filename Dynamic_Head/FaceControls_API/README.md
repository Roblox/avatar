# FaceControls API

A Dynamic Head consists of the following four components:

- Skinned **MeshPart** instance for the head geometry
- **Bones** that deform this skinned **MeshPart**
- _[NEW]_ **FaceControls** instance that moves these **Bones** when properties such as **Facecontrols.JawDrop** are changed.
- Cage **WrapTarget** instance for tight fitting facial accessories


The following figure shows these in the explorer.
<img width="900" alt="Screen Shot 2021-10-13 at 11 35 33 AM" src="https://user-images.githubusercontent.com/87549939/137193069-45693fd4-ed25-4ea0-9800-8d397b82b9ff.png">


## Updating MeshPart to support dynamic heads


In Maya, our artists created a joint-driven rig and posed the joints to match each of the individual FACS controls. We wrote a custom Maya plugin to extract a facs-to-joint mapping from these poses and store it as part of the character rig FBX.

This mapping is internal to the **MeshPart** that moves the bones when **FaceControls** properties are changed. This mapping maps **FaceControls** properties to the **Bones** and is not exposed to developers. When a Dynamic Head fbx is imported in Studio, this mapping is automatically imported as well. The mapping is stored with the **MeshPart**’s asset in the CDN (content delivery network). The **MeshPart** for a Dynamic Head looks and behaves the same as usual except when a **FaceControls** instance is a child of the MeshPart. Editing the properties of the **FaceControls** deforms the **MeshPart**’s geometry. Here is an example of how to set some of these properties from a script:

```
workspace.BlockyMale.Head.FaceControls.JawDrop = 0.5
workspace.BlockyMale.Head.FaceControls.LeftEyeClosed = 1.0
workspace.BlockyMale.Head.FaceControls.RightEyeClosed = 1.0
```


When the above lua code is executed, the **FaceControls** properties **JawDrop**, **LeftEyeClose**, and **RightEyeClose** are changed, which in turn moves the relevant subset of **Bones**. The **Bones** in turn drive the skinning which deforms the **MeshPart**’s geometry such that the left and right eyes are closed and the mouth is open half way.

Note that while the **Bones** are visible in the explorer, they cannot be directly animated or changed because they are procedurally driven by **FaceControls**. _We strongly discourage relying on these bones for other game behavior because they might be hidden or removed altogether in a future release._

Our **release plans**: We plan to release these plugins and detailed tutorials for authoring dynamic heads with custom mapping over the course of  the next year.

