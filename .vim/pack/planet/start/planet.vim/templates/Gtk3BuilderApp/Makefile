TARGET=app
CC=gcc
DEBUG=-g
OPT=-O0
WARN=-Wall
PTHREAD=-pthread
CCFLAGS=$(DEBUG) $(OPT) $(WARN) $(PTHREAD) -pipe
GTKLIB=`pkg-config --cflags --libs gtk+-3.0`
LD=gcc
LDFLAGS=$(PTHREAD) $(GTKLIB) -export-dynamic
OBJS= main.o

all: $(OBJS)
	$(LD) -o $(TARGET) $(OBJS) $(LDFLAGS)

main.o: src/main.c
	$(CC) -c $(CCFLAGS) src/main.c $(GTKLIB) -o main.o

clean:
	rm -f *.o $(TARGET)
