`timescale 1ns / 1ps



module SRT(
input wire[8:0] z, //0.x1x2x3x4x5...
input wire[4:0] d, //0.d1d2d3d4....
output wire [3:0] q,
output wire[8:0] s,
input wire clk,
input wire rst,
output wire done
    );
    
reg[8:0] s_reg;
reg[8:0] s_final;
reg correction;

reg done_reg;
reg[3:0] q_reg = 0;
integer i = 0;

reg[3:0] q_negative = 0;
reg[8:0] val;

integer msb = 4;


localparam[2:0] S0 = 0, S1=1, S2=2, S3=3, S4=4;

reg[2:0] state_present, state_next;

always@(posedge clk, posedge rst) //asyncronous reset
begin
    if(rst)
        state_present <= S0;
    else
        state_present <= state_next;
end

always@(state_present)
begin
    case(state_present)
    
    S0: //load initial values
    begin
        s_reg = z;
        s_final = 0;
        val = {d, 4'b0000};
        q_reg = 0;
        q_negative = 0;
        state_next = S1;
        done_reg = 0;
        msb=3;
        i = 0;
        correction = 0;
    end
    
    S1: //shifting
    begin
        s_reg = s_reg << 1; 
        i=i+1;
         
        $display("i=%d", i);
        $display("msb=%d" , msb);
        state_next = S2;
    end
    
    S2: //quotient and remainder calculation
    begin
        if(s_reg[8] == 1'b0 && s_reg[7] == 1'b1) 
        begin            
            s_reg = s_reg - val;
            q_reg[msb] = 1'b1; 
            q_negative[msb] = 1'b0;             
            state_next = S3;
        end
        
        else if(s_reg[8] == 1'b1 && s_reg[7] == 1'b0) 
        begin        
            s_reg = s_reg + val;
            q_reg[msb] = 1'b0; 
            q_negative[msb] = 1'b1;  
            state_next = S3; 
        end
        
        else
        begin        
                    
            q_reg[msb] = 1'b0; 
            q_negative[msb] = 1'b0;  
            state_next = S3;
        end
        
    end
    
    S3: //check if remainder and divisor are the same length
    begin
    
        msb = msb-1;
        if(i==4)
        begin
            done_reg = 1;
            state_next = S4;
        end  
        else
        begin
            done_reg = 0;
            state_next = S1;
        end 
    end
    
    S4:
    begin
    
        //load final output
        if(s_reg[8] == 1'b1) //if remainder is negative then perform correction
        begin
            correction = 1'b1;
            s_reg = s_reg + val;
            s_final = {4'b0000, s_reg[8:4]}; 
            state_next = S4; 
            
        end
        
        else
        begin
            correction = 1'b0;
            s_reg = s_reg;
            s_final = {4'b0000, s_reg[8:4]};  
            state_next = S4;
        end
        
    end
    
    default: state_next = S0;
    
    
    endcase
    
end

assign q = (!correction) ? ((q_reg - q_negative)) : ((q_reg - q_negative)-1);
assign done = done_reg;
assign s = s_final;

endmodule
 