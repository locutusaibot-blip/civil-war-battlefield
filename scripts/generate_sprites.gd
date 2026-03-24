@tool
extends EditorScript

# Run this in Godot editor to generate pixel art sprites

const SPRITE_SIZE = 32

func _run():
	print("Generating pixel art sprites...")
	
	# Create output directory
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("assets/sprites"):
		dir.make_dir_recursive("assets/sprites")
	
	# Generate sprites
	generate_infantry()
	generate_cavalry()
	generate_artillery()
	generate_projectile()
	
	print("Sprites generated in assets/sprites/")

func generate_infantry():
	var img = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))  # Transparent background
	
	# Colors
	var uniform_color = Color(0.15, 0.35, 0.6, 1.0)  # Union blue
	var skin_color = Color(0.85, 0.7, 0.55, 1.0)
	var hat_color = Color(0.2, 0.2, 0.25, 1.0)
	var rifle_color = Color(0.4, 0.25, 0.15, 1.0)
	var belt_color = Color(0.5, 0.4, 0.2, 1.0)
	
	# Draw infantry (standing with rifle)
	# Body (8x10 rectangle centered)
	for x in range(12, 20):
		for y in range(14, 24):
			img.set_pixel(x, y, uniform_color)
	
	# Head (6x6 circle-ish)
	for x in range(13, 19):
		for y in range(8, 14):
			img.set_pixel(x, y, skin_color)
	
	# Hat (8x4 on top of head)
	for x in range(12, 20):
		for y in range(6, 10):
			img.set_pixel(x, y, hat_color)
	# Hat brim
	for x in range(11, 21):
		img.set_pixel(x, 9, hat_color)
	
	# Rifle (vertical line on right side)
	for y in range(10, 28):
		img.set_pixel(21, y, rifle_color)
		img.set_pixel(22, y, rifle_color)
	# Rifle stock
	for y in range(24, 28):
		for x in range(20, 23):
			img.set_pixel(x, y, rifle_color)
	# Bayonet
	for y in range(8, 10):
		img.set_pixel(21, y, Color(0.7, 0.7, 0.75, 1.0))
		img.set_pixel(22, y, Color(0.7, 0.7, 0.75, 1.0))
	
	# Belt
	for x in range(12, 20):
		img.set_pixel(x, 20, belt_color)
	# Belt buckle
	img.set_pixel(15, 20, Color(0.8, 0.7, 0.3, 1.0))
	img.set_pixel(16, 20, Color(0.8, 0.7, 0.3, 1.0))
	
	# Legs
	for y in range(24, 30):
		img.set_pixel(13, y, uniform_color)
		img.set_pixel(14, y, uniform_color)
		img.set_pixel(17, y, uniform_color)
		img.set_pixel(18, y, uniform_color)
	
	# Boots
	for x in range(12, 15):
		img.set_pixel(x, 30, Color(0.15, 0.1, 0.08, 1.0))
	for x in range(17, 20):
		img.set_pixel(x, 30, Color(0.15, 0.1, 0.08, 1.0))
	
	img.save_png("res://assets/sprites/infantry_union.png")
	
	# Create Confederate version (grey uniform)
	var img_conf = img.duplicate()
	for x in range(SPRITE_SIZE):
		for y in range(SPRITE_SIZE):
			var pixel = img_conf.get_pixel(x, y)
			if pixel == uniform_color:
				img_conf.set_pixel(x, y, Color(0.45, 0.45, 0.5, 1.0))  # Confederate grey
	img_conf.save_png("res://assets/sprites/infantry_confederate.png")

func generate_cavalry():
	var img = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var uniform_color = Color(0.15, 0.35, 0.6, 1.0)
	var horse_color = Color(0.6, 0.4, 0.2, 1.0)
	var horse_mane = Color(0.2, 0.15, 0.1, 1.0)
	var skin_color = Color(0.85, 0.7, 0.55, 1.0)
	var hat_color = Color(0.2, 0.2, 0.25, 1.0)
	var saber_color = Color(0.8, 0.8, 0.85, 1.0)
	
	# Horse body (larger, fills more space)
	# Main body
	for x in range(8, 26):
		for y in range(16, 24):
			img.set_pixel(x, y, horse_color)
	
	# Horse neck (angled up-left)
	for i in range(8):
		var x = 7 + i
		var y = 16 - i
		for dy in range(4):
			for dx in range(3):
				if x + dx < SPRITE_SIZE and y + dy < SPRITE_SIZE:
					img.set_pixel(x + dx, y + dy, horse_color)
	
	# Horse head
	for x in range(14, 20):
		for y in range(6, 12):
			img.set_pixel(x, y, horse_color)
	# Snout
	for x in range(18, 22):
		for y in range(8, 11):
			img.set_pixel(x, y, horse_color)
	
	# Mane
	for y in range(8, 16):
		img.set_pixel(13, y, horse_mane)
		img.set_pixel(14, y, horse_mane)
	
	# Legs
	var leg_positions = [(10, 24), (12, 24), (20, 24), (22, 24)]
	for pos in leg_positions:
		for y in range(24, 30):
			img.set_pixel(pos[0], y, horse_color)
			img.set_pixel(pos[0] + 1, y, horse_color)
		# Hooves
		img.set_pixel(pos[0], 30, Color(0.3, 0.2, 0.15, 1.0))
		img.set_pixel(pos[0] + 1, 30, Color(0.3, 0.2, 0.15, 1.0))
	
	# Rider body (smaller, on top)
	for x in range(13, 19):
		for y in range(12, 18):
			img.set_pixel(x, y, uniform_color)
	
	# Rider head
	for x in range(14, 18):
		for y in range(8, 12):
			img.set_pixel(x, y, skin_color)
	
	# Rider hat
	for x in range(13, 19):
		for y in range(6, 9):
			img.set_pixel(x, y, hat_color)
	# Brim
	for x in range(14, 20):
		img.set_pixel(x, 9, hat_color)
	
	# Saber (raised)
	for i in range(12):
		var x = 19 + i
		var y = 10 - i
		if x < SPRITE_SIZE and y >= 0:
			img.set_pixel(x, y, saber_color)
			if x + 1 < SPRITE_SIZE:
				img.set_pixel(x + 1, y, saber_color)
	
	img.save_png("res://assets/sprites/cavalry_union.png")
	
	# Confederate version
	var img_conf = img.duplicate()
	for x in range(SPRITE_SIZE):
		for y in range(SPRITE_SIZE):
			var pixel = img_conf.get_pixel(x, y)
			if pixel == uniform_color:
				img_conf.set_pixel(x, y, Color(0.45, 0.45, 0.5, 1.0))
	img_conf.save_png("res://assets/sprites/cavalry_confederate.png")

