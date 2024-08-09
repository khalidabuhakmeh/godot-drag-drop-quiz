extends CPUParticles2D

@export var explode: bool:
	set(value):
		emitting = value
		$CPUParticles2D.emitting = value
		$CPUParticles2D2.emitting = value
