module sqrt2(
    inout   wire[15:0] IO_DATA,
    output  wire IS_NAN,
    output  wire IS_PINF,
    output  wire IS_NINF,
    output  wire RESULT,
    input   wire CLK,
    input   wire ENABLE
    ); 
    
    reg sign = 0;
    reg[4:0] exp = 0;
    reg[9:0] mant = 0;

    reg is_nan = 0;
    reg is_pinf = 0;
    reg is_ninf = 0;
    reg is_neg = 0;
    reg is_neg_zero = 0;
    reg is_pos_zero = 0;
    reg result = 0;

    reg cur_is_neg_zero = 0;
    reg cur_is_pos_zero = 0;
    reg cur_is_pinf = 0;
    reg cur_is_nan = 0;
    reg cur_is_neg = 0;
    reg cur_is_ninf = 0;

    reg[4:0] cnt = 0;
    reg[11:0] iter_num = 0;
    reg[23:0] iter_rest = 0;
    reg[11:0] iter_result = 0;
    reg[15:0] answer = 16'bzzzzzzzzzzzzzzzz;
    reg[4:0] shift = 0;

    assign IO_DATA = answer;
    assign IS_NAN = is_nan;
    assign IS_PINF = is_pinf;
    assign IS_NINF = is_ninf;
    assign RESULT = result;

    always @(posedge CLK) begin
        if (ENABLE && cnt <= 12 && !result) begin   
            cnt = cnt + 1;

            if (cnt == 1) begin
                sign = IO_DATA[15];
                exp = IO_DATA[14:10];
                mant = IO_DATA[9:0];
                answer = IO_DATA;

                cur_is_neg_zero = sign && (exp == 0) && (mant == 0);
                cur_is_pos_zero = !sign && (exp == 0) && (mant == 0);
                cur_is_pinf = (exp == 5'b11111) && (mant == 0) && !sign;
                cur_is_nan = (exp == 5'b11111) && (mant != 0);
                cur_is_neg = sign;
                cur_is_ninf = (exp == 5'b11111) && (mant == 0) && sign;

                if (!cur_is_neg_zero && !cur_is_pos_zero && !cur_is_pinf && !cur_is_nan && !cur_is_neg && !cur_is_ninf) begin 
                    if ((exp == 5'b00000) && (mant != 0))  begin //если число денормализованное 
                        if (mant[9] == 1) begin 
                            shift = 1;
                        end else if (mant[8] == 1) begin
                            shift = 2;
                        end else if (mant[7] == 1) begin 
                            shift = 3;
                        end else if (mant[6] == 1) begin 
                            shift = 4;
                        end else if (mant[5] == 1) begin 
                            shift = 5;
                        end else if (mant[4] == 1) begin 
                            shift = 6;
                        end else if (mant[3] == 1) begin 
                            shift = 7;
                        end else if (mant[2] == 1) begin 
                            shift = 8;
                        end else if (mant[1] == 1) begin 
                            shift = 9;
                        end else if (mant[0] == 1) begin 
                            shift = 10;
                        end

                        iter_num = mant << shift;
                        exp = shift + 14;

                        if (exp[0] == 1) begin 
                            exp = exp + 1; 
                            iter_num = iter_num << 1;
                        end 

                        exp = 5'b01111 - (exp >> 1);          

                    end else begin // если "обычное" число 
                        iter_num = mant;
                        iter_num[10] = 1;
                        if (exp[0] == 0) begin // если четная экспонента 
                            exp = exp - 1;
                            iter_num = (iter_num << 1); 
                        end

                        if (exp <= 5'b01111) begin
                            exp = 5'b01111 - ((5'b01111 - exp) >> 1);
                        end else begin 
                            exp = ((exp - 5'b01111) >> 1) + 5'b01111;
                        end
                    end
                end
            end else if (cnt > 1) begin
                is_neg_zero = sign && (exp == 0) && (mant == 0);
                is_pos_zero = !sign && (exp == 0) && (mant == 0);
                is_pinf = (exp == 5'b11111) && (mant == 0) && !sign;
                is_nan = (exp == 5'b11111) && (mant != 0);
                is_neg = sign;
                is_ninf = (exp == 5'b11111) && (mant == 0) && sign;

                if (is_pos_zero) begin 
                    exp = 0;
                end;
                
                if (is_neg_zero || is_pinf || is_ninf) begin // если крайние случаи 
                    answer = (sign << 15) + (exp << 10) + iter_result[9:0]; 
                    result = 1;
                end else if (is_nan) begin 
                    result = 1;
                    answer[9] = 1; 
                end else begin

                    iter_rest = (iter_rest << 2) + iter_num[11:10];
                    iter_num = iter_num << 2;

                    if (iter_rest >= (iter_result << 2) + 1) begin
                        iter_rest = iter_rest - ((iter_result << 2) + 1);
                        iter_result = (iter_result << 1) + 1;
                    end else begin
                        iter_result = (iter_result << 1) + 0;
                    end 

                    answer = (sign << 15) + (exp << 10) + iter_result[9:0];

                    if (cnt == 12) begin
                        result = 1;
                    end
                end
            end
        end
    end


    always @(negedge ENABLE) begin
        is_nan = 0;
        is_pinf = 0;
        is_ninf = 0;
        is_neg = 0;
        is_neg_zero = 0;
        is_pos_zero = 0;
        result = 0;

        cur_is_neg_zero = 0;
        cur_is_pos_zero = 0;
        cur_is_pinf = 0;
        cur_is_nan = 0;
        cur_is_neg = 0;
        cur_is_ninf = 0;

        cnt = 0;
        iter_num = 0;
        iter_rest = 0;
        iter_result = 0;
        answer = 16'bzzzzzzzzzzzzzzzz;
        shift = 0;
    end 

endmodule
