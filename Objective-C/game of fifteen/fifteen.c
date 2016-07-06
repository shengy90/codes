/**
 * fifteen.c
 *
 * Computer Science 50
 * Problem Set 3
 *
 * Implements Game of Fifteen (generalized to d x d).
 *
 * Usage: fifteen d
 *
 * whereby the board's dimensions are to be d x d,
 * where d must be in [DIM_MIN,DIM_MAX]
 *
 * Note that usleep is obsolete, but it offers more granularity than
 * sleep and is simpler to use than nanosleep; `man usleep` for more.



Instructions to play the game.

Rearrange the numbers such that:

for a 3X3 board (example),
you should get

1 2 3
4 5 6
7 8 _ 
 */
 
#define _XOPEN_SOURCE 500

#include <cs50.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

// constants
#define DIM_MIN 3
#define DIM_MAX 9

// board
int board[DIM_MAX][DIM_MAX];

// dimensions
int d;

//position of blank tile
int blank_tile_x;
int blank_tile_y;

//position of chosen tile
int tile_x;
int tile_y;

// prototypes
void clear(void);
void greet(void);
void init(void);
void draw(void);
bool move(int tile);
bool won(void);

int main(int argc, string argv[])
{
    // ensure proper usage
    if (argc != 2)
    {
        printf("Usage: fifteen d\n");
        return 1;
    }

    // ensure valid dimensions
    d = atoi(argv[1]);
    if (d < DIM_MIN || d > DIM_MAX)
    {
        printf("Board must be between %i x %i and %i x %i, inclusive.\n",
            DIM_MIN, DIM_MIN, DIM_MAX, DIM_MAX);
        return 2;
    }

    // open log
    FILE* file = fopen("log.txt", "w");
    if (file == NULL)
    {
        return 3;
    }

    // greet user with instructions
    greet();

    // initialize the board
    init();

    // accept moves until game is won
    while (true)
    {
        // clear the screen
        clear();

        // draw the current state of the board
        draw();

        // log the current state of the board (for testing)
        for (int i = 0; i < d; i++)
        {
            for (int j = 0; j < d; j++)
            {
                fprintf(file, "%i", board[i][j]);
                if (j < d - 1)
                {
                    fprintf(file, "|");
                }
            }
            fprintf(file, "\n");
        }
        fflush(file);

        // check for win
        if (won())
        {
            printf("ftw!\n");
            break;
        }

        // prompt for move
        printf("Tile to move: ");
        int tile = GetInt();
        
        // quit if user inputs 0 (for testing)
        if (tile == 0)
        {
            break;
        }

        // log move (for testing)
        fprintf(file, "%i\n", tile);
        fflush(file);

        // move if possible, else report illegality
        if (!move(tile))
        {
            printf("\nIllegal move.\n");
            usleep(500000);
        }

        // sleep thread for animation's sake
        usleep(500000);
    }
    
    // close log
    fclose(file);

    // success
    return 0;
}

/**
 * Clears screen using ANSI escape sequences.
 */
void clear(void)
{
    printf("\033[2J");
    printf("\033[%d;%dH", 0, 0);
}

/**
 * Greets player.
 */
void greet(void)
{
    clear();
    printf("WELCOME TO GAME OF FIFTEEN\n");
    usleep(1000000);
}

/**
 * Initializes the game's board with tiles numbered 1 through d*d - 1
 * (i.e., fills 2D array with values but does not actually print them).  
 */
void init(void)
{
    //Biggest number will be squared of dimension - 1
    int biggest_number = d*d - 1;
    //Populate backwards from left to right, top to bottom using nested for loops.
    for (int i=0; i<d; i++) {
        for (int j=0; j<d;j++) {
                board[i][j]=biggest_number;
                biggest_number=biggest_number - 1;
        }
    }
    
    //if biggest number is odd, swap position 1 and 2

    if ((d*d-1) % 2 != 0) {
        for (int i=0; i<d; i++) {
            for (int j=0; j<d; j++) {
                int placeholder;
                if (board[i][j]==1) {
                        placeholder=2;
                } else if (board[i][j]==2) {
                    placeholder = 1;}
                    else {
                        placeholder = board[i][j];
                }
                
                board[i][j] = placeholder;
            }
        }
    } 
}

/**
 * Prints the board in its current state.
 */
void draw(void)
{
    for (int i=0; i<d; i++) {
        
        for (int j=0; j<d; j++) {
            if(board[i][j]>0) {
                printf("%2d ", board[i][j]);
            } else {
                printf(" _");
                blank_tile_x = i;
                blank_tile_y = j;
            }
        }
        printf("\n \n");
        
    }
}

/**
 * If tile borders empty space, moves tile and returns true, else
 * returns false. 
 */
bool move(int tile)
{
    // TODO
    for (int i=0; i<d; i++) {
        for (int j=0; j<d; j++) {
            if (tile == board[i][j]) {
                tile_x = i;
                tile_y = j;
                
                if (
                    //prevent diagonal swaps    
                            //x position is adjacent to blank tile but y position is the same
                            ((tile_x == blank_tile_x + 1 || tile_x == blank_tile_x -1 ) && tile_y == blank_tile_y) ||
                            //or y position is adjacent to blank tile but x position is the same
                            ((tile_y == blank_tile_y + 1 || tile_y == blank_tile_y - 1) && tile_x == blank_tile_x)
                    ) {
                        board[tile_x][tile_y] = 0;
                        board[blank_tile_x][blank_tile_y] = tile;
                        return true;
                    }
            }
        }
    }
    return false;
}

/**
 * Returns true if game is won (i.e., board is in winning configuration), 
 * else false.
 */
bool won(void)
{
    int win_sequence = 1;
    for (int i = 0; i<d; i++) {
        for (int j=0; j<d; j++) {
            if (win_sequence < d*d) {
                if (board[i][j] != win_sequence) {
                    return false;
                } else {
                    win_sequence++;
                }
            }
        }
    }
    return true;
}