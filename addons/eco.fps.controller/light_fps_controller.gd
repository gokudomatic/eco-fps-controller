
extends KinematicBody


var _is_loaded = false
var velocity=Vector3()
var yaw = 0
var pitch = 0
var is_moving=false
var on_floor=false
var jump_timeout=0
var step_timeout=0
var fly_mode=false
var alive=true
var is_jumping=false
var is_running=false
var is_crouching=false
var body_position="stand"
var jump_strength=9

var node_camera=null
var node_leg=null
var node_yaw=null
var node_body=null
var node_head_check=null
var node_action_ray=null
var node_ray = null
var node_step_ray=null


var aim_offset=Vector3(0,1.5,0)

const GRAVITY_FACTOR=3

# params
export(bool) var active=true setget _set_active
export(float) var walk_speed=15
export(float) var run_factor=3
export(float) var crouch_factor=0.2

## dimensions
export(float) var leg_length=0.4 setget _set_leg_length
export(float) var body_radius=0.6 setget _set_body_radius
export(float) var body_height=0.8 setget _set_body_height
export(float) var camera_height=1.7 setget _set_camera_height
export(float) var action_range=2 setget _set_action_range

## actions
export(String) var action_forward="ui_up"
export(String) var action_backward="ui_down"
export(String) var action_left="ui_left"
export(String) var action_right="ui_right"
export(String) var action_action1="ui_action1"
export(String) var action_jump="ui_jump"
export(String) var action_use="ui_select"

## physics
export(float) var ACCEL= 2
export(float) var DEACCEL= 4 
export(float) var FLY_SPEED=100
export(float) var FLY_ACCEL=4
export(float) var GRAVITY=-9.8
export(float) var MAX_JUMP_TIMEOUT=0.2
export(float) var MAX_ATTACK_TIMEOUT=0.2
export(int) var MAX_SLOPE_ANGLE = 40
export(float) var STAIR_RAYCAST_HEIGHT=0.75
export(float) var STAIR_RAYCAST_DISTANCE=0.58
export(float) var STAIR_JUMP_SPEED=5
export(float) var STAIR_JUMP_TIMEOUT=0.1
export(float) var footstep_factor=0.004
export(float) var view_sensitivity = 0.3

#################################################################################3

# initializer
func _ready():

	_build_structure()

	_is_loaded=true
	
	_update_params()
	
	node_action_ray.add_exception(self)
	
	set_fixed_process(true)
	set_process_input(true)

func _build_structure():
	# collision
	var body=CollisionShape.new()
	body.set_transform(Transform(Vector3(1,0,0),Vector3(0,0,-1),Vector3(0,1,0),Vector3(0,1.4,0)))
	var body_shape=CapsuleShape.new()
	body_shape.set_radius(0.6)
	body_shape.set_height(0.8)
	body.set_shape(body_shape)
	add_child(body)
	
	var leg=CollisionShape.new()
	leg.set_transform(Transform(Vector3(1,0,0),Vector3(0,1,0),Vector3(0,0,1),Vector3(0,0,1)))
	var leg_shape=RayShape.new()
	leg_shape.set_length(0.4)
	leg.set_shape(leg_shape)
	body.add_child(leg)
	
	# camera
	var yaw=Spatial.new()
	add_child(yaw)
	
	var camera=Camera.new()
	camera.set_translation(Vector3(0,1.7,0))
	yaw.add_child(camera)
	
	var actionRay=RayCast.new()
	actionRay.set_enabled(true)
	actionRay.set_cast_to(Vector3(0,0,-2))
	camera.add_child(actionRay)
	
	# walking rays
	var wallRay=RayCast.new()
	wallRay.set_enabled(true)
	wallRay.set_cast_to(Vector3(0,-0.8,0))
	wallRay.set_translation(Vector3(0,0.4,0))
	add_child(wallRay)
	
	var stepRay=RayCast.new()
	stepRay.set_enabled(true)
	stepRay.set_cast_to(Vector3(0,-0.5,0))
	stepRay.set_translation(Vector3(0,0.75,-0.58))
	add_child(stepRay)
	
	# head collision check (for crouching)
	var head_area=Area.new()
	head_area.set_enable_monitoring(false)
	head_area.set_monitorable(false)
	head_area.set_translation(Vector3(0,2.2186,0))
	add_child(head_area)
	
	var head_col_shape=CollisionShape.new()
	var head_shape=SphereShape.new()
	head_shape.set_radius(0.2)
	head_col_shape.set_shape(head_shape)
	head_area.add_child(head_col_shape)
	
	# make links
	node_camera=camera
	node_leg=leg
	node_yaw=yaw
	node_body=body
	node_head_check=head_area
	node_action_ray=actionRay
	node_ray=wallRay
	node_step_ray=stepRay

