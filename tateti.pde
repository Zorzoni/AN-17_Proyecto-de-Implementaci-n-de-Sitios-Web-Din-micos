int[][] board = new int[3][3];
boolean xTurn = true;
boolean gameEnded = false;
int winner = 0;
boolean showWinLine = false;
int winType = 0;
int winIndex = 0;

// Variables para animaciones
float[][] pieceAnimations = new float[3][3];
float[][] pieceGlow = new float[3][3];
float winLineAnimation = 0;
boolean animatingWin = false;
float time = 0;
int cellSize = 120;
int boardOffsetX = 60;
int boardOffsetY = 60;

// Colores pixel art
color[] bgGradient = {color(15, 25, 45), color(25, 35, 55), color(35, 45, 65)};
color gridColor = color(60, 80, 120);
color xColor = color(255, 80, 80);
color oColor = color(80, 160, 255);
color winLineColor = color(255, 220, 100);
color buttonColor = color(100, 200, 100);

// Partículas
ArrayList<Particle> particles;

void setup() {
  size(480, 480);
  noSmooth(); // Crucial para pixel art
  
  // Inicializar animaciones
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      pieceAnimations[i][j] = 0;
      pieceGlow[i][j] = 0;
    }
  }
  
  particles = new ArrayList<Particle>();
  resetGame();
}

void draw() {
  time += 0.02;
  
  // Fondo pixel art animado
  drawPixelBackground();
  
  // Tablero
  pushMatrix();
  translate(boardOffsetX, boardOffsetY);
  
  drawPixelGrid();
  updateAnimations();
  drawPieces();
  
  if (showWinLine) {
    drawWinLine();
  }
  
  popMatrix();
  
  // Botón de reinicio pixel
  drawPixelButton();
  
  // Indicador de turno visual
  drawTurnIndicator();
  
  // Partículas
  updateParticles();
  
  checkWin();
}

void drawPixelBackground() {
  // Gradiente pixelado animado
  for (int y = 0; y < height; y += 4) {
    for (int x = 0; x < width; x += 4) {
      float wave = sin(time + x * 0.01 + y * 0.01) * 0.3 + 0.7;
      color bg = lerpColor(bgGradient[0], bgGradient[1], wave);
      fill(bg);
      noStroke();
      rect(x, y, 4, 4);
    }
  }
  
  // Estrellas pixeladas
  drawPixelStars();
}

void drawPixelStars() {
  fill(255, 200);
  noStroke();
  for (int i = 0; i < 20; i++) {
    float x = (i * 73) % width;
    float y = (i * 97) % height;
    float twinkle = sin(time * 2 + i) * 0.5 + 0.5;
    
    if (twinkle > 0.7) {
      // Estrella de 4 píxeles
      rect(x, y, 4, 4);
      rect(x-4, y, 4, 4);
      rect(x+4, y, 4, 4);
      rect(x, y-4, 4, 4);
      rect(x, y+4, 4, 4);
    }
  }
}

void drawPixelGrid() {
  // Fondo del tablero
  fill(20, 30, 50);
  noStroke();
  rect(-8, -8, cellSize * 3 + 16, cellSize * 3 + 16);
  
  // Líneas de la grilla con efecto glow
  drawGlowGrid();
  
  // Líneas principales
  fill(gridColor);
  noStroke();
  
  // Líneas verticales
  for (int i = 1; i < 3; i++) {
    rect(i * cellSize - 4, 0, 8, cellSize * 3);
  }
  
  // Líneas horizontales
  for (int i = 1; i < 3; i++) {
    rect(0, i * cellSize - 4, cellSize * 3, 8);
  }
}

void drawGlowGrid() {
  // Efecto glow para las líneas
  fill(gridColor, 80);
  noStroke();
  
  // Glow vertical
  for (int i = 1; i < 3; i++) {
    rect(i * cellSize - 8, -4, 16, cellSize * 3 + 8);
  }
  
  // Glow horizontal
  for (int i = 1; i < 3; i++) {
    rect(-4, i * cellSize - 8, cellSize * 3 + 8, 16);
  }
}

