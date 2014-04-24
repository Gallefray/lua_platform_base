require 'levels'
lurker = require "lib/lurker"
require "lib/AnAL"

function love.load()
	load_img()
	load()
end

function load_img()	
	anim = {}
end

function load()
	screen = {}
	game = {}
	world = {} 
	tween = {l = {}}
	player = {}

	screen.tx = 2
	screen.ty = 92

	game.mapn = MAP1 + 1 
	game.map = map1
	game.mapW = 25 -- 25
	game.mapH = 13 -- 13
	game.ts = 32

	world.gy = 0.4
	world.aresx = 0.5
	world.aresy = 0.5

	-- Player
	-- Be.
	player.x = 64.0
	player.y = 32.0
	player.vy = 0.1
	player.h = game.ts
	player.w = game.ts
	-- Move.
	player.dx = 0.0
	player.dy = 0.0
	player._mSpd = 4.0--20.0
	player._jSpd = 10.0--8.0

	player.hJmp = false

	player.jCnt = 0.0
	player.jStep = 2.0
	player._mjCnt = 64.0--15.0

	-- Tween:
	-- Start: 	243, 132, 0?
	-- End: 	255, 63,  0?
	tween.l.r = 255

	tween.l.min_g = 48--63
	tween.l.max_g = 99--132
	tween.l.g = tween.l.min_g	

	tween.l.b = 0
	tween.l.stp_g = 1
	tween.l.stpd_g = false
end

function love.draw()
	love.graphics.translate(screen.tx, screen.ty)
	drawMap()
	drawPlayer()
end

function love.update(dt)
	lurker.update()
	if love.keyboard.isDown("escape") then
		love.event.quit()
	end
	playerMov(dt)
	collision(dt)
	tween_f()
end

function drawMap()
	for i = 1, game.mapW do
		for j = 1, game.mapH do
			if (game.map[j][i] == air) then
				love.graphics.setColor(25, 25, 25, 255) -- Some tweening between 25 and 55 here wouldn't go amiss ;)
				love.graphics.rectangle("fill", i*game.ts-32, j*game.ts-32, game.ts, game.ts)	
			elseif (game.map[j][i] == wall) then
				love.graphics.setColor(200, 200, 200, 255)
				love.graphics.rectangle("fill", i*game.ts-32, j*game.ts-32, game.ts, game.ts)
			elseif (game.map[j][i] == door) then
				love.graphics.setColor(0, 0, 0, 255)
				love.graphics.rectangle("fill", i*game.ts-32, j*game.ts-32, game.ts, game.ts)
			end
		end
	end
end

function drawPlayer()
	love.graphics.setColor(255, 255, 255, 255)
	love.graphics.setColor(250, 55, 55, 255)
	love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
end

function playerMov(dt)
	canJump = true
	player.dx = 0
	player.dy = player.vy

	if collides(wall) then
		-- jumping is only illegal when
		-- banging your head, not
		-- if you just fell down
		canJump = player.dy > 0
		
		player.dy = 0
		player.vy = 0
	else
		player.vy = player.vy +world.gy
		-- to avoid clipping through floor tiles
		if (player.vy > game.ts) then
			player.vy = game.ts
		end
	end
	
	if not love.keyboard.isDown("z") then
		player.hJmp = false
	end

	if (player.vy < 1) and canJump and love.keyboard.isDown("z") and not (player.hJmp) then
		print("blop")
		player.vy = -player._jSpd
		player.hJmp = true
	end
	
	if love.keyboard.isDown("left") then
		player.dx = player.dx - player._mSpd
		if (collides(wall) or collides(inviswall)) then
			player.dx = player.dx + player._mSpd
		end
	end

	if love.keyboard.isDown("right") then
		player.dx = player.dx + player._mSpd
		if (collides(wall) or collides(inviswall)) then
			player.dx = player.dx - player._mSpd
		end
	end
	-- print(player.vy .. "	" .. prbool(canJump) .. " " .. prbool(player.hJmp))
	applyMov()
end

function collision(dt)
	if (collides(door)) then
		level_ld(game.mapn)
		game.mapn = game.mapn + 1
		player.x = 64.0
		player.y = 32.0
		player.vy = 0.1
		player.dx = 0.0
		player.dx = 0.0
	end
end

function applyMov()
	player.x = player.x + player.dx
	player.y = player.y + player.dy

	if (player.dx > 0.2) then
		player.dx = player.dx - world.aresx
	end
	if (player.dx < -0.2) then
		player.dx = player.dx + world.aresx
	end
end

function collides(tilenum)
	xleft = math.ceil((player.x + player.dx + 2) / game.ts)
	xright = math.ceil((player.x + player.dx + player.w) / game.ts)
	ytop = math.ceil((player.y + player.dy) / game.ts)
	ybottom = math.ceil((player.y + player.dy + player.h) / game.ts)
	return (game.map[ytop][xleft] 		== tilenum) or
	       (game.map[ytop][xright]		== tilenum) or
	       (game.map[ybottom][xleft] 	== tilenum) or
	       (game.map[ybottom][xright]	== tilenum) 
end

function tween_f()
	-- lava
	if (not tween.l.stpd_g) then
		if (tween.l.g >= tween.l.min_g  and tween.l.g < tween.l.max_g) then
			tween.l.g = tween.l.g + tween.l.stp_g
		end
		if (tween.l.g == tween.l.max_g) then
			tween.l.stpd_g = true
		end
	elseif (tween.l.stpd_g) then
		if (tween.l.g > tween.l.min_g  and tween.l.g <= tween.l.max_g) then
			tween.l.g = tween.l.g - tween.l.stp_g
		end
		if (tween.l.g == tween.l.min_g) then
			tween.l.stpd_g = false
		end
	end

	-- door
	-- A gold slide to the right revealing the grey when there is a collision.
end
 
function level_ld(l)
	-- print(l)
	if (l == MAP1) then
		game.map = map1 
	else
		love.event.quit()
	end
end

function prbool(bool)
	if bool == true then
		return "1"
	elseif bool == false then
		return "0"
	end
end
