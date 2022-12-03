`timescale 1ns / 1ps



module NON_RESTORING(
input wire[8:0] z, //0x1x2x3x4x5...
input wire[4:0] d, // ....
output wire [3:0] q,
output wire[8:0] s,
input wire clk,
input wire rst,
output wire done
    );
    
reg[8:0] s_reg, temp;
reg[8:0] s_final;

reg done_reg;
reg[3:0] q_reg = 0;
integer i = 0;

reg[8:0] val;

integer msb;

localparam[2:0] S0 = 0, S1=1, S2=2, S3=3, S4=4;

reg[2:0] state_present, state_next;

always@(posedge clk, posedge rst)
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
        state_next = S2;
        done_reg = 0;
        msb=4;
        i = 0;
        temp = 0;
    end
    
    S2:
    begin
        temp = s_reg << 1; 
        i=i+1;     
        state_next = S1;        
    end

    S1: //quotient and remainder
    begin

        if(s_reg[8] == 1'b1)  //negative so add
        begin
            s_reg =  temp + val;
            if(msb <= 3)
                q_reg[msb] = 1'b0;
            state_next = S3;
            $display("%d", msb);
            
        end
        
        // else if(s_reg[8] == 1'b0)
        else  //positive so subtract
        begin
            
            s_reg = temp - val;
            if(msb <= 3)
                q_reg[msb] = 1'b1;
            state_next = S3;
             $display("%d", msb);
            
        end      
    end
    
    S3:
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
            state_next = S2;
        end 
       
    end

    S4:
    begin
        //load final output
        if(s_reg[8] == 1'b1)
        begin
            q_reg[0] = 1'b0;
            s_reg = s_reg + val;
            s_final = {4'b0000, s_reg[8:4]};  
        end
        
        else
        begin
            q_reg[0] = 1'b1;
            s_final = {4'b0000, s_reg[8:4]};  
        end
        
    end
    
    endcase
end

assign q = q_reg;
assign done = done_reg;
assign s = s_final;

endmodule
 