func _update_params():
	_set_active(active)
	_set_leg_length(leg_length)
	_set_body_radius(body_radius)
	_set_body_height(body_height)
	_set_camera_height(camera_height)
	_set_action_range(action_range)

func notify_attribute_change(key,value):
	emit_signal("attribute_changed",key,value)

func _embed_children():
	var children=self.get_children()
	for child in children:
		if child.get_name().left(4)=="eco_":
			continue
		else:
			remove_child(child)
			node_camera.add_child(child)

# Keys and mouse handler
func _input(ie):
	if not active:
		return
	
	if ie.type == InputEvent.MOUSE_MOTION:
		yaw = fmod(yaw - ie.relative_x * view_sensitivity, 360)
		pitch = max(min(pitch - ie.relative_y * view_sensitivity, 90), -90)
		node_yaw.set_rotation(Vector3(0, deg2rad(yaw), 0))
		node_camera.set_rotation(Vector3(deg2rad(pitch), 0, 0))
	
	if ie.type == InputEvent.KEY:
		if Input.is_action_pressed(action_use):
			var ray=node_action_ray
			if ray.is_colliding():
				var obj=ray.get_collider()
				if obj.has_method("use"):
					obj.use(self)
		if Input.is_action_pressed("ui_toggle_crouch"):
			if body_position=="crouch":
				stand()
				body_position="stand"
			else:
				crouch()
				body_position="crouch"

# main loop
func _fixed_process(delta):
	
	if fly_mode:
		_fly(delta)
	else:
		_walk(delta)

func _enter_tree():
	if active:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _fly(delta):
	# read the rotation of the camera
	var aim = node_camera.get_global_transform().basis
	# calculate the direction where the player want to move
	var direction = Vector3()
	if Input.is_action_pressed(action_forward):
		direction -= aim[2]
	if Input.is_action_pressed(action_backward):
		direction += aim[2]
	if Input.is_action_pressed(action_left):
		direction -= aim[0]
	if Input.is_action_pressed(action_right):
		direction += aim[0]
	
	direction = direction.normalized()
		
	# calculate the target where the player want to move
	var target=direction*FLY_SPEED
	
	# calculate the velocity to move the player toward the target
	velocity=Vector3().linear_interpolate(target,FLY_ACCEL*delta)
	
	# move the node
	var motion=velocity*delta
	motion=move(motion)
	
	# slide until it doesn't need to slide anymore, or after n times
	var original_vel=velocity
	var attempts=4 # number of attempts to slide the node
	
	while(attempts and is_colliding()):
		var n=get_collision_normal()
		motion=n.slide(motion)
		velocity=n.slide(velocity)
		# check that the resulting velocity is not opposite to the original velocity, which would mean moving backward.
		if(original_vel.dot(velocity)>0):
			motion=move(motion)
			if (motion.length()<0.001):
				break
		attempts-=1

