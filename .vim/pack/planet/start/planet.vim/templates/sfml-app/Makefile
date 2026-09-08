CXX ?= c++
PKG_CONFIG ?= pkg-config
CXXFLAGS ?= -O0 -g
CXXFLAGS += -std=c++17 -Wall -Wextra
CPPFLAGS += $(shell $(PKG_CONFIG) --cflags sfml-window sfml-system glew gl)
LDLIBS += $(shell $(PKG_CONFIG) --libs sfml-window sfml-system glew gl)

.PHONY: all clean
all: sfml-app

sfml-app: main.cpp
	$(CXX) $(CPPFLAGS) $(CXXFLAGS) $(LDFLAGS) -o $@ $< $(LDLIBS)

clean:
	$(RM) sfml-app
