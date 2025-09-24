// CYBERPONG 3D - Temática Cyberpunk Futurista
// Variables principales del juego
PVector ballPos, ballSpeed;
float ballRadius = 8;
PVector paddle1Pos, paddle2Pos;
float paddleWidth = 12, paddleHeight = 70, paddleDepth = 20, paddleSpeed = 7;
int score1 = 0, score2 = 0;
int winningScore = 7;
float rotationY = 0;
float baseSpeed = 3.5;
float speedMultiplier = 1.0;

// Efectos visuales cyberpunk
ArrayList<Particle> particles;
ArrayList<TrailPoint> ballTrail;
ArrayList<Glitch> glitches;
float cameraAngle = 0;
float pulseTime = 0;
float scanlineOffset = 0;

// Colores neon
color neonCyan = color(0, 255, 255);
color neonPink = color(255, 0, 150);
color neonGreen = color(0, 255, 100);
color neonPurple = color(200, 0, 255);
color darkBg = color(5, 5, 15);

void setup() {
  size(800, 500, P3D);
  
  // Inicializar posiciones
  ballPos = new PVector(width / 2, height / 2, 0);
  ballSpeed = new PVector(baseSpeed, random(-2, 2), 0);
  paddle1Pos = new PVector(30, height / 2 - paddleHeight / 2, 0);
  paddle2Pos = new PVector(width - 42, height / 2 - paddleHeight / 2, 0);
  
  // Inicializar efectos
  particles = new ArrayList<Particle>();
  ballTrail = new ArrayList<TrailPoint>();
  glitches = new ArrayList<Glitch>();
}

void draw() {
  background(5, 5, 15);
  
  // Efectos de fondo cyberpunk
  drawCyberBackground();
  
  // Configurar luces neon
  setupNeonLights();
  
  // Efecto de cámara con movimiento dinámico
  setupDynamicCamera();
  
  // Lógica principal del juego
  moveBall();
  controlPaddles();
  checkCollisions();
  checkWinCondition();
  
  // Renderizar elementos del juego
  drawCyberField();
  drawNeonBall();
  drawCyberPaddles();
  updateEffects();
  
  // UI cyberpunk
  drawCyberUI();
  
  // Efectos post-procesado
  drawScanlines();
  drawGlitches();
  
  pulseTime += 0.08;
  scanlineOffset += 2;
}

void drawCyberBackground() {
  // Grid cyberpunk en el fondo más sutil
  stroke(0, 100, 150, 20);
  strokeWeight(1);
  
  for (int i = 0; i < width; i += 40) {
    line(i, 0, i, height);
  }
  for (int j = 0; j < height; j += 40) {
    line(0, j, width, j);
  }
  
  // Circuitos más pequeños en las esquinas
  drawCircuitPattern(30, 30, 60);
  drawCircuitPattern(width - 90, 30, 60);
  drawCircuitPattern(30, height - 90, 60);
  drawCircuitPattern(width - 90, height - 90, 60);
}

void drawCircuitPattern(float x, float y, float size) {
  pushMatrix();
  translate(x, y);
  
  stroke(neonCyan, 80);
  strokeWeight(2);
  noFill();
  
  // Líneas de circuito
  for (int i = 0; i < 8; i++) {
    float angle = i * PI / 4;
    float x1 = cos(angle) * size * 0.3;
    float y1 = sin(angle) * size * 0.3;
    float x2 = cos(angle) * size * 0.6;
    float y2 = sin(angle) * size * 0.6;
    line(x1, y1, x2, y2);
    
    // Nodos
    fill(neonCyan, 120);
    noStroke();
    ellipse(x2, y2, 4, 4);
  }
  
  popMatrix();
}

void setupNeonLights() {
  // Luz ambiental más clara para mejor visibilidad
  ambientLight(20, 25, 35);
  
  // Luces neon principales más suaves
  pointLight(0, 200, 200, ballPos.x, ballPos.y, ballPos.z + 60);
  pointLight(200, 0, 120, paddle1Pos.x, paddle1Pos.y + paddleHeight/2, 30);
  pointLight(150, 0, 200, paddle2Pos.x, paddle2Pos.y + paddleHeight/2, 30);
  
  // Luz central menos intensa
  float pulse = sin(pulseTime) * 0.3 + 0.7;
  pointLight(0, 150, 80, width/2, height/2, 50 + pulse * 20);
}

