MAFTEI Stefan - Radu, grupa 336CC
.___________. _______ .___  ___.      ___      
|           ||   ____||   \/   |     /   \     
`---|  |----`|  |__   |  \  /  |    /  ^  \    
    |  |     |   __|  |  |\/|  |   /  /_\  \   
    |  |     |  |____ |  |  |  |  /  _____  \  
    |__|     |_______||__|  |__| /__/     \__\ 


    === Implementarea ===

    Programul isi propune sa utilizeze FLEX C pentru a citit un fisier python
cu o anumita complexitate.
	Astfel se vor putea identifica functii. In cadrul acestora se pot
identifica parametri default, daca functia intoarce sau nu ceva (return), daca
exista comentarii de tip TODO.
	In afara functiilor TODO-urile sunt considerate task-uri.
	Functiile pot fi precedate de deocoratori:
	- @accepts -> tipul parametrilor (se va verifica daca nr de parametri din
accepts este egal cu cel al parametrilor din functie);
	- @returns -> daca functia intoarce ceva.
	Daca decoratorii nu sunt indepliniti se afiseaza un mesaj.
	De asemenea functiile pot contine functii interne care si ele pot contine
ce contin si functiile normale sau pot fi precedate de decoratori.
	Se va mai afisa si faptul ca functiile contin return si numarul de linii
de cod continute (decoratorii, comentariile si liniile goale nu se numara).

	Pentru a putea tine evidenta functiilor imbricate din cadrul fisierului
am creat o structura de date in care retin detaliile legate de o functie python
in care se afla si un array de parametri (parametri au si ei o structura de
date speciala).
	Am utilizat mai multe stari pentru a putea tine evidenta locului in care
se afla programul cu analiza. La inceput se verifica daca liniile incep cu
vreun caracter de comentariu (tratandu-se separat cazul task-urilor) sau cu
un cuvant cheie care anunta venirea unei functii.
	Prima functie gasita (cea cu "def" lipit de margine) va fi mereu
analizata diferit fata de functiile interne. Dupa se citeste antetul functiei
cu parametrii si eventual valori default ale parametrilor incepe analiza
interna a functiei.
	Pentru a respecta indentarea exista o stare ce identifica inceputul de
rand si aduce la nivelul in care se verifica daca e un return dat in functie.
Daca nu se trece la analiza normala a unui rand din functie: aici se verifica
existenta comentariilor, return-uri aparute in cadrul unor blocuri de
instructiuni sau aparitia unor functii interne (decoratori si functia).
	Analiza unei functii interne este asemanatoare cu analiza functiei mari,
dar aici se refolosesc starile, astfel incat daca se intalneste o noua functie
interna se va folosi acelasi principiu pentru analiza. Am avut nevoie de noi
stari pentru functiile interne deoarece trebuia sa tin cont de indentarile ce
vor aparea (de exemplu corpul unei functii interne contine cel putin
nr_functii - 1 tab-uri care trebuiesc gasite, altfel inseamna ca s-a iesit
din functie).
	Comentariile sunt analizate si ele asemanator ca si task-urile, doar ca
in cadrul functiilor ele sunt contorizate.
	Afisarea are loc in doua etape, deoarece o functie interna apare inaintea
specificarii numarului de linii de cod ale unei functii externe. Astfel cand
se termina citirea antetului unei noi functii se afiseaza prima parte, apoi
cand se iese din functie se afiseaza a doua parte. Se elibereaza la final si
memoria alocata in structurile de date utilizate.

	=== Testarea ===

	Am creat trei input-uri:
	- input.py -> cel oferit in enunt;
	- input2.py -> fisier normal;
	- input3.py -> cu functii interne.

	Regulile de rulare sunt run, run2 si, respectiv, run3 din makefile.