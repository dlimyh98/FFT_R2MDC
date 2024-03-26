compile:
	vcs -full64 +lint=all -debug_all -timescale=1ns/10ps ../src/*.v ../tb/tb_ifft64_radix2_top.v
plot:
	dve -vpd waveform.vpd &	
clean:
	@echo "Cleaning up files"
	rm -r csrc simv simv.daidir DVEfiles ucli.key waveform.vpd
