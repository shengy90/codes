#SOLUTION TO A453 PROGRAMMING PROJECT
#CONTROLLED ASSESSMENT MATERIAL 2 TASK 1

#WRITTEN BY SHENG CHAI OF IMPERIAL COLLEGE LONDON
#FOR MR R. ISLAM OF BISHOP CHALLONER TOWER HAMLETS


#COPYRIGHT 1ST FEBRUARY 2015
#UNAUTHORISED COPYING OR REDISTRIBUTION IS NOT PERMITTED

#Note to students: Before writing, always:
#1) Analyse the given task - Make sure you fully understand what is required
#2) Plan/ Structure your code - Similar to writing an essay, plan in advance

#Task 1

#Step 1: Analyse requirements
#1) Generate a quiz gonsistic of a series of 10 random questions
#2) Questions should use 2 random numbers
#3) Addition, multiplication, subtraction 
#4) Output if the answer to each question is correct or not
#5) Produce a final score out of 10
#6) Ask for the student's name

#Step 2: Plan!
#1) 10 RANDOM questions. Need to invoke 'random'. Ask the questions 10 times.
#Number of iterations: 10 (known) -> Use For loop!
#2) Need to generate 2 random numbers. Let us assume the 2 numbers will be a
#random number between 1 and 10
#3) 3 cases -> Need to use if statements!
#4) right or wrong. 2 cases. Again, need to use if statements!
#5) final score -> Need to tally up the score.
#6) Don't forget to ask for the name!


#We need to generate a random number from 1 to 10. To do so, use the following
#command:

from random import randrange

#this command instructs Python to import the function randrange, and will
#allow us to use the 'randrange command'

#Declare a variable score, and an initial value of 0
score=0
#Ask for the student's name
name=input('What is your name? ')


for question in range(10):
    number1=randrange(10)
    number2=randrange(10)
    operation=randrange(3)

    #question here is a dummy variable.
    #randrange generates a random number in the range 0 - 9
    #2 random numbers are generated
    #operation -> This variable will be use to generate 3 cases: Addition
    #Subtraction, or Multiplication

    if operation==0: #Assign operation ==0 to addition
        #Print question
        print('Question: What is ',number1,' + ',number2,' ? ')
        #Ask user for answer
        result=int(input('Answer: '))
        #If this is true 
        if result == number1+number2:
            #do the following
            print('Correct!')
            #If the user is correct, add score by 1
            score=score+1
        else:
            #if user is wrong, do the following
            print('Wrong!')

    elif operation==1: #Assign operation == 1 to subtraction
        print('Question: What is ',number1,' - ',number2,' ? ')
        result=int(input('Answer: '))
        if result == number1-number2:
            print('Correct!')
            score=score+1
        else:
            print('Wrong!')

    else: #terminate if statements using 'else:'. 
        print('Question: What is ',number1,' x ',number2,' ? ')
        result=int(input('Answer: '))
        if result == number1*number2:
            print('Correct!')
            score=score+1
        else:
            print('Wrong!')

#print score
print('Your score is ',score)

#Step 3: Now check. Are all 5 requirements met?


