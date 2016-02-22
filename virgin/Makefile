CC = gcc
CFLAGS = -O2 -fPIC -Wall
LUADIR = ../skynet/3rd/lua/
TARGET = luaclib/protobuf.so

.PHONY : all clean

all : $(TARGET)

$(TARGET) : luaclib/pbc-lua53.c
	$(CC) $(CFLAGS) -shared -o $@ -I../pbc -I$(LUADIR) -L../pbc/build $^ -lpbc

clean :
	rm -f $(TARGET)