func _walk(delta):
	
	# process timers
	if jump_timeout>0:
		jump_timeout-=delta
	
	# read the rotation of the camera
	var aim = node_camera.get_global_transform().basis
	# calculate the direction where the player want to move
	var direction = Vector3()
	if Input.is_action_pressed(action_forward):
		direction -= aim[2]
	if Input.is_action_pressed(action_backward):
		direction += aim[2]
	if Input.is_action_pressed(action_left):
		direction -= aim[0]
	if Input.is_action_pressed(action_right):
		direction += aim[0]
	
	is_running=Input.is_action_pressed("ui_run")
	
	var crouch_mode=body_position=="crouch"
	var is_crouch_pressed=Input.is_action_pressed("ui_crouch")

	if is_crouching and (crouch_mode==is_crouch_pressed):
		stand()
	elif not is_crouching and (crouch_mode!=is_crouch_pressed):
		crouch()
	
	#reset the flag for actor's movement state
	is_moving=(direction.length()>0)
	
	direction.y=0
	direction = direction.normalized()
	
	# clamp to ground if not jumping. Check only the first time a collision is detected (landing from a fall)
	var is_ray_colliding=node_ray.is_colliding()
	if !on_floor and jump_timeout<=0 and is_ray_colliding:
		set_translation(node_ray.get_collision_point())
		on_floor=true
	elif on_floor and not is_ray_colliding:
		# check that flag on_floor still reflects the state of the ray.
		on_floor=false
	
	if on_floor:
		if step_timeout<=0:
			step_timeout=1
		else:
			step_timeout-=velocity.length()*footstep_factor
		
		# if on floor move along the floor. To do so, we calculate the velocity perpendicular to the normal of the floor.
		var n=node_ray.get_collision_normal()
		velocity=velocity-velocity.dot(n)*n
		
		# if the character is in front of a stair, and if the step is flat enough, jump to the step.
		if is_moving and node_step_ray.is_colliding():
			var step_normal=node_step_ray.get_collision_normal()
			if (rad2deg(acos(step_normal.dot(Vector3(0,1,0))))< MAX_SLOPE_ANGLE):
				velocity.y=STAIR_JUMP_SPEED
				jump_timeout=STAIR_JUMP_TIMEOUT
		
		# apply gravity if on a slope too steep
		if (rad2deg(acos(n.dot(Vector3(0,1,0))))> MAX_SLOPE_ANGLE):
			velocity.y+=delta*GRAVITY*GRAVITY_FACTOR
	else:
		# apply gravity if falling
		velocity.y+=delta*GRAVITY*GRAVITY_FACTOR
	
	# calculate the target where the player want to move
	var target=direction*get_walk_speed(is_crouching,is_running)
	# if the character is moving, he must accelerate. Otherwise he deccelerates.
	var accel=DEACCEL
	if is_moving:
		accel=ACCEL
	
	# calculate velocity's change
	var hvel=velocity
	hvel.y=0
	
	# calculate the velocity to move toward the target, but only on the horizontal plane XZ
	hvel=hvel.linear_interpolate(target,accel*delta)
	velocity.x=hvel.x
	velocity.z=hvel.z
	
	# move the node
	var motion=velocity*delta
	motion=move(motion)
	
	# slide until it doesn't need to slide anymore, or after n times
	var original_vel=velocity
	if(motion.length()>0 and is_colliding()):
		var n=get_collision_normal()
		motion=n.slide(motion)
		velocity=n.slide(velocity)
		# check that the resulting velocity is not opposite to the original velocity, which would mean moving backward.
		if(original_vel.dot(velocity)>0):
			motion=move(motion)
	
	if on_floor:
		# move with floor but don't change the velocity.
		var floor_velocity=_get_floor_velocity(node_ray,delta)
		if floor_velocity.length()!=0:
			move(floor_velocity*delta)
	
		# jump
		if Input.is_action_pressed(action_jump) and body_position=="stand":
			velocity.y=jump_strength
			jump_timeout=MAX_JUMP_TIMEOUT
			on_floor=false
	
	# update the position of the raycast for stairs to where the character is trying to go, so it will cast the ray at the next loop.
	if is_moving:
		var sensor_position=Vector3(direction.z,0,-direction.x)*STAIR_RAYCAST_DISTANCE
		sensor_position.y=STAIR_RAYCAST_HEIGHT
		node_step_ray.set_translation(sensor_position)

