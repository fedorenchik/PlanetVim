CXX ?= c++
PKG_CONFIG ?= pkg-config
CXXFLAGS ?= -O0 -g
CXXFLAGS += -std=c++17 -Wall -Wextra
CPPFLAGS += $(shell $(PKG_CONFIG) --cflags glfw3 glew gl)
LDLIBS += $(shell $(PKG_CONFIG) --libs glfw3 glew gl)

.PHONY: all clean
all: glfw-app

glfw-app: main.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

clean:
	$(RM) glfw-app
