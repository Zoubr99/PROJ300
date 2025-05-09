//**********************************************************//
//  Reg map (each port uses 4 address space)

//    * 0: read data and status
//    * 1: write baud rate 
//    * 2: write data 
//    * 3: dummy write to remove data from head of rx FIFO 

//**********************************************************//

 module uart_wc
    #(parameter FIFO_DEPTH_BIT = 8)

    (
        //standard signals
        input logic clk,
        input logic reset,

        // uart slot interface with the MMIO controller
        input logic cs, 
        input logic read,
        input logic write,
        input logic [4:0] addr,
        input logic [31:0] wr_data,

        // output into the system
        output logic [31:0] rd_data,
        //output into the outside world
        output logic tx,
        // input into the system
        input logic rx
    );

    // internal signals declarations
    logic wr_uart, rd_uart, wr_dvsr;
    logic tx_full, rx_empty;
    logic [10:0] dvsr_reg;
    logic [7:0] r_data;
    logic  ctrl_reg;

   uart #(.DBIT(8), .SB_TICK(16), .FIFO_W(FIFO_DEPTH_BIT)) uart_unit    
   (.*, .dvsr(dvsr_reg), .w_data(wr_data[7:0]) );

    always_ff @(posedge clk, posedge reset)
        if(reset)
            dvsr_reg <= 0;
        else 
        if (wr_dvsr)
            dvsr_reg <= wr_data[10:0];

    // decoding logic 
    assign wr_dvsr = (write && cs && (addr[1:0] == 2'b01));
    assign wr_uart = (write && cs && (addr[1:0] == 2'b10));
    assign rd_uart = (write && cs && (addr[1:0] == 2'b11));

    // slot raed interface
    assign rd_data = {22'h000000, tx_full, rx_empty, r_data};
 endmodule