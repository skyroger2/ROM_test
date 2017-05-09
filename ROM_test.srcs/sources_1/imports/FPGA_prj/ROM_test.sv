`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.01.2017 15:31:19
// Design Name: 
// Module Name: ROM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

/*
logic [15:0] rom_values [8] = {
    16'o012700, 16'o000030, 16'o010020, 16'o010020, 16'o012706, 16'o001000, 16'o104257, 16'o000000
};
*/

module ROM_test
(
    input       [15:0]  ADDR,
    output      [15:0]  DATA_R,
    input       [15:0]  DATA_W,
    input               SYNC,
    input               DIN,
    input               DOUT,
    input               WTBT,
    output  reg         RPLY,
    input               IAKO,
    output  reg         VIRQ = 1,

    input               clk,
    input               rst
    );

`include "ROM_values_test.vh"

localparam  ADDRESS_START   = 16'o160000;
localparam  ADDRESS_END     = 16'o177577;

enum logic [1:0]
{
    MPI_S_FSM_IDLE,
    MPI_S_FSM_ADDRESS_VALIDATED,
    MPI_S_FSM_READ
} MPIFSM_currentState, MPIFSM_nextState;

logic   [15:0]    address;
logic   [15:0]    value;

always_ff @(posedge clk)
    if (!rst)   MPIFSM_currentState <= MPI_S_FSM_IDLE;   
    else        MPIFSM_currentState <= MPIFSM_nextState;

always_comb
    case (MPIFSM_currentState)
    MPI_S_FSM_IDLE: begin
        if (SYNC == 1'b1)           MPIFSM_nextState <= MPI_S_FSM_IDLE;
        else if ((ADDR >= ADDRESS_START) && (ADDR <= ADDRESS_END))
                                    MPIFSM_nextState <= MPI_S_FSM_ADDRESS_VALIDATED;
        else                        MPIFSM_nextState <= MPI_S_FSM_IDLE;
    end

    MPI_S_FSM_ADDRESS_VALIDATED: begin
        if (DIN == 1'b0)            MPIFSM_nextState <= MPI_S_FSM_READ;
        else if (SYNC == 1'b1)      MPIFSM_nextState <= MPI_S_FSM_IDLE;
        else                        MPIFSM_nextState <= MPI_S_FSM_ADDRESS_VALIDATED;
    end

    MPI_S_FSM_READ: begin
        if (DIN == 1'b0)            MPIFSM_nextState <= MPI_S_FSM_READ;
        else                        MPIFSM_nextState <= MPI_S_FSM_ADDRESS_VALIDATED;
    end

    default:                        MPIFSM_nextState <= MPI_S_FSM_IDLE;
    endcase

always_ff @(posedge clk)
begin
    if (MPIFSM_currentState == MPI_S_FSM_IDLE) begin
        if (SYNC == 1'b0)           address <= ADDR;
    end
    value <= rom_values_test[(address & 16'o017777) >> 1];
end

assign  DATA_R = (MPIFSM_currentState == MPI_S_FSM_READ) ? value : 16'hFFFF;
assign  RPLY = (MPIFSM_currentState == MPI_S_FSM_READ) ? 0 : 1;

endmodule
