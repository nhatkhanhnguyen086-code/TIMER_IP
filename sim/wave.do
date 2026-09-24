onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /test_bench/sys_clk
add wave -noupdate /test_bench/sys_rst_n
add wave -noupdate /test_bench/tim_psel
add wave -noupdate /test_bench/tim_penable
add wave -noupdate /test_bench/tim_pwrite
add wave -noupdate /test_bench/tim_pstrb
add wave -noupdate -radix hexadecimal /test_bench/tim_paddr
add wave -noupdate -radix hexadecimal /test_bench/tim_pwdata
add wave -noupdate /test_bench/dbg_mode
add wave -noupdate /test_bench/tim_pready
add wave -noupdate /test_bench/tim_pslverr
add wave -noupdate /test_bench/tim_int
add wave -noupdate /test_bench/tim_prdata
add wave -noupdate -radix binary /test_bench/dut/register_u/timer_en
add wave -noupdate -radix binary /test_bench/dut/register_u/div_en
add wave -noupdate -radix hexadecimal /test_bench/dut/register_u/div_val
add wave -noupdate -radix decimal /test_bench/dut/cnt_ctrl_u/cnt_int
add wave -noupdate -radix decimal /test_bench/dut/cnt_u/cnt
add wave -noupdate /test_bench/dut/register_u/halt_req
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40214 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 209
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {40146 ns} {40258 ns}
