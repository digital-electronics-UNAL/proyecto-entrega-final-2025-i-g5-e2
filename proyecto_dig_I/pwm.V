module PWM(
    input [7:0] ciclo_util,
    input clk,
    input rst,
    output PWM_S
);

    reg [7:0] contador;

    always @(posedge clk) begin
        if (rst == 0) begin
            contador <= 0;
        end else if (contador == 255) begin
            contador <= 0;
        end else begin 
            contador <= contador + 1;
        end
    end

    assign PWM_S = (contador < ciclo_util);

endmodule