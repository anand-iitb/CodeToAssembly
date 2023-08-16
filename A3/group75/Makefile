CXX = g++-8
EXE = iplC
CXXDEBUG = -g -Wall
CXXSTD = -std=c++11


.PHONY: all clean
all: parser lexer 	
	$(CXX) $(CXXDEBUG) -o iplC parser.o scanner.o driver.cpp type.cpp symbtab.cpp ast.cpp

parser: parser.yy scanner.hh
	bison -d -v $<
	$(CXX) $(CXXDEBUG) -c parser.tab.cc -o parser.o 

lexer: scanner.l scanner.hh parser.tab.hh parser.tab.cc	
	flex++ --outfile=scanner.yy.cc  $<
	$(CXX)  $(CXXDEBUG) -c scanner.yy.cc -o scanner.o
clean: 
	rm -f *.o $(EXE) *.cc parser.tab.hh position.hh stack.hh location.hh parser.output
