private Object p; // player
private ArrayList<Object> platforms;
private ArrayList<Object> enemies;
private final static float RIGHT_DISTANCE_VIEW = 300;
private final static float LEFT_DISTANCE_VIEW = 300;
private final static float VERTICAL_DISTANCE_VIEW = 50;
private float text_x;
private float text_y;

private float view_x, view_y;


public void setup() {
  size(800, 600);
  p = new Object();
  platforms = new ArrayList<Object>();
  enemies = new ArrayList<Object>();
  addEntities("tilemap.csv");

  view_x = view_y = 0;
  text_y = 570;
  text_x = 10;
}

public void draw() {
  background(255, 255, 255);
  scroll();
  textSize(32);
  text("Lives: " + p.getLives(), text_x, text_y);
  if (p.getLives() > 0) {
    p.update();
    resolveCollision(p, platforms);
    if (enemies.size() > 0)
      resolveEnemyCollision(p, enemies);
  }
  for (Object o : platforms) 
    o.update();
  for (Object o : enemies)
    o.update();
  //print(p.getLeft() + " - " + p.getTop() + "\n");
}

// checka för kollision
public boolean checkCollision(Object p, Object o) {
  final boolean x_overlap = p.getRight() <= o.getLeft() || p.getLeft() >= o.getRight();
  final boolean y_overlap = p.getBottom() <= o.getTop() || p.getTop() >= o.getBottom();
  if (x_overlap || y_overlap) return false;
  return true;
}

public ArrayList<Object> checkCollisionList(Object p, ArrayList<Object> list) {
  ArrayList<Object> newList = new ArrayList<Object>();
  for (Object o : list) {
    if (checkCollision(p, o)) {
      newList.add(o);
    }
  }
  return newList;
}

// checka om gubben är på en platform
public boolean isOnPlatform(Object p, ArrayList<Object> list) {
  p.updateY(2); // vi går ner två pixlar och sedan checkar om vi är i/på en platform
  final ArrayList<Object> newList = checkCollisionList(p, list);
  p.updateY(-2); // sedan går vi upp två pixelar
  if (newList.size() > 0) {
    return true;
  }
  return false;
}

public void resolveEnemyCollision(Object p, ArrayList<Object> list) {
  ArrayList<Object> newList = checkCollisionList(p, list);
  if (newList.size() > 0) {
    Object e = newList.get(0);
    if (checkCollision(p, e)) {
      if (e.getTop() - p.getTop() > 20) {
        enemies.remove(e);
      } else {
        p.respawn();
      }
    }
  }
}

public void resolveCollision(Object p, ArrayList<Object> list) {
  p.applyGravity(); // applicera gravitation

  p.updateY(p.getVelY()); // uppdatera gubbens y kordinat
  ArrayList<Object> newList = checkCollisionList(p, list);
  if (newList.size() > 0) {
    Object o = newList.get(0);
    if (checkCollision(p, o)) { // checka om det finns kollision mellan gubben och objekten
      if (p.getVelY() > 0) { // om gubbens y-hastighet är över 0 (går neråt)
        p.setBottom(o.getTop()); // sätt gubbens position till objektens topp
      } else if (p.getVelY() < 0) { // om gubbens y-hastighet är mindre än 0 (går uppåt)
        p.setTop(o.getBottom()); // sätt gubbens position till objekt botten
      }
    }
    p.setVelY(0); // sätt gubbens y-hastighet till 0
  }

  // samma gäller för x kordinat delen

  p.updateX(p.getVelX()); 
  newList = checkCollisionList(p, list);
  if (newList.size() > 0) {
    Object o = newList.get(0);
    if (checkCollision(p, o)) {
      if (p.getVelX() > 0) { 
        p.setRight(o.getLeft());
      } else if (p.getVelX() < 0) { 
        p.setLeft(o.getRight());
      }
    }
    p.setVelX(0);
  }
}

public void addEntities(String filename) {
  String[] lines = loadStrings(filename);
  for (int row = 0; row < lines.length; row++) {
    String[] values = split(lines[row], ",");
    for (int col = 0; col < values.length; col++) {
      switch(values[col]) {
      case "1":
        platforms.add(new Object(col * 32.0, row * 32.0, 32.0, 32.0, 66, 66, 66));
        break;
      case "2":
        final float leftEdge = col * 32.0;
        final float rightEdge = leftEdge + 6 * 32.0;
        enemies.add(new Object(col * 32.0, row * 32.0, 32.0, 32.0, leftEdge, rightEdge));
        break;
      case "3":
        p.setSpawn(col * 32, row * 32);
        p.setPosition(p.getSpawnX(), p.getSpawnY());
        break;
      }
    }
  }
}

