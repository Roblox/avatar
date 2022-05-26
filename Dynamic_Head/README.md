# New Documentation Notice

The following content is out-of-date. See [Dynamic Heads](https://create.roblox.com/docs/avatar/dynamic-heads) on the Creator Documentation site for up-to-date information and downloadable resources.


# Introducing Dynamic Heads


In this section we will introduce Dynamic Heads and go over some details.

Here are some links to further material found in this repository.

[**FACS Definition**](FACS_Controls). *Explanation of FACS and how it relates to Dynamic Heads.*

[**FaceControls API**](FaceControls_API). *Introducing a new instance to the data model called FaceControls.*

[**Example Places**](Example_Places) *Example RBXL files to try Dynamic Heads and Facial Animation in Studio.*

[**Creating Facial Animation**](Creating_Facial_Animation) *Video demo showing how to create and play a face animation in Studio.*

## What Is A Dynamic Head

A Dynamic Head is a new addition to the Roblox avatars that is capable of playing facial animations 
and triggering facial expressions. A Dynamic Head MeshPart internally implements a facial rig that 
is controlled by a new instance called **FaceControls**. This allows developers to introduce 
facial emotions and moods to their characters experiences and/or platform avatars with predefined 
animation clips, similar to body animations.






https://user-images.githubusercontent.com/14972507/133705345-e920da92-f84c-4123-94cc-9712ce772a4d.mov


https://user-images.githubusercontent.com/14972507/135934870-ac952834-3bf3-417c-8d36-2a048879bdac.mov




## What Can I Do With A Dynamic Head

* Facial Animation
  - Bring your faces to life through new emotes, moods and avatar animations.

https://user-images.githubusercontent.com/87549939/136114390-8cbd029f-a2c3-4ecd-abbe-3325a3f33e15.mov


* Customization through Accessories
  - Dynamic Accessories will not only fit correctly, but will also move properly with the facial 
    animation. Examples of Dynamic Accessories: Eyelashes, Eyebrows, Glasses, Hair, Beards, and Hats. 
    
    
https://user-images.githubusercontent.com/14972507/135935037-b042fbb6-a95d-44b1-b374-4ec8e0d8c31f.mov

* Future
  - Facial animation puppeteering driven by audio and video.
  - Personalization through color, texture, and deformation.





## What Are The Components Of A Dynamic Head

* Parameterization
  - The FaceControls instance under the Dynamic Head meshpart drives 1 of 50 individual FACs 
    poses. The Facial Action Coding System (FACS) is a comprehensive, anatomically based system for describing all visually discernible facial movement. 
    These poses are combined to create expressions. Recording multiple expressions
    over time creates facial animation.
* Internal Rigging
  - Bones and skinning is added to geometry of the face. This comprises multiple bones which are 
    skinned to the vertices of the face. By transforming the bones you can pose the face.
* Mapping
  - The mapping drives the bones of the Dynamic Head based on the FACS controls. It does this by storing the bone positions for each of the 50 FACS poses. The mapping is hidden within the MeshPart. For every FACS pose the translation and rotation of the bones is stored. When the FACS poses are driven with FaceControls the position of the bones are updated from these stored transforms.
* Fitting
  - Using a cage we can attach different Dynamic Accessories. The accessories currently need to 
    share joints and skinning in order for the Dynamic Head to function properly.



https://user-images.githubusercontent.com/14972507/135935138-a74f4db4-9fd7-40b2-b518-3466a5d77bbd.mp4


## Dynamic Head Rollout Plan
<img width="1270" alt="Rollout Plan" src="https://user-images.githubusercontent.com/87549939/136115255-c8f445fd-8808-4c2a-b9f6-17de4554aaf7.png">

## FAQ

**Q: I tried playing the example place but facial animation didn’t work, why is that?**

A: In order to try out facial animation you need to open the example place in Studio, turn on the “Facial Animation” beta feature, and restart.

**Q: This is super cool! Can I add Dynamic Heads and facial animation into my experience?**

A: Not yet! This release is a preview of the tech and functionality we’ll be releasing next year. In the meantime you can explore the documentation, familiarize yourself with the addition of the FaceControls instance in the data model, and play around with facial animation within the Studio beta feature!

**Q: What is the performance impact of adding Dynamic Heads in my experience?**

A: We’re working hard to optimize performance and we hope to release this functionality next year with little to no hit on performance. In the current release, the FaceControls instance drives the BoneInstance of the Dynamic heads and as such performance is tied to the number of bones in the Dynamic head rig.

**Q: How can I make a new Dynamic Head that supports facial animation?**

A: Next year we will release templates, tools, documentation, and tutorials that will help you make new Dynamic Heads for your experience.

**Q: If I make a new facial animation for a particular Dynamic Head, do I need to re-create the facial animation for a different head?**

A: Nope! The beauty of the FaceControls API is that we’re standardizing all the controls that move the face. This means that every Dynamic Head could be animated using the same controls and the same facial animation will work with every Dynamic Head that follows this new schema.

**Q: How does the increase in the number of bones impact the performance of my experience?**

A: The example place has Dynamic Heads with 31 bones. While we don’t expect much degradation in the run time performance (FPS), the join time for a game might be impacted slightly with rigs that have 100’s of bones.

**Q: How can I use the FaceControls API?**

A: The FaceControls API can be used to create new face animations in the Animation Editor. Furthermore, plugins can change the FACS values through the code.

**Q: Can I directly animate the head using the bones?**

A: The underlying bones in the Dynamic Head rig are currently exposed in the Data Model but this might change in the future. In fact, these bones are procedurally driven by FaceControls and hence cannot be directly animated.

**Q: How can I make existing heads dynamic?** 

A: Currently there is no easy process to do this. Next Year we will release tools, documentation, and tutorials that will help you make your existing head dynamic.

**Q: Can I change the FACS controls through a script?** 

A: Yes, as long as the script is running as a plugin.


