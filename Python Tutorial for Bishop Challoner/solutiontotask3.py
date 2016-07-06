#SOLUTION TO A453 PROGRAMMING PROJECT
#CONTROLLED ASSESSMENT MATERIAL 2 TASK 3

#WRITTEN BY SHENG CHAI OF IMPERIAL COLLEGE LONDON
#FOR MR R. ISLAM OF BISHOP CHALLONER TOWER HAMLETS


#COPYRIGHT 1ST FEBRUARY 2015
#UNAUTHORISED COPYING OR REDISTRIBUTION IS NOT PERMITTED

#Note to students: Before writing, always:
#1) Analyse the given task - Make sure you fully understand what is required
#2) Plan/ Structure your code - Similar to writing an essay, plan in advance

#Task 3

#Step 1: Analyse requirements
#1) Store only the last 3 scores
#2) Sort the data by 3 different ways: a)Alphabetical order with highest score
#b)Highest score, highest to lowest c)Average score, highest to lowest

#Step 2: Plan!
#1) Retain only the last 3 scores. Original code basically kept all the scores.
#Therefore we will need to count the number of times the student has done the
#test. IF MORE THAN 3 (USE IF LOOP!), remove earlier entries (REMOVE ENTRY FROM
#ARRAY, NEED TO USE '.pop'.
#2) Alphabetical order. Need to sort name array!
#3) Highest to lowest. Need to sort score array!
#4) Average, Highest to lowest. Need to count average!
#5) Need to also ask the teacher how the scores should be sorted --> IF LOOP!


#Declare a variable score, and an initial value of 0
score=0
#Ask for the student's name
studentname=str(input('What is your name? '))
#Ask for the student's class
studentclass=int(input('What is your class? '))


from random import randrange
#Copy the code from task 1 --> Asking the 10 questions
for question in range(10):
    number1=randrange(10)
    number2=randrange(10)
    operation=randrange(3)

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



'''
Note to students: In order to answer the full question, we will have to execute
the code from task 1 and 2 multiple times to generate a set of names and scores
for each class. For simulation and debugging purposes, we will assume that all
students have finished taking the test, and the teacher has collected all the
test results needed. Therefore I will create a 'fake' set of results. 
'''

class1name=['Sarah','John','Terry','Pippa']
class1score=[[1,5,7],[2,4],[4,7,1],[2]]
class2name=['Lucas','Angela','Stefan','Johann']
class2score=[[7,8,2],[3,5,6],[1,0,5],[3,5]]
class3name=['Marie','Antoine','Sebastien','Lucienne']
class3score=[[7,3,0],[3,4],[6,1],[0]]


#Create the 6 arrays needed

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
#If the student has done the test before, keep only the last 3 scores
#We will therefore need to count how many times the student has done the test
    
if (studentname in [i for i in classname]) == True:
    nameindex=classname.index(studentname)
    #This line gives the position of the student's score and name

    #Now, count how many times the student has done the test
    #len(array) gives the number of elements in an array
    scorecount=len(classscore[nameindex])

    #For example, studentclass=1, name='Terry'
    #nameindex=classname.index(name)
    #nameindex=2. Terry is in position:2 in the array classname
    #classscore[nameindex]=classscore[2]=[4,7,1] --> Terry's score
    #scorecount=len(classscore[2])=3 --> Terry has done the score 3 times



    #If the student has done the test more than 3 times, we want to only
    #retain the last 3 scores. Need an if loop!

    if scorecount>=3: #If the student has done the test 3 or more times

        classscore[nameindex].pop(0)#Removes the first element in the array
        classscore[nameindex].append(score) #Adds current score to the list

    else: #If the student hasn't done the test 3 or more times 
        classscore[nameindex].append(score) #Adds current sore to the list
        
else: #If the student hasn't done the test before
    classname.append(studentname)
    classscore.append([score])
   
if studentclass==1: 
    class1name=classname
    class1score=classscore
elif studentclass==2:
    class2name=classname
    class2score=classscore
else:
     class3name=classname
     class3score=classscore

#Now we have kept only the relavent score, we need to ask the teacher how
#the score needs to be sorted

classofstudent=int(input('What class do you want to display the scores of? (Enter 1, 2, or 3) '))
if classofstudent==1:
    chosenclassname=class1name
    chosenclassscore=class1score
elif classofstudent==2:
    chosenclassname=class2name
    chosenclassscore=class2score
else:
    chosenclassname=class3name
    chosenclassscore=class3score


