CXX ?= c++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -O2
app: main.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<
clean:
	rm -f app app.exe
.PHONY: clean
