module clk_div_50M_to_125k (
    input clk_in,       // Reloj de entrada de 50 MHz
    input  rst,        // Reset síncrono activo en alto
    output reg clk_out       // Reloj de salida de 125 kHz
);

    // Contador de 9 bits para contar hasta 200
    reg [8:0] counter = 0;

    always @(posedge clk_in) begin
        if (rst == 0) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == 199) begin
                counter <= 0;
                clk_out <= ~clk_out;  // Cambia de estado cada 200 ciclos → 125 kHz
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule