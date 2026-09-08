TARGET ?= app
CC ?= cc
PKG_CONFIG ?= pkg-config
CFLAGS ?= -O0 -g
CFLAGS += -Wall -Wextra
CPPFLAGS += $(shell $(PKG_CONFIG) --cflags gtk+-3.0)
LDLIBS += $(shell $(PKG_CONFIG) --libs gtk+-3.0)
LDFLAGS += -Wl,--export-dynamic

.PHONY: all clean
all: $(TARGET)

$(TARGET): main.o
	$(CC) $(LDFLAGS) -o $@ $^ $(LDLIBS)

main.o: src/main.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $< -o $@

clean:
	$(RM) main.o $(TARGET)
