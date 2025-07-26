module LCD1602_controller#(
    parameter NUM_COMMANDS = 4, 
    parameter NUM_DATA_ALL = 32,  
    parameter NUM_DATA_PERLINE = 16,
    parameter DATA_BITS = 8,
    parameter COUNT_MAX = 800000
)(
    input clk,             // Reloj
    input reset,           // Reset asíncrono
    input ready_i,         // Señal para iniciar la escritura
    input [7:0] num,       // Número dinámico a mostrar en la línea 2
    output reg rs,         // Register Select
    output reg rw,         // Read/Write (siempre en 0 porque solo escribimos)
    output enable,         // Enable (pulsos para el LCD)
    output reg [DATA_BITS-1:0] data // Datos a enviar al LCD
);

// Estados de la FSM
localparam IDLE                = 3'b000;
localparam CONFIG_CMD1         = 3'b001;
localparam WR_STATIC_TEXT_1L   = 3'b010;
localparam CONFIG_CMD2         = 3'b011;
localparam WR_DYNAMIC_TEXT_2L  = 3'b100;

reg [2:0] fsm_state;
reg [2:0] next_state;
reg clk_16ms;
reg [7:0] num_ascii [0:5]; 

// Comandos de configuración
localparam CLEAR_DISPLAY               = 8'h01;
localparam SHIFT_CURSOR_RIGHT          = 8'h06;
localparam DISPON_CURSOROFF            = 8'h0C;
localparam LINES2_MATRIX5x8_MODE8bit   = 8'h38;
localparam START_2LINE                 = 8'hC0;


// Definir un contador para el divisor de frecuencia
reg [$clog2(COUNT_MAX)-1:0] clk_counter;
// Definir un contador para controlar el envío de comandos
reg [$clog2(NUM_COMMANDS):0] command_counter;
// Definir un contador para controlar el envío de datos
reg [$clog2(NUM_DATA_PERLINE):0] data_counter;

// Banco de registros
reg [DATA_BITS-1:0] static_data_mem [0: NUM_DATA_ALL-1];
reg [DATA_BITS-1:0] config_mem [0:NUM_COMMANDS-1]; 


// Conversión a ASCII
always @(*) begin
    num_ascii[0] =101;   
    num_ascii[1] =115;
    num_ascii[2] = 58;
    num_ascii[3] = (num / 100) + 8'd48;            // Centenas
    num_ascii[4] = ((num / 10) % 10) + 8'd48;      // Decenas
    num_ascii[5] = (num % 10) + 8'd48;             // Unidades
end


initial begin
    fsm_state <= IDLE;
    command_counter <= 'b0;
    data_counter <= 'b0;
    rs <= 1'b0;
    rw <= 1'b0;
    data <= 8'b0;
    clk_16ms <= 1'b0;
    clk_counter <= 'b0;

    // Cargar texto estático de la línea 1
    $readmemh("C:/proyectos_para_dig_I/proyecto/data.txt", static_data_mem);    

    // Cargar comandos de configuración
    config_mem[0] <= LINES2_MATRIX5x8_MODE8bit;
    config_mem[1] <= SHIFT_CURSOR_RIGHT;
    config_mem[2] <= DISPON_CURSOROFF;
    config_mem[3] <= CLEAR_DISPLAY;
end

// Divisor de frecuencia (para generar enable cada 16ms)
always @(posedge clk) begin
    if (clk_counter == COUNT_MAX-1) begin
        clk_16ms <= ~clk_16ms;
        clk_counter <= 'b0;
    end else begin
        clk_counter <= clk_counter + 1;
    end
end

// Cambio de estado en el reloj lento
always @(posedge clk_16ms) begin
    if(reset == 0) begin
        fsm_state <= IDLE;
    end else begin
        fsm_state <= next_state;
    end
end

// Lógica de transición de estados
always @(*) begin
    case(fsm_state)
        IDLE: begin
            next_state <= (ready_i) ? CONFIG_CMD1 : IDLE;
        end
        CONFIG_CMD1: begin 
            next_state <= (command_counter == NUM_COMMANDS) ? WR_STATIC_TEXT_1L : CONFIG_CMD1;
        end
        WR_STATIC_TEXT_1L: begin
            next_state <= (data_counter == NUM_DATA_PERLINE) ? CONFIG_CMD2 : WR_STATIC_TEXT_1L;
        end
        CONFIG_CMD2: begin 
            next_state <= WR_DYNAMIC_TEXT_2L;
        end
        WR_DYNAMIC_TEXT_2L: begin
            next_state <= (data_counter == 6) ? IDLE : WR_DYNAMIC_TEXT_2L;
        end
        default: next_state <= IDLE;
    endcase
end

// Lógica de salida y contadores
always @(posedge clk_16ms) begin
    if (reset == 0) begin
        command_counter <= 'b0;
        data_counter <= 'b0;
        data <= 'b0;
        $readmemh("C:/proyectos_para_dig_I/proyecto/data.txt", static_data_mem);
    end else begin
        case (next_state)
            IDLE: begin
                command_counter <= 'b0;
                data_counter <= 'b0;
                rs <= 1'b0;
                data <= 'b0;
            end
            CONFIG_CMD1: begin
                rs <= 1'b0; // Comando
                data <= config_mem[command_counter];
                command_counter <= command_counter + 1;
            end
            WR_STATIC_TEXT_1L: begin
                rs <= 1'b1; // Datos
                data <= static_data_mem[data_counter];
                data_counter <= data_counter + 1;
            end
            CONFIG_CMD2: begin
                rs <= 1'b0; // Cambiar a segunda línea
                data <= START_2LINE;
                data_counter <= 'b0; // Reiniciar contador
            end
            WR_DYNAMIC_TEXT_2L: begin
                rs <= 1'b1; // Datos
                data <= num_ascii[data_counter];
                data_counter <= data_counter + 1;
            end
        endcase
    end
end

// Salida Enable para el LCD
assign enable = clk_16ms;

endmodule
