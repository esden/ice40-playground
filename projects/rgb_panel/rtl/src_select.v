`default_nettype none


// initially select B.  A has priority -- when A is active it is selected.

module src_select #(
    parameter integer N_ROWS          = 64,
    parameter integer N_COLS          = 64,
    parameter integer BITDEPTH        = 24,
    parameter integer INACTIVITY_TIME = 1000,
)(
    input  wire [LOG_N_ROWS-1:0] a_fbw_row_addr,
    input  wire                  a_fbw_row_store,
    input  wire                  a_fbw_row_swap,
    input  wire [BITDEPTH-1:0]   a_fbw_data,
    input  wire [LOG_N_COLS-1:0] a_fbw_col_addr,
    input  wire                  a_fbw_wren,
    input  wire                  a_frame_swap,

    input  wire [LOG_N_ROWS-1:0] b_fbw_row_addr,
    input  wire                  b_fbw_row_store,
    input  wire                  b_fbw_row_swap,
    input  wire [BITDEPTH-1:0]   b_fbw_data,
    input  wire [LOG_N_COLS-1:0] b_fbw_col_addr,
    input  wire                  b_fbw_wren,
    input  wire                  b_frame_swap,

    output wire [LOG_N_ROWS-1:0] fbw_row_addr,
    output wire                  fbw_row_store,
    output wire                  fbw_row_swap,
    output wire [BITDEPTH-1:0]   fbw_data,
    output wire [LOG_N_COLS-1:0] fbw_col_addr,
    output wire                  fbw_wren,
    output wire                  frame_swap,

    input  wire                  clk,
    input  wire                  rst
);

    parameter integer LOG_N_ROWS = $clog2(N_ROWS);
    parameter integer LOG_N_COLS = $clog2(N_COLS);
    parameter integer LOG_INAC_T = $clog2(INACTIVITY_TIME);

    reg [LOG_INAC_T:0] a_activity_counter = -1;
    wire b_active = a_activity_counter[LOG_INAC_T];

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            a_activity_counter <= -1;
        end
        else if (a_frame_swap) begin
            a_activity_counter <= INACTIVITY_TIME;
        end
        else if (b_frame_swap && !b_active) begin
            a_activity_counter <= a_activity_counter - 1;
        end
    end

    assign fbw_row_addr  = b_active ? b_fbw_row_addr  : a_fbw_row_addr;
    assign fbw_row_store = b_active ? b_fbw_row_store : a_fbw_row_store;
    assign fbw_row_swap  = b_active ? b_fbw_row_swap  : a_fbw_row_swap;
    assign fbw_data      = b_active ? b_fbw_data      : a_fbw_data;
    assign fbw_col_addr  = b_active ? b_fbw_col_addr  : a_fbw_col_addr;
    assign fbw_wren      = b_active ? b_fbw_wren      : a_fbw_wren;
    assign frame_swap    = b_active ? b_frame_swap    : a_frame_swap;

endmodule
