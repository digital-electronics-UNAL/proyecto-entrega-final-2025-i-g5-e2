module escalado_pa_union_pwm (
    input [8:0] in,
    output reg [7:0] out
);

always @(*) begin 
    if (in < 8) begin
        out <= 0;
    end else if (in > 94) begin
        out <= 0;
    end else if (in == 8) begin
        out <= 255 ;
    end else if (in == 9) begin
        out <= 255;
    end else begin
        out <= (95 - in)*3;
    end
end


endmodule