@accepts(tuple,bool)
@returns(string)
def print_formula(f, return_result = False):
	ret = ""
	if is_term(f):
		if is_constant(f):
			ret += str(get_value(f))
		elif is_variable(f):
			ret += "?" + get_name(f)
		elif is_function_call(f):
			ret += get_head(f) + "[" + "".join([print_formula(arg, True) + "," for arg in get_args(f)])[:-1] + "]"
		else:
			ret += "???"
	elif is_atom(f):
		ret += get_head(f) + "(" + "".join([print_formula(arg, True) + ", " for arg in get_args(f)])[:-2] + ")"
	elif is_sentence(f):
		# negation, conjunction or disjunction
		args = get_args(f)
		if len(args) == 1:
			ret += get_head(f) + print_formula(args[0], True)
		else:
			ret += "(" + get_head(f) + "".join([" " + print_formula(arg, True) for arg in get_args(f)]) + ")"
	else:
		ret += "???"
		print(ret)

@accepts(tuple, dict)
def occur_check(v, t, subst):
	# TODO:
	if(v == t):
		return True
	elif get_name(t) in subst:
		return occur_check(v, subst[get_name(t)], subst)
	elif has_args(t):
		checker = False
		for arg in t[-1]:
			checker |= occur_check(v, arg, subst)
		return checker
	else:
		return False

# Test!
test_batch(2, globals())
''' TODO: creati functie de unificare a formulelor prin substitutii '''

# Unifica formulele f1 si f2, sub o substitutie existenta subst.
# Rezultatul unificarii este o substitutie (dictionar nume-variabila -> termen),
# astfel incat daca se aplica substitutia celor doua formule, rezultatul este identic.
@accepts(tuple, tuple, dict)
@returns(dict)
def unify(f1, f2, subst = None):
	if subst is None:
		subst = {}
	# TODO1: pre-procesati formulele
	S = []
	S.append((f1, f2))

	while S:
		(f1, f2) = S.pop()

		# TODO2: reduceti formulele la elemente neinregistrate in subst
		while get_name(f1) in subst:
			f1 = subst[get_name(f1)]
		while get_name(f2) in subst:
			f2 = subst[get_name(f2)]


		if f1 != f2:
			if is_variable(f1):
				if occur_check(f1, f2, subst):
					return False
				else:
					subst[get_name(f1)] = f2
			elif is_variable(f2):
				if occur_check(f2, f1, subst):
					return False
				else:
					subst[get_name(f2)] = f1
			elif has_args(f1) and has_args(f2) and len(get_args(f1)) == len(get_args(f2)):
				if get_head(f1) == get_head(f2):
					for i in range(len(get_args(f1))):
						S.append((f1[-1][i], f2[-1][i]))
				else:
					return False
			else:
				return False

	# TODO: returnati substitutiile
	return subst

# Test!
test_batch(3, globals())