void drawPieces() {
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[i][j] == 1) {
        drawPixelX(i, j);
      } else if (board[i][j] == 2) {
        drawPixelO(i, j);
      }
    }
  }
}

void drawPixelX(int i, int j) {
  pushMatrix();
  translate(i * cellSize + cellSize/2, j * cellSize + cellSize/2);
  
  float scale = 1 + pieceAnimations[i][j] * 0.5;
  float glow = pieceGlow[i][j];
  
  pushMatrix();
  scale(scale);
  
  // Glow exterior
  if (glow > 0) {
    fill(red(xColor), green(xColor), blue(xColor), glow * 100);
    drawXShape(50);
  }
  
  // X principal
  fill(xColor);
  drawXShape(40);
  
  // Detalles internos
  fill(255, 150, 150);
  drawXShape(32);
  
  // Centro brillante
  fill(255, 200, 200);
  drawXShape(24);
  
  popMatrix();
  popMatrix();
}

void drawXShape(int size) {
  noStroke();
  int halfSize = size / 2;
  int thickness = max(4, size / 8);
  
  // Diagonal principal (top-left to bottom-right)
  for (int i = -halfSize; i <= halfSize; i += 4) {
    rect(i - thickness/2, i - thickness/2, thickness, thickness);
  }
  
  // Diagonal secundaria (top-right to bottom-left)
  for (int i = -halfSize; i <= halfSize; i += 4) {
    rect(i - thickness/2, -i - thickness/2, thickness, thickness);
  }
}

void drawPixelO(int i, int j) {
  pushMatrix();
  translate(i * cellSize + cellSize/2, j * cellSize + cellSize/2);
  
  float scale = 1 + pieceAnimations[i][j] * 0.5;
  float glow = pieceGlow[i][j];
  
  pushMatrix();
  scale(scale);
  
  // Glow exterior
  if (glow > 0) {
    fill(red(oColor), green(oColor), blue(oColor), glow * 100);
    drawOShape(50);
  }
  
  // O principal
  fill(oColor);
  drawOShape(40);
  
  // Detalles internos
  fill(150, 190, 255);
  drawOShape(32);
  
  // Agujero interior
  fill(20, 30, 50);
  drawOShape(16);
  
  popMatrix();
  popMatrix();
}

void drawOShape(int outerRadius) {
  noStroke();
  int innerRadius = outerRadius - 8;
  
  // Dibujar círculo pixelado
  for (int y = -outerRadius; y <= outerRadius; y += 4) {
    for (int x = -outerRadius; x <= outerRadius; x += 4) {
      float dist = sqrt(x*x + y*y);
      if (dist <= outerRadius && dist >= innerRadius) {
        rect(x-2, y-2, 4, 4);
      }
    }
  }
}

void drawPixelButton() {
  int buttonX = width - 80;
  int buttonY = 20;
  int buttonSize = 60;
  
  // Detectar hover
  boolean hover = (mouseX > buttonX && mouseX < buttonX + buttonSize && 
                   mouseY > buttonY && mouseY < buttonY + buttonSize);
  
  // Botón base
  color btnColor = hover ? lerpColor(buttonColor, color(150, 255, 150), 0.5) : buttonColor;
  fill(btnColor);
  noStroke();
  rect(buttonX, buttonY, buttonSize, buttonSize);
  
  // Borde pixelado
  fill(200, 255, 200);
  rect(buttonX, buttonY, buttonSize, 4); // top
  rect(buttonX, buttonY + buttonSize - 4, buttonSize, 4); // bottom
  rect(buttonX, buttonY, 4, buttonSize); // left
  rect(buttonX + buttonSize - 4, buttonY, 4, buttonSize); // right
  
  // Ícono de reset (flecha circular pixelada)
  fill(255);
  drawResetIcon(buttonX + buttonSize/2, buttonY + buttonSize/2);
}