func _get_floor_velocity(ray,delta):
	var floor_velocity=Vector3()
	# only static or rigid bodies are considered as floor. If the character is on top of another character, he can be ignored.
	var object = ray.get_collider()
	if object extends RigidBody or object extends StaticBody:
		var point = ray.get_collision_point() - object.get_translation()
		var floor_angular_vel = Vector3()
		# get the floor velocity and rotation depending on the kind of floor
		if object extends RigidBody:
			floor_velocity = object.get_linear_velocity()
			floor_angular_vel = object.get_angular_velocity()
		elif object extends StaticBody:
			floor_velocity = object.get_constant_linear_velocity()
			floor_angular_vel = object.get_constant_angular_velocity()
		# if there's an angular velocity, the floor velocity take it in account too.
		if(floor_angular_vel.length()>0):
			var transform = Matrix3(Vector3(1, 0, 0), floor_angular_vel.x)
			transform = transform.rotated(Vector3(0, 1, 0), floor_angular_vel.y)
			transform = transform.rotated(Vector3(0, 0, 1), floor_angular_vel.z)
			floor_velocity += transform.xform_inv(point) - point
			
			# if the floor has an angular velocity (rotation force), the character must rotate too.
			yaw = fmod(yaw + rad2deg(floor_angular_vel.y) * delta, 360)
			node_yaw.set_rotation(Vector3(0, deg2rad(yaw), 0))
	return floor_velocity


func _on_ladders_body_enter( body ):
	if body==self:
		fly_mode=true

func _on_ladders_body_exit( body ):
	if body==self:
		fly_mode=false

# crouch ########################################################3
func crouch():
	node_body.get_shape().set_height(0.1)
	node_body.get_shape().set_radius(0.1)
	node_body.set_translation(Vector3(0,0.55,0))
	node_camera.set_translation(Vector3(0,0.4,0))
	node_leg.set_translation(Vector3(0,0,0.1))
	is_crouching=true
	node_head_check.set_enable_monitoring(true)
	
func stand():
	if node_head_check.get_overlapping_bodies().size()>0:
		return
	
	node_body.get_shape().set_height(0.8)
	node_body.get_shape().set_radius(0.6)
	node_body.set_translation(Vector3(0,1.4,0))
	node_camera.set_translation(Vector3(0,1.7,0))
	node_leg.set_translation(Vector3(0,0,1))
	is_crouching=false
	node_head_check.set_enable_monitoring(false)


func get_walk_speed(is_crouching,is_running):
	var speed=walk_speed
	if is_crouching:
		speed*=crouch_factor
	if is_running:
		speed*=run_factor
	return speed

# Setter/Getter #################################################################

func _set_leg_length(value):
	leg_length=value
	if _is_loaded:
		node_leg.get_shape().set_length(value)
		node_ray.set_cast_to(Vector3(0,-value*2,0))

func _set_body_radius(value):
	body_radius=value
	if _is_loaded:
		node_body.get_shape().set_radius(value)

func _set_body_height(value):
	body_height=value
	if _is_loaded:
		node_body.get_shape().set_height(value)

func _set_camera_height(value):
	camera_height=value
	if _is_loaded:
		node_camera.set_translation(Vector3(0,value,0))

func _set_action_range(value):
	action_range=value
	if _is_loaded:
		node_action_ray.set_cast_to(Vector3(0,0,-value))

func _set_active(value):
	if value==active:
		return
	
	active=value
	if active:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
