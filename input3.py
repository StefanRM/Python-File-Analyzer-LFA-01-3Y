# TODO: task1
# TODO0: scrie o functie care contine o functie!
# TOasfw asda
# TODO1: nu uita sa scrii functia mentionata anterior!

''' TODO: creati functie de unificare a formulelor prin substitutii '''
''' TODO0: un todo mai lung
pe 2 linii'''
''' comentariu de test '''
''' alt 
comentariu de test'''
def outer(num1 = 0
):
	@accepts(int)
	@returns(int)
    def inner_increment(num1,
num100 = "lll" ):  # hidden from outer code
    	@accepts(int)
        def inner_increment2(a, b = 1, c = "aaa"):
        	# TODO0: deepest function comment
        	return a + 1
        num1 = inner_increment2(num1)
        return num1 + 1
    # TODO: un todo in functie
    # comentariu in functie
    ''' comentariu pe
    mai multe linii in functie '''
    num2 = inner_increment(num1)
    # TODO2: inca un todo in functie
    print(num1, num2)

outer(10)

# TODO: nu uita sa implementezi
''' TODO10: un alt todo autentic '''
''' comentariu'''
''' comentariu
pe mai
multe linii'''

@returns(int)
def sum(x , y = 0): # make sum of two numbers
	# TODO: must revise this
	@accepts(int)
	def do_it(): # function to do the summation
		# TODO2: make it complex
		return x + y
	''' TODO: 2 lines
comment -> must complete function '''
	return do_it

a = sum(1, 3)

@accepts(int)
@returns(int)
def factorial(number = 0):

    # error handling
    if not isinstance(number, int):
        raise TypeError("Sorry. 'number' must be an integer.")
    if not number >= 0:
        raise ValueError("Sorry. 'number' must be zero or positive.")

    @accepts(int, bool)
    def inner_factorial(number):
        ''' TODO: test this up! '''
        # stop condition
        if number <= 1:
            return 1
        return number*inner_factorial(number-1)
    return inner_factorial(number)

# call the outer function
print(factorial(4))