void setupDynamicCamera() {
  translate(width/2, height/2, 0);
  
  // Rotación más sutil para mantener visibilidad
  float ballInfluence = map(abs(ballSpeed.x), 0, 15, 0, 0.08);
  rotateY(sin(cameraAngle) * (0.06 + ballInfluence));
  rotateX(sin(cameraAngle * 1.3) * 0.03);
  rotateZ(sin(cameraAngle * 0.7) * 0.01);
  
  translate(-width/2, -height/2, 0);
  cameraAngle += 0.01;
}

void moveBall() {
  ballPos.add(ballSpeed);
  
  // Agregar punto al trail
  ballTrail.add(new TrailPoint(ballPos.x, ballPos.y, ballPos.z));
  
  // Mantener trail más corto
  if (ballTrail.size() > 8) {
    ballTrail.remove(0);
  }
  
  // Rebote en paredes superior e inferior
  if (ballPos.y - ballRadius <= 0 || ballPos.y + ballRadius >= height) {
    ballSpeed.y *= -1;
    ballPos.y = constrain(ballPos.y, ballRadius, height - ballRadius);
    
    // Efecto de rebote en pared
    createWallHitEffect(ballPos.x, ballPos.y);
    createGlitch();
  }
}

void controlPaddles() {
  // Jugador 1 (W/S)
  if (keyPressed) {
    if ((key == 'w' || key == 'W') && paddle1Pos.y > 0) {
      paddle1Pos.y -= paddleSpeed;
    }
    if ((key == 's' || key == 'S') && paddle1Pos.y < height - paddleHeight) {
      paddle1Pos.y += paddleSpeed;
    }
    
    // Jugador 2 (Flechas)
    if (keyCode == UP && paddle2Pos.y > 0) {
      paddle2Pos.y -= paddleSpeed;
    }
    if (keyCode == DOWN && paddle2Pos.y < height - paddleHeight) {
      paddle2Pos.y += paddleSpeed;
    }
  }
  
  paddle1Pos.y = constrain(paddle1Pos.y, 0, height - paddleHeight);
  paddle2Pos.y = constrain(paddle2Pos.y, 0, height - paddleHeight);
}

void checkCollisions() {
  // Colisión con raqueta 1 (izquierda)
  if (ballPos.x - ballRadius <= paddle1Pos.x + paddleWidth &&
      ballPos.y + ballRadius >= paddle1Pos.y &&
      ballPos.y - ballRadius <= paddle1Pos.y + paddleHeight &&
      ballSpeed.x < 0) {
    
    // Aumentar velocidad progresivamente
    speedMultiplier += 0.15;
    
    float relativeIntersectY = (ballPos.y - (paddle1Pos.y + paddleHeight/2)) / (paddleHeight/2);
    float bounceAngle = relativeIntersectY * PI/3;
    
    float speed = baseSpeed * speedMultiplier;
    ballSpeed.x = speed * cos(bounceAngle);
    ballSpeed.y = speed * sin(bounceAngle);
    
    ballPos.x = paddle1Pos.x + paddleWidth + ballRadius;
    
    createPaddleHitEffect(ballPos.x, ballPos.y, neonPink, true);
  }
  
  // Colisión con raqueta 2 (derecha)
  if (ballPos.x + ballRadius >= paddle2Pos.x &&
      ballPos.y + ballRadius >= paddle2Pos.y &&
      ballPos.y - ballRadius <= paddle2Pos.y + paddleHeight &&
      ballSpeed.x > 0) {
    
    // Aumentar velocidad progresivamente
    speedMultiplier += 0.15;
    
    float relativeIntersectY = (ballPos.y - (paddle2Pos.y + paddleHeight/2)) / (paddleHeight/2);
    float bounceAngle = relativeIntersectY * PI/3;
    
    float speed = baseSpeed * speedMultiplier;
    ballSpeed.x = -speed * cos(bounceAngle);
    ballSpeed.y = speed * sin(bounceAngle);
    
    ballPos.x = paddle2Pos.x - ballRadius;
    
    createPaddleHitEffect(ballPos.x, ballPos.y, neonPurple, false);
  }
  
  // Goles
  if (ballPos.x < -ballRadius) {
    score2++;
    createGoalEffect(false);
    resetBall();
  }
  
  if (ballPos.x > width + ballRadius) {
    score1++;
    createGoalEffect(true);
    resetBall();
  }
}

