module WEIGHT_BIAS_MEMORY #(parameter DATAWIDTH = 32) (
 input clk,
 input [7:0] addr1,
 input [7:0] addr2,
 output reg [DATAWIDTH-1:0] dout1,
 output reg [DATAWIDTH-1:0] dout2
 );

reg [7:0] ROM [511:0];

initial
begin
$readmemb("rom_bytes.data", ROM);
end

always @(posedge clk)
begin
dout1 <= {ROM[addr1], ROM[addr1 + 1], ROM[addr1 + 2], ROM[addr1 + 3]};
dout2 <= {ROM[addr2], ROM[addr2 + 1], ROM[addr2 + 2], ROM[addr2 + 3]};
end

endmodule
