class_name HitAndRunEnemyBehaviour

extends Resource

@export var startState = "run"
@export var surroundRadius = 750
@export var closestRadius = 50

func behave(ship, delta):
	if ship.state == "idle":
		ship.state = "choosing next destination"

        #must be here, if not new destination will be picked like every frame when state == "run"
		ship.previousLocation = ship.global_position
		ship.destination = ship.random_point_in_sphere_surface(ship.player.global_position, surroundRadius)

		ship.state = "attack"

	elif ship.state == "attack":
		ship.lookAtButSmooth(ship.player.global_position, delta)
		
		var moveVector = (ship.player.global_position - ship.global_position).normalized()
		ship.velocity = ship.velocity.lerp(moveVector * ship.maxSpeed, delta * ship.acceleration)

		if ship.global_position.distance_to(ship.player.global_position) < closestRadius:
			ship.state = "run"

		if ship.rayCast.is_colliding():
			var collided_object = ship.rayCast.get_collider()  

			if collided_object.is_in_group("player"):
				ship.shoot(1)

	elif ship.state == "run":


		ship.lookAtButSmooth(ship.destination, delta)

		if ship.destination.distance_to(ship.global_position) < ship.stoppingDistance:

			ship.velocity = Vector3.ZERO
			ship.speed = 0

			ship.state = "idle"

		else:

			var moveVector = (ship.destination-ship.global_position).normalized()
			ship.velocity = ship.velocity.lerp(moveVector * ship.maxSpeed, delta * ship.acceleration)
