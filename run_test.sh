#!/bin/sh

iverilog -g 2012 -o ./testbenches/test testbenches/$1 hdl/*.v hdl/ex_stage/*.v hdl/id_stage/*.v hdl/if_stage/*.v hdl/mem_stage/*.v hdl/io/*.v
vvp ./testbenches/test