func generate_artillery():
	var img = Image.create(SPRITE_SIZE, SPRITE_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var uniform_color = Color(0.15, 0.35, 0.6, 1.0)
	var cannon_color = Color(0.25, 0.25, 0.3, 1.0)
	var bronze_color = Color(0.6, 0.4, 0.2, 1.0)
	var wheel_color = Color(0.4, 0.25, 0.15, 1.0)
	var skin_color = Color(0.85, 0.7, 0.55, 1.0)
	
	# Large cannon barrel (angled)
	for i in range(20):
		var x = 6 + i
		var y = 16 + (i / 5)
		if x < SPRITE_SIZE and y < SPRITE_SIZE:
			for dy in range(4):
				if y + dy < SPRITE_SIZE:
					img.set_pixel(x, int(y) + dy, cannon_color)
	
	# Cannon muzzle (bronze ring)
	for y in range(16, 22):
		img.set_pixel(25, y, bronze_color)
		img.set_pixel(26, y, bronze_color)
	
	# Cannon base/carriage
	for x in range(10, 22):
		for y in range(20, 24):
			img.set_pixel(x, y, cannon_color)
	
	# Large wheels (2 wheels, one behind)
	# Back wheel
	for angle in range(360):
		var rad = deg_to_rad(angle)
		var wx = int(10 + cos(rad) * 6)
		var wy = int(24 + sin(rad) * 6)
		if wx >= 0 and wx < SPRITE_SIZE and wy >= 0 and wy < SPRITE_SIZE:
			if wy >= 24:
				img.set_pixel(wx, wy, wheel_color)
				img.set_pixel(wx + 1, wy, wheel_color)
	
	# Front wheel
	for angle in range(360):
		var rad = deg_to_rad(angle)
		var wx = int(20 + cos(rad) * 6)
		var wy = int(24 + sin(rad) * 6)
		if wx >= 0 and wx < SPRITE_SIZE and wy >= 0 and wy < SPRITE_SIZE:
			if wy >= 24:
				img.set_pixel(wx, wy, wheel_color)
				img.set_pixel(wx + 1, wy, wheel_color)
	
	# Artillery crew member (standing beside cannon)
	# Body
	for x in range(26, 30):
		for y in range(16, 24):
			img.set_pixel(x, y, uniform_color)
	
	# Head
	for x in range(27, 29):
		for y in range(13, 16):
			img.set_pixel(x, y, skin_color)
	
	# Legs
	for y in range(24, 30):
		img.set_pixel(26, y, uniform_color)
		img.set_pixel(27, y, uniform_color)
		img.set_pixel(28, y, uniform_color)
		img.set_pixel(29, y, uniform_color)
	
	# Ramrod/tool in hand
	for y in range(14, 22):
		img.set_pixel(30, y, Color(0.4, 0.25, 0.15, 1.0))
	
	img.save_png("res://assets/sprites/artillery_union.png")
	
	# Confederate version
	var img_conf = img.duplicate()
	for x in range(SPRITE_SIZE):
		for y in range(SPRITE_SIZE):
			var pixel = img_conf.get_pixel(x, y)
			if pixel == uniform_color:
				img_conf.set_pixel(x, y, Color(0.45, 0.45, 0.5, 1.0))
	img_conf.save_png("res://assets/sprites/artillery_confederate.png")

func generate_projectile():
	var img = Image.create(16, 16, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	# Cannonball (simple circle)
	var ball_color = Color(0.15, 0.15, 0.15, 1.0)
	var highlight = Color(0.4, 0.4, 0.4, 1.0)
	
	for x in range(16):
		for y in range(16):
			var dx = x - 8
			var dy = y - 8
			var dist = sqrt(dx * dx + dy * dy)
			if dist < 5:
				img.set_pixel(x, y, ball_color)
			elif dist < 6:
				img.set_pixel(x, y, Color(0.1, 0.1, 0.1, 1.0))
			
	# Highlight
	img.set_pixel(6, 6, highlight)
	img.set_pixel(7, 6, highlight)
	img.set_pixel(6, 7, highlight)
	
	img.save_png("res://assets/sprites/cannonball.png")