void checkWinCondition() {
  if (score1 >= winningScore || score2 >= winningScore) {
    // Efecto de victoria masivo
    for (int i = 0; i < 50; i++) {
      color winColor = (score1 >= winningScore) ? neonPink : neonPurple;
      particles.add(new Particle(random(width), random(height), winColor, 3.0));
    }
    
    // Crear múltiples glitches
    for (int i = 0; i < 5; i++) {
      createGlitch();
    }
    
    delay(2000);
    
    // Reiniciar automáticamente
    score1 = 0;
    score2 = 0;
    speedMultiplier = 1.0;
    resetBall();
    particles.clear();
    glitches.clear();
  }
}

void createPaddleHitEffect(float x, float y, color c, boolean leftSide) {
  // Partículas de impacto
  for (int i = 0; i < 12; i++) {
    particles.add(new Particle(x, y, c, 2.0));
  }
  
  // Ondas de choque
  for (int i = 0; i < 6; i++) {
    particles.add(new ShockWave(x, y, c));
  }
  
  createGlitch();
}

void createWallHitEffect(float x, float y) {
  for (int i = 0; i < 8; i++) {
    particles.add(new Particle(x, y, neonCyan, 1.5));
  }
}

void createGoalEffect(boolean player1Scored) {
  color goalColor = player1Scored ? neonPink : neonPurple;
  
  for (int i = 0; i < 30; i++) {
    particles.add(new Particle(width/2, height/2, goalColor, 4.0));
  }
  
  // Múltiples ondas de choque
  for (int i = 0; i < 10; i++) {
    particles.add(new ShockWave(width/2, height/2, goalColor));
  }
  
  // Glitches masivos
  for (int i = 0; i < 3; i++) {
    createGlitch();
  }
}

void resetBall() {
  ballPos = new PVector(width / 2, height / 2, 0);
  
  float angle = random(-PI/6, PI/6);
  ballSpeed = new PVector(baseSpeed * (random(1) > 0.5 ? 1 : -1), 
                         sin(angle) * baseSpeed, 0);
  
  speedMultiplier = max(1.0, speedMultiplier * 0.7); // Reducir velocidad pero mantener algo
  ballTrail.clear();
  
  delay(1000);
}

void drawCyberField() {
  // Campo principal con efecto holográfico
  fill(5, 20, 30, 60);
  stroke(neonCyan, 100);
  strokeWeight(2);
  rect(0, 0, width, height);
  
  // Línea central con efecto neon
  stroke(neonGreen, 150 + sin(pulseTime * 2) * 50);
  strokeWeight(3);
  line(width/2, 0, width/2, height);
  
  // Círculo central pulsante
  noFill();
  stroke(neonGreen, 100 + sin(pulseTime * 3) * 80);
  strokeWeight(2);
  float circleSize = 120 + sin(pulseTime) * 10;
  ellipse(width/2, height/2, circleSize, circleSize);
  
  // Zonas de gol con efectos neon
  drawGoalZone(0, neonPink);
  drawGoalZone(width - 40, neonPurple);
  
  // Bordes 3D futuristas
  drawCyberBorders();
}

void drawGoalZone(float x, color c) {
  fill(red(c), green(c), blue(c), 25);
  stroke(c, 100 + sin(pulseTime * 2) * 40);
  strokeWeight(2);
  rect(x, height/2 - 60, 30, 120);
  
  // Líneas de detalle más pequeñas
  stroke(c, 60);
  strokeWeight(1);
  for (int i = 0; i < 6; i++) {
    float y = height/2 - 50 + i * 16;
    line(x + 3, y, x + 27, y);
  }
}

