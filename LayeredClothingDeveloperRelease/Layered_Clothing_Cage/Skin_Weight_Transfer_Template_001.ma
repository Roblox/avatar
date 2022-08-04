//Maya ASCII 2020 scene
//Name: Skin_Weight_Transfer_Template_001.ma
//Last modified: Thu, Aug 04, 2022 12:03:28 PM
//Codeset: 1252
requires maya "2020";
requires "mtoa" "4.0.3";
requires "stereoCamera" "10.0";
requires "COLLADA" "3.05B";
requires "depthOfFieldView" "1.0";
requires "exportInfoNode" "7.0";
requires "finalRender" "0.2.1.6";
requires "stereoCamera" "10.0";
requires "imdLocator" "8.5";
requires "hctMayaSceneExport" "2012.2.0.1 (2012.2 r1)";
requires "mtoa" "4.0.3";
currentUnit -l centimeter -a degree -t film;
fileInfo "application" "maya";
fileInfo "product" "Maya 2020";
fileInfo "version" "2020";
fileInfo "cutIdentifier" "202011110415-b1e20b88e2";
fileInfo "osv" "Microsoft Windows 10 Technical Preview  (Build 19044)\n";
fileInfo "UUID" "67C5A629-4329-F0FE-A222-4A83C2C15CBA";
createNode transform -s -n "persp";
	rename -uid "E779A3F1-4871-6B8A-6B90-A2A74408687B";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 4.8655539865183908 2.3178919760593901 9.0207582896599483 ;
	setAttr ".r" -type "double3" -14.138352729682454 28.599999999972969 -9.0564246986460899e-16 ;
createNode camera -s -n "perspShape" -p "persp";
	rename -uid "41E3E90C-4C6C-13E1-6A49-84A3ABA0D25C";
	setAttr -k off ".v" no;
	setAttr ".fl" 34.999999999999993;
	setAttr ".coi" 10.481777851230031;
	setAttr ".imn" -type "string" "persp";
	setAttr ".den" -type "string" "persp_depth";
	setAttr ".man" -type "string" "persp_mask";
	setAttr ".tp" -type "double3" 0 -0.24243080615997314 0.096700996160507202 ;
	setAttr ".hc" -type "string" "viewSet -p %camera";
createNode transform -s -n "top";
	rename -uid "40BBE040-4F03-635B-CA56-97B76EE6DC91";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 0 1000.1 0 ;
	setAttr ".r" -type "double3" -90 0 0 ;
createNode camera -s -n "topShape" -p "top";
	rename -uid "8A32FECE-41C9-2B7E-CA8C-0699C6B20358";
	setAttr -k off ".v" no;
	setAttr ".rnd" no;
	setAttr ".coi" 1000.1;
	setAttr ".ow" 30;
	setAttr ".imn" -type "string" "top";
	setAttr ".den" -type "string" "top_depth";
	setAttr ".man" -type "string" "top_mask";
	setAttr ".hc" -type "string" "viewSet -t %camera";
	setAttr ".o" yes;
createNode transform -s -n "front";
	rename -uid "632AFF3C-4CAC-559E-6C07-BB9B90FF62AD";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 0.11635199617167152 1.4574149228001807 1000.1022147518514 ;
createNode camera -s -n "frontShape" -p "front";
	rename -uid "A21541EE-4A31-95DE-297D-65BD9E883A85";
	setAttr -k off ".v" no;
	setAttr ".rnd" no;
	setAttr ".coi" 1000.0504974617324;
	setAttr ".ow" 1.9577820707323024;
	setAttr ".imn" -type "string" "front";
	setAttr ".den" -type "string" "front_depth";
	setAttr ".man" -type "string" "front_mask";
	setAttr ".tp" -type "double3" 0.29132285756562137 1.0664890342803648 0.051717290118972414 ;
	setAttr ".hc" -type "string" "viewSet -f %camera";
	setAttr ".o" yes;
createNode transform -s -n "side";
	rename -uid "11614D8E-4A0A-2C7C-D497-7DB6EC9D4885";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 1000.1061257784298 1.8424913549740669 0.23637467657693087 ;
	setAttr ".r" -type "double3" 0 90 0 ;
createNode camera -s -n "sideShape" -p "side";
	rename -uid "27E94E34-4304-A0BB-9373-429E16682580";
	setAttr -k off ".v" no;
	setAttr ".rnd" no;
	setAttr ".coi" 1000.1061257784298;
	setAttr ".ow" 2.2509280447495548;
	setAttr ".imn" -type "string" "side";
	setAttr ".den" -type "string" "side_depth";
	setAttr ".man" -type "string" "side_mask";
	setAttr ".tp" -type "double3" 0 0.73537223041057587 0.084777452051639557 ;
	setAttr ".hc" -type "string" "viewSet -s %camera";
	setAttr ".o" yes;
createNode joint -n "Root";
	rename -uid "A7D4677D-4BAF-81B1-C658-25B1E6AF5D4E";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr ".radi" 0.2;
createNode joint -n "HumanoidRootNode" -p "Root";
	rename -uid "97075A80-4E9C-DEC4-26E8-718B2A12084C";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 1;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr ".radi" 0.2;
createNode joint -n "LowerTorso" -p "HumanoidRootNode";
	rename -uid "86CA44D5-4885-7A89-395D-2FA8AF0B8B43";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 2;
	setAttr ".t" -type "double3" -1.7256332301709633e-31 0.0010445861844345927 -8.5500786833181798e-16 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr ".radi" 0.2;
createNode joint -n "UpperTorso" -p "LowerTorso";
	rename -uid "99C08C3F-4F34-0CC2-EA7B-FF82C3E1E31D";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 3;
	setAttr ".t" -type "double3" 0 0.30419355558370681 0.071786129418169337 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0.30419355558370681 0.071786129418169337 1;
	setAttr ".radi" 0.2;
createNode joint -n "Head" -p "UpperTorso";
	rename -uid "392F4207-43E1-D017-FC92-4AAB4E0D727C";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 4;
	setAttr ".t" -type "double3" 0 1.3589628373390124 -0.05342726528749616 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 1.6631563929227191 0.018358864130673176 1;
	setAttr ".radi" 0.2;
createNode transform -n "Hat_Att" -p "Head";
	rename -uid "BBD6F571-434A-9773-FE38-8096EBDD49DD";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 0 0.99989 0 ;
createNode mesh -n "Hat_AttShape" -p "Hat_Att";
	rename -uid "9A5C642C-4AFA-8D04-BE94-64A7AB4D8B29";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr ".db" yes;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode transform -n "Hair_Att" -p "Head";
	rename -uid "90634FE2-4656-80C1-AAC5-E880C129B068";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 0 0.99989 0 ;
createNode mesh -n "Hair_AttShape" -p "Hair_Att";
	rename -uid "EFC2B55F-4C75-6A49-D379-099348033E97";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr ".db" yes;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode orientConstraint -n "Head_orientConstraint1" -p "Head";
	rename -uid "AB45366D-4E5F-CA90-2E3A-209C8DDAE5C5";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode orientConstraint -n "Head_orientConstraint2" -p "Head";
	rename -uid "6C3B1C93-4CE5-5008-F81E-E49454C04E60";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode joint -n "LeftUpperArm" -p "UpperTorso";
	rename -uid "FA101AFF-4DA9-FFA1-C10E-2799F8798EDC";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 4;
	setAttr ".t" -type "double3" 0.47164059093158489 1.0944316379404191 -0.053066046096766781 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.47164059093158489 1.3986251935241258 0.018720083321402556 1;
	setAttr ".radi" 0.2;
createNode joint -n "LeftLowerArm" -p "LeftUpperArm";
	rename -uid "2099867E-44B7-2A8A-EB53-8DA31E51DA31";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 5;
	setAttr ".t" -type "double3" 0.39978842937747716 -0.58902288848115025 0 ;
	setAttr ".r" -type "double3" -1.5166068366123108e-21 1.5166095485163402e-21 2.4265706312305743e-20 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.871429020309062 0.80960230504297559 0.018720083321402556 1;
	setAttr ".radi" 0.2;
createNode joint -n "LeftHand" -p "LeftLowerArm";
	rename -uid "ED222708-4B8D-04E8-B140-68A7C9C8E359";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 6;
	setAttr ".t" -type "double3" 0.46979366564751379 -0.68580388877977461 0.15859127104421195 ;
	setAttr ".r" -type "double3" 6.7415172026502541e-13 1.2934420826263755e-13 3.0350524269876789e-12 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 1.3412226859565757 0.12379841626320098 0.17731135436561452 1;
	setAttr ".radi" 0.2;
createNode orientConstraint -n "LeftHand_orientConstraint1" -p "LeftHand";
	rename -uid "64EC4CF4-42C8-FAB4-B2B5-E99ECA137119";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 6.7415172026502541e-13 1.2934420826263755e-13 3.0350524269876789e-12 ;
	setAttr ".rsrr" -type "double3" 6.7415172026502541e-13 1.2934420826263755e-13 3.0350524269876789e-12 ;
createNode orientConstraint -n "LeftHand_orientConstraint2" -p "LeftHand";
	rename -uid "62FAE215-4875-7B9C-2485-0A93A3668D7E";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 6.7415172026502541e-13 1.2934420826263755e-13 3.0350524269876789e-12 ;
	setAttr ".rsrr" -type "double3" 6.7415172026502541e-13 1.2934420826263755e-13 3.0350524269876789e-12 ;
createNode orientConstraint -n "LeftLowerArm_orientConstraint1" -p "LeftLowerArm";
	rename -uid "33157826-4C3A-E5A1-BE65-16AD21214196";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -9.2904838311369548e-06 -3.7183385757089135e-06 -4.566957431961783e-05 ;
	setAttr ".o" -type "double3" 9.2904867949638434e-06 3.7183311704075845e-06 4.5669574922544203e-05 ;
	setAttr ".rsrr" -type "double3" -1.5166068366123108e-21 1.5166095485163402e-21 2.4265706312305743e-20 ;
createNode orientConstraint -n "LeftLowerArm_orientConstraint2" -p "LeftLowerArm";
	rename -uid "BA02602F-44E4-D62D-28A3-37A86FEA7ABF";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -9.2904838311369548e-06 -3.7183385757089135e-06 -4.566957431961783e-05 ;
	setAttr ".o" -type "double3" 9.2904867949638434e-06 3.7183311704075845e-06 4.5669574922544203e-05 ;
	setAttr ".rsrr" -type "double3" -1.5166068366123108e-21 1.5166095485163402e-21 2.4265706312305743e-20 ;
createNode orientConstraint -n "LeftUpperArm_orientConstraint1" -p "LeftUpperArm";
	rename -uid "A448D635-4C08-F7F8-E541-F98B142ED7DE";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode orientConstraint -n "LeftUpperArm_orientConstraint2" -p "LeftUpperArm";
	rename -uid "BE3CB421-4965-0B5F-0A4D-969E391ADEFE";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode joint -n "RightUpperArm" -p "UpperTorso";
	rename -uid "EB29BC10-4ADB-AE47-829F-20881B82398A";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 4;
	setAttr ".t" -type "double3" -0.47164059093158489 1.0944316379404191 -0.053066046096766781 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.47164059093158489 1.3986251935241258 0.018720083321402556 1;
	setAttr ".radi" 0.2;
createNode joint -n "RightLowerArm" -p "RightUpperArm";
	rename -uid "A205E349-449E-28D3-6678-E2BE3B7E0DE6";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 5;
	setAttr ".t" -type "double3" -0.39978842937747711 -0.58902288848115025 0 ;
	setAttr ".r" -type "double3" -1.5166068366123108e-21 -1.5166095485163402e-21 -2.4265706312305743e-20 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.871429020309062 0.80960230504297559 0.018720083321402556 1;
	setAttr ".radi" 0.2;
createNode joint -n "RightHand" -p "RightLowerArm";
	rename -uid "58BADA1D-49F0-8CCE-1E86-F9BAA84F9641";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 6;
	setAttr ".t" -type "double3" -0.46979366564751368 -0.68580388877977461 0.15859127104421195 ;
	setAttr ".r" -type "double3" 6.7415172026502541e-13 -1.2934420826263755e-13 -3.0350524269876789e-12 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -1.3412226859565757 0.12379841626320098 0.17731135436561452 1;
	setAttr ".radi" 0.2;
createNode orientConstraint -n "RightHand_orientConstraint1" -p "RightHand";
	rename -uid "918F1715-4490-572B-1F49-B280685E61F6";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 6.7415172026502541e-13 -1.2934420826263755e-13 -3.0350524269876789e-12 ;
	setAttr ".rsrr" -type "double3" 6.7415172026502541e-13 -1.2934420826263755e-13 -3.0350524269876789e-12 ;
createNode orientConstraint -n "RightHand_orientConstraint2" -p "RightHand";
	rename -uid "F54E064D-4A30-B60D-9279-28BB4A082506";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 6.7415172026502541e-13 -1.2934420826263755e-13 -3.0350524269876789e-12 ;
	setAttr ".rsrr" -type "double3" 6.7415172026502541e-13 -1.2934420826263755e-13 -3.0350524269876789e-12 ;
createNode orientConstraint -n "RightLowerArm_orientConstraint1" -p "RightLowerArm";
	rename -uid "EF8589A3-4390-A76B-D994-E79E8C452551";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -9.2904838311369548e-06 3.7183385757089135e-06 4.566957431961783e-05 ;
	setAttr ".o" -type "double3" 9.2904867949638434e-06 -3.7183311704075845e-06 -4.5669574922544203e-05 ;
	setAttr ".rsrr" -type "double3" -1.5166068366123108e-21 -1.5166095485163402e-21 
		-2.4265706312305743e-20 ;
createNode orientConstraint -n "RightLowerArm_orientConstraint2" -p "RightLowerArm";
	rename -uid "2A14C463-483F-3F27-C408-C886E7642B2A";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -9.2904838311369548e-06 3.7183385757089135e-06 4.566957431961783e-05 ;
	setAttr ".o" -type "double3" 9.2904867949638434e-06 -3.7183311704075845e-06 -4.5669574922544203e-05 ;
	setAttr ".rsrr" -type "double3" -1.5166068366123108e-21 -1.5166095485163402e-21 
		-2.4265706312305743e-20 ;
createNode orientConstraint -n "RightUpperArm_orientConstraint1" -p "RightUpperArm";
	rename -uid "D6BF7548-49A6-4785-70DF-0DA4C1CDF176";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode orientConstraint -n "RightUpperArm_orientConstraint2" -p "RightUpperArm";
	rename -uid "35A91786-49F7-A8C0-A0EE-77B9B49E0578";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode transform -n "BodyFront_Att" -p "UpperTorso";
	rename -uid "FCFC5494-4C0C-3356-69FC-14BE2993222E";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 0 0.49439900000000003 0.540977 ;
createNode mesh -n "BodyFront_AttShape" -p "BodyFront_Att";
	rename -uid "33AF02D1-4257-3B53-9268-D682C9AC5C8E";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr ".db" yes;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode orientConstraint -n "UpperTorso_orientConstraint1" -p "UpperTorso";
	rename -uid "D9EC9059-4899-3EB0-A897-FFAC72C77CF6";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode orientConstraint -n "UpperTorso_orientConstraint2" -p "UpperTorso";
	rename -uid "A790A61E-4A7A-EA8D-05E5-6F8A7F525692";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode joint -n "LeftUpperLeg" -p "LowerTorso";
	rename -uid "0E50CAEB-41B0-ECC3-FB77-83A1DCCA9306";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 3;
	setAttr ".t" -type "double3" 0.29964910404920925 -0.11911620210506754 0.088160396778711791 ;
	setAttr ".r" -type "double3" 3.9755962890034234e-15 4.6590156466750731e-17 -4.891966429008827e-17 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.29964910404920925 -0.11911620210506754 0.088160396778711791 1;
	setAttr ".radi" 0.2;
createNode joint -n "LeftLowerLeg" -p "LeftUpperLeg";
	rename -uid "56E2852A-4855-7AB6-4F7A-F6993C450E2D";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 4;
	setAttr ".t" -type "double3" 0.18811670562103666 -1.3123153787497153 -0.056936922919584854 ;
	setAttr ".r" -type "double3" 7.9518720177886539e-16 -6.2120208622334312e-18 9.9004082491845309e-17 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.48776580967024591 -1.4314315808547828 0.031223473859126938 1;
	setAttr ".radi" 0.2;
createNode joint -n "LeftFoot" -p "LeftLowerLeg";
	rename -uid "4AA095FD-4C06-A342-34E5-238C68FFF260";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 5;
	setAttr ".t" -type "double3" 0.15968045942250741 -1.3151813791316724 -0.10510024798669483 ;
	setAttr ".r" -type "double3" 1.6949400184512609e-29 7.5830332790935439e-22 -3.6158720393626899e-28 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.64744626909275338 -2.7466129599864555 -0.073876774127567893 1;
	setAttr ".radi" 0.2;
createNode transform -n "LeftFoot_Att" -p "LeftFoot";
	rename -uid "F912E0D2-4A4D-968E-0F6D-93A5D200630B";
	setAttr ".v" no;
	setAttr ".t" -type "double3" 0.0009040000000000159 -0.41168100000000019 0.050014 ;
createNode mesh -n "LeftFoot_AttShape" -p "LeftFoot_Att";
	rename -uid "34B19DDD-4520-8272-01CA-99ACDAE6D57F";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr ".db" yes;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode orientConstraint -n "LeftFoot_orientConstraint1" -p "LeftFoot";
	rename -uid "EF2970F2-4AE7-6968-35DE-A7BDBD6BFF37";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -6.1755884241165512e-05 -1.8391984236612712e-06 -2.4616273214904068e-06 ;
	setAttr ".o" -type "double3" 6.1755884320183901e-05 1.8391957704111636e-06 2.4616293038570673e-06 ;
	setAttr ".rsrr" -type "double3" 1.6949400184512609e-29 7.5830332790935439e-22 -3.6158720393626899e-28 ;
createNode orientConstraint -n "LeftFoot_orientConstraint2" -p "LeftFoot";
	rename -uid "7158982F-4AE7-A54D-BB23-B7BBECAEC777";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -6.1755884241165512e-05 -1.8391984236612712e-06 -2.4616273214904068e-06 ;
	setAttr ".o" -type "double3" 6.1755884320183901e-05 1.8391957704111636e-06 2.4616293038570673e-06 ;
	setAttr ".rsrr" -type "double3" 1.6949400184512609e-29 7.5830332790935439e-22 -3.6158720393626899e-28 ;
createNode orientConstraint -n "LeftLowerLeg_orientConstraint1" -p "LeftLowerLeg";
	rename -uid "6CC2C9D6-4622-3C6D-0AC0-C4985E99C285";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 4.7497622200500986 0.071532751675052922 -0.33488050969850275 ;
	setAttr ".o" -type "double3" -4.7501003704986795 -0.043556553385438734 0.3396537662851955 ;
	setAttr ".rsrr" -type "double3" 7.9518720177886539e-16 -6.2120208622334312e-18 9.9004082491845309e-17 ;
createNode orientConstraint -n "LeftLowerLeg_orientConstraint2" -p "LeftLowerLeg";
	rename -uid "0C359E64-4EB5-24E8-A7B4-6E92C63481C7";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 4.7497622200500986 0.071532751675052922 -0.33488050969850275 ;
	setAttr ".o" -type "double3" -4.7501003704986795 -0.043556553385438734 0.3396537662851955 ;
	setAttr ".rsrr" -type "double3" 7.9518720177886539e-16 -6.2120208622334312e-18 9.9004082491845309e-17 ;
createNode orientConstraint -n "LeftUpperLeg_orientConstraint1" -p "LeftUpperLeg";
	rename -uid "FB925246-4980-03F9-30CF-C38F7DB14CE9";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -5.4376511573791486 -0.0506359115242958 0.40579384565353388 ;
	setAttr ".o" -type "double3" 5.4371623044387558 0.08886053323659833 -0.39916980249044837 ;
	setAttr ".rsrr" -type "double3" 3.9755962890034234e-15 4.6590156466750731e-17 -4.891966429008827e-17 ;
createNode orientConstraint -n "LeftUpperLeg_orientConstraint2" -p "LeftUpperLeg";
	rename -uid "AACE7E41-4C7A-173A-DC0E-A89C6B6F1624";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -5.4376511573791486 -0.0506359115242958 0.40579384565353388 ;
	setAttr ".o" -type "double3" 5.4371623044387558 0.08886053323659833 -0.39916980249044837 ;
	setAttr ".rsrr" -type "double3" 3.9755962890034234e-15 4.6590156466750731e-17 -4.891966429008827e-17 ;
createNode joint -n "RightUpperLeg" -p "LowerTorso";
	rename -uid "79922112-41F0-0336-BC5D-3F9111AE4A61";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 3;
	setAttr ".t" -type "double3" -0.29964910404920925 -0.11911620210506754 0.088160396778711791 ;
	setAttr ".r" -type "double3" 3.9755962890034234e-15 -4.6590156466750731e-17 4.891966429008827e-17 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.29964910404920925 -0.11911620210506754 0.088160396778711791 1;
	setAttr ".radi" 0.2;
createNode joint -n "RightLowerLeg" -p "RightUpperLeg";
	rename -uid "DB042F94-45D7-1E4F-76C5-85A2D3C3AE7A";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 4;
	setAttr ".t" -type "double3" -0.18811670562103666 -1.3123153787497153 -0.056936922919584854 ;
	setAttr ".r" -type "double3" 7.9518720177886539e-16 6.2120208622334312e-18 -9.9004082491845309e-17 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.48776580967024591 -1.4314315808547828 0.031223473859126938 1;
	setAttr ".radi" 0.2;
createNode joint -n "RightFoot" -p "RightLowerLeg";
	rename -uid "6085D510-4B78-C07E-4473-ADA67C1993DE";
	addAttr -ci true -sn "liw" -ln "lockInfluenceWeights" -min 0 -max 1 -at "bool";
	setAttr ".uoc" 1;
	setAttr ".oc" 5;
	setAttr ".t" -type "double3" -0.15968045942250747 -1.3151813791316727 -0.10510024798669483 ;
	setAttr ".r" -type "double3" 1.6949400184512609e-29 -7.5830332790935439e-22 3.6158720393626899e-28 ;
	setAttr ".mnrl" -type "double3" -360 -360 -360 ;
	setAttr ".mxrl" -type "double3" 360 360 360 ;
	setAttr ".bps" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.64744626909275338 -2.7466129599864555 -0.073876774127567893 1;
	setAttr ".radi" 0.2;
createNode transform -n "RightFoot_Att" -p "RightFoot";
	rename -uid "3FFDFC7E-413C-4D06-D12A-84B2CF3063CA";
	setAttr ".v" no;
	setAttr ".t" -type "double3" -0.0009040000000000159 -0.41168100000000019 0.050014 ;
createNode mesh -n "RightFoot_AttShape" -p "RightFoot_Att";
	rename -uid "8F221634-4CA6-3247-3BD3-5BADF55C10AD";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr ".db" yes;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode orientConstraint -n "RightFoot_orientConstraint1" -p "RightFoot";
	rename -uid "1E2CA309-47F5-6645-3E37-D8A3BA591590";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -6.1755884241165512e-05 1.8391984236612712e-06 2.4616273214904068e-06 ;
	setAttr ".o" -type "double3" 6.1755884320183901e-05 -1.8391957704111636e-06 -2.4616293038570673e-06 ;
	setAttr ".rsrr" -type "double3" 1.6949400184512609e-29 -7.5830332790935439e-22 3.6158720393626899e-28 ;
createNode orientConstraint -n "RightFoot_orientConstraint2" -p "RightFoot";
	rename -uid "746622BB-4E3E-58A2-4105-EF8492DC2EF0";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -6.1755884241165512e-05 1.8391984236612712e-06 2.4616273214904068e-06 ;
	setAttr ".o" -type "double3" 6.1755884320183901e-05 -1.8391957704111636e-06 -2.4616293038570673e-06 ;
	setAttr ".rsrr" -type "double3" 1.6949400184512609e-29 -7.5830332790935439e-22 3.6158720393626899e-28 ;
createNode orientConstraint -n "RightLowerLeg_orientConstraint1" -p "RightLowerLeg";
	rename -uid "45E60862-4343-4EA4-0CE5-A2AAEF3C3031";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 4.7497622200500986 -0.071532751675052922 0.33488050969850275 ;
	setAttr ".o" -type "double3" -4.7501003704986795 0.043556553385438734 -0.3396537662851955 ;
	setAttr ".rsrr" -type "double3" 7.9518720177886539e-16 6.2120208622334312e-18 -9.9004082491845309e-17 ;
createNode orientConstraint -n "RightLowerLeg_orientConstraint2" -p "RightLowerLeg";
	rename -uid "8E3F131D-4593-6EA2-E926-1B9551A07EE9";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" 4.7497622200500986 -0.071532751675052922 0.33488050969850275 ;
	setAttr ".o" -type "double3" -4.7501003704986795 0.043556553385438734 -0.3396537662851955 ;
	setAttr ".rsrr" -type "double3" 7.9518720177886539e-16 6.2120208622334312e-18 -9.9004082491845309e-17 ;
createNode orientConstraint -n "RightUpperLeg_orientConstraint1" -p "RightUpperLeg";
	rename -uid "D170718F-4CAA-8C3F-C23E-C78260CA8906";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -5.4376511573791486 0.0506359115242958 -0.40579384565353388 ;
	setAttr ".o" -type "double3" 5.4371623044387558 -0.08886053323659833 0.39916980249044837 ;
	setAttr ".rsrr" -type "double3" 3.9755962890034234e-15 -4.6590156466750731e-17 4.891966429008827e-17 ;
createNode orientConstraint -n "RightUpperLeg_orientConstraint2" -p "RightUpperLeg";
	rename -uid "3A9C91A4-40EB-206F-1D96-F789AB6609E0";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".lr" -type "double3" -5.4376511573791486 0.0506359115242958 -0.40579384565353388 ;
	setAttr ".o" -type "double3" 5.4371623044387558 -0.08886053323659833 0.39916980249044837 ;
	setAttr ".rsrr" -type "double3" 3.9755962890034234e-15 -4.6590156466750731e-17 4.891966429008827e-17 ;
createNode transform -n "WaistCenter_Att" -p "LowerTorso";
	rename -uid "0BAF31A1-4E9B-9541-7B0B-289DDD50B0F4";
	setAttr ".v" no;
createNode mesh -n "WaistCenter_AttShape" -p "WaistCenter_Att";
	rename -uid "BC6FA32D-4831-8BA2-165F-60A2175BC53D";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr ".db" yes;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode orientConstraint -n "LowerTorso_orientConstraint1" -p "LowerTorso";
	rename -uid "A4A2ADE3-4A0E-D389-BE57-14AB48AF77DC";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode pointConstraint -n "LowerTorso_pointConstraint1" -p "LowerTorso";
	rename -uid "1269D4F6-4428-5A1C-C930-9288EC82B2C7";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".o" -type "double3" -6.7362921945625869e-26 0.032218009175267071 -4.2748915571023309e-16 ;
	setAttr ".rst" -type "double3" -8.6281661508548166e-32 0.00052229309221729636 -4.2750393416590899e-16 ;
createNode orientConstraint -n "LowerTorso_orientConstraint2" -p "LowerTorso";
	rename -uid "41315349-475A-29C4-A021-F3A33B706C13";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode pointConstraint -n "LowerTorso_pointConstraint2" -p "LowerTorso";
	rename -uid "561D826F-4D82-0734-157D-1A9BFDE13B7F";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
	setAttr ".o" -type "double3" -6.7362965086456624e-26 0.032479155721375719 -6.4124112279318759e-16 ;
	setAttr ".rst" -type "double3" -1.2942249226282225e-31 0.00078343963832594454 -6.4125590124886349e-16 ;
createNode orientConstraint -n "HumanoidRootNode_orientConstraint1" -p "HumanoidRootNode";
	rename -uid "5D73F7E8-44FB-450B-F280-1EBB0767F77A";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode orientConstraint -n "HumanoidRootNode_orientConstraint2" -p "HumanoidRootNode";
	rename -uid "8CE582E0-4F0B-958B-3585-6197083BA5BF";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode transform -n "Root_Att" -p "Root";
	rename -uid "A1AF9382-49F8-15B7-6BB1-34AABFC12384";
	setAttr ".v" no;
createNode mesh -n "Root_AttShape" -p "Root_Att";
	rename -uid "388FF8CC-4D09-364A-8E75-098D89CEFB1F";
	setAttr -k off ".v";
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr ".db" yes;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode orientConstraint -n "Root_orientConstraint1" -p "Root";
	rename -uid "FB1B0C5A-4259-D8F7-B4D6-C196A34C021E";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode orientConstraint -n "Root_orientConstraint2" -p "Root";
	rename -uid "9D188916-440D-8BEF-C988-26B830E1FDA7";
	setAttr -k on ".nds";
	setAttr -k off ".v";
	setAttr -k off ".tx";
	setAttr -k off ".ty";
	setAttr -k off ".tz";
	setAttr -k off ".rx";
	setAttr -k off ".ry";
	setAttr -k off ".rz";
	setAttr -k off ".sx";
	setAttr -k off ".sy";
	setAttr -k off ".sz";
	setAttr ".erp" yes;
createNode transform -n "SkinWeightTransferTemplate";
	rename -uid "50F5E876-4835-7124-7488-44AE9672B6AE";
	addAttr -ci true -sn "dr" -ln "dropoff" -dv 4 -min 0 -max 20 -at "double";
	addAttr -ci true -sn "smt" -ln "smoothness" -min 0 -at "double";
	addAttr -ci true -sn "ift" -ln "inflType" -dv 2 -min 1 -max 2 -at "short";
	setAttr -l on ".tx";
	setAttr -l on ".ty";
	setAttr -l on ".tz";
	setAttr -l on ".rx";
	setAttr -l on ".ry";
	setAttr -l on ".rz";
	setAttr -l on ".sx";
	setAttr -l on ".sy";
	setAttr -l on ".sz";
	setAttr -k on ".dr";
	setAttr -k on ".smt";
createNode mesh -n "SkinWeightTransferTemplateShape" -p "SkinWeightTransferTemplate";
	rename -uid "C925F463-423C-8BC1-DEFD-99BA27E35595";
	setAttr -k off ".v";
	setAttr -s 8 ".iog[0].og";
	setAttr ".mb" no;
	setAttr ".csh" no;
	setAttr ".rcsh" no;
	setAttr ".vis" no;
	setAttr ".pv" -type "double2" 4.0529227256774902 3.7977250814437866 ;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr ".ccls" -type "string" "colorSet1";
	setAttr -s 3 ".clst";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr ".clst[1].clsn" -type "string" "SculptFreezeColorTemp";
	setAttr ".clst[2].clsn" -type "string" "SculptMaskColorTemp";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 4 ".pt";
	setAttr ".pt[4]" -type "float3" 0 4.6566129e-10 0 ;
	setAttr ".pt[5]" -type "float3" 0 9.3132257e-10 0 ;
	setAttr ".pt[14]" -type "float3" 0 4.6566129e-10 0 ;
	setAttr ".pt[15]" -type "float3" 0 9.3132257e-10 0 ;
	setAttr ".db" yes;
	setAttr ".vcs" 2;
	setAttr ".ai_translator" -type "string" "polymesh";
createNode mesh -n "SkinWeightTransferTemplateShapeOrig" -p "SkinWeightTransferTemplate";
	rename -uid "E6846E0B-423C-8622-19A5-F993EEB1F5A7";
	setAttr -k off ".v";
	setAttr ".io" yes;
	setAttr ".vir" yes;
	setAttr ".vif" yes;
	setAttr ".csh" no;
	setAttr ".rcsh" no;
	setAttr ".uvst[0].uvsn" -type "string" "map1";
	setAttr -s 1709 ".uvst[0].uvsp";
	setAttr ".uvst[0].uvsp[0:249]" -type "float2" 3.51601481 0.39861751 3.51287627
		 0.45016515 3.53197718 0.40371072 3.55831909 0.42293239 3.53176117 0.44058692 3.50000381
		 0.42141008 3.5458169 0.42293239 3.52996302 0.42186213 3.53013849 0.42492044 3.50000381
		 0.42475438 3.51183391 0.42162681 3.51215649 0.42481804 3.48713112 0.45016527 3.48399258
		 0.39861727 3.45419049 0.42293239 3.50000381 0.44790685 3.46824646 0.44058692 3.4416883
		 0.42293215 3.46803045 0.40371072 3.50000381 0.39645278 3.4698689 0.4249202 3.47004437
		 0.42186201 3.4878509 0.42481792 3.48817372 0.42162681 3.8557291 0.61907291 3.84083891
		 0.8003 3.79974031 0.72010231 3.80938387 0.60050249 3.76150894 0.64559543 3.77836227
		 0.5695591 3.7181766 0.55945694 3.72276616 0.56819761 3.69120598 0.56255841 3.69822407
		 0.55650234 3.5976665 0.71829295 3.64984941 0.65712059 3.69432187 0.68042934 3.6495018
		 0.74788117 3.7262094 0.75386035 3.73041892 0.68729484 3.7211163 0.82113814 3.58438063
		 0.81841421 3.54873872 0.73968434 3.67678022 0.57581127 3.72744298 0.59466016 3.71572328
		 0.48591483 3.72514272 0.46986282 3.73896837 0.51536608 3.72260904 0.52747476 3.6929183
		 0.50884998 3.68649268 0.5143863 3.68580699 0.47915792 3.69240403 0.48280609 3.57858396
		 0.58970141 3.59207106 0.57801843 3.6095047 0.57801831 3.5833106 0.60073781 3.53714061
		 0.57838094 3.55277777 0.58970129 3.54927158 0.60322666 3.52989841 0.57867944 3.60819149
		 0.60120273 3.58391213 0.61600935 3.55121088 0.39455998 3.57124019 0.41847873 3.52463961
		 0.38241005 3.50000381 0.3802098 3.52971244 0.35742235 3.50000334 0.3542583 3.50000477
		 0.32459378 3.53449106 0.32525682 3.57913303 0.3318032 3.58001137 0.36897075 3.61833906
		 0.38850164 3.62675047 0.34339607 3.65492439 0.42368901 3.66675258 0.38432717 3.50000358
		 0.60206676 3.50000381 0.58307278 3.51497555 0.58256114 3.51610804 0.60323048 3.50000381
		 0.52194333 3.50000381 0.50417769 3.50949287 0.50319254 3.5122714 0.52124357 3.50000381
		 0.55506468 3.51322699 0.55447459 3.52587199 0.47828817 3.54157281 0.48629391 3.52970648
		 0.49611282 3.52291679 0.48711777 3.53301334 0.51561081 3.54341221 0.50725746 3.51304317
		 0.46692348 3.50000381 0.46699262 3.50000381 0.45582354 3.51360655 0.45678425 3.52830839
		 0.46617019 3.53116441 0.45210242 3.5127492 0.53785896 3.50000381 0.538504 3.54499316
		 0.52224088 3.53106976 0.5346818 3.54844975 0.46787012 3.5528543 0.44537592 3.54331231
		 0.62404346 3.51822019 0.62275815 3.57858396 0.5720588 3.56570911 0.57210886 3.56747627
		 0.54930127 3.58837223 0.54892302 3.54632568 0.53988719 3.55116224 0.5593338 3.52912617
		 0.55375266 3.63286304 0.55519974 3.59644222 0.51221573 3.61171985 0.44225061 3.64019299
		 0.47764707 3.66294384 0.50996244 3.5441947 0.69990456 3.50000405 0.70370734 3.5181241
		 0.6459012 3.54107332 0.64499211 3.63729811 0.63986504 3.58629417 0.68914986 3.58674574
		 0.6300025 3.50000381 0.62253475 3.56698608 0.63934803 3.56626463 0.62093425 3.55283403
		 0.57215881 3.58545756 0.42342949 3.57319784 0.46270168 3.56583261 0.44692421 3.55852485
		 0.47196376 3.56223536 0.49570465 3.50000381 0.47446847 3.51265264 0.4760325 3.51143312
		 0.48977053 3.50000381 0.49092031 3.80160117 0.39164662 3.8474021 0.3653338 3.85198188
		 0.46666026 3.81131124 0.4733572 3.78128934 0.49745464 3.68868017 0.29245806 3.64471889
		 0.27116668 3.65431285 0.18841541 3.69814968 0.1983161 3.55446458 0.17625701 3.60022473
		 0.17796135 3.59344506 0.25454473 3.54944301 0.25095582 3.58540511 0.29620373 3.63182664
		 0.30329657 3.78806615 0.22204554 3.83944368 0.21723974 3.8474021 0.33600271 3.79517841
		 0.36550736 3.74050379 0.20830095 3.73227954 0.3205812 3.67667079 0.33329391 3.50000381
		 0.28899157 3.54018092 0.29178977 3.56629062 0.60198224 3.56568146 0.58970129 3.67643905
		 0.5322907 3.74688339 0.52574468 3.75603318 0.43210363 3.65905738 0.57925141 3.56571078
		 0.52421188 3.6937933 0.4568826 3.69176388 0.43580353 3.50000381 0.24529517 3.50000381
		 0.17516756 3.89077783 0.22008944 3.89077783 0.32271671 3.89077783 0.34953821 3.89077783
		 0.45568097 3.89077783 0.61870432 3.89077783 0.88928545 3.72476625 0.88928545 3.50000381
		 0.88928545 3.50000381 0.75129783 3.71766949 0.3848871 3.50000381 0.11071455 3.55966377
		 0.11071455 3.60130811 0.11071455 3.65333915 0.11071455 3.69625354 0.11071455 3.75582027
		 0.11071455 3.79918623 0.11071455 3.84386206 0.11071455 3.89077783 0.11071455 3.76582479
		 0.44475234 3.14447665 0.61906767 3.19124031 0.60058928 3.20047188 0.72013354 3.15923214
		 0.80028534 3.22227049 0.56983995 3.23879004 0.64576972 3.28182817 0.55945754 3.30178118
		 0.55650306 3.30879974 0.56255889 3.27723837 0.56819844 3.40234041 0.71829319 3.35056567
		 0.74790895 3.30577898 0.68044508 3.35018444 0.65712631 3.2739172 0.75392187 3.26980734
		 0.68737388 3.27889991 0.82117558 3.41562629 0.81841433 3.4512682 0.73968458 3.27256155
		 0.59466076 3.32322526 0.57581151 3.28428102 0.48591542 3.27739573 0.52747536 3.26115012
		 0.51539826 3.27486157 0.46986365 3.30554962 0.51078856 3.31132722 0.51453853 3.30516744
		 0.48369479 3.31205511 0.47880435 3.42142344 0.58970141 3.41669703 0.60073781 3.39050245
		 0.57801807 3.40793657 0.57801843 3.46286678 0.57838082 3.47010899 0.57867944 3.45073581
		 0.60322666 3.44722986 0.58970141 3.4160955 0.61600935 3.39181614 0.60120344 3.44879651
		 0.39455998 3.4287672 0.41847873 3.47536755 0.38240993 3.47029638 0.35742307 3.46552181
		 0.32525921 3.41999555 0.36897087 3.38166809 0.38850176 3.37325644 0.34339631 3.4208703
		 0.33180213 3.34508204 0.42368925 3.33325338 0.38432729 3.48389935 0.60323048 3.48503137
		 0.58256114 3.48773599 0.52124369 3.49051476 0.50319254 3.48678064 0.55447459 3.47413564
		 0.47828817;
	setAttr ".uvst[0].uvsp[250:499]" 3.4770906 0.48711777 3.47030067 0.49611282
		 3.45843458 0.48629391 3.46699381 0.51561081 3.45659518 0.50725663 3.48696423 0.46692348
		 3.48640084 0.45678413 3.471699 0.46617019 3.46884322 0.45210242 3.48725843 0.5378592
		 3.4689374 0.5346818 3.45501423 0.5222404 3.45155764 0.46787 3.44715333 0.44537604
		 3.48178744 0.62275815 3.45669508 0.62404394 3.42142344 0.5720588 3.41163492 0.54892325
		 3.43253136 0.54930151 3.43429828 0.57210886 3.45368195 0.53988707 3.47088146 0.55375266
		 3.44884515 0.55933416 3.36714411 0.55519974 3.35981417 0.47764707 3.38828754 0.44225061
		 3.40356541 0.51221573 3.31013727 0.44793701 3.45581293 0.69990456 3.45893526 0.64499199
		 3.48188448 0.64590108 3.41371298 0.68915009 3.43302155 0.63934803 3.41326189 0.6300025
		 3.433743 0.62093437 3.36272216 0.63986826 3.44717312 0.57215893 3.42680955 0.46270168
		 3.41454983 0.42342949 3.43417454 0.44692421 3.44148254 0.471964 3.4377718 0.49570477
		 3.48857403 0.48977053 3.48735476 0.47603238 3.20040369 0.39165318 3.18958783 0.47332489
		 3.14836597 0.46660101 3.15259743 0.36533427 3.21921778 0.49757457 3.31132627 0.2924583
		 3.30185938 0.19831562 3.34569573 0.18841517 3.35528708 0.27116656 3.41457367 0.29619277
		 3.36818027 0.3032968 3.21192884 0.22201192 3.20562124 0.36510646 3.15259743 0.33600307
		 3.16063118 0.21710598 3.25950718 0.20830011 3.26772547 0.32058144 3.32333517 0.33329415
		 3.45982599 0.29178989 3.43432617 0.58970153 3.43371701 0.60198224 3.33706188 0.50996268
		 3.32356715 0.53229094 3.25328851 0.52577782 3.24449158 0.43212473 3.34094882 0.57925177
		 3.43429685 0.524212 3.30342507 0.46342909 3.45056367 0.25095582 3.44554305 0.17625713
		 3.40656805 0.25454724 3.39978766 0.17796326 3.10922217 0.32271671 3.10922217 0.22008812
		 3.10922217 0.34953833 3.10922217 0.45568228 3.10922217 0.61871052 3.10922217 0.88928545
		 3.27524114 0.88928545 3.28233552 0.38488746 3.44034386 0.11071455 3.39869928 0.11071455
		 3.34666777 0.11071455 3.30375409 0.11071455 3.24418855 0.11071455 3.20081401 0.11071455
		 3.1561439 0.11071455 3.10922217 0.11071455 3.23477459 0.44477975 6.5369482 3.90999842
		 6.57389545 3.88792086 6.57389545 3.90999842 6.55229282 3.95010662 6.45626926 3.69900465
		 6.45626926 3.61033201 6.5 3.61033201 6.5 3.69900465 6.41253853 3.28884745 6.48384476
		 3.27579474 6.47249126 3.32250166 6.41253853 3.32062197 6.66697121 3.53082085 6.61926603
		 3.53082085 6.61926603 3.45131111 6.66697121 3.45131111 6.50288868 3.28110981 6.50577641
		 3.35288191 6.57155991 3.61033201 6.57155991 3.69900465 6.59581757 3.94896507 6.61084175
		 3.90999842 6.57155991 3.28088164 6.57155991 3.35242605 6.49204922 3.45242167 6.51469469
		 3.45210528 6.49602413 3.53137684 6.45428181 3.53960967 6.33302879 3.28884745 6.33302879
		 3.2653749 6.41253853 3.26647449 6.39889097 3.35242605 6.33302879 3.35242653 6.33302879
		 3.32063675 6.61926603 3.61033201 6.61926603 3.69900465 6.61926603 3.28088212 6.61926603
		 3.35242605 6.57155991 3.45131111 6.57155991 3.53082132 6.46305275 3.79915667 6.5
		 3.74989343 6.5 3.79915667 6.53694725 3.76220894 6.5369482 3.79915667 6.46305275 3.84841943
		 6.46305275 3.90999842 6.42559052 3.91035461 6.5 3.84841943 6.5 3.90999842 6.53694725
		 3.84841943 6.41253853 3.41950703 6.33302927 3.41466331 6.57389545 3.79915667 6.57389545
		 3.84841943 6.61084175 3.79915667 6.61084175 3.84841943 6.38915825 3.79915619 6.38915825
		 3.84841943 6.38915825 3.90999842 4.31751251 3.41427064 4.24925947 3.40192127 4.24925947
		 3.34337473 4.31751251 3.34410763 4.38310242 3.41426992 4.38310242 3.34410763 4.38310242
		 3.51122379 4.31751251 3.51122379 4.31751251 3.46217942 4.38310242 3.46217942 4.24925947
		 3.51122379 4.24925947 3.46217942 4.46446133 3.51122379 4.46446133 3.46217942 4.46446133
		 3.34410763 4.38310242 3.27326488 4.46446133 3.27326441 4.46446133 3.41427064 4.67496872
		 3.34410763 4.67496824 3.41426992 4.57339573 3.41426992 4.57339573 3.34410763 4.67496824
		 3.27326488 4.57339573 3.27326488 4.57339573 3.24119377 4.57339573 3.209337 4.67496824
		 3.209337 4.67496824 3.24119377 4.31751251 3.27326488 4.24925995 3.27326488 4.46446133
		 3.24119377 4.38310242 3.24126959 4.38310242 3.209337 4.46446133 3.209337 4.67496824
		 3.46217942 4.67496824 3.51122379 4.57339573 3.51122379 4.57339573 3.46217942 4.57339573
		 3.68263221 4.57339573 3.65109396 4.67496872 3.65109348 4.67496824 3.68263221 4.57339573
		 3.71451044 4.67496872 3.71451044 4.46446133 3.68263221 4.38310242 3.68274927 4.38310242
		 3.65109348 4.46446133 3.65109348 4.46446133 3.71451044 4.38310242 3.71451044 4.31751251
		 3.24128532 4.24925947 3.24130058 4.31751204 3.209337 4.24925995 3.209337 4.31751251
		 3.68277621 4.31751204 3.71451139 4.24925995 3.71451139 4.24925947 3.68280268 4.31751251
		 3.65109348 4.24925995 3.65109348 3.73687673 3.021528244 3.82716942 3.021528244 3.8435607
		 3.11690521 3.73687673 3.1169467 3.66396308 3.2496767 3.58193469 3.2496767 3.58178115
		 3.11694217 3.66396308 3.11699748 3.6798687 4.27127457 3.78554106 4.31880379 3.8565855
		 4.35245752 3.64345217 4.39522648 3.67151856 4.20393085 3.56456971 4.28058147 3.56014824
		 4.2373457 3.78554106 4.20862341 3.78554106 4.95446968 3.78554106 4.87190914 3.92763042
		 4.87128067 3.92763042 4.95446968 3.64345217 4.75953197 3.64345217 4.87122202 3.56441259
		 4.87132502 3.56456971 4.75953197 3.78554153 4.75953197 3.73687673 3.2496767 3.73687673
		 3.37878513 3.66396308 3.37878537 3.66396308 3.021528244 3.61520529 3.84165668 3.55183887
		 3.80624294 3.5666461 3.77179289 3.63536596 3.80246806 3.67318726 4.045530319 3.65289211
		 4.11170483 3.62972808 4.11170483 3.65831971 4.045530319;
	setAttr ".uvst[0].uvsp[500:749]" 3.92763042 4.75953197 3.78554106 4.66754723
		 3.92762995 4.66754723 3.64345217 4.66754723 3.58193469 3.37878513 3.56456971 4.66754723
		 3.66396308 3.60748768 3.73687673 3.62372351 3.73687673 3.70321846 3.66396308 3.67419863
		 3.85974383 3.2496767 3.58165097 3.021528244 3.56427908 4.95446825 3.64345217 4.95446968
		 5.68779182 3.55765486 5.63808298 3.55765486 5.6380825 3.50184464 5.68779182 3.50184464
		 5.63808298 3.790663 5.63808298 3.75416851 5.68779182 3.76911592 5.68779182 3.790663
		 5.48895359 3.36738014 5.41429043 3.36738014 5.41429043 3.28575182 5.48895359 3.28575182
		 5.41429043 3.24831343 5.48895359 3.24754405 5.68779182 3.38571882 5.63808298 3.36738014
		 5.63808298 3.28575182 5.68779182 3.28575182 5.63808298 3.24754405 5.68779182 3.24754405
		 5.63808298 3.71767569 5.63808298 3.63581491 5.68779182 3.61478496 5.68779182 3.71767569
		 5.68779182 3.44744492 5.63808298 3.44744492 5.48895359 3.55765486 5.41429043 3.55765486
		 5.41429043 3.50184536 5.48895359 3.50184536 5.48895359 3.790663 5.41428995 3.790663
		 5.41428995 3.75420475 5.48895359 3.75416851 5.48895359 3.44744492 5.41429043 3.44744492
		 5.58837318 3.55765486 5.58837318 3.50184464 5.58837318 3.44744492 5.58837318 3.36738014
		 5.58837318 3.28575182 5.58837318 3.24754405 5.58837318 3.75416851 5.58837318 3.790663
		 4.70338631 2.68687153 4.70338631 2.80987167 4.67059469 2.80491138 4.67059469 2.68421483
		 3.82780075 1.32782412 3.82780075 1.4128952 3.66395187 1.37697744 3.66395187 1.32782412
		 3.66395116 1.60554457 3.57572651 1.77217579 3.53767252 1.77217579 3.58202648 1.60554457
		 3.57014489 2.26360655 3.61097145 2.30678082 3.55492306 2.30678082 3.53459048 2.26360655
		 3.57525587 2.45793176 3.57525587 2.34995484 3.65179825 2.34995484 3.65179825 2.45793176
		 3.58202648 1.37704468 3.58202648 1.32782412 3.58202648 1.47719824 3.74176741 1.54210567
		 3.66395187 1.53496528 3.58202648 1.53496528 3.99164915 1.48994231 3.82780075 1.4814477
		 3.99164915 1.42988467 3.65179825 2.63639331 3.57525587 2.63639331 3.57525587 2.55348539
		 3.65179825 2.55247951 3.72834063 2.54985237 3.72834063 2.63639331 3.72417951 2.44580317
		 3.7350769 2.39473987 3.66395187 1.41745996 3.58202648 1.4174943 3.99164915 1.32782388
		 3.82212973 2.54670715 3.83253574 2.63639331 4.091175556 1.60531163 4.20696354 1.60531163
		 4.20696354 1.69851124 4.091175556 1.69851124 4.71623278 1.69851124 4.71623278 1.60531163
		 4.78024483 1.60531163 4.78024483 1.69851124 4.33739758 1.69851124 4.33739758 1.60531163
		 4.38087511 1.60531163 4.38087511 1.69851124 4.54255009 1.60531163 4.65221977 1.60531163
		 4.65221977 1.69851124 4.54255009 1.69851124 4.90882444 1.60531163 4.90882444 1.69851124
		 4.20696354 1.5365566 4.091175556 1.5365566 4.091175556 1.44182372 4.20696354 1.43968391
		 4.71623278 1.5365566 4.71623278 1.43471575 4.78024483 1.4366219 4.78024483 1.5365566
		 4.71623278 1.2660377 4.71623278 1.20754695 4.78024483 1.20754695 4.78024483 1.2660377
		 4.54255009 1.2660377 4.38087511 1.2660377 4.38087511 1.20754695 4.54255009 1.20754695
		 4.38087511 1.5365566 4.33739758 1.5365566 4.33739758 1.43721759 4.38087511 1.43639588
		 4.65221977 1.5365566 4.54255009 1.5365566 4.54255009 1.43340182 4.65221977 1.43280959
		 4.90882444 1.5365566 4.90882444 1.44182372 4.20696354 1.2660377 4.091175556 1.2660377
		 4.091175556 1.20754695 4.20696354 1.20754695 4.33739758 1.2660377 4.33739758 1.20754695
		 4.65221977 1.2660377 4.65221977 1.20754695 4.90882444 1.2660377 4.90882444 1.20754695
		 4.091175556 1.35377359 4.20696354 1.35377359 4.71623278 1.35377359 4.78024483 1.35377359
		 4.33739758 1.35377359 4.38087511 1.35377359 4.54255009 1.35377359 4.65221977 1.35377359
		 4.90882444 1.35377359 4.90882444 1.79245305 4.78024483 1.79245305 4.71623278 1.79245305
		 4.65221977 1.79245305 4.54255009 1.79245305 4.38087511 1.79245305 4.33739758 1.79245305
		 4.091175556 1.79245305 4.20696354 1.79245305 4.68216515 0.59991837 4.68216515 0.53717065
		 4.70406914 0.50141412 4.71512175 0.58472443 4.5061121 0.59991837 4.47315454 0.59456491
		 4.48326588 0.510566 4.50611162 0.53717065 4.72591543 0.47213766 4.83604622 0.53717065
		 4.83604622 0.57830977 4.74807978 0.56953001 4.19476557 0.73403311 4.19476557 0.71754229
		 4.2389164 0.71754229 4.2394104 0.73403311 4.19476557 0.6687634 4.239748 0.68521106
		 4.23842096 0.70105016 4.19476557 0.70105016 4.3522315 0.65555286 4.3522315 0.53716969
		 4.44019794 0.58921075 4.44019794 0.65555286 4.63815212 0.46809351 4.63815212 0.43810529
		 4.69585848 0.45476559 4.7095232 0.41880482 4.79206324 0.37968671 4.37099409 0.46998909
		 4.39621449 0.37968671 4.47749805 0.42249054 4.45984983 0.47950903 4.63946819 0.32282698
		 4.64117336 0.26596773 4.68216515 0.26596773 4.68216515 0.32282698 4.50611162 0.65555286
		 4.47315454 0.65555286 4.71512175 0.65555215 4.68216515 0.65555215 4.83604622 0.65555286
		 4.74807978 0.65555215 4.27066231 0.73403311 4.26967287 0.71754229 4.31801319 0.71754229
		 4.31801319 0.73403311 4.26868343 0.70105016 4.27133656 0.68521106 4.31801414 0.6687634
		 4.31801414 0.70105016 4.63815212 0.40811706 4.63848114 0.35481125 4.68469334 0.35726899
		 4.68764782 0.40811706 4.18958759 0.28527084 4.19476557 0.26596701 4.31801319 0.26596653
		 4.32319164 0.28527042 4.16395378 0.46295023 4.3488245 0.49411103 4.34882498 0.53811598
		 4.16395378 0.53811598 4.63815212 0.53717065 4.24201202 2.68811536 4.22657394 2.52706242
		 4.32173157 2.52706242 4.33716965 2.68287802 4.17899466 2.82205486 4.052536964 2.79277897
		 4.052536964 2.6957612 4.17899466 2.69339609 4.36931038 2.52706242 4.32173157 2.3923893
		 4.36931038 2.3923893 4.17899466 2.52706242 4.052536964 2.52706242 4.052536964 2.3923893;
	setAttr ".uvst[0].uvsp[750:999]" 4.17899466 2.3923893 4.54741859 2.80290365
		 4.36931038 2.80249643 4.36931038 2.68292141 4.54741859 2.68313956 4.73617792 2.81483221
		 4.73617792 2.68952799 4.80902958 2.70608354 4.80902958 2.84574556 4.94746304 2.84657431
		 4.94746304 2.70652771 4.17899466 2.29089332 4.052536964 2.29089332 4.052536964 2.17700696
		 4.17899466 2.17700696 4.67059469 2.52706242 4.54741859 2.52706242 4.54741859 2.3923893
		 4.67059469 2.3923893 4.94746304 2.52706242 4.80902958 2.52706242 4.80902958 2.3923893
		 4.94746304 2.3923893 4.73617792 2.52706242 4.73617792 2.3923893 4.67059469 2.29089332
		 4.54741859 2.29089332 4.54741859 2.17700696 4.67059469 2.17700696 4.94746304 2.29089332
		 4.80902958 2.29089332 4.80902958 2.17700696 4.94746304 2.17700696 4.36931038 2.29089332
		 4.36931038 2.17700696 4.73617792 2.29089332 4.73617792 2.17700696 4.32173157 2.29089332
		 4.32173157 2.17700696 4.23609734 2.81219482 4.33125496 2.80241537 3.58193469 3.67601991
		 3.58193469 3.6086843 3.80014658 3.80473566 3.80014658 3.89035177 3.7274375 3.90300798
		 3.70672274 3.77730584 3.78554106 4.045531273 3.78554106 4.11170483 3.71324968 4.11170483
		 3.73267555 4.045530319 3.8135066 2.48949385 3.86847687 3.37878513 3.95796847 2.48745465
		 3.95796847 2.5426302 3.95796847 2.63639331 3.94974184 3.021528244 3.94974184 3.11688709
		 3.94974184 3.2496767 3.94974184 3.37878537 3.73687673 3.42502427 3.87009382 3.42488647
		 3.87171054 3.4709878 3.73687673 3.50637984 3.94974184 3.47070956 3.94974184 3.42474747
		 3.92762995 4.61065626 3.78554106 4.61065626 3.78554106 4.5537653 3.92762995 4.5537653
		 3.64345217 4.5537653 3.64345217 4.61065626 3.56456971 4.61065626 3.56456971 4.5537653
		 4.70338631 2.3923893 4.70338631 2.52706242 4.70338631 2.17700696 4.70338631 2.29089332
		 4.68422604 1.69851124 4.68422604 1.79245305 4.68422604 1.43376267 4.68422604 1.5365566
		 4.68422604 1.35377359 4.68422604 1.2660377 4.68422604 1.20754695 3.64345217 4.47449589
		 3.81349587 4.46048546 3.56456971 4.47449589 3.80488372 2.43227983 3.95796847 2.43227983
		 3.82780075 1.55000067 3.99164915 1.55000067 5.48895359 3.209337 5.41429043 3.209337
		 5.58837318 3.209337 5.63808298 3.209337 5.68779182 3.209337 5.41428995 3.71767569
		 5.48895359 3.71767569 5.58837318 3.71767569 6.33302879 3.209337 6.41253853 3.20933771
		 6.47005749 3.24256611 6.50144386 3.24522352 6.57155991 3.24510956 6.61926603 3.24510956
		 6.66697121 3.57057691 6.61926603 3.57057691 6.57155991 3.57057691 6.49808884 3.57237196
		 6.45531368 3.57632947 6.41253853 3.58028817 6.33302927 3.57210445 6.33302927 3.53082085
		 6.41253853 3.54784179 6.41253853 3.61033201 6.41253853 3.69900465 6.41253853 3.50541019
		 5.3449564 3.55765486 5.3449564 3.50184536 5.3449564 3.44744492 5.34495544 3.3673799
		 5.3449564 3.28575182 5.3449564 3.24853945 5.31220818 3.28575182 5.31220818 3.24876595
		 5.34495497 3.209337 5.34495497 3.790663 5.34495497 3.75421405 5.34495497 3.71767569
		 3.54415059 4.2042408 3.59573412 4.19475269 3.68226171 3.91041851 3.6572299 3.92895532
		 3.5 3.80327415 3.5 3.76698112 3.5 3.60988092 3.5 3.67784119 3.5 3.37878537 3.5 3.2496767
		 3.5 3.11688662 3.5 3.021528244 3.5 2.63639331 3.5 2.55449104 3.5 2.45793176 3.5 2.34995556
		 3.5 2.30678153 3.5 2.2636075 3.49807405 1.77217579 3.49807405 1.60554457 3.49807405
		 1.53496528 3.49807405 1.47719824 3.49807405 1.41752696 3.49807405 1.37711263 3.49807405
		 1.32782412 3.5 4.87142801 3.5 4.95446825 3.5 4.75953197 3.5 4.66754723 3.5 4.5537653
		 3.5 4.61065626 3.5 4.47449589 3.5 4.28058147 3.5 4.2404151 3.5 4.20870972 4.36931038
		 2.10657549 4.54741859 2.10657549 4.67059469 2.10657549 4.70338631 2.10657549 4.73617792
		 2.10657549 4.80902958 2.10657549 4.94746304 2.10657549 4.052536964 2.10657549 4.17899466
		 2.10657549 4.22657394 2.17700696 4.22657394 2.10657549 4.32173157 2.10657549 3.87117195
		 3.55291128 3.73687673 3.56505156 3.94974184 3.54149628 3.92762995 4.49639845 6.45626926
		 3.209337 6.5 3.209337 6.57155991 3.209337 6.61926603 3.20933771 6.66697121 3.61033201
		 6.33302879 3.59932375 5.58837318 3.63581491 5.48895359 3.63581491 5.41429043 3.63581491
		 5.31220818 3.55765533 5.34495544 3.63581491 5.31220818 3.63581491 4.57339573 3.57972503
		 4.67496872 3.57972503 4.46446133 3.57972503 4.38310242 3.57972503 4.31751251 3.57972503
		 4.24925947 3.57972503 3.58407092 4.1838665 5.3122077 3.44744492 5.31220818 3.50184584
		 3.80014658 3.97847128 3.74408555 3.97847128 3.70597267 3.97847176 3.67772055 3.97847176
		 6.33302927 3.48242784 6.33302927 3.69900465 5.3122077 3.71767569 3.56456971 4.39522696
		 3.5 4.39522648 4.70332193 2.89103842 4.67059469 2.89103842 4.54741859 2.89103842
		 4.36931038 2.89103842 4.32591867 2.89103842 4.94746304 2.89103842 4.80902958 2.89103842
		 4.73617792 2.89103842 4.25044155 1.60531163 4.25044155 1.5365566 4.68422604 1.60531163
		 3.5 3.42483711 3.58193469 3.42483616 3.58193469 3.50619173 3.5 3.50619268 3.66396308
		 3.50614977 3.66396308 3.4247942 3.58193469 3.5574379 3.5 3.5580368 3.66396308 3.55681872
		 3.87494421 3.65535879 3.80014658 3.69081068 3.5 4.19989586 3.54003286 4.19490862
		 5.3122077 3.3673799 5.3122077 3.209337 5.3122077 3.790663 5.3122077 3.75422525 0.46305203
		 3.90999842 0.44770741 3.95010662 0.42610455 3.90999842 0.42610455 3.88792086 0.54373074
		 3.69900751 0.5 3.69900751 0.5 3.61033416 0.54373074 3.61033416 0.58746147 3.28884792
		 0.58746147 3.32062268 0.52750921 3.32250261;
	setAttr ".uvst[0].uvsp[1000:1249]" 0.51615572 3.27579522 0.3330276 3.53082299
		 0.3330276 3.45131254 0.38073325 3.45131254 0.38073325 3.53082299 0.49422359 3.35288239
		 0.4971118 3.28111005 0.42843938 3.69900751 0.42843938 3.61033416 0.40418291 3.94896507
		 0.38915801 3.90999842 0.42843938 3.35242701 0.42843938 3.28088188 0.50795078 3.45242333
		 0.54571819 3.53961134 0.50397587 3.53137827 0.48530483 3.45210671 0.58746147 3.26647472
		 0.66697264 3.26537538 0.66697264 3.28884792 0.66697264 3.35242748 0.60110879 3.35242701
		 0.66697264 3.3206377 0.38073325 3.69900751 0.38073325 3.61033416 0.38073325 3.35242701
		 0.38073325 3.28088236 0.42843938 3.45131254 0.42843938 3.53082323 0.53694725 3.79915667
		 0.49999976 3.79915667 0.49999976 3.74989343 0.46305323 3.76220894 0.46305203 3.79915667
		 0.53694725 3.84841967 0.57440972 3.91035485 0.53694677 3.90999842 0.49999976 3.90999842
		 0.49999976 3.84841967 0.46305323 3.84841967 0.58746147 3.41950846 0.66697168 3.41466475
		 0.42610455 3.84841967 0.42610455 3.79915667 0.38915825 3.84841967 0.38915825 3.79915667
		 0.61084223 3.79915619 0.61084223 3.84841967 0.61084223 3.90999842 2.68248749 3.41427064
		 2.68248749 3.34410763 2.75074029 3.34337473 2.75074029 3.40192127 2.61689758 3.41426992
		 2.61689758 3.34410763 2.61689758 3.51122355 2.61689758 3.46217918 2.68248749 3.46217918
		 2.68248749 3.51122355 2.75074029 3.46217918 2.75074029 3.51122355 2.53553867 3.51122355
		 2.53553867 3.46217918 2.53553867 3.34410763 2.53553867 3.27326441 2.61689758 3.27326488
		 2.53553867 3.41427064 2.32503176 3.41426992 2.32503128 3.34410763 2.42660427 3.34410763
		 2.42660427 3.41426992 2.32503176 3.27326488 2.42660427 3.27326488 2.42660427 3.24119377
		 2.32503176 3.24119377 2.32503176 3.209337 2.42660427 3.209337 2.68248749 3.27326488
		 2.75074029 3.27326488 2.53553867 3.24119377 2.53553867 3.209337 2.61689758 3.209337
		 2.61689758 3.24126959 2.32503176 3.51122355 2.32503176 3.46217918 2.42660427 3.46217918
		 2.42660427 3.51122355 2.42660427 3.68263221 2.32503176 3.68263221 2.32503128 3.65109348
		 2.42660427 3.65109396 2.42660427 3.71450996 2.32503128 3.71450996 2.53553867 3.68263221
		 2.53553867 3.65109348 2.61689758 3.65109348 2.61689758 3.68274927 2.61689758 3.71450996
		 2.53553867 3.71450996 2.68248749 3.24128485 2.75074029 3.24130058 2.68248749 3.209337
		 2.75074029 3.209337 2.68248749 3.68277621 2.75074029 3.68280268 2.75074029 3.71451139
		 2.68248749 3.71451139 2.68248749 3.65109348 2.75074029 3.65109348 3.26312304 3.021528244
		 3.26312304 3.1169467 3.15643907 3.11690521 3.17283058 3.021528244 3.33603692 3.2496767
		 3.33603692 3.11699748 3.41821885 3.11694217 3.41806531 3.2496767 3.3284812 4.20393085
		 3.43985152 4.2373457 3.43542981 4.28058147 3.32013106 4.27127457 3.2144587 4.95446968
		 3.072369576 4.95446968 3.072369576 4.87128067 3.2144587 4.87190914 3.35654783 4.75953197
		 3.43542981 4.75953197 3.43558693 4.87132502 3.35654783 4.87122202 3.21445823 4.75953197
		 3.26312304 3.2496767 3.33603692 3.37878537 3.26312304 3.37878513 3.33603692 3.021528244
		 3.44816113 3.80624294 3.38479471 3.84165668 3.36463404 3.80246806 3.4333539 3.77179289
		 3.32681227 4.045530319 3.34168005 4.045530319 3.37027168 4.11170483 3.34710789 4.11170483
		 3.072369576 4.75953197 3.072370052 4.66754723 3.2144587 4.66754723 3.35654783 4.66754723
		 3.41806531 3.37878513 3.43542981 4.66754723 3.33603692 3.60748768 3.33603692 3.67419863
		 3.26312304 3.70321846 3.26312304 3.62372351 3.14025617 3.2496767 3.41834903 3.021528244
		 3.43572092 4.95446825 3.35654783 4.95446968 1.3122077 3.55765462 1.3122077 3.50184441
		 1.3619175 3.50184441 1.36191726 3.55765462 1.36191726 3.790663 1.3122077 3.790663
		 1.3122077 3.76911545 1.36191726 3.75416851 1.51104641 3.36738014 1.51104641 3.28575182
		 1.58570933 3.28575182 1.58570933 3.36738014 1.51104641 3.24754405 1.58570933 3.24831319
		 1.3122077 3.38571882 1.3122077 3.28575182 1.36191726 3.28575182 1.36191726 3.36738014
		 1.3122077 3.24754405 1.36191726 3.24754405 1.36191726 3.71767521 1.3122077 3.71767521
		 1.3122077 3.61478472 1.36191726 3.63581467 1.3122077 3.44744468 1.36191726 3.44744468
		 1.51104641 3.55765462 1.51104641 3.50184536 1.58570933 3.50184536 1.58570933 3.55765462
		 1.51104641 3.790663 1.51104641 3.75416851 1.58570981 3.75420403 1.58570981 3.790663
		 1.51104641 3.44744468 1.58570933 3.44744468 1.41162705 3.55765462 1.41162705 3.50184441
		 1.41162705 3.44744468 1.41162705 3.36738014 1.41162705 3.28575182 1.41162705 3.24754405
		 1.41162705 3.790663 1.41162705 3.75416851 2.29661369 2.81225777 2.29661369 2.68747759
		 2.32940531 2.68482089 2.32940531 2.80729723 3.17219949 1.32782412 3.33604836 1.32782412
		 3.33604836 1.37697744 3.17219949 1.4128952 3.33604908 1.60554457 3.41797376 1.60554457
		 3.46232748 1.77217579 3.42427373 1.77217579 3.42985511 2.26360655 3.46540928 2.26360655
		 3.4450767 2.30678082 3.38902855 2.30678082 3.42474413 2.45793176 3.34820175 2.45793176
		 3.34820175 2.34995484 3.42474413 2.34995484 3.41797376 1.32782412 3.41797376 1.37704468
		 3.33604836 1.53496528 3.25823259 1.54210544 3.41797376 1.47719824 3.41797376 1.53496528
		 3.0083508492 1.48994231 3.0083508492 1.42988467 3.17219949 1.4814477 3.34820175 2.63639331
		 3.34820175 2.55247951 3.42474413 2.55348539 3.42474413 2.63639331 3.27165937 2.54985237
		 3.27165937 2.63639331 3.33604836 1.41745996 3.17219949 1.55000067 3.41797376 1.4174943
		 3.0083508492 1.32782388 3.16746402 2.63639331 3.17787004 2.54670715 3.27582026 2.44580317
		 2.79303646 1.60531163 2.90882444 1.60531163 2.90882444 1.69851124 2.79303646 1.69851124
		 2.28376746 1.60531163 2.28376746 1.69851124 2.21975565 1.69851124 2.21975565 1.60531163;
	setAttr ".uvst[0].uvsp[1250:1499]" 2.74955845 1.69851124 2.66260266 1.69851124
		 2.66260266 1.60531163 2.74955845 1.60531163 2.34778023 1.60531163 2.45745015 1.60531163
		 2.45745015 1.69851124 2.34778023 1.69851124 2.091175556 1.60531163 2.091175556 1.69851124
		 2.61912489 1.60531163 2.61912489 1.69851124 2.79303646 1.53655672 2.79303646 1.43968379
		 2.90882444 1.44182372 2.90882444 1.53655672 2.28376746 1.43471575 2.28376746 1.53655672
		 2.21975565 1.53655672 2.21975565 1.4366219 2.28376746 1.20754695 2.28376746 1.2660377
		 2.21975565 1.2660377 2.21975565 1.20754695 2.45745015 1.2660377 2.45745015 1.20754695
		 2.61912489 1.20754695 2.61912489 1.2660377 2.66260266 1.53655672 2.66260266 1.43721759
		 2.74955845 1.43886161 2.74955845 1.53655672 2.34778023 1.53655672 2.34778023 1.43280959
		 2.45745015 1.4334017 2.45745015 1.53655672 2.091175556 1.53655672 2.091175556 1.44182372
		 2.61912489 1.43639588 2.61912489 1.53655672 2.79303646 1.2660377 2.79303646 1.20754695
		 2.90882444 1.20754695 2.90882444 1.2660377 2.66260266 1.2660377 2.66260266 1.20754695
		 2.74955845 1.20754695 2.74955845 1.2660377 2.34778023 1.2660377 2.34778023 1.20754695
		 2.091175556 1.2660377 2.091175556 1.20754695 2.79303646 1.35377359 2.90882444 1.35377359
		 2.28376746 1.35377359 2.21975565 1.35377359 2.66260266 1.35377359 2.74955845 1.35377359
		 2.34778023 1.35377359 2.45745015 1.35377359 2.091175556 1.35377359 2.61912489 1.35377359
		 2.21975565 1.79245305 2.091175556 1.79245305 2.28376746 1.79245305 2.45745015 1.79245305
		 2.34778023 1.79245305 2.61912489 1.79245305 2.66260266 1.79245305 2.74955845 1.79245305
		 2.90882444 1.79245305 2.79303646 1.79245305 2.5061121 0.59991717 2.4731555 0.58472359
		 2.48420811 0.50141323 2.5061121 0.53716969 2.68216491 0.59991717 2.68216562 0.53716969
		 2.70501137 0.51056522 2.71512222 0.59456372 2.46236229 0.47213688 2.44019818 0.56952906
		 2.35223174 0.5783087 2.35223174 0.53716969 2.31801414 0.73403347 2.27336884 0.73403347
		 2.27386379 0.71754265 2.31801414 0.71754265 2.31801414 0.66876364 2.31801414 0.70105052
		 2.27435851 0.70105052 2.27303195 0.6852113 2.83604527 0.65555167 2.74807906 0.65555167
		 2.74807906 0.58920968 2.83604527 0.53716898 2.63815165 0.44236311 2.55012536 0.43810466
		 2.55012536 0.40811658 2.63815165 0.40811658 2.49514675 0.3654716 2.5061121 0.32282662
		 2.50358415 0.3572686 2.50062943 0.40811658 2.41820645 0.33704168 2.44019818 0.294397
		 2.77007103 0.33704168 2.69313049 0.3654716 2.68216491 0.32282662 2.74807954 0.294397
		 2.54880905 0.32282662 2.54710388 0.26596737 2.63513088 0.26596695 2.63683534 0.32282662
		 2.71512222 0.65555167 2.68216562 0.65555167 2.72842765 0.47950828 2.81728268 0.4699885
		 2.5061121 0.65555108 2.4731555 0.65555108 2.44019818 0.65555108 2.35223174 0.65555167
		 2.24310684 0.71754265 2.24211693 0.73403347 2.19476628 0.73403347 2.19476628 0.71754265
		 2.19476533 0.66876364 2.24144292 0.6852113 2.24409628 0.70105052 2.19476533 0.70105052
		 2.68216562 0.26596653 2.5497961 0.35481089 2.63782263 0.3548106 2.18958783 0.28527042
		 2.19476628 0.26596653 2.31801414 0.26596701 2.32319236 0.28527084 2.16395473 0.53811622
		 2.34882593 0.53811622 2.63815212 0.53716969 2.55012536 0.53716969 2.55012536 0.46809274
		 2.63815165 0.47660965 2.75798798 2.68872142 2.77342606 2.52944851 2.82100534 2.52944851
		 2.82100534 2.69400215 2.82100534 2.82444096 2.94746304 2.69636726 2.94746304 2.79516506
		 2.67826796 2.52944851 2.67826796 2.39477539 2.77342606 2.39477539 2.82100534 2.39477539
		 2.94746304 2.39477539 2.94746304 2.52944851 2.45258141 2.80528975 2.45258141 2.68374562
		 2.63068914 2.68352747 2.63068914 2.80488253 2.26382208 2.69013405 2.26382208 2.8172183
		 2.19097066 2.84813166 2.19097066 2.70668983 2.052536964 2.84896016 2.052536964 2.70713353
		 2.82100534 2.29327941 2.82100534 2.17939305 2.94746304 2.17939305 2.94746304 2.29327941
		 2.32940531 2.52944851 2.32940531 2.39477539 2.45258141 2.39477539 2.45258141 2.52944851
		 2.052536964 2.52944851 2.052536964 2.39477539 2.19097066 2.39477539 2.19097066 2.52944851
		 2.63068914 2.39477539 2.63068914 2.52944851 2.26382208 2.39477539 2.26382208 2.52944851
		 2.32940531 2.29327941 2.32940531 2.17939305 2.45258141 2.17939305 2.45258141 2.29327941
		 2.052536964 2.29327941 2.052536964 2.17939305 2.19097066 2.17939305 2.19097066 2.29327941
		 2.63068914 2.17939305 2.63068914 2.29327941 2.26382208 2.17939305 2.26382208 2.29327941
		 2.67826796 2.29327941 2.67826796 2.17939305 2.77342606 2.17939305 2.77342606 2.29327941
		 2.76390266 2.81458092 2.68764782 0.40811658 2.69632959 0.4593409 2.68444014 0.35702246
		 3.41806531 3.6086843 3.41806531 3.67601991 3.19985318 3.80473566 3.29327726 3.77730584
		 3.2725625 3.90300798 3.19985318 3.89035177 3.2144587 4.045531273 3.26732445 4.045530319
		 3.28675032 4.11170483 3.2144587 4.11170483 3.18649316 2.48949385 3.13152266 3.37878513
		 3.042031527 2.5426302 3.042031527 2.48745465 3.042031527 2.63639331 3.050257921 3.021528244
		 3.050257921 3.11688709 3.050257921 3.2496767 3.050257921 3.37878537 3.1299057 3.42488647
		 3.26312304 3.42502427 3.26312304 3.50637984 3.12828898 3.4709878 3.050257921 3.47070956
		 3.050257921 3.42474747 3.2144587 4.61065626 3.072370052 4.61065626 3.072370052 4.5537653
		 3.2144587 4.5537653 3.35654783 4.5537653 3.35654783 4.61065626 3.43542981 4.61065626
		 3.43542981 4.5537653 2.29661369 2.52944851 2.29661369 2.39477539 2.29661369 2.29327941
		 2.29661369 2.17939305 2.31577396 1.79245305 2.31577396 1.69851124 2.31577396 1.53655672
		 2.31577396 1.43376267 2.31577396 1.35377359 2.31577396 1.2660377 2.31577396 1.20754695
		 3.18650389 4.46048546 3.35654783 4.47449589 3.43542981 4.47449589 3.042031527 2.43227983;
	setAttr ".uvst[0].uvsp[1500:1708]" 3.19511628 2.43227983 3.0083508492 1.55000067
		 1.51104641 3.209337 1.58570933 3.209337 1.41162705 3.209337 1.36191726 3.209337 1.3122077
		 3.209337 1.51104641 3.71767521 1.58570981 3.71767521 1.41162705 3.71767521 0.58746147
		 3.20933771 0.66697264 3.209337 0.52994251 3.24256635 0.49855614 3.245224 0.42843938
		 3.24510956 0.38073325 3.24510956 0.3330276 3.57057881 0.38073325 3.57057881 0.42843938
		 3.57057881 0.50191069 3.57237411 0.54468656 3.57633209 0.58746147 3.58029032 0.58746147
		 3.54784393 0.66697168 3.53082299 0.66697168 3.57210636 0.58746147 3.61033416 0.58746147
		 3.69900751 0.58746147 3.50541186 1.65504408 3.50184536 1.65504408 3.55765462 1.65504444
		 3.36738014 1.65504408 3.44744468 1.65504408 3.28575182 1.68779159 3.28575182 1.65504408
		 3.24853921 1.68779159 3.24876595 1.65504479 3.209337 1.65504479 3.75421381 1.65504479
		 3.790663 1.65504479 3.71767521 3.40426588 4.19475269 3.45584917 4.2042408 3.34276962
		 3.92895532 3.31773829 3.91041851 2.45258141 2.10896158 2.63068914 2.10896158 2.32940531
		 2.10896158 2.29661369 2.10896158 2.26382208 2.10896158 2.19097066 2.10896158 2.052536964
		 2.10896158 2.82100534 2.10896158 2.94746304 2.10896158 2.77342606 2.10896158 3.26312304
		 3.56505156 3.12882805 3.55291128 3.050257921 3.54149628 3.072370052 4.49639845 0.54373074
		 3.209337 0.5 3.209337 0.42843938 3.209337 0.38073325 3.20933771 0.3330276 3.61033416
		 0.66697264 3.59932613 1.41162705 3.63581467 1.51104641 3.63581467 1.58570933 3.63581467
		 1.65504444 3.63581467 1.68779159 3.55765486 1.68779194 3.63581467 2.42660427 3.57972479
		 2.32503152 3.57972479 2.53553867 3.57972479 2.61689758 3.57972479 2.68248749 3.57972479
		 2.75074029 3.57972479 3.2144587 4.20862341 3.41592884 4.1838665 1.6877923 3.44744468
		 1.68779159 3.50184584 3.25591421 3.97847128 3.19985318 3.97847128 3.29402709 3.97847176
		 3.32227945 3.97847176 0.66697168 3.4824295 0.66697168 3.69900751 1.6877923 3.71767521
		 3.43542981 4.39522696 3.35654783 4.39522648 2.29690981 2.89342451 2.32940531 2.89342451
		 2.45258141 2.89342451 2.63068914 2.89342451 2.82100534 2.89342451 2.67408085 2.89342451
		 2.66874456 2.80480146 2.88423419 2.86138034 2.052536964 2.89342451 2.19097066 2.89342451
		 2.26382208 2.89342451 2.31577396 1.60531163 3.41806531 3.42483616 3.41806531 3.50619173
		 3.33603692 3.50614977 3.33603692 3.4247942 3.41806531 3.5574379 3.33603692 3.55681872
		 3.19985318 3.69081068 3.4599669 4.19490862 1.6877923 3.36738014 1.6877923 3.209337
		 1.6877923 3.75422525 1.6877923 3.790663 4.75074005 3.41426992 4.75074005 3.46217942
		 4.75074005 3.51122379 4.75074005 3.57972503 4.75074053 3.65109348 4.75074005 3.68263221
		 4.75074053 3.71451044 4.75074005 3.209337 4.75074005 3.24119377 4.75074005 3.27326488
		 4.75074053 3.34410763 2.24925971 3.34410763 2.24926019 3.27326488 2.24926019 3.24119377
		 2.24926019 3.209337 2.24925971 3.71450996 2.24926019 3.68263221 2.24925971 3.65109348
		 2.24925995 3.57972479 2.24926019 3.51122355 2.24926019 3.46217918 2.24926019 3.41426992
		 2.71077919 0.42248994 3.2144587 4.31880379 4.11576557 2.85899425 4.052536964 2.82695007
		 4.22657394 2.3923893 4.22657394 2.29089332 4.25044155 1.69851124 4.25044155 1.79245305
		 4.25044155 1.43886161 4.25044155 1.35377359 4.25044155 1.2660377 4.25044155 1.20754695
		 4.55012512 0.47661036 4.55012512 0.53717065 4.49194765 0.45934153 4.55012512 0.44236371
		 4.50062943 0.40811706 4.50383663 0.35702288 4.55045414 0.35481098 4.55012512 0.40811706
		 4.55144167 0.32282698 4.5061121 0.32282698 4.50611162 0.26596665 4.55314636 0.26596719
		 4.17899466 2.89103842 3.26492286 2.39473987 2.66282988 2.68348408 2.67826796 2.10896158
		 2.49241877 0.4547649 2.5061121 0.26596737 2.16395473 0.49411118 2.34882593 0.46295035
		 4.16395378 0.38082969 4.34882593 0.38082969 2.33342004 0.32339835 2.17935991 0.32339811
		 4.77007151 0.33704185 4.69313049 0.36547202 4.74807978 0.294397 4.3334198 0.32339811
		 4.17935944 0.32339835 4.49514675 0.36547202 4.41820574 0.33704185 4.44019699 0.294397
		 2.47875452 0.41880423 2.39621472 0.37968636 2.34882593 0.38082969 2.16395378 0.38082969
		 2.79206228 0.37968636 2.94746304 2.82933617 3.12505555 3.65535879 3.14341426 4.35245752
		 3.92762995 4.38611317 3.94974184 3.61990738 3.050257921 3.61990738 3.072370052 4.38611317
		 3.5 3.83956718 3.53703165 3.840693 3.46296811 3.840693 3.40495515 3.88084507 3.36780119
		 3.94749212 3.35053158 3.97847176 3.35654783 4.045530319 3.39343548 4.11170483 3.42759204
		 4.17298031 3.46408463 4.18557644 3.5 4.191082 3.53591514 4.18557644 3.57240772 4.17298031
		 3.60656404 4.11170483 3.64345217 4.045530319 3.63219833 3.94749212 3.64946842 3.97847176
		 3.59504485 3.88084507;
	setAttr ".cuvs" -type "string" "map1";
	setAttr ".dcol" yes;
	setAttr ".dcc" -type "string" "Ambient+Diffuse";
	setAttr -s 3 ".clst";
	setAttr ".clst[0].clsn" -type "string" "colorSet1";
	setAttr -s 3457 ".clst[0].clsp";
	setAttr ".clst[0].clsp[0:124]"  0.2349 0.62519997 0.2349 1 0.2349 0.62519997
		 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997
		 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997
		 0.2349 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354 0.1338
		 0.354 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354 0.1338
		 0.354 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997 0.2349
		 1 0.2349 0.62519997 0.2349 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.2349 0.62519997
		 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997
		 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997
		 0.2349 1 0.2349 0.62519997 0.2349 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354
		 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354 0.1338 0.354 1 0.354
		 0.1338 0.354 1 0.354 0.1338 0.354 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997
		 0.2349 1 0.2349 0.62519997 0.2349 1 0.2349 0.62519997 0.2349 1 0.354 0.1338 0.354
		 1 0.354 0.1338 0.354 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709
		 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659
		 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659
		 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1;
	setAttr ".clst[0].clsp[125:249]" 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055
		 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.61930001 0.50410002
		 0 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.61930001
		 0.50410002 0 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002
		 0 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1;
	setAttr ".clst[0].clsp[250:374]" 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055
		 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380002 0.083100006
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999
		 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999
		 1.00010001659 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380002 0.083100006 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002
		 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002 0.029100001
		 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.47090003 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999
		 1 0.47090003 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1;
	setAttr ".clst[0].clsp[375:499]" 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055
		 0.060200002 0.029100001 1 0.4709 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002
		 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380002 0.083100006 1 0.4709 0.17380002 0.083100006
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380002
		 0.083100006 1 0.4709 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1.000050067902 0.4709 0.17380001 0.083099999 1.00010001659
		 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001
		 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055
		 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1;
	setAttr ".clst[0].clsp[500:624]" 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1.00010001659
		 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659
		 0.4709 0.17380001 0.083099999 1.00010001659 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1;
	setAttr ".clst[0].clsp[625:749]" 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.61930001 0.50410002 0
		 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.61930001
		 0.50410002 0 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002
		 0 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1;
	setAttr ".clst[0].clsp[750:874]" 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380002 0.083100006 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1.00010001659 0.4709
		 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659
		 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380002
		 0.083100006 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055
		 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002
		 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.47090003 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.47090003
		 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002
		 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.4709 0.17380002 0.083100006 1 0.4709
		 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380002 0.083100006 1 0.4709
		 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1;
	setAttr ".clst[0].clsp[875:999]" 0.4709 0.17380002 0.083100006 1 0.4709 0.17380002
		 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380002 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380002
		 0.083100006 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1.000050067902 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999
		 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.4709
		 0.17380001 0.083099999 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060200002 0.029100001
		 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060200002 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001
		 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998
		 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055 0.060199998 0.029100001 1 0.1055
		 0.060199998 0.029100001 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1;
	setAttr ".clst[0].clsp[1000:1124]" 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.61930001 0.50410002
		 0 1 0.4709 0.17380001 0.083099999 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.61930001 0.50410002 0 1 0.61930001 0.50410002 0 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1;
	setAttr ".clst[0].clsp[1125:1249]" 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001
		 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1.00010001659 0.4709
		 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.000075101852
		 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1.00010001659
		 0.4709 0.17380001 0.083099999 1.000075101852 0.4709 0.17380001 0.083099999 1.00010001659
		 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1 0.4709
		 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1.00010001659 0.4709 0.17380001
		 0.083099999 1.00010001659 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999
		 1 0.4709 0.17380001 0.083099999 1 0.4709 0.17380001 0.083099999 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.36999997 0.072300002 0 1 0.4057 0.063199997 0 1 0.37 0.072300002
		 0 1 0.36999997 0.072300002 0 1 0.37 0.072300002 0 1 0.4057 0.063199997 0 1 0 0.62900001
		 0.43909997 1 0 0.62899989 0.43909994 1 0 0.62899989 0.43909994 1 0 0.62899995 0.43909997
		 1 0 0.62899995 0.43909997 1 0 0.62900001 0.4391 1 0.35509998 0.1418 0 1 0.36999997
		 0.072300002 0 1 0.4057 0.063199997 0 1 0 0.62899995 0.43909994 1 0.36999997 0.072300002
		 0 1 0.35509998 0.1418 0 1 0.493 0.34740001 0.087299995 1 0.49299991 0.34739995 0.087299995
		 1 0.49299997 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299991 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493
		 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299991 0.34740001 0.087299995
		 1 0.49299997 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34740001
		 0.087299995 1 0.49299997 0.34740001 0.08730001 1 0.49299991 0.34740001 0.087299995
		 1 0.49299994 0.34739998 0.087299995 1 0.49299997 0.34739995 0.087299995 1 0.49299997
		 0.34739998 0.087299995 1 0.49299997 0.34739998 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299997
		 0.34739998 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34739998 0.087299995
		 1 0.49299997 0.34740001 0.087299995 1 0.49299997 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.49299997 0.34740001 0.087299995 1 0.49299991 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779997 1 0.62899995
		 0 0.51779997 1 0.62900001 0 0.51779997 1 0.62900001 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62900001 0 0.51779991 1 0.66189998 0 0.5546 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62900001 0 0.51779991 1 0.62899995 0 0.51779991 1;
	setAttr ".clst[0].clsp[1250:1374]" 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62900001 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899989
		 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62900007 0 0.51779997
		 1 0.62900001 0 0.51779997 1 0.62900001 0 0.51779991 1 0.62899989 0 0.51779991 1 0.62900007
		 0 0.51779991 1 0.62900001 0 0.51779997 1 0.35509995 0.14180002 0 1 0.62900001 0 0.51779997
		 1 0.62900001 0 0.51779991 1 0.35510004 0.14180002 0 1 0.35510001 0.14180002 0 1 0.37
		 0.072300002 0 1 0.37 0.072300002 0 1 0.27200001 0.10860001 0 1 0.31996116 0.090834804
		 0 1 0.4057 0.063199997 0 1 0.37 0.072300002 0 1 0.28086761 0.10531535 0 1 0.3352192
		 0.085183091 0 1 0.4057 0.063199997 0 1 0.35509998 0.1418 0 1 0.36999997 0.072300002
		 0 1 0.37 0.072300002 0 1 0.36810952 0.081117868 0 1 0.28561312 0.10355758 0 1 0.4057
		 0.063199997 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.34594405 0.081210524
		 0 1 0.33001676 0.087110117 0 1 0.36999997 0.072300002 0 1 0.27200001 0.1086 0 1 0.4057
		 0.063199997 0 1 0.62899995 0 0.14709999 1 0.62900001 0 0.14709999 1 0.62899995 0
		 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999
		 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62900001 0 0.1471
		 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62899995 0
		 0.1471 1 0.051800001 0.37 0 1 0 0.62900001 0.43909997 1 0 0.62900007 0.4391 1 0 0.62900001
		 0.4391 1 0 0.62900001 0.43909997 1 0 0.62900001 0.4391 1 0.051800001 0.36999997 0
		 1 0.051799998 0.36999995 0 1 0 0.62899995 0.43909994 1 0.051800001 0.37 0 1 0 0.62899995
		 0.4391 1 0 0.62900007 0.4391 1 0 0.62900007 0.43909997 1 0 0.62899995 0.43909997
		 1 0.36999997 0 0.11379998 1 0.36999995 0 0.1138 1 0.37 0 0.11379999 1 0 0.2462 0.37
		 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0 0.2462 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24620001
		 0.37000003 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.37000003 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462
		 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24620003
		 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24620001 0.37 1 0 0.2462 0.37000003 1
		 0.051799998 0.36999997 0 1 0.051800001 0.36999997 0 1 0.36999997 0 0.11379999 1 0.36999997
		 0 0.1138 1 0.36999997 0 0.11379998 1 0.36999997 0 0.1138 1 0.36999997 0 0.11379998
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997
		 0 0.1138 1 0.36999997 0 0.11379999 1 0.36999997 0 0.11379998 1 0.37 0 0.11379999
		 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1;
	setAttr ".clst[0].clsp[1375:1499]" 0.36999997 0 0.1138 1 0.36999997 0 0.1138
		 1 0.36999997 0 0.11379998 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997
		 0 0.11379998 1 0.37 0 0.11379999 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.051799994 0.36999997
		 0 1 0.051799998 0.37000003 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997
		 0 1 0.051799994 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999995
		 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799994 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.35510001 0.14180002 0 1 0.36841232 0.079705715 0
		 1 0.37 0.072300002 0 1 0 0.62899995 0.43909994 1 0 0.62899989 0.43909994 1 0.37 0.072300002
		 0 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002 0 1 0 0.62899995 0.43909997
		 1 0.37 0.072300002 0 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002 0 1 0.37
		 0.072300002 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002
		 0 1 0.27200001 0.10859999 0 1 0.4057 0.063199997 0 1 0.051800001 0.36999997 0 1 0.051800001
		 0.36999997 0 1 0 0.2462 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0.27200001 0.10859999 0 1 0.62899995
		 0 0.51779991 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1
		 0.66189998 0 0.5546 1 0 0.62900007 0.43909997 1 0 0.62899995 0.43909994 1 0 0.62899995
		 0.43909997 1 0 0.62899995 0.43909994 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62900001 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.14709999
		 1 0.62899995 0 0.14709999 1 0.62900001 0 0.1471 1 0.493 0.34740001 0.087299995 1
		 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62900001 0 0.1471 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34739995 0.087299995 1 0.493
		 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.49299991 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493
		 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999
		 1 0.62899995 0 0.14709999 1 0.36999997 0.072300002 0 1 0.37 0.072300002 0 1 0.35509998
		 0.1418 0 1 0.35510004 0.14180002 0 1 0.37 0.072300002 0 1 0.36999997 0.072300002
		 0 1 0.36999997 0.072300002 0 1 0.37 0.072300002 0 1 0 0.62899989 0.43909997 1 0 0.62899995
		 0.43909997 1 0 0.62899995 0.43909997 1 0 0.62900001 0.4391 1 0 0.62900007 0.43909997
		 1 0 0.66189998 0.47639999 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1 0
		 0.62900007 0.4391 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002 0 1
		 0.051799998 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799994 0.36999997 0 1
		 0.051799998 0.36999997 0 1;
	setAttr ".clst[0].clsp[1500:1624]" 0.051799994 0.36999995 0 1 0.051799994 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.35510004 0.14180002 0 1 0.35509998 0.14180002 0
		 1 0.35510001 0.1418 0 1 0.49299991 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087300003 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493
		 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.62900001 0 0.1471 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.62900001 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62900007 0 0.51779991 1 0.62900001 0 0.51779997 1 0.36999997
		 0.072300002 0 1 0.36999997 0.072300002 0 1 0.493 0.34740001 0.087299995 1 0.62900001
		 0 0.1471 1 0.62899995 0 0.14709999 1 0.62900007 0 0.14709999 1 0.62899995 0 0.14709999
		 1 0.62900001 0 0.51779991 1 0.62899989 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62900007
		 0 0.51779991 1 0.66189998 0 0.5546 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0
		 1 0.62900001 0 0.51779997 1 0.37 0.072300002 0 1 0.36999997 0.072300002 0 1 0.37
		 0 0.1138 1 0.36999995 0 0.11379998 1 0.36999997 0 0.1138 1 0.36999997 0 0.11379998
		 1 0.36999995 0 0.1138 1 0.36999997 0 0.1138 1 0.051799998 0.36999997 0 1 0.051799994
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051799998
		 0.37000003 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051800001
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799994
		 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994
		 0.36999997 0 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.37000003 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0.35510004 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510004
		 0.14180002 0 1 0.4057 0.063199997 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37
		 0.072300002 0 1 0.37 0.072300002 0 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14710002
		 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.66189998 0
		 0.1586 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.49299997 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1
		 0 0.66189998 0.47639999 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299991
		 0.34740001 0.087299995 1 0.49299991 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34739998 0.087299995 1
		 0.49299997 0.34739998 0.087299995 1 0.49299991 0.34740001 0.087299995 1 0.49299997
		 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299991 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493
		 0.34739995 0.087299995 1 0.493 0.34739995 0.087300003 1 0.493 0.34740001 0.087299995
		 1 0.49299991 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.49299997 0.34739998 0.087299995 1 0.493 0.34739998 0.087299995 1
		 0.493 0.34740001 0.087299995 1;
	setAttr ".clst[0].clsp[1625:1749]" 0.49299991 0.34740001 0.087299995 1 0.49299997
		 0.34739998 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34739998 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299997
		 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.66189998 0 0.5546 1 0.4057 0.063199997 0 1 0.35510004 0.14180002 0 1 0.62899995
		 0 0.51779991 1 0.62900007 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779997 1 0.62900001
		 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779991
		 1 0.62900007 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62900001 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779991 1 0.35510004 0.14180002 0 1 0.66189998
		 0 0.5546 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779997 1 0.62900001 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62900001
		 0 0.51779997 1 0.62900001 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62900001 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62900001
		 0 0.51779997 1 0.62900001 0 0.51779991 1 0.62899989 0 0.51779991 1 0.62899989 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.66189998 0 0.5546 1 0.35510001
		 0.14180002 0 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.62899995 0 0.51779991
		 1 0.62900001 0 0.51779991 1 0.36841232 0.079705715 0 1 0.36999997 0.072300002 0 1
		 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002
		 0 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002
		 0 1 0.36999997 0.072300002 0 1 0.37396252 0.073924996 0 1 0.35510004 0.14180002 0
		 1 0.35510004 0.14180002 0 1 0.35510001 0.14180002 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002 0 1 0.27200001 0.1086 0 1 0.27200001
		 0.1086 0 1 0.33001676 0.087110125 0 1 0.31996113 0.090834804 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.28086761
		 0.10531535 0 1 0.36999997 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0
		 1 0.37 0.072300002 0 1 0.37 0.072300009 0 1 0.37 0.072300002 0 1 0.35509995 0.1418
		 0 1 0.36810952 0.081117868 0 1 0.36999997 0.072300002 0 1 0.37 0.072300002 0 1 0.37
		 0.072300002 0 1 0.3352192 0.085183091 0 1 0.28561312 0.10355757 0 1 0.34594408 0.081210524
		 0 1 0.37 0.072300002 0 1 0.35510004 0.14180002 0 1 0.35510001 0.14180002 0 1 0.35510004
		 0.14180002 0 1 0.35510004 0.14180002 0 1 0.36999997 0.072300002 0 1 0.37 0.072300002
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.493 0.34740001 0.087299995 1 0.62900001 0 0.1471 1 0.62900001 0
		 0.1471 1 0.493 0.34740001 0.087299995 1;
	setAttr ".clst[0].clsp[1750:1874]" 0.62900001 0 0.1471 1 0.62900001 0 0.1471
		 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62900001 0 0.1471
		 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.49299997 0.34740001 0.087299995 1
		 0.49299991 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.62900001 0 0.1471
		 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999
		 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999
		 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.62899995 0 0.14709999 1 0.62899995 0 0.1471 1 0.051799998 0.36999997
		 0 1 0.051799994 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051800001 0.36999997
		 0 1 0 0.62899989 0.43909997 1 0 0.62900007 0.4391 1 0 0.62900001 0.43909997 1 0 0.62900001
		 0.4391 1 0 0.62899995 0.43909997 1 0 0.62900001 0.43909994 1 0 0.62900001 0.43909997
		 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1 0
		 0.62900001 0.43909997 1 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1 0.051800005
		 0.37 0 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1 0 0.62899989 0.43909997
		 1 0 0.62899989 0.43909997 1 0 0.62899995 0.4391 1 0 0.62899995 0.43909997 1 0 0.62899995
		 0.43909997 1 0.051800001 0.37 0 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997
		 1 0 0.62899995 0.43909997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462
		 0.37 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0.37 0 0.1138 1 0.36999997 0 0.11379998
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462
		 0.37 1 0 0.2462 0.37 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0 0.2462 0.37 1 0.37
		 0 0.1138 1 0 0.24620001 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.37000003
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0.37 0 0.1138 1 0.37000003 0 0.11379998 1 0.36999997 0 0.1138
		 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.11379999 1 0.36999997 0 0.1138
		 1 0.36999997 0 0.11379998 1 0.36999997 0 0.1138 1 0.36999997 0 0.11379998 1 0.37000003
		 0 0.1138 1 0.36999997 0 0.11379998 1 0.36999997 0 0.1138 1 0.36999997 0 0.11379998
		 1 0.37000003 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0
		 0.11379998 1 0.37 0 0.11379999 1 0.37 0 0.11379999 1 0.36999997 0 0.1138 1 0.37 0
		 0.1138 1;
	setAttr ".clst[0].clsp[1875:1999]" 0.36999997 0 0.1138 1 0.36999997 0 0.1138
		 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997
		 0 0.1138 1 0.36999997 0 0.1138 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051799994 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051800001 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999997
		 0 1 0.051799994 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799994 0.36999995 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051799998 0.37000003
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799994 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799994 0.36999997
		 0 1 0.051799994 0.36999995 0 1 0.051799994 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799994 0.37000003 0 1 0.051799998 0.36999997
		 0 1 0.35510007 0.14180002 0 1 0.35510004 0.14180002 0 1 0 0.62899995 0.43909997 1
		 0.37 0.072300002 0 1 0.35509998 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510001 0.1418
		 0 1 0.27200001 0.10859999 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0 0.62900007 0.4391 1 0 0.62900001 0.43910003 1 0 0.62899995 0.4391
		 1 0.62899995 0 0.14709999 1 0.62900007 0 0.14709999 1 0.62899995 0 0.14709999 1 0.49299997
		 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.493
		 0.34740001 0.087299995 1 0.49299994 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995
		 1 0.49299997 0.34740001 0.087299995 1 0.62899995 0 0.14709999 1 0.62899995 0 0.14709999
		 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.66189998 0
		 0.1586 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62899995 0 0.14709999 1 0.62899995
		 0 0.14709999 1 0.36999997 0.072300002 0 1 0.36999997 0.072300002 0 1 0.4057 0.063199997
		 0 1 0.35509998 0.1418 0 1 0.35510004 0.1418 0 1 0.36999997 0.072300002 0 1 0 0.62899989
		 0.43909994 1 0 0.62899995 0.43909997 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37000003
		 1 0 0.2462 0.37 1 0.051800001 0.36999997 0 1 0.051799998 0.36999997 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.62900001 0 0.51779991 1 0.62900001 0 0.51779997 1 0.62900001
		 0 0.51779991 1 0.62900001 0 0.51779997 1 0.4425 0.0506 0 1 0.37 0.072300002 0 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.62900001 0 0.1471 1 0.62900007 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900007
		 0 0.1471 1 0 0.62900001 0.43909997 1 0 0.62900001 0.4391 1 0 0.62900001 0.4391 1;
	setAttr ".clst[0].clsp[2000:2124]" 0 0.62900001 0.43910003 1 0 0.62900001 0.4391
		 1 0 0.62900001 0.4391 1 0.051800001 0.37 0 1 0 0.62900001 0.43909994 1 0 0.62900007
		 0.4391 1 0 0.2462 0.37 1 0.37 0 0.1138 1 0 0.2462 0.37000003 1 0 0.2462 0.37 1 0
		 0.24619998 0.37 1 0 0.2462 0.37 1 0 0.24620001 0.37 1 0.37000003 0 0.1138 1 0.37
		 0.072300002 0 1 0.37 0.072300002 0 1 0.35510001 0.1418 0 1 0.35510001 0.1418 0 1
		 0.27200001 0.1086 0 1 0.27200001 0.1086 0 1 0 0.2462 0.37 1 0.27200001 0.10860001
		 0 1 0.62900001 0 0.51779997 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0 0.62900007 0.43910003 1 0 0.65093333 0.46396664 1 0.62900007 0 0.1471
		 1 0.66189998 0 0.1586 1 0.62900007 0 0.1471 1 0 0.62900001 0.4391 1 0 0.62900001
		 0.43910003 1 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.051799998 0.37 0 1 0.051800001
		 0.37 0 1 0.051799998 0.37 0 1 0.051799998 0.37 0 1 0.051800001 0.37 0 1 0.66189998
		 0 0.1586 1 0.66189998 0 0.1586 1 0.62900001 0 0.1471 1 0.62899995 0 0.1471 1 0.62899995
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.51779997 1
		 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.62899995 0
		 0.1471 1 0.051800001 0.36999997 0 1 0.051800001 0.37 0 1 0.051800005 0.37 0 1 0.051800005
		 0.37 0 1 0.35510001 0.1418 0 1 0.35509998 0.14179999 0 1 0.35510001 0.14179999 0
		 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0
		 0.1586 1 0.62900001 0 0.51779997 1 0.62900001 0 0.51779991 1 0.66189998 0 0.5546
		 1 0.66189998 0 0.5546 1 0.62900001 0 0.51779997 1 0.62900001 0 0.51779991 1 0.37
		 0.072300002 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.62900001 0 0.1471 1 0.62900007 0 0.1471 1 0.62900007
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62899995 0 0.14709999 1 0.62900001 0 0.1471 1
		 0.62900007 0 0.1471 1 0.62900001 0 0.14710002 1 0 0.62900001 0.43909997 1 0 0.62900001
		 0.4391 1 0 0.62900001 0.43909997 1 0 0.62900007 0.4391 1 0 0.62900001 0.4391 1 0
		 0.62900001 0.43910003 1 0.051800001 0.37 0 1 0 0.62900001 0.43909997 1 0 0.62900007
		 0.4391 1 0.37 0 0.1138 1 0 0.2462 0.37 1 0 0.24619998 0.37 1 0 0.2462 0.37 1 0 0.2462
		 0.37 1 0 0.24620001 0.37000003 1 0 0.24620001 0.36999997 1 0.37 0 0.1138 1 0.4057
		 0.063199997 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.35510001 0.1418 0 1 0.35510001
		 0.14180002 0 1 0.35510001 0.1418 0 1 0.27200001 0.1086 0 1 0 0.2462 0.37 1 0.27200001
		 0.10860001 0 1 0.62900001 0 0.51779997 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546
		 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0
		 0.5546 1 0.66189998 0 0.5546 1 0 0.62900001 0.4391 1 0 0.62900001 0.43909997 1;
	setAttr ".clst[0].clsp[2125:2249]" 0.62900001 0 0.1471 1 0.66189998 0 0.1586
		 1 0.62900007 0 0.1471 1 0 0.62900001 0.4391 1 0 0.66189998 0.47639999 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.051800005 0.37000003 0 1 0.051800001
		 0.37 0 1 0.051800001 0.37 0 1 0.051800001 0.37000003 0 1 0.051800001 0.37 0 1 0.66189998
		 0 0.1586 1 0.66189998 0 0.1586 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.14710002 1 0.62900001 0 0.51779997
		 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.62900001
		 0 0.1471 1 0.4057 0.063199997 0 1 0.051800005 0.37 0 1 0.051800005 0.37 0 1 0.051800005
		 0.37000003 0 1 0.051799998 0.37000003 0 1 0.35510004 0.14180002 0 1 0.35510001 0.1418
		 0 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.1586 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779997
		 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995
		 0 0.51779997 1 0.62900007 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62900001 0 0.51779997 1 0.62899995 0 0.51779997
		 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62900007
		 0 0.51779997 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62900001 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997
		 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995
		 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779991 1 0.62899995 0 0.51779997 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997 1 0.62899995 0 0.51779997
		 1 0.62899995 0 0.51779997 1 0.62900001 0 0.51779997 1 0.62900001 0 0.51779997 1 0.62899995
		 0 0.51779991 1 0.62899995 0 0.51779997 1 0.62900001 0 0.51779991 1 0.62899995 0 0.51779991
		 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0 0.66189998 0.47639999 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1;
	setAttr ".clst[0].clsp[2250:2374]" 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0.4057 0.063199997 0 1 0.66189998 0 0.5546 1 0.4057 0.063199997 0 1 0.66189998
		 0 0.5546 1 0.4057 0.063199997 0 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1
		 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0 0.66189998 0.47639999 1 0.4057 0.063199997 0 1 0 0.66189998 0.47639999
		 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.66189998 0 0.1586 1 0.66189998 0 0.5546 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.5546 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.1586 1 0.66189998 0 0.1586 1 0 0.66189998 0.47639999 1 0.66189998 0 0.5546 1
		 0.66189998 0 0.5546 1 0.4057 0.063199997 0 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546
		 1 0.4057 0.063199997 0 1 0.66189998 0 0.5546 1 0.66189998 0 0.1586 1 0.66189998 0
		 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998 0 0.5546 1 0.66189998
		 0 0.5546 1;
	setAttr ".clst[0].clsp[2375:2499]" 0.66189998 0 0.5546 1 0.4057 0.063199997 0
		 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1
		 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998
		 0 0.1586 1 0.66189998 0 0.1586 1 0.66189998 0 0.1586 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1 0 0.66189998 0.47639999 1 0.4057 0.063199997
		 0 1 0 0.66189998 0.47639999 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0
		 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462
		 0.37 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0 0.2462
		 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37
		 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1
		 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0
		 0.2462 0.37 1;
	setAttr ".clst[0].clsp[2500:2624]" 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37
		 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1
		 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0
		 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0.62900001 0 0.1471
		 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0
		 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001
		 0 0.1471 1 0.62900001 0 0.1471 1 0.62900001 0 0.1471 1 0.35510004 0.14180002 0 1
		 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.27200001 0.1086 0 1 0.27880657
		 0.10607879 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0
		 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.27880657 0.10607878 0 1 0.4057 0.063199997 0 1 0.35510001 0.1418 0 1 0.27200001
		 0.1086 0 1 0.35509998 0.14180002 0 1 0.35509998 0.14180002 0 1 0.35510004 0.14180002
		 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1
		 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35509998 0.14179999 0 1 0.35509998
		 0.14179999 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35509998 0.1418
		 0 1 0.35509998 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004
		 0.14180002 0 1 0.35510004 0.14180002 0 1 0.28561312 0.10355758 0 1 0.27880657 0.10607879
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.28561312 0.10355757 0 1 0.27200001 0.1086 0 1 0.35509998 0.14180002 0 1 0.35510001
		 0.1418 0 1 0.35510001 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510001 0.1418 0 1
		 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004
		 0.14180002 0 1 0.35509998 0.14179999 0 1 0.35510001 0.1418 0 1 0.35510004 0.14180002
		 0 1 0.35509998 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510001 0.14179999 0 1 0.35510001
		 0.1418 0 1 0.35510001 0.1418 0 1 0.35510001 0.1418 0 1 0.37 0 0.1138 1 0.37 0 0.11379999
		 1 0.37 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.1138 1;
	setAttr ".clst[0].clsp[2625:2749]" 0.37 0 0.11379999 1 0.36999997 0 0.1138 1
		 0.36999997 0 0.1138 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462
		 0.37 1 0 0.2462 0.37 1 0 0.2462 0.36999997 1 0 0.2462 0.36999997 1 0 0.2462 0.37
		 1 0 0.2462 0.37 1 0 0.24619998 0.37 1 0 0.24619998 0.37 1 0 0.2462 0.36999997 1 0
		 0.2462 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462
		 0.37 1 0 0.24619998 0.36999997 1 0 0.2462 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37
		 1 0 0.24619998 0.37 1 0 0.2462 0.37 1 0 0.2462 0.36999997 1 0 0.24619998 0.37 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.36999997 1 0 0.2462
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37
		 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.2462
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1
		 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462
		 0.36999997 1 0 0.2462 0.37 1 0.37 0.072299995 0 1 0.37 0.072300002 0 1 0.36999997
		 0.072300002 0 1 0.49299997 0.34740001 0.087299995 1 0.49299997 0.34740001 0.087299995
		 1 0.493 0.34740001 0.087299995 1 0.493 0.34740001 0.087299995 1 0.49299997 0.34739998
		 0.087299995 1 0 0.62899995 0.43909997 1 0 0.62900001 0.43909997 1 0.051799998 0.37
		 0 1 0.051799998 0.37 0 1 0.051799994 0.36999995 0 1 0.051799994 0.36999995 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999995 0 1 0.051799994
		 0.36999995 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0 0.2462 0.37 1 0.051799998 0.36999997
		 0 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462
		 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138
		 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997
		 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.051799998 0.37000003
		 0 1 0.051799994 0.36999995 0 1 0.051799998 0.37 0 1 0.051799998 0.36999997 0 1 0.051799994
		 0.36999995 0 1 0.051799994 0.36999995 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799994 0.36999995 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0 0.2462 0.37
		 1 0 0.2462 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.24619998 0.36999997
		 1 0 0.2462 0.37 1;
	setAttr ".clst[0].clsp[2750:2874]" 0 0.2462 0.37 1 0.37 0 0.1138 1 0.37 0 0.1138
		 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.36999997
		 0 0.1138 1 0.37 0 0.1138 1 0 0.62900001 0.43909997 1 0.051800005 0.37 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799994
		 0.36999997 0 1 0.051799998 0.37 0 1 0.051799998 0.37 0 1 0.051799998 0.36999995 0
		 1 0.051799998 0.36999995 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0
		 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0 0.2462 0.37 1 0.051799998
		 0.36999997 0 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.2462 0.36999997 1 0 0.2462 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0.36999995 0 0.1138 1 0.37 0 0.1138
		 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.11379999 1
		 0.37 0 0.11379999 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37
		 0 0.1138 1 0.051799998 0.36999997 0 1 0.051800005 0.37 0 1 0.051799994 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.37 0 1 0.051799998 0.36999995 0 1 0.051799998
		 0.37 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999995 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.2462 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.2462 0.37
		 1 0 0.2462 0.37 1 0.36999997 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.1138 1 0.493
		 0.34740001 0.087299995 1 0.49299997 0.34740001 0.087299995 1 0.49299997 0.34740001
		 0.087299995 1 0.493 0.34740001 0.087299995 1 0 0.62899995 0.43909997 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0 0.2462 0.37
		 1 0.051799998 0.36999997 0 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0.37 0 0.1138 1 0.37
		 0 0.11379999 1 0.37 0 0.11379999 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.37
		 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138
		 1 0.37 0 0.1138 1 0 0.62900001 0.43909997 1 0.051799998 0.36999997 0 1 0.051800005
		 0.37 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1;
	setAttr ".clst[0].clsp[2875:2999]" 0.051799998 0.36999997 0 1 0 0.24619998 0.36999997
		 1 0 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0.37 0 0.11379999 1 0.37 0 0.1138 1
		 0.36999997 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997
		 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0 0.62900007 0.43909997 1 0.051800005
		 0.37 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999997
		 0 1 0.051799994 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0 0.2462 0.37 1 0.051799998 0.36999997 0 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0.37
		 0 0.1138 1 0.37 0 0.11379999 1 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999
		 1 0.37 0 0.11379999 1 0.37 0 0.11379999 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0 0.62900007 0.43909997 1 0 0.62899995 0.43909997
		 1 0.051800005 0.37 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799994 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051800001 0.36999997 0 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37 1
		 0 0.2462 0.37 1 0.37 0 0.11379999 1 0.37 0 0.1138 1 0.36999997 0 0.11379999 1 0.37
		 0 0.11379999 1 0.37 0 0.11379999 1 0.36999997 0 0.11379999 1 0.36999997 0 0.1138
		 1 0.37 0 0.11379999 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.36999997
		 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.11379999 1
		 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999 1 0.36999997
		 0 0.11379999 1 0.36999997 0 0.11379999 1 0.37 0 0.11379999 1 0 0.2462 0.37 1 0 0.2462
		 0.37 1 0 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.37 1 0 0.24619998 0.37 1 0 0.2462 0.36999997 1 0 0.2462 0.36999997
		 1 0 0.2462 0.37 1 0.051799998 0.37 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1;
	setAttr ".clst[0].clsp[3000:3124]" 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999995 0 1 0.051799998 0.36999995 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051800001 0.37 0 1 0.36999997 0 0.11379999 1 0.36999997
		 0 0.11379999 1 0.36999997 0 0.11379998 1 0.36999997 0 0.11379999 1 0.37 0 0.11379999
		 1 0.36999997 0 0.11379999 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1
		 0 0.2462 0.36999997 1 0.051799998 0.37 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051800001
		 0.36999997 0 1 0.051800001 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998
		 0.36999997 0 1 0.051800001 0.37 0 1 0.051800001 0.37 0 1 0 0.2462 0.37 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0.051799994 0.36999995 0 1 0.051799994 0.36999997 0 1 0.051800001 0.36999997 0
		 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0
		 1 0.051800001 0.36999997 0 1 0.051800001 0.37 0 1 0 0.66189998 0.47639999 1 0 0.66189998
		 0.47639999 1 0 0.66189998 0.47639999 1 0.051800001 0.37 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051800001 0.36999997
		 0 1 0.051800001 0.36999997 0 1 0.051799998 0.37000003 0 1 0.051799998 0.37000003
		 0 1 0.051799994 0.36999995 0 1 0.051799994 0.36999995 0 1 0.051799994 0.36999997
		 0 1 0.051799994 0.36999997 0 1 0.051800001 0.37 0 1 0 0.2462 0.37 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.2462 0.37 1 0 0.2462 0.37 1
		 0 0.2462 0.37 1 0 0.66189998 0.47639999 1 0.051800005 0.37 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999995 0 1 0.051799998 0.36999995 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799998 0.37 0 1 0.051799998 0.37 0 1 0.051799998
		 0.36999997 0 1 0.051799998 0.36999997 0 1 0 0.2462 0.37 1 0.051800001 0.37 0 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.37 1 0 0.24619998 0.37 1 0 0.24619998
		 0.37 1 0 0.2462 0.37 1 0.37 0 0.1138 1 0 0.2462 0.37 1 0.36999997 0 0.11379999 1
		 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999 1 0.37
		 0 0.11379999 1 0.37 0 0.11379999 1 0.051800005 0.37 0 1 0.051799998 0.36999997 0
		 1 0.051799998 0.36999997 0 1;
	setAttr ".clst[0].clsp[3125:3249]" 0.051800001 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999995 0 1 0.051799998 0.36999997 0 1 0.051799998 0.36999997
		 0 1 0.051799998 0.36999997 0 1 0.051799994 0.37000003 0 1 0.051799994 0.37000003
		 0 1 0.051799998 0.36999997 0 1 0.051800001 0.37000003 0 1 0.051800001 0.37 0 1 0
		 0.2462 0.37 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997
		 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0 0.24619998 0.36999997 1 0
		 0.24619998 0.36999997 1 0 0.24619998 0.37000003 1 0 0.24619998 0.37 1 0 0.24619998
		 0.36999997 1 0 0.24619998 0.37 1 0 0.2462 0.37 1 0 0.2462 0.37 1 0.36999997 0 0.11379999
		 1 0.37 0 0.1138 1 0.36999997 0 0.11379998 1 0.36999997 0 0.1138 1 0.37 0 0.11379999
		 1 0.36999997 0 0.11379999 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.11379998
		 1 0.37000003 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37
		 0 0.1138 1 0 0.62899995 0.43909994 1 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138
		 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.11379999 1 0.37 0 0.1138 1
		 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.11379999 1 0.37 0
		 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.11379999
		 1 0.66189998 0 0.5546 1 0 0.66189998 0.47639999 1 0 0.66189998 0.47639999 1 0 0.62900001
		 0.4391 1 0.051800005 0.37 0 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1
		 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1 0 0.62899995
		 0.43909997 1 0 0.62900001 0.43909997 1 0.051800001 0.37000003 0 1 0 0.62899995 0.43909997
		 1 0 0.62900001 0.4391 1 0 0.62899995 0.43909997 1 0 0.62899995 0.43909997 1 0 0.62899995
		 0.43909997 1 0 0.62899995 0.43909997 1 0 0.62900001 0.43909997 1 0 0.62899995 0.43909997
		 1 0.051800001 0.37000003 0 1 0.051799998 0.36999997 0 1 0.051799998 0.37000003 0
		 1 0.051799998 0.37 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510001
		 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510001 0.1418 0 1 0.35510001 0.14180002
		 0 1 0.35510004 0.14180002 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.39067501 0.06825 0 1 0.4057 0.063199997 0 1 0.35509998
		 0.1418 0 1 0.35509998 0.1418 0 1 0.35509998 0.1418 0 1 0.35509998 0.14180002 0 1
		 0.35509998 0.14180002 0 1 0.35510004 0.14180002 0 1 0.4057 0.063199997 0 1 0.27200001
		 0.10859999 0 1 0.35509342 0.14179738 0 1 0.27200001 0.10860001 0 1;
	setAttr ".clst[0].clsp[3250:3374]" 0.35510004 0.14180002 0 1 0.35510004 0.14180002
		 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1
		 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35509998
		 0.1418 0 1 0.35509998 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002
		 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510004 0.14180002 0 1
		 0.35510004 0.14180002 0 1 0.35509998 0.14180002 0 1 0.35509998 0.14180002 0 1 0.35510001
		 0.14180002 0 1 0.27200001 0.10860001 0 1 0.4057 0.063199997 0 1 0.32298127 0.09126249
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.27200001 0.10860001 0 1 0.27200001
		 0.10859999 0 1 0.3550868 0.14179474 0 1 0.35510001 0.14180002 0 1 0.35510004 0.14180002
		 0 1 0.35510004 0.14180002 0 1 0.35510001 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510004
		 0.14180002 0 1 0.35510004 0.1418 0 1 0.35509998 0.1418 0 1 0.35510004 0.14180002
		 0 1 0.35510004 0.14180002 0 1 0.35509998 0.1418 0 1 0.35510004 0.14180002 0 1 0.35510004
		 0.14180002 0 1 0.35510001 0.14180002 0 1 0.35510004 0.14180002 0 1 0.35510001 0.14180002
		 0 1 0.35509998 0.14180002 0 1 0.35510001 0.14180002 0 1 0.35510001 0.14180002 0 1
		 0.32298127 0.09126249 0 1 0.27200001 0.10860001 0 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0 0.62899995
		 0.43909997 1 0 0.62899995 0.43909997 1 0.37 0 0.1138 1 0.36999997 0 0.11379999 1
		 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1
		 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.11379999 1 0.37
		 0 0.11379999 1 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999 1 0.37 0 0.1138
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997
		 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0
		 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.11379999 1 0.36999997 0 0.11379999 1 0.37
		 0 0.1138 1 0.36999997 0 0.11379999 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0
		 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138
		 1 0.36999997 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.11379999 1
		 0.37 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.11379999 1 0.37 0 0.1138 1 0.37 0 0.1138
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.36999997 0 0.1138
		 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.11379999
		 1;
	setAttr ".clst[0].clsp[3375:3456]" 0.37 0 0.11379999 1 0.37 0 0.11379999 1 0.37000003
		 0 0.1138 1 0.37 0 0.1138 1 0.37000003 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138
		 1 0.37 0 0.1138 1 0.37000003 0 0.1138 1 0.36999997 0 0.1138 1 0.37 0 0.1138 1 0.37
		 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.1138 1 0.37 0 0.11379999 1 0.37 0 0.11379999
		 1 0.37 0 0.11379999 1 0.37 0 0.11379999 1 0.37 0.072300002 0 1 0.37 0.072300002 0
		 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.36905476 0.076708935 0 1 0.4057 0.063199997 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.36905476 0.076708935 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057
		 0.063199997 0 1 0.37 0.072300002 0 1 0.4057 0.063199997 0 1 0.37 0.072300002 0 1
		 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0
		 1 0.37 0.072300002 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.37 0.072300002 0 1 0.36905476 0.076708935 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002
		 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1 0.36905476 0.076708935
		 0 1 0.37 0.072300002 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997 0 1 0.4057 0.063199997
		 0 1 0.4057 0.063199997 0 1 0.37 0.072300002 0 1 0.37 0.072300002 0 1;
	setAttr ".clst[1].clsn" -type "string" "SculptFreezeColorTemp";
	setAttr ".clst[2].clsn" -type "string" "SculptMaskColorTemp";
	setAttr ".covm[0]"  0 1 1;
	setAttr ".cdvm[0]"  0 1 1;
	setAttr -s 1358 ".vt";
	setAttr ".vt[0:165]"  1.6554669e-19 1.96350563 0.43020961 -4.7492342e-19 1.90761268 0.41297266
		 0 1.93934822 0.40927577 0 1.94317317 0.40985569 0.022258066 1.97053242 0.42501968
		 0.030923132 1.91284859 0.4079884 0.05369724 1.96313894 0.40650478 0.090000764 1.94675064 0.37167954
		 0.055783384 1.92363703 0.39687103 0.069669969 1.94597805 0.37658873 0.018360741 1.94371533 0.4049435
		 0.045954052 1.94564867 0.39166 0.018277002 1.93993509 0.40452009 0.045627195 1.94218147 0.39084646
		 -0.022257911 1.97053242 0.42501971 -0.030922994 1.91284859 0.40798843 -0.053697102 1.96313894 0.40650484
		 -0.090000659 1.94675064 0.37167963 -0.055783253 1.92363703 0.39687109 -0.069669858 1.94597805 0.37658879
		 -0.018360605 1.94371533 0.40494353 -0.045953929 1.94564867 0.39166003 -0.018276867 1.93993509 0.40452012
		 -0.045627072 1.94218147 0.39084649 -1.3977848e-19 2.21580982 0.43121934 8.4139535e-19 1.88113272 0.39064553
		 2.974694e-19 1.79270148 0.37254399 -4.8248768e-19 2.16519618 0.41148114 1.7463083e-18 2.18966436 0.41680971
		 -2.2063934e-19 2.041741133 0.47828513 -1.023926e-18 2.076145649 0.4595935 -5.6177465e-19 2.013067007 0.41636127
		 -8.7203562e-19 2.1275878 0.43160167 -2.8658021e-19 2.35631442 0.4060463 6.347099e-19 1.97862101 0.42220053
		 -2.2529277e-18 1.9236896 -0.089669466 2.0476827e-18 1.76822555 0.21416135 -2.1975788e-18 2.39386868 -0.16584553
		 3.3987306e-19 2.21923447 -0.20771468 1.8670771e-18 2.49684024 -0.035586104 4.161185e-18 2.50673366 0.18120366
		 2.3352097e-18 1.95255637 -0.09919697 2.3841752e-18 1.58530903 0.15713285 -9.2030593e-18 1.71174514 -0.12399216
		 0.21721584 2.10821772 0.03575182 0.23071143 2.1646452 0.13250557 0.22855195 2.17956471 0.052817043
		 0.26057714 2.18786049 0.055646837 0.21284124 2.048252821 0.062510222 0.22210778 2.097343922 0.13755713
		 0.21177414 1.99979877 0.11818039 0.24746743 2.047335148 0.065155677 0.25928906 2.11954737 0.037981424
		 0.046819054 2.16247725 0.38872692 0.15835316 2.16483784 0.34490046 0.13796151 2.16312933 0.36172354
		 0.13072592 2.1902101 0.37402356 0.11987632 2.17671585 0.37629768 0.065237775 2.1765728 0.39077657
		 0.07134939 2.21656775 0.41787526 0.14936572 2.21148252 0.38112858 0.17905799 2.20213437 0.33889228
		 0.19857012 2.11639786 0.30180684 0.21319558 2.16756797 0.20991814 0.15327856 2.078336239 0.35501373
		 0.11350349 1.94831693 0.35297567 0.08519011 1.9088968 0.36817068 0.043457586 1.88789332 0.38463557
		 0.065124296 1.80055141 0.35782886 0.12166788 1.83829927 0.28816977 0.1653467 1.88085771 0.21619165
		 0.19607507 1.93856871 0.16083136 0.20396399 2.03988719 0.24760041 0.025756527 2.18969202 0.41603899
		 0.020034777 2.16548967 0.40919897 0.02415365 2.041741133 0.46936116 0.02210377 2.075820684 0.45357805
		 0.016247716 2.015452862 0.41350016 0.047145355 2.038261414 0.42511341 0.032691855 2.020844936 0.40896359
		 0.043577038 2.069702625 0.41929144 0.054064389 2.066574335 0.40250665 0.052668378 2.036920786 0.39955115
		 0.020699296 2.12586951 0.42767021 0.12038963 2.1556108 0.37629762 0.21180052 2.085716963 0.19693914
		 0.092427805 2.35272431 0.38427782 0.1628404 2.33144498 0.33469924 0.030847637 2.21522188 0.42709586
		 0.033524789 2.24855232 0.42648813 0.076997668 2.24971938 0.4182896 0.15889682 2.23576021 0.37103161
		 0.060101107 2.11190248 0.39615461 0.033473514 2.16194916 0.39376196 0.035477843 2.1219945 0.40699705
		 0.17195982 1.99627292 0.29735297 0.020895932 1.98163855 0.4179661 0.048112638 1.97995842 0.40444657
		 0.07786458 1.97912645 0.3809652 0.09906482 1.9871788 0.37078404 0.1462453 1.94963253 -0.044859532
		 0.13971023 1.82302904 0.1314566 0.16260593 1.85757172 0.082680948 0.066493087 2.15636158 0.39077657
		 0.058050629 2.19041681 0.39602208 0.1923458 2.34531832 -0.1173655 0.18102872 2.19857693 -0.14671744
		 0.2312898 2.26812792 -0.041066039 0.2216128 2.16630387 -0.070991211 0.22285135 2.32381272 0.094659381
		 0.19416352 2.42780805 0.14223617 0.22575092 2.33904219 0.014828183 0.23223695 2.21378422 0.044233911
		 0.21002381 2.29203534 0.21444379 0.14935826 1.97479665 -0.057708122 0.19659981 2.26748443 0.25454333
		 0.14030465 2.13305688 0.37041175 0.064213686 2.14004374 0.38606098 0.23511995 2.090805531 0.12972803
		 0.25108716 2.16643453 0.12249434 0.16478346 1.63959336 0.055260882 0.18588533 1.67013109 0.0065043177
		 0.15121098 1.70941138 -0.093529359 0.053999208 1.77791452 0.20163968 0.068946794 1.59679759 0.13557176
		 0.086390793 1.71056366 -0.12049741 0.079685181 1.92564404 -0.082471654 0.076939926 1.95430088 -0.090339005
		 0.089938112 2.21603632 -0.19698527 0.10024679 2.38903451 -0.15484469 0.096311539 2.4823184 0.17082024
		 0.099308155 2.42614937 0.33353168 0.17829266 1.89375782 0.031032387 0.18734157 1.6957624 -0.048925564
		 0.12359229 1.61588192 0.09882547 0.094853915 1.79771411 0.16539405 0.10366987 2.47650981 -0.02854039
		 0.19976926 2.41991615 -0.00816595 4.8539739e-19 1.67531538 0.1831577 0.060223654 1.68694603 0.16005389
		 0.10828435 1.70580232 0.12602666 0.14560139 1.73232365 0.084926166 0.16917509 1.75932527 0.043025419
		 0.17690569 1.7838459 -0.0060699638 0.14276417 1.80536485 -0.055925276 0.083303362 1.80976713 -0.089966238
		 9.9222014e-20 1.81208503 -0.095600203 0.23070978 2.014836073 0.11527094 0.22107136 2.12042999 0.015112175
		 3.1406623e-20 1.77693534 0.30234373 0.061799075 1.78544211 0.29203165 0.10728744 1.81680238 0.23576172
		 0.14050795 1.85295582 0.17429973 0.16822082 1.895836 0.1212185 0.18140993 1.95766866 0.066327102
		 0.19132021 2.011358976 0.0059513282 0.19389284 2.025506973 -0.0126672 -8.7034465e-19 2.054129124 -0.16498983
		 0.084081292 2.053247929 -0.15330262 0.20609826 2.078289032 -0.05578452 0.16155754 2.055129766 -0.10769474
		 1.6513295e-18 2.44455028 0.35370082 0.17765428 2.38937092 0.29048267 0.22406881 2.17865133 0.16616851
		 0.21989676 2.11906552 0.16410939 -0.21721603 2.10821772 0.035752017;
	setAttr ".vt[166:331]" -0.23071153 2.1646452 0.13250577 -0.22855213 2.17956471 0.052817252
		 -0.26057732 2.18786049 0.055647075 -0.21284142 2.048252821 0.062510416 -0.22210789 2.097343922 0.13755733
		 -0.21177426 1.99979877 0.11818059 -0.24746761 2.047335148 0.065155901 -0.25928926 2.11954737 0.037981659
		 -0.046818931 2.16247725 0.38872695 -0.15835309 2.16483784 0.34490061 -0.13796142 2.16312933 0.36172366
		 -0.13072582 2.1902101 0.37402368 -0.11987621 2.17671585 0.3762978 -0.065237649 2.1765728 0.39077663
		 -0.071349241 2.21656775 0.41787532 -0.1493656 2.21148252 0.38112873 -0.17905791 2.20213437 0.33889243
		 -0.19857007 2.11639786 0.30180702 -0.21319562 2.16756797 0.20991834 -0.15327847 2.078336239 0.35501388
		 -0.1135034 1.94831693 0.35297576 -0.085190006 1.9088968 0.36817077 -0.043457467 1.88789332 0.3846356
		 -0.065124199 1.80055141 0.35782892 -0.12166783 1.83829927 0.28816989 -0.16534673 1.88085771 0.2161918
		 -0.19607516 1.93856871 0.16083154 -0.20396399 2.03988719 0.24760059 -0.025756381 2.18969202 0.41603902
		 -0.020034637 2.16548967 0.409199 -0.024153456 2.041741133 0.46936119 -0.022103589 2.075820684 0.45357808
		 -0.016247572 2.015452862 0.41350016 -0.047145203 2.038261414 0.42511344 -0.032691717 2.020844936 0.40896362
		 -0.043576889 2.069702625 0.41929147 -0.054064255 2.066574335 0.40250671 -0.052668247 2.036920786 0.39955121
		 -0.02069914 2.12586951 0.42767024 -0.12038952 2.1556108 0.37629774 -0.21180058 2.085716963 0.19693933
		 -0.092427686 2.35272431 0.38427791 -0.16284032 2.33144498 0.33469939 -0.030847481 2.21522188 0.42709589
		 -0.033524632 2.24855232 0.42648816 -0.076997519 2.24971938 0.41828966 -0.15889671 2.23576021 0.37103176
		 -0.06010098 2.11190248 0.39615467 -0.033473387 2.16194916 0.39376199 -0.035477705 2.1219945 0.40699708
		 -0.17195977 1.99627292 0.29735312 -0.020895785 1.98163855 0.41796613 -0.048112504 1.97995842 0.4044466
		 -0.077864468 1.97912645 0.38096526 -0.099064715 1.9871788 0.37078413 -0.14624557 1.94963253 -0.044859398
		 -0.13971034 1.82302904 0.13145672 -0.16260608 1.85757172 0.082681097 -0.06649296 2.15636158 0.39077663
		 -0.058050502 2.19041681 0.39602214 -0.19234614 2.34531832 -0.11736533 -0.18102908 2.19857693 -0.14671728
		 -0.23129007 2.26812792 -0.041065831 -0.22161309 2.16630387 -0.070991009 -0.2228515 2.32381272 0.094659582
		 -0.19416362 2.42780805 0.14223635 -0.22575115 2.33904219 0.014828388 -0.23223715 2.21378422 0.044234119
		 -0.21002384 2.29203534 0.21444398 -0.14935854 1.97479665 -0.057707988 -0.19659981 2.26748443 0.25454351
		 -0.14030455 2.13305688 0.37041187 -0.064213566 2.14004374 0.38606104 -0.23512007 2.090805531 0.12972824
		 -0.25108728 2.16643453 0.12249456 -0.16478355 1.63959336 0.055260956 -0.18588533 1.67013109 0.0065043177
		 -0.15121114 1.70941138 -0.093529291 -0.053999256 1.77791452 0.20163973 -0.068946846 1.59679759 0.13557179
		 -0.086390965 1.71056366 -0.12049737 -0.079685487 1.92564404 -0.082471579 -0.076940238 1.95430088 -0.090338938
		 -0.089938521 2.21603632 -0.1969852 -0.10024716 2.38903451 -0.1548446 -0.096311614 2.4823184 0.17082033
		 -0.099308081 2.42614937 0.33353177 -0.17829287 1.89375782 0.031032547 -0.1873417 1.6957624 -0.048925478
		 -0.12359229 1.61588192 0.09882547 -0.094853997 1.79771411 0.16539413 -0.10367012 2.47650981 -0.028540298
		 -0.1997695 2.41991615 -0.0081657693 -0.06022374 1.68694603 0.16005395 -0.10828435 1.70580232 0.12602666
		 -0.14560154 1.73232365 0.0849263 -0.16917528 1.75932527 0.043025572 -0.17690593 1.7838459 -0.0060698036
		 -0.14276445 1.80536485 -0.055925146 -0.083303675 1.80976713 -0.089966156 -0.2307099 2.014836073 0.11527115
		 -0.22107159 2.12042999 0.015112374 -0.061799042 1.78544211 0.29203171 -0.10728745 1.81680238 0.23576181
		 -0.14050803 1.85295582 0.17429987 -0.16822094 1.895836 0.12121865 -0.18141009 1.95766866 0.066327266
		 -0.19132043 2.011358976 0.0059515014 -0.19389307 2.025506973 -0.012667025 -0.084081665 2.053247929 -0.15330255
		 -0.20609854 2.078289032 -0.055784333 -0.16155787 2.055129766 -0.10769459 -0.17765425 2.38937092 0.29048282
		 -0.22406888 2.17865133 0.16616872 -0.21989685 2.11906552 0.16410959 0.12678221 2.24553132 0.39745882
		 0.11782856 2.21528888 0.40329215 0.10099468 2.19463134 0.38798153 0.094968908 2.18217659 0.38635039
		 0.096621923 2.15311646 0.38582414 0.097378217 2.13017249 0.38364583 0.095590852 2.097336531 0.39358121
		 0.077123821 2.025733471 0.39165127 0.064180732 2.011076212 0.39153036 0.04086009 2.00047278404 0.40699539
		 0.018633768 1.99793589 0.4140133 7.4429577e-19 1.99759674 0.41729203 -0.018633625 1.99793589 0.41401333
		 -0.040859953 2.00047278404 0.40699542 -0.064180605 2.011076212 0.39153042 -0.077123694 2.025733471 0.39165133
		 -0.095590726 2.097336531 0.3935813 -0.097378097 2.13017249 0.38364592 -0.096621804 2.15311646 0.38582423
		 -0.094968788 2.18217659 0.38635048 -0.10099456 2.19463134 0.38798162 -0.11782843 2.21528888 0.40329227
		 -0.12678207 2.24553132 0.39745894 0.031720437 2.025941849 0.42641518 0.020182703 2.023241043 0.44764981
		 9.6574474e-19 2.021420956 0.45654139 -0.020182528 2.023241043 0.44764984 -0.031720281 2.025941849 0.42641521
		 0.13703305 1.96070111 0.33681518 0.1175217 2.0082819462 0.37542289 0.086191811 2.058494091 0.39353636
		 0.056897812 2.087973118 0.39978454 0.039527439 2.09584856 0.41314426 0.021401532 2.1008451 0.44062415
		 -2.834239e-19 2.10186672 0.44559759 -0.021401364 2.1008451 0.44062418 -0.039527297 2.09584856 0.41314429
		 -0.056897681 2.087973118 0.39978459 -0.086191684 2.058494091 0.39353645 -0.11752159 2.0082819462 0.37542301
		 -0.13703297 1.96070111 0.3368153 0.1993562 1.98070872 0.19691993 0.17188089 1.93339181 0.2564742
		 0.12270905 1.88875127 0.30935913 0.055695988 1.84722304 0.37544104 -3.5333095e-19 1.83956277 0.38688505
		 -0.05569588 1.84722304 0.3754411 -0.122709 1.88875127 0.30935925 -0.17188089 1.93339181 0.25647435
		 -0.19935626 1.98070872 0.19692011 0.21563837 2.053049088 0.13609366;
	setAttr ".vt[332:497]" 0.22814274 2.054436922 0.12704593 -0.22814286 2.054436922 0.12704614
		 -0.21563847 2.053049088 0.13609385 1.2784979e-18 0.24534801 0.40765488 -7.1503742e-18 0.62014699 0.41843289
		 -6.1014637e-18 0.616804 -0.20998412 6.0173221e-18 1.22278059 -0.26043281 -1.1451885e-18 1.46792793 0.2486901
		 -5.4210109e-20 1.56958008 -0.19517221 9.7653986e-19 0.80303597 0.41528088 4.6527367e-18 0.45830399 -0.21413513
		 1.9515639e-18 -0.093311943 -0.28316852 -2.3592642e-33 -0.2852695 -0.079124823 2.1141942e-18 -0.18276678 0.32765025
		 -5.014435e-19 -0.21549667 -0.20542604 2.4742882e-19 0.089309998 0.39444292 6.6285043e-18 0.18470991 -0.26175234
		 -4.7433845e-20 1.036047578 0.39778927 7.995991e-19 1.46941006 -0.23375408 -3.3881318e-20 0.99001962 -0.24887799
		 2.1684043e-19 0.040318474 -0.29006755 -8.1315163e-20 1.34843135 -0.25609395 6.7762636e-21 1.26359284 0.35334045
		 1.52073801 -0.111418 0.10514887 1.46088505 -0.149324 0.10366888 1.44965303 -0.111093 0.36624992
		 1.46819997 -0.023386 0.33146387 1.56444502 -0.200499 0.12267487 1.50530398 -0.232465 0.11157288
		 1.50520098 -0.20571899 0.40805691 1.56338406 -0.18121 0.41030288 1.38644397 0.026239 0.35633588
		 1.32467198 0.018289 0.3269729 1.31723404 -0.0019170009 0.26384288 1.37817502 -0.083975002 0.31047088
		 1.43895698 0.037942 0.097621873 1.38301301 0.013475 0.099883869 1.34025204 0.011596 0.20788287
		 1.593925 -0.27906999 0.14191388 1.54068005 -0.30378899 0.14401887 1.55459595 -0.28630501 0.42220789
		 1.597736 -0.26541701 0.42209589 1.41921902 -0.098852001 0.41788691 1.38168705 -0.084247001 0.43129689
		 1.41799903 -0.115423 0.3945269 1.34747398 -0.118815 0.37114692 1.34226799 -0.086156003 0.40758491
		 1.40567899 -0.191416 0.45773786 1.37858498 -0.183461 0.47758788 1.40315402 -0.192302 0.43022192
		 1.34471905 -0.189169 0.41349292 1.33867002 -0.185582 0.44552392 1.42779195 0.046277002 0.28302187
		 1.39733899 0.135501 0.19201188 1.34831893 0.12184602 0.25464913 1.35426545 0.09192615 0.1077883
		 1.30880201 0.089387998 0.18111087 1.32031584 0.10845678 0.25026363 0.83643359 0.78446645 0.11670019
		 0.88436782 0.82245225 0.11292221 0.78290915 0.73460764 0.023154899 0.85360527 0.78378493 -0.09653753
		 0.90672219 0.82903671 -0.088893622 0.95830727 0.87423223 0.021799877 0.80679476 0.75222039 -0.052741349
		 0.79833871 0.749336 0.081642553 0.56030744 1.36247957 -0.14661185 0.53479147 1.34685147 0.1761051
		 0.58679903 1.46922338 0.015370735 0.6247161 1.25486493 -0.12487981 0.59929895 1.24457932 0.14983431
		 0.65579528 1.35379612 0.024540896 0.6552667 1.061684966 -0.11696147 0.63261127 1.059351921 0.14884946
		 0.69153363 1.14345884 -0.10924169 0.67084879 1.13460398 0.1429401 0.72633064 1.22394657 0.021987757
		 0.62071687 1.003097415 -0.070402883 0.61110348 0.9954468 0.089845546 0.60528308 0.98012859 0.014232293
		 0.56959283 1.14702785 0.15846014 0.55553871 1.072588682 0.10004463 0.55346096 1.050513983 0.013451234
		 0.5659948 1.079391718 -0.078062825 0.59369069 1.1516881 -0.13055971 0.50848609 1.53497159 0.0094853099
		 0.47210202 1.40352774 0.19092351 0.47853684 1.44327962 -0.16406752 0.46942565 1.31580353 -0.15814692
		 0.46349338 1.28675985 0.20925184 0.46861151 1.1793071 0.1382492 0.48355594 1.137133 0.011684553
		 0.46389502 1.19658947 -0.10702121 0.34854001 0.310431 -0.069475129 0.41157201 0.30597401 0.057825878
		 0.248631 0.31464201 -0.16554812 0.22864699 0.260896 0.3626979 0.34765601 0.61772698 -0.06866312
		 0.400363 0.61979401 0.04661487 0.31603491 1.21015 -0.20437281 0.249265 0.61703902 -0.15163013
		 0.3813999 1.44202697 0.19606572 0.242588 0.62301898 0.35836887 0.25422469 1.48679435 0.19973165
		 0.33120862 1.61052442 0.013138293 0.36210307 0.77700967 -0.07746952 0.25828999 0.777309 -0.16017012
		 0.251219 0.80414897 0.35387391 0.35169199 0.79774499 0.27536988 0.41641483 0.78107065 0.040171176
		 0.403272 0.455708 0.052282885 0.237895 0.44174299 0.36494291 0.34328499 0.45601699 -0.064868122
		 0.24620099 0.45741999 -0.15284713 1.1103245 0.43853721 -0.012548096 1.082186818 0.4408952 0.17171377
		 1.16200626 0.46789029 -0.014045127 1.12461948 0.47329476 0.17137486 1.19800329 0.51226032 0.095677868
		 1.049553394 0.40456876 0.08924298 1.26431084 0.3096945 0.040564612 1.28692985 0.34363824 0.13696171
		 1.2274642 0.31356674 0.19999725 1.19582665 0.29034719 0.1962131 1.17388034 0.26284012 0.12879358
		 1.22448683 0.28989303 0.040287241 1.36208296 0.201947 0.17356788 1.31236696 0.180143 0.23576286
		 1.28445852 0.162535 0.23077375 1.26708806 0.140591 0.16249888 1.31286395 0.16260816 0.090249881
		 1.34853697 0.17853749 0.084412381 0.41489056 -0.044644687 -0.1038363 0.46333063 -0.018477067 0.19591162
		 0.48289907 -0.0047049075 0.050923202 0.11964612 -0.29930824 -0.06902422 0.23928103 -0.16885939 0.31952584
		 0.098819464 -0.29023343 0.087780513 0.27235505 -0.51560903 -0.11517782 0.48553711 -0.43604127 -0.06139259
		 0.30898744 -0.12154882 -0.20253609 0.23931575 -0.022987749 0.33482888 0.20626017 -0.23093662 -0.18360108
		 0.3631607 0.19233167 -0.074993305 0.26171446 0.18758261 -0.18039185 0.42222363 0.18862669 0.053293601
		 0.2334103 0.11562081 0.34698346 0.76215345 -2.75193048 -0.074407861 0.74745357 -2.74614954 0.0073611727
		 0.71888715 -2.75175166 -0.15591127 0.54481232 -2.75175166 -0.14002226 0.52552903 -2.75175166 -0.06557624
		 0.56122774 -2.74920273 0.014939465 0.67322683 -2.0079729557 0.010561276 0.45966983 -2.022389889 -0.14540048
		 0.48210245 -2.026040077 0.0091828462 0.67691088 -2.00041127205 -0.15182431 0.70835751 -2.00072979927 -0.067470975
		 0.44091916 -2.02772069 -0.056926418 0.68781424 -2.44121909 -0.14526035 0.69466871 -2.44308233 -0.023734858
		 0.71894401 -2.44057488 -0.085662127 0.53549486 -2.44598842 -0.14149895 0.55300528 -2.44640374 -0.019744543
		 0.52116501 -2.45044899 -0.072385117 0.48716375 -2.24422646 -0.067178771;
	setAttr ".vt[498:663]" 0.51423252 -2.24166727 -0.0034593819 0.68363249 -2.22617555 -0.14737606
		 0.50508654 -2.239182 -0.14132923 0.68556833 -2.22962499 -0.010300916 0.71538568 -2.22535753 -0.078570537
		 0.69903064 -2.62365627 -0.1486235 0.7286002 -2.62406087 -0.082733199 0.71384764 -2.62555456 -0.02078091
		 0.56257689 -2.62424946 -0.010872912 0.53113812 -2.62500072 -0.070537172 0.54618722 -2.62190866 -0.14273056
		 0.3456203 -1.45580912 0.0093534142 0.37477556 -1.44867361 -0.075288601 0.60105282 -1.4168427 -0.077622309
		 0.64547861 -1.41372454 0.0086553264 0.61184877 -1.42588401 0.09598504 0.38427839 -1.45761895 0.10049652
		 0.78069508 -2.92612267 0.035658747 0.77699834 -2.99368429 0.034703426 0.71882361 -2.92310429 -0.15743865
		 0.7161395 -2.99368405 -0.15846434 0.55186236 -2.92416501 -0.13922016 0.55189145 -2.92891645 0.060697474
		 0.55572903 -2.99368405 -0.13858739 0.56236315 -2.99368429 0.062320665 0.58354926 -2.87208319 0.2771011
		 0.78950709 -2.87123775 0.26597911 0.80436343 -2.93572903 0.38491255 0.58406299 -2.93277979 0.4160437
		 0.57827598 -2.99368405 0.4308539 0.81577015 -2.99368405 0.39732587 0.54859132 -2.92835808 -0.058955237
		 0.55830431 -2.99368405 -0.054815233 0.76036185 -2.92309022 -0.069547057 0.75434041 -2.99368405 -0.068995081
		 0.59170616 -2.92067146 -0.19689356 0.59207243 -2.99368405 -0.19524489 0.59450448 -2.89629436 0.36562997
		 0.78628045 -2.90036488 0.34200281 0.76393276 -2.8414619 0.037953474 0.55551791 -2.84300947 0.052923746
		 0.50775826 -0.66935647 -0.03852943 0.54034418 -0.67226708 0.17946367 0.57305598 -0.65897399 0.060500115
		 0.23143649 -0.74263948 -0.023194378 0.23424773 -0.75097364 0.22191077 0.19360946 -0.75620276 0.090302378
		 0.53085333 -0.88628346 -0.038860265 0.55742335 -0.89187443 0.16356413 0.58786941 -0.87986124 0.054591622
		 0.27458903 -0.94084382 -0.021053897 0.27964607 -0.95244128 0.19583791 0.24151915 -0.95327687 0.079135746
		 0.19788389 -0.54874331 0.23317513 0.14955494 -0.56005567 0.094823927 0.52356315 -0.43587273 0.19218759
		 0.5515182 -0.41971019 0.058257878 0.18827589 -0.5438354 -0.030350845 0.25913838 1.024268627 0.34444341
		 0.41448864 1.57605863 0.011459983 0.33788785 1.48603165 -0.17886215 0.34951743 0.027338257 0.28371087
		 0.33991972 0.14119062 0.292429 0.33444101 0.27813801 0.29798272 0.33626401 0.44907001 0.29080486
		 0.33783001 0.62276602 0.27930188 0.42116511 0.1741253 0.19276659 0.409251 0.29496601 0.19495986
		 0.39876601 0.45294899 0.18133388 0.39412901 0.621261 0.17023589 0.41080499 0.78923899 0.16559987
		 0.3722491 1.0087260008 0.26817045 0.4455207 0.9937734 0.15551786 0.45353535 0.98283947 0.023192383
		 0.39467573 0.98023391 -0.096553892 0.27961418 0.98448819 -0.18340743 0.31305644 -0.71951282 -0.10079265
		 0.35075575 -0.9219768 -0.095816404 0.44365826 -1.43947184 -0.12759624 0.52463281 -2.016279936 -0.20327079
		 0.55979043 -2.23616576 -0.19820474 0.58123755 -2.44590783 -0.18564554 0.58863902 -2.62367916 -0.18995316
		 0.59080178 -2.75175166 -0.19783022 0.53414339 1.24359393 -0.14797556 0.5141232 1.15140569 -0.088586792
		 0.50655794 1.11355281 0.012460276 0.50771433 1.13959014 0.11236055 0.50945157 1.23495579 0.18147475
		 0.44194043 0.077892415 0.19445521 0.44723633 0.093818948 0.052736342 0.39115003 0.07574667 -0.085982114
		 0.28296265 0.043870863 -0.19405571 0.76154339 1.0014301538 0.13548198 0.71386737 0.94093871 0.13834357
		 0.6829465 0.89460999 0.082079612 0.67594588 0.88297713 0.016475126 0.69486463 0.90172929 -0.062852554
		 0.73295885 0.94976825 -0.10760614 0.77905124 1.009809494 -0.098522447 0.82076496 1.071548104 0.020610653
		 1.051410675 0.41310257 0.139055 1.17485535 0.27106878 0.16939394 1.26656699 0.14827099 0.20382188
		 1.30356002 0.096130997 0.22207187 1.070545435 0.41414982 0.026303237 1.19111621 0.26979864 0.078979358
		 1.28632784 0.14811382 0.11726604 1.33023858 0.090069495 0.13724872 1.35679603 0.010419 0.14850189
		 1.39997602 -0.072778001 0.24191289 1.45662904 -0.13821401 0.27437389 1.51124501 -0.225693 0.30591089
		 1.56910098 -0.329153 0.33772486 1.61567795 -0.306961 0.33693486 1.56677604 -0.19517399 0.30633289
		 1.51902699 -0.105915 0.27873588 1.43949699 0.048094999 0.22703989 1.42417705 -0.078731 0.099390879
		 1.48526502 -0.045405 0.096874878 1.47356403 -0.022933999 0.2553829 1.50785601 -0.089945003 0.36282688
		 1.058953047 0.61811531 -0.053994745 1.10815907 0.66635233 0.058602169 1.028581619 0.61940938 0.14405255
		 0.9793011 0.58265835 0.14472538 0.94107652 0.55183607 0.11070837 0.93364668 0.54189628 0.054661021
		 0.95943171 0.55517334 -0.014820826 1.0021867752 0.58486885 -0.055524375 0.24365573 1.58432412 -0.14524637
		 0.11666621 1.47072232 0.2383232 0.13267656 1.033109069 0.38470858 0.129544 0.80353701 0.39878792
		 0.12537301 0.621153 0.40296191 0.121196 0.435442 0.40163988 0.115912 0.249552 0.39669889
		 0.10977 0.095228001 0.38611686 0.102636 -0.048395488 0.35913673 0.099147059 -0.18011369 0.32844073
		 0.052514415 -0.29580137 0.087450057 0.068951003 -0.290306 -0.07527712 0.1116294 -0.21609949 -0.2001844
		 0.14958787 -0.094981909 -0.25671032 0.14604516 0.037937462 -0.26291338 0.13643077 0.18727325 -0.24423911
		 0.128703 0.31718999 -0.22146413 0.12733901 0.45850301 -0.20272513 0.128429 0.616898 -0.19705713
		 0.13284101 0.775464 -0.20601313 0.1448902 0.9884432 -0.23116919 0.15817212 1.21978724 -0.24298961
		 0.15108186 1.47288191 -0.21657191 0.12195207 1.57379425 -0.18033394 0.59302324 -1.28410447 0.11395822
		 0.62800813 -1.27265668 0.022086255 0.58126855 -1.28056288 -0.062000122 0.42189923 -1.30504334 -0.11454442
		 0.3498728 -1.31489813 -0.056970313 0.32062611 -1.32222176 0.030729949 0.35831273 -1.32196259 0.12838805
		 0.25620478 1.36717021 0.27761155 0.12825435 1.37422156 0.30114833 0.38523623 1.22029638 0.25765091
		 1.40383387 -0.080095023 0.16837187 1.46086204 -0.148166 0.18771888;
	setAttr ".vt[664:829]" 1.51029503 -0.233152 0.20603786 1.56062603 -0.32818401 0.21942286
		 1.61134505 -0.304423 0.21781589 1.56667805 -0.200817 0.20640387 1.52226806 -0.112411 0.19105287
		 1.48217106 -0.035319999 0.17939587 1.44076395 0.048647001 0.16173087 1.40215743 0.12938862 0.13648146
		 1.36545169 0.19758028 0.11680225 1.28750777 0.33648205 0.077512868 1.19420791 0.50183523 0.030830352
		 1.097934604 0.65266156 -0.0073402124 0.94673419 0.86389154 -0.040609885 0.80645883 1.056649685 -0.050272398
		 0.71256626 1.20802891 -0.055957906 0.64412016 1.33808279 -0.064288676 0.57919693 1.44583857 -0.084328428
		 0.49736649 1.51784432 -0.091524497 0.39253336 1.57026005 -0.087173171 0.3072947 1.61599803 -0.07660415
		 1.37983775 0.136427 0.24274394 1.34542167 0.19670799 0.22287092 1.2654196 0.33772027 0.18717164
		 1.17067492 0.50410259 0.14888436 1.080893278 0.65399051 0.11342239 0.93094927 0.86048853 0.079743378
		 0.80000573 1.055516601 0.088141419 0.70482862 1.2027632 0.094086044 0.63143563 1.32683539 0.10166415
		 0.56648397 1.44271708 0.10929744 0.49665052 1.50152469 0.10249729 0.4104054 1.53090572 0.11085119
		 0.30843979 1.56223881 0.10621417 0.32942837 1.34019101 -0.20764022 0.15858586 1.34674191 -0.23957513
		 0.75948381 -2.8444612 -0.072690703 0.71982169 -2.84481144 -0.15909649 0.59138089 -2.84116483 -0.19755401
		 0.54806989 -2.84216571 -0.14052315 0.53589153 -2.84464312 -0.06248562 0.22719 -0.31640983 -0.15078463
		 0.449054 -0.18984953 -0.094423622 0.51613939 -0.15977377 0.05393818 0.49795929 -0.18326123 0.20119557
		 0.16381674 -0.36838517 0.23829268 0.1095931 -0.38319305 0.091792524 0.13867842 -0.36123285 -0.057413671
		 0.60559893 -1.088925004 0.041145876 0.5738309 -1.10050261 0.1401507 0.32217792 -1.1473645 0.16337748
		 0.2844013 -1.14687943 0.056528084 0.31332922 -1.13623381 -0.035646364 0.38657337 -1.12186611 -0.10301411
		 0.55494559 -1.093667984 -0.046410739 0.43974715 -1.80377018 0.038258586 0.65796268 -1.78297377 0.039798852
		 0.70015061 -1.77092838 -0.047209095 0.66280121 -1.76796019 -0.13621068 0.48778865 -1.78076756 -0.19704251
		 0.41802672 -1.79224527 -0.13602118 0.39211529 -1.80320024 -0.037299845 0.1335718 1.26050842 0.34574991
		 0.26504558 1.24754465 0.31665039 0.37977266 1.33424175 0.25269774 1.0062446594 0.78435439 -0.032358538
		 1.018727541 0.79729927 0.030033506 0.98895186 0.78154987 0.087276012 0.93969738 0.74532288 0.11764683
		 0.88955665 0.71007746 0.11815887 0.85098678 0.67600721 0.086255826 0.8375541 0.66345972 0.029791895
		 0.8634755 0.67943251 -0.041938044 0.90729856 0.71085972 -0.084447458 0.96557367 0.7483663 -0.079693638
		 1.38502812 0.11170135 0.10789861 1.43961298 -0.039140001 0.36611986 -1.38644397 0.026239 0.35633588
		 -1.43961298 -0.039140001 0.36611986 -1.46819997 -0.023386 0.33146387 -1.42779195 0.046277002 0.28302187
		 -1.42417705 -0.078731 0.099390879 -1.48526502 -0.045405 0.096874878 -1.52073801 -0.111418 0.10514887
		 -1.46088505 -0.149324 0.10366888 -1.34025204 0.011596 0.20788287 -1.39997602 -0.072778001 0.24191289
		 -1.37817502 -0.083975002 0.31047088 -1.31723404 -0.0019170009 0.26384288 -1.56910098 -0.32915199 0.33772486
		 -1.61567795 -0.306961 0.33693486 -1.597736 -0.26541701 0.42209589 -1.55459595 -0.28630501 0.42220789
		 -1.45662904 -0.13821401 0.27437389 -1.44965303 -0.111093 0.36624992 -1.56444502 -0.200499 0.12267487
		 -1.50530398 -0.232465 0.11157288 -1.50785601 -0.089945003 0.36282688 -1.51124501 -0.225693 0.30591089
		 -1.50520098 -0.20571899 0.40805691 -1.51902699 -0.105915 0.27873588 -1.47356403 -0.022933999 0.2553829
		 -1.30880201 0.089387998 0.18111087 -1.3302387 0.090069495 0.13724872 -1.35679603 0.010419 0.14850189
		 -1.32467198 0.018289 0.3269729 -1.32031584 0.10845678 0.25026363 -1.30356002 0.096130997 0.22207187
		 -1.593925 -0.27906999 0.14191388 -1.54068005 -0.30378899 0.14401887 -1.56338406 -0.18121 0.41030288
		 -1.56677604 -0.19517399 0.30633289 -1.34471905 -0.189169 0.41349292 -1.40315402 -0.192302 0.43022192
		 -1.33867002 -0.185582 0.44552392 -1.40567899 -0.191416 0.45773786 -1.37858498 -0.183461 0.47758788
		 -1.34747398 -0.118815 0.37114692 -1.34226799 -0.086156003 0.40758491 -1.38168705 -0.084247001 0.43129689
		 -1.34831893 0.12184602 0.25464913 -1.41921902 -0.098852001 0.41788691 -1.41799903 -0.115423 0.3945269
		 -0.56648403 1.44271708 0.10929744 -0.49665052 1.50152469 0.10249729 -0.47210202 1.40352774 0.19092353
		 -0.53479147 1.34685147 0.1761051 -0.63143563 1.32683539 0.10166415 -0.59929895 1.24457932 0.14983431
		 -0.64412016 1.33808279 -0.064288668 -0.57919693 1.44583869 -0.08432842 -0.58679897 1.46922326 0.015370735
		 -0.65579534 1.35379612 0.024540896 -0.49736649 1.51784432 -0.091524497 -0.50848609 1.53497159 0.0094853099
		 -0.71256626 1.20802891 -0.055957906 -0.7263307 1.22394657 0.021987759 -0.69153363 1.14345884 -0.10924169
		 -0.6247161 1.25486493 -0.12487981 -0.67084879 1.13460398 0.1429401 -0.56959283 1.14702785 0.15846014
		 -0.63261127 1.059351921 0.14884946 -0.70482862 1.2027632 0.094086044 -0.93094927 0.86048853 0.079743378
		 -0.80000573 1.055516601 0.088141419 -0.76154339 1.0014301538 0.13548198 -0.88436782 0.82245219 0.11292221
		 -0.71386737 0.94093871 0.13834357 -0.83643359 0.78446639 0.11670019 -0.56030744 1.36247957 -0.14661185
		 -0.47853684 1.44327962 -0.16406752 -0.6829465 0.89460999 0.082079612 -0.67594588 0.88297713 0.016475126
		 -0.78290915 0.73460764 0.023154899 -0.79833871 0.749336 0.081642553 -0.46349338 1.28675985 0.20925182
		 -0.50945151 1.23495579 0.18147475 -0.61110348 0.99544674 0.089845546 -0.55553871 1.072588682 0.10004463
		 -0.55346096 1.050513983 0.013451234 -0.60528308 0.98012859 0.014232293 -0.90672219 0.82903671 -0.088893622
		 -0.77905124 1.009809494 -0.098522447 -0.94673419 0.86389154 -0.040609889 -0.80645883 1.056649685 -0.050272398
		 -0.82076496 1.071548104 0.020610653 -0.95830733 0.87423223 0.021799879;
	setAttr ".vt[830:995]" -0.69486463 0.90172929 -0.062852554 -0.73295885 0.9497683 -0.10760614
		 -0.85360533 0.78378487 -0.096537523 -0.80679476 0.75222045 -0.052741356 -0.62071687 1.003097415 -0.070402883
		 -0.5659948 1.079391718 -0.078062825 -0.59369069 1.1516881 -0.13055971 -0.6552667 1.061685085 -0.11696147
		 -0.50771433 1.13959014 0.11236055 -0.46861151 1.1793071 0.1382492 -0.50655794 1.11355281 0.012460275
		 -0.48355591 1.137133 0.011684541 -0.5141232 1.15140557 -0.088586792 -0.46389502 1.19658947 -0.10702121
		 -0.53414345 1.24359393 -0.14797556 -0.46942565 1.31580353 -0.15814692 -0.41448864 1.57605863 0.011459983
		 -0.39253336 1.57026005 -0.087173171 -0.33444101 0.27813801 0.29798272 -0.409251 0.29496601 0.19495986
		 -0.39876601 0.45294899 0.18133388 -0.33626401 0.44907001 0.29080486 -0.242588 0.62301898 0.35836887
		 -0.12537301 0.621153 0.40296191 -0.121196 0.435442 0.40163988 -0.237895 0.44174299 0.36494291
		 -0.25913838 1.024268627 0.34444341 -0.13267656 1.033109069 0.38470858 -0.3813999 1.44202697 0.19606572
		 -0.4104054 1.53090572 0.11085119 -0.33788785 1.48603165 -0.17886215 -0.32942837 1.34019101 -0.20764022
		 -0.15858586 1.34674191 -0.23957513 -0.15108186 1.47288191 -0.21657191 -0.31603491 1.21015 -0.20437281
		 -0.15817212 1.21978724 -0.24298961 -0.34854001 0.310431 -0.069475129 -0.34328499 0.45601699 -0.064868122
		 -0.403272 0.455708 0.052282885 -0.41157201 0.30597401 0.057825878 -0.24926502 0.61703902 -0.15163013
		 -0.24620099 0.45741999 -0.15284713 -0.12733901 0.45850301 -0.20272513 -0.128429 0.616898 -0.19705713
		 -0.34765601 0.61772698 -0.06866312 -0.33783001 0.62276602 0.27930188 -0.35169199 0.79774499 0.27536988
		 -0.251219 0.80414897 0.35387391 -0.22864699 0.260896 0.3626979 -0.11666621 1.47072232 0.2383232
		 -0.25422469 1.48679435 0.19973165 -0.33120862 1.61052442 0.013138293 -0.3072947 1.61599803 -0.07660415
		 -0.400363 0.61979401 0.04661487 -0.36210307 0.77700967 -0.07746952 -0.41641483 0.78107065 0.040171176
		 -0.25828999 0.777309 -0.16017012 -0.129544 0.80353701 0.39878792 -0.13284101 0.775464 -0.20601313
		 -0.26504558 1.24754465 0.31665039 -0.38523623 1.22029638 0.25765091 -0.37977266 1.33424175 0.25269774
		 -0.25620478 1.36717021 0.27761155 -0.39412901 0.621261 0.17023589 -0.115912 0.249552 0.39669889
		 -0.128703 0.31718999 -0.22146413 -0.248631 0.31464201 -0.16554812 -1.16200626 0.46789029 -0.014045127
		 -1.058953047 0.61811531 -0.053994745 -1.40215743 0.1293886 0.13648146 -1.36545169 0.19758028 0.11680225
		 -1.36208296 0.201947 0.17356788 -1.39733899 0.135501 0.19201188 -1.26708806 0.140591 0.16249888
		 -1.28632784 0.14811382 0.11726604 -1.12461948 0.47329476 0.17137486 -1.028581619 0.61940938 0.14405255
		 -0.9793011 0.58265835 0.14472538 -1.082186818 0.4408952 0.17171377 -0.94107652 0.55183607 0.11070837
		 -1.051410675 0.41310257 0.139055 -1.31236696 0.180143 0.23576286 -1.28445852 0.162535 0.23077375
		 -1.26656699 0.14827099 0.20382188 -1.31286395 0.16260816 0.090249881 -1.34853697 0.17853749 0.084412381
		 -1.38502812 0.11170135 0.10789861 -1.35426545 0.09192615 0.1077883 -1.37983775 0.136427 0.24274394
		 -1.34542167 0.19670799 0.22287092 -1.19420791 0.50183523 0.030830352 -1.097934604 0.65266156 -0.0073402124
		 -1.10815907 0.66635233 0.058602169 -1.19800329 0.51226032 0.095677868 -1.049553394 0.40456876 0.08924298
		 -0.93364668 0.54189628 0.054661021 -0.95943177 0.55517334 -0.014820826 -1.070545435 0.41414982 0.026303237
		 -1.17067492 0.50410259 0.14888436 -1.080893278 0.65399051 0.11342239 -1.28750777 0.33648205 0.077512868
		 -1.28692985 0.34363824 0.13696171 -1.2654196 0.33772027 0.18717164 -1.2274642 0.31356674 0.19999725
		 -1.19582665 0.29034719 0.1962131 -1.17485535 0.27106878 0.16939394 -1.19111621 0.26979864 0.078979358
		 -1.17388034 0.26284012 0.12879358 -1.26431084 0.3096945 0.040564612 -0.22718999 -0.31640983 -0.15078464
		 -0.44905403 -0.18984953 -0.094423614 -0.48553711 -0.43604127 -0.06139259 -0.27235505 -0.51560903 -0.11517782
		 -0.3631607 0.19233167 -0.074993305 -0.26171446 0.18758261 -0.18039185 -0.11964613 -0.29930824 -0.06902422
		 -0.098819464 -0.29023343 0.087780513 -0.052514415 -0.29580137 0.087450057 -0.068951003 -0.290306 -0.07527712
		 -0.23928103 -0.16885939 0.31952584 -0.099147059 -0.18011369 0.32844073 -0.23931575 -0.022987749 0.33482888
		 -0.102636 -0.048395488 0.35913673 -0.13643077 0.18727325 -0.24423911 -0.1116294 -0.21609949 -0.2001844
		 -0.14958787 -0.094981909 -0.25671032 -0.30898744 -0.12154882 -0.20253608 -0.20626019 -0.23093663 -0.18360108
		 -0.44723633 0.093818948 0.052736342 -0.39115003 0.07574667 -0.085982114 -0.42222363 0.18862669 0.053293601
		 -0.10977 0.095228001 0.38611686 -0.2334103 0.11562169 0.34698346 -0.33991972 0.14119066 0.292429
		 -0.34951743 0.027338257 0.28371087 -0.41489056 -0.044644687 -0.1038363 -0.28296265 0.043870863 -0.19405571
		 -0.14604516 0.037937462 -0.26291338 -0.42116511 0.1741253 0.19276659 -0.39211529 -1.80320024 -0.037299845
		 -0.43974715 -1.80377018 0.038258586 -0.48778865 -1.78076756 -0.19704251 -0.41802675 -1.79224527 -0.13602115
		 -0.65796268 -1.78297377 0.039798852 -0.70015061 -1.77092838 -0.047209095 -0.66280121 -1.76796019 -0.13621065
		 -0.48210245 -2.026040077 0.0091828462 -0.44091916 -2.02772069 -0.056926418 -0.48716378 -2.24422646 -0.067178771
		 -0.51423252 -2.24166727 -0.0034593819 -0.45966995 -2.022389889 -0.14540042 -0.52463281 -2.016279936 -0.20327079
		 -0.55979031 -2.23616505 -0.19820474 -0.50508654 -2.239182 -0.14132923 -0.54618722 -2.62190866 -0.14273056
		 -0.58863902 -2.62367916 -0.18995316 -0.59080178 -2.75175166 -0.19783022 -0.54481232 -2.75175166 -0.14002226
		 -0.7286002 -2.62406087 -0.082733199 -0.71384764 -2.62555408 -0.02078091 -0.74745357 -2.74614954 0.0073611727
		 -0.76215339 -2.75193024 -0.074407853 -0.67322683 -2.0079729557 0.010561276 -0.68556833 -2.22962499 -0.010300916
		 -0.67691088 -2.00041127205 -0.15182431 -0.70835745 -2.00073003769 -0.067470975;
	setAttr ".vt[996:1161]" -0.71538568 -2.22535753 -0.078570537 -0.68363255 -2.22617507 -0.14737606
		 -0.56257689 -2.62424946 -0.010872912 -0.53113812 -2.62500072 -0.070537172 -0.52552903 -2.75175166 -0.06557624
		 -0.56122774 -2.74920273 0.014939465 -0.69903064 -2.62365627 -0.1486235 -0.71888715 -2.75175166 -0.15591127
		 -0.52116501 -2.45044899 -0.072385117 -0.55300528 -2.44640374 -0.019744543 -0.58123755 -2.44590712 -0.18564554
		 -0.53549486 -2.44598842 -0.14149895 -0.69466871 -2.44308233 -0.023734858 -0.71894401 -2.44057488 -0.085662127
		 -0.68781424 -2.44121814 -0.14526035 -0.76393276 -2.8414619 0.037953474 -0.75948381 -2.8444612 -0.072690703
		 -0.53589153 -2.84464312 -0.06248562 -0.55551791 -2.84300947 0.052923746 -0.78069508 -2.92612267 0.035658747
		 -0.77699834 -2.99368429 0.034703426 -0.75434047 -2.99368405 -0.068995081 -0.76036185 -2.92309022 -0.069547057
		 -0.71982169 -2.84481072 -0.15909629 -0.59138089 -2.84116483 -0.19755401 -0.71613944 -2.99368405 -0.15846434
		 -0.59207243 -2.99368405 -0.19524489 -0.59170616 -2.92067146 -0.19689356 -0.71882361 -2.92310429 -0.15743865
		 -0.55572903 -2.99368405 -0.13858739 -0.55830431 -2.99368405 -0.054815233 -0.54859132 -2.92835808 -0.058955237
		 -0.55186236 -2.92416501 -0.13922016 -0.78950709 -2.87123775 0.26597911 -0.78628045 -2.90036488 0.34200281
		 -0.80436349 -2.93572903 0.38491258 -0.81577015 -2.99368405 0.39732587 -0.56236315 -2.99368429 0.062320665
		 -0.57827598 -2.99368405 0.4308539 -0.58406299 -2.93277979 0.4160437 -0.55189145 -2.92891622 0.060697481
		 -0.59450448 -2.89629436 0.36562997 -0.58354926 -2.87208319 0.2771011 -0.54806989 -2.84216571 -0.14052315
		 -0.19788389 -0.54874331 0.23317513 -0.23424773 -0.75097364 0.22191077 -0.16381674 -0.36838517 0.23829268
		 -0.1095931 -0.38319305 0.091792524 -0.14955494 -0.56005567 0.094823927 -0.54034418 -0.67226708 0.17946367
		 -0.55742335 -0.89187443 0.16356413 -0.19360946 -0.75620276 0.090302378 -0.24151915 -0.95327687 0.079135746
		 -0.27964607 -0.95244128 0.19583791 -0.51613939 -0.15977377 0.05393818 -0.49795932 -0.18326123 0.20119557
		 -0.52356315 -0.43587273 0.19218758 -0.5515182 -0.41971019 0.058257878 -0.13867842 -0.36123285 -0.057413671
		 -0.18827589 -0.5438354 -0.030350845 -0.32217792 -1.1473645 0.16337748 -0.2844013 -1.14687943 0.056528084
		 -0.32062611 -1.32222176 0.030729949 -0.35831273 -1.32196259 0.12838805 -0.50775826 -0.66935647 -0.03852943
		 -0.57305598 -0.65897399 0.060500115 -0.58786941 -0.87986124 0.054591622 -0.53085333 -0.88628346 -0.038860265
		 -0.23143649 -0.74263948 -0.023194378 -0.27458903 -0.94084382 -0.021053897 -0.31305644 -0.71951282 -0.10079265
		 -0.35075575 -0.9219768 -0.095816404 -0.55494565 -1.09366715 -0.046410739 -0.60559893 -1.088925004 0.041145876
		 -0.62800813 -1.27265668 0.022086255 -0.58126855 -1.28056276 -0.062000122 -0.31332922 -1.13623381 -0.035646364
		 -0.3498728 -1.31489813 -0.056970313 -0.5738309 -1.10050261 0.1401507 -0.59302324 -1.28410447 0.11395822
		 -0.38657337 -1.12186611 -0.10301411 -0.42189923 -1.30504334 -0.11454442 -0.12825435 1.37422156 0.30114833
		 -0.1335718 1.26050842 0.34574991 -0.44194043 0.077892415 0.19445521 -0.41080499 0.78923899 0.16559987
		 -0.4455207 0.9937734 0.15551786 -0.3722491 1.0087260008 0.26817045 -0.45353535 0.98283947 0.023192383
		 -0.39467573 0.98023391 -0.096553892 -0.27961418 0.98448819 -0.18340743 -0.1448902 0.9884432 -0.23116919
		 -0.46333063 -0.018477067 0.19591162 -0.48289907 -0.0047049075 0.050923202 -1.0021867752 0.58486885 -0.055524375
		 -1.1103245 0.43853721 -0.012548096 -1.22448683 0.289893 0.04028723 -1.38301289 0.013475 0.099883869
		 -1.40383399 -0.080095015 0.16837187 -1.46086204 -0.14816602 0.18771888 -1.51029491 -0.233152 0.20603786
		 -1.56062603 -0.32818401 0.21942286 -1.61134517 -0.30442297 0.21781589 -1.56667805 -0.200817 0.20640387
		 -1.52226806 -0.11241099 0.19105287 -1.48217106 -0.035319999 0.17939587 -1.44076407 0.048647001 0.16173087
		 -1.43949687 0.048094977 0.22703989 -1.43895698 0.037942 0.097621873 -1.0062446594 0.78435439 -0.032358538
		 -1.018727541 0.79729927 0.030033506 -0.98895186 0.78154987 0.087276012 -0.93969738 0.74532288 0.11764683
		 -0.88955665 0.71007746 0.11815887 -0.85098678 0.67600721 0.086255826 -0.8375541 0.66345972 0.029791895
		 -0.8634755 0.67943245 -0.04193804 -0.90729856 0.71085972 -0.084447458 -0.96557367 0.7483663 -0.079693638
		 -0.12195207 1.57379425 -0.18033394 -0.24365573 1.58432412 -0.14524637 -0.30843979 1.56223881 0.10621417
		 -3.0493186e-20 1.37391484 0.307037 -8.1052252e-18 0.43313 0.41442287 1.4162391e-17 -0.05412849 0.36541447
		 5.2583805e-18 -0.29332921 0.084814817 -4.5776485e-18 0.31643 -0.23560213 -9.3180391e-18 0.775065 -0.22136512
		 -0.3456203 -1.45580912 0.0093534142 -0.37477556 -1.44867373 -0.075288601 -0.44365826 -1.43947184 -0.12759624
		 -0.60105282 -1.4168427 -0.077622309 -0.64547861 -1.41372454 0.0086553264 -0.61184877 -1.42588401 0.09598504
		 -0.38427839 -1.45761895 0.10049652 0.88017863 0.93604755 0.083230712 0.90422612 0.95028853 0.021011243
		 0.89243877 0.93862671 -0.042779539 0.85635811 0.89949095 -0.092681393 0.80356997 0.85440469 -0.10162932
		 0.76031017 0.81625623 -0.058859654 0.73861229 0.79609483 0.020087741 0.75070214 0.80914676 0.082422405
		 0.78652614 0.84343094 0.12595657 0.83684218 0.89195281 0.12306529 -0.83684218 0.89195281 0.12306529
		 -0.78652614 0.84343094 0.12595657 -0.75070214 0.80914676 0.082422405 -0.73861229 0.79609483 0.020087743
		 -0.76031017 0.81625623 -0.058859617 -0.80356997 0.85440463 -0.10162932 -0.85635811 0.89949095 -0.092681393
		 -0.89243877 0.93862665 -0.042779535 -0.90422612 0.95028853 0.021011239 -0.88017863 0.93604755 0.083230712
		 0.42944825 0.89299744 0.16251089 0.43399495 0.88177788 0.030036567 0.37736383 0.87885916 -0.087314054
		 0.26895478 0.88000417 -0.17232279 0.13929649 0.88043797 -0.22031917 2.1684043e-19 0.88153273 -0.23718996
		 -0.13929649 0.88043797 -0.22031917 -0.26895478 0.88000417 -0.17232279 -0.37736383 0.87885916 -0.087314054
		 -0.43399495 0.88177788 0.030036567 -0.42944825 0.89299744 0.16251089;
	setAttr ".vt[1162:1327]" -0.36272311 0.90357119 0.27261758 -0.25525013 0.91303748 0.35074955
		 -0.13098715 0.9192881 0.39281893 -1.3552527e-20 0.9236359 0.40744728 0.13098715 0.9192881 0.39281893
		 0.25525013 0.91303748 0.35074955 0.36272311 0.90357119 0.27261758 0.38748851 -1.58498883 -0.1008754
		 0.35593438 -1.59594476 -0.0080934409 0.40375352 -1.60331333 0.073636696 0.6309424 -1.57749951 0.074494272
		 0.67260897 -1.56070542 -0.015250751 0.63144171 -1.55505252 -0.10251298 0.46328032 -1.57107544 -0.1577556
		 -0.35593438 -1.59594476 -0.0080934409 -0.38748854 -1.58498883 -0.10087539 -0.46328032 -1.57107544 -0.1577556
		 -0.63144171 -1.55505252 -0.10251298 -0.67260897 -1.56070542 -0.015250751 -0.6309424 -1.57749951 0.074494272
		 -0.40375352 -1.60331333 0.073636696 0.27136698 -0.32693011 0.30487317 0.30023146 -0.51683867 0.30018237
		 0.33023328 -0.73046517 0.28904298 0.36591867 -0.93972003 0.26417986 0.39964667 -1.13944423 0.2293871
		 0.42890817 -1.31638002 0.19261709 0.45167041 -1.45663333 0.16201653 0.47300822 -1.60297596 0.13167514
		 0.50328815 -1.80345857 0.092669629 0.53790385 -2.02384901 0.057815887 0.56817192 -2.23947573 0.032452323
		 0.59490144 -2.44748569 0.017402772 0.60832554 -2.62469244 0.025466839 0.62128633 -2.74424601 0.055230528
		 0.61595213 -2.79111457 0.11869919 0.63542569 -2.84025955 0.29648229 0.64932722 -2.88637471 0.38862693
		 0.65145767 -2.93275976 0.4447383 0.65374833 -2.99368405 0.46255133 0.36019233 -0.082376309 0.28805625
		 0.39375931 -0.26027256 0.29482484 0.42279136 -0.47553912 0.29233193 0.4488655 -0.70155978 0.2814295
		 0.4739736 -0.91770893 0.26265782 0.49709302 -1.12307787 0.2321966 0.51905161 -1.30442417 0.19793159
		 0.53913951 -1.44579113 0.17063133 0.55730671 -1.59208047 0.14015946 0.58601171 -1.79477084 0.099927008
		 0.6091848 -2.014304638 0.066832714 0.62950289 -2.23538494 0.040849715 0.64751178 -2.44381094 0.024373412
		 0.66469508 -2.62222743 0.027594917 0.68764639 -2.74424577 0.055470169 0.70911908 -2.78474736 0.11356461
		 0.72564632 -2.84075427 0.29094732 0.73003834 -2.88624096 0.37679479 0.73200935 -2.93275976 0.43027362
		 0.74158818 -2.99368405 0.44919264 -0.27136698 -0.32693011 0.30487317 -0.30023146 -0.51683867 0.30018237
		 -0.33023328 -0.73046517 0.28904298 -0.36591867 -0.93972003 0.26417986 -0.39964667 -1.13944423 0.2293871
		 -0.42890817 -1.31638002 0.19261709 -0.45167041 -1.45663333 0.16201653 -0.47300822 -1.60297596 0.13167514
		 -0.50328815 -1.80345857 0.092669629 -0.53790385 -2.02384901 0.057815887 -0.56817192 -2.23947573 0.032452323
		 -0.59490144 -2.44748569 0.017402772 -0.60832554 -2.62469244 0.025466839 -0.62128633 -2.74424601 0.055230528
		 -0.61595213 -2.79111457 0.11869919 -0.63542569 -2.84025955 0.29648229 -0.64932722 -2.88637471 0.38862693
		 -0.65145767 -2.93275976 0.4447383 -0.65374833 -2.99368405 0.46255133 -0.36019233 -0.082376309 0.28805625
		 -0.39375931 -0.26027256 0.29482484 -0.42279133 -0.47553915 0.29233196 -0.4488655 -0.70155978 0.2814295
		 -0.4739736 -0.91770893 0.26265782 -0.49709302 -1.12307787 0.2321966 -0.51905161 -1.30442417 0.19793159
		 -0.53913951 -1.44579113 0.17063133 -0.55730671 -1.59208047 0.14015946 -0.58601171 -1.79477084 0.099927008
		 -0.6091848 -2.014304638 0.066832714 -0.62950289 -2.23538494 0.040849715 -0.64751178 -2.44381094 0.024373412
		 -0.66469508 -2.62222743 0.027594917 -0.68764639 -2.74424577 0.055470169 -0.70911908 -2.78474736 0.11356461
		 -0.72564632 -2.84075427 0.29094732 -0.73003834 -2.88624096 0.37679479 -0.73200935 -2.93275976 0.43027362
		 -0.74158818 -2.99368405 0.44919264 0.66912305 -2.99368405 -0.20733316 0.66770834 -2.92092681 -0.2074587
		 0.66627347 -2.84100294 -0.20818792 0.66493297 -2.75175166 -0.20720267 0.65666354 -2.62132335 -0.19528612
		 0.64376402 -2.44312334 -0.19350478 0.63069803 -2.23006654 -0.20425873 0.60986745 -2.0041103363 -0.20479822
		 0.58419102 -1.76842332 -0.19711347 0.55572546 -1.56217468 -0.16448985 0.53144741 -1.42717969 -0.13576743
		 0.51122004 -1.2920624 -0.12214427 0.47992393 -1.10550869 -0.11167463 0.44965979 -0.90098959 -0.10714586
		 0.41959867 -0.69083667 -0.11177398 0.38196048 -0.47200599 -0.13185418 0.3432287 -0.25357822 -0.16993064
		 -0.3432287 -0.25357822 -0.16993067 -0.38196048 -0.47200599 -0.13185418 -0.41959867 -0.69083667 -0.11177398
		 -0.44965979 -0.90098959 -0.10714586 -0.47992396 -1.10550821 -0.11167463 -0.51122004 -1.2920624 -0.12214427
		 -0.53144741 -1.42717969 -0.13576743 -0.55572546 -1.56217468 -0.16448985 -0.58419102 -1.76842332 -0.19711347
		 -0.60986745 -2.0041103363 -0.20479822 -0.63069797 -2.23006558 -0.20425873 -0.64376402 -2.44312239 -0.19350478
		 -0.65666354 -2.62132335 -0.19528612 -0.66493297 -2.75175166 -0.20720267 -0.66627347 -2.84100294 -0.20818792
		 -0.66770834 -2.92092681 -0.2074587 -0.66912299 -2.99368405 -0.20733316 0.81043458 -2.93422461 0.26039082
		 0.81946081 -2.99368405 0.2614685 0.55359471 -2.99368405 0.31096664 0.55780995 -2.93651652 0.30393827
		 -0.81043458 -2.93422461 0.26039082 -0.81946081 -2.99368405 0.2614685 -0.55359471 -2.99368405 0.31096664
		 -0.55780995 -2.93651652 0.30393827 0.13614292 -0.25480601 0.24721564 0.070230417 -0.25662249 0.24397837
		 -2.005774e-18 -0.25595909 0.24557635 -0.070230417 -0.25662249 0.24397837 -0.13614292 -0.25480601 0.24721564
		 0.41542184 1.084590793 -0.1018787 0.47085714 1.076923609 0.019193202 0.45757759 1.089954138 0.1491701
		 0.37907037 1.11493087 0.26191458 0.26430082 1.13447201 0.33331963 0.13455303 1.14620495 0.37122303
		 1.2691942e-17 1.14975333 0.38200134 -0.13455303 1.14620495 0.37122303 -0.26430082 1.13447201 0.33331963
		 -0.37907037 1.11493087 0.26191458 -0.45757759 1.089954138 0.1491701 -0.47085714 1.076923609 0.019193202
		 -0.41542184 1.084590793 -0.1018787 -0.29601127 1.093414903 -0.19189312 -0.15181325 1.10042179 -0.23802683
		 0 1.10289359 -0.25642222 0.15181325 1.10042179 -0.23802683 0.29601127 1.093414903 -0.19189312
		 0.78178316 -2.84976125 0.16255435 0.79556483 -2.93017364 0.14802478;
	setAttr ".vt[1328:1357]" 0.80115211 -2.99368429 0.14808597 0.55906713 -2.99368429 0.18664366
		 0.55682123 -2.93271637 0.18231787 0.57211423 -2.86022282 0.18565078 0.62456357 -2.81619096 0.20795162
		 0.71584487 -2.80952215 0.19880675 -0.78178316 -2.84976125 0.16255435 -0.79556483 -2.93017364 0.14802478
		 -0.80115211 -2.99368429 0.14808597 -0.55906713 -2.99368429 0.18664366 -0.55682123 -2.93271637 0.18231788
		 -0.57211423 -2.86022282 0.18565078 -0.62456357 -2.81619096 0.20795162 -0.71584487 -2.80952215 0.19880675
		 0.091488034 1.53738296 0.18544337 -2.981556e-19 1.53596401 0.1994579 -0.091488034 1.53738296 0.18544337
		 -0.18392032 1.56015098 0.14557667 -0.23329531 1.60115719 0.085151911 -0.25944775 1.64306056 0.011899609
		 -0.2345292 1.66225588 -0.063209571 -0.18231979 1.65501082 -0.11610811 -0.098144472 1.64957905 -0.14686769
		 -2.0322014e-17 1.64725125 -0.15700336 0.098144472 1.64957905 -0.14686769 0.18231979 1.65501082 -0.11610811
		 0.2345292 1.66225588 -0.063209571 0.25944775 1.64306056 0.011899609 0.23329531 1.60115719 0.085151911
		 0.18392032 1.56015098 0.14557667;
	setAttr -s 2719 ".ed";
	setAttr ".ed[0:165]"  0 3 0 2 1 0 0 4 0 5 12 0 1 5 0 4 6 0 6 7 0 7 8 0 8 5 0
		 9 7 0 10 4 0 11 6 0 10 11 0 12 13 0 8 13 0 9 11 0 9 13 0 3 10 0 2 12 0 0 14 0 15 22 0
		 1 15 0 14 16 0 16 17 0 17 18 0 18 15 0 19 17 0 20 14 0 21 16 0 20 21 0 22 23 0 18 23 0
		 19 21 0 19 23 0 3 20 0 2 22 0 1 25 0 25 326 0 28 27 0 30 29 0 27 32 0 29 306 0 32 315 0
		 24 28 0 33 24 0 31 292 0 34 0 0 42 138 0 36 149 0 35 146 0 37 38 0 40 39 0 161 40 0
		 35 41 0 38 157 0 33 161 0 39 37 0 44 48 0 46 44 0 47 46 0 46 45 0 49 45 0 47 52 0
		 52 51 0 45 119 0 49 118 0 51 48 0 52 44 0 4 96 0 54 55 0 57 55 0 54 56 0 56 57 0
		 56 283 0 53 58 0 59 88 0 60 282 0 56 60 0 54 61 0 61 60 0 7 65 0 66 65 0 8 66 0 67 66 0
		 5 67 0 25 67 0 68 325 0 26 68 0 69 70 0 65 309 0 70 71 0 71 322 0 59 90 0 60 91 0
		 104 73 0 73 74 0 74 93 0 27 74 0 73 28 0 29 75 0 75 76 0 76 30 0 76 314 0 31 77 0
		 78 75 0 77 79 0 80 76 0 78 80 0 81 80 0 82 81 0 79 82 0 6 97 0 83 74 0 32 83 0 83 94 0
		 7 98 0 55 84 0 117 286 0 103 53 0 64 62 0 72 62 0 72 85 0 85 49 0 115 61 0 86 87 0
		 87 115 0 63 115 0 88 24 0 88 73 0 33 89 0 89 88 0 90 86 0 89 90 0 90 281 0 61 91 0
		 92 287 0 93 53 0 104 93 0 93 94 0 94 313 0 92 94 0 65 99 0 95 72 0 64 95 0 95 323 0
		 96 291 0 97 290 0 98 289 0 34 96 0 96 97 0 97 98 0 98 99 0 81 288 0 81 312 0 64 310 0
		 78 82 0 75 305 0 121 142 0 102 101 0 101 141 0 101 135 0 100 144 0 100 132 0 70 152 0
		 68 69 0 58 284 0;
	setAttr ".ed[166:331]" 58 104 0 104 59 0 105 106 0 106 128 0 105 107 0 107 108 0
		 108 106 0 109 110 0 110 162 0 162 113 0 137 111 0 105 137 0 46 112 0 109 112 0 110 137 0
		 162 131 0 45 163 0 113 109 0 112 163 0 87 162 0 63 163 0 100 114 0 106 160 0 44 155 0
		 116 54 0 116 84 0 117 93 0 92 117 0 117 103 0 116 64 0 54 62 0 85 63 0 48 50 0 118 51 0
		 119 52 0 118 119 0 119 47 0 51 147 0 50 147 0 84 285 0 78 304 0 89 24 0 42 124 0
		 120 121 0 121 133 0 122 125 0 123 36 0 123 139 0 124 134 0 126 100 0 127 114 0 128 38 0
		 129 105 0 130 110 0 125 145 0 126 127 0 127 158 0 128 129 0 129 136 0 136 130 0 130 131 0
		 132 102 0 133 122 0 132 143 0 68 150 0 71 153 0 132 154 0 134 120 0 135 123 0 134 140 0
		 69 151 0 33 86 0 40 130 0 37 129 0 41 127 0 35 126 0 125 43 0 107 112 0 111 107 0
		 39 136 0 136 137 0 109 111 0 114 156 0 62 63 0 138 36 0 139 124 0 140 135 0 141 120 0
		 142 102 0 143 133 0 144 122 0 145 126 0 146 43 0 138 139 0 139 140 0 140 141 0 141 142 0
		 142 143 0 143 144 0 144 145 0 145 146 0 147 332 0 71 50 0 148 112 0 108 148 0 44 148 0
		 149 26 0 150 123 0 151 135 0 152 101 0 153 102 0 154 50 0 149 150 0 150 151 0 151 152 0
		 152 153 0 153 154 0 155 100 0 156 148 0 155 156 0 154 155 0 48 155 0 108 159 0 157 41 0
		 158 128 0 157 158 0 159 156 0 160 114 0 159 160 0 158 160 0 61 62 0 50 331 0 131 86 0
		 113 115 0 161 131 0 113 163 0 163 164 0 164 85 0 49 164 0 165 169 0 167 165 0 168 167 0
		 167 166 0 170 166 0 168 173 0 173 172 0 166 240 0 171 334 0 170 239 0 172 169 0 173 165 0
		 14 217 0 175 176 0 178 176 0 175 177 0 177 178 0 177 301 0 174 179 0 180 209 0 181 302 0
		 177 181 0 175 182 0 182 181 0 17 186 0 187 186 0 18 187 0;
	setAttr ".ed[332:497]" 188 187 0 15 188 0 25 188 0 189 327 0 26 189 0 189 190 0
		 190 191 0 186 321 0 191 192 0 192 330 0 180 211 0 181 212 0 225 194 0 194 195 0 195 214 0
		 27 195 0 194 28 0 29 196 0 196 197 0 197 30 0 197 316 0 31 198 0 199 196 0 198 200 0
		 201 197 0 199 201 0 202 201 0 203 202 0 200 203 0 16 218 0 204 195 0 32 204 0 204 215 0
		 17 219 0 176 205 0 238 298 0 224 174 0 185 183 0 193 183 0 193 206 0 206 170 0 236 182 0
		 207 208 0 208 236 0 184 236 0 209 24 0 209 194 0 33 210 0 210 209 0 211 207 0 210 211 0
		 211 303 0 182 212 0 213 297 0 214 174 0 225 214 0 214 215 0 215 317 0 213 215 0 186 220 0
		 216 193 0 185 216 0 216 329 0 217 293 0 218 294 0 219 295 0 34 217 0 217 218 0 218 219 0
		 219 220 0 202 296 0 202 318 0 185 320 0 199 203 0 196 307 0 242 262 0 223 222 0 222 261 0
		 222 256 0 221 264 0 221 253 0 191 270 0 179 300 0 179 225 0 225 180 0 226 227 0 227 249 0
		 226 228 0 228 229 0 229 227 0 230 231 0 231 278 0 258 232 0 226 258 0 167 233 0 230 233 0
		 231 258 0 166 279 0 234 230 0 233 279 0 208 278 0 184 279 0 279 234 0 221 235 0 227 277 0
		 165 273 0 237 175 0 237 205 0 238 214 0 213 238 0 238 224 0 237 185 0 175 183 0 206 184 0
		 169 171 0 239 172 0 240 173 0 239 240 0 240 168 0 172 266 0 171 266 0 205 299 0 199 308 0
		 210 24 0 42 245 0 241 242 0 242 254 0 243 246 0 244 36 0 245 255 0 244 259 0 256 244 0
		 247 221 0 248 235 0 249 38 0 250 226 0 251 231 0 252 161 0 246 265 0 247 248 0 248 275 0
		 249 250 0 250 257 0 257 251 0 251 252 0 253 223 0 254 243 0 253 263 0 189 268 0 192 271 0
		 253 272 0 255 241 0 255 260 0 190 269 0 33 207 0 40 251 0 37 250 0 41 248 0 35 247 0
		 246 43 0 228 233 0 232 228 0 39 257 0 257 258 0 230 232 0 235 274 0;
	setAttr ".ed[498:663]" 183 184 0 279 280 0 259 245 0 260 256 0 261 241 0 262 223 0
		 263 254 0 264 243 0 265 247 0 138 259 0 259 260 0 260 261 0 261 262 0 262 263 0 263 264 0
		 264 265 0 265 146 0 266 333 0 192 171 0 267 233 0 229 267 0 165 267 0 268 244 0 269 256 0
		 270 222 0 271 223 0 272 171 0 149 268 0 268 269 0 269 270 0 270 271 0 271 272 0 273 221 0
		 274 267 0 273 274 0 272 273 0 169 273 0 229 276 0 275 249 0 157 275 0 276 274 0 277 235 0
		 276 277 0 275 277 0 182 183 0 252 207 0 234 236 0 252 278 0 278 234 0 280 206 0 170 280 0
		 281 91 0 282 59 0 283 104 0 284 57 0 285 103 0 286 116 0 287 64 0 288 99 0 289 82 0
		 290 79 0 291 77 0 292 34 0 293 198 0 294 200 0 295 203 0 296 220 0 297 185 0 298 237 0
		 299 224 0 300 178 0 301 225 0 302 180 0 303 212 0 281 282 0 282 283 0 283 284 0 285 286 0
		 286 287 0 287 311 0 288 289 0 289 290 0 290 291 0 291 292 0 292 293 0 293 294 0 294 295 0
		 295 296 0 296 319 0 297 298 0 298 299 0 300 301 0 301 302 0 302 303 0 87 281 0 208 303 0
		 304 79 0 305 77 0 306 31 0 307 198 0 308 200 0 304 305 0 305 306 0 306 307 0 307 308 0
		 87 91 0 208 212 0 309 95 0 310 99 0 311 288 0 312 92 0 313 80 0 314 83 0 315 30 0
		 316 204 0 317 201 0 318 213 0 319 297 0 320 220 0 321 216 0 309 310 0 310 311 0 311 312 0
		 312 313 0 313 314 0 314 315 0 315 316 0 316 317 0 317 318 0 318 319 0 319 320 0 320 321 0
		 322 72 0 323 70 0 324 69 0 325 67 0 326 26 0 327 188 0 328 190 0 329 191 0 330 193 0
		 322 323 0 323 324 0 324 325 0 325 326 0 326 327 0 327 328 0 328 329 0 329 330 0 309 324 0
		 321 328 0 66 324 0 187 328 0 331 85 0 331 49 0 332 118 0 331 332 0 333 239 0 334 170 0
		 334 206 0 333 334 0 322 331 0 330 334 0 363 739 0 739 358 0 358 384 0;
	setAttr ".ed[664:829]" 384 363 0 616 617 0 617 355 0 355 356 0 356 616 0 369 608 0
		 608 366 0 366 365 0 365 369 0 611 612 0 612 373 0 373 372 0 372 611 0 608 609 0 609 357 0
		 357 366 0 355 359 0 359 360 0 360 356 0 619 358 0 739 357 0 357 619 0 609 610 0 610 361 0
		 361 357 0 619 614 0 614 618 0 618 358 0 369 388 0 388 606 0 606 607 0 607 369 0 365 364 0
		 364 389 0 602 365 0 359 370 0 370 371 0 371 360 0 610 611 0 372 361 0 373 362 0 362 361 0
		 612 613 0 613 362 0 382 381 0 381 383 0 383 382 0 381 379 0 379 383 0 380 383 0 379 380 0
		 377 365 0 366 377 0 377 378 0 378 364 0 378 375 0 375 363 0 363 364 0 363 386 0 386 389 0
		 375 380 0 379 374 0 374 375 0 381 376 0 376 374 0 382 377 0 377 376 0 383 378 0 377 357 0
		 357 376 0 693 694 0 694 418 0 418 399 0 399 693 0 692 693 0 399 402 0 402 692 0 679 680 0
		 680 400 0 400 403 0 403 679 0 680 681 0 681 417 0 417 400 0 678 679 0 403 408 0 408 678 0
		 401 406 0 402 412 0 412 405 0 405 407 0 691 692 0 402 407 0 407 691 0 689 1131 0
		 690 591 0 591 1140 0 391 689 0 391 1140 0 591 592 0 592 1139 0 390 391 0 419 398 0
		 593 594 0 594 1137 0 392 397 0 397 1138 0 418 421 0 421 586 0 586 399 0 410 413 0
		 413 414 0 414 411 0 411 410 0 597 1134 0 676 1133 0 677 598 0 598 1132 0 395 676 0
		 595 596 0 596 1135 0 393 396 0 396 1136 0 594 595 0 396 392 0 592 593 0 397 390 0
		 409 415 0 415 416 0 416 404 0 404 409 0 409 411 0 414 415 0 410 405 0 412 413 0 585 586 0
		 421 422 0 422 585 0 584 585 0 422 423 0 423 584 0 583 584 0 423 424 0 424 583 0 582 583 0
		 424 420 0 420 582 0 557 682 0 561 565 0 565 566 0 566 562 0 562 561 0 434 632 0 632 633 0
		 633 443 0 443 434 0 556 630 0 695 433 0 682 558 0 558 697 0 697 698 0 698 650 0 650 558 0
		 558 419 0 431 649 0 425 444 0;
	setAttr ".ed[830:995]" 444 442 0 442 426 0 426 425 0 432 445 0 445 645 0 645 646 0
		 646 432 0 429 444 0 444 445 0 432 429 0 563 440 0 440 439 0 439 434 0 434 563 0 562 443 0
		 443 428 0 428 561 0 124 1342 0 629 435 0 435 1357 0 433 435 0 436 683 0 683 1354 0
		 121 1355 0 430 429 0 429 437 0 437 441 0 441 430 0 438 437 0 432 438 0 439 631 0
		 631 632 0 646 647 0 647 438 0 726 661 0 661 727 0 727 659 0 659 726 0 566 567 0 567 563 0
		 563 562 0 633 634 0 634 428 0 430 442 0 644 645 0 445 427 0 427 644 0 425 427 0 620 448 0
		 671 672 0 672 458 0 458 385 0 385 671 0 461 605 0 605 606 0 388 461 0 622 623 0 623 447 0
		 447 449 0 623 624 0 624 599 0 599 447 0 459 460 0 460 389 0 601 602 0 462 463 0 738 387 0
		 387 462 0 684 685 0 685 459 0 459 386 0 386 684 0 674 675 0 675 621 0 621 450 0 450 674 0
		 451 625 0 625 626 0 626 603 0 603 451 0 687 688 0 688 622 0 622 449 0 449 687 0 673 674 0
		 450 453 0 453 673 0 686 687 0 449 454 0 454 686 0 447 455 0 455 454 0 599 600 0 600 455 0
		 603 604 0 604 456 0 456 451 0 448 452 0 685 686 0 454 459 0 455 460 0 600 601 0 604 605 0
		 461 456 0 452 463 0 672 673 0 453 458 0 704 1277 0 705 471 0 471 1276 0 470 704 0
		 425 475 0 475 476 0 476 427 0 467 469 0 469 638 0 638 639 0 639 467 0 469 1303 0
		 468 637 0 637 1304 0 473 636 0 636 637 0 476 643 0 643 644 0 472 474 0 474 640 0
		 640 641 0 588 589 0 589 475 0 475 477 0 477 588 0 634 635 0 635 478 0 478 428 0 560 561 0
		 478 560 0 559 473 0 639 640 0 464 472 0 589 590 0 590 476 0 642 643 0 590 642 0 426 477 0
		 635 636 0 473 478 0 560 564 0 564 565 0 559 560 0 724 718 0 718 1171 0 720 721 0
		 721 1174 0 723 724 0 719 720 0 487 490 0 490 497 0 497 498 0 498 487 0 486 577 0
		 577 578 0 500 486 0 508 580 0 580 581 0 482 508 0;
	setAttr ".ed[996:1161]" 504 505 0 505 480 0 480 479 0 479 504 0 485 1212 0 501 485 0
		 488 489 0 489 502 0 502 499 0 499 488 0 490 486 0 500 497 0 489 485 0 501 502 0 506 507 0
		 507 483 0 483 484 0 484 506 0 505 1215 0 503 504 0 479 481 0 481 503 0 507 508 0
		 482 483 0 497 496 0 496 495 0 495 498 0 578 579 0 494 500 0 492 501 0 502 493 0 493 491 0
		 491 499 0 494 496 0 492 493 0 724 1170 0 493 504 0 503 491 0 492 505 0 496 507 0
		 506 495 0 494 508 0 579 580 0 537 699 0 699 479 0 483 703 0 703 538 0 515 516 0 516 532 0
		 532 531 0 531 515 0 481 700 0 700 1263 0 701 581 0 581 1264 0 518 1261 0 534 533 0
		 533 1262 0 517 518 0 521 530 0 530 529 0 529 519 0 519 521 0 524 1326 0 537 1217 0
		 524 536 0 525 1295 0 525 528 0 528 1296 0 522 1329 0 527 526 0 526 1298 0 526 535 0
		 535 523 0 525 1220 0 482 702 0 702 703 0 523 1331 0 480 537 0 530 522 0 522 520 0
		 520 529 0 699 700 0 532 518 0 517 531 0 519 533 0 527 1201 0 522 516 0 538 484 0
		 551 543 0 543 1185 0 708 709 0 709 552 0 552 551 0 551 708 0 540 1205 0 546 540 0
		 543 544 0 544 550 0 550 549 0 549 543 0 706 707 0 707 553 0 553 554 0 554 706 0 710 704 0
		 555 710 0 705 706 0 554 471 0 709 710 0 555 552 0 713 714 0 714 657 0 657 658 0 658 713 0
		 539 541 0 541 547 0 547 545 0 545 539 0 544 542 0 542 548 0 548 550 0 541 540 0 546 547 0
		 542 574 0 574 575 0 717 711 0 711 653 0 653 654 0 654 717 0 714 715 0 715 656 0 656 657 0
		 711 712 0 712 652 0 652 653 0 715 716 0 716 655 0 549 1186 0 712 1207 0 540 553 0
		 553 1204 0 552 544 0 541 554 0 542 555 0 470 574 0 539 471 0 658 1188 0 718 1191 0
		 498 1193 0 495 1194 0 506 1195 0 484 1196 0 538 1197 0 523 1198 0 535 1199 0 659 660 0
		 660 725 0 725 726 0 694 695 0 433 418 0 681 682 0 557 417 0 707 1203 0 587 564 0
		 567 568 0;
	setAttr ".ed[1162:1327]" 568 440 0 587 588 0 477 564 0 426 565 0 442 566 0 430 567 0
		 441 568 0 568 1151 0 570 569 0 569 1168 0 571 570 0 441 1152 0 437 1153 0 572 571 0
		 573 572 0 438 1154 0 647 1155 0 648 573 0 574 1275 0 545 1274 0 716 1273 0 654 1272 0
		 721 1269 0 577 1268 0 499 1267 0 491 1266 0 503 1265 0 424 1308 0 573 1325 0 648 1324 0
		 398 401 0 415 583 0 582 416 0 414 584 0 413 585 0 412 586 0 465 587 0 466 588 0 465 466 0
		 464 589 0 466 464 0 472 590 0 641 642 0 472 641 0 405 592 0 410 593 0 411 594 0 409 595 0
		 404 596 0 406 597 0 677 678 0 408 598 0 690 691 0 407 591 0 451 599 0 624 625 0 456 600 0
		 461 601 0 388 602 0 626 627 0 627 446 0 446 603 0 446 457 0 457 604 0 457 462 0 462 605 0
		 387 606 0 387 368 0 368 607 0 662 663 0 663 609 0 608 662 0 663 664 0 664 610 0 664 665 0
		 665 611 0 665 666 0 666 612 0 666 667 0 667 613 0 355 668 0 668 667 0 667 359 0 668 669 0
		 669 618 0 614 668 0 670 671 0 385 615 0 615 670 0 607 662 0 367 617 0 616 368 0 368 367 0
		 615 618 0 669 670 0 615 384 0 362 619 0 613 614 0 675 728 0 728 729 0 729 621 0 688 730 0
		 730 731 0 731 622 0 731 732 0 732 623 0 733 732 0 732 390 0 397 733 0 624 733 0 733 734 0
		 734 625 0 734 735 0 735 626 0 735 736 0 736 627 0 620 737 0 650 651 0 651 628 0 628 558 0
		 435 696 0 696 1356 0 42 1343 0 339 629 0 354 725 0 660 1118 0 1118 354 0 630 349 0
		 631 341 0 341 336 0 336 632 0 336 1119 0 1119 633 0 1119 335 0 335 634 0 335 347 0
		 347 635 0 347 1120 0 1120 636 0 1120 345 0 345 637 0 345 1305 0 1121 638 0 1121 344 0
		 344 639 0 346 640 0 344 346 0 346 343 0 352 642 0 641 343 0 343 352 0 348 643 0 352 348 0
		 348 1122 0 1122 644 0 342 645 0 1122 342 0 342 337 0 337 646 0 1123 647 0 337 1123 0
		 351 648 0 1123 1156 0 351 1323 0 338 649 0 698 353 0;
	setAttr ".ed[1328:1493]" 353 350 0 350 650 0 340 651 0 350 340 0 509 510 0 510 1169 0
		 510 576 0 576 1175 0 576 1271 0 511 512 0 512 1173 0 512 513 0 513 1172 0 513 1209 0
		 514 509 0 652 513 0 512 653 0 511 654 0 576 655 0 510 656 0 509 657 0 514 658 0 731 391 0
		 727 433 0 629 660 0 339 1118 0 570 1310 0 571 1309 0 616 662 0 356 663 0 360 664 0
		 371 665 0 370 666 0 617 669 0 367 670 0 738 671 0 463 738 0 452 673 0 672 463 0 448 674 0
		 620 675 0 676 728 0 728 737 0 737 394 0 394 676 0 597 677 0 406 678 0 401 679 0 398 680 0
		 419 681 0 683 628 0 628 1353 0 458 685 0 684 385 0 453 686 0 450 687 0 621 688 0
		 689 730 0 730 729 0 729 395 0 395 689 0 598 690 0 408 691 0 403 692 0 400 693 0 417 694 0
		 557 695 0 557 436 0 436 696 0 696 695 0 457 452 0 446 448 0 627 620 0 737 736 0 736 393 0
		 393 394 0 596 597 0 404 406 0 416 401 0 582 398 0 420 419 0 697 431 0 515 537 0 531 699 0
		 517 700 0 533 701 0 519 702 0 529 703 0 520 538 0 464 705 0 704 474 0 466 706 0 465 707 0
		 469 709 0 467 710 0 546 712 0 711 547 0 549 713 0 550 714 0 548 715 0 575 716 0 545 717 0
		 718 487 0 485 719 0 489 720 0 488 721 0 577 722 0 486 723 0 490 724 0 631 1166 0
		 349 1165 0 439 1167 0 569 556 0 630 1313 0 354 1314 0 556 1312 0 661 1311 0 431 424 0
		 340 1351 0 125 1352 0 682 683 0 392 734 0 396 735 0 374 739 0 367 738 0 684 384 0
		 740 743 0 743 742 0 742 741 0 741 740 0 744 747 0 747 746 0 746 745 0 745 744 0 748 751 0
		 751 750 0 750 749 0 749 748 0 752 755 0 755 754 0 754 753 0 753 752 0 750 757 0 757 756 0
		 756 749 0 747 759 0 759 758 0 758 746 0 742 760 0 760 757 0 757 741 0 757 762 0 762 761 0
		 761 756 0 742 764 0 764 763 0 763 760 0 748 767 0 767 766 0 766 765 0 765 748 0 751 770 0
		 770 769 0 769 768 0 759 772 0 772 771 0;
	setAttr ".ed[1494:1659]" 771 758 0 762 755 0 752 761 0 762 773 0 773 754 0 773 774 0
		 774 753 0 775 777 0 777 776 0 776 775 0 777 778 0 778 776 0 779 778 0 777 779 0 780 750 0
		 751 780 0 768 781 0 768 740 0 740 782 0 782 781 0 769 783 0 783 740 0 782 784 0 784 778 0
		 779 782 0 784 785 0 785 776 0 785 780 0 780 775 0 781 777 0 785 757 0 757 780 0 786 789 0
		 789 788 0 788 787 0 787 786 0 790 791 0 791 789 0 786 790 0 792 795 0 795 794 0 794 793 0
		 793 792 0 794 797 0 797 796 0 796 793 0 798 799 0 799 795 0 792 798 0 801 800 0 802 804 0
		 804 803 0 803 791 0 805 802 0 802 791 0 790 805 0 806 809 0 809 1141 0 808 807 0
		 807 1150 0 809 811 0 811 1142 0 810 808 0 813 812 0 814 1143 0 817 816 0 816 1144 0
		 815 814 0 789 819 0 819 818 0 820 823 0 823 822 0 822 821 0 821 820 0 825 1147 0
		 826 829 0 829 1149 0 828 827 0 827 1148 0 830 1145 0 833 832 0 832 1146 0 831 830 0
		 816 833 0 830 815 0 811 817 0 814 810 0 834 837 0 837 836 0 836 835 0 835 834 0 835 822 0
		 823 834 0 821 803 0 804 820 0 838 839 0 839 818 0 819 838 0 840 841 0 841 839 0 838 840 0
		 842 843 0 843 841 0 840 842 0 844 845 0 845 843 0 842 844 0 847 846 0 848 851 0 851 850 0
		 850 849 0 849 848 0 852 855 0 855 854 0 854 853 0 853 852 0 857 856 0 859 858 0 860 847 0
		 860 863 0 863 862 0 862 861 0 861 860 0 813 860 0 865 864 0 866 869 0 869 868 0 868 867 0
		 867 866 0 870 873 0 873 872 0 872 871 0 871 870 0 874 870 0 871 867 0 867 874 0 875 852 0
		 852 877 0 877 876 0 876 875 0 848 878 0 878 855 0 855 851 0 255 1345 0 880 879 0
		 879 1344 0 880 858 0 881 1347 0 254 1348 0 882 881 0 883 885 0 885 884 0 884 874 0
		 874 883 0 886 870 0 884 886 0 853 887 0 887 877 0 886 888 0 888 873 0 889 892 0 892 891 0
		 891 890 0 890 889 0 851 875 0 875 893 0;
	setAttr ".ed[1660:1825]" 893 850 0 878 894 0 894 854 0 868 883 0 895 896 0 896 871 0
		 872 895 0 896 866 0 898 897 0 899 902 0 902 901 0 901 900 0 900 899 0 903 765 0 766 904 0
		 904 903 0 905 908 0 908 907 0 907 906 0 906 905 0 908 910 0 910 909 0 909 907 0 769 912 0
		 912 911 0 911 783 0 770 913 0 913 912 0 914 917 0 917 916 0 916 915 0 915 914 0 918 783 0
		 911 919 0 919 918 0 920 923 0 923 922 0 922 921 0 921 920 0 924 927 0 927 926 0 926 925 0
		 925 924 0 928 905 0 906 929 0 929 928 0 930 931 0 931 923 0 920 930 0 932 933 0 928 932 0
		 933 934 0 934 908 0 905 933 0 935 910 0 924 937 0 937 936 0 936 927 0 897 938 0 911 933 0
		 932 919 0 912 934 0 913 935 0 937 903 0 904 936 0 938 915 0 901 931 0 930 900 0 939 942 0
		 942 1279 0 941 940 0 940 1278 0 896 944 0 944 943 0 943 866 0 945 948 0 948 947 0
		 947 946 0 946 945 0 947 1306 0 950 949 0 949 1307 0 950 952 0 952 951 0 895 953 0
		 953 944 0 957 956 0 956 955 0 955 954 0 954 957 0 958 960 0 960 943 0 943 959 0 959 958 0
		 878 962 0 962 961 0 961 894 0 963 962 0 848 963 0 945 957 0 944 966 0 966 959 0 967 966 0
		 953 967 0 960 869 0 962 951 0 952 961 0 849 968 0 968 963 0 963 964 0 970 969 0 972 971 0
		 971 1178 0 973 1250 0 975 974 0 969 972 0 974 973 0 976 979 0 979 978 0 978 977 0
		 977 976 0 980 983 0 983 982 0 982 981 0 984 987 0 987 986 0 986 985 0 988 991 0 991 990 0
		 990 989 0 989 988 0 992 993 0 993 1252 0 994 997 0 997 996 0 996 995 0 995 994 0
		 978 983 0 980 977 0 996 993 0 992 995 0 998 1001 0 1001 1000 0 1000 999 0 999 998 0
		 990 1255 0 1002 1003 0 1003 991 0 988 1002 0 1000 987 0 984 999 0 979 1005 0 1005 1004 0
		 1004 978 0 983 1007 0 1007 1006 0 1006 982 0 993 1008 0 1008 1253 0 997 1010 0 1010 1009 0
		 1009 996 0 1004 1007 0 1009 1008 0 972 1177 0 974 1180 0;
	setAttr ".ed[1826:1991]" 973 1181 0 1010 1002 0 988 1009 0 989 1008 0 1005 998 0
		 999 1004 0 984 1007 0 985 1006 0 991 1012 0 1012 1011 0 1011 990 0 1001 1014 0 1014 1013 0
		 1013 1000 0 1015 1018 0 1018 1017 0 1017 1016 0 1016 1015 0 1003 1291 0 986 1020 0
		 1020 1292 0 1019 1003 0 1021 1024 0 1024 1293 0 1023 1022 0 1022 1294 0 1025 1028 0
		 1028 1027 0 1027 1026 0 1026 1025 0 1011 1334 0 1029 1257 0 1015 1335 0 1031 1030 0
		 1030 1029 0 1016 1336 0 1032 1031 0 1033 1036 0 1036 1338 0 1035 1034 0 1034 1301 0
		 1038 1037 0 1032 1260 0 1013 1039 0 1039 987 0 1014 1339 0 1027 1036 0 1033 1026 0
		 1019 1012 0 1018 1024 0 1021 1017 0 1039 1020 0 1035 1239 0 1030 1258 0 1016 1033 0
		 1041 1040 0 1040 1223 0 1042 1040 0 1040 1044 0 1044 1043 0 1043 1042 0 1045 1046 0
		 1046 1245 0 1224 1244 0 1041 1049 0 1049 1048 0 1048 1047 0 1047 1041 0 1050 1053 0
		 1053 1052 0 1052 1051 0 1051 1050 0 1054 1055 0 1055 942 0 941 1053 0 1050 940 0
		 1044 1055 0 1054 1043 0 1056 1059 0 1059 1058 0 1058 1057 0 1057 1056 0 1060 1063 0
		 1063 1062 0 1062 1061 0 1061 1060 0 1048 1065 0 1065 1064 0 1064 1047 0 1062 1046 0
		 1045 1061 0 1065 1067 0 1067 1066 0 1068 1071 0 1071 1070 0 1070 1069 0 1069 1068 0
		 1058 1073 0 1073 1072 0 1072 1057 0 1070 1075 0 1075 1074 0 1074 1069 0 1073 1077 0
		 1077 1076 0 1075 1247 0 1052 1045 0 1042 1222 0 1047 1044 0 1053 1061 0 1066 942 0
		 1055 1064 0 941 1060 0 1056 1226 0 976 1231 0 1254 1234 0 1256 1236 0 889 1079 0
		 1079 1078 0 1078 892 0 788 858 0 859 787 0 797 846 0 847 796 0 968 1080 0 1080 964 0
		 876 1081 0 1081 893 0 968 960 0 958 1080 0 849 869 0 850 868 0 893 883 0 1081 885 0
		 876 1162 0 1083 1082 0 1082 1161 0 1084 1160 0 1082 1084 0 1084 1085 0 1085 1159 0
		 1086 1158 0 1085 1086 0 1086 1087 0 1087 1157 0 1067 1281 0 1060 1280 0 1077 1283 0
		 1068 1282 0 971 1286 0 982 1288 0 994 1287 0 1006 1289 0 985 1290 0 864 1321 0 1085 1320 0
		 865 1322 0 812 801 0 836 844 0 842 835 0 840 822 0 838 821 0 819 803 0 1080 1088 0
		 1088 1241 0 1089 1088 0;
	setAttr ".ed[1992:2157]" 958 1089 0 965 1089 0 959 965 0 966 956 0 967 955 0
		 810 804 0 802 808 0 814 820 0 815 823 0 830 834 0 831 837 0 800 825 0 828 799 0 798 827 0
		 805 807 0 925 909 0 910 924 0 935 937 0 913 903 0 770 765 0 927 1091 0 1091 1090 0
		 1090 926 0 936 1092 0 1092 1091 0 904 914 0 914 1092 0 766 917 0 767 1093 0 1093 917 0
		 1094 749 0 756 1095 0 1095 1094 0 761 1096 0 1096 1095 0 752 1097 0 1097 1096 0 753 1098 0
		 1098 1097 0 774 1099 0 1099 1098 0 758 1099 0 1099 1100 0 1100 746 0 1100 763 0 764 1101 0
		 1101 1100 0 1102 1103 0 1103 902 0 899 1102 0 1094 767 0 1104 1093 0 1093 744 0 745 1104 0
		 1102 1101 0 764 1103 0 743 1103 0 760 773 0 763 774 0 922 1106 0 1106 1105 0 1105 921 0
		 906 1108 0 1108 1107 0 1107 929 0 907 1109 0 1109 1108 0 811 1109 0 1109 1110 0 1110 817 0
		 925 1111 0 1111 1110 0 1110 909 0 926 1112 0 1112 1111 0 1113 1112 0 1090 1113 0
		 1114 898 0 860 1116 0 1116 1115 0 1115 863 0 241 1346 0 1117 880 0 879 339 0 1118 1078 0
		 1079 354 0 349 857 0 853 336 0 341 887 0 854 1119 0 894 335 0 961 347 0 952 1120 0
		 950 345 0 947 1121 0 948 344 0 954 346 0 343 955 0 967 352 0 953 348 0 895 1122 0
		 872 342 0 873 337 0 888 1123 0 1087 351 0 865 338 0 863 350 0 353 862 0 1115 340 0
		 1124 1176 0 1125 1124 0 1179 1127 0 1127 1284 0 1128 1127 0 1129 1128 0 1182 1130 0
		 1130 1228 0 1124 1130 0 1070 1128 0 1129 1075 0 1071 1127 0 1077 1126 0 1073 1125 0
		 1058 1124 0 1059 1130 0 809 1108 0 818 788 0 858 891 0 1078 879 0 839 1318 0 841 1319 0
		 1094 744 0 1095 747 0 1096 759 0 1097 772 0 1098 771 0 1101 745 0 1102 1104 0 899 916 0
		 916 1104 0 915 900 0 930 938 0 920 897 0 921 898 0 1114 1105 0 1105 826 0 826 824 0
		 827 825 0 798 800 0 792 801 0 793 812 0 796 813 0 243 1349 0 1116 882 0 902 918 0
		 919 901 0 932 931 0 928 923 0 929 922 0 1106 1107 0 1107 806 0 806 829 0 829 1106 0
		 807 828 0 805 799 0 790 795 0;
	setAttr ".ed[2158:2323]" 786 794 0 787 797 0 859 846 0 881 846 0 859 1117 0 1117 881 0
		 938 1092 0 897 1091 0 898 1090 0 1113 1114 0 1114 824 0 824 832 0 832 1113 0 825 831 0
		 800 837 0 801 836 0 812 844 0 813 845 0 862 865 0 1011 1015 0 1012 1018 0 1019 1024 0
		 1020 1023 0 1039 1028 0 1013 1027 0 1014 1036 0 957 939 0 940 965 0 1050 1089 0 1051 1088 0
		 1043 946 0 1054 945 0 1062 1069 0 1074 1046 0 1056 1049 0 1057 1048 0 1072 1065 0
		 1076 1067 0 1068 1063 0 976 970 0 973 992 0 974 995 0 975 994 0 971 981 0 972 980 0
		 969 977 0 857 1164 0 856 1163 0 856 1083 0 1079 1315 0 889 1316 0 843 864 0 1083 1317 0
		 1115 1350 0 882 847 0 1111 816 0 1112 833 0 741 784 0 743 918 0 1131 690 0 1132 395 0
		 1133 677 0 1134 394 0 1135 393 0 1136 595 0 1137 392 0 1138 593 0 1139 390 0 1131 1132 0
		 1132 1133 0 1133 1134 0 1134 1135 0 1135 1136 0 1136 1137 0 1137 1138 0 1138 1139 0
		 1139 1140 0 1140 1131 0 1141 808 0 1142 810 0 1143 817 0 1144 815 0 1145 833 0 1146 831 0
		 1147 824 0 1148 826 0 1149 828 0 1150 806 0 1141 1142 0 1142 1143 0 1143 1144 0 1144 1145 0
		 1145 1146 0 1146 1147 0 1147 1148 0 1148 1149 0 1149 1150 0 1150 1141 0 1151 570 0
		 1152 571 0 1153 572 0 1154 573 0 1155 648 0 1156 351 0 1157 888 0 1158 886 0 1159 884 0
		 1160 885 0 1161 1081 0 1162 1083 0 1163 877 0 1164 887 0 1165 341 0 1166 630 0 1167 556 0
		 1168 440 0 1151 1152 1 1152 1153 1 1153 1154 1 1154 1155 1 1155 1156 1 1156 1157 1
		 1157 1158 1 1158 1159 1 1159 1160 1 1160 1161 1 1161 1162 1 1162 1163 1 1163 1164 1
		 1164 1165 1 1165 1166 1 1166 1167 1 1167 1168 1 1168 1151 1 536 525 0 1037 1035 0
		 1169 723 0 1170 509 0 1171 514 0 1172 719 0 1173 720 0 1174 511 0 1175 722 0 1169 1170 1
		 1170 1171 1 1171 1190 1 1172 1173 1 1173 1174 1 1174 1270 1 1176 969 0 1177 1125 0
		 1178 1126 0 1179 975 0 1180 1128 0 1181 1129 0 1182 970 0 1176 1177 1 1177 1178 1
		 1178 1285 1 1179 1180 1 1180 1181 1 1181 1249 1 1182 1176 1 420 697 1 845 861 1 460 601 0;
	setAttr ".ed[2324:2489]" 389 602 0 468 1202 0 1183 708 0 1184 551 0 1186 1206 0
		 1187 713 0 1188 1208 0 1189 514 0 1190 1210 1 1191 1211 0 1192 487 0 1193 1213 0
		 1194 1214 0 1196 1216 0 1198 1218 0 1199 1219 0 1200 526 0 1201 1221 0 473 468 1
		 1183 1184 1 1184 1185 1 1185 1186 1 1186 1187 1 1187 1188 1 1188 1189 1 1189 1190 1
		 1190 1191 1 1191 1192 1 1192 1193 1 1193 1194 1 1194 1195 1 1195 1196 1 1196 1197 1
		 1197 1332 1 1198 1199 1 1199 1200 1 1200 1201 1 559 587 0 1202 465 0 1203 1183 0
		 1204 1184 0 1205 1185 0 1206 546 0 1207 1187 0 1208 652 0 1209 1189 0 1210 1172 1
		 1211 719 0 1212 1192 0 1213 501 0 1214 492 0 1215 1195 0 1216 480 0 1217 1197 0 1218 524 0
		 1219 536 0 1220 1200 0 1221 528 0 559 1202 1 1202 1203 1 1203 1204 1 1204 1205 1
		 1205 1206 1 1206 1207 1 1207 1208 1 1208 1209 1 1209 1210 1 1210 1211 1 1211 1212 1
		 1212 1213 1 1213 1214 1 1214 1215 1 1215 1216 1 1216 1217 1 1217 1333 1 1218 1219 1
		 1219 1220 1 1220 1221 1 781 780 0 768 751 0 934 935 0 951 964 0 1222 1242 0 1223 1243 0
		 1224 1041 0 1225 1049 0 1226 1246 0 1227 1059 0 1228 1248 0 1229 1182 1 1230 970 0
		 1231 1251 0 1232 979 0 1233 1005 0 1234 998 0 1235 1001 0 1236 1014 0 1237 1038 0
		 1238 1037 0 1239 1259 0 1240 1034 0 951 949 1 1222 1223 1 1223 1224 1 1224 1225 1
		 1225 1226 1 1226 1227 1 1227 1228 1 1228 1229 1 1229 1230 1 1230 1231 1 1231 1232 1
		 1232 1233 1 1233 1234 1 1234 1235 1 1235 1236 1 1236 1340 1 1237 1238 1 1238 1239 1
		 1239 1240 1 1241 949 0 1242 1051 0 1243 1052 0 1244 1045 0 1245 1225 0 1246 1074 0
		 1247 1227 0 1248 1129 0 1249 1229 1 1250 1230 0 1251 992 0 1252 1232 0 1253 1233 0
		 1254 989 0 1255 1235 0 1256 1011 0 1257 1237 0 1258 1238 0 1259 1031 0 1260 1240 0
		 964 1241 1 1241 1242 1 1242 1243 1 1243 1244 1 1244 1245 1 1245 1246 1 1246 1247 1
		 1247 1248 1 1248 1249 1 1249 1250 1 1250 1251 1 1251 1252 1 1252 1253 1 1253 1254 1
		 1254 1255 1 1255 1256 1 1256 1341 1 1257 1258 1 1258 1259 1 1259 1260 1 530 532 1
		 1026 1017 1 1261 534 0 1262 517 0 1263 701 0 1264 481 0;
	setAttr ".ed[2490:2655]" 1265 580 0 1266 579 0 1267 578 0 1268 488 0 1269 722 0
		 1270 1175 1 1271 511 0 1272 655 0 1273 717 0 1274 575 0 1275 539 0 1276 470 0 1277 705 0
		 1261 1262 1 1262 1263 1 1263 1264 1 1264 1265 1 1265 1266 1 1266 1267 1 1267 1268 1
		 1268 1269 1 1269 1270 1 1270 1271 1 1271 1272 1 1272 1273 1 1273 1274 1 1274 1275 1
		 1275 1276 1 1276 1277 1 1277 472 1 534 521 0 701 702 0 581 482 0 579 494 0 578 500 0
		 722 723 0 1175 1169 1 655 656 0 575 548 0 470 555 0 474 467 0 954 948 0 939 1054 0
		 1066 1064 0 1076 1072 0 1126 1125 0 981 980 0 985 984 0 1023 1028 0 1025 1022 0 956 965 0
		 1278 939 0 1279 941 0 1280 1066 0 1281 1063 0 1282 1076 0 1283 1071 0 1284 1126 0
		 1285 1179 1 1286 975 0 1287 981 0 1288 997 0 1289 1010 0 1290 1002 0 1291 986 0 1292 1019 0
		 1293 1023 0 1294 1021 0 956 1278 1 1278 1279 1 1279 1280 1 1280 1281 1 1281 1282 1
		 1282 1283 1 1283 1284 1 1284 1285 1 1285 1286 1 1286 1287 1 1287 1288 1 1288 1289 1
		 1289 1290 1 1290 1291 1 1291 1292 1 1292 1293 1 1293 1294 1 518 521 1 1021 1025 1
		 527 528 1 1032 1034 1 1295 1327 0 1296 1328 0 1297 527 0 1298 1330 0 1295 1296 1
		 1296 1297 1 1297 1298 1 1299 1031 0 1300 1032 0 1301 1337 0 1302 1035 0 1299 1300 1
		 1300 1301 1 1301 1302 1 1303 468 0 1304 638 0 1305 1121 0 1306 950 0 1307 946 0 1303 1304 1
		 1304 1305 1 1305 1306 1 1306 1307 1 708 1303 1 1042 1307 1 468 1183 1 949 1222 1
		 421 727 1 818 891 1 661 422 1 890 839 1 649 698 0 338 353 0 864 861 0 659 435 1 892 880 1
		 1308 572 0 1309 423 0 1310 422 0 1311 569 0 1312 726 0 1313 725 0 1314 349 0 1315 857 0
		 1316 856 0 1317 890 0 1318 1082 0 1319 1084 0 1320 843 0 1321 1086 0 1322 1087 0
		 1323 338 0 1324 649 0 1325 431 0 1308 1309 1 1309 1310 1 1310 1311 1 1311 1312 1
		 1312 1313 1 1313 1314 1 1314 1315 1 1315 1316 1 1316 1317 1 1317 1318 1 1318 1319 1
		 1319 1320 1 1320 1321 1 1321 1322 1 1322 1323 1 1323 1324 1 1324 1325 1 1325 1308 1
		 524 1295 1 1029 1299 1 523 1298 1 1038 1302 1 1326 537 0;
	setAttr ".ed[2656:2718]" 1327 515 0 1328 516 0 1329 1297 0 1330 520 0 1331 538 0
		 1332 1198 1 1333 1218 1 1326 1327 1 1327 1328 1 1328 1329 1 1329 1330 1 1330 1331 1
		 1331 1332 1 1332 1333 1 1333 1326 1 1334 1029 0 1335 1299 0 1336 1300 0 1337 1033 0
		 1338 1302 0 1339 1038 0 1340 1237 1 1341 1257 1 1334 1335 1 1335 1336 1 1336 1337 1
		 1337 1338 1 1338 1339 1 1339 1340 1 1340 1341 1 1341 1334 1 1342 629 0 1343 339 0
		 1344 245 0 1345 880 0 1346 1117 0 1347 242 0 1348 882 0 1349 1116 0 1350 246 0 1351 43 0
		 1352 651 0 1353 122 0 1354 133 0 1355 436 0 1356 120 0 1357 134 0 1342 1343 1 1343 1344 1
		 1344 1345 1 1345 1346 1 1346 1347 1 1347 1348 1 1348 1349 1 1349 1350 1 1350 1351 1
		 1351 1352 1 1352 1353 1 1353 1354 1 1354 1355 1 1355 1356 1 1356 1357 1 1357 1342 1;
	setAttr -s 1360 -ch 5410 ".fc";
	setAttr ".fc[0:499]" -type "polyFaces" 
		f 4 17 10 -3 0
		mu 0 4 9 11 1 15
		mc 0 4 0 1 2 3
		f 4 -6 -11 12 11
		mu 0 4 4 1 11 8
		mc 0 4 4 5 6 7
		f 4 16 -15 -8 -10
		mu 0 4 6 7 2 3
		mc 0 4 8 9 10 11
		f 4 14 -14 -4 -9
		mu 0 4 2 7 10 0
		mc 0 4 12 13 14 15
		f 4 9 -7 -12 -16
		mu 0 4 6 3 4 8
		mc 0 4 16 17 18 19
		f 4 1 4 3 -19
		mu 0 4 5 19 0 10
		mc 0 4 20 21 15 14
		f 4 -1 19 -28 -35
		mu 0 4 9 15 12 22
		mc 0 4 22 25 24 23
		f 4 -29 -30 27 22
		mu 0 4 16 20 22 12
		mc 0 4 26 29 28 27
		f 4 26 24 31 -34
		mu 0 4 14 17 18 21
		mc 0 4 30 33 32 31
		f 4 25 20 30 -32
		mu 0 4 18 13 23 21
		mc 0 4 34 37 36 35
		f 4 32 28 23 -27
		mu 0 4 14 20 16 17
		mc 0 4 38 41 40 39
		f 4 35 -21 -22 -2
		mu 0 4 5 23 13 19
		mc 0 4 42 36 37 43
		f 4 223 218 168 169
		mu 0 4 24 25 26 27
		mc 0 4 345 347 44 45
		f 4 170 171 172 -169
		mu 0 4 26 28 29 27
		mc 0 4 47 48 49 50
		f 4 59 60 64 202
		mu 0 4 30 31 32 33
		mc 0 4 51 52 53 54
		f 4 175 183 173 174
		mu 0 4 34 35 36 37
		mc 0 4 55 56 57 58
		f 4 176 244 -171 177
		mu 0 4 38 39 28 26
		mc 0 4 386 388 59 60
		f 4 224 246 -178 -219
		mu 0 4 25 40 38 26
		mc 0 4 348 384 387 63
		f 4 225 219 180 -247
		mu 0 4 40 41 37 38
		mc 0 4 349 350 65 66
		f 4 -174 247 -177 -181
		mu 0 4 37 36 39 38
		mc 0 4 68 69 70 71
		f 4 226 -182 -175 -220
		mu 0 4 41 42 34 37
		mc 0 4 351 352 72 73
		f 4 301 -185 -180 -184
		mu 0 4 35 43 44 36
		mc 0 4 75 76 77 78
		f 4 66 -58 -68 63
		mu 0 4 45 46 47 48
		mc 0 4 81 82 83 84
		f 4 -59 -60 62 67
		mu 0 4 47 31 30 48
		mc 0 4 85 86 87 88
		f 4 201 -65 -62 65
		mu 0 4 49 33 32 50
		mc 0 4 89 90 91 92
		f 4 654 653 -66 -653
		mu 0 4 51 52 49 50
		mc 0 4 1165 1166 93 94
		f 4 70 -70 71 72
		mu 0 4 53 54 55 56
		mc 0 4 95 96 97 98
		f 4 74 166 137 136
		mu 0 4 57 58 59 60
		mc 0 4 99 100 101 102
		f 4 -72 78 79 -78
		mu 0 4 56 55 61 62
		mc 0 4 103 104 105 106
		f 4 81 -81 7 82
		mu 0 4 63 64 3 2
		mc 0 4 107 108 109 110
		f 4 83 -83 8 84
		mu 0 4 65 63 2 0
		mc 0 4 111 112 113 114
		f 4 -85 -5 36 85
		mu 0 4 65 0 19 66
		mc 0 4 115 116 117 118
		f 4 642 634 87 86
		mu 0 4 67 68 69 70
		mc 0 4 1130 1132 119 120
		f 4 164 -633 641 -87
		mu 0 4 70 71 72 67
		mc 0 4 275 122 1129 1131
		f 4 640 632 88 -632
		mu 0 4 73 72 71 74
		mc 0 4 1127 1128 124 125
		f 4 639 631 90 91
		mu 0 4 75 73 74 76
		mc 0 4 1124 1126 127 128
		f 4 38 97 -96 98
		mu 0 4 77 78 79 80
		mc 0 4 130 131 132 133
		f 4 39 99 100 101
		mu 0 4 81 82 83 84
		mc 0 4 134 135 136 137
		f 4 40 113 112 -98
		mu 0 4 78 85 86 79
		mc 0 4 138 139 140 141
		f 4 110 -156 206 594
		mu 0 4 87 88 89 90
		mc 0 4 142 143 144 1054
		f 4 106 -101 -105 107
		mu 0 4 91 84 83 89
		mc 0 4 145 146 147 148
		f 4 108 -108 155 109
		mu 0 4 92 91 89 88
		mc 0 4 149 150 151 152
		f 4 581 560 148 145
		mu 0 4 93 94 95 96
		mc 0 4 989 991 153 154
		f 4 580 -146 149 146
		mu 0 4 97 93 96 98
		mc 0 4 987 990 155 156
		f 4 623 611 -102 102
		mu 0 4 99 100 81 84
		mc 0 4 1085 1087 157 158
		f 4 621 609 -109 153
		mu 0 4 101 102 91 92
		mc 0 4 1081 1083 159 160
		f 4 579 -147 150 147
		mu 0 4 103 97 98 104
		mc 0 4 985 988 161 162
		f 4 167 75 128 -95
		mu 0 4 59 105 106 80
		mc 0 4 165 166 167 168
		f 4 205 575 554 191
		mu 0 4 107 108 109 110
		mc 0 4 169 978 979 172
		f 4 193 192 138 -141
		mu 0 4 111 112 60 113
		mc 0 4 173 174 175 176
		f 4 -120 143 142 120
		mu 0 4 114 115 116 117
		mc 0 4 177 178 179 180
		f 4 -122 -631 659 651
		mu 0 4 118 117 75 51
		mc 0 4 181 182 1125 1163
		f 4 -238 129 132 131
		mu 0 4 119 120 121 122
		mc 0 4 184 185 186 187
		f 4 -126 603 -135 -124
		mu 0 4 123 124 125 61
		mc 0 4 208 188 1053 210
		f 3 134 -94 -80
		mu 0 3 61 125 62
		mc 0 3 190 191 192
		f 4 -129 127 43 -99
		mu 0 4 80 106 126 77
		mc 0 4 193 194 195 196
		f 3 -128 -131 207
		mu 0 3 126 106 121
		mc 0 3 197 198 199
		f 4 -133 130 -76 92
		mu 0 4 122 121 106 105
		mc 0 4 200 201 202 203
		f 4 93 -550 572 -77
		mu 0 4 62 125 127 128
		mc 0 4 204 205 972 974
		f 4 94 95 96 -138
		mu 0 4 59 80 79 60
		mc 0 4 211 212 213 214
		f 4 -113 114 -139 -97
		mu 0 4 79 86 113 60
		mc 0 4 215 216 217 218
		f 4 -610 622 -103 -107
		mu 0 4 91 102 99 84
		mc 0 4 219 1084 1086 222
		f 4 -137 -193 194 118
		mu 0 4 57 60 112 129
		mc 0 4 223 224 225 226
		f 4 618 606 -142 89
		mu 0 4 130 131 132 64
		mc 0 4 1075 1077 227 228
		f 4 -149 46 2 68
		mu 0 4 96 95 15 1
		mc 0 4 230 231 232 233
		f 4 -150 -69 5 111
		mu 0 4 98 96 1 4
		mc 0 4 234 235 236 237
		f 4 -151 -112 6 115
		mu 0 4 104 98 4 3
		mc 0 4 238 239 240 241
		f 4 -152 -116 80 141
		mu 0 4 132 104 3 64
		mc 0 4 242 243 244 245
		f 4 578 -148 151 -557
		mu 0 4 133 103 104 132
		mc 0 4 984 986 246 247
		f 4 619 607 556 -607
		mu 0 4 131 134 133 132
		mc 0 4 1078 1079 983 248
		f 4 103 -596 600 596
		mu 0 4 135 136 137 138
		mc 0 4 250 251 1057 1058
		f 4 -217 222 295 293
		mu 0 4 139 140 141 142
		mc 0 4 255 344 478 481
		f 4 294 -189 -173 288
		mu 0 4 143 142 27 29
		mc 0 4 479 482 471 391
		f 4 158 159 262 254
		mu 0 4 144 145 146 147
		mc 0 4 257 258 400 402
		f 4 260 252 234 213
		mu 0 4 148 149 150 151
		mc 0 4 396 398 373 339
		f 4 280 -164 -89 236
		mu 0 4 152 153 74 71
		mc 0 4 444 447 262 261
		f 4 265 257 215 161
		mu 0 4 154 155 156 157
		mc 0 4 406 408 341 264
		f 4 264 -162 162 229
		mu 0 4 158 154 157 159
		mc 0 4 404 407 265 361
		f 4 -91 163 281 -232
		mu 0 4 76 74 153 160
		mc 0 4 271 272 446 449
		f 4 -88 -273 278 -231
		mu 0 4 70 69 161 162
		mc 0 4 276 277 441 443
		f 4 -73 73 574 552
		mu 0 4 53 56 163 164
		mc 0 4 279 280 975 977
		f 4 76 573 -74 77
		mu 0 4 62 128 163 56
		mc 0 4 283 973 976 286
		f 4 -61 178 184 -183
		mu 0 4 32 31 44 43
		mc 0 4 287 288 289 290
		f 3 304 303 122
		mu 0 3 50 165 118
		mc 0 3 291 499 319
		f 4 -216 221 216 -188
		mu 0 4 157 156 140 139
		mc 0 4 296 342 343 299
		f 4 -179 58 271 269
		mu 0 4 44 31 47 166
		mc 0 4 302 301 270 434
		f 3 287 -190 57
		mu 0 3 46 167 47
		mc 0 3 440 463 303
		f 4 -192 190 69 116
		mu 0 4 107 110 55 54
		mc 0 4 305 306 307 308
		f 4 126 123 296 249
		mu 0 4 168 123 61 114
		mc 0 4 394 304 393 315
		f 4 576 555 -196 -555
		mu 0 4 109 169 115 110
		mc 0 4 980 981 309 310
		f 4 -191 195 119 -197
		mu 0 4 55 110 115 114
		mc 0 4 311 312 309 313
		f 4 203 -205 -199 -67
		mu 0 4 45 170 171 46
		mc 0 4 321 429 322 323
		f 4 -64 -201 -202 199
		mu 0 4 45 48 33 49
		mc 0 4 324 325 90 89
		f 3 -63 -203 200
		mu 0 3 48 30 33
		mc 0 3 326 327 54
		f 4 599 595 105 -595
		mu 0 4 90 137 136 87
		mc 0 4 1055 1056 328 329
		f 3 -208 -130 44
		mu 0 3 126 121 120
		mc 0 3 332 333 334
		f 4 212 -251 259 -214
		mu 0 4 151 172 173 148
		mc 0 4 335 260 395 397
		f 4 266 -50 241 -258
		mu 0 4 155 174 175 156
		mc 0 4 409 410 263 380
		f 4 53 240 -222 -242
		mu 0 4 175 176 140 156
		mc 0 4 297 298 378 379
		f 4 -290 291 -223 -241
		mu 0 4 176 177 141 140
		mc 0 4 256 474 475 344
		f 4 -51 239 -224 217
		mu 0 4 178 179 25 24
		mc 0 4 46 355 356 345
		f 4 -57 245 -225 -240
		mu 0 4 179 180 40 25
		mc 0 4 64 383 385 348
		f 4 -52 238 -226 -246
		mu 0 4 180 181 41 40
		mc 0 4 67 357 358 349
		f 4 -53 300 -227 -239
		mu 0 4 181 182 42 41
		mc 0 4 74 359 360 351
		f 4 227 -255 263 -230
		mu 0 4 159 144 147 158
		mc 0 4 361 266 403 405
		f 4 -269 231 282 277
		mu 0 4 171 76 160 183
		mc 0 4 372 369 448 450
		f 4 261 -160 160 -253
		mu 0 4 149 146 145 150
		mc 0 4 399 401 259 376
		f 4 279 -237 -165 230
		mu 0 4 162 152 71 70
		mc 0 4 442 445 261 370
		f 4 179 -244 -245 -248
		mu 0 4 36 44 28 39
		mc 0 4 389 390 79 80
		f 4 197 -250 -121 121
		mu 0 4 118 168 114 117
		mc 0 4 318 392 316 317
		f 4 -260 -48 208 -252
		mu 0 4 148 173 184 185
		mc 0 4 411 412 337 338
		f 4 214 235 -261 251
		mu 0 4 185 186 149 148
		mc 0 4 340 414 415 413
		f 4 -254 -262 -236 233
		mu 0 4 187 146 149 186
		mc 0 4 416 417 399 375
		f 4 -263 253 209 157
		mu 0 4 147 146 187 188
		mc 0 4 418 419 267 268
		f 4 -264 -158 210 -256
		mu 0 4 158 147 188 189
		mc 0 4 420 421 364 365
		f 4 -257 -265 255 228
		mu 0 4 190 154 158 189
		mc 0 4 422 423 404 363
		f 4 220 -266 256 211
		mu 0 4 191 155 154 190
		mc 0 4 424 425 406 269
		f 4 -259 -267 -221 242
		mu 0 4 192 174 155 191
		mc 0 4 426 427 409 381
		f 4 -200 -654 -268 -204
		mu 0 4 45 49 52 170
		mc 0 4 431 432 1167 430
		f 4 -270 -271 -172 243
		mu 0 4 44 166 29 28
		mc 0 4 382 437 61 62
		f 4 -272 189 285 284
		mu 0 4 166 47 167 193
		mc 0 4 438 439 462 464
		f 4 -279 -49 -213 -274
		mu 0 4 162 161 172 151
		mc 0 4 452 453 278 366
		f 4 -235 -275 -280 273
		mu 0 4 151 150 152 162
		mc 0 4 336 454 455 442
		f 4 -276 -281 274 -161
		mu 0 4 145 153 152 150
		mc 0 4 456 457 444 374
		f 4 -282 275 -159 -277
		mu 0 4 160 153 145 144
		mc 0 4 458 459 367 368
		f 4 -283 276 -228 232
		mu 0 4 183 160 144 159
		mc 0 4 460 461 371 362
		f 4 -286 283 187 248
		mu 0 4 193 167 157 139
		mc 0 4 465 466 300 436
		f 4 -163 -284 -287 -233
		mu 0 4 159 157 167 183
		mc 0 4 467 468 463 451
		f 4 286 -288 198 -278
		mu 0 4 183 167 46 171
		mc 0 4 469 470 440 320
		f 4 -293 -289 270 -285
		mu 0 4 193 143 29 166
		mc 0 4 472 480 473 435
		f 4 -292 -55 -218 -291
		mu 0 4 141 177 178 24
		mc 0 4 476 477 353 354
		f 4 -249 -294 -295 292
		mu 0 4 193 139 142 143
		mc 0 4 483 484 482 479
		f 4 -296 290 -170 188
		mu 0 4 142 141 24 27
		mc 0 4 485 486 346 254
		f 3 -297 -79 196
		mu 0 3 114 61 55
		mc 0 3 487 488 314
		f 3 -123 -652 652
		mu 0 3 50 118 51
		mc 0 3 183 489 1164
		f 4 -301 -56 237 -299
		mu 0 4 42 182 120 119
		mc 0 4 491 492 129 377
		f 4 181 298 124 185
		mu 0 4 34 42 119 124
		mc 0 4 493 494 330 331
		f 4 -176 -186 125 -300
		mu 0 4 35 34 124 123
		mc 0 4 495 496 163 164
		f 4 -302 299 -127 186
		mu 0 4 43 35 123 168
		mc 0 4 497 498 294 295
		f 4 -304 -303 -187 -198
		mu 0 4 118 165 43 168
		mc 0 4 500 501 490 293
		f 4 302 -305 61 182
		mu 0 4 43 165 50 32
		mc 0 4 502 503 291 292
		f 4 -419 -418 -468 -474
		mu 0 4 194 195 196 197
		mc 0 4 812 505 504 814
		f 4 417 -422 -421 -420
		mu 0 4 196 195 198 199
		mc 0 4 507 510 509 508
		f 4 -451 -313 -309 -308
		mu 0 4 200 201 202 203
		mc 0 4 511 514 513 512
		f 4 -424 -423 -431 -547
		mu 0 4 204 205 206 207
		mc 0 4 515 518 517 516
		f 4 -426 419 -494 -425
		mu 0 4 208 196 199 209
		mc 0 4 853 520 519 855
		f 4 467 425 -496 -475
		mu 0 4 197 196 208 210
		mc 0 4 815 523 854 851
		f 4 495 -429 -469 -476
		mu 0 4 210 208 205 211
		mc 0 4 816 526 525 817
		f 4 428 424 -497 422
		mu 0 4 205 208 209 206
		mc 0 4 528 531 530 529
		f 4 468 423 -546 -477
		mu 0 4 211 205 204 212
		mc 0 4 818 533 532 819
		f 4 430 427 431 434
		mu 0 4 207 206 213 214
		mc 0 4 535 538 537 536
		f 4 -312 316 305 -316
		mu 0 4 215 216 217 218
		mc 0 4 541 544 543 542
		f 4 -317 -311 307 306
		mu 0 4 217 216 200 203
		mc 0 4 545 548 547 546
		f 4 -315 309 312 -450
		mu 0 4 219 220 202 201
		mc 0 4 549 552 551 550
		f 4 658 656 314 -656
		mu 0 4 221 222 220 219
		mc 0 4 1171 1172 554 553
		f 4 -322 -321 318 -320
		mu 0 4 223 224 225 226
		mc 0 4 555 558 557 556
		f 4 -387 -388 -416 -324
		mu 0 4 227 228 229 230
		mc 0 4 559 562 561 560
		f 4 326 -329 -328 320
		mu 0 4 224 231 232 225
		mc 0 4 563 566 565 564
		f 4 -332 -25 329 -331
		mu 0 4 233 18 17 234
		mc 0 4 567 570 569 568
		f 4 -334 -26 331 -333
		mu 0 4 235 13 18 233
		mc 0 4 571 574 573 572
		f 4 -335 -37 21 333
		mu 0 4 235 66 19 13
		mc 0 4 575 578 577 576
		f 4 643 -336 -337 -635
		mu 0 4 68 236 237 69
		mc 0 4 1133 1135 580 579
		f 4 645 637 -339 -637
		mu 0 4 238 239 240 241
		mc 0 4 1137 1138 583 582
		f 4 646 -342 -341 -638
		mu 0 4 239 242 243 240
		mc 0 4 1139 1141 587 586
		f 4 -349 345 -348 -39
		mu 0 4 77 244 245 78
		mc 0 4 589 592 591 590
		f 4 -352 -351 -350 -40
		mu 0 4 81 246 247 82
		mc 0 4 593 596 595 594
		f 4 347 -363 -364 -41
		mu 0 4 78 245 248 85
		mc 0 4 597 600 599 598
		f 4 -599 -455 405 -361
		mu 0 4 249 250 251 252
		mc 0 4 601 1063 603 602
		f 4 -358 354 350 -357
		mu 0 4 253 251 247 246
		mc 0 4 604 607 606 605
		f 4 -360 -406 357 -359
		mu 0 4 254 252 251 253
		mc 0 4 608 611 610 609
		f 4 582 -396 -399 -561
		mu 0 4 94 255 256 95
		mc 0 4 992 994 614 613
		f 4 583 -397 -400 395
		mu 0 4 255 257 258 256
		mc 0 4 993 996 617 616
		f 4 624 -353 351 -612
		mu 0 4 100 259 246 81
		mc 0 4 1088 1090 620 619
		f 4 626 -404 358 -614
		mu 0 4 260 261 254 253
		mc 0 4 1092 1094 623 622
		f 4 584 -398 -401 396
		mu 0 4 257 262 263 258
		mc 0 4 995 998 626 625
		f 4 344 -379 -325 -417
		mu 0 4 229 244 264 265
		mc 0 4 629 632 631 630
		f 4 -440 -567 588 -454
		mu 0 4 266 267 268 269
		mc 0 4 633 636 1004 1005
		f 4 390 -389 -441 -442
		mu 0 4 270 271 228 272
		mc 0 4 637 640 639 638
		f 4 -371 -393 -394 369
		mu 0 4 273 274 275 276
		mc 0 4 641 644 643 642
		f 4 660 -314 -517 341
		mu 0 4 242 222 277 243
		mc 0 4 1140 1174 895 901
		f 4 -382 -383 -380 486
		mu 0 4 278 279 280 120
		mc 0 4 647 650 649 648
		f 4 381 374 593 -384
		mu 0 4 279 278 281 282
		mc 0 4 651 654 653 1012
		f 3 328 343 -385
		mu 0 3 232 231 283
		mc 0 3 655 657 656
		f 4 348 -44 -378 378
		mu 0 4 244 77 126 264
		mc 0 4 658 661 660 659
		f 3 -456 380 377
		mu 0 3 126 280 264
		mc 0 3 662 664 663
		f 4 -343 324 -381 382
		mu 0 4 279 265 264 280
		mc 0 4 665 668 667 666
		f 4 325 591 571 -344
		mu 0 4 231 284 282 283
		mc 0 4 669 1009 1011 670
		f 4 373 384 -605 375
		mu 0 4 285 232 283 281
		mc 0 4 673 675 652 1074
		f 4 387 -347 -346 -345
		mu 0 4 229 228 245 244
		mc 0 4 676 679 678 677
		f 4 346 388 -365 362
		mu 0 4 245 228 271 248
		mc 0 4 680 683 682 681
		f 4 356 352 625 613
		mu 0 4 253 246 259 260
		mc 0 4 684 687 1089 1091
		f 4 -369 -443 440 386
		mu 0 4 227 286 272 228
		mc 0 4 688 691 690 689
		f 4 629 -340 391 -617
		mu 0 4 287 288 234 289
		mc 0 4 1098 1099 693 692
		f 4 -318 -20 -47 398
		mu 0 4 256 12 15 95
		mc 0 4 694 697 696 695
		f 4 -362 -23 317 399
		mu 0 4 258 16 12 256
		mc 0 4 698 701 700 699
		f 4 -366 -24 361 400
		mu 0 4 263 17 16 258
		mc 0 4 702 705 704 703
		f 4 -392 -330 365 401
		mu 0 4 289 234 17 263
		mc 0 4 706 709 708 707
		f 4 585 564 -402 397
		mu 0 4 262 290 289 263
		mc 0 4 997 999 712 711
		f 4 586 628 616 -565
		mu 0 4 290 291 287 289
		mc 0 4 1000 1095 1097 714
		f 4 -597 601 597 -354
		mu 0 4 135 138 292 293
		mc 0 4 716 1059 1060 717
		f 4 -540 -542 -473 465
		mu 0 4 294 295 296 297
		mc 0 4 721 949 946 811
		f 4 -536 421 436 -541
		mu 0 4 298 198 195 295
		mc 0 4 947 858 939 950
		f 4 -504 -511 -410 -409
		mu 0 4 299 300 301 302
		mc 0 4 723 869 867 724
		f 4 -486 338 413 -528
		mu 0 4 303 241 240 304
		mc 0 4 912 727 728 915
		f 4 -412 -465 -507 -514
		mu 0 4 305 306 307 308
		mc 0 4 873 730 808 875
		f 4 -480 -413 411 -513
		mu 0 4 309 310 306 305
		mc 0 4 871 828 731 874
		f 4 481 -529 -414 340
		mu 0 4 243 311 304 240
		mc 0 4 737 917 914 738
		f 4 -338 335 644 636
		mu 0 4 241 237 236 238
		mc 0 4 581 740 1134 1136
		f 4 480 -526 272 336
		mu 0 4 237 312 161 69
		mc 0 4 741 911 909 742
		f 4 -569 589 -323 321
		mu 0 4 223 313 314 224
		mc 0 4 744 1006 1008 745
		f 4 -327 322 590 -326
		mu 0 4 231 224 314 284
		mc 0 4 748 751 1007 1010
		f 4 429 -432 -427 308
		mu 0 4 202 214 213 203
		mc 0 4 752 755 754 753
		f 3 -373 -548 -549
		mu 0 3 220 315 316
		mc 0 3 756 785 967
		f 4 435 -466 -472 464
		mu 0 4 306 294 297 307
		mc 0 4 761 764 810 809
		f 4 -518 -520 -307 426
		mu 0 4 213 317 217 203
		mc 0 4 767 902 736 766
		f 3 -306 437 -535
		mu 0 3 218 217 318
		mc 0 3 908 768 931
		f 4 -367 -319 -439 439
		mu 0 4 266 226 225 267
		mc 0 4 770 773 772 771
		f 4 -499 -543 -374 -377
		mu 0 4 319 273 232 285
		mc 0 4 861 781 860 769
		f 4 587 566 443 -566
		mu 0 4 320 268 267 276
		mc 0 4 1002 1003 776 775
		f 4 444 -370 -444 438
		mu 0 4 225 273 276 267
		mc 0 4 777 779 775 778
		f 4 315 446 452 -452
		mu 0 4 215 218 277 321
		mc 0 4 787 789 788 896
		f 4 -448 449 448 311
		mu 0 4 215 219 201 216
		mc 0 4 790 549 550 791
		f 3 -449 450 310
		mu 0 3 216 201 200
		mc 0 3 792 514 793
		f 4 602 598 -356 -598
		mu 0 4 292 250 249 293
		mc 0 4 1061 1062 796 795
		f 3 -45 379 455
		mu 0 3 126 120 280
		mc 0 3 799 801 800
		f 4 462 -508 250 -461
		mu 0 4 322 323 173 172
		mc 0 4 802 864 862 726
		f 4 -463 -464 -502 -509
		mu 0 4 323 322 324 325
		mc 0 4 863 806 840 865
		f 4 506 -491 49 -515
		mu 0 4 308 307 326 327
		mc 0 4 876 847 729 877
		f 4 490 471 -490 -54
		mu 0 4 326 307 297 328
		mc 0 4 762 846 845 763
		f 4 489 472 -538 289
		mu 0 4 328 297 296 329
		mc 0 4 722 811 943 942
		f 4 -467 473 -489 50
		mu 0 4 330 194 197 331
		mc 0 4 506 812 823 822
		f 4 488 474 -495 56
		mu 0 4 331 197 210 332
		mc 0 4 524 815 852 850
		f 4 494 475 -488 51
		mu 0 4 332 210 211 181
		mc 0 4 527 816 825 824
		f 4 487 476 469 52
		mu 0 4 181 211 212 182
		mc 0 4 534 818 827 826
		f 4 479 -512 503 -478
		mu 0 4 310 309 300 299
		mc 0 4 828 872 870 732
		f 4 -525 -530 -482 516
		mu 0 4 277 333 311 243
		mc 0 4 839 918 916 836
		f 4 501 -411 409 -510
		mu 0 4 325 324 302 301
		mc 0 4 866 843 725 868
		f 4 -481 337 485 -527
		mu 0 4 312 237 241 303
		mc 0 4 910 837 727 913
		f 4 496 493 492 -428
		mu 0 4 206 209 199 213
		mc 0 4 856 540 539 857
		f 4 -372 370 498 -446
		mu 0 4 315 274 273 319
		mc 0 4 784 783 782 859
		f 4 500 -457 47 507
		mu 0 4 323 334 184 173
		mc 0 4 878 805 804 879
		f 4 -462 -501 508 -485
		mu 0 4 335 334 323 325
		mc 0 4 881 807 880 882
		f 4 -484 484 509 502
		mu 0 4 336 335 325 301
		mc 0 4 883 842 866 884
		f 4 -408 -458 -503 510
		mu 0 4 300 337 336 301
		mc 0 4 885 734 733 886
		f 4 504 -459 407 511
		mu 0 4 309 338 337 300
		mc 0 4 887 832 831 888
		f 4 -479 -505 512 505
		mu 0 4 339 338 309 305
		mc 0 4 889 830 871 890
		f 4 -460 -506 513 -471
		mu 0 4 340 339 305 308
		mc 0 4 891 735 873 892
		f 4 -492 470 514 258
		mu 0 4 341 340 308 327
		mc 0 4 893 848 876 894
		f 4 451 515 655 447
		mu 0 4 215 321 221 219
		mc 0 4 899 897 1170 900
		f 4 -493 420 518 517
		mu 0 4 213 199 198 317
		mc 0 4 849 522 521 905
		f 4 -532 -533 -438 519
		mu 0 4 317 342 318 217
		mc 0 4 906 932 930 907
		f 4 520 460 48 525
		mu 0 4 312 322 172 161
		mc 0 4 920 833 743 921
		f 4 463 -521 526 521
		mu 0 4 324 322 312 303
		mc 0 4 922 803 910 923
		f 4 410 -522 527 522
		mu 0 4 302 324 303 304
		mc 0 4 924 841 912 925
		f 4 523 408 -523 528
		mu 0 4 311 299 302 304
		mc 0 4 926 835 834 927
		f 4 -483 477 -524 529
		mu 0 4 333 310 299 311
		mc 0 4 928 829 838 929
		f 4 -498 -436 -531 532
		mu 0 4 342 294 306 318
		mc 0 4 933 904 765 934
		f 4 482 533 530 412
		mu 0 4 310 333 318 306
		mc 0 4 935 919 931 936
		f 4 524 -447 534 -534
		mu 0 4 333 277 218 318
		mc 0 4 937 786 908 938
		f 4 531 -519 535 538
		mu 0 4 342 317 198 298
		mc 0 4 940 903 941 948
		f 4 536 466 54 537
		mu 0 4 296 194 330 329
		mc 0 4 944 821 820 945
		f 4 -539 540 539 497
		mu 0 4 342 298 295 294
		mc 0 4 951 947 950 952
		f 4 -437 418 -537 541
		mu 0 4 295 195 194 296
		mc 0 4 953 720 813 954
		f 3 -445 327 542
		mu 0 3 273 225 232
		mc 0 3 955 780 956
		f 3 -657 657 372
		mu 0 3 220 222 315
		mc 0 3 646 1173 957
		f 4 543 -487 55 -470
		mu 0 4 212 278 120 182
		mc 0 4 959 844 588 960
		f 4 -433 -375 -544 545
		mu 0 4 204 281 278 212
		mc 0 4 961 798 797 962
		f 4 544 -376 432 546
		mu 0 4 207 285 281 204
		mc 0 4 963 628 627 964
		f 4 -434 376 -545 -435
		mu 0 4 214 319 285 207
		mc 0 4 965 760 759 966
		f 4 445 433 499 547
		mu 0 4 315 319 214 316
		mc 0 4 968 758 958 969
		f 4 -430 -310 548 -500
		mu 0 4 214 202 220 316
		mc 0 4 970 757 756 971
		f 4 -573 -134 -93 -551
		mu 0 4 128 127 122 105
		mc 0 4 1013 1014 206 207
		f 4 -574 550 -168 -552
		mu 0 4 163 128 105 59
		mc 0 4 1015 1016 284 285
		f 4 -575 551 -167 165
		mu 0 4 164 163 59 58
		mc 0 4 1017 1018 281 282
		f 4 -576 553 -195 117
		mu 0 4 109 108 129 112
		mc 0 4 1019 1020 170 171
		f 4 -194 135 -577 -118
		mu 0 4 112 111 169 109
		mc 0 4 1021 1022 981 980
		f 4 620 -154 152 -608
		mu 0 4 134 101 92 133
		mc 0 4 1080 1082 1023 983
		f 4 -110 -558 -579 -153
		mu 0 4 92 88 103 133
		mc 0 4 1024 1025 986 984
		f 4 -111 -559 -580 557
		mu 0 4 88 87 97 103
		mc 0 4 1026 1027 988 985
		f 4 -106 -560 -581 558
		mu 0 4 87 136 93 97
		mc 0 4 1028 1029 990 987
		f 4 -104 45 -582 559
		mu 0 4 136 135 94 93
		mc 0 4 1030 1031 991 989
		f 4 -562 -583 -46 353
		mu 0 4 293 255 94 135
		mc 0 4 1032 1033 992 612
		f 4 -563 -584 561 355
		mu 0 4 249 257 255 293
		mc 0 4 1034 1035 993 615
		f 4 -564 -585 562 360
		mu 0 4 252 262 257 249
		mc 0 4 1036 1037 995 624
		f 4 402 -586 563 359
		mu 0 4 254 290 262 252
		mc 0 4 1038 1039 997 710
		f 4 627 -587 -403 403
		mu 0 4 261 291 290 254
		mc 0 4 1093 1096 1000 713
		f 4 367 -588 -386 441
		mu 0 4 272 268 320 270
		mc 0 4 1040 1041 1002 774
		f 4 -589 -368 442 -568
		mu 0 4 269 268 272 286
		mc 0 4 1042 1043 635 634
		f 4 -590 -415 415 -570
		mu 0 4 314 313 230 229
		mc 0 4 1044 1045 747 746
		f 4 -591 569 416 -571
		mu 0 4 284 314 229 265
		mc 0 4 1046 1047 750 749
		f 4 -592 570 342 383
		mu 0 4 282 284 265 279
		mc 0 4 1048 1049 672 671
		f 4 133 -593 -125 -132
		mu 0 4 122 127 124 119
		mc 0 4 1050 1051 188 189
		f 3 604 -572 -594
		mu 0 3 281 283 282
		mc 0 3 674 652 1052
		f 4 104 156 -600 -207
		mu 0 4 89 83 137 90
		mc 0 4 1064 1065 1056 1055
		f 4 -601 -157 -100 41
		mu 0 4 138 137 83 82
		mc 0 4 1066 1067 252 253
		f 4 -602 -42 349 406
		mu 0 4 292 138 82 247
		mc 0 4 1068 1069 719 718
		f 4 454 -603 -407 -355
		mu 0 4 251 250 292 247
		mc 0 4 1070 1071 1061 794
		f 3 592 549 -604
		mu 0 3 124 127 125
		mc 0 3 1072 1073 209
		f 4 154 -619 605 -144
		mu 0 4 115 131 130 116
		mc 0 4 1100 1101 1075 229
		f 4 577 -620 -155 -556
		mu 0 4 169 134 131 115
		mc 0 4 1102 1103 1078 249
		f 4 -609 -621 -578 -136
		mu 0 4 111 101 134 169
		mc 0 4 1104 1105 1080 982
		f 4 140 139 -622 608
		mu 0 4 111 113 102 101
		mc 0 4 1106 1107 1083 1081
		f 4 -623 -140 -115 -611
		mu 0 4 99 102 113 86
		mc 0 4 1108 1109 220 221
		f 4 -114 42 -624 610
		mu 0 4 86 85 100 99
		mc 0 4 1110 1111 1087 1085
		f 4 -613 -625 -43 363
		mu 0 4 248 259 100 85
		mc 0 4 1112 1113 1088 618
		f 4 -626 612 364 389
		mu 0 4 260 259 248 271
		mc 0 4 1114 1115 686 685
		f 4 -615 -627 -390 -391
		mu 0 4 270 261 260 271
		mc 0 4 1116 1117 1092 621
		f 4 385 -616 -628 614
		mu 0 4 270 320 291 261
		mc 0 4 1118 1119 1096 1093
		f 4 -629 615 565 404
		mu 0 4 287 291 320 276
		mc 0 4 1120 1121 1001 715
		f 4 393 -618 -630 -405
		mu 0 4 276 275 288 287
		mc 0 4 1122 1123 1099 1098
		f 4 -143 144 -640 630
		mu 0 4 117 116 73 75
		mc 0 4 1142 1143 1126 1124
		f 4 647 -641 -145 -606
		mu 0 4 130 72 73 116
		mc 0 4 1076 1144 1127 126
		f 4 37 -643 633 -86
		mu 0 4 66 68 67 65
		mc 0 4 1146 1147 1130 121
		f 4 334 -636 -644 -38
		mu 0 4 66 235 236 68
		mc 0 4 1148 1149 1135 1133
		f 4 635 332 650 -645
		mu 0 4 236 235 233 238
		mc 0 4 1150 739 1151 1136
		f 4 -639 -647 -395 392
		mu 0 4 274 242 239 275
		mc 0 4 1154 1155 1139 585
		f 4 -648 -90 -82 649
		mu 0 4 72 130 64 63
		mc 0 4 1156 1076 123 273
		f 4 -649 617 394 -646
		mu 0 4 238 288 275 239
		mc 0 4 1157 1158 584 1138
		f 4 -650 -84 -634 -642
		mu 0 4 72 63 65 67
		mc 0 4 1159 1160 274 1145
		f 4 -651 330 339 648
		mu 0 4 238 233 234 288
		mc 0 4 1161 1162 1152 1153
		f 4 204 267 -655 -298
		mu 0 4 171 170 52 51
		mc 0 4 1168 1169 1166 1165
		f 4 313 -659 -516 -453
		mu 0 4 277 222 221 321
		mc 0 4 1175 1176 1171 898
		f 4 -660 -92 268 297
		mu 0 4 51 75 76 171
		mc 0 4 1177 1178 433 428
		f 4 -658 -661 638 371
		mu 0 4 315 222 242 274
		mc 0 4 1179 1180 1140 645
		f 4 661 662 663 664
		mu 0 4 343 344 345 346
		mc 0 4 1209 1589 1204 1230
		f 4 665 666 667 668
		mu 0 4 347 348 349 350
		mc 0 4 1461 1462 1201 1202
		f 4 669 670 671 672
		mu 0 4 351 352 353 354
		mc 0 4 1215 1453 1212 1211
		f 4 673 674 675 676
		mu 0 4 355 356 357 358
		mc 0 4 1456 1457 1219 1218
		f 4 677 678 679 -671
		mu 0 4 352 359 360 353
		mc 0 4 1453 1454 1203 1212
		f 4 680 681 682 -668
		mu 0 4 349 361 362 350
		mc 0 4 1201 1205 1206 1202
		f 4 683 -663 684 685
		mu 0 4 363 345 344 364
		mc 0 4 1464 1204 1589 1203
		f 4 686 687 688 -679
		mu 0 4 359 365 366 360
		mc 0 4 1454 1455 1207 1203
		f 4 -684 689 690 691
		mu 0 4 367 368 369 370
		mc 0 4 1204 1464 1459 1463
		f 4 692 693 694 695
		mu 0 4 351 371 372 373
		mc 0 4 1215 1234 1451 1452
		f 4 697 2324 698 696
		mu 0 4 374 375 376 354
		mc 0 4 1210 1235 1447 2679
		f 4 699 700 701 -682
		mu 0 4 361 377 378 362
		mc 0 4 1205 1216 1217 1206
		f 4 702 -677 703 -688
		mu 0 4 365 379 380 366
		mc 0 4 1455 1456 1218 1207
		f 4 -704 -676 704 705
		mu 0 4 366 380 357 381
		mc 0 4 1207 1218 1219 1208
		f 4 -705 -675 706 707
		mu 0 4 381 357 356 382
		mc 0 4 1208 1219 1457 1458
		f 3 708 709 710
		mu 0 3 383 384 385
		mc 0 3 1228 1227 1229
		f 3 711 712 -710
		mu 0 3 384 386 385
		mc 0 3 1227 1225 1229
		f 3 713 -713 714
		mu 0 3 387 385 386
		mc 0 3 1226 1229 1225
		f 3 715 -672 716
		mu 0 3 388 389 390
		mc 0 3 1223 1211 1212
		f 4 718 -697 -716 717
		mu 0 4 391 392 389 388
		mc 0 4 1224 1210 2680 2681
		f 4 -719 719 720 721
		mu 0 4 392 391 393 343
		mc 0 4 1210 1224 1221 1209
		f 4 722 723 -698 -722
		mu 0 4 394 395 375 374
		mc 0 4 1209 1232 1235 1210
		f 4 724 -715 725 726
		mu 0 4 393 387 396 397
		mc 0 4 1221 1226 1225 1220
		f 4 -726 -712 727 728
		mu 0 4 397 396 398 399
		mc 0 4 1220 1225 1227 1222
		f 4 -709 729 730 -728
		mu 0 4 400 383 388 401
		mc 0 4 1227 1228 1223 1222
		f 4 -711 731 -718 -730
		mu 0 4 383 385 391 388
		mc 0 4 2683 1229 1224 2682
		f 4 -732 -714 -725 -720
		mu 0 4 391 385 387 393
		mc 0 4 1224 1229 1226 1221
		f 3 732 733 -731
		mu 0 3 388 402 401
		mc 0 3 1223 1203 1222
		f 3 -717 -680 -733
		mu 0 3 388 390 402
		mc 0 3 1223 1212 1203
		f 4 734 735 736 737
		mu 0 4 403 404 405 406
		mc 0 4 1537 2324 2265 2262
		f 4 738 -738 739 740
		mu 0 4 407 403 406 408
		mc 0 4 1536 1979 1980 1248
		f 4 741 742 743 744
		mu 0 4 409 410 411 412
		mc 0 4 1523 1524 1246 1249
		f 4 745 746 747 -743
		mu 0 4 410 413 414 411
		mc 0 4 1524 1525 1263 1246
		f 4 748 -745 749 750
		mu 0 4 415 409 412 416
		mc 0 4 1522 1523 1249 1254
		f 4 -757 752 753 754
		mu 0 4 417 408 418 419
		mc 0 4 1253 1248 1258 1251
		f 4 755 -741 756 757
		mu 0 4 420 407 408 417
		mc 0 4 1535 1536 1248 1253
		f 4 2235 2217 759 760
		mu 0 4 421 422 423 424
		mc 0 4 2180 2161 1534 1436
		f 4 2234 -761 763 764
		mu 0 4 425 421 424 426
		mc 0 4 2177 2179 1436 1437
		f 4 767 768 2232 2224
		mu 0 4 427 428 429 430
		mc 0 4 1438 1439 2173 2175
		f 4 773 -737 771 772
		mu 0 4 431 406 405 432
		mc 0 4 2307 1245 2267 2269
		f 4 774 775 776 777
		mu 0 4 433 434 435 436
		mc 0 4 1256 1259 1260 1257
		f 4 2227 2219 780 781
		mu 0 4 437 438 439 440
		mc 0 4 2163 2165 1521 1443
		f 4 783 784 2230 2222
		mu 0 4 441 442 443 444
		mc 0 4 1440 1441 2169 2171
		f 4 787 -2223 2231 -769
		mu 0 4 445 441 444 446
		mc 0 4 1439 1440 2172 2174
		f 4 789 -2225 2233 -765
		mu 0 4 426 427 430 425
		mc 0 4 1437 1438 2176 2178
		f 4 791 792 793 794
		mu 0 4 447 448 449 450
		mc 0 4 1255 1261 1262 1250
		f 4 795 -777 796 -792
		mu 0 4 447 451 452 448
		mc 0 4 1255 1257 1260 1261
		f 4 797 -754 798 -775
		mu 0 4 433 419 418 434
		mc 0 4 1256 1251 1258 1259
		f 4 799 -773 800 801
		mu 0 4 453 431 432 454
		mc 0 4 2305 2308 2270 2271
		f 4 802 -802 803 804
		mu 0 4 455 453 454 456
		mc 0 4 2304 2306 2272 2273
		f 4 805 -805 806 807
		mu 0 4 457 458 459 460
		mc 0 4 1428 1429 2274 2275
		f 4 808 -808 809 810
		mu 0 4 461 457 460 462
		mc 0 4 1427 1981 1982 1266
		f 4 812 813 814 815
		mu 0 4 463 464 465 466
		mc 0 4 1406 1410 1411 1407
		f 4 816 817 818 819
		mu 0 4 467 468 469 470
		mc 0 4 1279 1478 1479 1288
		f 4 -2322 -810 -1446 -1410
		mu 0 4 471 472 473 474
		mc 0 4 2676 1983 3227 3229
		f 4 823 824 825 826
		mu 0 4 475 471 476 477
		mc 0 4 1403 1541 1542 1494
		f 4 -824 827 -1409 2321
		mu 0 4 471 475 478 472
		mc 0 4 1541 1403 2330 2268
		f 4 829 830 831 832
		mu 0 4 479 480 481 482
		mc 0 4 1271 1289 1287 1272
		f 4 833 834 835 836
		mu 0 4 483 484 485 486
		mc 0 4 2280 2293 1491 2315
		f 4 837 838 -834 839
		mu 0 4 487 480 484 483
		mc 0 4 2278 2291 2294 2281
		f 4 840 841 842 843
		mu 0 4 488 489 490 467
		mc 0 4 1408 1285 1284 1279
		f 4 -816 844 845 846
		mu 0 4 463 466 470 491
		mc 0 4 1406 1407 1288 1274
		f 4 2718 2687 848 849
		mu 0 4 492 493 494 495
		mc 0 4 3423 3393 1474 1280
		f 4 851 852 2715 2700
		mu 0 4 496 497 498 499
		mc 0 4 1281 1527 3417 3419
		f 4 854 855 856 857
		mu 0 4 500 487 501 502
		mc 0 4 1276 1275 1282 1286
		f 4 858 -856 -840 859
		mu 0 4 503 501 487 483
		mc 0 4 2288 2286 2279 2282
		f 4 860 861 -817 -843
		mu 0 4 490 504 468 467
		mc 0 4 1284 1477 1478 1279
		f 4 862 863 -860 -837
		mu 0 4 486 505 503 483
		mc 0 4 1492 2317 2289 1277
		f 4 864 865 866 867
		mu 0 4 506 507 508 509
		mc 0 4 1571 1505 1572 1503
		f 4 -815 868 869 870
		mu 0 4 466 465 510 488
		mc 0 4 1407 1411 1412 1408
		f 4 -819 871 872 -846
		mu 0 4 470 469 511 491
		mc 0 4 1288 1479 1480 1274
		f 4 -831 -838 -855 873
		mu 0 4 481 480 487 500
		mc 0 4 1287 1289 1275 1276
		f 4 874 -835 875 876
		mu 0 4 512 485 484 513
		mc 0 4 2311 2313 1987 1273
		f 4 -839 -830 877 -876
		mu 0 4 484 480 479 513
		mc 0 4 1290 2292 2277 1988
		f 4 -845 -871 -844 -820
		mu 0 4 470 466 488 467
		mc 0 4 1288 1407 1408 1279
		f 4 879 880 881 882
		mu 0 4 514 515 516 517
		mc 0 4 2452 2453 2454 2455
		f 4 883 884 -694 885
		mu 0 4 518 519 520 521
		mc 0 4 2456 2457 2458 2459
		f 4 -913 886 887 888
		mu 0 4 522 523 524 525
		mc 0 4 1294 1467 1468 1292
		f 4 889 890 891 -888
		mu 0 4 524 526 527 525
		mc 0 4 1468 1469 1444 1292
		f 4 -901 892 893 -724
		mu 0 4 528 529 530 531
		mc 0 4 2460 2461 2462 2463
		f 4 -894 2323 894 -2325
		mu 0 4 531 530 532 533
		mc 0 4 2466 1304 2464 2465
		f 4 895 1364 896 897
		mu 0 4 534 535 536 537
		mc 0 4 2467 2468 2469 2470
		f 4 898 899 900 901
		mu 0 4 538 539 529 528
		mc 0 4 2471 2472 2473 2474
		f 4 902 903 904 905
		mu 0 4 540 541 542 543
		mc 0 4 1518 1519 1466 1295
		f 4 906 907 908 909
		mu 0 4 544 545 546 547
		mc 0 4 1296 1470 1471 1448
		f 4 910 911 912 913
		mu 0 4 548 549 523 522
		mc 0 4 1531 1532 1467 1294
		f 4 914 -906 915 916
		mu 0 4 550 540 543 551
		mc 0 4 1517 1518 1295 1298
		f 4 917 -914 918 919
		mu 0 4 552 548 522 553
		mc 0 4 1530 1531 1294 1299
		f 4 -919 -889 920 921
		mu 0 4 553 522 525 554
		mc 0 4 1299 1294 1292 1300
		f 4 -921 -892 922 923
		mu 0 4 554 525 527 555
		mc 0 4 1300 1292 1444 1445
		f 4 -910 924 925 926
		mu 0 4 544 547 556 557
		mc 0 4 1296 1448 1449 1301
		f 4 928 -920 929 -900
		mu 0 4 539 552 553 529
		mc 0 4 1989 1530 1299 1990
		f 4 -930 -922 930 -893
		mu 0 4 529 553 554 530
		mc 0 4 1990 1299 1300 1991
		f 4 -931 -924 931 -2324
		mu 0 4 530 554 555 532
		mc 0 4 1991 1300 1445 1992
		f 4 -926 932 -884 933
		mu 0 4 557 556 519 518
		mc 0 4 1301 1449 1993 1994
		f 4 935 -917 936 -881
		mu 0 4 515 550 551 516
		mc 0 4 1995 1517 1298 1996
		f 4 2518 2502 938 939
		mu 0 4 558 559 560 561
		mc 0 4 3005 3007 1550 1315
		f 4 941 942 943 -878
		mu 0 4 562 563 564 565
		mc 0 4 1997 1318 1319 1998
		f 4 944 945 946 947
		mu 0 4 566 567 568 569
		mc 0 4 1311 1313 1484 1485
		f 4 948 2598 2594 -946
		mu 0 4 570 571 572 573
		mc 0 4 1313 3198 3200 1484
		f 4 952 -950 -2343 951
		mu 0 4 574 575 576 577
		mc 0 4 1482 1483 1312 3164
		f 4 -944 953 954 -877
		mu 0 4 565 564 578 579
		mc 0 4 1998 1319 1489 1999
		f 4 -1206 955 956 957
		mu 0 4 580 581 582 583
		mc 0 4 1590 2345 2296 2310
		f 4 958 959 960 961
		mu 0 4 584 585 563 586
		mc 0 4 1433 1434 1318 1320
		f 4 -873 962 963 964
		mu 0 4 587 588 589 590
		mc 0 4 2000 2001 1481 1321
		f 4 965 -847 -965 966
		mu 0 4 591 592 587 590
		mc 0 4 1405 2002 2000 1321
		f 4 967 2342 2325 -2383
		mu 0 4 593 577 576 594
		mc 0 4 1404 2684 2685 2759
		f 4 -957 2530 -948 968
		mu 0 4 583 582 566 569
		mc 0 4 1486 2297 2295 3057
		f 4 -943 -960 970 971
		mu 0 4 564 563 585 595
		mc 0 4 1319 1318 1434 1435
		f 4 972 -954 -972 973
		mu 0 4 596 578 564 595
		mc 0 4 1488 1489 1319 1435
		f 4 -961 -942 -833 974
		mu 0 4 586 563 562 597
		mc 0 4 1320 1318 1997 2004
		f 4 -964 975 -952 976
		mu 0 4 590 589 574 577
		mc 0 4 1321 1481 1482 1316
		f 4 977 978 -813 -966
		mu 0 4 591 598 599 592
		mc 0 4 1405 1409 2005 2002
		f 4 979 -967 -977 -968
		mu 0 4 593 591 590 577
		mc 0 4 1404 1405 1321 1316
		f 4 980 981 -2303 -1032
		mu 0 4 600 601 602 603
		mc 0 4 1569 1563 2644 2645
		f 4 2300 2525 -2295 -2527
		mu 0 4 604 605 606 607
		mc 0 4 2652 1567 1568 2651
		f 4 2391 2371 -2298 -2371
		mu 0 4 608 609 610 611
		mc 0 4 2776 2777 1564 2646
		f 4 982 983 -2306 2298
		mu 0 4 612 613 614 615
		mc 0 4 1565 1566 2649 2650
		f 4 984 1031 -2302 2294
		mu 0 4 606 616 617 607
		mc 0 4 1568 1569 2642 2643
		f 4 985 -2299 -2305 2297
		mu 0 4 610 612 615 611
		mc 0 4 1564 1565 2647 2648
		f 4 986 987 988 989
		mu 0 4 618 619 620 621
		mc 0 4 1330 1333 1340 1341
		f 4 991 2524 992 990
		mu 0 4 622 623 624 625
		mc 0 4 1422 1423 1343 3047
		f 4 994 2522 995 993
		mu 0 4 626 627 628 629
		mc 0 4 2483 2484 1325 3044
		f 4 996 997 998 999
		mu 0 4 630 631 632 633
		mc 0 4 2485 2486 2487 2488
		f 4 1000 2393 2373 1001
		mu 0 4 634 635 636 637
		mc 0 4 1328 2779 2781 1344
		f 4 1002 1003 1004 1005
		mu 0 4 638 639 640 641
		mc 0 4 1331 1332 1345 1342
		f 4 1006 -993 1007 -988
		mu 0 4 642 625 624 643
		mc 0 4 1333 1329 1343 1340
		f 4 1008 -1002 1009 -1004
		mu 0 4 639 634 637 640
		mc 0 4 1332 1328 1344 1345
		f 4 1010 1011 1012 1013
		mu 0 4 644 645 646 647
		mc 0 4 2489 2490 2491 2492
		f 4 1014 2396 2376 -998
		mu 0 4 631 648 649 632
		mc 0 4 1348 2785 2787 2493
		f 4 1015 -1000 1016 1017
		mu 0 4 650 630 633 651
		mc 0 4 1346 1347 2494 2495
		f 4 1018 -996 1019 -1012
		mu 0 4 652 629 628 653
		mc 0 4 1350 2006 2496 2497
		f 4 -989 1020 1021 1022
		mu 0 4 621 620 654 655
		mc 0 4 1341 1340 1339 1338
		f 4 1023 2523 1024 -2525
		mu 0 4 623 656 657 624
		mc 0 4 1423 1424 1337 3046
		f 4 -2374 2394 2374 1025
		mu 0 4 637 636 658 659
		mc 0 4 1344 2782 2783 1335
		f 4 -1005 1026 1027 1028
		mu 0 4 641 640 660 661
		mc 0 4 1342 1345 1336 1334
		f 4 -1008 -1025 1029 -1021
		mu 0 4 643 624 657 662
		mc 0 4 1340 1343 1337 1339
		f 4 -1010 -1026 1030 -1027
		mu 0 4 640 637 659 660
		mc 0 4 1345 1344 1335 1336
		f 4 2301 2295 1332 1333
		mu 0 4 607 617 663 664
		mc 0 4 2628 2630 1352 1353
		f 4 1335 2526 -1334 1334
		mu 0 4 665 604 607 664
		mc 0 4 1421 2640 2629 1353
		f 4 2305 2299 1337 1338
		mu 0 4 615 614 666 667
		mc 0 4 2636 2638 1354 1355
		f 4 2304 -1339 1339 1340
		mu 0 4 611 615 667 668
		mc 0 4 2634 2637 2443 2444
		f 4 2390 2370 -1341 1341
		mu 0 4 669 608 611 668
		mc 0 4 2773 2775 2635 2445
		f 4 -2296 2302 2296 1342
		mu 0 4 670 603 602 671
		mc 0 4 2442 2631 2632 2446
		f 4 -1028 1032 -1016 1033
		mu 0 4 661 660 630 650
		mc 0 4 1334 1336 2008 2009
		f 4 -1031 1034 -997 -1033
		mu 0 4 660 659 631 630
		mc 0 4 1336 1335 2010 2008
		f 4 -2375 2395 -1015 -1035
		mu 0 4 659 658 648 631
		mc 0 4 1335 2784 2786 2010
		f 4 -1022 1035 -1011 1036
		mu 0 4 655 654 645 644
		mc 0 4 1338 1339 2011 2012
		f 4 -1030 1037 -1019 -1036
		mu 0 4 662 657 629 652
		mc 0 4 1339 1337 1351 2011
		f 4 1038 -994 -1038 -2524
		mu 0 4 656 626 629 657
		mc 0 4 1424 1425 1351 3045
		f 4 -999 1074 1039 1040
		mu 0 4 672 673 674 675
		mc 0 4 1322 1323 1543 1544
		f 4 1041 1042 1084 -1013
		mu 0 4 676 677 678 679
		mc 0 4 1326 1548 1383 1327
		f 4 1043 1044 1045 1046
		mu 0 4 680 681 682 683
		mc 0 4 1358 1359 1378 1377
		f 4 1047 1048 2505 2489
		mu 0 4 684 685 686 687
		mc 0 4 1324 1545 2979 2981
		f 4 1051 2503 2487 1054
		mu 0 4 688 689 690 691
		mc 0 4 1361 2975 2977 1360
		f 4 1055 1056 1057 1058
		mu 0 4 692 693 694 695
		mc 0 4 1364 1376 1375 1362
		f 4 2398 2670 2655 1060
		mu 0 4 696 697 698 674
		mc 0 4 2789 3343 3329 1382
		f 4 -2657 2664 2657 -1044
		mu 0 4 680 699 700 681
		mc 0 4 1369 3332 3333 1371
		f 4 1065 2666 2659 -1077
		mu 0 4 701 702 703 704
		mc 0 4 1367 3335 3337 1366
		f 4 2401 2381 -1064 1070
		mu 0 4 705 706 707 708
		mc 0 4 2795 2797 1374 1370
		f 4 -1020 1071 1072 -1042
		mu 0 4 676 709 710 677
		mc 0 4 1326 2007 1547 1548
		f 4 1075 1076 1077 -1057
		mu 0 4 693 701 704 694
		mc 0 4 1376 1365 1363 1375
		f 4 1078 -1048 -1017 -1041
		mu 0 4 675 711 712 672
		mc 0 4 1544 1545 1324 1322
		f 4 1079 -1055 1080 -1046
		mu 0 4 682 713 714 683
		mc 0 4 1378 1361 1360 1377
		f 4 -1050 2521 -1072 -2523
		mu 0 4 715 716 717 718
		mc 0 4 2013 1546 1547 2007
		f 4 -1053 2520 -1059 1081
		mu 0 4 719 720 721 722
		mc 0 4 1379 1380 1364 1362
		f 4 2399 2379 -1062 -2379
		mu 0 4 723 724 725 726
		mc 0 4 2792 2793 1381 1368
		f 4 -2382 -2342 -1083 2577
		mu 0 4 727 728 729 730
		mc 0 4 1374 2798 2723 1373
		f 4 -1084 -1076 2484 -1045
		mu 0 4 731 732 733 734
		mc 0 4 1359 1365 1376 1378
		f 4 -2380 2400 -1071 -2293
		mu 0 4 725 724 705 708
		mc 0 4 2623 2794 2796 1370
		f 4 2397 -1061 -1075 -2377
		mu 0 4 735 696 674 673
		mc 0 4 2788 2790 1382 1323
		f 4 2344 -2366 -2386 2364
		mu 0 4 736 737 738 739
		mc 0 4 2688 2690 2803 2763
		f 4 1087 1088 1089 1090
		mu 0 4 740 741 742 743
		mc 0 4 1553 1554 1397 1396
		f 4 1091 2386 2366 1092
		mu 0 4 744 738 745 746
		mc 0 4 1385 2765 2767 1391
		f 4 1093 1094 1095 1096
		mu 0 4 747 748 749 750
		mc 0 4 1388 1389 1395 1394
		f 4 1097 1098 1099 1100
		mu 0 4 751 752 753 754
		mc 0 4 1551 1552 1398 1399;
	setAttr ".fc[500:999]"
		f 4 -941 2529 1102 1101
		mu 0 4 755 756 757 758
		mc 0 4 1549 1314 1400 3055
		f 4 1103 -1101 1104 -939
		mu 0 4 560 751 754 561
		mc 0 4 1550 1551 1399 1315
		f 4 1105 -1103 1106 -1089
		mu 0 4 759 758 757 760
		mc 0 4 1554 1555 1400 1397
		f 4 1107 1108 1109 1110
		mu 0 4 761 762 763 764
		mc 0 4 1558 1559 1501 1502
		f 4 1111 1112 1113 1114
		mu 0 4 765 766 767 768
		mc 0 4 1384 1386 1392 1390
		f 4 1115 1116 1117 -1095
		mu 0 4 769 770 771 772
		mc 0 4 1389 1387 1393 1395
		f 4 1118 -1093 1119 -1113
		mu 0 4 766 744 746 767
		mc 0 4 1386 1385 1391 1392
		f 4 1121 2528 -1117 1120
		mu 0 4 773 774 771 770
		mc 0 4 1419 1420 1393 3052
		f 4 1122 1123 1124 1125
		mu 0 4 775 776 777 778
		mc 0 4 1562 1556 1497 1498
		f 4 1126 1127 1128 -1109
		mu 0 4 779 780 781 782
		mc 0 4 1559 1560 1500 1501
		f 4 1129 1130 1131 -1124
		mu 0 4 776 783 784 777
		mc 0 4 1556 1557 1496 1497
		f 4 1133 2527 -1128 1132
		mu 0 4 785 786 781 780
		mc 0 4 1561 1499 1500 3050
		f 4 1135 2388 2368 -1131
		mu 0 4 783 787 788 784
		mc 0 4 1557 2769 2771 1496
		f 4 2385 -1092 1136 1137
		mu 0 4 739 738 744 753
		mc 0 4 2763 2766 1385 1398
		f 4 2343 -2365 -2385 2363
		mu 0 4 789 736 739 790
		mc 0 4 2686 2689 2801 2802
		f 4 -1090 1138 -1094 -1086
		mu 0 4 743 742 748 747
		mc 0 4 1396 1397 1389 1388
		f 4 -1100 -1137 -1119 1139
		mu 0 4 754 753 744 766
		mc 0 4 1399 1398 1385 1386
		f 4 1141 -1121 1140 -2530
		mu 0 4 756 773 770 757
		mc 0 4 1314 1419 3053 3054
		f 4 -1105 -1140 -1112 1142
		mu 0 4 561 754 766 765
		mc 0 4 1315 1399 1386 1384
		f 4 -1107 -1141 -1116 -1139
		mu 0 4 760 757 770 769
		mc 0 4 1397 1400 1387 1389
		f 4 1152 1153 1154 -868
		mu 0 4 509 791 792 506
		mc 0 4 1503 1504 1570 1571
		f 4 -736 1155 821 1156
		mu 0 4 793 794 795 796
		mc 0 4 2266 1538 2325 2334
		f 4 -747 1157 -812 1158
		mu 0 4 797 798 799 800
		mc 0 4 2014 2015 1526 1402
		f 4 1159 2384 -1138 -1099
		mu 0 4 752 790 739 753
		mc 0 4 1552 2761 2764 1398
		f 4 2361 1160 -978 -980
		mu 0 4 593 801 598 591
		mc 0 4 1404 1432 1409 1405
		f 4 -841 -870 1161 1162
		mu 0 4 489 488 510 802
		mc 0 4 1285 1408 1412 1413
		f 4 1163 -962 1164 -1161
		mu 0 4 801 803 804 598
		mc 0 4 1432 1433 1320 1409
		f 4 -979 -1165 -975 1165
		mu 0 4 599 598 804 805
		mc 0 4 2005 1409 1320 2004
		f 4 -832 1166 -814 -1166
		mu 0 4 806 807 465 464
		mc 0 4 1272 1287 1411 1410
		f 4 -869 -1167 -874 1167
		mu 0 4 510 465 807 808
		mc 0 4 1412 1411 1287 1276
		f 4 -858 1168 -1162 -1168
		mu 0 4 808 809 802 510
		mc 0 4 1276 1286 1413 1412
		f 4 2291 2256 1170 1171
		mu 0 4 810 811 812 813
		mc 0 4 2582 2548 1415 1414
		f 4 1172 -2257 2274 2257
		mu 0 4 814 812 811 815
		mc 0 4 1416 1415 2549 2550
		f 4 2275 2258 1175 -2258
		mu 0 4 816 817 818 819
		mc 0 4 2551 2552 1417 2018
		f 4 1176 -2259 2276 2259
		mu 0 4 820 818 817 821
		mc 0 4 2301 2299 2553 2554
		f 4 2277 2260 1179 -2260
		mu 0 4 821 822 823 820
		mc 0 4 2555 2556 2319 2302
		f 4 2516 2500 -1115 1181
		mu 0 4 824 825 765 768
		mc 0 4 3001 3003 1384 1390
		f 4 2514 2498 -1126 1183
		mu 0 4 826 827 775 778
		mc 0 4 2997 2999 1562 1498
		f 4 -2300 2306 2512 2496
		mu 0 4 666 614 828 829
		mc 0 4 1354 2639 2993 2995
		f 4 2509 2493 -1006 1186
		mu 0 4 830 831 638 641
		mc 0 4 2987 2989 1331 1342
		f 4 2508 -1187 -1029 1187
		mu 0 4 832 830 641 661
		mc 0 4 2985 2988 1342 1334
		f 4 2507 -1188 -1034 1188
		mu 0 4 833 832 661 650
		mc 0 4 2983 2986 1334 2009
		f 4 2506 -1189 -1018 -2490
		mu 0 4 834 833 650 651
		mc 0 4 2982 2984 2499 2020
		f 4 2517 -940 -1143 -2501
		mu 0 4 825 558 561 765
		mc 0 4 3004 3006 1315 1384
		f 4 2650 2615 -1177 1190
		mu 0 4 835 836 818 820
		mc 0 4 3280 3246 2300 2303
		f 4 1191 2649 -1191 -1180
		mu 0 4 823 837 835 820
		mc 0 4 1493 3278 3281 1418
		f 4 -793 1193 -809 1194
		mu 0 4 449 448 457 461
		mc 0 4 1262 1261 1981 1427
		f 4 -797 1195 -806 -1194
		mu 0 4 448 452 458 457
		mc 0 4 1261 1260 2022 1981
		f 4 -776 1196 -803 -1196
		mu 0 4 435 434 453 455
		mc 0 4 2023 2024 2025 2026
		f 4 -799 1197 -800 -1197
		mu 0 4 434 418 431 453
		mc 0 4 2027 2263 2309 1430
		f 4 -740 -774 -1198 -753
		mu 0 4 408 406 431 418
		mc 0 4 2029 2322 1431 2028
		f 4 2382 2362 1198 -2362
		mu 0 4 593 594 838 801
		mc 0 4 1404 2759 1309 1432
		f 4 1199 -1164 -1199 1200
		mu 0 4 839 803 801 838
		mc 0 4 1310 1433 1432 1309
		f 4 1201 -959 -1200 1202
		mu 0 4 840 585 584 841
		mc 0 4 2030 1434 1433 1310
		f 4 1204 -974 -1204 1205
		mu 0 4 580 596 595 581
		mc 0 4 1487 1488 1435 2031
		f 4 -1216 -755 1206 -764
		mu 0 4 424 417 419 426
		mc 0 4 1436 1253 1251 1437
		f 4 -798 1207 -790 -1207
		mu 0 4 419 433 427 426
		mc 0 4 1251 1256 1438 1437
		f 4 -778 1208 -768 -1208
		mu 0 4 433 436 428 427
		mc 0 4 1256 1257 1439 1438
		f 4 1209 -788 -1209 -796
		mu 0 4 447 441 445 451
		mc 0 4 1255 1440 1439 1257
		f 4 -795 1210 -784 -1210
		mu 0 4 447 450 442 441
		mc 0 4 1255 1250 1441 1440
		f 4 1212 -751 1213 -781
		mu 0 4 439 415 416 440
		mc 0 4 1521 1522 1254 1443
		f 4 1214 -758 1215 -760
		mu 0 4 423 420 417 424
		mc 0 4 1534 1535 1253 1436
		f 4 1216 -891 1217 -907
		mu 0 4 842 527 526 843
		mc 0 4 1296 1444 1469 1470
		f 4 -923 -1217 -927 1218
		mu 0 4 555 527 842 844
		mc 0 4 1445 1444 1296 1301
		f 4 -932 -1219 -934 1219
		mu 0 4 532 555 844 845
		mc 0 4 1992 1445 1301 1994
		f 4 -895 -1220 -886 1220
		mu 0 4 533 532 845 846
		mc 0 4 2475 1446 1305 2476
		f 4 -699 -1221 -693 -673
		mu 0 4 354 376 371 351
		mc 0 4 1211 1447 1234 1215
		f 4 -909 1221 1222 1223
		mu 0 4 547 546 847 848
		mc 0 4 1448 1471 1472 1291
		f 4 -925 -1224 1224 1225
		mu 0 4 556 547 848 849
		mc 0 4 1449 1448 1291 1302
		f 4 -933 -1226 1226 1227
		mu 0 4 519 556 849 534
		mc 0 4 1993 1449 1302 2032
		f 4 -885 -1228 -898 1228
		mu 0 4 520 519 534 537
		mc 0 4 2477 1450 1306 2478
		f 4 -695 -1229 1229 1230
		mu 0 4 373 372 850 851
		mc 0 4 1452 1451 1233 1214
		f 4 1231 1232 -678 1233
		mu 0 4 852 853 359 352
		mc 0 4 1506 1507 1454 1453
		f 4 1234 1235 -687 -1233
		mu 0 4 853 854 365 359
		mc 0 4 1507 1508 1455 1454
		f 4 1236 1237 -703 -1236
		mu 0 4 854 855 379 365
		mc 0 4 1508 1509 1456 1455
		f 4 1238 1239 -674 -1238
		mu 0 4 856 857 356 355
		mc 0 4 1509 1510 1457 1456
		f 4 -707 -1240 1240 1241
		mu 0 4 382 356 857 858
		mc 0 4 1458 1457 1510 1511
		f 4 -681 1242 1243 1244
		mu 0 4 361 349 859 858
		mc 0 4 1205 1201 1512 1511
		f 4 1245 1246 -691 1247
		mu 0 4 859 860 370 369
		mc 0 4 1512 1513 1463 1459
		f 4 1248 -883 1249 1250
		mu 0 4 861 862 863 864
		mc 0 4 1514 1515 1231 1460
		f 4 -670 -696 1251 -1234
		mu 0 4 352 351 373 852
		mc 0 4 1453 1215 1452 1506
		f 4 1252 -666 1253 1254
		mu 0 4 865 348 347 866
		mc 0 4 1213 1462 1461 1214
		f 4 1255 -1247 1256 -1251
		mu 0 4 864 370 860 861
		mc 0 4 1460 1463 1513 1514
		f 4 -664 -692 -1256 1257
		mu 0 4 867 367 370 864
		mc 0 4 1230 1204 1463 1460
		f 4 -689 -706 1258 -686
		mu 0 4 360 366 381 368
		mc 0 4 1203 1207 1208 1464
		f 4 1259 -690 -1259 -708
		mu 0 4 382 369 368 381
		mc 0 4 1458 1459 1464 1208
		f 4 1260 1261 1262 -904
		mu 0 4 541 868 869 542
		mc 0 4 1519 1578 1579 1466
		f 4 1263 1264 1265 -912
		mu 0 4 549 870 871 523
		mc 0 4 1532 1580 1581 1467
		f 4 1266 1267 -887 -1266
		mu 0 4 871 872 524 523
		mc 0 4 1581 1582 1468 1467
		f 4 1268 1269 -791 1270
		mu 0 4 873 872 874 875
		mc 0 4 2341 2340 2253 2260
		f 4 -1218 1271 1272 1273
		mu 0 4 843 526 873 876
		mc 0 4 1470 1469 2034 1584
		f 4 -908 -1274 1274 1275
		mu 0 4 546 545 877 878
		mc 0 4 1471 1470 1584 1585
		f 4 -1276 1276 1277 -1222
		mu 0 4 546 878 879 847
		mc 0 4 1471 1585 1586 1472
		f 4 1279 1280 1281 -827
		mu 0 4 477 880 881 475
		mc 0 4 1494 1495 1473 1403
		f 4 1282 1283 2717 -850
		mu 0 4 495 882 883 492
		mc 0 4 2284 2327 3421 3424
		f 4 2703 2688 1285 -2688
		mu 0 4 493 884 885 494
		mc 0 4 3394 3395 1185 1474
		f 4 1286 -1154 1287 1288
		mu 0 4 886 792 791 887
		mc 0 4 1200 1570 1504 1964
		f 4 -862 1290 1291 1292
		mu 0 4 468 504 888 889
		mc 0 4 1478 1477 1187 1183
		f 4 -818 -1293 1293 1294
		mu 0 4 469 468 889 890
		mc 0 4 1479 1478 1183 1965
		f 4 -872 -1295 1295 1296
		mu 0 4 511 469 890 891
		mc 0 4 1480 1479 1965 1182
		f 4 -963 -1297 1297 1298
		mu 0 4 589 588 892 893
		mc 0 4 1481 2001 2035 1193
		f 4 -976 -1299 1299 1300
		mu 0 4 574 589 893 894
		mc 0 4 1482 1481 1193 1966
		f 4 -953 -1301 1301 1302
		mu 0 4 575 574 894 895
		mc 0 4 1483 1482 1966 1191
		f 4 -2595 2599 2595 1304
		mu 0 4 573 572 896 897
		mc 0 4 1484 3201 3202 1967
		f 4 -947 -1305 1305 1306
		mu 0 4 569 568 898 899
		mc 0 4 1485 1484 1967 1190
		f 4 1307 -969 -1307 1308
		mu 0 4 900 583 569 899
		mc 0 4 1192 2036 1485 1190
		f 4 -1312 -958 -1308 1309
		mu 0 4 901 580 583 900
		mc 0 4 1189 1487 2036 1192
		f 4 1310 -1205 1311 1312
		mu 0 4 902 596 580 901
		mc 0 4 1198 1488 1487 1189
		f 4 1313 -973 -1311 1314
		mu 0 4 903 578 596 902
		mc 0 4 1194 1489 1488 1198
		f 4 -955 -1314 1315 1316
		mu 0 4 579 578 903 904
		mc 0 4 2312 2037 2247 2436
		f 4 1317 -875 -1317 1318
		mu 0 4 905 485 512 906
		mc 0 4 2244 2314 1490 2437
		f 4 -836 -1318 1319 1320
		mu 0 4 486 485 905 907
		mc 0 4 2316 1986 2245 2241
		f 4 1321 -863 -1321 1322
		mu 0 4 908 505 486 907
		mc 0 4 2439 2318 2039 2242
		f 4 1323 -2261 2278 2261
		mu 0 4 909 823 822 910
		mc 0 4 2248 2320 2557 2558
		f 4 2648 -1192 -1324 1325
		mu 0 4 911 837 823 909
		mc 0 4 3276 3279 2041 2249
		f 4 -826 1327 1328 1329
		mu 0 4 477 476 912 913
		mc 0 4 1494 1542 1199 1196
		f 4 1330 -1280 -1330 1331
		mu 0 4 914 880 477 913
		mc 0 4 1186 1495 1494 1196
		f 4 -1132 1343 -1340 1344
		mu 0 4 777 784 915 916
		mc 0 4 1497 1496 1356 2042
		f 4 -1125 -1345 -1338 1345
		mu 0 4 778 777 916 917
		mc 0 4 1498 1497 2042 2044
		f 4 2513 -1184 -1346 -2497
		mu 0 4 918 826 778 917
		mc 0 4 2996 2998 1498 2044
		f 4 -1347 -1335 1347 -2528
		mu 0 4 786 919 920 781
		mc 0 4 1499 2045 2046 3049
		f 4 -1129 -1348 -1333 1348
		mu 0 4 782 781 920 921
		mc 0 4 1501 1500 2046 2043
		f 4 -1110 -1349 -1343 1349
		mu 0 4 764 763 922 923
		mc 0 4 1502 1501 2043 1357
		f 4 -2331 2348 -2370 -2390
		mu 0 4 788 924 925 926
		mc 0 4 2811 2697 2699 2810
		f 4 -2369 2389 -1342 -1344
		mu 0 4 784 788 926 915
		mc 0 4 1496 2772 2774 1356
		f 4 -867 1351 850 -2614
		mu 0 4 509 508 796 495
		mc 0 4 1503 1572 3241 3242
		f 4 2613 -849 1352 -1153
		mu 0 4 509 495 494 791
		mc 0 4 1503 3240 1475 1504
		f 4 -1288 -1353 -1286 1353
		mu 0 4 887 791 494 885
		mc 0 4 1964 1504 1475 1963
		f 4 -1171 1354 2635 2618
		mu 0 4 813 812 927 928
		mc 0 4 1414 1415 3250 3252
		f 4 2634 -1355 -1173 1355
		mu 0 4 929 927 812 814
		mc 0 4 3248 3251 1415 1416
		f 4 -1176 -2616 2633 -1356
		mu 0 4 819 818 836 930
		mc 0 4 2018 1417 3247 3249
		f 4 1356 -1252 -1231 -1254
		mu 0 4 931 852 373 851
		mc 0 4 1461 1506 1452 1214
		f 4 1357 -1232 -1357 -669
		mu 0 4 932 853 852 931
		mc 0 4 1202 1507 1506 1461
		f 4 1358 -1235 -1358 -683
		mu 0 4 933 854 853 932
		mc 0 4 1206 1508 1507 1202
		f 4 -702 1359 -1237 -1359
		mu 0 4 933 934 855 854
		mc 0 4 1206 1217 1509 1508
		f 4 1360 -1239 -1360 -701
		mu 0 4 377 857 856 935
		mc 0 4 1216 1510 1509 1217
		f 4 -1241 -1361 -700 -1245
		mu 0 4 858 857 377 361
		mc 0 4 1511 1510 1216 1205
		f 4 1361 -1246 -1243 -667
		mu 0 4 348 860 859 349
		mc 0 4 1462 1513 1512 1201
		f 4 -1257 -1362 -1253 1362
		mu 0 4 861 860 348 865
		mc 0 4 1514 1513 1462 1213
		f 4 1363 -1249 -1363 1452
		mu 0 4 936 862 861 865
		mc 0 4 1588 1515 1514 1213
		f 4 1365 -936 1366 -935
		mu 0 4 937 550 515 535
		mc 0 4 1297 1517 1995 1307
		f 4 1367 -915 -1366 -928
		mu 0 4 938 540 550 937
		mc 0 4 1293 1518 1517 1297
		f 4 1368 -903 -1368 -879
		mu 0 4 939 541 540 938
		mc 0 4 1465 1519 1518 1293
		f 4 1369 1370 1371 1372
		mu 0 4 940 868 941 942
		mc 0 4 2050 1578 1587 2051
		f 4 1373 -2220 2228 -779
		mu 0 4 943 439 438 944
		mc 0 4 1442 1521 2166 2167
		f 4 1374 -1213 -1374 -1212
		mu 0 4 945 415 439 943
		mc 0 4 1252 1522 1521 1442
		f 4 1375 -749 -1375 -752
		mu 0 4 946 409 415 945
		mc 0 4 1247 1523 1522 1252
		f 4 -1193 1376 -742 -1376
		mu 0 4 946 947 410 409
		mc 0 4 1247 1244 1524 1523
		f 4 1377 -746 -1377 -767
		mu 0 4 948 413 410 947
		mc 0 4 1265 1525 1524 1244
		f 4 -1158 -1378 -828 -823
		mu 0 4 799 798 478 475
		mc 0 4 1526 2015 1984 1403
		f 4 2714 -853 1378 1379
		mu 0 4 949 498 497 881
		mc 0 4 3415 3418 1527 1473
		f 4 -1244 -1248 -1260 -1242
		mu 0 4 858 859 369 382
		mc 0 4 1511 1512 1459 1458
		f 4 1380 -899 1381 -882
		mu 0 4 516 539 538 517
		mc 0 4 1303 1529 2479 2480
		f 4 1382 -929 -1381 -937
		mu 0 4 551 552 539 516
		mc 0 4 1298 1530 1989 1996
		f 4 1383 -918 -1383 -916
		mu 0 4 543 548 552 551
		mc 0 4 1295 1531 1530 1298
		f 4 1384 -911 -1384 -905
		mu 0 4 542 549 548 543
		mc 0 4 1466 1532 1531 1295
		f 4 1385 1386 1387 1388
		mu 0 4 950 870 869 951
		mc 0 4 2052 1580 1579 2053
		f 4 1389 -2218 2226 -782
		mu 0 4 440 423 422 437
		mc 0 4 1443 1534 2162 2164
		f 4 1390 -1215 -1390 -1214
		mu 0 4 416 420 423 440
		mc 0 4 1254 1535 1534 1443
		f 4 1391 -756 -1391 -750
		mu 0 4 412 407 420 416
		mc 0 4 1249 1536 1535 1254
		f 4 -744 1392 -739 -1392
		mu 0 4 412 411 403 407
		mc 0 4 1249 1246 1979 1536
		f 4 1393 -735 -1393 -748
		mu 0 4 414 404 403 411
		mc 0 4 1263 2054 1979 1246
		f 4 -1156 -1394 -1159 1394
		mu 0 4 795 794 952 953
		mc 0 4 2326 2055 2264 2298
		f 4 -1395 1395 1396 1397
		mu 0 4 795 953 954 882
		mc 0 4 2338 2337 2285 2328
		f 4 2716 -1284 -1397 -2701
		mu 0 4 955 883 882 954
		mc 0 4 3420 3422 1539 2057
		f 4 -723 -665 -1454 -902
		mu 0 4 395 394 867 956
		mc 0 4 1232 1209 1230 1528
		f 4 -1230 -897 -1453 -1255
		mu 0 4 866 957 936 865
		mc 0 4 1214 1233 1588 1213
		f 4 1398 934 -896 -1227
		mu 0 4 849 937 535 534
		mc 0 4 1302 1297 1307 2032
		f 4 1399 927 -1399 -1225
		mu 0 4 848 938 937 849
		mc 0 4 1291 1293 1297 1302
		f 4 1400 878 -1400 -1223
		mu 0 4 847 939 938 848
		mc 0 4 1472 1465 1293 1291
		f 4 -1372 1401 1402 1403
		mu 0 4 942 941 879 958
		mc 0 4 2051 1587 1586 2058
		f 4 1404 778 2229 -785
		mu 0 4 442 943 944 443
		mc 0 4 1441 1442 2168 2170
		f 4 1405 1211 -1405 -1211
		mu 0 4 450 945 943 442
		mc 0 4 1250 1252 1442 1441
		f 4 1406 751 -1406 -794
		mu 0 4 449 946 945 450
		mc 0 4 1262 1247 1252 1250
		f 4 1407 1192 -1407 -1195
		mu 0 4 461 947 946 449
		mc 0 4 1427 1244 1247 1262
		f 4 1408 766 -1408 -811
		mu 0 4 462 948 947 461
		mc 0 4 1266 1265 1244 1427
		f 4 -825 1409 828 2610
		mu 0 4 476 471 474 959
		mc 0 4 2332 2331 3228 3230
		f 4 -1328 -2611 -1327 2611
		mu 0 4 912 476 959 960
		mc 0 4 2251 2333 3231 3232
		f 4 -1040 -1411 -1047 1411
		mu 0 4 675 674 680 683
		mc 0 4 1544 1543 1358 1377
		f 4 -1081 1412 -1079 -1412
		mu 0 4 683 714 711 675
		mc 0 4 1377 1360 1545 1544
		f 4 2504 -1049 -1413 -2488
		mu 0 4 690 686 685 691
		mc 0 4 2978 2980 1545 1360
		f 4 -1414 -1082 1414 -2522
		mu 0 4 716 719 722 717
		mc 0 4 1546 1379 1362 1547
		f 4 -1073 -1415 -1058 1415
		mu 0 4 677 710 695 694
		mc 0 4 1548 1547 1362 1375
		f 4 -1043 -1416 -1078 1416
		mu 0 4 678 677 694 704
		mc 0 4 1383 1548 1375 1363
		f 4 2519 -970 1417 -2503
		mu 0 4 559 961 962 560
		mc 0 4 3008 3009 1308 1550
		f 4 -1203 1419 -1104 -1418
		mu 0 4 962 963 751 560
		mc 0 4 1308 2059 1551 1550
		f 4 -1201 1420 -1098 -1420
		mu 0 4 963 964 752 751
		mc 0 4 2059 2060 1552 1551
		f 4 -2363 2383 -1160 -1421
		mu 0 4 964 965 790 752
		mc 0 4 2060 2760 2762 1552
		f 4 -945 1422 -1106 -1422
		mu 0 4 966 967 758 759
		mc 0 4 2062 2003 1555 1554
		f 4 -1419 -1102 -1423 -2531
		mu 0 4 968 755 758 967
		mc 0 4 1317 1549 1555 3056
		f 4 -1120 1423 -1130 1424
		mu 0 4 767 746 783 776
		mc 0 4 1392 1391 1557 1556
		f 4 -2367 2387 -1136 -1424
		mu 0 4 746 745 787 783
		mc 0 4 1391 2768 2770 1557
		f 4 -1096 1426 -1108 -1426
		mu 0 4 750 749 762 761
		mc 0 4 1394 1395 1559 1558
		f 4 -1118 1427 -1127 -1427
		mu 0 4 772 771 780 779
		mc 0 4 1395 1393 1560 1559
		f 4 1428 -1133 -1428 -2529
		mu 0 4 774 785 780 771
		mc 0 4 1420 1561 1560 3051
		f 4 2515 -1182 1429 -2499
		mu 0 4 827 824 768 775
		mc 0 4 3000 3002 1390 1562
		f 4 -1114 -1425 -1123 -1430
		mu 0 4 768 767 776 775
		mc 0 4 1390 1392 1556 1562
		f 4 -2334 2351 -2373 -2393
		mu 0 4 609 969 970 635
		mc 0 4 2815 2703 2705 2814
		f 4 -2372 2392 -1001 1431
		mu 0 4 610 609 635 634
		mc 0 4 1564 2778 2780 1328
		f 4 -986 -1432 -1009 1432
		mu 0 4 612 610 634 639
		mc 0 4 1565 1564 1328 1332
		f 4 -983 -1433 -1003 1433
		mu 0 4 613 612 639 638
		mc 0 4 1566 1565 1332 1331
		f 4 2510 -1185 -1434 -2494
		mu 0 4 831 971 613 638
		mc 0 4 2990 2992 1566 1331
		f 4 -1435 -991 1435 -2526
		mu 0 4 605 622 625 606
		mc 0 4 1567 1422 1329 3048
		f 4 -985 -1436 -1007 1436
		mu 0 4 616 606 625 642
		mc 0 4 1569 1568 1329 1333
		f 4 -981 -1437 -987 -1431
		mu 0 4 601 600 619 618
		mc 0 4 1563 1569 1333 1330
		f 4 2288 2271 1289 1438
		mu 0 4 972 973 974 975
		mc 0 4 2576 2578 1476 1195
		f 4 820 -2272 2289 2272
		mu 0 4 976 974 973 977
		mc 0 4 1401 1476 2579 2580
		f 4 2290 -1172 1440 -2273
		mu 0 4 977 810 813 976
		mc 0 4 2581 2583 1414 1401
		f 4 1441 2638 2621 -1290
		mu 0 4 974 978 979 975
		mc 0 4 1476 3256 3258 1195
		f 4 2637 -1442 -821 1443
		mu 0 4 980 978 974 976
		mc 0 4 3254 3257 1476 1401
		f 4 -801 2606 -866 2608
		mu 0 4 981 982 508 507
		mc 0 4 1268 1267 1572 1505
		f 4 2636 -1444 -1441 -2619
		mu 0 4 928 980 976 813
		mc 0 4 3253 3255 1401 1414
		f 4 -1331 1446 2712 2697
		mu 0 4 880 914 983 984
		mc 0 4 1495 1186 3411 3413
		f 4 -1281 -2698 2713 -1380
		mu 0 4 881 880 984 949
		mc 0 4 1473 1495 3414 3416
		f 4 1448 -852 -1396 811
		mu 0 4 799 497 496 800
		mc 0 4 1526 1527 1281 1402
		f 4 -1283 -851 -822 -1398
		mu 0 4 882 495 796 795
		mc 0 4 2056 1985 2283 2339
		f 4 -1379 -1449 822 -1282
		mu 0 4 881 497 799 475
		mc 0 4 1473 1527 1526 1403
		f 4 -1370 -783 -1388 -1262
		mu 0 4 868 940 951 869
		mc 0 4 1578 2050 2053 1579
		f 4 -1386 -762 -1351 -1265
		mu 0 4 870 950 985 871
		mc 0 4 2066 2323 2255 2048
		f 4 -766 -1270 -1267 1350
		mu 0 4 985 874 872 871
		mc 0 4 2321 2254 2033 2047
		f 4 -890 -1268 -1269 -1272
		mu 0 4 526 524 872 873
		mc 0 4 1469 1468 1582 2034
		f 4 -770 1449 -1273 -1271
		mu 0 4 875 986 876 873
		mc 0 4 2261 2256 2342 1583
		f 4 -789 1450 -1275 -1450
		mu 0 4 987 988 878 877
		mc 0 4 2257 2259 2068 2067
		f 4 -786 -1403 -1277 -1451
		mu 0 4 988 958 879 878
		mc 0 4 2069 2258 2344 2343
		f 4 -1261 -1369 1278 -1371
		mu 0 4 868 541 939 941
		mc 0 4 1578 1519 1465 1587
		f 4 -1264 -1385 -1263 -1387
		mu 0 4 870 549 542 869
		mc 0 4 1580 1532 1466 1579
		f 4 -1279 -1401 -1278 -1402
		mu 0 4 941 939 847 879
		mc 0 4 1587 1465 1472 1586
		f 4 -1367 -880 -1364 -1365
		mu 0 4 535 515 514 536
		mc 0 4 2049 1516 2481 2482
		f 4 -721 -727 1451 -662
		mu 0 4 343 393 397 344
		mc 0 4 1209 1221 1220 1589
		f 4 -729 -734 -685 -1452
		mu 0 4 397 399 364 344
		mc 0 4 1220 1222 1203 1589
		f 4 1453 -1258 -1250 -1382
		mu 0 4 956 867 864 863
		mc 0 4 1528 1230 1460 1231
		f 4 1454 1455 1456 1457
		mu 0 4 989 990 991 992
		mc 0 4 1591 1594 1593 1592
		f 4 1458 1459 1460 1461
		mu 0 4 993 994 995 996
		mc 0 4 1595 1598 1597 1596
		f 4 1462 1463 1464 1465
		mu 0 4 997 998 999 1000
		mc 0 4 1599 1602 1601 1600
		f 4 1466 1467 1468 1469
		mu 0 4 1001 1002 1003 1004
		mc 0 4 1603 1606 1605 1604
		f 4 -1465 1470 1471 1472
		mu 0 4 1000 999 1005 1006
		mc 0 4 1600 1601 1608 1607
		f 4 -1460 1473 1474 1475
		mu 0 4 995 994 1007 1008
		mc 0 4 1597 1598 1610 1609
		f 4 -1457 1476 1477 1478
		mu 0 4 992 991 1009 1010
		mc 0 4 1592 1593 1611 1608
		f 4 -1472 1479 1480 1481
		mu 0 4 1006 1005 1011 1012
		mc 0 4 1607 1608 1613 1612
		f 4 1482 1483 1484 -1477
		mu 0 4 1013 1014 1015 1016
		mc 0 4 1593 1615 1614 1611
		f 4 1485 1486 1487 1488
		mu 0 4 997 1017 1018 1019
		mc 0 4 1599 1618 1617 1616
		f 4 1491 2403 1489 1490
		mu 0 4 1020 1021 998 1022
		mc 0 4 1620 1619 2829 2830
		f 4 -1475 1492 1493 1494
		mu 0 4 1008 1007 1023 1024
		mc 0 4 1609 1610 1623 1622
		f 4 -1481 1495 -1467 1496
		mu 0 4 1012 1011 1025 1026
		mc 0 4 1612 1613 1606 1603
		f 4 1497 1498 -1468 -1496
		mu 0 4 1011 1027 1003 1025
		mc 0 4 1613 1624 1605 1606
		f 4 1499 1500 -1469 -1499
		mu 0 4 1027 1028 1004 1003
		mc 0 4 1624 1625 1604 1605
		f 3 1501 1502 1503
		mu 0 3 1029 1030 1031
		mc 0 3 1626 1628 1627
		f 3 -1503 1504 1505
		mu 0 3 1031 1030 1032
		mc 0 3 1627 1628 1629
		f 3 1506 -1505 1507
		mu 0 3 1033 1032 1030
		mc 0 3 1630 1629 1628
		f 3 1508 -1464 1509
		mu 0 3 1034 1035 1036
		mc 0 3 1631 1601 1602
		f 4 1510 2402 -1510 -2404
		mu 0 4 1037 1038 1034 1036
		mc 0 4 1619 1632 1631 2828
		f 4 1511 1512 1513 -1511
		mu 0 4 1037 989 1039 1038
		mc 0 4 1619 1591 1633 1632
		f 4 -1512 -1492 1514 1515
		mu 0 4 1040 1021 1020 1041
		mc 0 4 1591 1619 1620 1634
		f 4 1516 1517 -1507 1518
		mu 0 4 1039 1042 1043 1033
		mc 0 4 1633 1635 1629 1630
		f 4 1519 1520 -1506 -1518
		mu 0 4 1042 1044 1045 1043
		mc 0 4 1635 1636 1627 1629
		f 4 -1521 1521 1522 -1504
		mu 0 4 1046 1047 1034 1029
		mc 0 4 1627 1636 1631 1626
		f 4 1523 -1502 -1523 -2403
		mu 0 4 1038 1030 1029 1034
		mc 0 4 1632 1628 1626 2827
		f 4 -1514 -1519 -1508 -1524
		mu 0 4 1038 1039 1033 1030
		mc 0 4 1632 1633 1630 1628
		f 3 -1522 1524 1525
		mu 0 3 1034 1047 1048
		mc 0 3 1631 1636 1608
		f 3 -1526 -1471 -1509
		mu 0 3 1034 1048 1035
		mc 0 3 1631 1608 1601
		f 4 1526 1527 1528 1529
		mu 0 4 1049 1050 1051 1052
		mc 0 4 1637 2350 2347 2346
		f 4 1530 1531 -1527 1532
		mu 0 4 1053 1054 1050 1049
		mc 0 4 1640 1641 2070 2071
		f 4 1533 1534 1535 1536
		mu 0 4 1055 1056 1057 1058
		mc 0 4 1642 1645 1644 1643
		f 4 -1536 1537 1538 1539
		mu 0 4 1058 1057 1059 1060
		mc 0 4 1643 1644 1647 1646
		f 4 1540 1541 -1534 1542
		mu 0 4 1061 1062 1056 1055
		mc 0 4 1648 1649 1645 1642
		f 4 1544 1545 1546 -1549
		mu 0 4 1063 1064 1065 1054
		mc 0 4 1652 1654 1653 1641
		f 4 1547 1548 -1531 1549
		mu 0 4 1066 1063 1054 1053
		mc 0 4 1655 1652 1641 1640
		f 4 2255 2236 1552 1553
		mu 0 4 1067 1068 1069 1070
		mc 0 4 2219 2201 1658 1657
		f 4 2246 2237 1556 -2237
		mu 0 4 1068 1071 1072 1069
		mc 0 4 2202 2203 1659 1658
		f 4 1558 2248 2239 1561
		mu 0 4 1073 1074 1075 1076
		mc 0 4 1663 2205 2207 1664
		f 4 1563 2118 -1528 1562
		mu 0 4 1077 1078 1051 1050
		mc 0 4 2365 2363 2349 3195
		f 4 1564 1565 1566 1567
		mu 0 4 1079 1080 1081 1082
		mc 0 4 1669 1672 1671 1670
		f 4 2253 2244 1571 1572
		mu 0 4 1083 1084 1085 1086
		mc 0 4 2215 2217 1678 1677
		f 4 1573 2250 2241 1576
		mu 0 4 1087 1088 1089 1090
		mc 0 4 1680 2209 2211 1681
		f 4 -2240 2249 -1574 1578
		mu 0 4 1091 1092 1088 1087
		mc 0 4 1664 2208 2210 1680
		f 4 -2238 2247 -1559 1580
		mu 0 4 1072 1071 1074 1073
		mc 0 4 1659 2204 2206 1663
		f 4 1581 1582 1583 1584
		mu 0 4 1093 1094 1095 1096
		mc 0 4 1684 1687 1686 1685
		f 4 -1585 1585 -1566 1586
		mu 0 4 1093 1096 1097 1098
		mc 0 4 1684 1685 1671 1672
		f 4 -1568 1587 -1546 1588
		mu 0 4 1079 1082 1065 1064
		mc 0 4 1669 1670 1653 1654
		f 4 1589 1590 -1564 1591
		mu 0 4 1099 1100 1078 1077
		mc 0 4 2370 2372 2364 2366
		f 4 1592 1593 -1590 1594
		mu 0 4 1101 1102 1100 1099
		mc 0 4 1690 2374 2373 2371
		f 4 1595 1596 -1593 1597
		mu 0 4 1103 1104 1105 1106
		mc 0 4 1691 2375 2072 2073
		f 4 1598 1599 -1596 1600
		mu 0 4 1107 1108 1104 1103
		mc 0 4 1692 1693 2074 2075
		f 4 1602 1603 1604 1605
		mu 0 4 1109 1110 1111 1112
		mc 0 4 1696 1699 1698 1697
		f 4 1606 1607 1608 1609
		mu 0 4 1113 1114 1115 1116
		mc 0 4 1700 1703 1702 1701
		f 4 1613 1614 1615 1616
		mu 0 4 1117 1118 1119 1120
		mc 0 4 1708 1711 1710 1709
		f 4 1619 1620 1621 1622
		mu 0 4 1121 1122 1123 1124
		mc 0 4 1712 1715 1714 1713
		f 4 1623 1624 1625 1626
		mu 0 4 1125 1126 1127 1128
		mc 0 4 2391 2398 1718 2394
		f 4 1627 -1627 1628 1629
		mu 0 4 1129 1125 1128 1124
		mc 0 4 2400 2392 2395 2389
		f 4 1630 1631 1632 1633
		mu 0 4 1130 1113 1131 1132
		mc 0 4 1721 1700 1723 1722
		f 4 1634 1635 1636 -1603
		mu 0 4 1109 1133 1114 1110
		mc 0 4 1696 1724 1703 1699
		f 4 2705 2690 1638 1639
		mu 0 4 1134 1135 1136 1137
		mc 0 4 3397 3399 1726 1725
		f 4 1641 2708 2693 1643
		mu 0 4 1138 1139 1140 1141
		mc 0 4 1728 3403 3405 1729
		f 4 1644 1645 1646 1647
		mu 0 4 1142 1143 1144 1129
		mc 0 4 1732 1734 1733 1720
		f 4 1648 -1628 -1647 1649
		mu 0 4 1145 1125 1129 1144
		mc 0 4 2407 2393 2401 2405
		f 4 -1632 -1610 1650 1651
		mu 0 4 1131 1113 1116 1146
		mc 0 4 1723 1700 1701 1735
		f 4 -1624 -1649 1652 1653
		mu 0 4 1126 1125 1145 1147
		mc 0 4 1719 1716 2408 2410
		f 4 1654 1655 1656 1657
		mu 0 4 1148 1149 1150 1151
		mc 0 4 1736 1739 1738 1737
		f 4 1658 1659 1660 -1604
		mu 0 4 1110 1130 1152 1111
		mc 0 4 1699 1721 1740 1698
		f 4 -1636 1661 1662 -1608
		mu 0 4 1114 1133 1153 1115
		mc 0 4 1703 1724 1741 1702
		f 4 1663 -1648 -1630 -1622
		mu 0 4 1123 1142 1129 1124
		mc 0 4 1714 1732 1720 1713
		f 4 1664 1665 -1626 1666
		mu 0 4 1154 1155 1128 1127
		mc 0 4 2412 1743 2078 2396
		f 4 -1666 1667 -1623 -1629
		mu 0 4 1128 1155 1121 1124
		mc 0 4 1717 2080 2388 2390
		f 4 -1607 -1631 -1659 -1637
		mu 0 4 1114 1113 1130 1110
		mc 0 4 1703 1700 1721 1699
		f 4 1669 1670 1671 1672
		mu 0 4 1156 1157 1158 1159
		mc 0 4 2517 2518 2519 2520
		f 4 1673 -1488 1674 1675
		mu 0 4 1160 1161 1162 1163
		mc 0 4 2521 2522 2523 2524
		f 4 1676 1677 1678 1679
		mu 0 4 1164 1165 1166 1167
		mc 0 4 1752 1755 1754 1753
		f 4 -1678 1680 1681 1682
		mu 0 4 1166 1165 1168 1169
		mc 0 4 1754 1755 1757 1756
		f 4 -1515 1683 1684 1685
		mu 0 4 1170 1171 1172 1173
		mc 0 4 2525 2526 2527 2528
		f 4 -1684 -1491 1686 1687
		mu 0 4 1172 1171 1174 1175
		mc 0 4 1758 2529 2530 2531
		f 4 1688 1689 1690 1691
		mu 0 4 1176 1177 1178 1179
		mc 0 4 2532 2533 2534 2535
		f 4 1692 -1686 1693 1694
		mu 0 4 1180 1170 1173 1181
		mc 0 4 2536 2537 2538 2539
		f 4 1695 1696 1697 1698
		mu 0 4 1182 1183 1184 1185
		mc 0 4 1765 1768 1767 1766
		f 4 1699 1700 1701 1702
		mu 0 4 1186 1187 1188 1189
		mc 0 4 1769 1772 1771 1770
		f 4 1703 -1680 1704 1705
		mu 0 4 1190 1164 1167 1191
		mc 0 4 1773 1752 1753 1774
		f 4 1706 1707 -1696 1708
		mu 0 4 1192 1193 1183 1182
		mc 0 4 1775 1776 1768 1765
		f 4 1709 -1714 -1704 1710
		mu 0 4 1194 1195 1164 1190
		mc 0 4 1777 1778 1752 1773
		f 4 1711 1712 -1677 1713
		mu 0 4 1195 1196 1165 1164
		mc 0 4 1778 1779 1755 1752
		f 4 -1681 -1713 2404 1714
		mu 0 4 1168 1165 1196 1197
		mc 0 4 1757 1755 1779 1780
		f 4 1715 1716 1717 -1700
		mu 0 4 1186 1198 1199 1187
		mc 0 4 1769 1782 1781 1772
		f 4 -1694 1719 -1710 1720
		mu 0 4 1181 1173 1195 1194
		mc 0 4 2081 2082 1778 1777
		f 4 -1685 1721 -1712 -1720
		mu 0 4 1173 1172 1196 1195
		mc 0 4 2082 2083 1779 1778
		f 4 -1722 -1688 1722 -2405
		mu 0 4 1196 1172 1175 1197
		mc 0 4 1779 2083 2084 1780
		f 4 1723 -1676 1724 -1717
		mu 0 4 1198 1160 1163 1199
		mc 0 4 1782 2085 2086 1781
		f 4 -1672 1726 -1707 1727
		mu 0 4 1159 1158 1193 1192
		mc 0 4 2087 2088 1776 1775
		f 4 2559 2542 1730 1731
		mu 0 4 1200 1201 1202 1203
		mc 0 4 3088 3090 1787 1786
		f 4 -1668 1732 1733 1734
		mu 0 4 1204 1205 1206 1207
		mc 0 4 2089 2090 1790 1789
		f 4 1735 1736 1737 1738
		mu 0 4 1208 1209 1210 1211
		mc 0 4 1791 1794 1793 1792
		f 4 -1738 1739 2601 2597
		mu 0 4 1212 1213 1214 1215
		mc 0 4 1792 1793 3204 3206
		f 4 1743 2425 -1741 1742
		mu 0 4 1216 1217 1218 1219
		mc 0 4 1798 2831 1797 1796
		f 4 -1665 1744 1745 -1733
		mu 0 4 1205 1220 1221 1206
		mc 0 4 2090 2091 1799 1790
		f 4 1746 1747 1748 1749
		mu 0 4 1222 1223 1224 1225
		mc 0 4 2416 2415 1801 2414
		f 4 1750 1751 1752 1753
		mu 0 4 1226 1227 1207 1228
		mc 0 4 1803 1805 1789 1804
		f 4 1754 1755 1756 -1662
		mu 0 4 1229 1230 1231 1232
		mc 0 4 2092 1807 1806 2093
		f 4 1757 -1755 -1635 1758
		mu 0 4 1233 1230 1229 1234
		mc 0 4 1808 1807 2092 2094
		f 4 -1750 2531 -1736 1759
		mu 0 4 1222 1225 1209 1208
		mc 0 4 2417 1800 3058 3059
		f 4 1995 2540 -1995 -1762
		mu 0 4 1235 1223 1236 1228
		mc 0 4 1811 3086 2123 1804
		f 4 1760 1761 -1753 -1734
		mu 0 4 1206 1235 1228 1207
		mc 0 4 1790 1811 1804 1789
		f 4 1762 -1761 -1746 1763
		mu 0 4 1237 1235 1206 1221
		mc 0 4 1812 1811 1790 1799
		f 4 1764 -1620 -1735 -1752
		mu 0 4 1227 1238 1204 1207
		mc 0 4 1805 2096 2089 1789
		f 4 1765 -1744 1766 -1756
		mu 0 4 1230 1217 1216 1231
		mc 0 4 1807 3318 1798 1806
		f 4 -1759 -1606 1767 1768
		mu 0 4 1233 1234 1239 1240
		mc 0 4 1808 2094 2097 1813
		f 4 -2406 -1766 -1758 1769
		mu 0 4 1241 1217 1230 1233
		mc 0 4 1809 3319 1807 1808
		f 4 1770 -2308 -2321 2313
		mu 0 4 1242 1243 1244 1245
		mc 0 4 1815 1814 2674 2675
		f 4 1772 -2316 -1825 1771
		mu 0 4 1246 1247 1248 1249
		mc 0 4 1816 2667 2668 3075
		f 4 -2453 2473 2453 -2434
		mu 0 4 1250 1251 1252 1253
		mc 0 4 2877 2909 2910 2876
		f 4 1774 1825 -2318 2310
		mu 0 4 1254 1255 1256 1257
		mc 0 4 1820 1819 2669 2670
		f 4 1775 1824 -2315 2307
		mu 0 4 1258 1249 1248 1259
		mc 0 4 1814 1817 2665 2666
		f 4 1776 1826 -2319 -1826
		mu 0 4 1255 1260 1261 1256
		mc 0 4 1819 1818 2671 2672
		f 4 1777 1778 1779 1780
		mu 0 4 1262 1263 1264 1265
		mc 0 4 1821 1824 1823 1822
		f 4 1783 2536 1781 1782
		mu 0 4 1266 1267 1268 1269
		mc 0 4 1827 1826 3078 3079
		f 4 1786 2537 1784 1785
		mu 0 4 1270 1271 1272 1273
		mc 0 4 2500 2501 3084 3085
		f 4 1787 1788 1789 1790
		mu 0 4 1274 1275 1276 1277
		mc 0 4 2502 2503 2504 2505
		f 4 2475 2455 -2436 2415
		mu 0 4 1278 1279 1280 1281
		mc 0 4 2912 2914 2879 2850
		f 4 1793 1794 1795 1796
		mu 0 4 1282 1283 1284 1285
		mc 0 4 1836 1839 1838 1837
		f 4 -1780 1797 -1782 1798
		mu 0 4 1286 1287 1269 1268
		mc 0 4 1822 1823 1828 1825
		f 4 -1796 1799 -1792 1800
		mu 0 4 1285 1284 1288 1289
		mc 0 4 1837 1838 1835 1834
		f 4 1801 1802 1803 1804
		mu 0 4 1290 1291 1292 1293
		mc 0 4 2506 2507 2508 2509
		f 4 2478 2458 -2439 -1942
		mu 0 4 1294 1295 1296 1297
		mc 0 4 2918 2920 2882 2857
		f 4 1806 1807 -1788 1808
		mu 0 4 1298 1299 1275 1274
		mc 0 4 1844 2510 2511 1831
		f 4 -1804 1809 -1785 1810
		mu 0 4 1300 1301 1273 1272
		mc 0 4 1841 2512 2513 2099
		f 4 1811 1812 1813 -1779
		mu 0 4 1263 1302 1303 1264
		mc 0 4 1824 1847 1846 1823
		f 4 1816 -1783 1814 1815
		mu 0 4 1304 1266 1269 1305
		mc 0 4 1848 1827 3080 3081
		f 4 -2456 2476 2456 -2437
		mu 0 4 1280 1279 1306 1307
		mc 0 4 2853 2915 2916 2880
		f 4 1819 1820 1821 -1795
		mu 0 4 1283 1308 1309 1284
		mc 0 4 1839 1852 1851 1838
		f 4 -1814 1822 -1815 -1798
		mu 0 4 1287 1310 1305 1269
		mc 0 4 1823 1846 1849 1828
		f 4 -1822 1823 -1818 -1800
		mu 0 4 1284 1309 1311 1288
		mc 0 4 1838 1851 1850 1835
		f 4 2314 2308 2102 2101
		mu 0 4 1259 1248 1312 1313
		mc 0 4 2653 2655 1971 1970
		f 4 2309 2535 -2309 2315
		mu 0 4 1247 1314 1312 1248
		mc 0 4 2656 1972 3073 3074
		f 4 2317 2311 2105 -2104
		mu 0 4 1257 1256 1315 1316
		mc 0 4 2658 2660 1974 1973
		f 4 -2312 2318 2312 2106
		mu 0 4 1315 1256 1261 1317
		mc 0 4 2448 2661 2662 2449
		f 4 2472 2452 -2433 2412
		mu 0 4 1318 1251 1250 1319
		mc 0 4 2906 2908 2846 2844
		f 4 2320 -2102 2109 -2108
		mu 0 4 1245 1244 1320 1321
		mc 0 4 2663 2654 2447 2451
		f 4 1827 -1809 1828 -1821
		mu 0 4 1308 1298 1274 1309
		mc 0 4 1852 2100 2101 1851
		f 4 -1829 -1791 1829 -1824
		mu 0 4 1309 1274 1277 1311
		mc 0 4 1851 2101 2102 1850
		f 4 -2457 2477 1941 -2438
		mu 0 4 1307 1306 1294 1297
		mc 0 4 2855 2917 2919 2881
		f 4 1830 -1805 1831 -1813
		mu 0 4 1302 1290 1293 1303
		mc 0 4 1847 2103 2104 1846
		f 4 -1832 -1811 1832 -1823
		mu 0 4 1310 1300 1272 1305
		mc 0 4 1846 2104 1829 1849
		f 4 1833 -1816 -1833 -2538
		mu 0 4 1271 1304 1305 1272
		mc 0 4 1830 1848 3082 3083
		f 4 1834 1835 1836 -1789
		mu 0 4 1322 1323 1324 1325
		mc 0 4 1833 1854 1853 1832
		f 4 -1803 1837 1838 1839
		mu 0 4 1326 1327 1328 1329
		mc 0 4 1842 1843 1856 1855
		f 4 1840 1841 1842 1843
		mu 0 4 1330 1331 1332 1333
		mc 0 4 1857 1860 1859 1858
		f 4 1844 2572 2555 1847
		mu 0 4 1334 1335 1336 1337
		mc 0 4 1845 3114 3116 1861
		f 4 1848 1849 2574 2557
		mu 0 4 1338 1339 1340 1341
		mc 0 4 1863 1866 3118 3120
		f 4 1852 1853 1854 1855
		mu 0 4 1342 1343 1344 1345
		mc 0 4 1867 1870 1869 1868
		f 4 2685 2678 2460 -2678
		mu 0 4 1346 1347 1348 1349
		mc 0 4 3374 3375 2923 2885
		f 4 2586 1859 1860 2652
		mu 0 4 1350 1351 1352 1353
		mc 0 4 3179 1873 3193 3194
		f 4 2590 2587 1862 -2587
		mu 0 4 1350 1354 1355 1351
		mc 0 4 3180 3181 1874 1873
		f 4 2592 2589 1865 1866
		mu 0 4 1356 1357 1358 1359
		mc 0 4 3183 3185 1878 1877
		f 4 2483 2463 -2444 2423
		mu 0 4 1360 1361 1362 1363
		mc 0 4 2927 2929 2890 2891
		f 4 -1840 1869 1870 -1810
		mu 0 4 1326 1329 1364 1365
		mc 0 4 1842 1855 1882 2098
		f 4 -1855 1872 -1864 1873
		mu 0 4 1345 1344 1366 1367
		mc 0 4 1868 1869 1879 1876
		f 4 -1835 -1808 -1848 1874
		mu 0 4 1323 1322 1368 1369
		mc 0 4 1854 1833 1845 1861
		f 4 -1842 1875 -1849 1876
		mu 0 4 1332 1331 1370 1371
		mc 0 4 1859 1860 1866 1863
		f 4 -1846 -1786 -1871 1877
		mu 0 4 1372 1373 1374 1375
		mc 0 4 1862 2105 2098 1882
		f 4 2539 -1851 2538 -1853
		mu 0 4 1376 1377 1378 1379
		mc 0 4 1867 1864 1865 1870
		f 4 1878 2443 2424 -1866
		mu 0 4 1358 1363 1362 1380
		mc 0 4 1878 2866 2868 1877
		f 4 -2461 2481 2461 -2442
		mu 0 4 1349 1348 1381 1382
		mc 0 4 2888 2924 2925 2887
		f 4 -2425 -2464 -1869 2578
		mu 0 4 1383 1384 1385 1386
		mc 0 4 1877 2869 2930 3161
		f 4 2576 -1856 2485 -1877
		mu 0 4 1338 1376 1387 1388
		mc 0 4 1863 1867 1868 1859
		f 4 -2459 2479 1942 -2440
		mu 0 4 1389 1390 1391 1392
		mc 0 4 2884 2921 2922 2883
		f 4 2427 2408 1881 1882
		mu 0 4 1393 1394 1395 1396
		mc 0 4 2834 2836 1884 1883
		f 4 1883 1884 1885 1886
		mu 0 4 1397 1396 1398 1399
		mc 0 4 1885 1883 1887 1886
		f 4 1889 2468 2448 -2429
		mu 0 4 1394 1400 1401 1402
		mc 0 4 2837 2898 2900 2875
		f 4 1890 1891 1892 1893
		mu 0 4 1395 1403 1404 1405
		mc 0 4 1884 1892 1891 1890
		f 4 1894 1895 1896 1897
		mu 0 4 1406 1407 1408 1409
		mc 0 4 1893 1896 1895 1894
		f 4 -1729 2532 1898 1899
		mu 0 4 1410 1411 1412 1413
		mc 0 4 1788 1785 3062 3063
		f 4 -1731 1900 -1895 1901
		mu 0 4 1203 1202 1407 1406
		mc 0 4 1786 1787 1896 1893
		f 4 -1886 1902 -1899 1903
		mu 0 4 1414 1415 1413 1412
		mc 0 4 1886 1887 1898 1897
		f 4 1904 1905 1906 1907
		mu 0 4 1416 1417 1418 1419
		mc 0 4 1899 1902 1901 1900
		f 4 1908 1909 1910 1911
		mu 0 4 1420 1421 1422 1423
		mc 0 4 1903 1906 1905 1904
		f 4 -1893 1912 1913 1914
		mu 0 4 1424 1425 1426 1427
		mc 0 4 1890 1891 1908 1907
		f 4 -1911 1915 -1888 1916
		mu 0 4 1423 1422 1428 1429
		mc 0 4 1904 1905 1889 1888
		f 4 1918 2533 -1914 1917
		mu 0 4 1430 1431 1427 1426
		mc 0 4 1910 1909 3065 3066
		f 4 1919 1920 1921 1922
		mu 0 4 1432 1433 1434 1435
		mc 0 4 1911 1914 1913 1912
		f 4 -1907 1923 1924 1925
		mu 0 4 1436 1437 1438 1439
		mc 0 4 1900 1901 1916 1915
		f 4 -1922 1926 1927 1928
		mu 0 4 1435 1434 1440 1441
		mc 0 4 1912 1913 1918 1917
		f 4 1930 2534 -1925 1929
		mu 0 4 1442 1443 1439 1438
		mc 0 4 1920 1919 3069 3070
		f 4 2428 2409 -1891 -2409
		mu 0 4 1394 1402 1403 1395
		mc 0 4 2837 2838 1892 1884
		f 4 2470 2450 -2431 2410
		mu 0 4 1444 1445 1446 1447
		mc 0 4 2902 2904 2842 2840
		f 4 2426 -1883 -1884 1933
		mu 0 4 1448 1393 1396 1397
		mc 0 4 2832 2835 1883 1885
		f 4 -1882 -1894 1934 -1885
		mu 0 4 1396 1395 1405 1398
		mc 0 4 1883 1884 1890 1887
		f 4 1935 -1917 -1933 -1896
		mu 0 4 1407 1423 1429 1408
		mc 0 4 1896 1904 1888 1895
		f 4 1936 -1900 1937 -2534
		mu 0 4 1431 1410 1413 1427
		mc 0 4 1909 1788 1898 3064
		f 4 1938 -1912 -1936 -1901
		mu 0 4 1202 1420 1423 1407
		mc 0 4 1787 1903 1904 1896
		f 4 -1935 -1915 -1938 -1903
		mu 0 4 1415 1424 1427 1413
		mc 0 4 1887 1890 1907 1898
		f 4 2430 2411 -1905 1939
		mu 0 4 1447 1446 1417 1416
		mc 0 4 2840 2842 1902 1899
		f 4 2432 2413 2107 2108
		mu 0 4 1319 1250 1245 1321
		mc 0 4 2844 2846 2664 2450
		f 4 2435 2416 -1778 1940
		mu 0 4 1281 1280 1263 1262
		mc 0 4 2850 2852 1824 1821
		f 4 2436 2417 -1812 -2417
		mu 0 4 1280 1307 1302 1263
		mc 0 4 2853 2854 1847 1824
		f 4 2437 2418 -1831 -2418
		mu 0 4 1307 1297 1290 1302
		mc 0 4 2855 2856 2103 1847
		f 4 2438 2419 -1802 -2419
		mu 0 4 1297 1296 1291 1290
		mc 0 4 2857 2858 2514 1840
		f 4 -1838 -2420 2439 2420
		mu 0 4 1328 1327 1389 1392
		mc 0 4 1856 1843 2859 2860
		f 4 -2677 2684 2677 2421
		mu 0 4 1449 1450 1346 1349
		mc 0 4 1881 3372 3373 2862
		f 4 -2422 2441 2422 -1868
		mu 0 4 1449 1349 1382 1451
		mc 0 4 1881 2863 2864 1880
		f 4 -1655 1943 1944 1945
		mu 0 4 1149 1148 1452 1453
		mc 0 4 1739 1736 1922 1921
		f 4 1946 -1612 1947 -1529
		mu 0 4 1454 1455 1456 1457
		mc 0 4 2348 2379 2106 1638
		f 4 1948 -1602 1949 -1539
		mu 0 4 1458 1459 1460 1461
		mc 0 4 2107 1694 1695 2108
		f 4 -1770 -1769 1950 1951
		mu 0 4 1241 1233 1240 1462
		mc 0 4 1809 1808 1813 1923
		f 4 1952 1953 -1660 -1634
		mu 0 4 1132 1463 1152 1130
		mc 0 4 1722 1924 1740 1721
		f 4 -1951 1954 -1751 1955
		mu 0 4 1462 1240 1464 1465
		mc 0 4 1923 1813 1805 1803
		f 4 1956 -1765 -1955 -1768
		mu 0 4 1239 1466 1464 1240
		mc 0 4 2097 2096 1805 1813
		f 4 -1957 -1605 1957 -1621
		mu 0 4 1467 1112 1111 1468
		mc 0 4 1715 1697 1698 1714
		f 4 1958 -1664 -1958 -1661
		mu 0 4 1152 1469 1468 1111
		mc 0 4 1740 1732 1714 1698
		f 4 -1959 -1954 1959 -1645
		mu 0 4 1469 1152 1463 1470
		mc 0 4 1732 1740 1924 1734
		f 4 2284 2267 1961 1962
		mu 0 4 1471 1472 1473 1474
		mc 0 4 2568 2570 1926 1925
		f 4 1963 2283 -1963 1964
		mu 0 4 1475 1476 1471 1474
		mc 0 4 1927 2566 2569 1925
		f 4 2282 -1964 1965 1966
		mu 0 4 1477 1478 1479 1480
		mc 0 4 2564 2567 2112 1928
		f 4 1967 2281 -1967 1968
		mu 0 4 1481 1482 1477 1480
		mc 0 4 2420 2562 2565 2418
		f 4 2280 -1968 1969 1970
		mu 0 4 1483 1482 1481 1484
		mc 0 4 2560 2563 2421 2423
		f 4 2561 2544 -1909 1972
		mu 0 4 1485 1486 1421 1420
		mc 0 4 3092 3094 1906 1903
		f 4 2563 2546 -1920 1974
		mu 0 4 1487 1488 1433 1432
		mc 0 4 3096 3098 1914 1911
		f 4 2565 2548 2103 2104
		mu 0 4 1489 1490 1257 1316
		mc 0 4 3100 3102 2659 1973
		f 4 2568 2551 -1794 1977
		mu 0 4 1491 1492 1283 1282
		mc 0 4 3106 3108 1839 1836
		f 4 2569 2552 -1820 -2552
		mu 0 4 1492 1493 1308 1283
		mc 0 4 3109 3110 1852 1839
		f 4 2570 2553 -1828 -2553
		mu 0 4 1493 1494 1298 1308
		mc 0 4 3111 3112 2100 1852
		f 4 2571 -1845 -1807 -2554
		mu 0 4 1494 1495 1299 1298
		mc 0 4 3113 3115 2113 2515
		f 4 2560 -1973 -1939 -2543
		mu 0 4 1201 1485 1420 1202
		mc 0 4 3091 3093 1903 1787
		f 4 2645 2628 -1969 1981
		mu 0 4 1496 1497 1481 1480
		mc 0 4 3270 3272 2422 2419
		f 4 -1970 -2629 2646 2629
		mu 0 4 1484 1481 1497 1498
		mc 0 4 1930 1929 3273 3274
		f 4 1984 -1601 1985 -1584
		mu 0 4 1095 1107 1103 1096
		mc 0 4 1686 1692 2075 1685
		f 4 -1986 -1598 1986 -1586
		mu 0 4 1096 1103 1106 1097
		mc 0 4 1685 2075 2115 1671
		f 4 -1987 -1595 1987 -1567
		mu 0 4 1081 1101 1099 1082
		mc 0 4 2116 2117 2118 2119
		f 4 -1988 -1592 1988 -1588
		mu 0 4 1082 1099 1077 1065
		mc 0 4 2120 1688 2367 2352
		f 4 -1547 -1989 -1563 -1532
		mu 0 4 1054 1065 1077 1050
		mc 0 4 2122 2121 1668 2362
		f 4 1991 -1990 -1956 1992
		mu 0 4 1499 1500 1462 1465
		mc 0 4 1933 1932 1923 1803
		f 4 1993 -1993 -1754 1994
		mu 0 4 1236 1501 1226 1228
		mc 0 4 2123 1933 1803 1804
		f 4 -1748 -1996 -1763 1996
		mu 0 4 1224 1223 1235 1237
		mc 0 4 1934 2124 1811 1812
		f 4 -1557 1997 -1545 1998
		mu 0 4 1069 1072 1064 1063
		mc 0 4 1658 1659 1654 1652
		f 4 -1998 -1581 1999 -1589
		mu 0 4 1064 1072 1073 1079
		mc 0 4 1654 1659 1663 1669
		f 4 -2000 -1562 2000 -1565
		mu 0 4 1079 1073 1076 1080
		mc 0 4 1669 1663 1664 1672
		f 4 -1587 -2001 -1579 2001
		mu 0 4 1093 1098 1091 1087
		mc 0 4 1684 1672 1664 1680
		f 4 -2002 -1577 2002 -1582
		mu 0 4 1093 1087 1090 1094
		mc 0 4 1684 1680 1681 1687
		f 4 -1572 2004 -1541 2005
		mu 0 4 1086 1085 1062 1061
		mc 0 4 1677 1678 1649 1648
		f 4 -1553 -1999 -1548 2006
		mu 0 4 1070 1069 1063 1066
		mc 0 4 1657 1658 1652 1655
		f 4 -1703 2007 -1682 2008
		mu 0 4 1502 1503 1169 1168
		mc 0 4 1769 1770 1756 1757
		f 4 2009 -1716 -2009 -1715
		mu 0 4 1197 1504 1502 1168
		mc 0 4 1780 1782 1769 1757
		f 4 2010 -1724 -2010 -1723
		mu 0 4 1175 1505 1504 1197
		mc 0 4 2084 2085 1782 1780
		f 4 2011 -1674 -2011 -1687
		mu 0 4 1174 1506 1505 1175
		mc 0 4 2540 2541 1750 1759
		f 4 -1463 -1489 -2012 -1490
		mu 0 4 998 997 1019 1022
		mc 0 4 1602 1599 1616 1621
		f 4 2012 2013 2014 -1701
		mu 0 4 1187 1507 1508 1188
		mc 0 4 1772 1936 1935 1771
		f 4 2015 2016 -2013 -1718
		mu 0 4 1199 1509 1507 1187
		mc 0 4 1781 1937 1936 1772
		f 4 2017 2018 -2016 -1725
		mu 0 4 1163 1176 1509 1199
		mc 0 4 2086 2125 1937 1781
		f 4 2019 -1689 -2018 -1675
		mu 0 4 1162 1177 1176 1163
		mc 0 4 2542 2543 1760 1751
		f 4 2020 2021 -2020 -1487
		mu 0 4 1017 1510 1511 1018
		mc 0 4 1618 1938 1762 1617
		f 4 2022 -1473 2023 2024
		mu 0 4 1512 1000 1006 1513
		mc 0 4 1939 1600 1607 1940
		f 4 -2024 -1482 2025 2026
		mu 0 4 1513 1006 1012 1514
		mc 0 4 1940 1607 1612 1941
		f 4 -2026 -1497 2027 2028
		mu 0 4 1514 1012 1026 1515
		mc 0 4 1941 1612 1603 1942
		f 4 -2028 -1470 2029 2030
		mu 0 4 1516 1001 1004 1517
		mc 0 4 1942 1603 1604 1943
		f 4 2031 2032 -2030 -1501
		mu 0 4 1028 1518 1517 1004
		mc 0 4 1625 1944 1943 1604
		f 4 2033 2034 2035 -1476
		mu 0 4 1008 1518 1519 995
		mc 0 4 1609 1944 1945 1597
		f 4 2036 -1484 2037 2038
		mu 0 4 1519 1015 1014 1520
		mc 0 4 1945 1614 1615 1946
		f 4 2039 2040 -1670 2041
		mu 0 4 1521 1522 1523 1524
		mc 0 4 1947 1948 1749 1746
		f 4 -2023 2042 -1486 -1466
		mu 0 4 1000 1512 1017 997
		mc 0 4 1600 1939 1618 1599
		f 4 2043 2044 -1462 2045
		mu 0 4 1525 1526 993 996
		mc 0 4 1949 1938 1595 1596
		f 4 -2040 2046 -2038 2047
		mu 0 4 1522 1521 1520 1014
		mc 0 4 1948 1947 1946 1615
		f 4 2048 -2048 -1483 -1456
		mu 0 4 1527 1522 1014 1013
		mc 0 4 1594 1948 1615 1593
		f 4 -1478 2049 -1498 -1480
		mu 0 4 1005 1016 1027 1011
		mc 0 4 1608 1611 1624 1613
		f 4 -1500 -2050 -1485 2050
		mu 0 4 1028 1027 1016 1015
		mc 0 4 1625 1624 1611 1614
		f 4 -1698 2051 2052 2053
		mu 0 4 1185 1184 1528 1529
		mc 0 4 1766 1767 1951 1950;
	setAttr ".fc[1000:1359]"
		f 4 -1705 2054 2055 2056
		mu 0 4 1191 1167 1530 1531
		mc 0 4 1774 1753 1953 1952
		f 4 2057 2058 -2055 -1679
		mu 0 4 1166 1532 1530 1167
		mc 0 4 1754 1954 1953 1753
		f 4 2059 2060 2061 -1580
		mu 0 4 1533 1532 1534 1535
		mc 0 4 2356 2428 2429 2360
		f 4 2062 2063 2064 -2008
		mu 0 4 1503 1536 1534 1169
		mc 0 4 1770 1956 2127 1756
		f 4 2065 2066 -2063 -1702
		mu 0 4 1188 1537 1538 1189
		mc 0 4 1771 1957 1956 1770
		f 4 2067 -2066 -2015 2068
		mu 0 4 1539 1537 1188 1508
		mc 0 4 1958 1957 1771 1935
		f 4 -1614 2070 2071 2072
		mu 0 4 1118 1117 1540 1541
		mc 0 4 1711 1708 1961 1960
		f 4 -2691 2706 2691 2074
		mu 0 4 1136 1135 1542 1543
		mc 0 4 2402 3400 3401 2433
		f 4 2704 -1640 2075 -2689
		mu 0 4 884 1134 1137 885
		mc 0 4 3396 3398 1725 1185
		f 4 -1289 2076 -1945 2077
		mu 0 4 886 887 1453 1452
		mc 0 4 1200 1964 1921 1922
		f 4 2079 -1292 2080 -1651
		mu 0 4 1116 889 888 1146
		mc 0 4 1701 1183 1187 1735
		f 4 2081 -1294 -2080 -1609
		mu 0 4 1115 890 889 1116
		mc 0 4 1702 1965 1183 1701
		f 4 2082 -1296 -2082 -1663
		mu 0 4 1153 891 890 1115
		mc 0 4 1741 1182 1965 1702
		f 4 2083 -1298 -2083 -1757
		mu 0 4 1231 893 892 1232
		mc 0 4 1806 1193 2035 2093
		f 4 2084 -1300 -2084 -1767
		mu 0 4 1216 894 893 1231
		mc 0 4 1798 1966 1193 1806
		f 4 2085 -1302 -2085 -1743
		mu 0 4 1219 895 894 1216
		mc 0 4 1796 1191 1966 1798
		f 4 2086 -2596 2600 -1740
		mu 0 4 1213 897 896 1214
		mc 0 4 1793 1967 3203 3205
		f 4 2087 -1306 -2087 -1737
		mu 0 4 1209 899 898 1210
		mc 0 4 1794 1190 1967 1793
		f 4 2088 -1309 -2088 -2532
		mu 0 4 1225 900 899 1209
		mc 0 4 2128 1192 1190 1794
		f 4 -1749 -2090 -1310 -2089
		mu 0 4 1225 1224 901 900
		mc 0 4 2128 1934 1189 1192
		f 4 -1313 2089 -1997 2090
		mu 0 4 902 901 1224 1237
		mc 0 4 1198 1189 1934 1812
		f 4 -1315 -2091 -1764 2091
		mu 0 4 903 902 1237 1221
		mc 0 4 1194 1198 1812 1799
		f 4 2092 -1316 -2092 -1745
		mu 0 4 1220 904 903 1221
		mc 0 4 2413 2438 2038 2129
		f 4 -1319 -2093 -1667 2093
		mu 0 4 905 906 1154 1127
		mc 0 4 2246 1968 1742 2397
		f 4 2094 -1320 -2094 -1625
		mu 0 4 1126 907 905 1127
		mc 0 4 2399 2243 1188 2079
		f 4 -1323 -2095 -1654 2095
		mu 0 4 908 907 1126 1147
		mc 0 4 2441 1184 2130 2411
		f 4 -2262 2279 -1971 2096
		mu 0 4 909 910 1483 1484
		mc 0 4 2250 2559 2561 2424
		f 4 2647 -1326 -2097 -2630
		mu 0 4 1498 911 909 1484
		mc 0 4 3275 3277 1197 2132
		f 4 2098 -1329 2099 -1615
		mu 0 4 1118 913 912 1119
		mc 0 4 1711 1196 1199 1710
		f 4 -1332 -2099 -2073 2100
		mu 0 4 914 913 1118 1541
		mc 0 4 1186 1196 1711 1960
		f 4 2110 -2107 2111 -1927
		mu 0 4 1434 1544 1545 1440
		mc 0 4 1913 2133 1975 1918
		f 4 2112 -2106 -2111 -1921
		mu 0 4 1433 1546 1544 1434
		mc 0 4 1914 2135 2133 1913
		f 4 2564 -2105 -2113 -2547
		mu 0 4 1488 1547 1546 1433
		mc 0 4 3099 3101 2135 1914
		f 4 -2114 -1930 2114 -2536
		mu 0 4 1548 1442 1438 1549
		mc 0 4 2136 1920 3071 3072
		f 4 2115 -2103 -2115 -1924
		mu 0 4 1437 1550 1549 1438
		mc 0 4 1901 2134 2137 1916
		f 4 2116 -2110 -2116 -1906
		mu 0 4 1417 1551 1552 1418
		mc 0 4 1902 1976 2134 1901
		f 4 2431 -2109 -2117 -2412
		mu 0 4 1446 1553 1551 1417
		mc 0 4 2843 2845 1976 1902
		f 4 2119 -1656 2614 1640
		mu 0 4 1455 1150 1149 1136
		mc 0 4 1707 1738 1739 3243
		f 4 -1354 -2076 -2121 -2077
		mu 0 4 887 885 1137 1453
		mc 0 4 1964 1963 1727 1921
		f 4 2642 2625 -1962 2210
		mu 0 4 1554 1555 1474 1473
		mc 0 4 3264 3266 1925 1926
		f 4 2643 2626 -1965 -2626
		mu 0 4 1555 1556 1475 1474
		mc 0 4 3267 3268 1927 1925
		f 4 -2627 2644 -1982 -1966
		mu 0 4 1479 1557 1496 1480
		mc 0 4 2112 3269 3271 1928
		f 4 -2045 -2021 -2043 2123
		mu 0 4 1558 1510 1017 1512
		mc 0 4 1595 1938 1618 1939
		f 4 -1459 -2124 -2025 2124
		mu 0 4 1559 1558 1512 1513
		mc 0 4 1598 1595 1939 1940
		f 4 -1474 -2125 -2027 2125
		mu 0 4 1560 1559 1513 1514
		mc 0 4 1610 1598 1940 1941
		f 4 -2126 -2029 2126 -1493
		mu 0 4 1560 1514 1515 1561
		mc 0 4 1610 1941 1942 1623
		f 4 -1494 -2127 -2031 2127
		mu 0 4 1024 1562 1516 1517
		mc 0 4 1622 1623 1942 1943
		f 4 -2034 -1495 -2128 -2033
		mu 0 4 1518 1008 1024 1517
		mc 0 4 1944 1609 1622 1943
		f 4 -1461 -2036 -2039 2128
		mu 0 4 996 995 1519 1520
		mc 0 4 1596 1597 1945 1946
		f 4 2129 -2046 -2129 -2047
		mu 0 4 1521 1525 996 1520
		mc 0 4 1947 1949 1596 1946
		f 4 -2042 2130 2131 -2130
		mu 0 4 1521 1524 1563 1525
		mc 0 4 1947 1746 1761 1949
		f 4 1725 2132 -1728 2133
		mu 0 4 1564 1179 1159 1192
		mc 0 4 1783 1784 2087 1775
		f 4 1718 -2134 -1709 2134
		mu 0 4 1565 1564 1192 1182
		mc 0 4 1744 1783 1775 1765
		f 4 1668 -2135 -1699 2135
		mu 0 4 1566 1565 1182 1185
		mc 0 4 1745 1744 1765 1766
		f 4 2136 2137 2138 -2169
		mu 0 4 1567 1529 1568 1569
		mc 0 4 1959 1950 2141 2142
		f 4 1568 2252 -1573 2139
		mu 0 4 1570 1571 1083 1086
		mc 0 4 1674 2214 2216 1677
		f 4 2003 -2140 -2006 2140
		mu 0 4 1572 1570 1086 1061
		mc 0 4 1650 1674 1677 1648
		f 4 1543 -2141 -1543 2141
		mu 0 4 1573 1572 1061 1055
		mc 0 4 1651 1650 1648 1642
		f 4 -2142 -1537 2142 1983
		mu 0 4 1573 1055 1058 1574
		mc 0 4 1651 1642 1643 1661
		f 4 1557 -2143 -1540 2143
		mu 0 4 1575 1574 1058 1060
		mc 0 4 1662 1661 1643 1646
		f 4 -1613 -1618 -2144 -1950
		mu 0 4 1460 1117 1576 1461
		mc 0 4 1695 1708 2076 2108
		f 4 2709 2694 2145 -2694
		mu 0 4 1140 1577 1540 1141
		mc 0 4 3406 3407 1961 1729
		f 4 -2032 -2051 -2037 -2035
		mu 0 4 1518 1028 1015 1519
		mc 0 4 1944 1625 1614 1945
		f 4 -1671 2146 -1695 2147
		mu 0 4 1158 1157 1180 1181
		mc 0 4 1748 2544 2545 1764
		f 4 -1727 -2148 -1721 2148
		mu 0 4 1193 1158 1181 1194
		mc 0 4 1776 2088 2081 1777
		f 4 -1708 -2149 -1711 2149
		mu 0 4 1183 1193 1194 1190
		mc 0 4 1768 1776 1777 1773
		f 4 -1697 -2150 -1706 2150
		mu 0 4 1184 1183 1190 1191
		mc 0 4 1767 1768 1773 1774
		f 4 2151 2152 2153 2154
		mu 0 4 1528 1531 1578 1579
		mc 0 4 1951 1952 2143 2144
		f 4 -2245 2254 -1554 2155
		mu 0 4 1085 1084 1067 1070
		mc 0 4 1678 2218 2220 1657
		f 4 -2005 -2156 -2007 2156
		mu 0 4 1062 1085 1070 1066
		mc 0 4 1649 1678 1657 1655
		f 4 -1542 -2157 -1550 2157
		mu 0 4 1056 1062 1066 1053
		mc 0 4 1645 1649 1655 1640
		f 4 -2158 -1533 2158 -1535
		mu 0 4 1056 1053 1049 1057
		mc 0 4 1645 1640 2071 1644
		f 4 -1538 -2159 -1530 2159
		mu 0 4 1059 1057 1049 1052
		mc 0 4 1647 1644 2071 2145
		f 4 2160 -1949 -2160 -1948
		mu 0 4 1456 1580 1581 1457
		mc 0 4 2380 2377 2351 2146
		f 4 2161 -2161 2162 2163
		mu 0 4 1582 1580 1456 1543
		mc 0 4 2404 2378 2381 2434
		f 4 2707 -1642 -2164 -2692
		mu 0 4 1542 1583 1582 1543
		mc 0 4 3402 3404 2148 1962
		f 4 -1455 -1516 -1693 -2217
		mu 0 4 1527 1040 1041 1584
		mc 0 4 1594 1591 1634 1763
		f 4 -1690 -2022 -2044 -2132
		mu 0 4 1563 1585 1526 1525
		mc 0 4 1761 1762 1938 1949
		f 4 -2019 -1692 -1726 2164
		mu 0 4 1509 1176 1179 1564
		mc 0 4 1937 2125 1784 1783
		f 4 -2017 -2165 -1719 2165
		mu 0 4 1507 1509 1564 1565
		mc 0 4 1936 1937 1783 1744
		f 4 -2014 -2166 -1669 2166
		mu 0 4 1508 1507 1565 1566
		mc 0 4 1935 1936 1744 1745
		f 4 2167 2168 2169 2170
		mu 0 4 1539 1567 1569 1586
		mc 0 4 1958 1959 2142 2149
		f 4 -2242 2251 -1569 2171
		mu 0 4 1090 1089 1571 1570
		mc 0 4 1681 2212 2213 1674
		f 4 -2003 -2172 -2004 2172
		mu 0 4 1094 1090 1570 1572
		mc 0 4 1687 1681 1674 1650
		f 4 -1583 -2173 -1544 2173
		mu 0 4 1095 1094 1572 1573
		mc 0 4 1686 1687 1650 1651
		f 4 -1985 -2174 -1984 2174
		mu 0 4 1107 1095 1573 1574
		mc 0 4 1692 1686 1651 1661
		f 4 -1599 -2175 -1558 2175
		mu 0 4 1108 1107 1574 1575
		mc 0 4 1693 1692 1661 1662
		f 4 2176 1618 2612 -1616
		mu 0 4 1119 1587 1588 1120
		mc 0 4 2386 3234 3236 2384
		f 4 -2612 -2098 -2177 -2100
		mu 0 4 912 960 1587 1119
		mc 0 4 2252 3233 3235 2387
		f 4 2178 -1841 -2178 -1836
		mu 0 4 1323 1331 1330 1324
		mc 0 4 1854 1860 1857 1853
		f 4 -2179 -1875 2179 -1876
		mu 0 4 1331 1323 1369 1370
		mc 0 4 1860 1854 1861 1866
		f 4 2573 -1850 -2180 -2556
		mu 0 4 1336 1340 1339 1337
		mc 0 4 3117 3119 1866 1861
		f 4 -2181 -1878 2181 -2539
		mu 0 4 1378 1372 1375 1379
		mc 0 4 1865 1862 1882 1870
		f 4 2182 -1854 -2182 -1870
		mu 0 4 1329 1344 1343 1364
		mc 0 4 1855 1869 1870 1882
		f 4 2183 -1873 -2183 -1839
		mu 0 4 1328 1366 1344 1329
		mc 0 4 1856 1879 1869 1855
		f 4 2558 -1732 2185 -2541
		mu 0 4 1589 1200 1203 1590
		mc 0 4 3087 3089 1786 1810
		f 4 -2186 -1902 2186 -1994
		mu 0 4 1590 1203 1406 1591
		mc 0 4 1810 1786 1893 2151
		f 4 -2187 -1898 2187 -1992
		mu 0 4 1591 1406 1409 1592
		mc 0 4 2151 1893 1894 2152
		f 4 -2445 2465 -2407 -2606
		mu 0 4 1593 1594 1595 1448
		mc 0 4 2872 2893 2895 2871
		f 4 2605 -1934 2603 -1742
		mu 0 4 1593 1448 1397 1596
		mc 0 4 2153 2833 1885 3207
		f 4 -2189 -1904 2189 -1739
		mu 0 4 1597 1414 1412 1598
		mc 0 4 2154 1886 1897 2095
		f 4 -2185 -1760 -2190 -2533
		mu 0 4 1411 1599 1598 1412
		mc 0 4 1785 1802 3060 3061
		f 4 2190 -1929 2191 -1916
		mu 0 4 1422 1435 1441 1428
		mc 0 4 1905 1912 1917 1889
		f 4 -2449 2469 -2411 -2430
		mu 0 4 1402 1401 1444 1447
		mc 0 4 2839 2901 2903 2841
		f 4 2429 -1940 2192 -2410
		mu 0 4 1402 1447 1416 1403
		mc 0 4 2839 2841 1899 1892
		f 4 -2193 -1908 2193 -1892
		mu 0 4 1403 1416 1419 1404
		mc 0 4 1892 1899 1900 1891
		f 4 -2194 -1926 2194 -1913
		mu 0 4 1425 1436 1439 1426
		mc 0 4 1891 1900 1915 1908
		f 4 2195 -1918 -2195 -2535
		mu 0 4 1443 1430 1426 1439
		mc 0 4 1919 1910 3067 3068
		f 4 2562 -1975 2196 -2545
		mu 0 4 1486 1487 1432 1421
		mc 0 4 3095 3097 1911 1906
		f 4 -2197 -1923 -2191 -1910
		mu 0 4 1421 1432 1435 1422
		mc 0 4 1906 1911 1912 1905
		f 4 2434 -1941 2197 -2415
		mu 0 4 1253 1281 1262 1242
		mc 0 4 2849 2851 1821 1815
		f 4 2199 -1801 -2199 -1777
		mu 0 4 1255 1285 1289 1260
		mc 0 4 1819 1837 1834 1818
		f 4 2200 -1797 -2200 -1775
		mu 0 4 1254 1282 1285 1255
		mc 0 4 1820 1836 1837 1819
		f 4 2567 -1978 -2201 -2550
		mu 0 4 1600 1491 1282 1254
		mc 0 4 3105 3107 1836 1820
		f 4 -2202 -1772 2202 -2537
		mu 0 4 1267 1246 1249 1268
		mc 0 4 1826 1816 3076 3077
		f 4 2203 -1799 -2203 -1776
		mu 0 4 1258 1286 1268 1249
		mc 0 4 1814 1822 1825 1817
		f 4 -2198 -1781 -2204 -1771
		mu 0 4 1242 1262 1265 1243
		mc 0 4 1815 1821 1822 1814
		f 4 2287 -1439 2078 2204
		mu 0 4 1601 972 975 1602
		mc 0 4 2574 2577 1195 1706
		f 4 2205 2286 -2205 1610
		mu 0 4 1603 1604 1601 1602
		mc 0 4 1705 2572 2575 1706
		f 4 2285 -2206 2206 -2268
		mu 0 4 1472 1604 1603 1473
		mc 0 4 2571 2573 1705 1926
		f 4 -2079 -2622 2639 2622
		mu 0 4 1602 975 979 1605
		mc 0 4 1706 1195 3259 3260
		f 4 2640 2623 -1611 -2623
		mu 0 4 1605 1606 1603 1602
		mc 0 4 3261 3262 1705 1706
		f 4 2607 -2120 -1947 -2119
		mu 0 4 1607 1150 1455 1454
		mc 0 4 1667 1738 1707 1639
		f 4 2641 -2211 -2207 -2624
		mu 0 4 1606 1554 1473 1603
		mc 0 4 3263 3265 1926 1705
		f 4 2211 2711 -1447 -2101
		mu 0 4 1541 1608 983 914
		mc 0 4 1960 3409 3412 1186
		f 4 -2695 2710 -2212 -2072
		mu 0 4 1540 1577 1608 1541
		mc 0 4 1961 3408 3410 1960
		f 4 1601 -2162 -1644 2212
		mu 0 4 1460 1459 1138 1141
		mc 0 4 1695 1694 1728 1729
		f 4 -1641 -2075 -2163 1611
		mu 0 4 1455 1136 1543 1456
		mc 0 4 2383 2077 2147 2382
		f 4 -2213 -2146 -2071 1612
		mu 0 4 1460 1141 1540 1117
		mc 0 4 1695 1729 1961 1708
		f 4 -2053 -2155 -1570 -2138
		mu 0 4 1529 1528 1579 1568
		mc 0 4 1950 1951 2144 2141
		f 4 -2056 -2118 -1551 -2153
		mu 0 4 1531 1530 1609 1578
		mc 0 4 2157 2138 2354 2353
		f 4 -2060 -1555 2117 -2059
		mu 0 4 1532 1533 1609 1530
		mc 0 4 2126 2357 2355 2139
		f 4 -2058 -1683 -2065 -2061
		mu 0 4 1532 1166 1169 1534
		mc 0 4 1954 1754 1756 2127
		f 4 2213 -1560 -2062 -2064
		mu 0 4 1536 1610 1535 1534
		mc 0 4 2430 2358 2361 1955
		f 4 2214 -1578 -2214 -2067
		mu 0 4 1537 1611 1612 1538
		mc 0 4 2159 2369 2359 2158
		f 4 -2171 -1575 -2215 -2068
		mu 0 4 1539 1586 1611 1537
		mc 0 4 2432 2368 2160 2431
		f 4 -2137 2069 -2136 -2054
		mu 0 4 1529 1567 1566 1185
		mc 0 4 1950 1959 1745 1766
		f 4 -2152 -2052 -2151 -2057
		mu 0 4 1531 1528 1184 1191
		mc 0 4 1952 1951 1767 1774
		f 4 -2168 -2069 -2167 -2070
		mu 0 4 1567 1539 1508 1566
		mc 0 4 1959 1958 1935 1745
		f 4 -1691 -2131 -1673 -2133
		mu 0 4 1179 1178 1156 1159
		mc 0 4 2140 2546 2547 1747
		f 4 -1458 2215 -1517 -1513
		mu 0 4 989 992 1042 1039
		mc 0 4 1591 1592 1635 1633
		f 4 -1525 -1520 -2216 -1479
		mu 0 4 1010 1044 1042 992
		mc 0 4 1608 1636 1635 1592
		f 4 -2049 2216 -2147 -2041
		mu 0 4 1522 1527 1584 1523
		mc 0 4 1948 1594 1763 1749
		f 4 -2227 -759 -1389 -2219
		mu 0 4 437 422 1613 1614
		mc 0 4 2181 2182 1533 1241
		f 4 779 -2228 2218 782
		mu 0 4 1615 438 437 1614
		mc 0 4 2183 2184 2163 1241
		f 4 -2229 -780 -1373 -2221
		mu 0 4 944 438 1615 1616
		mc 0 4 2185 2186 1520 1240
		f 4 -2230 2220 -1404 -2222
		mu 0 4 443 944 1616 1617
		mc 0 4 2187 2188 1540 1239
		f 4 -2231 2221 785 786
		mu 0 4 444 443 1617 1618
		mc 0 4 2189 2190 1239 1242
		f 4 -2232 -787 788 -2224
		mu 0 4 446 444 1618 1619
		mc 0 4 2191 2192 1242 1238
		f 4 -2233 2223 769 770
		mu 0 4 430 429 1620 1621
		mc 0 4 2193 2194 1238 1243
		f 4 -2234 -771 790 -2226
		mu 0 4 425 430 1621 1622
		mc 0 4 2195 2196 1243 1236
		f 4 762 -2235 2225 765
		mu 0 4 1623 421 425 1622
		mc 0 4 2197 2198 2177 1236
		f 4 758 -2236 -763 761
		mu 0 4 1613 422 421 1623
		mc 0 4 2199 2200 2180 1237
		f 4 1554 1555 -2247 -1552
		mu 0 4 1624 1625 1071 1068
		mc 0 4 2221 2222 2203 2202
		f 4 -2248 -1556 1579 -2239
		mu 0 4 1074 1071 1625 1626
		mc 0 4 2223 2224 1660 1666
		f 4 -2249 2238 1559 1560
		mu 0 4 1075 1074 1626 1627
		mc 0 4 2225 2226 1666 1665
		f 4 -2250 -1561 1577 -2241
		mu 0 4 1088 1092 1628 1629
		mc 0 4 2227 2228 1665 1683
		f 4 -2251 2240 1574 1575
		mu 0 4 1089 1088 1629 1630
		mc 0 4 2229 2230 1683 1682
		f 4 -2252 -1576 -2170 -2243
		mu 0 4 1571 1089 1630 1631
		mc 0 4 2231 2232 1682 1673
		f 4 -2253 2242 -2139 -2244
		mu 0 4 1083 1571 1631 1632
		mc 0 4 2233 2234 1675 1676
		f 4 1569 1570 -2254 2243
		mu 0 4 1632 1633 1084 1083
		mc 0 4 2235 2236 2217 2215
		f 4 -2255 -1571 -2154 -2246
		mu 0 4 1067 1084 1633 1634
		mc 0 4 2237 2238 1679 1656
		f 4 1550 1551 -2256 2245
		mu 0 4 1634 1624 1068 1067
		mc 0 4 2239 2240 2201 2219
		f 4 -2275 -1170 -1169 1173
		mu 0 4 815 811 802 809
		mc 0 4 2584 2585 2016 2017
		f 4 1174 -2276 -1174 -857
		mu 0 4 501 817 816 502
		mc 0 4 2586 2587 2551 2019
		f 4 -2277 -1175 -859 1177
		mu 0 4 821 817 501 503
		mc 0 4 2588 2589 2287 2290
		f 4 1178 -2278 -1178 -864
		mu 0 4 505 822 821 503
		mc 0 4 2590 2591 2555 1283
		f 4 -2279 -1179 -1322 1324
		mu 0 4 910 822 505 908
		mc 0 4 2592 2593 2040 2440
		f 4 -2280 -1325 -2096 -2263
		mu 0 4 1483 910 908 1147
		mc 0 4 2594 2595 1969 2131
		f 4 -1653 -2264 -2281 2262
		mu 0 4 1147 1145 1482 1483
		mc 0 4 2596 2597 2563 2560
		f 4 -2282 2263 -1650 -2265
		mu 0 4 1477 1482 1145 1144
		mc 0 4 2598 2599 2409 2406
		f 4 -1646 -2266 -2283 2264
		mu 0 4 1144 1143 1478 1477
		mc 0 4 2600 2601 2567 2564
		f 4 -2284 2265 -1960 -2267
		mu 0 4 1471 1476 1470 1463
		mc 0 4 2602 2603 2111 2110
		f 4 1960 -2285 2266 -1953
		mu 0 4 1132 1472 1471 1463
		mc 0 4 2604 2605 2568 2110
		f 4 -2269 -2286 -1961 -1633
		mu 0 4 1131 1604 1472 1132
		mc 0 4 2606 2607 2571 2109
		f 4 -2287 2268 -1652 -2270
		mu 0 4 1601 1604 1131 1146
		mc 0 4 2608 2609 2156 2155
		f 4 -2081 -2271 -2288 2269
		mu 0 4 1146 888 972 1601
		mc 0 4 2610 2611 2577 2574
		f 4 1437 -2289 2270 -1291
		mu 0 4 504 973 972 888
		mc 0 4 2612 2613 2576 2064
		f 4 -2290 -1438 -861 1439
		mu 0 4 977 973 504 490
		mc 0 4 2614 2615 2063 2065
		f 4 -842 -2274 -2291 -1440
		mu 0 4 490 489 810 977
		mc 0 4 2616 2617 2583 2581
		f 4 -1163 1169 -2292 2273
		mu 0 4 489 802 811 810
		mc 0 4 2618 2619 2548 2582
		f 4 2683 2676 2654 -2676
		mu 0 4 1635 1450 1449 1357
		mc 0 4 3370 3371 3323 3320
		f 4 2663 2656 1410 -2656
		mu 0 4 698 699 680 674
		mc 0 4 3330 3331 1369 2620
		f 4 -2462 2482 -2424 -2443
		mu 0 4 1382 1381 1360 1363
		mc 0 4 2865 2926 2928 2889
		f 4 2442 -1879 -2294 -2423
		mu 0 4 1382 1363 1358 1451
		mc 0 4 2865 2867 2626 1880
		f 4 2511 -2307 -984 1184
		mu 0 4 971 828 614 613
		mc 0 4 2991 2994 2639 1566
		f 4 -2311 -2549 2566 2549
		mu 0 4 1254 1257 1490 1600
		mc 0 4 1820 2659 3103 3104
		f 4 -2314 -2414 2433 2414
		mu 0 4 1242 1245 1250 1253
		mc 0 4 1815 2664 2847 2848
		f 4 1617 -1617 -2323 -2176
		mu 0 4 1576 1117 1120 1636
		mc 0 4 2677 2678 2150 2376
		f 4 2602 -949 1421 -1088
		mu 0 4 740 1637 1638 741
		mc 0 4 2724 3199 2062 1554
		f 4 -2344 2326 -1091 -2328
		mu 0 4 736 789 740 743
		mc 0 4 2725 2726 1553 1396
		f 4 -2345 2327 1085 1086
		mu 0 4 737 736 743 747
		mc 0 4 2727 2728 1396 1388
		f 4 -2346 -1087 -1097 1134
		mu 0 4 1639 737 747 750
		mc 0 4 2729 2730 1388 1394
		f 4 -2347 -1135 1425 -2330
		mu 0 4 1640 1639 750 761
		mc 0 4 2731 2732 1394 1558
		f 4 -2348 2329 -1111 1143
		mu 0 4 924 1640 761 764
		mc 0 4 2733 2734 1558 1502
		f 4 -2349 -1144 -1350 -2332
		mu 0 4 925 924 764 923
		mc 0 4 2735 2736 1502 1357
		f 4 -2297 2303 -2350 2331
		mu 0 4 671 602 1641 1642
		mc 0 4 2737 2738 2700 2698
		f 4 -2351 -2304 -982 1144
		mu 0 4 969 1641 602 601
		mc 0 4 2739 2740 2633 1563
		f 4 -2352 -1145 1430 -2335
		mu 0 4 970 969 601 618
		mc 0 4 2741 2742 1563 1330
		f 4 -2353 2334 -990 1145
		mu 0 4 1643 970 618 621
		mc 0 4 2743 2744 1330 1341
		f 4 -2354 -1146 -1023 1146
		mu 0 4 1644 1643 621 655
		mc 0 4 2745 2746 1341 1338
		f 4 -2355 -1147 -1037 1147
		mu 0 4 1645 1644 655 644
		mc 0 4 2747 2748 1338 2012
		f 4 -2356 -1148 -1014 1148
		mu 0 4 1646 1645 644 647
		mc 0 4 2749 2750 1349 2498
		f 4 1149 -2357 -1149 -1085
		mu 0 4 678 1647 1648 679
		mc 0 4 2751 2752 2713 1327
		f 4 2668 -2358 -1150 -2661
		mu 0 4 1649 1650 1647 678
		mc 0 4 3340 3342 2715 1383
		f 4 -1070 1151 -2359 -1151
		mu 0 4 1651 1652 1653 1654
		mc 0 4 2753 2754 2718 2717
		f 4 -2360 -1152 -1069 -2341
		mu 0 4 1655 1653 1652 1656
		mc 0 4 2755 2756 2624 1372
		f 4 -1067 1082 -2361 2340
		mu 0 4 1656 1657 1658 1655
		mc 0 4 2757 2758 2722 2720
		f 4 -2364 -2384 -2326 2604
		mu 0 4 789 790 965 1659
		mc 0 4 2687 2799 2800 2061
		f 4 -2387 2365 2345 2328
		mu 0 4 745 738 737 1639
		mc 0 4 2804 2805 2691 2692
		f 4 -2368 -2388 -2329 2346
		mu 0 4 1640 787 745 1639
		mc 0 4 2695 2806 2807 2693
		f 4 -2389 2367 2347 2330
		mu 0 4 788 787 1640 924
		mc 0 4 2808 2809 2694 2696
		f 4 -2391 2369 2349 2332
		mu 0 4 608 669 1642 1641
		mc 0 4 2812 2773 2698 2700
		f 4 -2392 -2333 2350 2333
		mu 0 4 609 608 1641 969
		mc 0 4 2813 2776 2701 2702
		f 4 -2394 2372 2352 2335
		mu 0 4 636 635 970 1643
		mc 0 4 2816 2817 2704 2706
		f 4 -2395 -2336 2353 2336
		mu 0 4 658 636 1643 1644
		mc 0 4 2818 2819 2707 2708
		f 4 -2376 -2396 -2337 2354
		mu 0 4 1645 648 658 1644
		mc 0 4 2710 2820 2821 2709
		f 4 -2397 2375 2355 2337
		mu 0 4 649 648 1645 1646
		mc 0 4 2822 2823 2711 2712
		f 4 -2378 -2398 -2338 2356
		mu 0 4 1647 696 735 1648
		mc 0 4 2714 2790 2788 2713
		f 4 2669 -2399 2377 2357
		mu 0 4 1650 697 696 1647
		mc 0 4 3341 3344 2789 2715
		f 4 -2400 -2339 2358 2339
		mu 0 4 724 723 1654 1653
		mc 0 4 2793 2792 2717 2718
		f 4 -2381 -2401 -2340 2359
		mu 0 4 1655 705 724 1653
		mc 0 4 2721 2824 2825 2719
		f 4 -2402 2380 2360 2341
		mu 0 4 706 705 1655 1658
		mc 0 4 2826 2795 2720 2722
		f 4 -2426 2405 2464 2444
		mu 0 4 1218 1217 1241 1660
		mc 0 4 2870 2831 1809 2892
		f 4 -2408 -2427 2406 2466
		mu 0 4 1661 1393 1448 1595
		mc 0 4 2897 2873 2832 2894
		f 4 -2428 2407 2467 -1890
		mu 0 4 1394 1393 1661 1400
		mc 0 4 2874 2834 2896 2899
		f 4 -2413 -2432 -2451 2471
		mu 0 4 1662 1553 1446 1445
		mc 0 4 2907 2845 2843 2905
		f 4 -2416 -2435 -2454 2474
		mu 0 4 1278 1281 1253 1252
		mc 0 4 2913 2878 2849 2911
		f 4 -2465 -1952 1989 1990
		mu 0 4 1660 1241 1462 1500
		mc 0 4 2931 2932 1923 1932
		f 4 -2188 -2446 -2466 -1991
		mu 0 4 1592 1409 1595 1594
		mc 0 4 2933 2934 2895 2893
		f 4 -1897 -2447 -2467 2445
		mu 0 4 1409 1408 1661 1595
		mc 0 4 2935 2936 2897 2894
		f 4 -2468 2446 1932 -2448
		mu 0 4 1400 1661 1408 1429
		mc 0 4 2937 2938 1895 1888
		f 4 1887 1888 -2469 2447
		mu 0 4 1429 1428 1401 1400
		mc 0 4 2939 2940 2900 2898
		f 4 -2192 -2450 -2470 -1889
		mu 0 4 1428 1441 1444 1401
		mc 0 4 2941 2942 2903 2901
		f 4 -1928 1931 -2471 2449
		mu 0 4 1441 1440 1445 1444
		mc 0 4 2943 2944 2904 2902
		f 4 -2112 -2452 -2472 -1932
		mu 0 4 1440 1545 1662 1445
		mc 0 4 2945 2946 2907 2905
		f 4 -2313 2319 -2473 2451
		mu 0 4 1317 1261 1251 1318
		mc 0 4 2947 2948 2908 2906
		f 4 1773 -2474 -2320 -1827
		mu 0 4 1260 1252 1251 1261
		mc 0 4 2949 2950 2909 2673
		f 4 2198 -2455 -2475 -1774
		mu 0 4 1260 1289 1278 1252
		mc 0 4 2951 2952 2913 2911
		f 4 1791 1792 -2476 2454
		mu 0 4 1289 1288 1279 1278
		mc 0 4 2953 2954 2914 2912
		f 4 1817 1818 -2477 -1793
		mu 0 4 1288 1311 1306 1279
		mc 0 4 2955 2956 2916 2915
		f 4 -1830 -2458 -2478 -1819
		mu 0 4 1311 1277 1294 1306
		mc 0 4 2957 2958 2919 2917
		f 4 -1790 1805 -2479 2457
		mu 0 4 1277 1276 1295 1294
		mc 0 4 2959 2960 2920 2918
		f 4 -2480 -1806 -1837 -2460
		mu 0 4 1391 1390 1325 1324
		mc 0 4 2961 2962 1832 1853
		f 4 -2679 2686 2671 1857
		mu 0 4 1348 1347 1663 1353
		mc 0 4 2963 3376 3361 1871
		f 4 -2482 -1858 -1861 1879
		mu 0 4 1381 1348 1353 1352
		mc 0 4 2965 2966 1871 1872
		f 4 -2483 -1880 -1860 -2463
		mu 0 4 1360 1381 1352 1351
		mc 0 4 2967 2968 2625 1873
		f 4 -2484 2462 -1863 1868
		mu 0 4 1361 1360 1351 1664
		mc 0 4 2969 2970 1873 1874
		f 4 2575 -2521 -2487 -1052
		mu 0 4 688 721 720 689
		mc 0 4 2972 2971 1380 2976
		f 4 -1874 -1881 -1843 -2486
		mu 0 4 1387 1665 1666 1388
		mc 0 4 1868 1876 1858 2974
		f 4 -2504 2486 1052 1053
		mu 0 4 690 689 720 719
		mc 0 4 3010 3011 1380 1379
		f 4 -2489 -2505 -1054 1413
		mu 0 4 716 686 690 719
		mc 0 4 3012 3013 2978 1379
		f 4 -2506 2488 1049 1050
		mu 0 4 687 686 716 715
		mc 0 4 3014 3015 1546 2013
		f 4 -995 -2491 -2507 -1051
		mu 0 4 627 626 833 834
		mc 0 4 3016 3017 2984 2982
		f 4 -1039 -2492 -2508 2490
		mu 0 4 626 656 832 833
		mc 0 4 3018 3019 2986 2983
		f 4 -1024 -2493 -2509 2491
		mu 0 4 656 623 830 832
		mc 0 4 3020 3021 2988 2985
		f 4 -992 1185 -2510 2492
		mu 0 4 623 622 831 830
		mc 0 4 3022 3023 2989 2987
		f 4 1434 -2495 -2511 -1186
		mu 0 4 622 605 971 831
		mc 0 4 3024 3025 2992 2990
		f 4 -2301 -2496 -2512 2494
		mu 0 4 605 604 828 971
		mc 0 4 3026 3027 2994 2991
		f 4 -2513 2495 -1336 1336
		mu 0 4 829 828 604 665
		mc 0 4 3028 3029 2641 1421
		f 4 1346 -2498 -2514 -1337
		mu 0 4 919 786 826 918
		mc 0 4 3030 3031 2998 2996
		f 4 1182 -2515 2497 -1134
		mu 0 4 785 827 826 786
		mc 0 4 3032 3033 2997 1499
		f 4 -2500 -2516 -1183 -1429
		mu 0 4 774 824 827 785
		mc 0 4 3034 3035 3000 1561
		f 4 -1122 1180 -2517 2499
		mu 0 4 774 773 825 824
		mc 0 4 3036 3037 3003 3001
		f 4 -1142 -2502 -2518 -1181
		mu 0 4 773 756 558 825
		mc 0 4 3038 3039 3006 3004
		f 4 937 -2519 2501 940
		mu 0 4 755 559 558 756
		mc 0 4 3040 3041 3005 1314
		f 4 -956 -2520 -938 1418
		mu 0 4 968 961 559 755
		mc 0 4 3042 3043 3008 1549
		f 4 2184 -2542 -2559 -1747
		mu 0 4 1599 1411 1200 1589
		mc 0 4 3122 3123 3089 3087
		f 4 1728 1729 -2560 2541
		mu 0 4 1411 1410 1201 1200
		mc 0 4 3124 3125 3090 3088
		f 4 -2544 -2561 -1730 -1937
		mu 0 4 1431 1485 1201 1410
		mc 0 4 3126 3127 3091 1788
		f 4 1971 -2562 2543 -1919
		mu 0 4 1430 1486 1485 1431
		mc 0 4 3128 3129 3092 1909
		f 4 -2196 -2546 -2563 -1972
		mu 0 4 1430 1443 1487 1486
		mc 0 4 3130 3131 3097 3095
		f 4 -1931 1973 -2564 2545
		mu 0 4 1443 1442 1488 1487
		mc 0 4 3132 3133 3098 3096
		f 4 -2548 -2565 -1974 2113
		mu 0 4 1548 1547 1488 1442
		mc 0 4 3134 3135 3099 1920
		f 4 -2310 2316 -2566 2547
		mu 0 4 1314 1247 1490 1489
		mc 0 4 3136 3137 3102 3100
		f 4 -2567 -2317 -1773 1975
		mu 0 4 1600 1490 1247 1246
		mc 0 4 3138 3139 2657 1816
		f 4 -2551 -2568 -1976 2201
		mu 0 4 1267 1491 1600 1246
		mc 0 4 3140 3141 3105 1816
		f 4 1976 -2569 2550 -1784
		mu 0 4 1266 1492 1491 1267
		mc 0 4 3142 3143 3106 1826
		f 4 1978 -2570 -1977 -1817
		mu 0 4 1304 1493 1492 1266
		mc 0 4 3144 3145 3109 1827
		f 4 1979 -2571 -1979 -1834
		mu 0 4 1271 1494 1493 1304
		mc 0 4 3146 3147 3111 1848
		f 4 -2555 -2572 -1980 -1787
		mu 0 4 1270 1495 1494 1271
		mc 0 4 3148 3149 3113 2516
		f 4 -2573 2554 1845 1846
		mu 0 4 1336 1335 1373 1372
		mc 0 4 3150 3151 2105 1862
		f 4 2180 -2557 -2574 -1847
		mu 0 4 1372 1378 1340 1336
		mc 0 4 3152 3153 3119 3117
		f 4 -2575 2556 1850 1851
		mu 0 4 1341 1340 1378 1377
		mc 0 4 3154 3155 1865 1864
		f 4 -1056 -2576 -1080 -2485
		mu 0 4 733 721 688 734
		mc 0 4 3156 3157 2972 2973
		f 4 -2540 -2577 -2558 -1852
		mu 0 4 1377 1376 1338 1341
		mc 0 4 3158 3159 1863 3121
		f 4 2665 -1066 1083 -2658
		mu 0 4 1667 1668 732 731
		mc 0 4 3334 3336 1367 3160
		f 4 -2579 -2588 2591 -1867
		mu 0 4 1383 1386 1669 1670
		mc 0 4 3162 3163 3182 3184
		f 4 -2584 -1063 1063 1064
		mu 0 4 1671 1672 708 1673
		mc 0 4 3173 3174 1370 1374
		f 4 -2578 -2582 -2585 -1065
		mu 0 4 727 730 1674 1675
		mc 0 4 3175 3176 3170 3168
		f 4 -2586 2581 1066 1067
		mu 0 4 1676 1677 1678 1656
		mc 0 4 3177 3178 1373 1372
		f 4 2680 2673 -2591 -2673
		mu 0 4 1679 1680 1354 1350
		mc 0 4 3364 3365 3181 3180
		f 4 -2592 -2674 2681 -2589
		mu 0 4 1670 1669 1681 1682
		mc 0 4 3186 3187 3366 3368
		f 4 2682 2675 -2593 2588
		mu 0 4 1683 1635 1357 1356
		mc 0 4 3367 3369 3185 3183
		f 4 2653 -1068 1068 1069
		mu 0 4 1651 1676 1656 1652
		mc 0 4 3324 3172 2627 3192
		f 4 969 1203 -971 -1202
		mu 0 4 840 581 595 585
		mc 0 4 3196 3197 1435 1434
		f 4 -2599 2593 949 950
		mu 0 4 572 571 576 575
		mc 0 4 3208 3209 1312 1483
		f 4 -2600 -951 -1303 1303
		mu 0 4 896 572 575 895
		mc 0 4 3210 3211 1483 1191
		f 4 -2601 -1304 -2086 -2597
		mu 0 4 1214 896 895 1219
		mc 0 4 3212 3213 1191 1796
		f 4 -2602 2596 1740 1741
		mu 0 4 1215 1214 1219 1218
		mc 0 4 3214 3215 1796 1795
		f 4 -2604 -1887 2188 -2598
		mu 0 4 1596 1397 1399 1684
		mc 0 4 3216 3217 1886 2154
		f 4 -2327 -2605 -2594 -2603
		mu 0 4 740 789 1659 1637
		mc 0 4 3218 3219 2061 3199
		f 4 -2607 -772 -1157 -1352
		mu 0 4 508 982 793 796
		mc 0 4 3220 3221 1264 1278
		f 4 -1657 -2608 -1591 -2610
		mu 0 4 1151 1150 1607 1685
		mc 0 4 3225 3226 1667 1689
		f 4 -1600 2322 -2613 -2210
		mu 0 4 1686 1636 1120 1588
		mc 0 4 3238 3239 2385 3237
		f 4 -2615 -1946 2120 -1639
		mu 0 4 1136 1149 1453 1137
		mc 0 4 3244 3245 1921 1727
		f 4 -2634 -1190 -807 -2617
		mu 0 4 930 836 473 1687
		mc 0 4 3282 3283 1426 2021
		f 4 -804 -2618 -2635 2616
		mu 0 4 1688 981 927 929
		mc 0 4 3284 3285 3251 3248
		f 4 -2636 2617 -2609 1444
		mu 0 4 928 927 981 507
		mc 0 4 3286 3287 3223 3224
		f 4 -865 -2620 -2637 -1445
		mu 0 4 507 506 980 928
		mc 0 4 3288 3289 3255 3253
		f 4 -1155 -2621 -2638 2619
		mu 0 4 506 792 978 980
		mc 0 4 3290 3291 3257 3254
		f 4 -2639 2620 -1287 1442
		mu 0 4 979 978 792 886
		mc 0 4 3292 3293 1570 1200
		f 4 -2640 -1443 -2078 2207
		mu 0 4 1605 979 886 1452
		mc 0 4 3294 3295 1200 1922
		f 4 2208 -2641 -2208 -1944
		mu 0 4 1148 1606 1605 1452
		mc 0 4 3296 3297 3261 1922
		f 4 -2625 -2642 -2209 -1658
		mu 0 4 1151 1554 1606 1148
		mc 0 4 3298 3299 3263 1736
		f 4 2121 -2643 2624 2609
		mu 0 4 1685 1555 1554 1151
		mc 0 4 3300 3301 3264 3222
		f 4 2122 -2644 -2122 -1594
		mu 0 4 1689 1556 1555 1685
		mc 0 4 3302 3303 3267 1689
		f 4 -2645 -2123 -1597 -2628
		mu 0 4 1496 1557 1690 1686
		mc 0 4 3304 3305 2114 1704
		f 4 1980 -2646 2627 2209
		mu 0 4 1588 1497 1496 1686
		mc 0 4 3306 3307 3270 2426
		f 4 -2647 -1981 -1619 1982
		mu 0 4 1498 1497 1588 1587
		mc 0 4 3308 3309 2425 1931
		f 4 -2631 -2648 -1983 2097
		mu 0 4 960 911 1498 1587
		mc 0 4 3310 3311 3275 2427
		f 4 1326 -2632 -2649 2630
		mu 0 4 960 959 837 911
		mc 0 4 3312 3313 3279 3276
		f 4 -2650 2631 -829 -2633
		mu 0 4 835 837 959 474
		mc 0 4 3314 3315 1573 2335
		f 4 1445 1189 -2651 2632
		mu 0 4 474 473 836 835
		mc 0 4 3316 3317 3246 3280
		f 4 -2652 1061 2292 1062
		mu 0 4 1672 726 725 708
		mc 0 4 3165 3321 3188 3189
		f 4 2679 2672 -2653 -2672
		mu 0 4 1663 1679 1350 1353
		mc 0 4 3362 3363 3322 2621
		f 4 -2660 2667 2660 -1417
		mu 0 4 704 703 1649 678
		mc 0 4 3325 3338 3339 1383
		f 4 -2655 1867 2293 -2590
		mu 0 4 1357 1449 1451 1358
		mc 0 4 3327 3328 3190 3191
		f 4 2651 2579 -2664 -1060
		mu 0 4 726 1672 699 698
		mc 0 4 3345 3346 3331 3330
		f 4 -2665 -2580 2583 2580
		mu 0 4 700 699 1672 1671
		mc 0 4 3347 3348 3166 3167
		f 4 2584 -2659 -2666 -2581
		mu 0 4 1675 1674 1668 1667
		mc 0 4 3349 3350 3336 3334
		f 4 -2667 2658 2585 2582
		mu 0 4 703 702 1677 1676
		mc 0 4 3351 3352 3169 3171
		f 4 -2668 -2583 -2654 1073
		mu 0 4 1649 703 1676 1651
		mc 0 4 3353 3354 3326 3324
		f 4 1150 -2662 -2669 -1074
		mu 0 4 1651 1654 1650 1649
		mc 0 4 3355 3356 3342 3340
		f 4 -2663 -2670 2661 2338
		mu 0 4 723 697 1650 1654
		mc 0 4 3357 3358 3341 2716
		f 4 -2671 2662 2378 1059
		mu 0 4 698 697 723 726
		mc 0 4 3359 3360 2791 1368
		f 4 1858 -2680 -1857 2177
		mu 0 4 1330 1679 1663 1324
		mc 0 4 3377 3378 3362 2622
		f 4 -1844 1861 -2681 -1859
		mu 0 4 1330 1333 1680 1679
		mc 0 4 3379 3380 3365 3364
		f 4 -2682 -1862 1880 -2675
		mu 0 4 1682 1681 1666 1665
		mc 0 4 3381 3382 1875 1876
		f 4 1863 1864 -2683 2674
		mu 0 4 1367 1366 1635 1683
		mc 0 4 3383 3384 3369 3367
		f 4 -2184 1871 -2684 -1865
		mu 0 4 1366 1328 1450 1635
		mc 0 4 3385 3386 3371 3370
		f 4 -2685 -1872 -2421 2440
		mu 0 4 1346 1450 1328 1392
		mc 0 4 3387 3388 1856 2861
		f 4 2480 -2686 -2441 -1943
		mu 0 4 1391 1347 1346 1392
		mc 0 4 3389 3390 3374 2886
		f 4 -2687 -2481 2459 1856
		mu 0 4 1663 1347 1391 1324
		mc 0 4 3391 3392 2964 1853
		f 4 1284 -2704 -848 -209
		mu 0 4 1691 884 493 1692
		mc 0 4 3425 3426 3394 1574
		f 4 456 -2690 -2705 -1285
		mu 0 4 1691 1693 1134 884
		mc 0 4 3427 3428 3398 3396
		f 4 461 1637 -2706 2689
		mu 0 4 1693 1694 1135 1134
		mc 0 4 3429 3430 3399 3397
		f 4 -2707 -1638 483 2073
		mu 0 4 1542 1135 1694 1695
		mc 0 4 3431 3432 2403 2435
		f 4 457 -2693 -2708 -2074
		mu 0 4 1695 1696 1583 1542
		mc 0 4 3433 3434 3404 3402
		f 4 -2709 2692 458 1642
		mu 0 4 1140 1139 1697 1698
		mc 0 4 3435 3436 1731 1730
		f 4 478 2144 -2710 -1643
		mu 0 4 1698 1699 1577 1140
		mc 0 4 3437 3438 3407 3406
		f 4 -2711 -2145 459 -2696
		mu 0 4 1608 1577 1699 1700
		mc 0 4 3439 3440 1977 1978
		f 4 -2712 2695 491 -2697
		mu 0 4 983 1608 1700 1701
		mc 0 4 3441 3442 1978 1181
		f 4 -2713 2696 -243 1447
		mu 0 4 984 983 1701 1702
		mc 0 4 3443 3444 1181 1576
		f 4 -2714 -1448 -212 -2699
		mu 0 4 949 984 1702 1703
		mc 0 4 3445 3446 1576 1269
		f 4 -2700 -2715 2698 -229
		mu 0 4 1704 498 949 1703
		mc 0 4 3447 3448 3415 1269
		f 4 -2716 2699 -211 853
		mu 0 4 499 498 1704 1705
		mc 0 4 3449 3450 1577 1270
		f 4 -2702 -2717 -854 -210
		mu 0 4 1706 883 955 1707
		mc 0 4 3451 3452 3420 2276
		f 4 -2718 2701 -234 -2703
		mu 0 4 492 883 1706 1708
		mc 0 4 3453 3454 2329 2336
		f 4 847 -2719 2702 -215
		mu 0 4 1692 493 492 1708
		mc 0 4 3455 3456 3423 1575;
	setAttr ".cd" -type "dataPolyComponent" Index_Data Edge 0 ;
	setAttr ".cvd" -type "dataPolyComponent" Index_Data Vertex 0 ;
	setAttr ".pd[0]" -type "dataPolyComponent" Index_Data UV 0 ;
	setAttr ".hfd" -type "dataPolyComponent" Index_Data Face 0 ;
	setAttr ".db" yes;
createNode lightLinker -s -n "lightLinker1";
	rename -uid "F8FF7778-42B8-0523-F37C-23BEDA10942C";
	setAttr -s 3 ".lnk";
	setAttr -s 3 ".slnk";
createNode shapeEditorManager -n "shapeEditorManager";
	rename -uid "B5DBA756-42A7-745B-4A82-C4B7E616C491";
createNode poseInterpolatorManager -n "poseInterpolatorManager";
	rename -uid "7E9BA052-4345-39E5-D25F-FB8430AD91FC";
createNode displayLayerManager -n "layerManager";
	rename -uid "F1384B29-4DD3-EE83-322D-94B9161A4027";
createNode displayLayer -n "defaultLayer";
	rename -uid "25E855AE-4862-A5A0-9981-8F99D30E48AB";
createNode renderLayerManager -n "renderLayerManager";
	rename -uid "1713706E-45C9-F238-ABB3-B0ADF2CECF49";
createNode renderLayer -n "defaultRenderLayer";
	rename -uid "91FCF7B4-4CAB-73BB-51CD-88B0FFB61D09";
	setAttr ".g" yes;
createNode shadingEngine -n "lambert2SG";
	rename -uid "4C18F0CD-49C6-925C-4F7E-AC84420CB366";
	setAttr ".ihi" 0;
	setAttr -s 2 ".dsm";
	setAttr ".ro" yes;
	setAttr -s 2 ".gn";
createNode materialInfo -n "materialInfo1";
	rename -uid "06C7D88E-46D6-D08A-0A86-4E9FA707355D";
createNode lambert -n "lambert2";
	rename -uid "E9E7ACFF-4AAC-49D5-52F0-449BD3A53819";
createNode polyColorPerVertex -n "polyColorPerVertex8";
	rename -uid "DC16B0FF-49D5-C054-A565-6981978D10BF";
	setAttr ".uopa" yes;
	setAttr -s 58 ".vclr";
	setAttr ".vclr[0].vxal" 1;
	setAttr -s 4 ".vclr[0].vfcl";
	setAttr ".vclr[0].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[0].vfal" 1;
	setAttr ".vclr[0].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[7].vfal" 1;
	setAttr ".vclr[0].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[48].vfal" 1;
	setAttr ".vclr[0].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[55].vfal" 1;
	setAttr ".vclr[1].vxal" 1;
	setAttr -s 4 ".vclr[1].vfcl";
	setAttr ".vclr[1].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[0].vfal" 1;
	setAttr ".vclr[1].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[1].vfal" 1;
	setAttr ".vclr[1].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[48].vfal" 1;
	setAttr ".vclr[1].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vxal" 1;
	setAttr -s 4 ".vclr[2].vfcl";
	setAttr ".vclr[2].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[1].vfal" 1;
	setAttr ".vclr[2].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[2].vfal" 1;
	setAttr ".vclr[2].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vxal" 1;
	setAttr -s 4 ".vclr[3].vfcl";
	setAttr ".vclr[3].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[2].vfal" 1;
	setAttr ".vclr[3].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[3].vfal" 1;
	setAttr ".vclr[3].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vxal" 1;
	setAttr -s 4 ".vclr[4].vfcl";
	setAttr ".vclr[4].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[3].vfal" 1;
	setAttr ".vclr[4].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[4].vfal" 1;
	setAttr ".vclr[4].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vxal" 1;
	setAttr -s 4 ".vclr[5].vfcl";
	setAttr ".vclr[5].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[4].vfal" 1;
	setAttr ".vclr[5].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[5].vfal" 1;
	setAttr ".vclr[5].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vxal" 1;
	setAttr -s 4 ".vclr[6].vfcl";
	setAttr ".vclr[6].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[5].vfal" 1;
	setAttr ".vclr[6].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[6].vfal" 1;
	setAttr ".vclr[6].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vxal" 1;
	setAttr -s 4 ".vclr[7].vfcl";
	setAttr ".vclr[7].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[6].vfal" 1;
	setAttr ".vclr[7].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[7].vfal" 1;
	setAttr ".vclr[7].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[55].vfal" 1;
	setAttr ".vclr[8].vxal" 1;
	setAttr -s 4 ".vclr[8].vfcl";
	setAttr ".vclr[8].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[0].vfal" 1;
	setAttr ".vclr[8].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[7].vfal" 1;
	setAttr ".vclr[8].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[8].vfal" 1;
	setAttr ".vclr[8].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[15].vfal" 1;
	setAttr ".vclr[9].vxal" 1;
	setAttr -s 4 ".vclr[9].vfcl";
	setAttr ".vclr[9].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[0].vfal" 1;
	setAttr ".vclr[9].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[1].vfal" 1;
	setAttr ".vclr[9].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[8].vfal" 1;
	setAttr ".vclr[9].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vxal" 1;
	setAttr -s 4 ".vclr[10].vfcl";
	setAttr ".vclr[10].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[1].vfal" 1;
	setAttr ".vclr[10].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[2].vfal" 1;
	setAttr ".vclr[10].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vxal" 1;
	setAttr -s 4 ".vclr[11].vfcl";
	setAttr ".vclr[11].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[2].vfal" 1;
	setAttr ".vclr[11].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[3].vfal" 1;
	setAttr ".vclr[11].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vxal" 1;
	setAttr -s 4 ".vclr[12].vfcl";
	setAttr ".vclr[12].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[3].vfal" 1;
	setAttr ".vclr[12].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[4].vfal" 1;
	setAttr ".vclr[12].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vxal" 1;
	setAttr -s 4 ".vclr[13].vfcl";
	setAttr ".vclr[13].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[4].vfal" 1;
	setAttr ".vclr[13].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[5].vfal" 1;
	setAttr ".vclr[13].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vxal" 1;
	setAttr -s 4 ".vclr[14].vfcl";
	setAttr ".vclr[14].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[5].vfal" 1;
	setAttr ".vclr[14].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[6].vfal" 1;
	setAttr ".vclr[14].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vxal" 1;
	setAttr -s 4 ".vclr[15].vfcl";
	setAttr ".vclr[15].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[6].vfal" 1;
	setAttr ".vclr[15].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[7].vfal" 1;
	setAttr ".vclr[15].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vxal" 1;
	setAttr -s 4 ".vclr[16].vfcl";
	setAttr ".vclr[16].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[8].vfal" 1;
	setAttr ".vclr[16].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[16].vfal" 1;
	setAttr ".vclr[16].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[23].vfal" 1;
	setAttr ".vclr[17].vxal" 1;
	setAttr -s 4 ".vclr[17].vfcl";
	setAttr ".vclr[17].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[8].vfal" 1;
	setAttr ".vclr[17].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[9].vfal" 1;
	setAttr ".vclr[17].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[16].vfal" 1;
	setAttr ".vclr[17].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vxal" 1;
	setAttr -s 4 ".vclr[18].vfcl";
	setAttr ".vclr[18].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[9].vfal" 1;
	setAttr ".vclr[18].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[10].vfal" 1;
	setAttr ".vclr[18].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vxal" 1;
	setAttr -s 4 ".vclr[19].vfcl";
	setAttr ".vclr[19].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[10].vfal" 1;
	setAttr ".vclr[19].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[11].vfal" 1;
	setAttr ".vclr[19].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vxal" 1;
	setAttr -s 4 ".vclr[20].vfcl";
	setAttr ".vclr[20].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[11].vfal" 1;
	setAttr ".vclr[20].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[12].vfal" 1;
	setAttr ".vclr[20].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vxal" 1;
	setAttr -s 4 ".vclr[21].vfcl";
	setAttr ".vclr[21].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[12].vfal" 1;
	setAttr ".vclr[21].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[13].vfal" 1;
	setAttr ".vclr[21].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vxal" 1;
	setAttr -s 4 ".vclr[22].vfcl";
	setAttr ".vclr[22].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[13].vfal" 1;
	setAttr ".vclr[22].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[14].vfal" 1;
	setAttr ".vclr[22].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vxal" 1;
	setAttr -s 4 ".vclr[23].vfcl";
	setAttr ".vclr[23].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[14].vfal" 1;
	setAttr ".vclr[23].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[15].vfal" 1;
	setAttr ".vclr[23].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vxal" 1;
	setAttr -s 4 ".vclr[24].vfcl";
	setAttr ".vclr[24].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[16].vfal" 1;
	setAttr ".vclr[24].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[24].vfal" 1;
	setAttr ".vclr[24].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[31].vfal" 1;
	setAttr ".vclr[25].vxal" 1;
	setAttr -s 4 ".vclr[25].vfcl";
	setAttr ".vclr[25].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[16].vfal" 1;
	setAttr ".vclr[25].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[17].vfal" 1;
	setAttr ".vclr[25].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[24].vfal" 1;
	setAttr ".vclr[25].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vxal" 1;
	setAttr -s 4 ".vclr[26].vfcl";
	setAttr ".vclr[26].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[17].vfal" 1;
	setAttr ".vclr[26].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[18].vfal" 1;
	setAttr ".vclr[26].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vxal" 1;
	setAttr -s 4 ".vclr[27].vfcl";
	setAttr ".vclr[27].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[18].vfal" 1;
	setAttr ".vclr[27].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[19].vfal" 1;
	setAttr ".vclr[27].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vxal" 1;
	setAttr -s 4 ".vclr[28].vfcl";
	setAttr ".vclr[28].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[19].vfal" 1;
	setAttr ".vclr[28].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[20].vfal" 1;
	setAttr ".vclr[28].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vxal" 1;
	setAttr -s 4 ".vclr[29].vfcl";
	setAttr ".vclr[29].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[20].vfal" 1;
	setAttr ".vclr[29].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[21].vfal" 1;
	setAttr ".vclr[29].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vxal" 1;
	setAttr -s 4 ".vclr[30].vfcl";
	setAttr ".vclr[30].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[21].vfal" 1;
	setAttr ".vclr[30].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[22].vfal" 1;
	setAttr ".vclr[30].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vxal" 1;
	setAttr -s 4 ".vclr[31].vfcl";
	setAttr ".vclr[31].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[22].vfal" 1;
	setAttr ".vclr[31].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[23].vfal" 1;
	setAttr ".vclr[31].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vxal" 1;
	setAttr -s 4 ".vclr[32].vfcl";
	setAttr ".vclr[32].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[24].vfal" 1;
	setAttr ".vclr[32].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[32].vfal" 1;
	setAttr ".vclr[32].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[39].vfal" 1;
	setAttr ".vclr[33].vxal" 1;
	setAttr -s 4 ".vclr[33].vfcl";
	setAttr ".vclr[33].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[24].vfal" 1;
	setAttr ".vclr[33].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[25].vfal" 1;
	setAttr ".vclr[33].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[32].vfal" 1;
	setAttr ".vclr[33].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vxal" 1;
	setAttr -s 4 ".vclr[34].vfcl";
	setAttr ".vclr[34].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[25].vfal" 1;
	setAttr ".vclr[34].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[26].vfal" 1;
	setAttr ".vclr[34].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vxal" 1;
	setAttr -s 4 ".vclr[35].vfcl";
	setAttr ".vclr[35].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[26].vfal" 1;
	setAttr ".vclr[35].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[27].vfal" 1;
	setAttr ".vclr[35].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vxal" 1;
	setAttr -s 4 ".vclr[36].vfcl";
	setAttr ".vclr[36].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[27].vfal" 1;
	setAttr ".vclr[36].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[28].vfal" 1;
	setAttr ".vclr[36].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vxal" 1;
	setAttr -s 4 ".vclr[37].vfcl";
	setAttr ".vclr[37].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[28].vfal" 1;
	setAttr ".vclr[37].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[29].vfal" 1;
	setAttr ".vclr[37].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vxal" 1;
	setAttr -s 4 ".vclr[38].vfcl";
	setAttr ".vclr[38].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[29].vfal" 1;
	setAttr ".vclr[38].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[30].vfal" 1;
	setAttr ".vclr[38].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vxal" 1;
	setAttr -s 4 ".vclr[39].vfcl";
	setAttr ".vclr[39].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[30].vfal" 1;
	setAttr ".vclr[39].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[31].vfal" 1;
	setAttr ".vclr[39].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vxal" 1;
	setAttr -s 4 ".vclr[40].vfcl";
	setAttr ".vclr[40].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[32].vfal" 1;
	setAttr ".vclr[40].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[40].vfal" 1;
	setAttr ".vclr[40].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[47].vfal" 1;
	setAttr ".vclr[41].vxal" 1;
	setAttr -s 4 ".vclr[41].vfcl";
	setAttr ".vclr[41].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[32].vfal" 1;
	setAttr ".vclr[41].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[33].vfal" 1;
	setAttr ".vclr[41].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[40].vfal" 1;
	setAttr ".vclr[41].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vxal" 1;
	setAttr -s 4 ".vclr[42].vfcl";
	setAttr ".vclr[42].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[33].vfal" 1;
	setAttr ".vclr[42].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[34].vfal" 1;
	setAttr ".vclr[42].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vxal" 1;
	setAttr -s 4 ".vclr[43].vfcl";
	setAttr ".vclr[43].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[34].vfal" 1;
	setAttr ".vclr[43].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[35].vfal" 1;
	setAttr ".vclr[43].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vxal" 1;
	setAttr -s 4 ".vclr[44].vfcl";
	setAttr ".vclr[44].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[35].vfal" 1;
	setAttr ".vclr[44].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[36].vfal" 1;
	setAttr ".vclr[44].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vxal" 1;
	setAttr -s 4 ".vclr[45].vfcl";
	setAttr ".vclr[45].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[36].vfal" 1;
	setAttr ".vclr[45].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[37].vfal" 1;
	setAttr ".vclr[45].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vxal" 1;
	setAttr -s 4 ".vclr[46].vfcl";
	setAttr ".vclr[46].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[37].vfal" 1;
	setAttr ".vclr[46].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[38].vfal" 1;
	setAttr ".vclr[46].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vxal" 1;
	setAttr -s 4 ".vclr[47].vfcl";
	setAttr ".vclr[47].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[38].vfal" 1;
	setAttr ".vclr[47].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[39].vfal" 1;
	setAttr ".vclr[47].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vxal" 1;
	setAttr -s 4 ".vclr[48].vfcl";
	setAttr ".vclr[48].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[40].vfal" 1;
	setAttr ".vclr[48].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[56].vfal" 1;
	setAttr ".vclr[48].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[63].vfal" 1;
	setAttr ".vclr[49].vxal" 1;
	setAttr -s 4 ".vclr[49].vfcl";
	setAttr ".vclr[49].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[40].vfal" 1;
	setAttr ".vclr[49].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[41].vfal" 1;
	setAttr ".vclr[49].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[56].vfal" 1;
	setAttr ".vclr[49].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vxal" 1;
	setAttr -s 4 ".vclr[50].vfcl";
	setAttr ".vclr[50].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[41].vfal" 1;
	setAttr ".vclr[50].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[42].vfal" 1;
	setAttr ".vclr[50].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vxal" 1;
	setAttr -s 4 ".vclr[51].vfcl";
	setAttr ".vclr[51].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[42].vfal" 1;
	setAttr ".vclr[51].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[43].vfal" 1;
	setAttr ".vclr[51].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vxal" 1;
	setAttr -s 4 ".vclr[52].vfcl";
	setAttr ".vclr[52].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[43].vfal" 1;
	setAttr ".vclr[52].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[44].vfal" 1;
	setAttr ".vclr[52].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vxal" 1;
	setAttr -s 4 ".vclr[53].vfcl";
	setAttr ".vclr[53].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[44].vfal" 1;
	setAttr ".vclr[53].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[45].vfal" 1;
	setAttr ".vclr[53].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vxal" 1;
	setAttr -s 4 ".vclr[54].vfcl";
	setAttr ".vclr[54].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[45].vfal" 1;
	setAttr ".vclr[54].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[46].vfal" 1;
	setAttr ".vclr[54].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vxal" 1;
	setAttr -s 4 ".vclr[55].vfcl";
	setAttr ".vclr[55].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[46].vfal" 1;
	setAttr ".vclr[55].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[47].vfal" 1;
	setAttr ".vclr[55].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[63].vfal" 1;
	setAttr ".vclr[56].vxal" 1;
	setAttr -s 8 ".vclr[56].vfcl";
	setAttr ".vclr[56].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[48].vfal" 1;
	setAttr ".vclr[56].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[49].vfal" 1;
	setAttr ".vclr[56].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[50].vfal" 1;
	setAttr ".vclr[56].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[51].vfal" 1;
	setAttr ".vclr[56].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[52].vfal" 1;
	setAttr ".vclr[56].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[53].vfal" 1;
	setAttr ".vclr[56].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[54].vfal" 1;
	setAttr ".vclr[56].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[55].vfal" 1;
	setAttr ".vclr[57].vxal" 1;
	setAttr -s 8 ".vclr[57].vfcl";
	setAttr ".vclr[57].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[56].vfal" 1;
	setAttr ".vclr[57].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[57].vfal" 1;
	setAttr ".vclr[57].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[58].vfal" 1;
	setAttr ".vclr[57].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[59].vfal" 1;
	setAttr ".vclr[57].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[60].vfal" 1;
	setAttr ".vclr[57].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[61].vfal" 1;
	setAttr ".vclr[57].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[62].vfal" 1;
	setAttr ".vclr[57].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[63].vfal" 1;
	setAttr ".cn" -type "string" "colorSet1";
	setAttr ".clam" no;
createNode polySphere -n "polySphere8";
	rename -uid "E19DBD39-4AB1-C410-A871-C2B6B2706BD2";
	setAttr ".r" 0.15;
	setAttr ".sa" 8;
	setAttr ".sh" 8;
createNode polyColorPerVertex -n "polyColorPerVertex13";
	rename -uid "DF55122C-47FE-59EA-D6D8-C094EC9785CD";
	setAttr ".uopa" yes;
	setAttr -s 58 ".vclr";
	setAttr ".vclr[0].vxal" 1;
	setAttr -s 4 ".vclr[0].vfcl";
	setAttr ".vclr[0].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[0].vfal" 1;
	setAttr ".vclr[0].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[7].vfal" 1;
	setAttr ".vclr[0].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[48].vfal" 1;
	setAttr ".vclr[0].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[55].vfal" 1;
	setAttr ".vclr[1].vxal" 1;
	setAttr -s 4 ".vclr[1].vfcl";
	setAttr ".vclr[1].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[0].vfal" 1;
	setAttr ".vclr[1].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[1].vfal" 1;
	setAttr ".vclr[1].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[48].vfal" 1;
	setAttr ".vclr[1].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vxal" 1;
	setAttr -s 4 ".vclr[2].vfcl";
	setAttr ".vclr[2].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[1].vfal" 1;
	setAttr ".vclr[2].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[2].vfal" 1;
	setAttr ".vclr[2].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vxal" 1;
	setAttr -s 4 ".vclr[3].vfcl";
	setAttr ".vclr[3].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[2].vfal" 1;
	setAttr ".vclr[3].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[3].vfal" 1;
	setAttr ".vclr[3].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vxal" 1;
	setAttr -s 4 ".vclr[4].vfcl";
	setAttr ".vclr[4].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[3].vfal" 1;
	setAttr ".vclr[4].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[4].vfal" 1;
	setAttr ".vclr[4].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vxal" 1;
	setAttr -s 4 ".vclr[5].vfcl";
	setAttr ".vclr[5].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[4].vfal" 1;
	setAttr ".vclr[5].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[5].vfal" 1;
	setAttr ".vclr[5].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vxal" 1;
	setAttr -s 4 ".vclr[6].vfcl";
	setAttr ".vclr[6].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[5].vfal" 1;
	setAttr ".vclr[6].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[6].vfal" 1;
	setAttr ".vclr[6].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vxal" 1;
	setAttr -s 4 ".vclr[7].vfcl";
	setAttr ".vclr[7].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[6].vfal" 1;
	setAttr ".vclr[7].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[7].vfal" 1;
	setAttr ".vclr[7].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[55].vfal" 1;
	setAttr ".vclr[8].vxal" 1;
	setAttr -s 4 ".vclr[8].vfcl";
	setAttr ".vclr[8].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[0].vfal" 1;
	setAttr ".vclr[8].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[7].vfal" 1;
	setAttr ".vclr[8].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[8].vfal" 1;
	setAttr ".vclr[8].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[15].vfal" 1;
	setAttr ".vclr[9].vxal" 1;
	setAttr -s 4 ".vclr[9].vfcl";
	setAttr ".vclr[9].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[0].vfal" 1;
	setAttr ".vclr[9].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[1].vfal" 1;
	setAttr ".vclr[9].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[8].vfal" 1;
	setAttr ".vclr[9].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vxal" 1;
	setAttr -s 4 ".vclr[10].vfcl";
	setAttr ".vclr[10].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[1].vfal" 1;
	setAttr ".vclr[10].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[2].vfal" 1;
	setAttr ".vclr[10].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vxal" 1;
	setAttr -s 4 ".vclr[11].vfcl";
	setAttr ".vclr[11].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[2].vfal" 1;
	setAttr ".vclr[11].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[3].vfal" 1;
	setAttr ".vclr[11].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vxal" 1;
	setAttr -s 4 ".vclr[12].vfcl";
	setAttr ".vclr[12].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[3].vfal" 1;
	setAttr ".vclr[12].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[4].vfal" 1;
	setAttr ".vclr[12].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vxal" 1;
	setAttr -s 4 ".vclr[13].vfcl";
	setAttr ".vclr[13].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[4].vfal" 1;
	setAttr ".vclr[13].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[5].vfal" 1;
	setAttr ".vclr[13].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vxal" 1;
	setAttr -s 4 ".vclr[14].vfcl";
	setAttr ".vclr[14].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[5].vfal" 1;
	setAttr ".vclr[14].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[6].vfal" 1;
	setAttr ".vclr[14].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vxal" 1;
	setAttr -s 4 ".vclr[15].vfcl";
	setAttr ".vclr[15].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[6].vfal" 1;
	setAttr ".vclr[15].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[7].vfal" 1;
	setAttr ".vclr[15].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vxal" 1;
	setAttr -s 4 ".vclr[16].vfcl";
	setAttr ".vclr[16].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[8].vfal" 1;
	setAttr ".vclr[16].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[16].vfal" 1;
	setAttr ".vclr[16].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[23].vfal" 1;
	setAttr ".vclr[17].vxal" 1;
	setAttr -s 4 ".vclr[17].vfcl";
	setAttr ".vclr[17].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[8].vfal" 1;
	setAttr ".vclr[17].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[9].vfal" 1;
	setAttr ".vclr[17].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[16].vfal" 1;
	setAttr ".vclr[17].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vxal" 1;
	setAttr -s 4 ".vclr[18].vfcl";
	setAttr ".vclr[18].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[9].vfal" 1;
	setAttr ".vclr[18].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[10].vfal" 1;
	setAttr ".vclr[18].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vxal" 1;
	setAttr -s 4 ".vclr[19].vfcl";
	setAttr ".vclr[19].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[10].vfal" 1;
	setAttr ".vclr[19].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[11].vfal" 1;
	setAttr ".vclr[19].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vxal" 1;
	setAttr -s 4 ".vclr[20].vfcl";
	setAttr ".vclr[20].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[11].vfal" 1;
	setAttr ".vclr[20].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[12].vfal" 1;
	setAttr ".vclr[20].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vxal" 1;
	setAttr -s 4 ".vclr[21].vfcl";
	setAttr ".vclr[21].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[12].vfal" 1;
	setAttr ".vclr[21].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[13].vfal" 1;
	setAttr ".vclr[21].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vxal" 1;
	setAttr -s 4 ".vclr[22].vfcl";
	setAttr ".vclr[22].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[13].vfal" 1;
	setAttr ".vclr[22].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[14].vfal" 1;
	setAttr ".vclr[22].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vxal" 1;
	setAttr -s 4 ".vclr[23].vfcl";
	setAttr ".vclr[23].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[14].vfal" 1;
	setAttr ".vclr[23].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[15].vfal" 1;
	setAttr ".vclr[23].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vxal" 1;
	setAttr -s 4 ".vclr[24].vfcl";
	setAttr ".vclr[24].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[16].vfal" 1;
	setAttr ".vclr[24].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[24].vfal" 1;
	setAttr ".vclr[24].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[31].vfal" 1;
	setAttr ".vclr[25].vxal" 1;
	setAttr -s 4 ".vclr[25].vfcl";
	setAttr ".vclr[25].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[16].vfal" 1;
	setAttr ".vclr[25].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[17].vfal" 1;
	setAttr ".vclr[25].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[24].vfal" 1;
	setAttr ".vclr[25].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vxal" 1;
	setAttr -s 4 ".vclr[26].vfcl";
	setAttr ".vclr[26].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[17].vfal" 1;
	setAttr ".vclr[26].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[18].vfal" 1;
	setAttr ".vclr[26].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vxal" 1;
	setAttr -s 4 ".vclr[27].vfcl";
	setAttr ".vclr[27].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[18].vfal" 1;
	setAttr ".vclr[27].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[19].vfal" 1;
	setAttr ".vclr[27].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vxal" 1;
	setAttr -s 4 ".vclr[28].vfcl";
	setAttr ".vclr[28].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[19].vfal" 1;
	setAttr ".vclr[28].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[20].vfal" 1;
	setAttr ".vclr[28].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vxal" 1;
	setAttr -s 4 ".vclr[29].vfcl";
	setAttr ".vclr[29].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[20].vfal" 1;
	setAttr ".vclr[29].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[21].vfal" 1;
	setAttr ".vclr[29].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vxal" 1;
	setAttr -s 4 ".vclr[30].vfcl";
	setAttr ".vclr[30].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[21].vfal" 1;
	setAttr ".vclr[30].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[22].vfal" 1;
	setAttr ".vclr[30].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vxal" 1;
	setAttr -s 4 ".vclr[31].vfcl";
	setAttr ".vclr[31].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[22].vfal" 1;
	setAttr ".vclr[31].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[23].vfal" 1;
	setAttr ".vclr[31].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vxal" 1;
	setAttr -s 4 ".vclr[32].vfcl";
	setAttr ".vclr[32].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[24].vfal" 1;
	setAttr ".vclr[32].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[32].vfal" 1;
	setAttr ".vclr[32].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[39].vfal" 1;
	setAttr ".vclr[33].vxal" 1;
	setAttr -s 4 ".vclr[33].vfcl";
	setAttr ".vclr[33].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[24].vfal" 1;
	setAttr ".vclr[33].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[25].vfal" 1;
	setAttr ".vclr[33].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[32].vfal" 1;
	setAttr ".vclr[33].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vxal" 1;
	setAttr -s 4 ".vclr[34].vfcl";
	setAttr ".vclr[34].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[25].vfal" 1;
	setAttr ".vclr[34].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[26].vfal" 1;
	setAttr ".vclr[34].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vxal" 1;
	setAttr -s 4 ".vclr[35].vfcl";
	setAttr ".vclr[35].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[26].vfal" 1;
	setAttr ".vclr[35].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[27].vfal" 1;
	setAttr ".vclr[35].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vxal" 1;
	setAttr -s 4 ".vclr[36].vfcl";
	setAttr ".vclr[36].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[27].vfal" 1;
	setAttr ".vclr[36].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[28].vfal" 1;
	setAttr ".vclr[36].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vxal" 1;
	setAttr -s 4 ".vclr[37].vfcl";
	setAttr ".vclr[37].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[28].vfal" 1;
	setAttr ".vclr[37].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[29].vfal" 1;
	setAttr ".vclr[37].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vxal" 1;
	setAttr -s 4 ".vclr[38].vfcl";
	setAttr ".vclr[38].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[29].vfal" 1;
	setAttr ".vclr[38].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[30].vfal" 1;
	setAttr ".vclr[38].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vxal" 1;
	setAttr -s 4 ".vclr[39].vfcl";
	setAttr ".vclr[39].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[30].vfal" 1;
	setAttr ".vclr[39].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[31].vfal" 1;
	setAttr ".vclr[39].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vxal" 1;
	setAttr -s 4 ".vclr[40].vfcl";
	setAttr ".vclr[40].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[32].vfal" 1;
	setAttr ".vclr[40].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[40].vfal" 1;
	setAttr ".vclr[40].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[47].vfal" 1;
	setAttr ".vclr[41].vxal" 1;
	setAttr -s 4 ".vclr[41].vfcl";
	setAttr ".vclr[41].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[32].vfal" 1;
	setAttr ".vclr[41].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[33].vfal" 1;
	setAttr ".vclr[41].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[40].vfal" 1;
	setAttr ".vclr[41].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vxal" 1;
	setAttr -s 4 ".vclr[42].vfcl";
	setAttr ".vclr[42].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[33].vfal" 1;
	setAttr ".vclr[42].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[34].vfal" 1;
	setAttr ".vclr[42].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vxal" 1;
	setAttr -s 4 ".vclr[43].vfcl";
	setAttr ".vclr[43].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[34].vfal" 1;
	setAttr ".vclr[43].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[35].vfal" 1;
	setAttr ".vclr[43].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vxal" 1;
	setAttr -s 4 ".vclr[44].vfcl";
	setAttr ".vclr[44].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[35].vfal" 1;
	setAttr ".vclr[44].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[36].vfal" 1;
	setAttr ".vclr[44].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vxal" 1;
	setAttr -s 4 ".vclr[45].vfcl";
	setAttr ".vclr[45].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[36].vfal" 1;
	setAttr ".vclr[45].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[37].vfal" 1;
	setAttr ".vclr[45].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vxal" 1;
	setAttr -s 4 ".vclr[46].vfcl";
	setAttr ".vclr[46].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[37].vfal" 1;
	setAttr ".vclr[46].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[38].vfal" 1;
	setAttr ".vclr[46].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vxal" 1;
	setAttr -s 4 ".vclr[47].vfcl";
	setAttr ".vclr[47].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[38].vfal" 1;
	setAttr ".vclr[47].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[39].vfal" 1;
	setAttr ".vclr[47].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vxal" 1;
	setAttr -s 4 ".vclr[48].vfcl";
	setAttr ".vclr[48].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[40].vfal" 1;
	setAttr ".vclr[48].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[56].vfal" 1;
	setAttr ".vclr[48].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[63].vfal" 1;
	setAttr ".vclr[49].vxal" 1;
	setAttr -s 4 ".vclr[49].vfcl";
	setAttr ".vclr[49].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[40].vfal" 1;
	setAttr ".vclr[49].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[41].vfal" 1;
	setAttr ".vclr[49].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[56].vfal" 1;
	setAttr ".vclr[49].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vxal" 1;
	setAttr -s 4 ".vclr[50].vfcl";
	setAttr ".vclr[50].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[41].vfal" 1;
	setAttr ".vclr[50].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[42].vfal" 1;
	setAttr ".vclr[50].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vxal" 1;
	setAttr -s 4 ".vclr[51].vfcl";
	setAttr ".vclr[51].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[42].vfal" 1;
	setAttr ".vclr[51].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[43].vfal" 1;
	setAttr ".vclr[51].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vxal" 1;
	setAttr -s 4 ".vclr[52].vfcl";
	setAttr ".vclr[52].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[43].vfal" 1;
	setAttr ".vclr[52].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[44].vfal" 1;
	setAttr ".vclr[52].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vxal" 1;
	setAttr -s 4 ".vclr[53].vfcl";
	setAttr ".vclr[53].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[44].vfal" 1;
	setAttr ".vclr[53].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[45].vfal" 1;
	setAttr ".vclr[53].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vxal" 1;
	setAttr -s 4 ".vclr[54].vfcl";
	setAttr ".vclr[54].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[45].vfal" 1;
	setAttr ".vclr[54].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[46].vfal" 1;
	setAttr ".vclr[54].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vxal" 1;
	setAttr -s 4 ".vclr[55].vfcl";
	setAttr ".vclr[55].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[46].vfal" 1;
	setAttr ".vclr[55].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[47].vfal" 1;
	setAttr ".vclr[55].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[63].vfal" 1;
	setAttr ".vclr[56].vxal" 1;
	setAttr -s 8 ".vclr[56].vfcl";
	setAttr ".vclr[56].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[48].vfal" 1;
	setAttr ".vclr[56].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[49].vfal" 1;
	setAttr ".vclr[56].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[50].vfal" 1;
	setAttr ".vclr[56].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[51].vfal" 1;
	setAttr ".vclr[56].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[52].vfal" 1;
	setAttr ".vclr[56].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[53].vfal" 1;
	setAttr ".vclr[56].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[54].vfal" 1;
	setAttr ".vclr[56].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[55].vfal" 1;
	setAttr ".vclr[57].vxal" 1;
	setAttr -s 8 ".vclr[57].vfcl";
	setAttr ".vclr[57].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[56].vfal" 1;
	setAttr ".vclr[57].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[57].vfal" 1;
	setAttr ".vclr[57].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[58].vfal" 1;
	setAttr ".vclr[57].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[59].vfal" 1;
	setAttr ".vclr[57].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[60].vfal" 1;
	setAttr ".vclr[57].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[61].vfal" 1;
	setAttr ".vclr[57].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[62].vfal" 1;
	setAttr ".vclr[57].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[63].vfal" 1;
	setAttr ".cn" -type "string" "colorSet1";
	setAttr ".clam" no;
createNode polySphere -n "polySphere13";
	rename -uid "F15150EB-45EB-C399-8722-36B1F56DF4FA";
	setAttr ".r" 0.15;
	setAttr ".sa" 8;
	setAttr ".sh" 8;
createNode polyColorPerVertex -n "polyColorPerVertex2";
	rename -uid "FBE78864-4E46-C6E4-0BC7-4BAF56651890";
	setAttr ".uopa" yes;
	setAttr -s 58 ".vclr";
	setAttr ".vclr[0].vxal" 1;
	setAttr -s 4 ".vclr[0].vfcl";
	setAttr ".vclr[0].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[0].vfal" 1;
	setAttr ".vclr[0].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[7].vfal" 1;
	setAttr ".vclr[0].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[48].vfal" 1;
	setAttr ".vclr[0].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[55].vfal" 1;
	setAttr ".vclr[1].vxal" 1;
	setAttr -s 4 ".vclr[1].vfcl";
	setAttr ".vclr[1].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[0].vfal" 1;
	setAttr ".vclr[1].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[1].vfal" 1;
	setAttr ".vclr[1].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[48].vfal" 1;
	setAttr ".vclr[1].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vxal" 1;
	setAttr -s 4 ".vclr[2].vfcl";
	setAttr ".vclr[2].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[1].vfal" 1;
	setAttr ".vclr[2].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[2].vfal" 1;
	setAttr ".vclr[2].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vxal" 1;
	setAttr -s 4 ".vclr[3].vfcl";
	setAttr ".vclr[3].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[2].vfal" 1;
	setAttr ".vclr[3].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[3].vfal" 1;
	setAttr ".vclr[3].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vxal" 1;
	setAttr -s 4 ".vclr[4].vfcl";
	setAttr ".vclr[4].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[3].vfal" 1;
	setAttr ".vclr[4].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[4].vfal" 1;
	setAttr ".vclr[4].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vxal" 1;
	setAttr -s 4 ".vclr[5].vfcl";
	setAttr ".vclr[5].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[4].vfal" 1;
	setAttr ".vclr[5].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[5].vfal" 1;
	setAttr ".vclr[5].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vxal" 1;
	setAttr -s 4 ".vclr[6].vfcl";
	setAttr ".vclr[6].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[5].vfal" 1;
	setAttr ".vclr[6].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[6].vfal" 1;
	setAttr ".vclr[6].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vxal" 1;
	setAttr -s 4 ".vclr[7].vfcl";
	setAttr ".vclr[7].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[6].vfal" 1;
	setAttr ".vclr[7].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[7].vfal" 1;
	setAttr ".vclr[7].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[55].vfal" 1;
	setAttr ".vclr[8].vxal" 1;
	setAttr -s 4 ".vclr[8].vfcl";
	setAttr ".vclr[8].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[0].vfal" 1;
	setAttr ".vclr[8].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[7].vfal" 1;
	setAttr ".vclr[8].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[8].vfal" 1;
	setAttr ".vclr[8].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[15].vfal" 1;
	setAttr ".vclr[9].vxal" 1;
	setAttr -s 4 ".vclr[9].vfcl";
	setAttr ".vclr[9].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[0].vfal" 1;
	setAttr ".vclr[9].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[1].vfal" 1;
	setAttr ".vclr[9].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[8].vfal" 1;
	setAttr ".vclr[9].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vxal" 1;
	setAttr -s 4 ".vclr[10].vfcl";
	setAttr ".vclr[10].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[1].vfal" 1;
	setAttr ".vclr[10].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[2].vfal" 1;
	setAttr ".vclr[10].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vxal" 1;
	setAttr -s 4 ".vclr[11].vfcl";
	setAttr ".vclr[11].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[2].vfal" 1;
	setAttr ".vclr[11].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[3].vfal" 1;
	setAttr ".vclr[11].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vxal" 1;
	setAttr -s 4 ".vclr[12].vfcl";
	setAttr ".vclr[12].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[3].vfal" 1;
	setAttr ".vclr[12].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[4].vfal" 1;
	setAttr ".vclr[12].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vxal" 1;
	setAttr -s 4 ".vclr[13].vfcl";
	setAttr ".vclr[13].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[4].vfal" 1;
	setAttr ".vclr[13].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[5].vfal" 1;
	setAttr ".vclr[13].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vxal" 1;
	setAttr -s 4 ".vclr[14].vfcl";
	setAttr ".vclr[14].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[5].vfal" 1;
	setAttr ".vclr[14].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[6].vfal" 1;
	setAttr ".vclr[14].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vxal" 1;
	setAttr -s 4 ".vclr[15].vfcl";
	setAttr ".vclr[15].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[6].vfal" 1;
	setAttr ".vclr[15].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[7].vfal" 1;
	setAttr ".vclr[15].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vxal" 1;
	setAttr -s 4 ".vclr[16].vfcl";
	setAttr ".vclr[16].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[8].vfal" 1;
	setAttr ".vclr[16].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[16].vfal" 1;
	setAttr ".vclr[16].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[23].vfal" 1;
	setAttr ".vclr[17].vxal" 1;
	setAttr -s 4 ".vclr[17].vfcl";
	setAttr ".vclr[17].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[8].vfal" 1;
	setAttr ".vclr[17].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[9].vfal" 1;
	setAttr ".vclr[17].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[16].vfal" 1;
	setAttr ".vclr[17].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vxal" 1;
	setAttr -s 4 ".vclr[18].vfcl";
	setAttr ".vclr[18].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[9].vfal" 1;
	setAttr ".vclr[18].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[10].vfal" 1;
	setAttr ".vclr[18].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vxal" 1;
	setAttr -s 4 ".vclr[19].vfcl";
	setAttr ".vclr[19].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[10].vfal" 1;
	setAttr ".vclr[19].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[11].vfal" 1;
	setAttr ".vclr[19].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vxal" 1;
	setAttr -s 4 ".vclr[20].vfcl";
	setAttr ".vclr[20].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[11].vfal" 1;
	setAttr ".vclr[20].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[12].vfal" 1;
	setAttr ".vclr[20].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vxal" 1;
	setAttr -s 4 ".vclr[21].vfcl";
	setAttr ".vclr[21].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[12].vfal" 1;
	setAttr ".vclr[21].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[13].vfal" 1;
	setAttr ".vclr[21].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vxal" 1;
	setAttr -s 4 ".vclr[22].vfcl";
	setAttr ".vclr[22].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[13].vfal" 1;
	setAttr ".vclr[22].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[14].vfal" 1;
	setAttr ".vclr[22].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vxal" 1;
	setAttr -s 4 ".vclr[23].vfcl";
	setAttr ".vclr[23].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[14].vfal" 1;
	setAttr ".vclr[23].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[15].vfal" 1;
	setAttr ".vclr[23].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vxal" 1;
	setAttr -s 4 ".vclr[24].vfcl";
	setAttr ".vclr[24].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[16].vfal" 1;
	setAttr ".vclr[24].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[24].vfal" 1;
	setAttr ".vclr[24].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[31].vfal" 1;
	setAttr ".vclr[25].vxal" 1;
	setAttr -s 4 ".vclr[25].vfcl";
	setAttr ".vclr[25].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[16].vfal" 1;
	setAttr ".vclr[25].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[17].vfal" 1;
	setAttr ".vclr[25].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[24].vfal" 1;
	setAttr ".vclr[25].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vxal" 1;
	setAttr -s 4 ".vclr[26].vfcl";
	setAttr ".vclr[26].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[17].vfal" 1;
	setAttr ".vclr[26].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[18].vfal" 1;
	setAttr ".vclr[26].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vxal" 1;
	setAttr -s 4 ".vclr[27].vfcl";
	setAttr ".vclr[27].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[18].vfal" 1;
	setAttr ".vclr[27].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[19].vfal" 1;
	setAttr ".vclr[27].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vxal" 1;
	setAttr -s 4 ".vclr[28].vfcl";
	setAttr ".vclr[28].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[19].vfal" 1;
	setAttr ".vclr[28].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[20].vfal" 1;
	setAttr ".vclr[28].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vxal" 1;
	setAttr -s 4 ".vclr[29].vfcl";
	setAttr ".vclr[29].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[20].vfal" 1;
	setAttr ".vclr[29].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[21].vfal" 1;
	setAttr ".vclr[29].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vxal" 1;
	setAttr -s 4 ".vclr[30].vfcl";
	setAttr ".vclr[30].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[21].vfal" 1;
	setAttr ".vclr[30].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[22].vfal" 1;
	setAttr ".vclr[30].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vxal" 1;
	setAttr -s 4 ".vclr[31].vfcl";
	setAttr ".vclr[31].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[22].vfal" 1;
	setAttr ".vclr[31].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[23].vfal" 1;
	setAttr ".vclr[31].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vxal" 1;
	setAttr -s 4 ".vclr[32].vfcl";
	setAttr ".vclr[32].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[24].vfal" 1;
	setAttr ".vclr[32].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[32].vfal" 1;
	setAttr ".vclr[32].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[39].vfal" 1;
	setAttr ".vclr[33].vxal" 1;
	setAttr -s 4 ".vclr[33].vfcl";
	setAttr ".vclr[33].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[24].vfal" 1;
	setAttr ".vclr[33].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[25].vfal" 1;
	setAttr ".vclr[33].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[32].vfal" 1;
	setAttr ".vclr[33].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vxal" 1;
	setAttr -s 4 ".vclr[34].vfcl";
	setAttr ".vclr[34].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[25].vfal" 1;
	setAttr ".vclr[34].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[26].vfal" 1;
	setAttr ".vclr[34].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vxal" 1;
	setAttr -s 4 ".vclr[35].vfcl";
	setAttr ".vclr[35].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[26].vfal" 1;
	setAttr ".vclr[35].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[27].vfal" 1;
	setAttr ".vclr[35].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vxal" 1;
	setAttr -s 4 ".vclr[36].vfcl";
	setAttr ".vclr[36].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[27].vfal" 1;
	setAttr ".vclr[36].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[28].vfal" 1;
	setAttr ".vclr[36].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vxal" 1;
	setAttr -s 4 ".vclr[37].vfcl";
	setAttr ".vclr[37].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[28].vfal" 1;
	setAttr ".vclr[37].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[29].vfal" 1;
	setAttr ".vclr[37].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vxal" 1;
	setAttr -s 4 ".vclr[38].vfcl";
	setAttr ".vclr[38].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[29].vfal" 1;
	setAttr ".vclr[38].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[30].vfal" 1;
	setAttr ".vclr[38].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vxal" 1;
	setAttr -s 4 ".vclr[39].vfcl";
	setAttr ".vclr[39].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[30].vfal" 1;
	setAttr ".vclr[39].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[31].vfal" 1;
	setAttr ".vclr[39].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vxal" 1;
	setAttr -s 4 ".vclr[40].vfcl";
	setAttr ".vclr[40].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[32].vfal" 1;
	setAttr ".vclr[40].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[40].vfal" 1;
	setAttr ".vclr[40].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[47].vfal" 1;
	setAttr ".vclr[41].vxal" 1;
	setAttr -s 4 ".vclr[41].vfcl";
	setAttr ".vclr[41].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[32].vfal" 1;
	setAttr ".vclr[41].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[33].vfal" 1;
	setAttr ".vclr[41].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[40].vfal" 1;
	setAttr ".vclr[41].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vxal" 1;
	setAttr -s 4 ".vclr[42].vfcl";
	setAttr ".vclr[42].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[33].vfal" 1;
	setAttr ".vclr[42].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[34].vfal" 1;
	setAttr ".vclr[42].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vxal" 1;
	setAttr -s 4 ".vclr[43].vfcl";
	setAttr ".vclr[43].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[34].vfal" 1;
	setAttr ".vclr[43].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[35].vfal" 1;
	setAttr ".vclr[43].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vxal" 1;
	setAttr -s 4 ".vclr[44].vfcl";
	setAttr ".vclr[44].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[35].vfal" 1;
	setAttr ".vclr[44].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[36].vfal" 1;
	setAttr ".vclr[44].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vxal" 1;
	setAttr -s 4 ".vclr[45].vfcl";
	setAttr ".vclr[45].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[36].vfal" 1;
	setAttr ".vclr[45].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[37].vfal" 1;
	setAttr ".vclr[45].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vxal" 1;
	setAttr -s 4 ".vclr[46].vfcl";
	setAttr ".vclr[46].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[37].vfal" 1;
	setAttr ".vclr[46].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[38].vfal" 1;
	setAttr ".vclr[46].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vxal" 1;
	setAttr -s 4 ".vclr[47].vfcl";
	setAttr ".vclr[47].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[38].vfal" 1;
	setAttr ".vclr[47].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[39].vfal" 1;
	setAttr ".vclr[47].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vxal" 1;
	setAttr -s 4 ".vclr[48].vfcl";
	setAttr ".vclr[48].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[40].vfal" 1;
	setAttr ".vclr[48].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[56].vfal" 1;
	setAttr ".vclr[48].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[63].vfal" 1;
	setAttr ".vclr[49].vxal" 1;
	setAttr -s 4 ".vclr[49].vfcl";
	setAttr ".vclr[49].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[40].vfal" 1;
	setAttr ".vclr[49].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[41].vfal" 1;
	setAttr ".vclr[49].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[56].vfal" 1;
	setAttr ".vclr[49].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vxal" 1;
	setAttr -s 4 ".vclr[50].vfcl";
	setAttr ".vclr[50].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[41].vfal" 1;
	setAttr ".vclr[50].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[42].vfal" 1;
	setAttr ".vclr[50].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vxal" 1;
	setAttr -s 4 ".vclr[51].vfcl";
	setAttr ".vclr[51].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[42].vfal" 1;
	setAttr ".vclr[51].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[43].vfal" 1;
	setAttr ".vclr[51].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vxal" 1;
	setAttr -s 4 ".vclr[52].vfcl";
	setAttr ".vclr[52].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[43].vfal" 1;
	setAttr ".vclr[52].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[44].vfal" 1;
	setAttr ".vclr[52].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vxal" 1;
	setAttr -s 4 ".vclr[53].vfcl";
	setAttr ".vclr[53].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[44].vfal" 1;
	setAttr ".vclr[53].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[45].vfal" 1;
	setAttr ".vclr[53].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vxal" 1;
	setAttr -s 4 ".vclr[54].vfcl";
	setAttr ".vclr[54].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[45].vfal" 1;
	setAttr ".vclr[54].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[46].vfal" 1;
	setAttr ".vclr[54].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vxal" 1;
	setAttr -s 4 ".vclr[55].vfcl";
	setAttr ".vclr[55].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[46].vfal" 1;
	setAttr ".vclr[55].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[47].vfal" 1;
	setAttr ".vclr[55].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[63].vfal" 1;
	setAttr ".vclr[56].vxal" 1;
	setAttr -s 8 ".vclr[56].vfcl";
	setAttr ".vclr[56].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[48].vfal" 1;
	setAttr ".vclr[56].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[49].vfal" 1;
	setAttr ".vclr[56].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[50].vfal" 1;
	setAttr ".vclr[56].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[51].vfal" 1;
	setAttr ".vclr[56].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[52].vfal" 1;
	setAttr ".vclr[56].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[53].vfal" 1;
	setAttr ".vclr[56].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[54].vfal" 1;
	setAttr ".vclr[56].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[55].vfal" 1;
	setAttr ".vclr[57].vxal" 1;
	setAttr -s 8 ".vclr[57].vfcl";
	setAttr ".vclr[57].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[56].vfal" 1;
	setAttr ".vclr[57].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[57].vfal" 1;
	setAttr ".vclr[57].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[58].vfal" 1;
	setAttr ".vclr[57].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[59].vfal" 1;
	setAttr ".vclr[57].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[60].vfal" 1;
	setAttr ".vclr[57].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[61].vfal" 1;
	setAttr ".vclr[57].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[62].vfal" 1;
	setAttr ".vclr[57].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[63].vfal" 1;
	setAttr ".cn" -type "string" "colorSet1";
	setAttr ".clam" no;
createNode polySphere -n "polySphere2";
	rename -uid "0A8F005A-4B2F-90E4-1E9C-DAAC59E741F8";
	setAttr ".r" 0.15;
	setAttr ".sa" 8;
	setAttr ".sh" 8;
createNode polyColorPerVertex -n "polyColorPerVertex3";
	rename -uid "E2E61723-4F8D-67FB-0E45-A19A8B505DF2";
	setAttr ".uopa" yes;
	setAttr -s 58 ".vclr";
	setAttr ".vclr[0].vxal" 1;
	setAttr -s 4 ".vclr[0].vfcl";
	setAttr ".vclr[0].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[0].vfal" 1;
	setAttr ".vclr[0].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[7].vfal" 1;
	setAttr ".vclr[0].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[48].vfal" 1;
	setAttr ".vclr[0].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[55].vfal" 1;
	setAttr ".vclr[1].vxal" 1;
	setAttr -s 4 ".vclr[1].vfcl";
	setAttr ".vclr[1].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[0].vfal" 1;
	setAttr ".vclr[1].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[1].vfal" 1;
	setAttr ".vclr[1].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[48].vfal" 1;
	setAttr ".vclr[1].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vxal" 1;
	setAttr -s 4 ".vclr[2].vfcl";
	setAttr ".vclr[2].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[1].vfal" 1;
	setAttr ".vclr[2].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[2].vfal" 1;
	setAttr ".vclr[2].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vxal" 1;
	setAttr -s 4 ".vclr[3].vfcl";
	setAttr ".vclr[3].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[2].vfal" 1;
	setAttr ".vclr[3].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[3].vfal" 1;
	setAttr ".vclr[3].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vxal" 1;
	setAttr -s 4 ".vclr[4].vfcl";
	setAttr ".vclr[4].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[3].vfal" 1;
	setAttr ".vclr[4].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[4].vfal" 1;
	setAttr ".vclr[4].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vxal" 1;
	setAttr -s 4 ".vclr[5].vfcl";
	setAttr ".vclr[5].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[4].vfal" 1;
	setAttr ".vclr[5].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[5].vfal" 1;
	setAttr ".vclr[5].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vxal" 1;
	setAttr -s 4 ".vclr[6].vfcl";
	setAttr ".vclr[6].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[5].vfal" 1;
	setAttr ".vclr[6].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[6].vfal" 1;
	setAttr ".vclr[6].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vxal" 1;
	setAttr -s 4 ".vclr[7].vfcl";
	setAttr ".vclr[7].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[6].vfal" 1;
	setAttr ".vclr[7].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[7].vfal" 1;
	setAttr ".vclr[7].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[55].vfal" 1;
	setAttr ".vclr[8].vxal" 1;
	setAttr -s 4 ".vclr[8].vfcl";
	setAttr ".vclr[8].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[0].vfal" 1;
	setAttr ".vclr[8].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[7].vfal" 1;
	setAttr ".vclr[8].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[8].vfal" 1;
	setAttr ".vclr[8].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[15].vfal" 1;
	setAttr ".vclr[9].vxal" 1;
	setAttr -s 4 ".vclr[9].vfcl";
	setAttr ".vclr[9].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[0].vfal" 1;
	setAttr ".vclr[9].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[1].vfal" 1;
	setAttr ".vclr[9].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[8].vfal" 1;
	setAttr ".vclr[9].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vxal" 1;
	setAttr -s 4 ".vclr[10].vfcl";
	setAttr ".vclr[10].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[1].vfal" 1;
	setAttr ".vclr[10].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[2].vfal" 1;
	setAttr ".vclr[10].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vxal" 1;
	setAttr -s 4 ".vclr[11].vfcl";
	setAttr ".vclr[11].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[2].vfal" 1;
	setAttr ".vclr[11].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[3].vfal" 1;
	setAttr ".vclr[11].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vxal" 1;
	setAttr -s 4 ".vclr[12].vfcl";
	setAttr ".vclr[12].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[3].vfal" 1;
	setAttr ".vclr[12].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[4].vfal" 1;
	setAttr ".vclr[12].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vxal" 1;
	setAttr -s 4 ".vclr[13].vfcl";
	setAttr ".vclr[13].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[4].vfal" 1;
	setAttr ".vclr[13].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[5].vfal" 1;
	setAttr ".vclr[13].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vxal" 1;
	setAttr -s 4 ".vclr[14].vfcl";
	setAttr ".vclr[14].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[5].vfal" 1;
	setAttr ".vclr[14].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[6].vfal" 1;
	setAttr ".vclr[14].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vxal" 1;
	setAttr -s 4 ".vclr[15].vfcl";
	setAttr ".vclr[15].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[6].vfal" 1;
	setAttr ".vclr[15].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[7].vfal" 1;
	setAttr ".vclr[15].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vxal" 1;
	setAttr -s 4 ".vclr[16].vfcl";
	setAttr ".vclr[16].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[8].vfal" 1;
	setAttr ".vclr[16].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[16].vfal" 1;
	setAttr ".vclr[16].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[23].vfal" 1;
	setAttr ".vclr[17].vxal" 1;
	setAttr -s 4 ".vclr[17].vfcl";
	setAttr ".vclr[17].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[8].vfal" 1;
	setAttr ".vclr[17].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[9].vfal" 1;
	setAttr ".vclr[17].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[16].vfal" 1;
	setAttr ".vclr[17].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vxal" 1;
	setAttr -s 4 ".vclr[18].vfcl";
	setAttr ".vclr[18].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[9].vfal" 1;
	setAttr ".vclr[18].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[10].vfal" 1;
	setAttr ".vclr[18].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vxal" 1;
	setAttr -s 4 ".vclr[19].vfcl";
	setAttr ".vclr[19].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[10].vfal" 1;
	setAttr ".vclr[19].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[11].vfal" 1;
	setAttr ".vclr[19].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vxal" 1;
	setAttr -s 4 ".vclr[20].vfcl";
	setAttr ".vclr[20].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[11].vfal" 1;
	setAttr ".vclr[20].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[12].vfal" 1;
	setAttr ".vclr[20].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vxal" 1;
	setAttr -s 4 ".vclr[21].vfcl";
	setAttr ".vclr[21].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[12].vfal" 1;
	setAttr ".vclr[21].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[13].vfal" 1;
	setAttr ".vclr[21].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vxal" 1;
	setAttr -s 4 ".vclr[22].vfcl";
	setAttr ".vclr[22].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[13].vfal" 1;
	setAttr ".vclr[22].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[14].vfal" 1;
	setAttr ".vclr[22].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vxal" 1;
	setAttr -s 4 ".vclr[23].vfcl";
	setAttr ".vclr[23].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[14].vfal" 1;
	setAttr ".vclr[23].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[15].vfal" 1;
	setAttr ".vclr[23].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vxal" 1;
	setAttr -s 4 ".vclr[24].vfcl";
	setAttr ".vclr[24].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[16].vfal" 1;
	setAttr ".vclr[24].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[24].vfal" 1;
	setAttr ".vclr[24].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[31].vfal" 1;
	setAttr ".vclr[25].vxal" 1;
	setAttr -s 4 ".vclr[25].vfcl";
	setAttr ".vclr[25].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[16].vfal" 1;
	setAttr ".vclr[25].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[17].vfal" 1;
	setAttr ".vclr[25].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[24].vfal" 1;
	setAttr ".vclr[25].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vxal" 1;
	setAttr -s 4 ".vclr[26].vfcl";
	setAttr ".vclr[26].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[17].vfal" 1;
	setAttr ".vclr[26].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[18].vfal" 1;
	setAttr ".vclr[26].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vxal" 1;
	setAttr -s 4 ".vclr[27].vfcl";
	setAttr ".vclr[27].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[18].vfal" 1;
	setAttr ".vclr[27].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[19].vfal" 1;
	setAttr ".vclr[27].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vxal" 1;
	setAttr -s 4 ".vclr[28].vfcl";
	setAttr ".vclr[28].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[19].vfal" 1;
	setAttr ".vclr[28].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[20].vfal" 1;
	setAttr ".vclr[28].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vxal" 1;
	setAttr -s 4 ".vclr[29].vfcl";
	setAttr ".vclr[29].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[20].vfal" 1;
	setAttr ".vclr[29].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[21].vfal" 1;
	setAttr ".vclr[29].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vxal" 1;
	setAttr -s 4 ".vclr[30].vfcl";
	setAttr ".vclr[30].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[21].vfal" 1;
	setAttr ".vclr[30].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[22].vfal" 1;
	setAttr ".vclr[30].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vxal" 1;
	setAttr -s 4 ".vclr[31].vfcl";
	setAttr ".vclr[31].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[22].vfal" 1;
	setAttr ".vclr[31].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[23].vfal" 1;
	setAttr ".vclr[31].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vxal" 1;
	setAttr -s 4 ".vclr[32].vfcl";
	setAttr ".vclr[32].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[24].vfal" 1;
	setAttr ".vclr[32].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[32].vfal" 1;
	setAttr ".vclr[32].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[39].vfal" 1;
	setAttr ".vclr[33].vxal" 1;
	setAttr -s 4 ".vclr[33].vfcl";
	setAttr ".vclr[33].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[24].vfal" 1;
	setAttr ".vclr[33].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[25].vfal" 1;
	setAttr ".vclr[33].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[32].vfal" 1;
	setAttr ".vclr[33].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vxal" 1;
	setAttr -s 4 ".vclr[34].vfcl";
	setAttr ".vclr[34].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[25].vfal" 1;
	setAttr ".vclr[34].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[26].vfal" 1;
	setAttr ".vclr[34].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vxal" 1;
	setAttr -s 4 ".vclr[35].vfcl";
	setAttr ".vclr[35].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[26].vfal" 1;
	setAttr ".vclr[35].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[27].vfal" 1;
	setAttr ".vclr[35].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vxal" 1;
	setAttr -s 4 ".vclr[36].vfcl";
	setAttr ".vclr[36].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[27].vfal" 1;
	setAttr ".vclr[36].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[28].vfal" 1;
	setAttr ".vclr[36].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vxal" 1;
	setAttr -s 4 ".vclr[37].vfcl";
	setAttr ".vclr[37].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[28].vfal" 1;
	setAttr ".vclr[37].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[29].vfal" 1;
	setAttr ".vclr[37].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vxal" 1;
	setAttr -s 4 ".vclr[38].vfcl";
	setAttr ".vclr[38].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[29].vfal" 1;
	setAttr ".vclr[38].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[30].vfal" 1;
	setAttr ".vclr[38].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vxal" 1;
	setAttr -s 4 ".vclr[39].vfcl";
	setAttr ".vclr[39].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[30].vfal" 1;
	setAttr ".vclr[39].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[31].vfal" 1;
	setAttr ".vclr[39].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vxal" 1;
	setAttr -s 4 ".vclr[40].vfcl";
	setAttr ".vclr[40].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[32].vfal" 1;
	setAttr ".vclr[40].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[40].vfal" 1;
	setAttr ".vclr[40].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[47].vfal" 1;
	setAttr ".vclr[41].vxal" 1;
	setAttr -s 4 ".vclr[41].vfcl";
	setAttr ".vclr[41].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[32].vfal" 1;
	setAttr ".vclr[41].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[33].vfal" 1;
	setAttr ".vclr[41].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[40].vfal" 1;
	setAttr ".vclr[41].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vxal" 1;
	setAttr -s 4 ".vclr[42].vfcl";
	setAttr ".vclr[42].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[33].vfal" 1;
	setAttr ".vclr[42].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[34].vfal" 1;
	setAttr ".vclr[42].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vxal" 1;
	setAttr -s 4 ".vclr[43].vfcl";
	setAttr ".vclr[43].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[34].vfal" 1;
	setAttr ".vclr[43].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[35].vfal" 1;
	setAttr ".vclr[43].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vxal" 1;
	setAttr -s 4 ".vclr[44].vfcl";
	setAttr ".vclr[44].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[35].vfal" 1;
	setAttr ".vclr[44].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[36].vfal" 1;
	setAttr ".vclr[44].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vxal" 1;
	setAttr -s 4 ".vclr[45].vfcl";
	setAttr ".vclr[45].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[36].vfal" 1;
	setAttr ".vclr[45].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[37].vfal" 1;
	setAttr ".vclr[45].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vxal" 1;
	setAttr -s 4 ".vclr[46].vfcl";
	setAttr ".vclr[46].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[37].vfal" 1;
	setAttr ".vclr[46].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[38].vfal" 1;
	setAttr ".vclr[46].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vxal" 1;
	setAttr -s 4 ".vclr[47].vfcl";
	setAttr ".vclr[47].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[38].vfal" 1;
	setAttr ".vclr[47].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[39].vfal" 1;
	setAttr ".vclr[47].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vxal" 1;
	setAttr -s 4 ".vclr[48].vfcl";
	setAttr ".vclr[48].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[40].vfal" 1;
	setAttr ".vclr[48].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[56].vfal" 1;
	setAttr ".vclr[48].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[63].vfal" 1;
	setAttr ".vclr[49].vxal" 1;
	setAttr -s 4 ".vclr[49].vfcl";
	setAttr ".vclr[49].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[40].vfal" 1;
	setAttr ".vclr[49].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[41].vfal" 1;
	setAttr ".vclr[49].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[56].vfal" 1;
	setAttr ".vclr[49].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vxal" 1;
	setAttr -s 4 ".vclr[50].vfcl";
	setAttr ".vclr[50].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[41].vfal" 1;
	setAttr ".vclr[50].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[42].vfal" 1;
	setAttr ".vclr[50].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vxal" 1;
	setAttr -s 4 ".vclr[51].vfcl";
	setAttr ".vclr[51].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[42].vfal" 1;
	setAttr ".vclr[51].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[43].vfal" 1;
	setAttr ".vclr[51].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vxal" 1;
	setAttr -s 4 ".vclr[52].vfcl";
	setAttr ".vclr[52].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[43].vfal" 1;
	setAttr ".vclr[52].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[44].vfal" 1;
	setAttr ".vclr[52].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vxal" 1;
	setAttr -s 4 ".vclr[53].vfcl";
	setAttr ".vclr[53].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[44].vfal" 1;
	setAttr ".vclr[53].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[45].vfal" 1;
	setAttr ".vclr[53].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vxal" 1;
	setAttr -s 4 ".vclr[54].vfcl";
	setAttr ".vclr[54].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[45].vfal" 1;
	setAttr ".vclr[54].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[46].vfal" 1;
	setAttr ".vclr[54].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vxal" 1;
	setAttr -s 4 ".vclr[55].vfcl";
	setAttr ".vclr[55].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[46].vfal" 1;
	setAttr ".vclr[55].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[47].vfal" 1;
	setAttr ".vclr[55].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[63].vfal" 1;
	setAttr ".vclr[56].vxal" 1;
	setAttr -s 8 ".vclr[56].vfcl";
	setAttr ".vclr[56].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[48].vfal" 1;
	setAttr ".vclr[56].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[49].vfal" 1;
	setAttr ".vclr[56].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[50].vfal" 1;
	setAttr ".vclr[56].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[51].vfal" 1;
	setAttr ".vclr[56].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[52].vfal" 1;
	setAttr ".vclr[56].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[53].vfal" 1;
	setAttr ".vclr[56].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[54].vfal" 1;
	setAttr ".vclr[56].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[55].vfal" 1;
	setAttr ".vclr[57].vxal" 1;
	setAttr -s 8 ".vclr[57].vfcl";
	setAttr ".vclr[57].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[56].vfal" 1;
	setAttr ".vclr[57].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[57].vfal" 1;
	setAttr ".vclr[57].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[58].vfal" 1;
	setAttr ".vclr[57].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[59].vfal" 1;
	setAttr ".vclr[57].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[60].vfal" 1;
	setAttr ".vclr[57].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[61].vfal" 1;
	setAttr ".vclr[57].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[62].vfal" 1;
	setAttr ".vclr[57].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[63].vfal" 1;
	setAttr ".cn" -type "string" "colorSet1";
	setAttr ".clam" no;
createNode polySphere -n "polySphere3";
	rename -uid "C9561FF7-4E6E-110F-446F-1B988FCF3E8F";
	setAttr ".r" 0.15;
	setAttr ".sa" 8;
	setAttr ".sh" 8;
createNode polyColorPerVertex -n "polyColorPerVertex15";
	rename -uid "E7AE75BC-4851-0E75-8BE1-3CB3AD28FE14";
	setAttr ".uopa" yes;
	setAttr -s 58 ".vclr";
	setAttr ".vclr[0].vxal" 1;
	setAttr -s 4 ".vclr[0].vfcl";
	setAttr ".vclr[0].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[0].vfal" 1;
	setAttr ".vclr[0].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[7].vfal" 1;
	setAttr ".vclr[0].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[48].vfal" 1;
	setAttr ".vclr[0].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[55].vfal" 1;
	setAttr ".vclr[1].vxal" 1;
	setAttr -s 4 ".vclr[1].vfcl";
	setAttr ".vclr[1].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[0].vfal" 1;
	setAttr ".vclr[1].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[1].vfal" 1;
	setAttr ".vclr[1].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[48].vfal" 1;
	setAttr ".vclr[1].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vxal" 1;
	setAttr -s 4 ".vclr[2].vfcl";
	setAttr ".vclr[2].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[1].vfal" 1;
	setAttr ".vclr[2].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[2].vfal" 1;
	setAttr ".vclr[2].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vxal" 1;
	setAttr -s 4 ".vclr[3].vfcl";
	setAttr ".vclr[3].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[2].vfal" 1;
	setAttr ".vclr[3].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[3].vfal" 1;
	setAttr ".vclr[3].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vxal" 1;
	setAttr -s 4 ".vclr[4].vfcl";
	setAttr ".vclr[4].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[3].vfal" 1;
	setAttr ".vclr[4].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[4].vfal" 1;
	setAttr ".vclr[4].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vxal" 1;
	setAttr -s 4 ".vclr[5].vfcl";
	setAttr ".vclr[5].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[4].vfal" 1;
	setAttr ".vclr[5].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[5].vfal" 1;
	setAttr ".vclr[5].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vxal" 1;
	setAttr -s 4 ".vclr[6].vfcl";
	setAttr ".vclr[6].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[5].vfal" 1;
	setAttr ".vclr[6].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[6].vfal" 1;
	setAttr ".vclr[6].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vxal" 1;
	setAttr -s 4 ".vclr[7].vfcl";
	setAttr ".vclr[7].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[6].vfal" 1;
	setAttr ".vclr[7].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[7].vfal" 1;
	setAttr ".vclr[7].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[55].vfal" 1;
	setAttr ".vclr[8].vxal" 1;
	setAttr -s 4 ".vclr[8].vfcl";
	setAttr ".vclr[8].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[0].vfal" 1;
	setAttr ".vclr[8].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[7].vfal" 1;
	setAttr ".vclr[8].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[8].vfal" 1;
	setAttr ".vclr[8].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[15].vfal" 1;
	setAttr ".vclr[9].vxal" 1;
	setAttr -s 4 ".vclr[9].vfcl";
	setAttr ".vclr[9].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[0].vfal" 1;
	setAttr ".vclr[9].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[1].vfal" 1;
	setAttr ".vclr[9].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[8].vfal" 1;
	setAttr ".vclr[9].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vxal" 1;
	setAttr -s 4 ".vclr[10].vfcl";
	setAttr ".vclr[10].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[1].vfal" 1;
	setAttr ".vclr[10].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[2].vfal" 1;
	setAttr ".vclr[10].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vxal" 1;
	setAttr -s 4 ".vclr[11].vfcl";
	setAttr ".vclr[11].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[2].vfal" 1;
	setAttr ".vclr[11].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[3].vfal" 1;
	setAttr ".vclr[11].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vxal" 1;
	setAttr -s 4 ".vclr[12].vfcl";
	setAttr ".vclr[12].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[3].vfal" 1;
	setAttr ".vclr[12].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[4].vfal" 1;
	setAttr ".vclr[12].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vxal" 1;
	setAttr -s 4 ".vclr[13].vfcl";
	setAttr ".vclr[13].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[4].vfal" 1;
	setAttr ".vclr[13].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[5].vfal" 1;
	setAttr ".vclr[13].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vxal" 1;
	setAttr -s 4 ".vclr[14].vfcl";
	setAttr ".vclr[14].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[5].vfal" 1;
	setAttr ".vclr[14].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[6].vfal" 1;
	setAttr ".vclr[14].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vxal" 1;
	setAttr -s 4 ".vclr[15].vfcl";
	setAttr ".vclr[15].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[6].vfal" 1;
	setAttr ".vclr[15].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[7].vfal" 1;
	setAttr ".vclr[15].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vxal" 1;
	setAttr -s 4 ".vclr[16].vfcl";
	setAttr ".vclr[16].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[8].vfal" 1;
	setAttr ".vclr[16].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[16].vfal" 1;
	setAttr ".vclr[16].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[23].vfal" 1;
	setAttr ".vclr[17].vxal" 1;
	setAttr -s 4 ".vclr[17].vfcl";
	setAttr ".vclr[17].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[8].vfal" 1;
	setAttr ".vclr[17].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[9].vfal" 1;
	setAttr ".vclr[17].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[16].vfal" 1;
	setAttr ".vclr[17].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vxal" 1;
	setAttr -s 4 ".vclr[18].vfcl";
	setAttr ".vclr[18].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[9].vfal" 1;
	setAttr ".vclr[18].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[10].vfal" 1;
	setAttr ".vclr[18].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vxal" 1;
	setAttr -s 4 ".vclr[19].vfcl";
	setAttr ".vclr[19].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[10].vfal" 1;
	setAttr ".vclr[19].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[11].vfal" 1;
	setAttr ".vclr[19].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vxal" 1;
	setAttr -s 4 ".vclr[20].vfcl";
	setAttr ".vclr[20].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[11].vfal" 1;
	setAttr ".vclr[20].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[12].vfal" 1;
	setAttr ".vclr[20].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vxal" 1;
	setAttr -s 4 ".vclr[21].vfcl";
	setAttr ".vclr[21].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[12].vfal" 1;
	setAttr ".vclr[21].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[13].vfal" 1;
	setAttr ".vclr[21].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vxal" 1;
	setAttr -s 4 ".vclr[22].vfcl";
	setAttr ".vclr[22].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[13].vfal" 1;
	setAttr ".vclr[22].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[14].vfal" 1;
	setAttr ".vclr[22].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vxal" 1;
	setAttr -s 4 ".vclr[23].vfcl";
	setAttr ".vclr[23].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[14].vfal" 1;
	setAttr ".vclr[23].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[15].vfal" 1;
	setAttr ".vclr[23].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vxal" 1;
	setAttr -s 4 ".vclr[24].vfcl";
	setAttr ".vclr[24].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[16].vfal" 1;
	setAttr ".vclr[24].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[24].vfal" 1;
	setAttr ".vclr[24].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[31].vfal" 1;
	setAttr ".vclr[25].vxal" 1;
	setAttr -s 4 ".vclr[25].vfcl";
	setAttr ".vclr[25].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[16].vfal" 1;
	setAttr ".vclr[25].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[17].vfal" 1;
	setAttr ".vclr[25].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[24].vfal" 1;
	setAttr ".vclr[25].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vxal" 1;
	setAttr -s 4 ".vclr[26].vfcl";
	setAttr ".vclr[26].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[17].vfal" 1;
	setAttr ".vclr[26].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[18].vfal" 1;
	setAttr ".vclr[26].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vxal" 1;
	setAttr -s 4 ".vclr[27].vfcl";
	setAttr ".vclr[27].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[18].vfal" 1;
	setAttr ".vclr[27].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[19].vfal" 1;
	setAttr ".vclr[27].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vxal" 1;
	setAttr -s 4 ".vclr[28].vfcl";
	setAttr ".vclr[28].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[19].vfal" 1;
	setAttr ".vclr[28].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[20].vfal" 1;
	setAttr ".vclr[28].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vxal" 1;
	setAttr -s 4 ".vclr[29].vfcl";
	setAttr ".vclr[29].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[20].vfal" 1;
	setAttr ".vclr[29].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[21].vfal" 1;
	setAttr ".vclr[29].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vxal" 1;
	setAttr -s 4 ".vclr[30].vfcl";
	setAttr ".vclr[30].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[21].vfal" 1;
	setAttr ".vclr[30].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[22].vfal" 1;
	setAttr ".vclr[30].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vxal" 1;
	setAttr -s 4 ".vclr[31].vfcl";
	setAttr ".vclr[31].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[22].vfal" 1;
	setAttr ".vclr[31].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[23].vfal" 1;
	setAttr ".vclr[31].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vxal" 1;
	setAttr -s 4 ".vclr[32].vfcl";
	setAttr ".vclr[32].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[24].vfal" 1;
	setAttr ".vclr[32].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[32].vfal" 1;
	setAttr ".vclr[32].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[39].vfal" 1;
	setAttr ".vclr[33].vxal" 1;
	setAttr -s 4 ".vclr[33].vfcl";
	setAttr ".vclr[33].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[24].vfal" 1;
	setAttr ".vclr[33].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[25].vfal" 1;
	setAttr ".vclr[33].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[32].vfal" 1;
	setAttr ".vclr[33].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vxal" 1;
	setAttr -s 4 ".vclr[34].vfcl";
	setAttr ".vclr[34].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[25].vfal" 1;
	setAttr ".vclr[34].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[26].vfal" 1;
	setAttr ".vclr[34].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vxal" 1;
	setAttr -s 4 ".vclr[35].vfcl";
	setAttr ".vclr[35].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[26].vfal" 1;
	setAttr ".vclr[35].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[27].vfal" 1;
	setAttr ".vclr[35].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vxal" 1;
	setAttr -s 4 ".vclr[36].vfcl";
	setAttr ".vclr[36].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[27].vfal" 1;
	setAttr ".vclr[36].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[28].vfal" 1;
	setAttr ".vclr[36].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vxal" 1;
	setAttr -s 4 ".vclr[37].vfcl";
	setAttr ".vclr[37].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[28].vfal" 1;
	setAttr ".vclr[37].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[29].vfal" 1;
	setAttr ".vclr[37].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vxal" 1;
	setAttr -s 4 ".vclr[38].vfcl";
	setAttr ".vclr[38].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[29].vfal" 1;
	setAttr ".vclr[38].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[30].vfal" 1;
	setAttr ".vclr[38].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vxal" 1;
	setAttr -s 4 ".vclr[39].vfcl";
	setAttr ".vclr[39].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[30].vfal" 1;
	setAttr ".vclr[39].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[31].vfal" 1;
	setAttr ".vclr[39].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vxal" 1;
	setAttr -s 4 ".vclr[40].vfcl";
	setAttr ".vclr[40].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[32].vfal" 1;
	setAttr ".vclr[40].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[40].vfal" 1;
	setAttr ".vclr[40].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[47].vfal" 1;
	setAttr ".vclr[41].vxal" 1;
	setAttr -s 4 ".vclr[41].vfcl";
	setAttr ".vclr[41].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[32].vfal" 1;
	setAttr ".vclr[41].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[33].vfal" 1;
	setAttr ".vclr[41].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[40].vfal" 1;
	setAttr ".vclr[41].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vxal" 1;
	setAttr -s 4 ".vclr[42].vfcl";
	setAttr ".vclr[42].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[33].vfal" 1;
	setAttr ".vclr[42].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[34].vfal" 1;
	setAttr ".vclr[42].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vxal" 1;
	setAttr -s 4 ".vclr[43].vfcl";
	setAttr ".vclr[43].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[34].vfal" 1;
	setAttr ".vclr[43].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[35].vfal" 1;
	setAttr ".vclr[43].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vxal" 1;
	setAttr -s 4 ".vclr[44].vfcl";
	setAttr ".vclr[44].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[35].vfal" 1;
	setAttr ".vclr[44].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[36].vfal" 1;
	setAttr ".vclr[44].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vxal" 1;
	setAttr -s 4 ".vclr[45].vfcl";
	setAttr ".vclr[45].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[36].vfal" 1;
	setAttr ".vclr[45].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[37].vfal" 1;
	setAttr ".vclr[45].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vxal" 1;
	setAttr -s 4 ".vclr[46].vfcl";
	setAttr ".vclr[46].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[37].vfal" 1;
	setAttr ".vclr[46].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[38].vfal" 1;
	setAttr ".vclr[46].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vxal" 1;
	setAttr -s 4 ".vclr[47].vfcl";
	setAttr ".vclr[47].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[38].vfal" 1;
	setAttr ".vclr[47].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[39].vfal" 1;
	setAttr ".vclr[47].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vxal" 1;
	setAttr -s 4 ".vclr[48].vfcl";
	setAttr ".vclr[48].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[40].vfal" 1;
	setAttr ".vclr[48].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[56].vfal" 1;
	setAttr ".vclr[48].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[63].vfal" 1;
	setAttr ".vclr[49].vxal" 1;
	setAttr -s 4 ".vclr[49].vfcl";
	setAttr ".vclr[49].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[40].vfal" 1;
	setAttr ".vclr[49].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[41].vfal" 1;
	setAttr ".vclr[49].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[56].vfal" 1;
	setAttr ".vclr[49].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vxal" 1;
	setAttr -s 4 ".vclr[50].vfcl";
	setAttr ".vclr[50].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[41].vfal" 1;
	setAttr ".vclr[50].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[42].vfal" 1;
	setAttr ".vclr[50].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vxal" 1;
	setAttr -s 4 ".vclr[51].vfcl";
	setAttr ".vclr[51].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[42].vfal" 1;
	setAttr ".vclr[51].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[43].vfal" 1;
	setAttr ".vclr[51].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vxal" 1;
	setAttr -s 4 ".vclr[52].vfcl";
	setAttr ".vclr[52].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[43].vfal" 1;
	setAttr ".vclr[52].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[44].vfal" 1;
	setAttr ".vclr[52].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vxal" 1;
	setAttr -s 4 ".vclr[53].vfcl";
	setAttr ".vclr[53].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[44].vfal" 1;
	setAttr ".vclr[53].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[45].vfal" 1;
	setAttr ".vclr[53].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vxal" 1;
	setAttr -s 4 ".vclr[54].vfcl";
	setAttr ".vclr[54].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[45].vfal" 1;
	setAttr ".vclr[54].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[46].vfal" 1;
	setAttr ".vclr[54].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vxal" 1;
	setAttr -s 4 ".vclr[55].vfcl";
	setAttr ".vclr[55].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[46].vfal" 1;
	setAttr ".vclr[55].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[47].vfal" 1;
	setAttr ".vclr[55].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[63].vfal" 1;
	setAttr ".vclr[56].vxal" 1;
	setAttr -s 8 ".vclr[56].vfcl";
	setAttr ".vclr[56].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[48].vfal" 1;
	setAttr ".vclr[56].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[49].vfal" 1;
	setAttr ".vclr[56].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[50].vfal" 1;
	setAttr ".vclr[56].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[51].vfal" 1;
	setAttr ".vclr[56].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[52].vfal" 1;
	setAttr ".vclr[56].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[53].vfal" 1;
	setAttr ".vclr[56].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[54].vfal" 1;
	setAttr ".vclr[56].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[55].vfal" 1;
	setAttr ".vclr[57].vxal" 1;
	setAttr -s 8 ".vclr[57].vfcl";
	setAttr ".vclr[57].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[56].vfal" 1;
	setAttr ".vclr[57].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[57].vfal" 1;
	setAttr ".vclr[57].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[58].vfal" 1;
	setAttr ".vclr[57].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[59].vfal" 1;
	setAttr ".vclr[57].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[60].vfal" 1;
	setAttr ".vclr[57].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[61].vfal" 1;
	setAttr ".vclr[57].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[62].vfal" 1;
	setAttr ".vclr[57].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[63].vfal" 1;
	setAttr ".cn" -type "string" "colorSet1";
	setAttr ".clam" no;
createNode polySphere -n "polySphere15";
	rename -uid "9032E1FD-4BBC-9277-18EF-E795DBF55F76";
	setAttr ".r" 0.15;
	setAttr ".sa" 8;
	setAttr ".sh" 8;
createNode polyColorPerVertex -n "polyColorPerVertex6";
	rename -uid "A60F9556-4B75-2539-63B4-F79632E3D1A5";
	setAttr ".uopa" yes;
	setAttr -s 58 ".vclr";
	setAttr ".vclr[0].vxal" 1;
	setAttr -s 4 ".vclr[0].vfcl";
	setAttr ".vclr[0].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[0].vfal" 1;
	setAttr ".vclr[0].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[7].vfal" 1;
	setAttr ".vclr[0].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[48].vfal" 1;
	setAttr ".vclr[0].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[55].vfal" 1;
	setAttr ".vclr[1].vxal" 1;
	setAttr -s 4 ".vclr[1].vfcl";
	setAttr ".vclr[1].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[0].vfal" 1;
	setAttr ".vclr[1].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[1].vfal" 1;
	setAttr ".vclr[1].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[48].vfal" 1;
	setAttr ".vclr[1].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vxal" 1;
	setAttr -s 4 ".vclr[2].vfcl";
	setAttr ".vclr[2].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[1].vfal" 1;
	setAttr ".vclr[2].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[2].vfal" 1;
	setAttr ".vclr[2].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vxal" 1;
	setAttr -s 4 ".vclr[3].vfcl";
	setAttr ".vclr[3].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[2].vfal" 1;
	setAttr ".vclr[3].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[3].vfal" 1;
	setAttr ".vclr[3].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vxal" 1;
	setAttr -s 4 ".vclr[4].vfcl";
	setAttr ".vclr[4].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[3].vfal" 1;
	setAttr ".vclr[4].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[4].vfal" 1;
	setAttr ".vclr[4].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vxal" 1;
	setAttr -s 4 ".vclr[5].vfcl";
	setAttr ".vclr[5].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[4].vfal" 1;
	setAttr ".vclr[5].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[5].vfal" 1;
	setAttr ".vclr[5].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vxal" 1;
	setAttr -s 4 ".vclr[6].vfcl";
	setAttr ".vclr[6].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[5].vfal" 1;
	setAttr ".vclr[6].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[6].vfal" 1;
	setAttr ".vclr[6].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vxal" 1;
	setAttr -s 4 ".vclr[7].vfcl";
	setAttr ".vclr[7].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[6].vfal" 1;
	setAttr ".vclr[7].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[7].vfal" 1;
	setAttr ".vclr[7].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[55].vfal" 1;
	setAttr ".vclr[8].vxal" 1;
	setAttr -s 4 ".vclr[8].vfcl";
	setAttr ".vclr[8].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[0].vfal" 1;
	setAttr ".vclr[8].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[7].vfal" 1;
	setAttr ".vclr[8].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[8].vfal" 1;
	setAttr ".vclr[8].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[15].vfal" 1;
	setAttr ".vclr[9].vxal" 1;
	setAttr -s 4 ".vclr[9].vfcl";
	setAttr ".vclr[9].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[0].vfal" 1;
	setAttr ".vclr[9].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[1].vfal" 1;
	setAttr ".vclr[9].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[8].vfal" 1;
	setAttr ".vclr[9].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vxal" 1;
	setAttr -s 4 ".vclr[10].vfcl";
	setAttr ".vclr[10].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[1].vfal" 1;
	setAttr ".vclr[10].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[2].vfal" 1;
	setAttr ".vclr[10].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vxal" 1;
	setAttr -s 4 ".vclr[11].vfcl";
	setAttr ".vclr[11].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[2].vfal" 1;
	setAttr ".vclr[11].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[3].vfal" 1;
	setAttr ".vclr[11].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vxal" 1;
	setAttr -s 4 ".vclr[12].vfcl";
	setAttr ".vclr[12].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[3].vfal" 1;
	setAttr ".vclr[12].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[4].vfal" 1;
	setAttr ".vclr[12].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vxal" 1;
	setAttr -s 4 ".vclr[13].vfcl";
	setAttr ".vclr[13].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[4].vfal" 1;
	setAttr ".vclr[13].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[5].vfal" 1;
	setAttr ".vclr[13].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vxal" 1;
	setAttr -s 4 ".vclr[14].vfcl";
	setAttr ".vclr[14].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[5].vfal" 1;
	setAttr ".vclr[14].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[6].vfal" 1;
	setAttr ".vclr[14].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vxal" 1;
	setAttr -s 4 ".vclr[15].vfcl";
	setAttr ".vclr[15].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[6].vfal" 1;
	setAttr ".vclr[15].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[7].vfal" 1;
	setAttr ".vclr[15].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vxal" 1;
	setAttr -s 4 ".vclr[16].vfcl";
	setAttr ".vclr[16].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[8].vfal" 1;
	setAttr ".vclr[16].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[16].vfal" 1;
	setAttr ".vclr[16].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[23].vfal" 1;
	setAttr ".vclr[17].vxal" 1;
	setAttr -s 4 ".vclr[17].vfcl";
	setAttr ".vclr[17].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[8].vfal" 1;
	setAttr ".vclr[17].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[9].vfal" 1;
	setAttr ".vclr[17].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[16].vfal" 1;
	setAttr ".vclr[17].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vxal" 1;
	setAttr -s 4 ".vclr[18].vfcl";
	setAttr ".vclr[18].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[9].vfal" 1;
	setAttr ".vclr[18].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[10].vfal" 1;
	setAttr ".vclr[18].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vxal" 1;
	setAttr -s 4 ".vclr[19].vfcl";
	setAttr ".vclr[19].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[10].vfal" 1;
	setAttr ".vclr[19].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[11].vfal" 1;
	setAttr ".vclr[19].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vxal" 1;
	setAttr -s 4 ".vclr[20].vfcl";
	setAttr ".vclr[20].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[11].vfal" 1;
	setAttr ".vclr[20].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[12].vfal" 1;
	setAttr ".vclr[20].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vxal" 1;
	setAttr -s 4 ".vclr[21].vfcl";
	setAttr ".vclr[21].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[12].vfal" 1;
	setAttr ".vclr[21].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[13].vfal" 1;
	setAttr ".vclr[21].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vxal" 1;
	setAttr -s 4 ".vclr[22].vfcl";
	setAttr ".vclr[22].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[13].vfal" 1;
	setAttr ".vclr[22].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[14].vfal" 1;
	setAttr ".vclr[22].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vxal" 1;
	setAttr -s 4 ".vclr[23].vfcl";
	setAttr ".vclr[23].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[14].vfal" 1;
	setAttr ".vclr[23].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[15].vfal" 1;
	setAttr ".vclr[23].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vxal" 1;
	setAttr -s 4 ".vclr[24].vfcl";
	setAttr ".vclr[24].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[16].vfal" 1;
	setAttr ".vclr[24].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[24].vfal" 1;
	setAttr ".vclr[24].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[31].vfal" 1;
	setAttr ".vclr[25].vxal" 1;
	setAttr -s 4 ".vclr[25].vfcl";
	setAttr ".vclr[25].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[16].vfal" 1;
	setAttr ".vclr[25].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[17].vfal" 1;
	setAttr ".vclr[25].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[24].vfal" 1;
	setAttr ".vclr[25].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vxal" 1;
	setAttr -s 4 ".vclr[26].vfcl";
	setAttr ".vclr[26].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[17].vfal" 1;
	setAttr ".vclr[26].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[18].vfal" 1;
	setAttr ".vclr[26].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vxal" 1;
	setAttr -s 4 ".vclr[27].vfcl";
	setAttr ".vclr[27].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[18].vfal" 1;
	setAttr ".vclr[27].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[19].vfal" 1;
	setAttr ".vclr[27].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vxal" 1;
	setAttr -s 4 ".vclr[28].vfcl";
	setAttr ".vclr[28].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[19].vfal" 1;
	setAttr ".vclr[28].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[20].vfal" 1;
	setAttr ".vclr[28].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vxal" 1;
	setAttr -s 4 ".vclr[29].vfcl";
	setAttr ".vclr[29].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[20].vfal" 1;
	setAttr ".vclr[29].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[21].vfal" 1;
	setAttr ".vclr[29].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vxal" 1;
	setAttr -s 4 ".vclr[30].vfcl";
	setAttr ".vclr[30].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[21].vfal" 1;
	setAttr ".vclr[30].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[22].vfal" 1;
	setAttr ".vclr[30].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vxal" 1;
	setAttr -s 4 ".vclr[31].vfcl";
	setAttr ".vclr[31].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[22].vfal" 1;
	setAttr ".vclr[31].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[23].vfal" 1;
	setAttr ".vclr[31].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vxal" 1;
	setAttr -s 4 ".vclr[32].vfcl";
	setAttr ".vclr[32].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[24].vfal" 1;
	setAttr ".vclr[32].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[32].vfal" 1;
	setAttr ".vclr[32].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[39].vfal" 1;
	setAttr ".vclr[33].vxal" 1;
	setAttr -s 4 ".vclr[33].vfcl";
	setAttr ".vclr[33].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[24].vfal" 1;
	setAttr ".vclr[33].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[25].vfal" 1;
	setAttr ".vclr[33].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[32].vfal" 1;
	setAttr ".vclr[33].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vxal" 1;
	setAttr -s 4 ".vclr[34].vfcl";
	setAttr ".vclr[34].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[25].vfal" 1;
	setAttr ".vclr[34].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[26].vfal" 1;
	setAttr ".vclr[34].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vxal" 1;
	setAttr -s 4 ".vclr[35].vfcl";
	setAttr ".vclr[35].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[26].vfal" 1;
	setAttr ".vclr[35].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[27].vfal" 1;
	setAttr ".vclr[35].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vxal" 1;
	setAttr -s 4 ".vclr[36].vfcl";
	setAttr ".vclr[36].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[27].vfal" 1;
	setAttr ".vclr[36].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[28].vfal" 1;
	setAttr ".vclr[36].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vxal" 1;
	setAttr -s 4 ".vclr[37].vfcl";
	setAttr ".vclr[37].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[28].vfal" 1;
	setAttr ".vclr[37].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[29].vfal" 1;
	setAttr ".vclr[37].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vxal" 1;
	setAttr -s 4 ".vclr[38].vfcl";
	setAttr ".vclr[38].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[29].vfal" 1;
	setAttr ".vclr[38].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[30].vfal" 1;
	setAttr ".vclr[38].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vxal" 1;
	setAttr -s 4 ".vclr[39].vfcl";
	setAttr ".vclr[39].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[30].vfal" 1;
	setAttr ".vclr[39].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[31].vfal" 1;
	setAttr ".vclr[39].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vxal" 1;
	setAttr -s 4 ".vclr[40].vfcl";
	setAttr ".vclr[40].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[32].vfal" 1;
	setAttr ".vclr[40].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[40].vfal" 1;
	setAttr ".vclr[40].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[47].vfal" 1;
	setAttr ".vclr[41].vxal" 1;
	setAttr -s 4 ".vclr[41].vfcl";
	setAttr ".vclr[41].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[32].vfal" 1;
	setAttr ".vclr[41].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[33].vfal" 1;
	setAttr ".vclr[41].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[40].vfal" 1;
	setAttr ".vclr[41].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vxal" 1;
	setAttr -s 4 ".vclr[42].vfcl";
	setAttr ".vclr[42].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[33].vfal" 1;
	setAttr ".vclr[42].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[34].vfal" 1;
	setAttr ".vclr[42].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vxal" 1;
	setAttr -s 4 ".vclr[43].vfcl";
	setAttr ".vclr[43].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[34].vfal" 1;
	setAttr ".vclr[43].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[35].vfal" 1;
	setAttr ".vclr[43].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vxal" 1;
	setAttr -s 4 ".vclr[44].vfcl";
	setAttr ".vclr[44].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[35].vfal" 1;
	setAttr ".vclr[44].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[36].vfal" 1;
	setAttr ".vclr[44].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vxal" 1;
	setAttr -s 4 ".vclr[45].vfcl";
	setAttr ".vclr[45].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[36].vfal" 1;
	setAttr ".vclr[45].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[37].vfal" 1;
	setAttr ".vclr[45].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vxal" 1;
	setAttr -s 4 ".vclr[46].vfcl";
	setAttr ".vclr[46].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[37].vfal" 1;
	setAttr ".vclr[46].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[38].vfal" 1;
	setAttr ".vclr[46].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vxal" 1;
	setAttr -s 4 ".vclr[47].vfcl";
	setAttr ".vclr[47].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[38].vfal" 1;
	setAttr ".vclr[47].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[39].vfal" 1;
	setAttr ".vclr[47].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vxal" 1;
	setAttr -s 4 ".vclr[48].vfcl";
	setAttr ".vclr[48].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[40].vfal" 1;
	setAttr ".vclr[48].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[56].vfal" 1;
	setAttr ".vclr[48].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[63].vfal" 1;
	setAttr ".vclr[49].vxal" 1;
	setAttr -s 4 ".vclr[49].vfcl";
	setAttr ".vclr[49].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[40].vfal" 1;
	setAttr ".vclr[49].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[41].vfal" 1;
	setAttr ".vclr[49].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[56].vfal" 1;
	setAttr ".vclr[49].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vxal" 1;
	setAttr -s 4 ".vclr[50].vfcl";
	setAttr ".vclr[50].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[41].vfal" 1;
	setAttr ".vclr[50].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[42].vfal" 1;
	setAttr ".vclr[50].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vxal" 1;
	setAttr -s 4 ".vclr[51].vfcl";
	setAttr ".vclr[51].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[42].vfal" 1;
	setAttr ".vclr[51].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[43].vfal" 1;
	setAttr ".vclr[51].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vxal" 1;
	setAttr -s 4 ".vclr[52].vfcl";
	setAttr ".vclr[52].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[43].vfal" 1;
	setAttr ".vclr[52].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[44].vfal" 1;
	setAttr ".vclr[52].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vxal" 1;
	setAttr -s 4 ".vclr[53].vfcl";
	setAttr ".vclr[53].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[44].vfal" 1;
	setAttr ".vclr[53].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[45].vfal" 1;
	setAttr ".vclr[53].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vxal" 1;
	setAttr -s 4 ".vclr[54].vfcl";
	setAttr ".vclr[54].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[45].vfal" 1;
	setAttr ".vclr[54].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[46].vfal" 1;
	setAttr ".vclr[54].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vxal" 1;
	setAttr -s 4 ".vclr[55].vfcl";
	setAttr ".vclr[55].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[46].vfal" 1;
	setAttr ".vclr[55].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[47].vfal" 1;
	setAttr ".vclr[55].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[63].vfal" 1;
	setAttr ".vclr[56].vxal" 1;
	setAttr -s 8 ".vclr[56].vfcl";
	setAttr ".vclr[56].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[48].vfal" 1;
	setAttr ".vclr[56].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[49].vfal" 1;
	setAttr ".vclr[56].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[50].vfal" 1;
	setAttr ".vclr[56].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[51].vfal" 1;
	setAttr ".vclr[56].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[52].vfal" 1;
	setAttr ".vclr[56].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[53].vfal" 1;
	setAttr ".vclr[56].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[54].vfal" 1;
	setAttr ".vclr[56].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[55].vfal" 1;
	setAttr ".vclr[57].vxal" 1;
	setAttr -s 8 ".vclr[57].vfcl";
	setAttr ".vclr[57].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[56].vfal" 1;
	setAttr ".vclr[57].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[57].vfal" 1;
	setAttr ".vclr[57].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[58].vfal" 1;
	setAttr ".vclr[57].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[59].vfal" 1;
	setAttr ".vclr[57].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[60].vfal" 1;
	setAttr ".vclr[57].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[61].vfal" 1;
	setAttr ".vclr[57].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[62].vfal" 1;
	setAttr ".vclr[57].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[63].vfal" 1;
	setAttr ".cn" -type "string" "colorSet1";
	setAttr ".clam" no;
createNode polySphere -n "polySphere6";
	rename -uid "E509441A-4F1A-864D-905F-BCBF676C094B";
	setAttr ".r" 0.15;
	setAttr ".sa" 8;
	setAttr ".sh" 8;
createNode polyColorPerVertex -n "polyColorPerVertex10";
	rename -uid "DAFAD825-4C66-A06F-F91F-028262F707B5";
	setAttr ".uopa" yes;
	setAttr -s 58 ".vclr";
	setAttr ".vclr[0].vxal" 1;
	setAttr -s 4 ".vclr[0].vfcl";
	setAttr ".vclr[0].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[0].vfal" 1;
	setAttr ".vclr[0].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[7].vfal" 1;
	setAttr ".vclr[0].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[48].vfal" 1;
	setAttr ".vclr[0].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[0].vfcl[55].vfal" 1;
	setAttr ".vclr[1].vxal" 1;
	setAttr -s 4 ".vclr[1].vfcl";
	setAttr ".vclr[1].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[0].vfal" 1;
	setAttr ".vclr[1].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[1].vfal" 1;
	setAttr ".vclr[1].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[48].vfal" 1;
	setAttr ".vclr[1].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[1].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vxal" 1;
	setAttr -s 4 ".vclr[2].vfcl";
	setAttr ".vclr[2].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[1].vfal" 1;
	setAttr ".vclr[2].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[2].vfal" 1;
	setAttr ".vclr[2].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[49].vfal" 1;
	setAttr ".vclr[2].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[2].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vxal" 1;
	setAttr -s 4 ".vclr[3].vfcl";
	setAttr ".vclr[3].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[2].vfal" 1;
	setAttr ".vclr[3].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[3].vfal" 1;
	setAttr ".vclr[3].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[50].vfal" 1;
	setAttr ".vclr[3].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[3].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vxal" 1;
	setAttr -s 4 ".vclr[4].vfcl";
	setAttr ".vclr[4].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[3].vfal" 1;
	setAttr ".vclr[4].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[4].vfal" 1;
	setAttr ".vclr[4].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[51].vfal" 1;
	setAttr ".vclr[4].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[4].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vxal" 1;
	setAttr -s 4 ".vclr[5].vfcl";
	setAttr ".vclr[5].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[4].vfal" 1;
	setAttr ".vclr[5].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[5].vfal" 1;
	setAttr ".vclr[5].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[52].vfal" 1;
	setAttr ".vclr[5].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[5].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vxal" 1;
	setAttr -s 4 ".vclr[6].vfcl";
	setAttr ".vclr[6].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[5].vfal" 1;
	setAttr ".vclr[6].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[6].vfal" 1;
	setAttr ".vclr[6].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[53].vfal" 1;
	setAttr ".vclr[6].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[6].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vxal" 1;
	setAttr -s 4 ".vclr[7].vfcl";
	setAttr ".vclr[7].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[6].vfal" 1;
	setAttr ".vclr[7].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[7].vfal" 1;
	setAttr ".vclr[7].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[54].vfal" 1;
	setAttr ".vclr[7].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[7].vfcl[55].vfal" 1;
	setAttr ".vclr[8].vxal" 1;
	setAttr -s 4 ".vclr[8].vfcl";
	setAttr ".vclr[8].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[0].vfal" 1;
	setAttr ".vclr[8].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[7].vfal" 1;
	setAttr ".vclr[8].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[8].vfal" 1;
	setAttr ".vclr[8].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[8].vfcl[15].vfal" 1;
	setAttr ".vclr[9].vxal" 1;
	setAttr -s 4 ".vclr[9].vfcl";
	setAttr ".vclr[9].vfcl[0].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[0].vfal" 1;
	setAttr ".vclr[9].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[1].vfal" 1;
	setAttr ".vclr[9].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[8].vfal" 1;
	setAttr ".vclr[9].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[9].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vxal" 1;
	setAttr -s 4 ".vclr[10].vfcl";
	setAttr ".vclr[10].vfcl[1].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[1].vfal" 1;
	setAttr ".vclr[10].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[2].vfal" 1;
	setAttr ".vclr[10].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[9].vfal" 1;
	setAttr ".vclr[10].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[10].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vxal" 1;
	setAttr -s 4 ".vclr[11].vfcl";
	setAttr ".vclr[11].vfcl[2].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[2].vfal" 1;
	setAttr ".vclr[11].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[3].vfal" 1;
	setAttr ".vclr[11].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[10].vfal" 1;
	setAttr ".vclr[11].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[11].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vxal" 1;
	setAttr -s 4 ".vclr[12].vfcl";
	setAttr ".vclr[12].vfcl[3].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[3].vfal" 1;
	setAttr ".vclr[12].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[4].vfal" 1;
	setAttr ".vclr[12].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[11].vfal" 1;
	setAttr ".vclr[12].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[12].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vxal" 1;
	setAttr -s 4 ".vclr[13].vfcl";
	setAttr ".vclr[13].vfcl[4].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[4].vfal" 1;
	setAttr ".vclr[13].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[5].vfal" 1;
	setAttr ".vclr[13].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[12].vfal" 1;
	setAttr ".vclr[13].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[13].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vxal" 1;
	setAttr -s 4 ".vclr[14].vfcl";
	setAttr ".vclr[14].vfcl[5].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[5].vfal" 1;
	setAttr ".vclr[14].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[6].vfal" 1;
	setAttr ".vclr[14].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[13].vfal" 1;
	setAttr ".vclr[14].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[14].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vxal" 1;
	setAttr -s 4 ".vclr[15].vfcl";
	setAttr ".vclr[15].vfcl[6].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[6].vfal" 1;
	setAttr ".vclr[15].vfcl[7].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[7].vfal" 1;
	setAttr ".vclr[15].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[14].vfal" 1;
	setAttr ".vclr[15].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[15].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vxal" 1;
	setAttr -s 4 ".vclr[16].vfcl";
	setAttr ".vclr[16].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[8].vfal" 1;
	setAttr ".vclr[16].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[15].vfal" 1;
	setAttr ".vclr[16].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[16].vfal" 1;
	setAttr ".vclr[16].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[16].vfcl[23].vfal" 1;
	setAttr ".vclr[17].vxal" 1;
	setAttr -s 4 ".vclr[17].vfcl";
	setAttr ".vclr[17].vfcl[8].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[8].vfal" 1;
	setAttr ".vclr[17].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[9].vfal" 1;
	setAttr ".vclr[17].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[16].vfal" 1;
	setAttr ".vclr[17].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[17].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vxal" 1;
	setAttr -s 4 ".vclr[18].vfcl";
	setAttr ".vclr[18].vfcl[9].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[9].vfal" 1;
	setAttr ".vclr[18].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[10].vfal" 1;
	setAttr ".vclr[18].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[17].vfal" 1;
	setAttr ".vclr[18].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[18].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vxal" 1;
	setAttr -s 4 ".vclr[19].vfcl";
	setAttr ".vclr[19].vfcl[10].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[10].vfal" 1;
	setAttr ".vclr[19].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[11].vfal" 1;
	setAttr ".vclr[19].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[18].vfal" 1;
	setAttr ".vclr[19].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[19].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vxal" 1;
	setAttr -s 4 ".vclr[20].vfcl";
	setAttr ".vclr[20].vfcl[11].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[11].vfal" 1;
	setAttr ".vclr[20].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[12].vfal" 1;
	setAttr ".vclr[20].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[19].vfal" 1;
	setAttr ".vclr[20].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[20].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vxal" 1;
	setAttr -s 4 ".vclr[21].vfcl";
	setAttr ".vclr[21].vfcl[12].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[12].vfal" 1;
	setAttr ".vclr[21].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[13].vfal" 1;
	setAttr ".vclr[21].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[20].vfal" 1;
	setAttr ".vclr[21].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[21].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vxal" 1;
	setAttr -s 4 ".vclr[22].vfcl";
	setAttr ".vclr[22].vfcl[13].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[13].vfal" 1;
	setAttr ".vclr[22].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[14].vfal" 1;
	setAttr ".vclr[22].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[21].vfal" 1;
	setAttr ".vclr[22].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[22].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vxal" 1;
	setAttr -s 4 ".vclr[23].vfcl";
	setAttr ".vclr[23].vfcl[14].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[14].vfal" 1;
	setAttr ".vclr[23].vfcl[15].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[15].vfal" 1;
	setAttr ".vclr[23].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[22].vfal" 1;
	setAttr ".vclr[23].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[23].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vxal" 1;
	setAttr -s 4 ".vclr[24].vfcl";
	setAttr ".vclr[24].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[16].vfal" 1;
	setAttr ".vclr[24].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[23].vfal" 1;
	setAttr ".vclr[24].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[24].vfal" 1;
	setAttr ".vclr[24].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[24].vfcl[31].vfal" 1;
	setAttr ".vclr[25].vxal" 1;
	setAttr -s 4 ".vclr[25].vfcl";
	setAttr ".vclr[25].vfcl[16].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[16].vfal" 1;
	setAttr ".vclr[25].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[17].vfal" 1;
	setAttr ".vclr[25].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[24].vfal" 1;
	setAttr ".vclr[25].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[25].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vxal" 1;
	setAttr -s 4 ".vclr[26].vfcl";
	setAttr ".vclr[26].vfcl[17].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[17].vfal" 1;
	setAttr ".vclr[26].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[18].vfal" 1;
	setAttr ".vclr[26].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[25].vfal" 1;
	setAttr ".vclr[26].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[26].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vxal" 1;
	setAttr -s 4 ".vclr[27].vfcl";
	setAttr ".vclr[27].vfcl[18].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[18].vfal" 1;
	setAttr ".vclr[27].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[19].vfal" 1;
	setAttr ".vclr[27].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[26].vfal" 1;
	setAttr ".vclr[27].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[27].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vxal" 1;
	setAttr -s 4 ".vclr[28].vfcl";
	setAttr ".vclr[28].vfcl[19].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[19].vfal" 1;
	setAttr ".vclr[28].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[20].vfal" 1;
	setAttr ".vclr[28].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[27].vfal" 1;
	setAttr ".vclr[28].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[28].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vxal" 1;
	setAttr -s 4 ".vclr[29].vfcl";
	setAttr ".vclr[29].vfcl[20].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[20].vfal" 1;
	setAttr ".vclr[29].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[21].vfal" 1;
	setAttr ".vclr[29].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[28].vfal" 1;
	setAttr ".vclr[29].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[29].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vxal" 1;
	setAttr -s 4 ".vclr[30].vfcl";
	setAttr ".vclr[30].vfcl[21].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[21].vfal" 1;
	setAttr ".vclr[30].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[22].vfal" 1;
	setAttr ".vclr[30].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[29].vfal" 1;
	setAttr ".vclr[30].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[30].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vxal" 1;
	setAttr -s 4 ".vclr[31].vfcl";
	setAttr ".vclr[31].vfcl[22].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[22].vfal" 1;
	setAttr ".vclr[31].vfcl[23].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[23].vfal" 1;
	setAttr ".vclr[31].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[30].vfal" 1;
	setAttr ".vclr[31].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[31].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vxal" 1;
	setAttr -s 4 ".vclr[32].vfcl";
	setAttr ".vclr[32].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[24].vfal" 1;
	setAttr ".vclr[32].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[31].vfal" 1;
	setAttr ".vclr[32].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[32].vfal" 1;
	setAttr ".vclr[32].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[32].vfcl[39].vfal" 1;
	setAttr ".vclr[33].vxal" 1;
	setAttr -s 4 ".vclr[33].vfcl";
	setAttr ".vclr[33].vfcl[24].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[24].vfal" 1;
	setAttr ".vclr[33].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[25].vfal" 1;
	setAttr ".vclr[33].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[32].vfal" 1;
	setAttr ".vclr[33].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[33].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vxal" 1;
	setAttr -s 4 ".vclr[34].vfcl";
	setAttr ".vclr[34].vfcl[25].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[25].vfal" 1;
	setAttr ".vclr[34].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[26].vfal" 1;
	setAttr ".vclr[34].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[33].vfal" 1;
	setAttr ".vclr[34].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[34].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vxal" 1;
	setAttr -s 4 ".vclr[35].vfcl";
	setAttr ".vclr[35].vfcl[26].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[26].vfal" 1;
	setAttr ".vclr[35].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[27].vfal" 1;
	setAttr ".vclr[35].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[34].vfal" 1;
	setAttr ".vclr[35].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[35].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vxal" 1;
	setAttr -s 4 ".vclr[36].vfcl";
	setAttr ".vclr[36].vfcl[27].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[27].vfal" 1;
	setAttr ".vclr[36].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[28].vfal" 1;
	setAttr ".vclr[36].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[35].vfal" 1;
	setAttr ".vclr[36].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[36].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vxal" 1;
	setAttr -s 4 ".vclr[37].vfcl";
	setAttr ".vclr[37].vfcl[28].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[28].vfal" 1;
	setAttr ".vclr[37].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[29].vfal" 1;
	setAttr ".vclr[37].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[36].vfal" 1;
	setAttr ".vclr[37].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[37].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vxal" 1;
	setAttr -s 4 ".vclr[38].vfcl";
	setAttr ".vclr[38].vfcl[29].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[29].vfal" 1;
	setAttr ".vclr[38].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[30].vfal" 1;
	setAttr ".vclr[38].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[37].vfal" 1;
	setAttr ".vclr[38].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[38].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vxal" 1;
	setAttr -s 4 ".vclr[39].vfcl";
	setAttr ".vclr[39].vfcl[30].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[30].vfal" 1;
	setAttr ".vclr[39].vfcl[31].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[31].vfal" 1;
	setAttr ".vclr[39].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[38].vfal" 1;
	setAttr ".vclr[39].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[39].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vxal" 1;
	setAttr -s 4 ".vclr[40].vfcl";
	setAttr ".vclr[40].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[32].vfal" 1;
	setAttr ".vclr[40].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[39].vfal" 1;
	setAttr ".vclr[40].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[40].vfal" 1;
	setAttr ".vclr[40].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[40].vfcl[47].vfal" 1;
	setAttr ".vclr[41].vxal" 1;
	setAttr -s 4 ".vclr[41].vfcl";
	setAttr ".vclr[41].vfcl[32].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[32].vfal" 1;
	setAttr ".vclr[41].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[33].vfal" 1;
	setAttr ".vclr[41].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[40].vfal" 1;
	setAttr ".vclr[41].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[41].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vxal" 1;
	setAttr -s 4 ".vclr[42].vfcl";
	setAttr ".vclr[42].vfcl[33].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[33].vfal" 1;
	setAttr ".vclr[42].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[34].vfal" 1;
	setAttr ".vclr[42].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[41].vfal" 1;
	setAttr ".vclr[42].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[42].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vxal" 1;
	setAttr -s 4 ".vclr[43].vfcl";
	setAttr ".vclr[43].vfcl[34].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[34].vfal" 1;
	setAttr ".vclr[43].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[35].vfal" 1;
	setAttr ".vclr[43].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[42].vfal" 1;
	setAttr ".vclr[43].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[43].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vxal" 1;
	setAttr -s 4 ".vclr[44].vfcl";
	setAttr ".vclr[44].vfcl[35].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[35].vfal" 1;
	setAttr ".vclr[44].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[36].vfal" 1;
	setAttr ".vclr[44].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[43].vfal" 1;
	setAttr ".vclr[44].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[44].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vxal" 1;
	setAttr -s 4 ".vclr[45].vfcl";
	setAttr ".vclr[45].vfcl[36].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[36].vfal" 1;
	setAttr ".vclr[45].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[37].vfal" 1;
	setAttr ".vclr[45].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[44].vfal" 1;
	setAttr ".vclr[45].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[45].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vxal" 1;
	setAttr -s 4 ".vclr[46].vfcl";
	setAttr ".vclr[46].vfcl[37].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[37].vfal" 1;
	setAttr ".vclr[46].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[38].vfal" 1;
	setAttr ".vclr[46].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[45].vfal" 1;
	setAttr ".vclr[46].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[46].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vxal" 1;
	setAttr -s 4 ".vclr[47].vfcl";
	setAttr ".vclr[47].vfcl[38].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[38].vfal" 1;
	setAttr ".vclr[47].vfcl[39].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[39].vfal" 1;
	setAttr ".vclr[47].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[46].vfal" 1;
	setAttr ".vclr[47].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[47].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vxal" 1;
	setAttr -s 4 ".vclr[48].vfcl";
	setAttr ".vclr[48].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[40].vfal" 1;
	setAttr ".vclr[48].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[47].vfal" 1;
	setAttr ".vclr[48].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[56].vfal" 1;
	setAttr ".vclr[48].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[48].vfcl[63].vfal" 1;
	setAttr ".vclr[49].vxal" 1;
	setAttr -s 4 ".vclr[49].vfcl";
	setAttr ".vclr[49].vfcl[40].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[40].vfal" 1;
	setAttr ".vclr[49].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[41].vfal" 1;
	setAttr ".vclr[49].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[56].vfal" 1;
	setAttr ".vclr[49].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[49].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vxal" 1;
	setAttr -s 4 ".vclr[50].vfcl";
	setAttr ".vclr[50].vfcl[41].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[41].vfal" 1;
	setAttr ".vclr[50].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[42].vfal" 1;
	setAttr ".vclr[50].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[57].vfal" 1;
	setAttr ".vclr[50].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[50].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vxal" 1;
	setAttr -s 4 ".vclr[51].vfcl";
	setAttr ".vclr[51].vfcl[42].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[42].vfal" 1;
	setAttr ".vclr[51].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[43].vfal" 1;
	setAttr ".vclr[51].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[58].vfal" 1;
	setAttr ".vclr[51].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[51].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vxal" 1;
	setAttr -s 4 ".vclr[52].vfcl";
	setAttr ".vclr[52].vfcl[43].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[43].vfal" 1;
	setAttr ".vclr[52].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[44].vfal" 1;
	setAttr ".vclr[52].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[59].vfal" 1;
	setAttr ".vclr[52].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[52].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vxal" 1;
	setAttr -s 4 ".vclr[53].vfcl";
	setAttr ".vclr[53].vfcl[44].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[44].vfal" 1;
	setAttr ".vclr[53].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[45].vfal" 1;
	setAttr ".vclr[53].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[60].vfal" 1;
	setAttr ".vclr[53].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[53].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vxal" 1;
	setAttr -s 4 ".vclr[54].vfcl";
	setAttr ".vclr[54].vfcl[45].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[45].vfal" 1;
	setAttr ".vclr[54].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[46].vfal" 1;
	setAttr ".vclr[54].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[61].vfal" 1;
	setAttr ".vclr[54].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[54].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vxal" 1;
	setAttr -s 4 ".vclr[55].vfcl";
	setAttr ".vclr[55].vfcl[46].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[46].vfal" 1;
	setAttr ".vclr[55].vfcl[47].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[47].vfal" 1;
	setAttr ".vclr[55].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[62].vfal" 1;
	setAttr ".vclr[55].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[55].vfcl[63].vfal" 1;
	setAttr ".vclr[56].vxal" 1;
	setAttr -s 8 ".vclr[56].vfcl";
	setAttr ".vclr[56].vfcl[48].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[48].vfal" 1;
	setAttr ".vclr[56].vfcl[49].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[49].vfal" 1;
	setAttr ".vclr[56].vfcl[50].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[50].vfal" 1;
	setAttr ".vclr[56].vfcl[51].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[51].vfal" 1;
	setAttr ".vclr[56].vfcl[52].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[52].vfal" 1;
	setAttr ".vclr[56].vfcl[53].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[53].vfal" 1;
	setAttr ".vclr[56].vfcl[54].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[54].vfal" 1;
	setAttr ".vclr[56].vfcl[55].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[56].vfcl[55].vfal" 1;
	setAttr ".vclr[57].vxal" 1;
	setAttr -s 8 ".vclr[57].vfcl";
	setAttr ".vclr[57].vfcl[56].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[56].vfal" 1;
	setAttr ".vclr[57].vfcl[57].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[57].vfal" 1;
	setAttr ".vclr[57].vfcl[58].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[58].vfal" 1;
	setAttr ".vclr[57].vfcl[59].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[59].vfal" 1;
	setAttr ".vclr[57].vfcl[60].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[60].vfal" 1;
	setAttr ".vclr[57].vfcl[61].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[61].vfal" 1;
	setAttr ".vclr[57].vfcl[62].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[62].vfal" 1;
	setAttr ".vclr[57].vfcl[63].frgb" -type "float3" 0 0.252157 0 ;
	setAttr ".vclr[57].vfcl[63].vfal" 1;
	setAttr ".cn" -type "string" "colorSet1";
	setAttr ".clam" no;
createNode polySphere -n "polySphere10";
	rename -uid "A9FB93EB-4DFC-5DA4-B6C7-ADB34566D9A1";
	setAttr ".r" 0.15;
	setAttr ".sa" 8;
	setAttr ".sh" 8;
createNode skinCluster -n "skinCluster1";
	rename -uid "F090E009-441B-77AE-78AC-6681F64485D3";
	setAttr -s 1358 ".wl";
	setAttr ".wl[0:464].w"
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		1 4 1
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		1 4 1
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		2 3 0.75 4 0.25
		2 3 0.75 4 0.25
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 4 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 2 1
		1 2 1
		1 2 1
		1 2 1
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		1 3 1
		1 3 1
		1 3 1
		1 2 1
		1 3 1
		1 3 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		2 6 0.5 7 0.5
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		2 5 0.5 6 0.5
		2 5 0.5 6 0.5
		2 5 0.5 6 0.5
		2 5 0.5 6 0.5
		2 5 0.5 6 0.5
		2 5 0.5 6 0.5
		2 5 0.5 6 0.5
		2 5 0.5 6 0.5
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		2 3 0.7 5 0.30000000000000004
		2 3 0.7 5 0.30000000000000004
		2 3 0.7 5 0.30000000000000004
		2 3 0.50542137026786804 5 0.49457862973213196
		2 3 0.56892665703489576 5 0.4310733429651043
		2 3 0.5 5 0.5
		2 3 0.5 5 0.5
		2 3 0.5 5 0.5
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 2 0.49999999999999983;
	setAttr ".wl[464:905].w"
		1 11 0.50000000000000011
		2 2 0.5 11 0.5
		2 2 0.5 11 0.5
		2 2 0.5 11 0.5
		2 2 0.5 11 0.5
		2 2 0.5 11 0.5
		1 11 1
		1 11 1
		2 2 0.52604130380325398 11 0.47395869619674608
		1 2 1
		2 2 0.5 11 0.5
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		1 13 1
		1 13 1
		2 12 0.5 13 0.5
		2 12 0.5 13 0.5
		1 13 1
		1 13 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		2 11 0.4981874543063744 12 0.50181254569362566
		2 11 0.49708586189339171 12 0.50291413810660823
		2 11 0.49878215296968997 12 0.50121784703031003
		2 11 0.49979931958860097 12 0.50020068041139898
		2 11 0.49952920390046096 12 0.50047079609953904
		2 11 0.49801873552862652 12 0.50198126447137348
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 3 1
		1 3 1
		1 3 1
		2 2 0.9 11 0.099999999999999978
		2 2 0.5 3 0.5
		1 3 1
		1 3 1
		1 3 1
		2 2 0.5 3 0.5
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 11 1
		1 11 1
		2 11 0.5 12 0.5
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		2 12 0.5 13 0.5
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		2 2 0.9 11 0.099999999999999978
		2 2 0.9 11 0.099999999999999978
		2 2 0.9 11 0.099999999999999978
		1 2 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		1 6 1
		1 6 1
		1 6 1
		1 7 1
		1 6 1
		1 6 1
		1 6 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		2 2 0.5 3 0.5
		1 2 1
		1 2 1
		1 2 1
		1 2 1
		1 2 1
		1 2 1
		1 2 1
		2 2 0.5 3 0.5
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 3 1
		1 3 1
		1 3 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		1 7 1
		2 6 0.5 7 0.5
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		2 5 0.5 6 0.5
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		2 3 0.7 5 0.30000000000000004
		1 3 1
		1 3 1
		2 6 0.5 7 0.5
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		2 5 0.5 6 0.5
		1 5 1
		1 5 1
		1 5 1
		1 5 1
		2 3 0.7 5 0.30000000000000004
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 3 1
		1 3 1
		1 3 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		1 6 1
		2 6 0.5 7 0.5
		1 7 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 8 1
		2 3 0.7 8 0.30000000000000004
		2 3 0.7 8 0.30000000000000004
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		2 3 0.7 8 0.30000000000000004
		2 3 0.7 8 0.30000000000000004
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		2 8 0.5 9 0.5
		1 8 1
		1 8 1
		2 8 0.5 9 0.5
		1 8 1
		2 8 0.5 9 0.5
		1 8 1
		2 3 0.7 8 0.30000000000000004
		1 8 1
		1 8 1
		2 8 0.5 9 0.5
		2 8 0.5 9 0.5
		2 3 0.56892665113514684 8 0.43107334886485327
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		2 8 0.5 9 0.5
		1 8 1
		2 8 0.49999999392579852 9 0.50000000607420148
		1 8 1
		1 8 1
		2 8 0.5 9 0.5
		1 8 1
		1 8 1
		2 8 0.5 9 0.5
		2 8 0.50000002237254804 9 0.49999997762745196
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		1 8 1
		2 3 0.5 8 0.5
		1 8 1
		2 3 0.50000002980232239 8 0.49999997019767761
		1 8 1
		2 3 0.5 8 0.5
		1 8 1
		2 3 0.50542137026786804 8 0.49457862973213196
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 9 1
		1 9 1
		2 9 0.5 10 0.5
		1 9 1
		1 9 1
		2 9 0.5 10 0.5
		1 9 1
		1 9 1
		1 9 1;
	setAttr ".wl[906:1341].w"
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		2 9 0.5 10 0.5
		1 10 1
		2 9 0.5 10 0.5
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		2 2 0.49999997019767761 14 0.50000002980232239
		2 2 0.5 14 0.5
		1 2 1
		1 2 1
		2 2 0.5 14 0.5
		1 2 1
		1 2 1
		1 2 1
		2 2 0.5 3 0.5
		1 2 1
		1 2 1
		2 2 0.52604130225107126 14 0.47395869774892874
		2 2 0.49999991059303284 14 0.50000008940696716
		2 2 0.9 14 0.099999999999999978
		2 2 0.9 14 0.099999999999999978
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		2 2 0.5 3 0.5
		2 2 0.9 14 0.099999999999999978
		2 2 0.49999999999999983 14 0.50000000000000011
		1 2 1
		1 2 1
		2 2 0.5 3 0.5
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		2 15 0.5 16 0.5
		2 15 0.5 16 0.5
		1 15 1
		1 15 1
		1 16 1
		1 16 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 16 1
		1 16 1
		1 15 1
		2 15 0.5 16 0.5
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 3 1
		1 3 1
		2 2 0.9 14 0.099999999999999978
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		2 2 0.5 14 0.5
		2 2 0.5 14 0.5
		1 9 1
		1 9 1
		1 9 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 10 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 9 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 2 1
		1 2 1
		1 3 1
		1 3 1
		2 14 0.4981874543063744 15 0.50181254569362566
		2 14 0.49708586202471178 15 0.50291413797528817
		2 14 0.5 15 0.5
		2 14 0.49878215296968997 15 0.50121784703031003
		2 14 0.49979931958860097 15 0.50020068041139898
		2 14 0.49952920390046096 15 0.50047079609953904
		2 14 0.49801873552862652 15 0.50198126447137348
		2 5 0.79456694558989216 6 0.20543305441010784
		2 5 0.7742233497394887 6 0.22577665026051127
		2 5 0.75609562680592357 6 0.2439043731940764
		2 5 0.69096569477081382 6 0.30903430522918618
		2 5 0.65106236251074145 6 0.3489376374892586
		2 5 0.64030249310438003 6 0.35969750689561997
		2 5 0.62511635694470269 6 0.37488364305529731
		2 5 0.63629642211926862 6 0.36370357788073143
		2 5 0.66386574393242181 6 0.33613425606757819
		2 5 0.73944738194485937 6 0.26055261805514063
		2 8 0.73944738194485937 9 0.26055261805514063
		2 8 0.66386574393242181 9 0.33613425606757819
		2 8 0.63629642211926862 9 0.36370357788073143
		2 8 0.62511635694470269 9 0.37488364305529731
		2 8 0.64030248676823032 9 0.35969751323176974
		2 8 0.65106227946142525 9 0.34893772053857475
		2 8 0.69096569477081382 9 0.30903430522918618
		2 8 0.75609548284074912 9 0.24390451715925088
		2 8 0.77422334757849565 9 0.22577665242150424
		2 8 0.79456694558989216 9 0.20543305441010784
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		2 11 0.49722900940995174 12 0.50277099059004826
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		2 2 0.5 11 0.5
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		2 11 0.49803081671393945 12 0.50196918328606055
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		2 14 0.49722900940995174 15 0.50277099059004826
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		2 2 0.5 14 0.5
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		2 14 0.49803081671393945 15 0.50196918328606055
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 13 1
		1 13 1
		1 13 1
		2 12 0.5 13 0.5
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		1 12 1
		2 11 0.5 12 0.5
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 11 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		1 14 1
		2 14 0.5 15 0.5
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		1 15 1
		2 15 0.5 16 0.5
		1 16 1
		1 16 1
		1 16 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		2 2 0.5 11 0.5
		1 2 1
		1 2 1
		1 2 1
		2 2 0.5 14 0.5
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 13 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1
		1 16 1;
	setAttr ".wl[1342:1357].w"
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1
		1 3 1;
	setAttr -s 17 ".pm";
	setAttr ".pm[0]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr ".pm[1]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr ".pm[2]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr ".pm[3]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 -0.30419355558370681 -0.071786129418169337 1;
	setAttr ".pm[4]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 -1.6631563929227191 -0.018358864130673176 1;
	setAttr ".pm[5]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.47164059093158489 -1.3986251935241258 -0.018720083321402556 1;
	setAttr ".pm[6]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.871429020309062 -0.80960230504297559 -0.018720083321402556 1;
	setAttr ".pm[7]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -1.3412226859565757 -0.12379841626320098 -0.17731135436561452 1;
	setAttr ".pm[8]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.47164059093158489 -1.3986251935241258 -0.018720083321402556 1;
	setAttr ".pm[9]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.871429020309062 -0.80960230504297559 -0.018720083321402556 1;
	setAttr ".pm[10]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 1.3412226859565757 -0.12379841626320098 -0.17731135436561452 1;
	setAttr ".pm[11]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.29964910404920925 0.11911620210506754 -0.088160396778711791 1;
	setAttr ".pm[12]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.48776580967024591 1.4314315808547828 -0.031223473859126938 1;
	setAttr ".pm[13]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 -0.64744626909275338 2.7466129599864555 0.073876774127567893 1;
	setAttr ".pm[14]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.29964910404920925 0.11911620210506754 -0.088160396778711791 1;
	setAttr ".pm[15]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.48776580967024591 1.4314315808547828 -0.031223473859126938 1;
	setAttr ".pm[16]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0.64744626909275338 2.7466129599864555 0.073876774127567893 1;
	setAttr ".gm" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr -s 15 ".ma";
	setAttr -s 17 ".dpf[0:16]"  4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4 4;
	setAttr -s 15 ".lw";
	setAttr -s 15 ".lw";
	setAttr ".mmi" yes;
	setAttr ".mi" 4;
	setAttr ".ucm" yes;
	setAttr -s 15 ".ifcl";
	setAttr -s 15 ".ifcl";
createNode groupId -n "groupId1";
	rename -uid "8B2385D7-4368-F0EE-46D4-AD871EAAD1C0";
	setAttr ".ihi" 0;
createNode groupParts -n "groupParts1";
	rename -uid "47B93AD1-401B-826F-426C-31B92E013EC6";
	setAttr ".ihi" 0;
createNode groupId -n "groupId2";
	rename -uid "0AEC5C77-4FE9-2941-CBCF-488680F8C1A3";
	setAttr ".ihi" 0;
createNode groupParts -n "groupParts2";
	rename -uid "E5826B26-4901-AA00-9C41-D0B6C8956A6C";
	setAttr ".ihi" 0;
	setAttr ".ic" -type "componentList" 1 "f[0:1359]";
createNode tweak -n "tweak1";
	rename -uid "808B7134-4ED2-EDAD-AF2B-8EB7562C4E16";
createNode objectSet -n "skinCluster1Set";
	rename -uid "7EEA8AF0-4D84-0E23-2BB6-08BF734B388F";
	setAttr ".ihi" 0;
	setAttr ".vo" yes;
createNode groupId -n "skinCluster1GroupId";
	rename -uid "5F45CE35-406B-0002-A370-20ADED7D93A8";
	setAttr ".ihi" 0;
createNode groupParts -n "skinCluster1GroupParts";
	rename -uid "19F8CC1F-452B-6D05-8518-5C9951162D05";
	setAttr ".ihi" 0;
	setAttr ".ic" -type "componentList" 1 "vtx[*]";
createNode objectSet -n "tweakSet1";
	rename -uid "5A228D51-43C0-98E6-47E4-AB9F59D67FC8";
	setAttr ".ihi" 0;
	setAttr ".vo" yes;
createNode groupId -n "groupId4";
	rename -uid "6E4C9F6F-46A3-4D30-CA77-CD90A367C798";
	setAttr ".ihi" 0;
createNode groupParts -n "groupParts4";
	rename -uid "0B6EBB18-4062-5434-0A0B-D980F4E74341";
	setAttr ".ihi" 0;
	setAttr ".ic" -type "componentList" 1 "vtx[*]";
createNode dagPose -n "bindPose1";
	rename -uid "23DC273C-422D-6E38-0271-828504B6D893";
	setAttr -s 18 ".wm";
	setAttr ".wm[0]" -type "matrix" 1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1;
	setAttr -s 18 ".xm";
	setAttr ".xm[0]" -type "matrix" "xform" 1 1 1 0 0 0 0 0 0 0 0 0 0 0 -0.2476237835318682
		 0.236347783478635 0 0 0 0 -0.2476237835318682 0.236347783478635 0 0 0 0 0 0 1 0 0 0 1 1
		 1 1 yes;
	setAttr ".xm[1]" -type "matrix" "xform" 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
		 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[2]" -type "matrix" "xform" 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
		 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[3]" -type "matrix" "xform" 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
		 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[4]" -type "matrix" "xform" 1 1 1 0 0 0 0 0 0.30419355558370681
		 0.071786129418169337 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[5]" -type "matrix" "xform" 1 1 1 0 0 0 0 0 1.3589628373390124 -0.05342726528749616 0
		 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[6]" -type "matrix" "xform" 1 1 1 0 0 0 0 0.47164059093158489 1.0944316379404191
		 -0.053066046096766781 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[7]" -type "matrix" "xform" 1 1 1 0 0 0 0 0.39978842937747716 -0.58902288848115025
		 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[8]" -type "matrix" "xform" 1 1 1 0 0 0 0 0.46979366564751379 -0.68580388877977461
		 0.15859127104421195 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[9]" -type "matrix" "xform" 1 1 1 0 0 0 0 -0.47164059093158489 1.0944316379404191
		 -0.053066046096766781 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[10]" -type "matrix" "xform" 1 1 1 0 0 0 0 -0.39978842937747711
		 -0.58902288848115025 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[11]" -type "matrix" "xform" 1 1 1 0 0 0 0 -0.46979366564751368
		 -0.68580388877977461 0.15859127104421195 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1
		 1 1 yes;
	setAttr ".xm[12]" -type "matrix" "xform" 1 1 1 0 0 0 0 0.29964910404920925 -0.11911620210506754
		 0.088160396778711791 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[13]" -type "matrix" "xform" 1 1 1 0 0 0 0 0.18811670562103666 -1.3123153787497153
		 -0.056936922919584854 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[14]" -type "matrix" "xform" 1 1 1 0 0 0 0 0.15968045942250741 -1.3151813791316724
		 -0.10510024798669483 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1 1 1 yes;
	setAttr ".xm[15]" -type "matrix" "xform" 1 1 1 0 0 0 0 -0.29964910404920925
		 -0.11911620210506754 0.088160396778711791 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 
		0 0 0 1 1 1 1 yes;
	setAttr ".xm[16]" -type "matrix" "xform" 1 1 1 0 0 0 0 -0.18811670562103666
		 -1.3123153787497153 -0.056936922919584854 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 
		0 0 0 1 1 1 1 yes;
	setAttr ".xm[17]" -type "matrix" "xform" 1 1 1 0 0 0 0 -0.15968045942250747
		 -1.3151813791316727 -0.10510024798669483 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 1 1
		 1 1 yes;
	setAttr -s 18 ".m";
	setAttr -s 18 ".p";
	setAttr -s 18 ".g[0:17]" yes yes yes no no no no no no no no no no 
		no no no no no;
	setAttr ".bp" yes;
createNode animLayer -n "BaseAnimation";
	rename -uid "14B5C64A-4CD8-240E-D25F-059AFCCBEC6F";
	setAttr ".ovrd" yes;
createNode script -n "uiConfigurationScriptNode";
	rename -uid "AE6472AB-4803-9EE4-7D56-A894995E5A13";
	setAttr ".b" -type "string" (
		"// Maya Mel UI Configuration File.\n//\n//  This script is machine generated.  Edit at your own risk.\n//\n//\n\nglobal string $gMainPane;\nif (`paneLayout -exists $gMainPane`) {\n\n\tglobal int $gUseScenePanelConfig;\n\tint    $useSceneConfig = $gUseScenePanelConfig;\n\tint    $nodeEditorPanelVisible = stringArrayContains(\"nodeEditorPanel1\", `getPanel -vis`);\n\tint    $nodeEditorWorkspaceControlOpen = (`workspaceControl -exists nodeEditorPanel1Window` && `workspaceControl -q -visible nodeEditorPanel1Window`);\n\tint    $menusOkayInPanels = `optionVar -q allowMenusInPanels`;\n\tint    $nVisPanes = `paneLayout -q -nvp $gMainPane`;\n\tint    $nPanes = 0;\n\tstring $editorName;\n\tstring $panelName;\n\tstring $itemFilterName;\n\tstring $panelConfig;\n\n\t//\n\t//  get current state of the UI\n\t//\n\tsceneUIReplacement -update $gMainPane;\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Top View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Top View\")) -mbv $menusOkayInPanels  $panelName;\n"
		+ "\t\t$editorName = $panelName;\n        modelEditor -e \n            -camera \"top\" \n            -useInteractiveMode 0\n            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n            -wireframeOnShaded 0\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n            -xray 0\n            -jointXray 1\n            -activeComponentsXray 0\n            -displayTextures 0\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n"
		+ "            -depthOfFieldPreview 1\n            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n"
		+ "            -hulls 1\n            -grid 1\n            -imagePlane 1\n            -joints 1\n            -ikHandles 1\n            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 1\n            -height 1\n            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n"
		+ "\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Side View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Side View\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        modelEditor -e \n            -camera \"side\" \n            -useInteractiveMode 0\n            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n            -wireframeOnShaded 0\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n            -xray 0\n            -jointXray 1\n            -activeComponentsXray 0\n            -displayTextures 0\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n"
		+ "            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n            -depthOfFieldPreview 1\n            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n"
		+ "            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n            -hulls 1\n            -grid 1\n            -imagePlane 1\n            -joints 1\n            -ikHandles 1\n            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 1\n            -height 1\n"
		+ "            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Front View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Front View\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        modelEditor -e \n            -camera \"front\" \n            -useInteractiveMode 0\n            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n            -wireframeOnShaded 0\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n"
		+ "            -xray 0\n            -jointXray 1\n            -activeComponentsXray 0\n            -displayTextures 0\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n            -depthOfFieldPreview 1\n            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n"
		+ "            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n            -hulls 1\n            -grid 1\n            -imagePlane 1\n            -joints 1\n            -ikHandles 1\n            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n"
		+ "            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 1243\n            -height 1657\n            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"modelPanel\" (localizedPanelLabel(\"Persp View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tmodelPanel -edit -l (localizedPanelLabel(\"Persp View\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        modelEditor -e \n            -camera \"persp\" \n            -useInteractiveMode 0\n            -displayLights \"default\" \n            -displayAppearance \"smoothShaded\" \n            -activeOnly 0\n            -ignorePanZoom 0\n"
		+ "            -wireframeOnShaded 0\n            -headsUpDisplay 1\n            -holdOuts 1\n            -selectionHiliteDisplay 1\n            -useDefaultMaterial 0\n            -bufferMode \"double\" \n            -twoSidedLighting 0\n            -backfaceCulling 0\n            -xray 0\n            -jointXray 1\n            -activeComponentsXray 0\n            -displayTextures 0\n            -smoothWireframe 0\n            -lineWidth 1\n            -textureAnisotropic 0\n            -textureHilight 1\n            -textureSampling 2\n            -textureDisplay \"modulate\" \n            -textureMaxSize 32768\n            -fogging 0\n            -fogSource \"fragment\" \n            -fogMode \"linear\" \n            -fogStart 0\n            -fogEnd 100\n            -fogDensity 0.1\n            -fogColor 0.5 0.5 0.5 1 \n            -depthOfFieldPreview 1\n            -maxConstantTransparency 1\n            -rendererName \"vp2Renderer\" \n            -objectFilterShowInHUD 1\n            -isFiltered 0\n            -colorResolution 256 256 \n            -bumpResolution 512 512 \n"
		+ "            -textureCompression 0\n            -transparencyAlgorithm \"frontAndBackCull\" \n            -transpInShadows 0\n            -cullingOverride \"none\" \n            -lowQualityLighting 0\n            -maximumNumHardwareLights 1\n            -occlusionCulling 0\n            -shadingModel 0\n            -useBaseRenderer 0\n            -useReducedRenderer 0\n            -smallObjectCulling 0\n            -smallObjectThreshold -1 \n            -interactiveDisableShadows 0\n            -interactiveBackFaceCull 0\n            -sortTransparent 1\n            -controllers 1\n            -nurbsCurves 1\n            -nurbsSurfaces 1\n            -polymeshes 1\n            -subdivSurfaces 1\n            -planes 1\n            -lights 1\n            -cameras 1\n            -controlVertices 1\n            -hulls 1\n            -grid 0\n            -imagePlane 1\n            -joints 1\n            -ikHandles 1\n            -deformers 1\n            -dynamics 1\n            -particleInstancers 1\n            -fluids 1\n            -hairSystems 1\n            -follicles 1\n"
		+ "            -nCloths 1\n            -nParticles 1\n            -nRigids 1\n            -dynamicConstraints 1\n            -locators 1\n            -manipulators 1\n            -pluginShapes 1\n            -dimensions 1\n            -handles 1\n            -pivots 1\n            -textures 1\n            -strokes 1\n            -motionTrails 1\n            -clipGhosts 1\n            -greasePencils 1\n            -shadows 0\n            -captureSequenceNumber -1\n            -width 2749\n            -height 1657\n            -sceneRenderFilter 0\n            $editorName;\n        modelEditor -e -viewSelected 0 $editorName;\n        modelEditor -e \n            -pluginObjects \"gpuCacheDisplayFilter\" 1 \n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"outlinerPanel\" (localizedPanelLabel(\"ToggledOutliner\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\toutlinerPanel -edit -l (localizedPanelLabel(\"ToggledOutliner\")) -mbv $menusOkayInPanels  $panelName;\n"
		+ "\t\t$editorName = $panelName;\n        outlinerEditor -e \n            -docTag \"isolOutln_fromSeln\" \n            -showShapes 0\n            -showAssignedMaterials 0\n            -showTimeEditor 1\n            -showReferenceNodes 1\n            -showReferenceMembers 1\n            -showAttributes 0\n            -showConnected 0\n            -showAnimCurvesOnly 0\n            -showMuteInfo 0\n            -organizeByLayer 1\n            -organizeByClip 1\n            -showAnimLayerWeight 1\n            -autoExpandLayers 1\n            -autoExpand 0\n            -autoExpandAnimatedShapes 1\n            -showDagOnly 1\n            -showAssets 1\n            -showContainedOnly 1\n            -showPublishedAsConnected 0\n            -showParentContainers 0\n            -showContainerContents 1\n            -ignoreDagHierarchy 0\n            -expandConnections 0\n            -showUpstreamCurves 1\n            -showUnitlessCurves 1\n            -showCompounds 1\n            -showLeafs 1\n            -showNumericAttrsOnly 0\n            -highlightActive 1\n"
		+ "            -autoSelectNewObjects 0\n            -doNotSelectNewObjects 0\n            -dropIsParent 1\n            -transmitFilters 0\n            -setFilter \"defaultSetFilter\" \n            -showSetMembers 1\n            -allowMultiSelection 1\n            -alwaysToggleSelect 0\n            -directSelect 0\n            -isSet 0\n            -isSetMember 0\n            -displayMode \"DAG\" \n            -expandObjects 0\n            -setsIgnoreFilters 1\n            -containersIgnoreFilters 0\n            -editAttrName 0\n            -showAttrValues 0\n            -highlightSecondary 0\n            -showUVAttrsOnly 0\n            -showTextureNodesOnly 0\n            -attrAlphaOrder \"default\" \n            -animLayerFilterOptions \"allAffecting\" \n            -sortOrder \"none\" \n            -longNames 0\n            -niceNames 1\n            -showNamespace 1\n            -showPinIcons 0\n            -mapMotionTrails 0\n            -ignoreHiddenAttribute 0\n            -ignoreOutlinerColor 0\n            -renderFilterVisible 0\n            -renderFilterIndex 0\n"
		+ "            -selectionOrder \"chronological\" \n            -expandAttribute 0\n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"outlinerPanel\" (localizedPanelLabel(\"Outliner\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\toutlinerPanel -edit -l (localizedPanelLabel(\"Outliner\")) -mbv $menusOkayInPanels  $panelName;\n\t\t$editorName = $panelName;\n        outlinerEditor -e \n            -showShapes 0\n            -showAssignedMaterials 0\n            -showTimeEditor 1\n            -showReferenceNodes 0\n            -showReferenceMembers 0\n            -showAttributes 0\n            -showConnected 0\n            -showAnimCurvesOnly 0\n            -showMuteInfo 0\n            -organizeByLayer 1\n            -organizeByClip 1\n            -showAnimLayerWeight 1\n            -autoExpandLayers 1\n            -autoExpand 0\n            -autoExpandAnimatedShapes 1\n            -showDagOnly 1\n            -showAssets 1\n            -showContainedOnly 1\n"
		+ "            -showPublishedAsConnected 0\n            -showParentContainers 0\n            -showContainerContents 1\n            -ignoreDagHierarchy 0\n            -expandConnections 0\n            -showUpstreamCurves 1\n            -showUnitlessCurves 1\n            -showCompounds 1\n            -showLeafs 1\n            -showNumericAttrsOnly 0\n            -highlightActive 1\n            -autoSelectNewObjects 0\n            -doNotSelectNewObjects 0\n            -dropIsParent 1\n            -transmitFilters 0\n            -setFilter \"defaultSetFilter\" \n            -showSetMembers 1\n            -allowMultiSelection 1\n            -alwaysToggleSelect 0\n            -directSelect 0\n            -displayMode \"DAG\" \n            -expandObjects 0\n            -setsIgnoreFilters 1\n            -containersIgnoreFilters 0\n            -editAttrName 0\n            -showAttrValues 0\n            -highlightSecondary 0\n            -showUVAttrsOnly 0\n            -showTextureNodesOnly 0\n            -attrAlphaOrder \"default\" \n            -animLayerFilterOptions \"allAffecting\" \n"
		+ "            -sortOrder \"none\" \n            -longNames 0\n            -niceNames 1\n            -showNamespace 1\n            -showPinIcons 0\n            -mapMotionTrails 0\n            -ignoreHiddenAttribute 0\n            -ignoreOutlinerColor 0\n            -renderFilterVisible 0\n            $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"graphEditor\" (localizedPanelLabel(\"Graph Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Graph Editor\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"OutlineEd\");\n            outlinerEditor -e \n                -showShapes 1\n                -showAssignedMaterials 0\n                -showTimeEditor 1\n                -showReferenceNodes 0\n                -showReferenceMembers 0\n                -showAttributes 1\n                -showConnected 1\n                -showAnimCurvesOnly 1\n                -showMuteInfo 0\n"
		+ "                -organizeByLayer 1\n                -organizeByClip 1\n                -showAnimLayerWeight 1\n                -autoExpandLayers 1\n                -autoExpand 1\n                -autoExpandAnimatedShapes 1\n                -showDagOnly 0\n                -showAssets 1\n                -showContainedOnly 0\n                -showPublishedAsConnected 0\n                -showParentContainers 0\n                -showContainerContents 0\n                -ignoreDagHierarchy 0\n                -expandConnections 1\n                -showUpstreamCurves 1\n                -showUnitlessCurves 1\n                -showCompounds 0\n                -showLeafs 1\n                -showNumericAttrsOnly 1\n                -highlightActive 0\n                -autoSelectNewObjects 1\n                -doNotSelectNewObjects 0\n                -dropIsParent 1\n                -transmitFilters 1\n                -setFilter \"0\" \n                -showSetMembers 0\n                -allowMultiSelection 1\n                -alwaysToggleSelect 0\n                -directSelect 0\n"
		+ "                -displayMode \"DAG\" \n                -expandObjects 0\n                -setsIgnoreFilters 1\n                -containersIgnoreFilters 0\n                -editAttrName 0\n                -showAttrValues 0\n                -highlightSecondary 0\n                -showUVAttrsOnly 0\n                -showTextureNodesOnly 0\n                -attrAlphaOrder \"default\" \n                -animLayerFilterOptions \"allAffecting\" \n                -sortOrder \"none\" \n                -longNames 0\n                -niceNames 1\n                -showNamespace 1\n                -showPinIcons 1\n                -mapMotionTrails 1\n                -ignoreHiddenAttribute 0\n                -ignoreOutlinerColor 0\n                -renderFilterVisible 0\n                $editorName;\n\n\t\t\t$editorName = ($panelName+\"GraphEd\");\n            animCurveEditor -e \n                -displayValues 0\n                -snapTime \"integer\" \n                -snapValue \"none\" \n                -showPlayRangeShades \"on\" \n                -lockPlayRangeShades \"off\" \n"
		+ "                -smoothness \"fine\" \n                -resultSamples 1\n                -resultScreenSamples 0\n                -resultUpdate \"delayed\" \n                -showUpstreamCurves 1\n                -stackedCurvesMin -1\n                -stackedCurvesMax 1\n                -stackedCurvesSpace 0.2\n                -preSelectionHighlight 0\n                -constrainDrag 0\n                -valueLinesToggle 1\n                -highlightAffectedCurves 0\n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"dopeSheetPanel\" (localizedPanelLabel(\"Dope Sheet\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Dope Sheet\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"OutlineEd\");\n            outlinerEditor -e \n                -showShapes 1\n                -showAssignedMaterials 0\n                -showTimeEditor 1\n                -showReferenceNodes 0\n"
		+ "                -showReferenceMembers 0\n                -showAttributes 1\n                -showConnected 1\n                -showAnimCurvesOnly 1\n                -showMuteInfo 0\n                -organizeByLayer 1\n                -organizeByClip 1\n                -showAnimLayerWeight 1\n                -autoExpandLayers 1\n                -autoExpand 0\n                -autoExpandAnimatedShapes 1\n                -showDagOnly 0\n                -showAssets 1\n                -showContainedOnly 0\n                -showPublishedAsConnected 0\n                -showParentContainers 0\n                -showContainerContents 0\n                -ignoreDagHierarchy 0\n                -expandConnections 1\n                -showUpstreamCurves 1\n                -showUnitlessCurves 0\n                -showCompounds 1\n                -showLeafs 1\n                -showNumericAttrsOnly 1\n                -highlightActive 0\n                -autoSelectNewObjects 0\n                -doNotSelectNewObjects 1\n                -dropIsParent 1\n                -transmitFilters 0\n"
		+ "                -setFilter \"0\" \n                -showSetMembers 0\n                -allowMultiSelection 1\n                -alwaysToggleSelect 0\n                -directSelect 0\n                -displayMode \"DAG\" \n                -expandObjects 0\n                -setsIgnoreFilters 1\n                -containersIgnoreFilters 0\n                -editAttrName 0\n                -showAttrValues 0\n                -highlightSecondary 0\n                -showUVAttrsOnly 0\n                -showTextureNodesOnly 0\n                -attrAlphaOrder \"default\" \n                -animLayerFilterOptions \"allAffecting\" \n                -sortOrder \"none\" \n                -longNames 0\n                -niceNames 1\n                -showNamespace 1\n                -showPinIcons 0\n                -mapMotionTrails 1\n                -ignoreHiddenAttribute 0\n                -ignoreOutlinerColor 0\n                -renderFilterVisible 0\n                $editorName;\n\n\t\t\t$editorName = ($panelName+\"DopeSheetEd\");\n            dopeSheetEditor -e \n                -displayValues 0\n"
		+ "                -snapTime \"integer\" \n                -snapValue \"none\" \n                -outliner \"dopeSheetPanel1OutlineEd\" \n                -showSummary 1\n                -showScene 0\n                -hierarchyBelow 0\n                -showTicks 1\n                -selectionWindow 0 0 0 0 \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"timeEditorPanel\" (localizedPanelLabel(\"Time Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Time Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"clipEditorPanel\" (localizedPanelLabel(\"Trax Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Trax Editor\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = clipEditorNameFromPanel($panelName);\n"
		+ "            clipEditor -e \n                -displayValues 0\n                -snapTime \"none\" \n                -snapValue \"none\" \n                -initialized 0\n                -manageSequencer 0 \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"sequenceEditorPanel\" (localizedPanelLabel(\"Camera Sequencer\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Camera Sequencer\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = sequenceEditorNameFromPanel($panelName);\n            clipEditor -e \n                -displayValues 0\n                -snapTime \"none\" \n                -snapValue \"none\" \n                -initialized 0\n                -manageSequencer 1 \n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"hyperGraphPanel\" (localizedPanelLabel(\"Hypergraph Hierarchy\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Hypergraph Hierarchy\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"HyperGraphEd\");\n            hyperGraph -e \n                -graphLayoutStyle \"hierarchicalLayout\" \n                -orientation \"horiz\" \n                -mergeConnections 0\n                -zoom 1\n                -animateTransition 0\n                -showRelationships 1\n                -showShapes 0\n                -showDeformers 0\n                -showExpressions 0\n                -showConstraints 0\n                -showConnectionFromSelected 0\n                -showConnectionToSelected 0\n                -showConstraintLabels 0\n                -showUnderworld 0\n                -showInvisible 0\n                -transitionFrames 1\n                -opaqueContainers 0\n                -freeform 0\n                -imagePosition 0 0 \n                -imageScale 1\n                -imageEnabled 0\n                -graphType \"DAG\" \n"
		+ "                -heatMapDisplay 0\n                -updateSelection 1\n                -updateNodeAdded 1\n                -useDrawOverrideColor 0\n                -limitGraphTraversal -1\n                -range 0 0 \n                -iconSize \"smallIcons\" \n                -showCachedConnections 0\n                $editorName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"hyperShadePanel\" (localizedPanelLabel(\"Hypershade\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Hypershade\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"visorPanel\" (localizedPanelLabel(\"Visor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Visor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n"
		+ "\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"nodeEditorPanel\" (localizedPanelLabel(\"Node Editor\")) `;\n\tif ($nodeEditorPanelVisible || $nodeEditorWorkspaceControlOpen) {\n\t\tif (\"\" == $panelName) {\n\t\t\tif ($useSceneConfig) {\n\t\t\t\t$panelName = `scriptedPanel -unParent  -type \"nodeEditorPanel\" -l (localizedPanelLabel(\"Node Editor\")) -mbv $menusOkayInPanels `;\n\n\t\t\t$editorName = ($panelName+\"NodeEditorEd\");\n            nodeEditor -e \n                -allAttributes 0\n                -allNodes 0\n                -autoSizeNodes 1\n                -consistentNameSize 1\n                -createNodeCommand \"nodeEdCreateNodeCommand\" \n                -connectNodeOnCreation 0\n                -connectOnDrop 0\n                -copyConnectionsOnPaste 0\n                -connectionStyle \"bezier\" \n                -defaultPinnedState 0\n                -additiveGraphingMode 0\n                -settingsChangedCallback \"nodeEdSyncControls\" \n                -traversalDepthLimit -1\n                -keyPressCommand \"nodeEdKeyPressCommand\" \n"
		+ "                -nodeTitleMode \"name\" \n                -gridSnap 0\n                -gridVisibility 1\n                -crosshairOnEdgeDragging 0\n                -popupMenuScript \"nodeEdBuildPanelMenus\" \n                -showNamespace 1\n                -showShapes 1\n                -showSGShapes 0\n                -showTransforms 1\n                -useAssets 1\n                -syncedSelection 1\n                -extendToShapes 1\n                -editorMode \"default\" \n                -hasWatchpoint 0\n                $editorName;\n\t\t\t}\n\t\t} else {\n\t\t\t$label = `panel -q -label $panelName`;\n\t\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Node Editor\")) -mbv $menusOkayInPanels  $panelName;\n\n\t\t\t$editorName = ($panelName+\"NodeEditorEd\");\n            nodeEditor -e \n                -allAttributes 0\n                -allNodes 0\n                -autoSizeNodes 1\n                -consistentNameSize 1\n                -createNodeCommand \"nodeEdCreateNodeCommand\" \n                -connectNodeOnCreation 0\n                -connectOnDrop 0\n"
		+ "                -copyConnectionsOnPaste 0\n                -connectionStyle \"bezier\" \n                -defaultPinnedState 0\n                -additiveGraphingMode 0\n                -settingsChangedCallback \"nodeEdSyncControls\" \n                -traversalDepthLimit -1\n                -keyPressCommand \"nodeEdKeyPressCommand\" \n                -nodeTitleMode \"name\" \n                -gridSnap 0\n                -gridVisibility 1\n                -crosshairOnEdgeDragging 0\n                -popupMenuScript \"nodeEdBuildPanelMenus\" \n                -showNamespace 1\n                -showShapes 1\n                -showSGShapes 0\n                -showTransforms 1\n                -useAssets 1\n                -syncedSelection 1\n                -extendToShapes 1\n                -editorMode \"default\" \n                -hasWatchpoint 0\n                $editorName;\n\t\t\tif (!$useSceneConfig) {\n\t\t\t\tpanel -e -l $label $panelName;\n\t\t\t}\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"createNodePanel\" (localizedPanelLabel(\"Create Node\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Create Node\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"polyTexturePlacementPanel\" (localizedPanelLabel(\"UV Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"UV Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"renderWindowPanel\" (localizedPanelLabel(\"Render View\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Render View\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"shapePanel\" (localizedPanelLabel(\"Shape Editor\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tshapePanel -edit -l (localizedPanelLabel(\"Shape Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextPanel \"posePanel\" (localizedPanelLabel(\"Pose Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tposePanel -edit -l (localizedPanelLabel(\"Pose Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"dynRelEdPanel\" (localizedPanelLabel(\"Dynamic Relationships\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Dynamic Relationships\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"relationshipPanel\" (localizedPanelLabel(\"Relationship Editor\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Relationship Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"referenceEditorPanel\" (localizedPanelLabel(\"Reference Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Reference Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"componentEditorPanel\" (localizedPanelLabel(\"Component Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Component Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"dynPaintScriptedPanelType\" (localizedPanelLabel(\"Paint Effects\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Paint Effects\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"scriptEditorPanel\" (localizedPanelLabel(\"Script Editor\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Script Editor\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"profilerPanel\" (localizedPanelLabel(\"Profiler Tool\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Profiler Tool\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"contentBrowserPanel\" (localizedPanelLabel(\"Content Browser\")) `;\n"
		+ "\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Content Browser\")) -mbv $menusOkayInPanels  $panelName;\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\t$panelName = `sceneUIReplacement -getNextScriptedPanel \"Stereo\" (localizedPanelLabel(\"Stereo\")) `;\n\tif (\"\" != $panelName) {\n\t\t$label = `panel -q -label $panelName`;\n\t\tscriptedPanel -edit -l (localizedPanelLabel(\"Stereo\")) -mbv $menusOkayInPanels  $panelName;\n{ string $editorName = ($panelName+\"Editor\");\n            stereoCameraView -e \n                -camera \"persp\" \n                -useInteractiveMode 0\n                -displayLights \"default\" \n                -displayAppearance \"wireframe\" \n                -activeOnly 0\n                -ignorePanZoom 0\n                -wireframeOnShaded 0\n                -headsUpDisplay 1\n                -holdOuts 1\n                -selectionHiliteDisplay 1\n                -useDefaultMaterial 0\n                -bufferMode \"double\" \n                -twoSidedLighting 1\n"
		+ "                -backfaceCulling 0\n                -xray 0\n                -jointXray 0\n                -activeComponentsXray 0\n                -displayTextures 0\n                -smoothWireframe 0\n                -lineWidth 1\n                -textureAnisotropic 0\n                -textureHilight 1\n                -textureSampling 2\n                -textureDisplay \"modulate\" \n                -textureMaxSize 32768\n                -fogging 0\n                -fogSource \"fragment\" \n                -fogMode \"linear\" \n                -fogStart 0\n                -fogEnd 100\n                -fogDensity 0.1\n                -fogColor 0.5 0.5 0.5 1 \n                -depthOfFieldPreview 1\n                -maxConstantTransparency 1\n                -objectFilterShowInHUD 1\n                -isFiltered 0\n                -colorResolution 4 4 \n                -bumpResolution 4 4 \n                -textureCompression 0\n                -transparencyAlgorithm \"frontAndBackCull\" \n                -transpInShadows 0\n                -cullingOverride \"none\" \n"
		+ "                -lowQualityLighting 0\n                -maximumNumHardwareLights 0\n                -occlusionCulling 0\n                -shadingModel 0\n                -useBaseRenderer 0\n                -useReducedRenderer 0\n                -smallObjectCulling 0\n                -smallObjectThreshold -1 \n                -interactiveDisableShadows 0\n                -interactiveBackFaceCull 0\n                -sortTransparent 1\n                -controllers 1\n                -nurbsCurves 1\n                -nurbsSurfaces 1\n                -polymeshes 1\n                -subdivSurfaces 1\n                -planes 1\n                -lights 1\n                -cameras 1\n                -controlVertices 1\n                -hulls 1\n                -grid 1\n                -imagePlane 1\n                -joints 1\n                -ikHandles 1\n                -deformers 1\n                -dynamics 1\n                -particleInstancers 1\n                -fluids 1\n                -hairSystems 1\n                -follicles 1\n                -nCloths 1\n"
		+ "                -nParticles 1\n                -nRigids 1\n                -dynamicConstraints 1\n                -locators 1\n                -manipulators 1\n                -pluginShapes 1\n                -dimensions 1\n                -handles 1\n                -pivots 1\n                -textures 1\n                -strokes 1\n                -motionTrails 1\n                -clipGhosts 1\n                -greasePencils 1\n                -shadows 0\n                -captureSequenceNumber -1\n                -width 0\n                -height 0\n                -sceneRenderFilter 0\n                -displayMode \"centerEye\" \n                -viewColor 0 0 0 1 \n                -useCustomBackground 1\n                $editorName;\n            stereoCameraView -e -viewSelected 0 $editorName;\n            stereoCameraView -e \n                -pluginObjects \"gpuCacheDisplayFilter\" 1 \n                $editorName; };\n\t\tif (!$useSceneConfig) {\n\t\t\tpanel -e -l $label $panelName;\n\t\t}\n\t}\n\n\n\tif ($useSceneConfig) {\n        string $configName = `getPanel -cwl (localizedPanelLabel(\"Current Layout\"))`;\n"
		+ "        if (\"\" != $configName) {\n\t\t\tpanelConfiguration -edit -label (localizedPanelLabel(\"Current Layout\")) \n\t\t\t\t-userCreated false\n\t\t\t\t-defaultImage \"vacantCell.xP:/\"\n\t\t\t\t-image \"\"\n\t\t\t\t-sc false\n\t\t\t\t-configString \"global string $gMainPane; paneLayout -e -cn \\\"single\\\" -ps 1 100 100 $gMainPane;\"\n\t\t\t\t-removeAllPanels\n\t\t\t\t-ap false\n\t\t\t\t\t(localizedPanelLabel(\"Persp View\")) \n\t\t\t\t\t\"modelPanel\"\n"
		+ "\t\t\t\t\t\"$panelName = `modelPanel -unParent -l (localizedPanelLabel(\\\"Persp View\\\")) -mbv $menusOkayInPanels `;\\n$editorName = $panelName;\\nmodelEditor -e \\n    -cam `findStartUpCamera persp` \\n    -useInteractiveMode 0\\n    -displayLights \\\"default\\\" \\n    -displayAppearance \\\"smoothShaded\\\" \\n    -activeOnly 0\\n    -ignorePanZoom 0\\n    -wireframeOnShaded 0\\n    -headsUpDisplay 1\\n    -holdOuts 1\\n    -selectionHiliteDisplay 1\\n    -useDefaultMaterial 0\\n    -bufferMode \\\"double\\\" \\n    -twoSidedLighting 0\\n    -backfaceCulling 0\\n    -xray 0\\n    -jointXray 1\\n    -activeComponentsXray 0\\n    -displayTextures 0\\n    -smoothWireframe 0\\n    -lineWidth 1\\n    -textureAnisotropic 0\\n    -textureHilight 1\\n    -textureSampling 2\\n    -textureDisplay \\\"modulate\\\" \\n    -textureMaxSize 32768\\n    -fogging 0\\n    -fogSource \\\"fragment\\\" \\n    -fogMode \\\"linear\\\" \\n    -fogStart 0\\n    -fogEnd 100\\n    -fogDensity 0.1\\n    -fogColor 0.5 0.5 0.5 1 \\n    -depthOfFieldPreview 1\\n    -maxConstantTransparency 1\\n    -rendererName \\\"vp2Renderer\\\" \\n    -objectFilterShowInHUD 1\\n    -isFiltered 0\\n    -colorResolution 256 256 \\n    -bumpResolution 512 512 \\n    -textureCompression 0\\n    -transparencyAlgorithm \\\"frontAndBackCull\\\" \\n    -transpInShadows 0\\n    -cullingOverride \\\"none\\\" \\n    -lowQualityLighting 0\\n    -maximumNumHardwareLights 1\\n    -occlusionCulling 0\\n    -shadingModel 0\\n    -useBaseRenderer 0\\n    -useReducedRenderer 0\\n    -smallObjectCulling 0\\n    -smallObjectThreshold -1 \\n    -interactiveDisableShadows 0\\n    -interactiveBackFaceCull 0\\n    -sortTransparent 1\\n    -controllers 1\\n    -nurbsCurves 1\\n    -nurbsSurfaces 1\\n    -polymeshes 1\\n    -subdivSurfaces 1\\n    -planes 1\\n    -lights 1\\n    -cameras 1\\n    -controlVertices 1\\n    -hulls 1\\n    -grid 0\\n    -imagePlane 1\\n    -joints 1\\n    -ikHandles 1\\n    -deformers 1\\n    -dynamics 1\\n    -particleInstancers 1\\n    -fluids 1\\n    -hairSystems 1\\n    -follicles 1\\n    -nCloths 1\\n    -nParticles 1\\n    -nRigids 1\\n    -dynamicConstraints 1\\n    -locators 1\\n    -manipulators 1\\n    -pluginShapes 1\\n    -dimensions 1\\n    -handles 1\\n    -pivots 1\\n    -textures 1\\n    -strokes 1\\n    -motionTrails 1\\n    -clipGhosts 1\\n    -greasePencils 1\\n    -shadows 0\\n    -captureSequenceNumber -1\\n    -width 2749\\n    -height 1657\\n    -sceneRenderFilter 0\\n    $editorName;\\nmodelEditor -e -viewSelected 0 $editorName;\\nmodelEditor -e \\n    -pluginObjects \\\"gpuCacheDisplayFilter\\\" 1 \\n    $editorName\"\n"
		+ "\t\t\t\t\t\"modelPanel -edit -l (localizedPanelLabel(\\\"Persp View\\\")) -mbv $menusOkayInPanels  $panelName;\\n$editorName = $panelName;\\nmodelEditor -e \\n    -cam `findStartUpCamera persp` \\n    -useInteractiveMode 0\\n    -displayLights \\\"default\\\" \\n    -displayAppearance \\\"smoothShaded\\\" \\n    -activeOnly 0\\n    -ignorePanZoom 0\\n    -wireframeOnShaded 0\\n    -headsUpDisplay 1\\n    -holdOuts 1\\n    -selectionHiliteDisplay 1\\n    -useDefaultMaterial 0\\n    -bufferMode \\\"double\\\" \\n    -twoSidedLighting 0\\n    -backfaceCulling 0\\n    -xray 0\\n    -jointXray 1\\n    -activeComponentsXray 0\\n    -displayTextures 0\\n    -smoothWireframe 0\\n    -lineWidth 1\\n    -textureAnisotropic 0\\n    -textureHilight 1\\n    -textureSampling 2\\n    -textureDisplay \\\"modulate\\\" \\n    -textureMaxSize 32768\\n    -fogging 0\\n    -fogSource \\\"fragment\\\" \\n    -fogMode \\\"linear\\\" \\n    -fogStart 0\\n    -fogEnd 100\\n    -fogDensity 0.1\\n    -fogColor 0.5 0.5 0.5 1 \\n    -depthOfFieldPreview 1\\n    -maxConstantTransparency 1\\n    -rendererName \\\"vp2Renderer\\\" \\n    -objectFilterShowInHUD 1\\n    -isFiltered 0\\n    -colorResolution 256 256 \\n    -bumpResolution 512 512 \\n    -textureCompression 0\\n    -transparencyAlgorithm \\\"frontAndBackCull\\\" \\n    -transpInShadows 0\\n    -cullingOverride \\\"none\\\" \\n    -lowQualityLighting 0\\n    -maximumNumHardwareLights 1\\n    -occlusionCulling 0\\n    -shadingModel 0\\n    -useBaseRenderer 0\\n    -useReducedRenderer 0\\n    -smallObjectCulling 0\\n    -smallObjectThreshold -1 \\n    -interactiveDisableShadows 0\\n    -interactiveBackFaceCull 0\\n    -sortTransparent 1\\n    -controllers 1\\n    -nurbsCurves 1\\n    -nurbsSurfaces 1\\n    -polymeshes 1\\n    -subdivSurfaces 1\\n    -planes 1\\n    -lights 1\\n    -cameras 1\\n    -controlVertices 1\\n    -hulls 1\\n    -grid 0\\n    -imagePlane 1\\n    -joints 1\\n    -ikHandles 1\\n    -deformers 1\\n    -dynamics 1\\n    -particleInstancers 1\\n    -fluids 1\\n    -hairSystems 1\\n    -follicles 1\\n    -nCloths 1\\n    -nParticles 1\\n    -nRigids 1\\n    -dynamicConstraints 1\\n    -locators 1\\n    -manipulators 1\\n    -pluginShapes 1\\n    -dimensions 1\\n    -handles 1\\n    -pivots 1\\n    -textures 1\\n    -strokes 1\\n    -motionTrails 1\\n    -clipGhosts 1\\n    -greasePencils 1\\n    -shadows 0\\n    -captureSequenceNumber -1\\n    -width 2749\\n    -height 1657\\n    -sceneRenderFilter 0\\n    $editorName;\\nmodelEditor -e -viewSelected 0 $editorName;\\nmodelEditor -e \\n    -pluginObjects \\\"gpuCacheDisplayFilter\\\" 1 \\n    $editorName\"\n"
		+ "\t\t\t\t$configName;\n\n            setNamedPanelLayout (localizedPanelLabel(\"Current Layout\"));\n        }\n\n        panelHistory -e -clear mainPanelHistory;\n        sceneUIReplacement -clear;\n\t}\n\n\ngrid -spacing 1 -size 12 -divisions 1 -displayAxes yes -displayGridLines yes -displayDivisionLines yes -displayPerspectiveLabels no -displayOrthographicLabels no -displayAxesBold yes -perspectiveLabelPosition axis -orthographicLabelPosition edge;\nviewManip -drawCompass 0 -compassAngle 0 -frontParameters \"\" -homeParameters \"\" -selectionLockParameters \"\";\n}\n");
	setAttr ".st" 3;
createNode script -n "sceneConfigurationScriptNode";
	rename -uid "E9A2D1EF-404F-0373-B1A3-7B85E5074CF9";
	setAttr ".b" -type "string" "playbackOptions -min 1 -max 528 -ast 1 -aet 528 ";
	setAttr ".st" 6;
select -ne :time1;
	setAttr ".o" 1;
	setAttr ".unw" 1;
select -ne :hardwareRenderingGlobals;
	setAttr ".otfna" -type "stringArray" 22 "NURBS Curves" "NURBS Surfaces" "Polygons" "Subdiv Surface" "Particles" "Particle Instance" "Fluids" "Strokes" "Image Planes" "UI" "Lights" "Cameras" "Locators" "Joints" "IK Handles" "Deformers" "Motion Trails" "Components" "Hair Systems" "Follicles" "Misc. UI" "Ornaments"  ;
	setAttr ".otfva" -type "Int32Array" 22 0 1 1 1 1 1
		 1 1 1 0 0 0 0 0 0 0 0 0
		 0 0 0 0 ;
	setAttr ".fprt" yes;
select -ne :renderPartition;
	setAttr -s 3 ".st";
select -ne :renderGlobalsList1;
select -ne :defaultShaderList1;
	setAttr -s 6 ".s";
select -ne :postProcessList1;
	setAttr -s 2 ".p";
select -ne :defaultRenderingList1;
select -ne :initialShadingGroup;
	setAttr -s 7 ".dsm";
	setAttr ".ro" yes;
select -ne :initialParticleSE;
	setAttr ".ro" yes;
select -ne :defaultRenderGlobals;
	addAttr -ci true -h true -sn "dss" -ln "defaultSurfaceShader" -dt "string";
	setAttr ".dss" -type "string" "lambert1";
select -ne :defaultResolution;
	setAttr ".pa" 1;
select -ne :hardwareRenderGlobals;
	setAttr ".ctrs" 256;
	setAttr ".btrs" 512;
select -ne :ikSystem;
	setAttr -s 4 ".sol";
connectAttr "Root.s" "HumanoidRootNode.is";
connectAttr "HumanoidRootNode.s" "LowerTorso.is";
connectAttr "LowerTorso.s" "UpperTorso.is";
connectAttr "UpperTorso.s" "Head.is";
connectAttr "polyColorPerVertex8.out" "Hat_AttShape.i";
connectAttr "polyColorPerVertex13.out" "Hair_AttShape.i";
connectAttr "Head.ro" "Head_orientConstraint1.cro";
connectAttr "Head.pim" "Head_orientConstraint1.cpim";
connectAttr "Head.jo" "Head_orientConstraint1.cjo";
connectAttr "Head.is" "Head_orientConstraint1.is";
connectAttr "Head.ro" "Head_orientConstraint2.cro";
connectAttr "Head.pim" "Head_orientConstraint2.cpim";
connectAttr "Head.jo" "Head_orientConstraint2.cjo";
connectAttr "Head.is" "Head_orientConstraint2.is";
connectAttr "UpperTorso.s" "LeftUpperArm.is";
connectAttr "LeftUpperArm.s" "LeftLowerArm.is";
connectAttr "LeftLowerArm.s" "LeftHand.is";
connectAttr "LeftHand.ro" "LeftHand_orientConstraint1.cro";
connectAttr "LeftHand.pim" "LeftHand_orientConstraint1.cpim";
connectAttr "LeftHand.jo" "LeftHand_orientConstraint1.cjo";
connectAttr "LeftHand.is" "LeftHand_orientConstraint1.is";
connectAttr "LeftHand.ro" "LeftHand_orientConstraint2.cro";
connectAttr "LeftHand.pim" "LeftHand_orientConstraint2.cpim";
connectAttr "LeftHand.jo" "LeftHand_orientConstraint2.cjo";
connectAttr "LeftHand.is" "LeftHand_orientConstraint2.is";
connectAttr "LeftLowerArm.ro" "LeftLowerArm_orientConstraint1.cro";
connectAttr "LeftLowerArm.pim" "LeftLowerArm_orientConstraint1.cpim";
connectAttr "LeftLowerArm.jo" "LeftLowerArm_orientConstraint1.cjo";
connectAttr "LeftLowerArm.is" "LeftLowerArm_orientConstraint1.is";
connectAttr "LeftLowerArm.ro" "LeftLowerArm_orientConstraint2.cro";
connectAttr "LeftLowerArm.pim" "LeftLowerArm_orientConstraint2.cpim";
connectAttr "LeftLowerArm.jo" "LeftLowerArm_orientConstraint2.cjo";
connectAttr "LeftLowerArm.is" "LeftLowerArm_orientConstraint2.is";
connectAttr "LeftUpperArm.ro" "LeftUpperArm_orientConstraint1.cro";
connectAttr "LeftUpperArm.pim" "LeftUpperArm_orientConstraint1.cpim";
connectAttr "LeftUpperArm.jo" "LeftUpperArm_orientConstraint1.cjo";
connectAttr "LeftUpperArm.is" "LeftUpperArm_orientConstraint1.is";
connectAttr "LeftUpperArm.ro" "LeftUpperArm_orientConstraint2.cro";
connectAttr "LeftUpperArm.pim" "LeftUpperArm_orientConstraint2.cpim";
connectAttr "LeftUpperArm.jo" "LeftUpperArm_orientConstraint2.cjo";
connectAttr "LeftUpperArm.is" "LeftUpperArm_orientConstraint2.is";
connectAttr "UpperTorso.s" "RightUpperArm.is";
connectAttr "RightUpperArm.s" "RightLowerArm.is";
connectAttr "RightLowerArm.s" "RightHand.is";
connectAttr "RightHand.ro" "RightHand_orientConstraint1.cro";
connectAttr "RightHand.pim" "RightHand_orientConstraint1.cpim";
connectAttr "RightHand.jo" "RightHand_orientConstraint1.cjo";
connectAttr "RightHand.is" "RightHand_orientConstraint1.is";
connectAttr "RightHand.ro" "RightHand_orientConstraint2.cro";
connectAttr "RightHand.pim" "RightHand_orientConstraint2.cpim";
connectAttr "RightHand.jo" "RightHand_orientConstraint2.cjo";
connectAttr "RightHand.is" "RightHand_orientConstraint2.is";
connectAttr "RightLowerArm.ro" "RightLowerArm_orientConstraint1.cro";
connectAttr "RightLowerArm.pim" "RightLowerArm_orientConstraint1.cpim";
connectAttr "RightLowerArm.jo" "RightLowerArm_orientConstraint1.cjo";
connectAttr "RightLowerArm.is" "RightLowerArm_orientConstraint1.is";
connectAttr "RightLowerArm.ro" "RightLowerArm_orientConstraint2.cro";
connectAttr "RightLowerArm.pim" "RightLowerArm_orientConstraint2.cpim";
connectAttr "RightLowerArm.jo" "RightLowerArm_orientConstraint2.cjo";
connectAttr "RightLowerArm.is" "RightLowerArm_orientConstraint2.is";
connectAttr "RightUpperArm.ro" "RightUpperArm_orientConstraint1.cro";
connectAttr "RightUpperArm.pim" "RightUpperArm_orientConstraint1.cpim";
connectAttr "RightUpperArm.jo" "RightUpperArm_orientConstraint1.cjo";
connectAttr "RightUpperArm.is" "RightUpperArm_orientConstraint1.is";
connectAttr "RightUpperArm.ro" "RightUpperArm_orientConstraint2.cro";
connectAttr "RightUpperArm.pim" "RightUpperArm_orientConstraint2.cpim";
connectAttr "RightUpperArm.jo" "RightUpperArm_orientConstraint2.cjo";
connectAttr "RightUpperArm.is" "RightUpperArm_orientConstraint2.is";
connectAttr "polyColorPerVertex2.out" "BodyFront_AttShape.i";
connectAttr "UpperTorso.ro" "UpperTorso_orientConstraint1.cro";
connectAttr "UpperTorso.pim" "UpperTorso_orientConstraint1.cpim";
connectAttr "UpperTorso.jo" "UpperTorso_orientConstraint1.cjo";
connectAttr "UpperTorso.is" "UpperTorso_orientConstraint1.is";
connectAttr "UpperTorso.ro" "UpperTorso_orientConstraint2.cro";
connectAttr "UpperTorso.pim" "UpperTorso_orientConstraint2.cpim";
connectAttr "UpperTorso.jo" "UpperTorso_orientConstraint2.cjo";
connectAttr "UpperTorso.is" "UpperTorso_orientConstraint2.is";
connectAttr "LowerTorso.s" "LeftUpperLeg.is";
connectAttr "LeftUpperLeg.s" "LeftLowerLeg.is";
connectAttr "LeftLowerLeg.s" "LeftFoot.is";
connectAttr "polyColorPerVertex3.out" "LeftFoot_AttShape.i";
connectAttr "LeftFoot.ro" "LeftFoot_orientConstraint1.cro";
connectAttr "LeftFoot.pim" "LeftFoot_orientConstraint1.cpim";
connectAttr "LeftFoot.jo" "LeftFoot_orientConstraint1.cjo";
connectAttr "LeftFoot.is" "LeftFoot_orientConstraint1.is";
connectAttr "LeftFoot.ro" "LeftFoot_orientConstraint2.cro";
connectAttr "LeftFoot.pim" "LeftFoot_orientConstraint2.cpim";
connectAttr "LeftFoot.jo" "LeftFoot_orientConstraint2.cjo";
connectAttr "LeftFoot.is" "LeftFoot_orientConstraint2.is";
connectAttr "LeftLowerLeg.ro" "LeftLowerLeg_orientConstraint1.cro";
connectAttr "LeftLowerLeg.pim" "LeftLowerLeg_orientConstraint1.cpim";
connectAttr "LeftLowerLeg.jo" "LeftLowerLeg_orientConstraint1.cjo";
connectAttr "LeftLowerLeg.is" "LeftLowerLeg_orientConstraint1.is";
connectAttr "LeftLowerLeg.ro" "LeftLowerLeg_orientConstraint2.cro";
connectAttr "LeftLowerLeg.pim" "LeftLowerLeg_orientConstraint2.cpim";
connectAttr "LeftLowerLeg.jo" "LeftLowerLeg_orientConstraint2.cjo";
connectAttr "LeftLowerLeg.is" "LeftLowerLeg_orientConstraint2.is";
connectAttr "LeftUpperLeg.ro" "LeftUpperLeg_orientConstraint1.cro";
connectAttr "LeftUpperLeg.pim" "LeftUpperLeg_orientConstraint1.cpim";
connectAttr "LeftUpperLeg.jo" "LeftUpperLeg_orientConstraint1.cjo";
connectAttr "LeftUpperLeg.is" "LeftUpperLeg_orientConstraint1.is";
connectAttr "LeftUpperLeg.ro" "LeftUpperLeg_orientConstraint2.cro";
connectAttr "LeftUpperLeg.pim" "LeftUpperLeg_orientConstraint2.cpim";
connectAttr "LeftUpperLeg.jo" "LeftUpperLeg_orientConstraint2.cjo";
connectAttr "LeftUpperLeg.is" "LeftUpperLeg_orientConstraint2.is";
connectAttr "LowerTorso.s" "RightUpperLeg.is";
connectAttr "RightUpperLeg.s" "RightLowerLeg.is";
connectAttr "RightLowerLeg.s" "RightFoot.is";
connectAttr "polyColorPerVertex15.out" "RightFoot_AttShape.i";
connectAttr "RightFoot.ro" "RightFoot_orientConstraint1.cro";
connectAttr "RightFoot.pim" "RightFoot_orientConstraint1.cpim";
connectAttr "RightFoot.jo" "RightFoot_orientConstraint1.cjo";
connectAttr "RightFoot.is" "RightFoot_orientConstraint1.is";
connectAttr "RightFoot.ro" "RightFoot_orientConstraint2.cro";
connectAttr "RightFoot.pim" "RightFoot_orientConstraint2.cpim";
connectAttr "RightFoot.jo" "RightFoot_orientConstraint2.cjo";
connectAttr "RightFoot.is" "RightFoot_orientConstraint2.is";
connectAttr "RightLowerLeg.ro" "RightLowerLeg_orientConstraint1.cro";
connectAttr "RightLowerLeg.pim" "RightLowerLeg_orientConstraint1.cpim";
connectAttr "RightLowerLeg.jo" "RightLowerLeg_orientConstraint1.cjo";
connectAttr "RightLowerLeg.is" "RightLowerLeg_orientConstraint1.is";
connectAttr "RightLowerLeg.ro" "RightLowerLeg_orientConstraint2.cro";
connectAttr "RightLowerLeg.pim" "RightLowerLeg_orientConstraint2.cpim";
connectAttr "RightLowerLeg.jo" "RightLowerLeg_orientConstraint2.cjo";
connectAttr "RightLowerLeg.is" "RightLowerLeg_orientConstraint2.is";
connectAttr "RightUpperLeg.ro" "RightUpperLeg_orientConstraint1.cro";
connectAttr "RightUpperLeg.pim" "RightUpperLeg_orientConstraint1.cpim";
connectAttr "RightUpperLeg.jo" "RightUpperLeg_orientConstraint1.cjo";
connectAttr "RightUpperLeg.is" "RightUpperLeg_orientConstraint1.is";
connectAttr "RightUpperLeg.ro" "RightUpperLeg_orientConstraint2.cro";
connectAttr "RightUpperLeg.pim" "RightUpperLeg_orientConstraint2.cpim";
connectAttr "RightUpperLeg.jo" "RightUpperLeg_orientConstraint2.cjo";
connectAttr "RightUpperLeg.is" "RightUpperLeg_orientConstraint2.is";
connectAttr "polyColorPerVertex6.out" "WaistCenter_AttShape.i";
connectAttr "LowerTorso.ro" "LowerTorso_orientConstraint1.cro";
connectAttr "LowerTorso.pim" "LowerTorso_orientConstraint1.cpim";
connectAttr "LowerTorso.jo" "LowerTorso_orientConstraint1.cjo";
connectAttr "LowerTorso.is" "LowerTorso_orientConstraint1.is";
connectAttr "LowerTorso.pim" "LowerTorso_pointConstraint1.cpim";
connectAttr "LowerTorso.rp" "LowerTorso_pointConstraint1.crp";
connectAttr "LowerTorso.rpt" "LowerTorso_pointConstraint1.crt";
connectAttr "LowerTorso.ro" "LowerTorso_orientConstraint2.cro";
connectAttr "LowerTorso.pim" "LowerTorso_orientConstraint2.cpim";
connectAttr "LowerTorso.jo" "LowerTorso_orientConstraint2.cjo";
connectAttr "LowerTorso.is" "LowerTorso_orientConstraint2.is";
connectAttr "LowerTorso.pim" "LowerTorso_pointConstraint2.cpim";
connectAttr "LowerTorso.rp" "LowerTorso_pointConstraint2.crp";
connectAttr "LowerTorso.rpt" "LowerTorso_pointConstraint2.crt";
connectAttr "HumanoidRootNode.ro" "HumanoidRootNode_orientConstraint1.cro";
connectAttr "HumanoidRootNode.pim" "HumanoidRootNode_orientConstraint1.cpim";
connectAttr "HumanoidRootNode.jo" "HumanoidRootNode_orientConstraint1.cjo";
connectAttr "HumanoidRootNode.is" "HumanoidRootNode_orientConstraint1.is";
connectAttr "HumanoidRootNode.ro" "HumanoidRootNode_orientConstraint2.cro";
connectAttr "HumanoidRootNode.pim" "HumanoidRootNode_orientConstraint2.cpim";
connectAttr "HumanoidRootNode.jo" "HumanoidRootNode_orientConstraint2.cjo";
connectAttr "HumanoidRootNode.is" "HumanoidRootNode_orientConstraint2.is";
connectAttr "polyColorPerVertex10.out" "Root_AttShape.i";
connectAttr "Root.ro" "Root_orientConstraint1.cro";
connectAttr "Root.pim" "Root_orientConstraint1.cpim";
connectAttr "Root.jo" "Root_orientConstraint1.cjo";
connectAttr "Root.is" "Root_orientConstraint1.is";
connectAttr "Root.ro" "Root_orientConstraint2.cro";
connectAttr "Root.pim" "Root_orientConstraint2.cpim";
connectAttr "Root.jo" "Root_orientConstraint2.cjo";
connectAttr "Root.is" "Root_orientConstraint2.is";
connectAttr "groupId1.id" "SkinWeightTransferTemplateShape.iog.og[1].gid";
connectAttr "lambert2SG.mwc" "SkinWeightTransferTemplateShape.iog.og[1].gco";
connectAttr "groupId2.id" "SkinWeightTransferTemplateShape.iog.og[3].gid";
connectAttr "lambert2SG.mwc" "SkinWeightTransferTemplateShape.iog.og[3].gco";
connectAttr "skinCluster1GroupId.id" "SkinWeightTransferTemplateShape.iog.og[4].gid"
		;
connectAttr "skinCluster1Set.mwc" "SkinWeightTransferTemplateShape.iog.og[4].gco"
		;
connectAttr "groupId4.id" "SkinWeightTransferTemplateShape.iog.og[5].gid";
connectAttr "tweakSet1.mwc" "SkinWeightTransferTemplateShape.iog.og[5].gco";
connectAttr "skinCluster1.og[0]" "SkinWeightTransferTemplateShape.i";
connectAttr "tweak1.vl[0].vt[0]" "SkinWeightTransferTemplateShape.twl";
relationship "link" ":lightLinker1" ":initialShadingGroup.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" ":initialParticleSE.message" ":defaultLightSet.message";
relationship "link" ":lightLinker1" "lambert2SG.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" ":initialShadingGroup.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" ":initialParticleSE.message" ":defaultLightSet.message";
relationship "shadowLink" ":lightLinker1" "lambert2SG.message" ":defaultLightSet.message";
connectAttr "layerManager.dli[0]" "defaultLayer.id";
connectAttr "renderLayerManager.rlmi[0]" "defaultRenderLayer.rlid";
connectAttr "lambert2.oc" "lambert2SG.ss";
connectAttr "SkinWeightTransferTemplateShape.iog.og[1]" "lambert2SG.dsm" -na;
connectAttr "SkinWeightTransferTemplateShape.iog.og[3]" "lambert2SG.dsm" -na;
connectAttr "groupId1.msg" "lambert2SG.gn" -na;
connectAttr "groupId2.msg" "lambert2SG.gn" -na;
connectAttr "lambert2SG.msg" "materialInfo1.sg";
connectAttr "lambert2.msg" "materialInfo1.m";
connectAttr "polySphere8.out" "polyColorPerVertex8.ip";
connectAttr "polySphere13.out" "polyColorPerVertex13.ip";
connectAttr "polySphere2.out" "polyColorPerVertex2.ip";
connectAttr "polySphere3.out" "polyColorPerVertex3.ip";
connectAttr "polySphere15.out" "polyColorPerVertex15.ip";
connectAttr "polySphere6.out" "polyColorPerVertex6.ip";
connectAttr "polySphere10.out" "polyColorPerVertex10.ip";
connectAttr "skinCluster1GroupParts.og" "skinCluster1.ip[0].ig";
connectAttr "skinCluster1GroupId.id" "skinCluster1.ip[0].gi";
connectAttr "bindPose1.msg" "skinCluster1.bp";
connectAttr "LowerTorso.wm" "skinCluster1.ma[2]";
connectAttr "UpperTorso.wm" "skinCluster1.ma[3]";
connectAttr "Head.wm" "skinCluster1.ma[4]";
connectAttr "LeftUpperArm.wm" "skinCluster1.ma[5]";
connectAttr "LeftLowerArm.wm" "skinCluster1.ma[6]";
connectAttr "LeftHand.wm" "skinCluster1.ma[7]";
connectAttr "RightUpperArm.wm" "skinCluster1.ma[8]";
connectAttr "RightLowerArm.wm" "skinCluster1.ma[9]";
connectAttr "RightHand.wm" "skinCluster1.ma[10]";
connectAttr "LeftUpperLeg.wm" "skinCluster1.ma[11]";
connectAttr "LeftLowerLeg.wm" "skinCluster1.ma[12]";
connectAttr "LeftFoot.wm" "skinCluster1.ma[13]";
connectAttr "RightUpperLeg.wm" "skinCluster1.ma[14]";
connectAttr "RightLowerLeg.wm" "skinCluster1.ma[15]";
connectAttr "RightFoot.wm" "skinCluster1.ma[16]";
connectAttr "LowerTorso.liw" "skinCluster1.lw[2]";
connectAttr "UpperTorso.liw" "skinCluster1.lw[3]";
connectAttr "Head.liw" "skinCluster1.lw[4]";
connectAttr "LeftUpperArm.liw" "skinCluster1.lw[5]";
connectAttr "LeftLowerArm.liw" "skinCluster1.lw[6]";
connectAttr "LeftHand.liw" "skinCluster1.lw[7]";
connectAttr "RightUpperArm.liw" "skinCluster1.lw[8]";
connectAttr "RightLowerArm.liw" "skinCluster1.lw[9]";
connectAttr "RightHand.liw" "skinCluster1.lw[10]";
connectAttr "LeftUpperLeg.liw" "skinCluster1.lw[11]";
connectAttr "LeftLowerLeg.liw" "skinCluster1.lw[12]";
connectAttr "LeftFoot.liw" "skinCluster1.lw[13]";
connectAttr "RightUpperLeg.liw" "skinCluster1.lw[14]";
connectAttr "RightLowerLeg.liw" "skinCluster1.lw[15]";
connectAttr "RightFoot.liw" "skinCluster1.lw[16]";
connectAttr "LowerTorso.obcc" "skinCluster1.ifcl[2]";
connectAttr "UpperTorso.obcc" "skinCluster1.ifcl[3]";
connectAttr "Head.obcc" "skinCluster1.ifcl[4]";
connectAttr "LeftUpperArm.obcc" "skinCluster1.ifcl[5]";
connectAttr "LeftLowerArm.obcc" "skinCluster1.ifcl[6]";
connectAttr "LeftHand.obcc" "skinCluster1.ifcl[7]";
connectAttr "RightUpperArm.obcc" "skinCluster1.ifcl[8]";
connectAttr "RightLowerArm.obcc" "skinCluster1.ifcl[9]";
connectAttr "RightHand.obcc" "skinCluster1.ifcl[10]";
connectAttr "LeftUpperLeg.obcc" "skinCluster1.ifcl[11]";
connectAttr "LeftLowerLeg.obcc" "skinCluster1.ifcl[12]";
connectAttr "LeftFoot.obcc" "skinCluster1.ifcl[13]";
connectAttr "RightUpperLeg.obcc" "skinCluster1.ifcl[14]";
connectAttr "RightLowerLeg.obcc" "skinCluster1.ifcl[15]";
connectAttr "RightFoot.obcc" "skinCluster1.ifcl[16]";
connectAttr "UpperTorso.msg" "skinCluster1.ptt";
connectAttr "SkinWeightTransferTemplateShapeOrig.w" "groupParts1.ig";
connectAttr "groupId1.id" "groupParts1.gi";
connectAttr "groupParts1.og" "groupParts2.ig";
connectAttr "groupId2.id" "groupParts2.gi";
connectAttr "groupParts4.og" "tweak1.ip[0].ig";
connectAttr "groupId4.id" "tweak1.ip[0].gi";
connectAttr "skinCluster1GroupId.msg" "skinCluster1Set.gn" -na;
connectAttr "SkinWeightTransferTemplateShape.iog.og[4]" "skinCluster1Set.dsm" -na
		;
connectAttr "skinCluster1.msg" "skinCluster1Set.ub[0]";
connectAttr "tweak1.og[0]" "skinCluster1GroupParts.ig";
connectAttr "skinCluster1GroupId.id" "skinCluster1GroupParts.gi";
connectAttr "groupId4.msg" "tweakSet1.gn" -na;
connectAttr "SkinWeightTransferTemplateShape.iog.og[5]" "tweakSet1.dsm" -na;
connectAttr "tweak1.msg" "tweakSet1.ub[0]";
connectAttr "groupParts2.og" "groupParts4.ig";
connectAttr "groupId4.id" "groupParts4.gi";
connectAttr "Root.msg" "bindPose1.m[1]";
connectAttr "HumanoidRootNode.msg" "bindPose1.m[2]";
connectAttr "LowerTorso.msg" "bindPose1.m[3]";
connectAttr "UpperTorso.msg" "bindPose1.m[4]";
connectAttr "Head.msg" "bindPose1.m[5]";
connectAttr "LeftUpperArm.msg" "bindPose1.m[6]";
connectAttr "LeftLowerArm.msg" "bindPose1.m[7]";
connectAttr "LeftHand.msg" "bindPose1.m[8]";
connectAttr "RightUpperArm.msg" "bindPose1.m[9]";
connectAttr "RightLowerArm.msg" "bindPose1.m[10]";
connectAttr "RightHand.msg" "bindPose1.m[11]";
connectAttr "LeftUpperLeg.msg" "bindPose1.m[12]";
connectAttr "LeftLowerLeg.msg" "bindPose1.m[13]";
connectAttr "LeftFoot.msg" "bindPose1.m[14]";
connectAttr "RightUpperLeg.msg" "bindPose1.m[15]";
connectAttr "RightLowerLeg.msg" "bindPose1.m[16]";
connectAttr "RightFoot.msg" "bindPose1.m[17]";
connectAttr "bindPose1.w" "bindPose1.p[0]";
connectAttr "bindPose1.m[0]" "bindPose1.p[1]";
connectAttr "bindPose1.m[1]" "bindPose1.p[2]";
connectAttr "bindPose1.m[2]" "bindPose1.p[3]";
connectAttr "bindPose1.m[3]" "bindPose1.p[4]";
connectAttr "bindPose1.m[4]" "bindPose1.p[5]";
connectAttr "bindPose1.m[4]" "bindPose1.p[6]";
connectAttr "bindPose1.m[6]" "bindPose1.p[7]";
connectAttr "bindPose1.m[7]" "bindPose1.p[8]";
connectAttr "bindPose1.m[4]" "bindPose1.p[9]";
connectAttr "bindPose1.m[9]" "bindPose1.p[10]";
connectAttr "bindPose1.m[10]" "bindPose1.p[11]";
connectAttr "bindPose1.m[3]" "bindPose1.p[12]";
connectAttr "bindPose1.m[12]" "bindPose1.p[13]";
connectAttr "bindPose1.m[13]" "bindPose1.p[14]";
connectAttr "bindPose1.m[3]" "bindPose1.p[15]";
connectAttr "bindPose1.m[15]" "bindPose1.p[16]";
connectAttr "bindPose1.m[16]" "bindPose1.p[17]";
connectAttr "Root.bps" "bindPose1.wm[1]";
connectAttr "HumanoidRootNode.bps" "bindPose1.wm[2]";
connectAttr "LowerTorso.bps" "bindPose1.wm[3]";
connectAttr "UpperTorso.bps" "bindPose1.wm[4]";
connectAttr "Head.bps" "bindPose1.wm[5]";
connectAttr "LeftUpperArm.bps" "bindPose1.wm[6]";
connectAttr "LeftLowerArm.bps" "bindPose1.wm[7]";
connectAttr "LeftHand.bps" "bindPose1.wm[8]";
connectAttr "RightUpperArm.bps" "bindPose1.wm[9]";
connectAttr "RightLowerArm.bps" "bindPose1.wm[10]";
connectAttr "RightHand.bps" "bindPose1.wm[11]";
connectAttr "LeftUpperLeg.bps" "bindPose1.wm[12]";
connectAttr "LeftLowerLeg.bps" "bindPose1.wm[13]";
connectAttr "LeftFoot.bps" "bindPose1.wm[14]";
connectAttr "RightUpperLeg.bps" "bindPose1.wm[15]";
connectAttr "RightLowerLeg.bps" "bindPose1.wm[16]";
connectAttr "RightFoot.bps" "bindPose1.wm[17]";
connectAttr "lambert2SG.pa" ":renderPartition.st" -na;
connectAttr "lambert2.msg" ":defaultShaderList1.s" -na;
connectAttr "defaultRenderLayer.msg" ":defaultRenderingList1.r" -na;
connectAttr "BodyFront_AttShape.iog" ":initialShadingGroup.dsm" -na;
connectAttr "LeftFoot_AttShape.iog" ":initialShadingGroup.dsm" -na;
connectAttr "WaistCenter_AttShape.iog" ":initialShadingGroup.dsm" -na;
connectAttr "Hat_AttShape.iog" ":initialShadingGroup.dsm" -na;
connectAttr "Root_AttShape.iog" ":initialShadingGroup.dsm" -na;
connectAttr "Hair_AttShape.iog" ":initialShadingGroup.dsm" -na;
connectAttr "RightFoot_AttShape.iog" ":initialShadingGroup.dsm" -na;
dataStructure -fmt "raw" -as "name=Blur3dMetaData:string=Blur3dValue";
// End of Skin_Weight_Transfer_Template_001.ma
