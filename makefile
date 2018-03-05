# MAFTEI Stefan - Radu, grupa 336CC
build: tema.l
	flex tema.l
	gcc lex.yy.c -lfl -o tema.out

run: tema.out
	./tema.out < input.py

run2: tema.out
	./tema.out < input2.py

run3: tema.out
	./tema.out < input3.py

clean: tema.out
	rm tema.out
	rm lex.yy.c
