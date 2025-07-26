module hc_sr04_mm #(parameter COUNT_MAX = 50  )
	 (
    input clk,
    input Echo,
    input rst,
    output reg Trigger,
    output reg [8:0] distancia_cm, 
    output reg valid
);

    // --- Reloj microsegundo ---
    reg [5:0] counter = 0;
    reg micro = 0;

    always @(posedge clk) begin
        if (counter == COUNT_MAX - 1) begin
            counter <= 0;
            micro <= ~micro;
        end else counter <= counter + 1;
    end

    // --- Sincronización de Echo ---
    reg echo_d1 = 0, echo_d2 = 0;
    wire echo_rise = echo_d1 & ~echo_d2;
    wire echo_fall = ~echo_d1 & echo_d2;

    always @(posedge micro) begin
        echo_d2 <= echo_d1;
        echo_d1 <= Echo;
    end

    // --- Estados FSM ---
    localparam IDLE        = 3'd0;
    localparam TRIGGER     = 3'd1;
    localparam WAIT_ECHO   = 3'd2;
    localparam COUNT_ECHO  = 3'd3;
    localparam COOLDOWN    = 3'd4;

    reg [2:0] state = IDLE;

    reg [3:0] trigger_count = 0;
    reg [14:0] Tiemp = 0;
    reg [15:0] cooldown_counter = 0;

    always @(posedge micro) begin
        if (rst == 0) begin
            state            <= IDLE;
            Trigger          <= 0;
            trigger_count    <= 0;
            Tiemp            <= 0;
            cooldown_counter <= 0;
            distancia_cm     <= 0;
            valid            <= 0;
        end else begin
            case (state)
                IDLE: begin
                    Trigger <= 0;
                    valid   <= 0;
                    Tiemp   <= 0;
                    state   <= TRIGGER;
                end

                TRIGGER: begin
                    Trigger <= 1;
                    trigger_count <= trigger_count + 1;
                    if (trigger_count >= 10) begin
                        Trigger <= 0;
                        trigger_count <= 0;
                        state <= WAIT_ECHO;
                    end
                end

                WAIT_ECHO: if (echo_rise) begin
                    Tiemp <= 0;
                    state <= COUNT_ECHO;
                end

                COUNT_ECHO: begin
                    if (echo_fall == 0) begin
                        Tiemp <= Tiemp + 1;
                    end else begin
                        // Calcular y saturar
                        if (Tiemp >= 116 && Tiemp <= 23200) begin
                            // conversión a cm
                            if ((Tiemp /29) > 100)
                                distancia_cm <= 100;
                            else
                                distancia_cm <= Tiemp / 29;
                            valid <= 1;
                        end else begin
                            distancia_cm <= 0;
                            valid <= 0;
                        end
                        cooldown_counter <= 0;
                        state <= COOLDOWN;
                    end
                end

                COOLDOWN: begin
                    cooldown_counter <= cooldown_counter + 1;
                    if (cooldown_counter >= 60000) begin
                        cooldown_counter <= 0;
                        state <= IDLE;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
