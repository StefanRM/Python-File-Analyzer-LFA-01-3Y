@accepts(int, bool)
@returns(int)
def incr(  num1    =    0   ,
  randParam1 = 5,   randParam2 = "null"): # jajaj
    num2 = num1 + 1
    ''' TODO: fa asta!
 si asta! '''
    print(num1, num2)
    # comment random
    # TODO1: nu uita return...

incr(10)

# TODO: implement complex printing

# Function definition is here
@accepts(string)
def printme( str ):
	print(str)
	# TODO0: make it more complex
	return

# Now you can call printme function
printme("I'm first call of printme() function!")
printme("Again second call to the same function")


@returns(bool)
def isPalindrome(string = "" ): # classic function
	# TODO: comment all lines
	left_pos = 0
	right_pos = len(string) - 1
	''' TODO0: write less '''
	
	# checks characters while going to the middle
	while right_pos >= left_pos:
		if not string[left_pos] == string[right_pos]:
			return False
		left_pos += 1
		right_pos -= 1
	# TODO2: do another function
	return True
print(isPalindrome('aza'))