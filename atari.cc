#include "atari.h"

#include <memory>
#include <thread>
#include <stdio.h>

#include "tia.h"
#include "memory.h"
#include "registers.h"
#include "cpu.h"

std::unique_ptr<TIA> tia;

std::shared_ptr<RamRegion> ram = nullptr;
std::shared_ptr<RomRegion> rom = nullptr;
std::shared_ptr<StackRegion> stack = nullptr;
std::shared_ptr<RamRegion> irq_vector = nullptr;

std::unique_ptr<std::thread> emulation_thread;

void emulate() {
	while(should_execute) {
//		dump_regs();
		execute_next_insn();
		tia->process_tia();
	}
}

void load_program_file(const char* filename) {
	uint8_t* rom_backing = (uint8_t*)malloc(ROM_END - ROM_START);
	FILE* program_file = fopen(filename, "r");
	if (!program_file) {
		printf("could not open %s", filename);
		exit(-1);
	}

	fread(rom_backing, 1, ROM_END - ROM_START, program_file);
	fclose(program_file);

	init_registers(ROM_START);

	tia = std::make_unique<TIA>(TIA_START, TIA_END);

	ram = std::make_shared<RamRegion>(RAM_START, RAM_END);
	rom = std::make_shared<RomRegion>(ROM_START, ROM_END, rom_backing);
	stack = std::make_shared<StackRegion>(STACK_BOTTOM, STACK_TOP);
	irq_vector = std::make_shared<RamRegion>(NMI_VECTOR, IRQ_VECTOR+1);

	memory_regions.push_back(ram);
	memory_regions.push_back(stack);
	memory_regions.push_back(rom);	
	memory_regions.push_back(irq_vector);
	memory_regions.push_back(tia->get_dma_region());

	irq_vector_addr = IRQ_VECTOR;
	write_word(IRQ_VECTOR, 0);

	free(rom_backing);
}

void start_emulation_thread() {
	should_execute = true;
	emulation_thread = std::make_unique<std::thread>(emulate);
}