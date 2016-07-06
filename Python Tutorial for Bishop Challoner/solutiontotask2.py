#SOLUTION TO A453 PROGRAMMING PROJECT
#CONTROLLED ASSESSMENT MATERIAL 2 TASK 2

#WRITTEN BY SHENG CHAI OF IMPERIAL COLLEGE LONDON
#FOR MR R. ISLAM OF BISHOP CHALLONER TOWER HAMLETS


#COPYRIGHT 1ST FEBRUARY 2015
#UNAUTHORISED COPYING OR REDISTRIBUTION IS NOT PERMITTED

#Note to students: Before writing, always:
#1) Analyse the given task - Make sure you fully understand what is required
#2) Plan/ Structure your code - Similar to writing an essay, plan in advance

#Task 2

#Step 1: Analyse requirements
#1) Keep track of scores of each member
#2) 3 classes. Data should be kept separately
#3) We need to store the score. But what happens if the student has done the
#test before? Which scores should we keep?


#Step 2: Plan!
#1) Code should ask for the student's name and class
#2) Data stored separately for each class. Therefore 3 separate arrays will
#be needed.
#3) 2 types of data within each class - name, score. 3 classes in total.
#Therefore, 6 arrays in total!
#4) Answer from task 1 will be needed for this task.
#5) For this task, let us assume that we will store all the student's score.
#We would therefore need to check if the student has done the test.
#If he has done it, do something. If he hasn't, do something else.
#TWO CASES -> If statement!
#6)We will need to ADD elements to an array --> need to use .append!



#Declare a variable score, and an initial value of 0
score=0
#Ask for the student's name
studentname=input('What is your name? ')
#Ask for the student's class
studentclass=input('What is your class? ')

from random import randrange
#Copy the code from task 1 --> Asking the 10 questions
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

#Now we have the student's name, class, and score, we need to store them into
#the respective arrays

#Create the 6 arrays needed
class1name=[]
class1score=[]

class2name=[]
class2score=[]

class3name=[]
class3score=[]
#nameofarray=[] -> ='[]' creates an empty array.

#We need to classify the name and score into their respective classes
#If class 1, store in class 1 array and so on. --> THREE CASES --> IF LOOP!

if studentclass==1: #If student is in class 1, do the following
    classname=class1name
    classscore=class1score
elif studentclass==2:
    classname=class2name
    classscore=class2score
else:
    classname=class3name
    classscore=class3score

#Now, check if the student has done the test before

if (name in [i for i in classname]) == True:
    #if (statement) == True: means "if the statement in the parenthesis is
    #true, then do the following"
    #'i for i in array' literally means for every element in array. i here
    #is a dummy variable
    #name in [i for i in classname] literally means "if the variable 'name'
    #exist in the array called classname"
    #Therefore the line 'if (name in [i for i in classname]) == True:' test
    #the statement "if variable 'name' exist in array called classname"
    #and if the statement is true do the following:



    #classname.index(variable) gives the index(position) of the variable 'name'
    #in the array 'classname'
    #For example,
    #classname=['John','Casey','Kate']
    #nameindex=classname.index('Casey')
    #Therefore, nameindex=1
    nameindex=classname.index(name)
    
    
    #To access an element in an array, type: array[index], where 'array' is the
    #array in question, and 'index' is the position you are interested in
    #For example,
    #a=[1,2,3]
    #a[1]=2
    #a[0]=1
    #Remember that Python starts counting from 0!!
    classscore[nameindex].append(score)
    #therefore, 'classscore[nameindex]' accesses the students score.
    #'.append(score)' adds the current score to the list.
    #Note that classscore here is a nested array!
    #For example, classscore=[[5,1,3],[4,7,8],[9,0,2]]
    #classscore[1].append(3) does the following:
    #classscore[[5,1,3],[4,7,8,3],[9,0,2]
    

#If the student hasn't done the test before, do the following    
else:
    #Adds the student's name to the list
    classname.append(name)
    #Add's the student's score to the following
    classscore.append([score])
    #Reminder, classscore is a nested array.
    #For example, classscore=[[5,1,3],[4,7,8,3],[9,0,2]]
    #classscore.append([6])
    #classscore=[[5,1,3],[4,7,8,3],[9,0,2],[6]]

    #For more information on nested array, see the
    #programming handbook I have written
    

if studentclass==1: #If student is in class 1, do the following
    class1name=classname
    class1score=classscore
elif studentclass==2:
    class2name=classname
    class2score=classscore
else:
     class3name=classname
     class3score=classscore

#To students from my tutoring class, you will realise at this point that
#this solution is slightly different from your solution. Remember I said that
#there is no 1 correct solution when it comes to programming?
#This is exactly what I mean. There are many ways to solve the same problem.
#Yours is equally valid as mine. However, I have found a way to shorten the code
#whilst performing the same function. In programming, we always aim to
#find the shortest way possible to write a code. The shorter, the better!


#In your code, you had to copy and paste the same set of lines that does
#the exact same thing for each class, which is rather chunky.
#What I have done here is that I have one paragraph that basically does it for
#all 3 cases, resulting in a shortened code. You can compare the uncommented
#with your code to see the difference.    

     

#Step 3: Now check. Are all 3 requirements met?


#EXTRA:
#Now that you've got the basic code running, think of other ways that you can
#improve, either by shortening, or adding more functions that make it more
#convenient for the user.
#For example, if there are many students queueing up to do the test, this code
#will require the teacher to run the test every single time someone is sitting
#the test. Perhaps there is one way you can automate the process?

#Hint: This will require the use of while loops. For students not in my tutoring
#class, perhaps you could ask Justin, Jennifer, or Vlad for some guidance!

     
