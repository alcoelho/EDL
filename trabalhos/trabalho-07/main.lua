--
--Feito por Alline Coelho e Luiz Andrade
--

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
local w = 80
local h = 70

-- trabalho 07
-- move é uma closure pois atende a todos os "requisitos":
--  - é um subprograma dentro da função "moveChar".
--  - o ambiente da closure é criado no momento que moveChar é criado.
function moveChar (x,y)
return{
  move = function(dx,dy)
    x = x + dx
    y = y + dy
  return x,y
  end}
end

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

local limite = {x1 = 100, x2 = 300, y1 = 100, y2 = 300 }
local moveEneX = 200
local moveEneY = 100


-- trabalho 07
--criação da corotina para o movimento do inimigo
local function moveE1(x,y)
    while true do
    
      while moveEneX >= limite.x1 and moveEneY <= limite.y1 do  
        moveEneX = moveEneX - x
        coroutine.yield()
      end
      
      while moveEneY <= limite.y2 and moveEneX <= limite.x1 do
        moveEneY = moveEneY + y
        coroutine.yield()
      end
    
      while moveEneX <= limite.x2 and moveEneY >= limite.y2 do
        moveEneX = moveEneX + x
        coroutine.yield()
      end
    
      while moveEneY >= limite.y1 and moveEneX >= limite.x2 do
        moveEneY = moveEneY - y
        coroutine.yield()
      end
    end
  end
  
local deaths  = 0
local isAlive = true
local winGame = false

-------------[[ funções principais ]]--------------

function love.load () -- ibagens
  --music = love.audio.newSource("encounter.mp3")
  --music:play()
  
  -- trabalho 07
  -- criando a closure e instanciando o ambiente.
  -- upvalues: variaveis "x" e "y" de "moveChar"
  
  p1 = moveChar((love.graphics.getWidth() / 2) - 50,
                (love.graphics.getHeight() - 150))
              
  e1 = coroutine.create(moveE1)

  if arg[#arg] == "-debug" then require("mobdebug").start() end

  waterblock  = love.graphics.newImage("images/water-block.png")
  grassblock  = love.graphics.newImage('images/grass-block.png')
  stoneblock  = love.graphics.newImage('images/stone-block.png')
  gameover    = love.graphics.newImage('images/game-over.png')

  enemyImg1   = love.graphics.newImage('images/enemy-bug.png')
  enemyImg2   = love.graphics.newImage('images/minion.png')
  eImg        = love.graphics.newImage('images/Rock.png')
  char.image  = love.graphics.newImage('images/chargirl.png')
  explosion   = love.graphics.newImage('images/explosion.png')

end

function love.draw()
  local numrows = 6
  local numcols = 7

  auxiliar.bg(numrows,numcols)

  local x,y = p1.move(0,0)
  if isAlive then
    love.graphics.draw(char.image, x, y)
  else
    auxiliar.fonte()
    love.graphics.print("THIS PLAYER IS NO MORE! HE HAS CEASED TO BE!",90, 15)
    love.graphics.print("PRESS R/ESC TO RESTART/QUIT", 30, 30)
    love.graphics.print("DEATH COUNT: "..deaths, 450, 30)
    love.graphics.draw(gameover, 0, 150)
    enemies1 = {}
    enemies2 = {}
  end

  
  if y < 50 and isAlive then
    auxiliar.wins()
  end
  
  love.graphics.draw(eImg, moveEneX, moveEneY)

end
function love.update(dt)

  auxiliar.teclado(dt)
  
  -- trabalho 07
  coroutine.resume(e1,(dt*10000),(dt*10000))

  createEnemyTimer = createEnemyTimer - (1 * dt) -- respawn
  if createEnemyTimer < 0 then
	   createEnemyTimer = createEnemyTimerMax

     --trab06
     --newEnemy1 é uma tupla, mas funciona como um registro na prática, já que a partir dele
     --são criados os inimigos do jogo seguindo o mesmo modelo inicial
     --newEnemy1 = { x = -100, y = 150 + math.random(300), img = enemyImg1 } -- inimigos por linha
     --table.insert(enemies1, newEnemy1)

     --trab06
     --newEnemy2 é uma tupla
     --newEnemy2 = {  x = 700, y = 150 + math.random(300), img = enemyImg2 } -- inimigos por linha
     --table.insert(enemies2, newEnemy2)
   end

  local x,y = p1.move(0,0)
  
  if CheckCollision(moveEneX, moveEneY, enemyW, enemyH, x, y, w, h)
  	and isAlive then
  		isAlive = false
      deaths = deaths + 1
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
      -- trabalho 07
      -- chamada arbritária da closure
      local x = p1.move(0,0)
      if x > 0 then
        p1.move(-(dt * 1000),0)
      end
      
    elseif love.keyboard.isDown('d', 'right')then
      local x = p1.move(0,0)
      if x < (love.graphics.getWidth() - char.image:getWidth()) then
        p1.move(dt * 1000,0)
      end
      
    elseif love.keyboard.isDown('w', 'up') then
      local _,y = p1.move(0,0)
      if y > 0 then
        p1.move(0,-(dt * 1000))
      end
      
    elseif love.keyboard.isDown('s', 'down') then
      local _,y = p1.move(0,0)
      if y < (love.graphics.getHeight() - char.image:getHeight()) then
        p1.move(0, dt * 1000)
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
  p1 = moveChar((love.graphics.getWidth() / 2) - 100,
                (love.graphics.getHeight() - 100))
  love.graphics.setColor(255, 255, 255)
  enemies1 = {}
  enemies2 = {}
  createEnemyTimer = createEnemyTimerMax
  isAlive = true
  winGame = false
end
