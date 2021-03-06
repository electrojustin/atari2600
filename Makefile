CC=clang -g -pthread
#CC=clang -O2 -pthread
INCLUDE=-I/usr/include/qt -I/usr/include/qt/QtGui -I/usr/include/qt/QtCore -I/usr/include/qt/QtWidgets
#INCLUDE=-I/usr/include/x86_64-linux-gnu/qt5 -I/usr/include/x86_64-linux-gnu/qt5/QtGui -I/usr/include/x86_64-linux-gnu/qt5/QtCore -I/usr/include/x86_64-linux-gnu/qt5/QtWidgets
LINK=-lstdc++ -L/usr/lib/x86_64-linux-gnu/ -lQt5Core -lQt5Gui -lQt5Widgets
ASM=acme
atari2600: main.o registers.o memory.o operand.o instructions.o cpu.o qt_display.o display.o ntsc.o tia.o atari.o pia.o input.o
	${CC} ${INCLUDE} ${LINK} main.o registers.o memory.o operand.o instructions.o cpu.o qt_display.o display.o ntsc.o tia.o atari.o pia.o input.o -o atari2600
main.o: main.cc atari.h
	${CC} ${INCLUDE} -fPIC -c main.cc
registers.o: registers.h registers.cc
	${CC} ${INCLUDE} -c registers.cc
memory.o: memory.h memory.cc
	${CC} ${INCLUDE} -c memory.cc
operand.o: operand.h operand.cc registers.h memory.h
	${CC} ${INCLUDE} -c operand.cc
instructions.o: instructions.h instructions.cc registers.h memory.h cpu.h
	${CC} ${INCLUDE} -c instructions.cc
cpu.o: cpu.h cpu.cc operand.h instructions.h registers.h memory.h
	${CC} ${INCLUDE} -c cpu.cc
display.o: display.cc display.h qt_display.h
	${CC} ${INCLUDE} -fPIC -c display.cc
qt_display.o: display.h qt_display.cc qt_display.h input.h
	${CC} ${INCLUDE} -fPIC -c qt_display.cc
ntsc.o: ntsc.cc ntsc.h display.h
	${CC} ${INCLUDE} -c ntsc.cc
tia.o: tia.cc tia.h ntsc.h registers.h memory.h input.h
	${CC} ${INCLUDE} -c tia.cc
atari.o: atari.cc atari.h tia.h memory.h registers.h cpu.h pia.h
	${CC} ${INCLUDE} -c atari.cc
pia.o: pia.cc pia.h registers.h memory.h input.h
	${CC} ${INCLUDE} -c pia.cc
input.o: input.cc input.h
	${CC} ${INCLUDE} -c input.cc
tests: tests/fib.bin tests/scanline_test.bin tests/playfield_test.bin tests/player_test.bin tests/nusiz_test.bin
tests/fib.bin: tests/fib.asm
	${ASM} -o tests/fib.bin tests/fib.asm
tests/scanline_test.bin: tests/scanline_test.asm
	${ASM} -o tests/scanline_test.bin tests/scanline_test.asm
tests/playfield_test.bin: tests/playfield_test.asm
	${ASM} -o tests/playfield_test.bin tests/playfield_test.asm
tests/player_test.bin: tests/player_test.asm
	${ASM} -o tests/player_test.bin tests/player_test.asm
tests/nusiz_test.bin: tests/nusiz_test.asm
	${ASM} -o tests/nusiz_test.bin tests/nusiz_test.asm
clean:
	rm *.o ; rm tests/*.bin