void drawResetIcon(float cx, float cy) {
  noStroke();
  
  // Flecha circular pixelada
  fill(255);
  
  // Círculo base
  for (int angle = 45; angle < 315; angle += 20) {
    float x = cx + cos(radians(angle)) * 15;
    float y = cy + sin(radians(angle)) * 15;
    rect(x-2, y-2, 4, 4);
  }
  
  // Punta de flecha
  rect(cx + 12, cy - 18, 4, 4);
  rect(cx + 8, cy - 14, 4, 4);
  rect(cx + 16, cy - 14, 4, 4);
}

void drawTurnIndicator() {
  if (gameEnded) return;
  
  int indicatorY = 20;
  float pulse = sin(time * 3) * 0.3 + 0.7;
  
  // Indicador del jugador actual
  pushMatrix();
  translate(20, indicatorY);
  scale(pulse * 0.8);
  
  if (xTurn) {
    fill(red(xColor) * pulse, green(xColor) * pulse, blue(xColor) * pulse);
    drawXShape(30);
  } else {
    fill(red(oColor) * pulse, green(oColor) * pulse, blue(oColor) * pulse);
    drawOShape(20);
  }
  
  popMatrix();
}

void drawWinLine() {
  if (animatingWin) {
    winLineAnimation = min(winLineAnimation + 0.03, 1);
  }
  
  // Calcular posiciones
  float x1, y1, x2, y2;
  
  if (winType == 0) { // Fila
    x1 = 0;
    y1 = winIndex * cellSize + cellSize/2;
    x2 = cellSize * 3;
    y2 = winIndex * cellSize + cellSize/2;
  } else if (winType == 1) { // Columna
    x1 = winIndex * cellSize + cellSize/2;
    y1 = 0;
    x2 = winIndex * cellSize + cellSize/2;
    y2 = cellSize * 3;
  } else if (winType == 2) { // Diagonal principal
    x1 = 0;
    y1 = 0;
    x2 = cellSize * 3;
    y2 = cellSize * 3;
  } else { // Diagonal secundaria
    x1 = 0;
    y1 = cellSize * 3;
    x2 = cellSize * 3;
    y2 = 0;
  }
  
  // Animar línea
  float animX2 = lerp(x1, x2, winLineAnimation);
  float animY2 = lerp(y1, y2, winLineAnimation);
  
  drawPixelLine(x1, y1, animX2, animY2, winLineColor, 12);
}

void drawPixelLine(float x1, float y1, float x2, float y2, color c, int thickness) {
  float dist = sqrt((x2-x1)*(x2-x1) + (y2-y1)*(y2-y1));
  float dx = (x2-x1) / dist * 4;
  float dy = (y2-y1) / dist * 4;
  
  fill(c);
  noStroke();
  
  for (float i = 0; i < dist; i += 4) {
    float x = x1 + dx * i/4;
    float y = y1 + dy * i/4;
    rect(x - thickness/2, y - thickness/2, thickness, thickness);
    
    // Efecto sparkle
    if (random(100) < 20) {
      particles.add(new Particle(x + boardOffsetX, y + boardOffsetY, c));
    }
  }
}

void updateAnimations() {
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (pieceAnimations[i][j] > 0) {
        pieceAnimations[i][j] -= 0.03;
      }
      if (pieceGlow[i][j] > 0) {
        pieceGlow[i][j] -= 0.05;
      }
    }
  }
}

