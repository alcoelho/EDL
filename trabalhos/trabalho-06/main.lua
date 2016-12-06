local auxiliar = {}

--trab06
--char é uma tupla
local char = {
  image = nil,
  x     = (love.graphics.getWidth() / 2) - 50,
  y     = (love.graphics.getHeight() - 150),
  w     = 80,
  h     = 70
}

local enemyW = 100
local enemyH = 77

local createEnemyTimerMax = 0.4
local createEnemyTimer    = createEnemyTimerMax

--trab06
--enemies1 é usada como array
enemies1 = {}
enemies2 = {}

function CheckCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

local deaths  = 0
local isAlive = true
local winGame = false

-------------[[ funções principais ]]--------------

function love.load () -- ibagens
  --music = love.audio.newSource("encounter.mp3")
  --music:play()

  if arg[#arg] == "-debug" then require("mobdebug").start() end

  waterblock  = love.graphics.newImage("images/water-block.png")
  grassblock  = love.graphics.newImage('images/grass-block.png')
  stoneblock  = love.graphics.newImage('images/stone-block.png')
  gameover    = love.graphics.newImage('images/game-over.png')

  enemyImg1   = love.graphics.newImage('images/enemy-bug.png')
  enemyImg2   = love.graphics.newImage('images/minion.png')
  char.image  = love.graphics.newImage('images/chargirl.png')
  explosion   = love.graphics.newImage('images/explosion.png')

  for i=0, 10, 1 do
    newEnemy1 = { x = math.random()*800, y = math.random()*1000, img = enemyImg1 } -- inimigos por linha
    table.insert(enemies1, newEnemy1)
   end

  for i=0, 10, 1 do
    newEnemy2 = { x = math.random()*800, y = math.random()*1000, img = enemyImg2 } -- inimigos por linha
    table.insert(enemies2, newEnemy2)
  end
end

function love.draw()
  local numrows = 6
  local numcols = 7

  auxiliar.bg(numrows,numcols)

  if isAlive then
    love.graphics.draw(char.image, char.x, char.y)
  else
    auxiliar.fonte()
    love.graphics.print("THIS PLAYER IS NO MORE! HE HAS CEASED TO BE!",90, 15)
    love.graphics.print("PRESS R/ESC TO RESTART/QUIT", 30, 30)
    love.graphics.print("DEATH COUNT: "..deaths, 450, 30)
    love.graphics.draw(gameover, 0, 150)
    enemies1 = {}
    enemies2 = {}
  end

  if char.y < 50 and isAlive then
    auxiliar.wins()
  end

  for i, enemy in ipairs(enemies1) do
    if not enemy.exploding then --desenha normalmente se não tiver explodindo
      love.graphics.draw(enemy.img, enemy.x, enemy.y)
    else
      love.graphics.draw(explosion, enemy.x, enemy.y)
    end
  end
  for i, enemy in ipairs(enemies2) do
    love.graphics.draw(enemy.img, enemy.x, enemy.y)
  end

end
function love.update(dt)

  auxiliar.teclado(dt)

  createEnemyTimer = createEnemyTimer - (1 * dt) -- respawn
  if createEnemyTimer < 0 then
	   createEnemyTimer = createEnemyTimerMax

     --trab06
     --newEnemy1 é um registro
     newEnemy1 = { x = -100, y = 150 + math.random(300), img = enemyImg1 } -- inimigos por linha
     table.insert(enemies1, newEnemy1)

     --trab06
     newEnemy2 = {  x = 700, y = 150 + math.random(300), img = enemyImg2 } -- inimigos por linha
     table.insert(enemies2, newEnemy2)
   end

  for i, enemy in ipairs(enemies1) do -- movimentos do inimigo
    if not enemy.exploding then -- explosão não anda
      enemy.x = enemy.x + (200 * dt)
    end
  end
  for i, enemy in ipairs(enemies2) do -- movimentos do inimigo
    enemy.x = enemy.x - (200 * dt)
  end


  for i, enemy in ipairs(enemies1) do
  	if CheckCollision(enemy.x, enemy.y, enemyW, enemyH, char.x, char.y, char.w, char.h)
  	and isAlive then
  		table.remove(enemies1, i)
  		isAlive = false
      deaths = deaths + 1
  	end
  end
  for i, enemy in ipairs(enemies2) do
  	if CheckCollision(enemy.x, enemy.y, enemyW, enemyH, char.x, char.y, char.w, char.h)
  	and isAlive then
  		table.remove(enemies2, i)
  		isAlive = false
      deaths = deaths + 1
  	end
  end


    firstEnemy = enemies1[1]
    for i, enemy in ipairs(enemies1) do
      for j, other in ipairs(enemies2) do
        if CheckCollision(enemy.x, enemy.y, enemyW, enemyH, other.x, other.y, enemyW, enemyH) then
          enemy.exploding = true
        end
      end
    end


end

-------------[[ funções auxiliares ]]--------------

auxiliar.bg = function(numrows, numcols) -- texturas do fundo
  for row = 0, numrows do
    for col = 0, numcols do
      if row < 1 then
        love.graphics.draw(waterblock, col * 100, row * 80)
      elseif row < 3 then
        love.graphics.draw(stoneblock, col * 100, row * 80)
      else
        love.graphics.draw(grassblock, col * 100, row * 80)
      end
    end
  end
end

--trab06
--KeyConstant é usado como enumeração de possíveis teclas que o usuário pode pressionar
auxiliar.teclado = function(dt) -- movimentos possiveis do jogador
  if love.keyboard.isDown('escape') then
    love.event.push('quit')
  end

  if love.keyboard.isDown('r') then
    auxiliar.restart()
  end

  if not winGame then
    if love.keyboard.isDown('a', 'left')then
      if char.x > 0 then
        char.x = char.x - (dt * 100)
      end
    elseif love.keyboard.isDown('d', 'right')then
      if char.x < (love.graphics.getWidth() - char.image:getWidth()) then
        char.x = char.x + (dt * 100)
      end
    elseif love.keyboard.isDown('w', 'up') then
      if char.y > 0 then
        char.y = char.y - (dt * 100)
      end
    elseif love.keyboard.isDown('s', 'down') then
      if char.y < (love.graphics.getHeight() - char.image:getHeight()) then
        char.y = char.y + (dt * 100)
      end
    end
  end
end

auxiliar.wins = function() -- tela de vitoria
  winGame = true
  auxiliar.fonte()
  love.graphics.print("--YOU DIED--", (love.graphics.getWidth() / 2) - 50, 10)
  love.graphics.print("Life is meaningless, death is a victory. Press R to restart", 25, 25 )
  love.graphics.setColor(255, 0, 0)
  enemies1 = {}
  enemies2 = {}
end

auxiliar.fonte = function() --
  local font = love.graphics.newImageFont("images/Fonte.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
  love.graphics.setFont(font)
end

auxiliar.restart = function() -- pe lanza
  char.x = (love.graphics.getWidth() / 2) - 100
  char.y = (love.graphics.getHeight() - 100)
  love.graphics.setColor(255, 255, 255)
  enemies1 = {}
  enemies2 = {}
  createEnemyTimer = createEnemyTimerMax
  isAlive = true
  winGame = false
end
