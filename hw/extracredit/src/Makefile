def: clean check testHW8 testHW9

dist: all.tar clean
	chmod a+r all.tar

check: check.cpp
	g++ -std=c++11 check.cpp -o check

gen: gen.cpp
	g++ gen.cpp -o gen

all.tar: gen
	gen
	tar cf all.tar Makefile gen.cpp check.cpp MANIFEST.MF USER* *.java

clean:
	/bin/rm -f gen check *.class 141OS.jar alt141OS.jar PRINTER*

141OS.jar: MainClass.java
	javac MainClass.java
	jar cmf MANIFEST.MF 141OS.jar  *.class

testHW8: 141OS.jar
	java -jar 141OS.jar -1 -1 -1
	check 1 PRINTER*

testHW9: 141OS.jar
	java -jar 141OS.jar -26 -2 -4
	check 26 PRINTER*

alt141OS.jar: MainClass.java
	javac MainClass.java
	jar cf alt141OS.jar *.class

alttest: alt141OS.jar
	java -cp alt141OS.jar MainClass
