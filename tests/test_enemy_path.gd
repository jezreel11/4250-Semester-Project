extends Node

# Simple unit test for scripts/enemies/enemypath.gd
# Run with: godot --script res://tests/test_enemy_path.gd

func _ready():
    # Load the enemy path script (it extends PathFollow2D)
    var EnemyPath = load("res://scripts/enemies/enemypath.gd")
    var enemy = EnemyPath.new()

    # Sanity: exported speed must be present and numeric
    assert(typeof(enemy.speed) == TYPE_FLOAT or typeof(enemy.speed) == TYPE_INT)

    # Test 1: calling _process should advance progress by speed * delta
    var start_progress = enemy.progress
    var dt = 0.25
    enemy._process(dt)
    var expected = start_progress + enemy.speed * dt
    # Use small epsilon for floats
    var eps = 0.0001
    assert(abs(enemy.progress - expected) < eps),
        "progress did not advance as expected: got %s expected %s".format(enemy.progress, expected)

    # Test 2: after enough processing, progress_ratio should reach or exceed 1.0
    var max_steps = 10000
    var steps = 0
    while enemy.progress_ratio < 1.0 and steps < max_steps:
        enemy._process(0.1)
        steps += 1

    assert(enemy.progress_ratio >= 1.0), "progress_ratio did not reach 1.0 after %d steps".format(steps)

    print("[TEST PASS] enemypath: progress advances and reaches end of path")
    # Exit Godot with success
    get_tree().quit(0)
