#include "palette_test.h"
#include "text_mode_vga_color.h"


int main() {
	while (1) {
		paletteTest();
		textVGAColorScreenSaver();
	}
	return 0;
}
