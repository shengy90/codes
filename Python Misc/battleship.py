from random import randint #Import randint from random

board = []                  #initiating array for the score board

for x in range(5):
    board.append(["O"] * 5) #Creating 5X5 rows and colums of Os

def print_board(board):
    for row in board:
        print (" ".join(row)) #Getting rid of the commas

print ("Let's play Battleship!")
print_board(board)          

def random_row(board):      #Generating random coordinates for the position of the ship
    return randint(0, len(board) - 1)

def random_col(board):
    return randint(0, len(board[0]) - 1)

ship_row = random_row(board)    
ship_col = random_col(board)



if __name__ == '__main__':
    for turn in range (4):
        
        if turn == 3:   #Maximum 3 tries
        
            print ("Game Over")
            print ("Ship was located at row: %s and column %s" %(ship_row,ship_col))
        
        else:
        
            print ("Turn"), turn+1    #Print turn number

            guess_row = int(input("Guess Row:")) #Ask for guess 
            guess_col = int(input("Guess Col:"))
            
            if guess_row == ship_row and guess_col == ship_col:
                print ("Congratulations! You sunk my battleship!") #HIT
                break
            
            else: #MISS
                if (guess_row < 0 or guess_row > 4) or (guess_col < 0 or guess_col > 4): #If guess is outside the board
                    print ("Oops, that's not even in the ocean.")
                elif(board[guess_row][guess_col] == "X"):
                    print ("You guessed that one already.")
                else: #repeated guess
                    print ("You missed my battleship!")
                    board[guess_row][guess_col] = "X"
                # Print (turn + 1) here!
                print_board(board) 
