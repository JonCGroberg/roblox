--!strict
export type Resource = {
	id: string,
	name: string,
	basePrice: number,
	type: "raw" | "processed" | "special",
}

export type Facility = {
	id: string,
	type: string,
	position: Vector3,
	rotation: Vector3,
	inputBuffer: { [string]: number },
	outputBuffer: { [string]: number },
	processingRate: number,
	efficiency: number,
}

export type Bot = {
	id: string,
	facilityId: string,
	position: Vector3,
	target: Vector3?,
	carrying: { [string]: number },
	speed: number,
	state: "idle" | "moving" | "loading" | "unloading",
}

-- types are still exposed even with nil due to export
return nil
