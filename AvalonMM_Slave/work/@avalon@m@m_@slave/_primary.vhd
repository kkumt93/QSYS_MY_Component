library verilog;
use verilog.vl_types.all;
entity AvalonMM_Slave is
    port(
        reset           : in     vl_logic;
        clk             : in     vl_logic;
        address         : in     vl_logic_vector(3 downto 0);
        read            : in     vl_logic;
        readdata        : out    vl_logic_vector(31 downto 0);
        write           : in     vl_logic;
        writedata       : in     vl_logic_vector(31 downto 0)
    );
end AvalonMM_Slave;
