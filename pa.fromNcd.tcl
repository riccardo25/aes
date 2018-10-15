
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name aes -dir "D:/Repository/XILINX/aes/planAhead_run_2" -part xc6slx45csg324-3
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "D:/Repository/XILINX/aes/aescore.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {D:/Repository/XILINX/aes} }
set_param project.paUcfFile  "D:/Repository/XILINX/aeswithusb/pins.ucf"
add_files "D:/Repository/XILINX/aeswithusb/pins.ucf" -fileset [get_property constrset [current_run]]
open_netlist_design
read_xdl -file "D:/Repository/XILINX/aes/aescore.ncd"
if {[catch {read_twx -name results_1 -file "D:/Repository/XILINX/aes/aescore.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"D:/Repository/XILINX/aes/aescore.twx\": $eInfo"
}
