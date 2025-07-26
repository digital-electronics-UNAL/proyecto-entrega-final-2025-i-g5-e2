`timescale 1ns / 1ps

module display (
    input [7:0] num,
    input clk,
    input rst,
    output reg [3:0] an,
    output [6:0] sseg,
    output led
);

// Registro de BCD que se enviará al decodificador
reg [3:0] bcd;

// Instancia del decodificador BCD a display de 7 segmentos
bcd_to_7seg bcdtosseg (
    .BCD(bcd),
    .SSeg(sseg)
);

// Registros para almacenar cada dígito del número
reg [3:0] digit_0, digit_1, digit_2;

// Contador para dividir la frecuencia
reg [26:0] cfreq;
assign led = cfreq[16];
wire enable = cfreq[16];

// Divisor de frecuencia (clock enable)
always @(posedge clk) begin
    if (rst == 0)
        cfreq <= 0;
    else
        cfreq <= cfreq + 1'b1;
end

// Multiplexor de dígitos
reg [1:0] count;

always @(posedge enable) begin
    // Cálculo de los dígitos en BCD
    digit_2 = (num / 100) % 10;
    digit_1 = (num / 10) % 10;
    digit_0 = num % 10;

    if (!rst) begin
        count <= 0;
        an <= 3'b111;
    end else begin
        case (count)
            3'd0: begin bcd <= digit_0; an <= 3'b110; end
            3'd1: begin bcd <= digit_1; an <= 3'b101; end
            3'd2: begin bcd <= digit_2; an <= 3'b011; end
            default: begin bcd <= 3'd3; an <= 3'b111; end
        endcase

        if (count == 2'd3)
            count <= 0;
        else
            count <= count + 1;
    end
end

endmodule