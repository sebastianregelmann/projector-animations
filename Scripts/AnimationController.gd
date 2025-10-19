extends Node2D

const MQTTConfig = preload("res://Scripts/mqtt_config.gd")
const AnimationCancel = preload("res://Scripts/AnimationCancel.gd")
const AnimationLoop = preload("res://Scripts/AnimationLoop.gd")
const AnimationCount = preload("res://Scripts/AnimationCount.gd")



@export var text_rect: TextureRect

# Duration of one full animation cycle (in seconds)

var textures = [] # Array to store loaded textures
var defaulTexture = [] # Array to store loaded textures

var current_frame := 0 # Current frame index
var time_accumulator := 0.0 # Accumulated time
var frame_duration := 0.0 # Duration of each frame

#settings for the animation
var animationRunning = false 
var animationLooping = false
var animationLoopCounts = 0
var maxAnimationLoops = 0
var animationCountDefaultImage :String
var animation_cycle_duration : float

func _process(delta):
	if not animationRunning or textures.size() == 0:
		return

	# Accumulate time
	time_accumulator += delta

	# Determine if it's time to advance to the next frame
	if time_accumulator >= frame_duration:
		time_accumulator -= frame_duration
		current_frame = (current_frame + 1) % textures.size()
		text_rect.texture = textures[current_frame]

		# If we completed a full animation cycle
		if current_frame == 0:
			if animationLooping:
				# Infinite loop, nothing else to do
				pass
			else:
				# Counted animation
				animationLoopCounts += 1
				if animationLoopCounts >= maxAnimationLoops:
					count_animation_end()



func cancel_animation(cancelConfig: AnimationCancel) -> void:
	#load the image
	defaulTexture = load_default_image(cancelConfig.default_image_path)
	
	#apply Texture
	text_rect.texture = defaulTexture
	#clear old loaded textures
	textures.clear()
	#stop animation playing
	animationRunning = false
	time_accumulator = 0
	current_frame = 0
	animationLoopCounts = 0


func start_loop_animation(loopConfig : AnimationLoop) -> void:
	#load the image
	load_images(loopConfig.images_path)
		
	#calculate frame duration
	animation_cycle_duration = loopConfig.animation_duration
	frame_duration = animation_cycle_duration / textures.size()
	time_accumulator = 0
	current_frame = 0
	animationLoopCounts = 0

	#enable the animation
	animationLooping = true;
	animationRunning = true;

	


func start_count_animation(countConfig: AnimationCount) -> void:
	#load the image
	load_images(countConfig.images_path)
	defaulTexture = load_default_image(countConfig.default_image_path)

		
	#calculate frame duration
	animation_cycle_duration = countConfig.animation_duration
	frame_duration = animation_cycle_duration / textures.size()
	time_accumulator = 0
	current_frame = 0
	
	#enable the animation
	animationLooping = false;
	animationRunning = true;
	
	#reset variables for counting the animaiton loop
	animationLoopCounts = 0
	maxAnimationLoops = countConfig.animation_count


func count_animation_end():
	#apply Texture
	text_rect.texture = defaulTexture
	#clear old loaded textures
	textures.clear()
	#stop animation playing
	animationRunning = false


func load_default_image(path: String):
	var dir := DirAccess.open(path)
	
	#loop over each file
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir():
			# Check if file has a valid image extension
			var ext = file_name.get_extension().to_lower()
			if ext in ["png", "jpg", "jpeg"]:
				return load(path + file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	return null


func load_images(path: String) -> void:
	textures.clear()
	#open folder
	var dir := DirAccess.open(path)
	
	#loop over each file
	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir():
			# Check if file has a valid image extension
			var ext = file_name.get_extension().to_lower()
			if ext in ["png", "jpg", "jpeg"]:
				var tex = load(path + file_name)
				textures.append(tex)
		
		file_name = dir.get_next()
	dir.list_dir_end()