void drawCyberBorders() {
  noStroke();
  
  // Bordes más pequeños y controlados
  for (int i = 0; i < 10; i++) {
    float alpha = map(i, 0, 9, 80, 0);
    fill(0, 100, 150, alpha);
    
    // Borde superior
    beginShape();
    vertex(0, i, 0);
    vertex(width, i, 0);
    vertex(width, i, -i);
    vertex(0, i, -i);
    endShape(CLOSE);
    
    // Borde inferior
    beginShape();
    vertex(0, height - i, 0);
    vertex(width, height - i, 0);
    vertex(width, height - i, -i);
    vertex(0, height - i, -i);
    endShape(CLOSE);
  }
}

void drawNeonBall() {
  pushMatrix();
  translate(ballPos.x, ballPos.y, ballPos.z);
  
  // Trail más sutil
  drawBallTrail();
  
  // Rotación más suave
  rotateX(frameCount * 0.1);
  rotateY(frameCount * 0.08);
  rotateZ(frameCount * 0.05);
  
  // Core de la pelota más visible
  fill(255, 255, 255, 220);
  noStroke();
  sphere(ballRadius * 0.8);
  
  // Aura exterior más contenida
  float pulse = sin(pulseTime * 3) * 0.2 + 0.8;
  fill(0, 255, 255, 80 * pulse);
  sphere(ballRadius * 1.2);
  
  // Anillo exterior más pequeño
  fill(255, 0, 150, 50 * pulse);
  sphere(ballRadius * 1.4);
  
  popMatrix();
}

void drawBallTrail() {
  if (ballTrail.size() < 2) return;
  
  noFill();
  strokeWeight(2);
  
  for (int i = 1; i < ballTrail.size(); i++) {
    TrailPoint current = ballTrail.get(i);
    TrailPoint previous = ballTrail.get(i - 1);
    
    float alpha = map(i, 0, ballTrail.size() - 1, 0, 150);
    stroke(0, 255, 255, alpha);
    
    line(previous.x - ballPos.x, previous.y - ballPos.y, previous.z - ballPos.z,
         current.x - ballPos.x, current.y - ballPos.y, current.z - ballPos.z);
  }
}

void drawCyberPaddles() {
  // Paddle 1 (Izquierda - Rosa neon)
  drawCyberPaddle(paddle1Pos, neonPink, true);
  
  // Paddle 2 (Derecha - Morado neon)
  drawCyberPaddle(paddle2Pos, neonPurple, false);
}

void drawCyberPaddle(PVector pos, color c, boolean isLeft) {
  pushMatrix();
  translate(pos.x + paddleWidth/2, pos.y + paddleHeight/2, 0);
  
  // Cuerpo principal
  fill(red(c), green(c), blue(c), 200);
  noStroke();
  box(paddleWidth, paddleHeight, paddleDepth);
  
  // Bordes luminosos
  stroke(c, 255);
  strokeWeight(2);
  noFill();
  box(paddleWidth * 1.1, paddleHeight * 1.05, paddleDepth * 1.1);
  
  // Líneas de energía
  stroke(c, 150);
  strokeWeight(1);
  for (int i = 0; i < 5; i++) {
    float y = -paddleHeight/2 + 10 + i * (paddleHeight - 20) / 4;
    line(-paddleWidth/2, y, paddleWidth/2, y);
  }
  
  // Aura exterior
  fill(red(c), green(c), blue(c), 30);
  noStroke();
  box(paddleWidth * 1.3, paddleHeight * 1.2, paddleDepth * 1.4);
  
  popMatrix();
}

void updateEffects() {
  // Actualizar partículas
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
  
  // Dibujar partículas
  for (Particle p : particles) {
    p.display();
  }
  
  // Actualizar glitches
  for (int i = glitches.size() - 1; i >= 0; i--) {
    Glitch g = glitches.get(i);
    g.update();
    if (g.isDead()) {
      glitches.remove(i);
    }
  }
}

