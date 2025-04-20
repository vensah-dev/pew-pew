class_name chaseAndKillEnemyBehaviour

extends Resource

@export var startState = "attack"
@export var surroundRadius = 500
@export var closestRadius = 100

func behave(ship, delta):
    if ship.state == "attack":
        ship.lookAtButSmooth(ship.player.global_position, delta)

        if ship.global_position.distance_to(ship.player.global_position) < closestRadius:
            ship.velocity = ship.velocity.lerp(Vector3.ZERO * ship.maxSpeed, delta * ship.acceleration)
        else:
            ship.moveTo(ship.player.global_position, delta)


        if ship.rayCast.is_colliding():
            var collided_object = ship.rayCast.get_collider()  

            if collided_object.is_in_group("player"):
                ship.shoot(1)
