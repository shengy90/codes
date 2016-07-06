import random
lowerLimit,upperLimit,numberOfGuesses = 1,100,0
secretNumber=(random.randint(lowerLimit, upperLimit))
#print ('Secret Number: '+str(secretNumber))

def makeGuess(lowerLimit, upperLimit, numberOfGuesses):
	mid = int((upperLimit - lowerLimit)/2 + lowerLimit)
	guess= mid
	numberOfGuesses+=1
	return guess, numberOfGuesses

firstGuess, numberOfGuesses = makeGuess(
	lowerLimit, upperLimit, numberOfGuesses)
print('First guess: {}. Number of guesses: {}'.format(
	firstGuess,numberOfGuesses))

guess=firstGuess
def checkGuess(guess,numberOfGuesses,lowerLimit,upperLimit):
	while guess != numberOfGuesses:
		if guess<secretNumber:
			previousGuess = guess
			lowerLimit = guess
			guess,numberOfGuesses=makeGuess(lowerLimit,upperLimit,numberOfGuesses)
			print('{} is too low ! Next guess: {}. Number of guesses: {}.'.format(
				previousGuess,guess, numberOfGuesses))

		elif guess>secretNumber:
			previousGuess = guess
			upperLimit = guess
			guess, numberOfGuesses = makeGuess(lowerLimit,upperLimit,numberOfGuesses)
			print('{} is too high! Next guess: {}. Number of guesses: {}.'.format(
				previousGuess,guess,numberOfGuesses))
		else:
			print('{} is the correct guess! Number of guesses: {}.'.format(
				guess,numberOfGuesses))
			break

checkGuess(guess,numberOfGuesses,lowerLimit,upperLimit)