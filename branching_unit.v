module branching_unit (
    input zero,
    input branch,
    input bne,
    output reg take_branch
);
    always @(*) begin
        if (branch) begin
            if (bne) 
                begin //BNE
                    take_branch = ~zero; // Take branch if not equal
                end 
            else 
                begin //BEQ
                    take_branch = zero; // Take branch if equal
                end
        end 
        else begin
            take_branch = 0; // No branch
        end
    end
    
endmodule