public void scroll() {
  float right = view_x + width - RIGHT_DISTANCE_VIEW;
  if (p.getRight() > right) {
    view_x += p.getRight() - right;
    text_x += p.getRight() - right;
  }

  float left = view_x + LEFT_DISTANCE_VIEW;
  if (p.getLeft() < left) {
    view_x -= left - p.getLeft();
    text_x -= left - p.getLeft();
  }

  float bottom = view_y + height - VERTICAL_DISTANCE_VIEW;
  if (p.getBottom() > bottom) {
    view_y += p.getBottom() - bottom;
    text_y += p.getBottom() - bottom;
  }

  float top = view_y + VERTICAL_DISTANCE_VIEW;
  if (p.getTop() < top) {
    view_y -= top - p.getTop();
    text_y -= top - p.getTop();
  }

  translate(-view_x, -view_y);
}

private boolean up, left, right;

public class Object {
  private float x, y, w, h, spawn_x, spawn_y;
  private float vel_x, vel_y, gravity, leftEdge = 0, rightEdge = 0;
  private int lives, r, g, b;
  private boolean isPlayer = false;

  // platform
  public Object(float x, float y, float w, float h, int r, int g, int b) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.r = r;
    this.g = g;
    this.b = b;
  }

  // enemy
  public Object(float x, float y, float w, float h, float leftEdge, float rightEdge) {
    this.x = x;
    this.y = y;
    this.w = w;
    this.h = h;
    this.leftEdge = leftEdge;
    this.rightEdge = rightEdge;
    this.vel_x = 1.5;
    this.r = 100;
    this.g = 250;
    this.b = 200;
  }

  // player
  public Object() {
    this.x = 0; // start x kordinat
    this.y = 0; // start y kordinat
    this.spawn_x = this.x;
    this.spawn_y = this.y;
    this.vel_x = 0; // start x-hastighet
    this.vel_y = 0; // start y-hastighet
    this.w = this.h = 32; // storleken (höjd och bredd)
    this.lives = 3; // antal liv
    this.gravity = 0.2; // gravitation
    this.r = 0;
    this.g = 0;
    this.b = 0;
    this.isPlayer = true;
  }

  public void update() {
    fill(r, g, b);
    rect(x, y, w, h);
    movement();
  }

  // rörelse
  private void movement() {
    if (isPlayer) {
      if (!right && !left) {
        vel_x = 0;
      } else {
        if (right) {
          vel_x = 3;
        }
        if (left) { 
          vel_x = -3;
        }
      }
    } else if (leftEdge != 0 || rightEdge != 0) {
      x += vel_x;
      if (getLeft() <= leftEdge) {
        setLeft(leftEdge);
        vel_x *= -1;
      } else if (getRight() >= rightEdge) {
        setRight(rightEdge);
        vel_x *= -1;
      }
    }
  }

  public void jump() {
    vel_y = -5.5;
  }

  public int getLives() {
    return lives;
  }

  public float getTop() {
    return y;
  }

  public float getBottom() {
    return y + h;
  }

  public float getLeft() {
    return x;
  }

  public float getRight() {
    return x + w;
  }

  public float getLeftEdge() {
    return leftEdge;
  }

  public float getRightEdge() {
    return rightEdge;
  }

  public float getSpawnX() {
    return spawn_x;
  }

  public float getSpawnY() {
    return spawn_y;
  }

  public void setTop(float y) {
    this.y = y;
  }

  public void setBottom(float y) {
    this.y = y - h;
  }

  public void setLeft(float x) {
    this.x = x;
  }

  public void setRight(float x) {
    this.x = x - w;
  }

  public void setVelY(float vel) {
    vel_y = vel;
  }

  public void setVelX(float vel) {
    vel_x = vel;
  }

  public float getVelY() {
    return vel_y;
  }

  public float getVelX() {
    return vel_x;
  }

  public void applyGravity() {
    vel_y += gravity;
  }

  public void updateY(float vel) {
    y += vel;
  }

  public void updateX(float vel) {
    x += vel;
  }

  public void setSpawn(int x, int y) {
    spawn_x = x;
    spawn_y = y;
  }

  public void setPosition(float x, float y) {
    this.x = x;
    this.y = y;
  }

  public void respawn() {
    setPosition(spawn_x, spawn_y);
    lives--;
    vel_x = vel_y = 0;
  }
}

public void keyPressed() {
  switch (keyCode) {
  case UP:
    up = true;
    if (isOnPlatform(p, platforms))
      p.jump();
    break;
  case LEFT:
    left = true;
    break;
  case RIGHT:
    right = true;
    break;
  case ENTER:
    setup();
  }
}


public void keyReleased() {
  switch (keyCode) {
  case UP:
    up = false;
    break;
  case LEFT:
    left = false;
    break;
  case RIGHT:
    right = false;
  }
}