void drawCyberUI() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  // Marcador con estilo cyberpunk
  textAlign(CENTER, CENTER);
  
  // Fondo del marcador
  fill(0, 0, 0, 150);
  rect(width/2 - 100, 20, 200, 60);
  
  // Bordes neon del marcador
  stroke(neonCyan, 200);
  strokeWeight(2);
  noFill();
  rect(width/2 - 100, 20, 200, 60);
  
  // Números del marcador
  textSize(32);
  fill(neonPink, 255);
  text(score1, width/2 - 30, 50);
  
  fill(neonCyan, 200);
  text(":", width/2, 50);
  
  fill(neonPurple, 255);
  text(score2, width/2 + 30, 50);
  
  // Indicadores de velocidad
  textAlign(LEFT, TOP);
  textSize(14);
  fill(neonGreen, 180);
  text("VELOCIDAD: " + nf(speedMultiplier, 1, 1) + "x", 20, 20);
  
  // Controles minimalistas
  textAlign(RIGHT, TOP);
  fill(255, 120);
  text("W/S  ↑/↓", width - 20, 20);
  
  hint(ENABLE_DEPTH_TEST);
}

void drawScanlines() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  stroke(0, 255, 255, 15);
  strokeWeight(1);
  
  for (int i = 0; i < height; i += 4) {
    float offset = sin(i * 0.1 + scanlineOffset * 0.05) * 2;
    line(0, i + offset, width, i + offset);
  }
  
  hint(ENABLE_DEPTH_TEST);
}

void createGlitch() {
  glitches.add(new Glitch());
}

void drawGlitches() {
  camera();
  hint(DISABLE_DEPTH_TEST);
  
  for (Glitch g : glitches) {
    g.display();
  }
  
  hint(ENABLE_DEPTH_TEST);
}

void keyPressed() {
  if (key == 'r' || key == 'R') {
    score1 = 0;
    score2 = 0;
    speedMultiplier = 1.0;
    resetBall();
    particles.clear();
    glitches.clear();
  }
}

// Clases para efectos

class Particle {
  PVector pos, vel;
  color col;
  float life, maxLife;
  float size;
  float intensity;
  
  Particle(float x, float y, color c, float i) {
    pos = new PVector(x, y, random(-30, 30));
    vel = new PVector(random(-8, 8), random(-8, 8), random(-5, 5));
    col = c;
    maxLife = life = random(40, 120);
    size = random(2, 8) * i;
    intensity = i;
  }
  
  void update() {
    pos.add(vel);
    vel.mult(0.94);
    vel.y += 0.2;
    life--;
    size *= 0.985;
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    
    float alpha = map(life, 0, maxLife, 0, 255) * intensity;
    fill(red(col), green(col), blue(col), alpha);
    noStroke();
    
    sphere(size);
    
    // Glow effect
    fill(red(col), green(col), blue(col), alpha * 0.3);
    sphere(size * 2);
    
    popMatrix();
  }
  
  boolean isDead() {
    return life <= 0 || size < 0.5;
  }
}

class ShockWave extends Particle {
  float radius;
  float maxRadius;
  
  ShockWave(float x, float y, color c) {
    super(x, y, c, 1.0);
    radius = 5;
    maxRadius = random(50, 120);
    vel = new PVector(0, 0, 0);
  }
  
  void update() {
    radius += 4;
    life--;
    if (radius > maxRadius) life = 0;
  }
  
  void display() {
    pushMatrix();
    translate(pos.x, pos.y, pos.z);
    
    float alpha = map(radius, 5, maxRadius, 200, 0);
    stroke(red(col), green(col), blue(col), alpha);
    strokeWeight(3);
    noFill();
    
    ellipse(0, 0, radius * 2, radius * 2);
    
    popMatrix();
  }
}

class TrailPoint {
  float x, y, z;
  
  TrailPoint(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}

class Glitch {
  float x, y, w, h;
  color glitchColor;
  int life;
  float offset;
  
  Glitch() {
    x = random(width);
    y = random(height);
    w = random(50, 200);
    h = random(5, 30);
    glitchColor = random(1) > 0.5 ? neonPink : neonCyan;
    life = (int)random(5, 15);
    offset = random(-20, 20);
  }
  
  void update() {
    life--;
    offset = random(-30, 30);
  }
  
  void display() {
    if (random(1) > 0.7) {
      fill(red(glitchColor), green(glitchColor), blue(glitchColor), 150);
      noStroke();
      rect(x + offset, y, w, h);
    }
  }
  
  boolean isDead() {
    return life <= 0;
  }
}