void mousePressed() {
  // Verificar botón de reset
  if (mouseX > width - 80 && mouseX < width - 20 && mouseY > 20 && mouseY < 80) {
    resetGame();
    // Explosión de partículas
    for (int i = 0; i < 15; i++) {
      particles.add(new Particle(mouseX, mouseY, color(random(100, 255), random(100, 255), random(100, 255))));
    }
    return;
  }
  
  if (gameEnded) return;
  
  // Calcular celda clickeada
  int adjustedX = mouseX - boardOffsetX;
  int adjustedY = mouseY - boardOffsetY;
  
  if (adjustedX < 0 || adjustedX > cellSize * 3 || adjustedY < 0 || adjustedY > cellSize * 3) return;
  
  int i = adjustedX / cellSize;
  int j = adjustedY / cellSize;
  
  if (i >= 0 && i < 3 && j >= 0 && j < 3 && board[i][j] == 0) {
    board[i][j] = xTurn ? 1 : 2;
    
    // Iniciar animaciones
    pieceAnimations[i][j] = 1.0;
    pieceGlow[i][j] = 1.0;
    
    // Partículas
    color pieceColor = xTurn ? xColor : oColor;
    for (int p = 0; p < 8; p++) {
      particles.add(new Particle(
        boardOffsetX + i * cellSize + cellSize/2 + random(-20, 20),
        boardOffsetY + j * cellSize + cellSize/2 + random(-20, 20),
        pieceColor
      ));
    }
    
    xTurn = !xTurn;
  }
}

void checkWin() {
  // Verificar filas
  for (int i = 0; i < 3; i++) {
    if (board[0][i] != 0 && board[0][i] == board[1][i] && board[1][i] == board[2][i]) {
      winner = board[0][i];
      winType = 0;
      winIndex = i;
      gameEnded = true;
      showWinLine = true;
      animatingWin = true;
      winLineAnimation = 0;
      return;
    }
  }
  
  // Verificar columnas
  for (int i = 0; i < 3; i++) {
    if (board[i][0] != 0 && board[i][0] == board[i][1] && board[i][1] == board[i][2]) {
      winner = board[i][0];
      winType = 1;
      winIndex = i;
      gameEnded = true;
      showWinLine = true;
      animatingWin = true;
      winLineAnimation = 0;
      return;
    }
  }
  
  // Verificar diagonal principal
  if (board[0][0] != 0 && board[0][0] == board[1][1] && board[1][1] == board[2][2]) {
    winner = board[0][0];
    winType = 2;
    gameEnded = true;
    showWinLine = true;
    animatingWin = true;
    winLineAnimation = 0;
    return;
  }
  
  // Verificar diagonal secundaria
  if (board[0][2] != 0 && board[0][2] == board[1][1] && board[1][1] == board[2][0]) {
    winner = board[0][2];
    winType = 3;
    gameEnded = true;
    showWinLine = true;
    animatingWin = true;
    winLineAnimation = 0;
    return;
  }
  
  // Verificar empate
  boolean boardFull = true;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      if (board[i][j] == 0) {
        boardFull = false;
        break;
      }
    }
    if (!boardFull) break;
  }
  
  if (boardFull && winner == 0) {
    winner = 3; // Empate
    gameEnded = true;
  }
}

void resetGame() {
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      board[i][j] = 0;
      pieceAnimations[i][j] = 0;
      pieceGlow[i][j] = 0;
    }
  }
  xTurn = true;
  gameEnded = false;
  winner = 0;
  showWinLine = false;
  animatingWin = false;
  winLineAnimation = 0;
}

// Clase Particle
class Particle {
  float x, y;
  float vx, vy;
  color col;
  float life;
  float size;
  
  Particle(float x, float y, color c) {
    this.x = x;
    this.y = y;
    this.vx = random(-3, 3);
    this.vy = random(-4, -1);
    this.col = c;
    this.life = 255;
    this.size = random(2, 8);
  }
  
  void update() {
    x += vx;
    y += vy;
    vy += 0.15; // gravedad
    life -= 4;
    size *= 0.96;
    
    // Bounce en los bordes
    if (x < 0 || x > width) vx *= -0.8;
    if (y > height) vy *= -0.6;
  }
  
  void display() {
    fill(red(col), green(col), blue(col), life);
    noStroke();
    
    // Partícula pixelada
    int pixelSize = max(2, (int)(size/2) * 2);
    rect(x - pixelSize/2, y - pixelSize/2, pixelSize, pixelSize);
  }
  
  boolean isDead() {
    return life <= 0 || size < 1;
  }
}

void updateParticles() {
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    
    if (p.isDead()) {
      particles.remove(i);
    }
  }
}
