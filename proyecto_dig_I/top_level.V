module top_level (
    input clk,
    input reset,
    input Echo,
    input ready_i,
    output reg rs,         
    output reg rw,   
    output Trigger,
    output buzzr,
    output rumb,
    output dir1,
    output dir2,
	output [2:0] an,
	output [6:0] sseg,
	output led,
    output enable,         // Enable (pulsos para el LCD)
    output reg [7:0] data
);



wire divfrec;
wire [8:0]distancia_cm;
wire valid;
wire [8:0] valor_mostrado;
wire pwm_buzzer;
reg [7:0] buz;                // Duty cycle calculado


assign buzzr = ~pwm_buzzer;

assign dir1 = 1; // 1 lógico
assign dir2 = 0; // 0 lógico

// === Instancia de módulos ===
clk_div_50M_to_125k div(
    .clk_in(clk),
    .rst(reset),
    .clk_out(divfrec)
);

PWM rumble(
    .clk(divfrec),
    .rst(reset),
    .ciclo_util(buz),
    .PWM_S(rumb)
);

PWM buzzer(
    .clk(divfrec),
    .rst(reset),
    .ciclo_util(buz),
    .PWM_S(pwm_buzzer)
);

hc_sr04_mm Trig (
        .clk(clk),
        .Echo(Echo),
        .rst(reset),
        .Trigger(Trigger),
        .distancia_cm(distancia_cm),
        .valid(valid)
);

assign valor_mostrado = valid ? distancia_cm : 9'd100;

    display disp (
        .num(valor_mostrado),
        .clk(clk),
        .rst(reset),
        .an(an),
        .sseg(sseg),
        .led(led)
    );

escalado_pa_union_pwm escalado(
    .in(valor_mostrado),
    .out(buz)
);

LCD1602_controller lcd(
    .clk(clk),            
    .reset(reset),         
    .ready_i(ready_i),         
    .num(buz),     
    .rs(rs),         
    .rw(rw),       
    .enable(enable),        
    .data(data)
);

endmodule