export type EditableMeshMap = {
	[MeshPart]: EditableMesh,
}

export type ProjectionTarget = EditableMesh | WrapTextureTransfer

export type ProjectionTargetMap = {
	[MeshPart]: ProjectionTarget,
}

export type ScaleFactorMap = {
	[MeshPart]: Vector3,
}

return {}
