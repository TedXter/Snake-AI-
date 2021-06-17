import java.util.*;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
LinkedList<Square> snake = new LinkedList<Square>();
int rowsxcols = 50;
int spawnX = 0;
int spawnY;
int foodX = rowsxcols/2, foodY = foodX;
int sqDimension;
int speed = 5;
Square[][] grid = new Square[rowsxcols][rowsxcols];
Square direction = new Square(0, 1);
boolean paused = false;
boolean ai = true;
boolean keyPressedYet = false;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class Square{
  double f;
  double h;
  double g = 0;//distance from the head of the snake which is snake.get(snake.size()-1);
  Square parent;//needed to find the path back
  int x;
  int y;
  boolean isSnake = false;
  boolean isFood = false;
  //need this constructor to construct direction objects
  Square(int y, int x){
    this.x = x;
    this.y = y;
  }
  //to make the square objects on the grid
  Square(int y, int x, double h){
    this.x = x;
    this.y = y;
    this.h = h;
    this.f = g + h;
  }
  // draw the square with a specified color in RGB
  void show(int r, int g, int b){
    fill(r, g, b);
    stroke(0); 
    rect(this.x * sqDimension , this.y * sqDimension, sqDimension, sqDimension);
  }
  
  // compare squares with their coordinates
  boolean equals(Object obj){
    if(obj instanceof Square){
      return x == ((Square)obj).x && y == ((Square)obj).y;
    }
    return false;
  }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// returns a square given coordinates and the grid
static Square getSquare(Square[][] grid, int i, int j){
  for(Square[] a: grid){
    for(Square s: a){
      if(s.y == i && s.x == j){
        return s;
      }
    }
  }
  return null;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//TODO 
//checks if the snake has a way out, if it arrives at this square
//DFS until we reach a dead end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static Square[] neighborsOf(Square s, Square direction, Square[][] grid, int dx, int dy){
   Square[] n = new Square[3];
   int i = s.y;
   int j = s.x;
   Square right = getSquare(grid, i, j+1);
   Square left = getSquare(grid, i, j-1);
   Square up = getSquare(grid, i-1, j);
   Square down = getSquare(grid, i+1, j); 
  if(direction.x > 0){
    //prior up, down, or right
    if(dy < 0){
      //prior up or right
      if(abs(dx) > abs(dy)){
        //prior right
        n = new Square[]{right, up, down};
      }else{
        //prior up
        n = new Square[]{up, right, down};
      }
    }else{
      //prior down or right
      if(abs(dx) > abs(dy)){
        //right
        n = new Square[]{right, down, up};
      }else{
        //down
        n = new Square[]{down, right, up};
      }
    }
  }else if(direction.x < 0){
    //up, down, or left
    if(dy < 0){
      //prior up or left
      if(abs(dx) > abs(dy)){
        //left
        n = new Square[]{left, up, down};
      }else{
        //up
        n = new Square[]{up, left, down};
      }
    }else{
      //prior down or left
      if(abs(dx) > abs(dy)){
        //left
        n = new Square[]{left, down, up};
      }else{
        //down
        n = new Square[]{down, left, up};
      }
    }
  }else if(direction.y > 0){
    //left, right, or down
    if(dx < 0){
      //prior left or down
      if(abs(dy) > abs(dx)){
        //down
        n = new Square[]{down, left, right};
      }else{
        //left
        n = new Square[]{left, down, right};
      }
    }else{
      //prior right or down
      if(abs(dy) > abs(dx)){
        //down
        n = new Square[]{down, right, left};
      }else{
        //right
        n = new Square[]{right, down, left};
      }
    }
  }else{
    //left, right, or up
    if(dx < 0){
      //prior left or up
      if(abs(dy) > abs(dx)){
        //up
        n = new Square[]{up, left, right};
      }else{
        //left
        n = new Square[]{left, up, right};
      }
    }else{
      //prior right or up
      if(abs(dy) > abs(dx)){
        //up
        n = new Square[]{up, right, left};
      }else{
        //right
        n = new Square[]{right, up, left};
      }
    }
  }
  return n;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void setup(){
  size(1000, 1000);
  background(0);
  sqDimension = height/rowsxcols;
  spawnY = rowsxcols/2;
  foodX = rowsxcols/2;
  foodY = foodX;
  // Heuristic scores for each square initialized to their manhattan distance 
  // (euclidian distance makes the snake do zigzags and thats too chaotic) 
  //initialize the grid
  for(int i = 0; i < grid.length; i++){
    for(int j = 0; j < grid[i].length; j++){
      grid[i][j] = new Square(i, j, abs(foodY-i) + abs(foodX-j)); //create a new Square (y, x, eucledian distance from the coordinate of the food)
    }
  }
  //start of the snake
  grid[spawnY][spawnX].isSnake = true;
  snake.offer(grid[spawnY][spawnX]);
  grid[foodY][foodX].isFood = true;
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void draw(){
  if(frameCount % speed == 0){
    background(0);
    if(grid[snake.getLast().y][snake.getLast().x].isFood){
        Square tail = snake.getFirst();
        Square head = snake.getLast();
        int newY = head.y + direction.y;
        int newX = head.x + direction.x;
        
        grid[head.y][head.x].isFood = false;

        if(newY < rowsxcols && newY >= 0 && newX < rowsxcols && newX >= 0 && !snake.contains(grid[newY][newX])){
          grid[tail.y][tail.x].isSnake = false;
          grid[newY][newX].isSnake = true;
          snake.offer(grid[newY][newX]);
        }else{
          noLoop();
        }
        //squares on the game not occupied by the snake
        //need to update this is not efficient at all
        ArrayList<Square> emptySpace = new ArrayList<Square>();
        for(Square[] a: grid){
          for(Square b: a){
            if(!b.isSnake){
              emptySpace.add(b);
            }
          }
        }
        // a new random place for the food to appear
        int randIndex = (int)random(emptySpace.size());
        Square randSquare = emptySpace.get(randIndex);
        grid[randSquare.y][randSquare.x].isFood = true;
        foodX = randSquare.x;
        foodY = randSquare.y;
      }else{
        //if the snake didnt eat food
        Square tail = snake.getFirst();
        Square head = snake.getLast();
        int newY = head.y + direction.y;
        int newX = head.x + direction.x;
        if(newY < rowsxcols && newY >= 0 && newX < rowsxcols && newX >= 0 && !snake.contains(grid[newY][newX])){
          snake.poll();
          grid[tail.y][tail.x].isSnake = false;
          grid[newY][newX].isSnake = true;
          snake.offer(grid[newY][newX]);
          snake.getLast().g = 0; 
        }else{
          //snake dies :(
          noLoop();
        }
      }
    // Show the game
    for(Square[] a: grid){
      for(Square s: a){
        s.h = abs(foodY-s.y) + abs(foodX-s.x);
        if(s.isSnake){
          s.show(0, 255, 0);
          continue;
        }else if(s.isFood){
          s.show(255, 0, 0);
          continue;
        }
        s.show(0, 0, 0);
      }
    }
    //show the score
    fill(255);
    textAlign(CENTER, BOTTOM);
    text("Score: " + snake.size()+ "", 50, 50);
    //AI part
    if(ai){   
      Square h = snake.peekLast();
      int i = h.y;
      int j = h.x;
      int dy = foodY - h.y;
      int dx = foodX - h.x;
      //the possible ways to go from the head of the snake, the neighbors
      //sorted by priority
      Square[] neighbors = neighborsOf(h, direction, grid, dx, dy);
      int min = -1;
      double minH = Double.MAX_VALUE; // the value of the minimum heuristic
      for(int n = 0; n < neighbors.length; n++){
        Square curr = neighbors[n];
        //skip the neighbors that the snake cannot move to
        if(curr == null)continue;
        else if(curr.isSnake)continue;
        if(curr.h <= minH){
          min = n;
          minH = curr.h;
        }
      }
      //guaranteed a direction, unless snake arrives at a deadend
      if(min >= 0){
         direction = new Square(neighbors[min].y - i, neighbors[min].x - j);
      }
    }
    
    //can now recieve input from user
    keyPressedYet = false;
  }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void keyPressed(){
  // pause and unpause
  if(keyCode == 80){
    if(paused){
      loop();
      paused = false;
    }else{
      noLoop();
      paused = true;
    }
  }
  // speed of the game
  if(keyCode == 70){
    if(speed > 1) speed--;
  }
  if(keyCode == 83){
    if(speed < 5) speed++;
  }
  // a - turn on ai
  if(keyCode == 65){
    if(ai){
      ai = false;
    }else{
      ai = true;
    }
  }
  // KEYBOARD CONTROLS
  if(!keyPressedYet){
    switch(keyCode){
    //left
    case 37: 
      if(direction.y != 0){
        direction = new Square(0, -1);
      }
      break;
    //up
    case 38: 
      if(direction.x != 0){
        direction = new Square(-1, 0);
      }
    break;
    //right
    case 39:
      if(direction.y != 0){
        direction = new Square(0, 1);
      }
    break;
    //down
    case 40:
      if(direction.x != 0){
        direction = new Square(1, 0);
      }
    break;
    default: break;
    }
    keyPressedYet = true;
  }

}
