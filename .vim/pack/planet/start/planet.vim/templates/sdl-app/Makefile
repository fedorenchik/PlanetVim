CXX ?= c++
PKG_CONFIG ?= pkg-config
CXXFLAGS ?= -O0 -g
CXXFLAGS += -std=c++17 -Wall -Wextra
CPPFLAGS += $(shell $(PKG_CONFIG) --cflags sdl2 glew gl)
LDLIBS += $(shell $(PKG_CONFIG) --libs sdl2 glew gl)

.PHONY: all clean
all: sdl-app

sdl-app: main.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

clean:
	$(RM) sdl-app