sortmethod=int(input('How do you want to display the scores? (1:alphabetical order, max score, 2:by highest score, highest to lowest, 3:by average score, highest to lowest'))


     
if sortmethod ==1:
    #Method 1: Alphabetical Order
    maxscore=[0]*len(chosenclassscore)
    nameandscore=[0]*len(chosenclassscore)
    #Recall that for indexing arrays using for loops, the size of the arrays
    #must be prespecified, with initial values of 0. For more information on
    #this, see the programming guide book.
    
    for y in range(len(chosenclassscore)):

        #max(array) gives the maximum value of the array.
        #Note that chosenclassscore is a nested array!
        maxscore[y]=max(chosenclassscore[y])
        #Result of this line:
        #chosenclassscore=[[1,5,7],[2,4],[4,7,1],[2]]
        #chosenclassscore[0]=[1,5,7] -> max(chosenclassscore[0])=7
        #->maxscore[0]=7
        #for loop repeats for len(chosenclassscore) times. Resulting output:
        #maxscore=[7,4,7,2]


        #creating a nested array. first element=name. second element=max score
        nameandscore[y]=chosenclassname[y],maxscore[y]
        #chosenclassname=['Sarah','John','Terry','Pippa']
        #chosenclassname[0]='Sarah'
        #maxscore[0]=7 (Sarah's maximum score)
        #therefore nameandscore[0]=[('Sarah',7)]
        #for loop repeats for (chosenclassscore) times. Resulting output:
        #nameandscore[y]=[('Sarah', 7), ('John', 9), ('Terry', 7), ('Pippa', 2)]
        #END OF FOR LOOP!


    #Note indentation. This line is not in the for loop!
    #sorted(array) sorts the array from lowest to highest.
    #if the array is a nested array, it sorts the first element of the nested
    #elements
    alphabeticalorder=sorted(nameandscore)

    #For Example:
    #nameandscore[y]=[('Sarah', 7), ('John', 9), ('Terry', 7), ('Pippa', 2)]
    #the first element in each nested elements is the name in this case.
    #sorted will sort the element from A to Z.
    #Resulting output:
    #[('John', 9), ('Pippa', 2), ('Sarah', 7), ('Terry', 7)]
    

    #Prints the name!
    for y in range(len(chosenclassscore)):
        #Recall, to access elements in an array, type array[index],
        #where 'array' refers to the array of interest, and 'index' refers
        #to the index of the element you want to find
        #if the array is a nested array, for example:
        #array=[('John', 9), ('Pippa', 2), ('Sarah', 7), ('Terry', 7)]
        #array[2][1]=7
        #array[1][1]='Pippa'
        print(alphabeticalorder[y][0],' scored ',alphabeticalorder[y][1])




elif sortmethod ==2:
    #sorting by highest score. Same method as above.
    maxscore=[0]*len(chosenclassscore)
    for y in range(len(chosenclassscore)):
        #array with the highest scores of each student
        maxscore[y]=max(chosenclassscore[y])
        #attaches the name to the highest score
        nameandscore[y]=maxscore[y],chosenclassname[y]
                   
    highestorder=sorted(nameandscore, reverse=True)
    #Recall that sorted sorts from lowest value to highest value?
    #To do the opposite, use 'reverse=True'.
    #Note, it's True, not true!
    
    for y in range(len(chosenclassscore)):
        print(highestorder[y][1], ' highest score is ',highestorder[y][0]


else:
    #Sorting average score from highest to lowest
    #First, you need to calculate the average.
    
    averagescore=[sum(i)/len(i) for i in chosenclassscore]
    #This line looks a little bit complicated, but it means the same thing
    #as 'i for i in array' mentioned earlier. Note that 'i' is a dummy variable.
    #This line literally means for every element in chosenclassscore,
    #take the sum of each element, divided by it's size.
    #For example, chosenclassscore=[[1,5,7],[2,4],[4,7,1],[2]]
    #averagescore=[sum(i)/len(i) for i in chosenclassscore] means
    #averagescore=[sum(1,5,7)/3 , sum(2,4)/2, sum(4,7,1)/3, sum(2)/1]
                 

    #Initialising array for indexing          
    nameandscore=[0]*len(averagescore)
    for y in range(len(averagescore)):
        nameandscore[y]=averagescore[y],chosenclassname[y]


    averageorder=sorted(averagescorewithname, reverse=True)
    for y in range(len(averageorder)):
        print(averageorder[y][1],' average sccore is ',averageorder[y][0])    
    
    
   
  

    





        
