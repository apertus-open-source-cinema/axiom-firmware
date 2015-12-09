----------------------------------------------------------------------------
--  vivado_pkg.vhd
--	Vivado Specific Attributes
--	Version 1.0
--
--  Copyright (C) 2013 H.Poetzl
--
--	This program is free software: you can redistribute it and/or
--	modify it under the terms of the GNU General Public License
--	as published by the Free Software Foundation, either version
--	2 of the License, or (at your option) any later version.
----------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.ALL;

package vivado_pkg is

    attribute ASYNC_REG : string;

    --  This attribute can be placed on any register;
    --
    --  Values are FALSE (default) and TRUE.
    --
    --  FALSE :	The register can be optimized away, or absorbed into 
    --		a block such as SRL, DSP, or RAMB.
    --  TRUE :	The register is part of a synchronization chain. 
    --		It will be preserved through implementation, placed near
    --		the other registers in the chain and used for MTBF
    --		reporting.


    attribute BEL : string;

    attribute BLACK_BOX : string;

    attribute BUFFER_TYPE : string;			-- deprecated

    attribute IO_BUFFER_TYPE : string;

    attribute CLOCK_BUFFER_TYPE : string;

    --  Apply BUFFER_TYPE on an input to describe what type of buffer 
    --  to use.
    --
    --  By default, Vivado synthesis uses IBUF/BUFG or BUFGPs
    --  for clocks and IBUFs for inputs.
    --
    --  The BUFFER_TYPE attribute can be placed on any top-level port.
    --
    --  Values are:
    --  ibuf :	For clock ports where a IBUF/BUFG pair is not wanted.
    --		In this case only, the IBUF is inferred for the clock.
    --
    --  none :	Indicates that no input or output buffers are used.
    --		A none value on a clock port results in no buffers.


    attribute DONT_TOUCH : string;

    --  Use the DONT_TOUCH attribute in place of KEEP or KEEP_HIERARCHY.
    --  The DONT_TOUCH works in the same way as KEEP or KEEP_HIERARCHY
    --  attributes; however, unlike KEEP and KEEP_HIERARCHY, DONT_TOUCH
    --  is forward-annotated to place and route to prevent logic
    --  optimization.
    --
    --  Like KEEP and KEEP_HIERARCHY, be careful when using DONT_TOUCH.
    --  In cases where other attributes are in conflict with DONT_TOUCH,
    --  the DONT_TOUCH attribute takes precedence.
    --
    --  This attribute can be placed on any signal, module, entity,
    --  or component.
    --
    --  Values are FALSE (default) and TRUE.


    attribute DRIVE : integer;


    attribute FSM_ENCODING : string;

    --  FSM_ENCODING controls how a state machine is encoded during 
    --  synthesis.
    --  As a default, the Vivado synthesis tool chooses an encoding
    --  protocol for state machines based on internal algorithms that
    --  determine the best solution for most designs. 
    --  However, the FSM_ENCODING property lets you specify the state
    --  machine encoding of your choice.
    --
    --  Values are:
    --  off :	This disables state machine encoding within the
    --		Vivado synthesis tool. In this case the state machine
    --		is synthesized as logic.
    --  one_hot :
    --  sequential :
    --  johnson :
    --  gray :
    --  auto :	This is the default behavior when FSM_ENCODING is
    --		not specified. it allows the Vivado synthesis tool to
    --		determine the best state machine encoding method.


    attribute FSM_SAFE_STATE : string;

    attribute GATED_CLOCK : string;

    attribute HIODELAY_GROUP : string;

    attribute HLUTNM : string;

    attribute HU_SET : string;

    attribute IN_TERM : string;


    attribute IOB : string;

    --  The IOB is not a synthesis attribute; it is used downstream
    --  by Vivado implementation. This attribute indicates if a register
    --  should go into the I/O buffer.
    --
    --  Place this attribute on the register that you want in the I/O
    --  buffer. Place this attribute on the register that you want in
    --  the I/O buffer.
    --
    --  Values are FALSE and TRUE.


    attribute IOBDELAY : string;

    attribute IODELAY_GROUP : string;

    attribute IOSTANDARD : string;


    attribute KEEP_HIERARCHY : string;

    --  KEEP_HIERARCHY is used to prevent optimizations along the
    --  hierarchy boundaries. The Vivado synthesis tool attempts to
    --  keep the same general hierarchies specified in the RTL, but
    --  for QoR reasons it can flatten or modify them.
    --
    --  If KEEP_HIERARCHY is placed on the instance, the synthesis
    --  tool keeps the boundary on that level static.
    --  This can affect QoR and also should not be used on modules
    --  that describe the control logic of 3-state outputs and I/O
    --  buffers.
    --
    --  The KEEP_HIERARCHY can be placed in the module or 
    --  architecture level or the instance.
    --
    --  Values are FALSE and TRUE.


    attribute LOC : string;

    attribute LOCK_PINS : string;

    attribute LUTNM : string;


    attribute MARK_DEBUG : string;

    --  Set MARK_DEBUG on a net in the RTL to preserve it and make it
    --  visible in the netlist.
    --
    --  This allows it to be connected to the logic debug tools at any
    --  point in the compilation flow.
    --
    --  Values are FALSE and TRUE.


    attribute MAX_FANOUT : integer;

    --  MAX_FANOUT instructs Vivado synthesis on the fanout limits
    --  for registers and signals. You can specify this either in
    --  RTL or as an input to the project. The value is an integer.
    --
    --  This attribute only works on registers and combinatorial
    --  signals. To achieve the fanout, it replicates the register
    --  or the driver that drives the combinatorial signal.


    attribute PACKAGE_PIN : string;


    attribute RAM_STYLE : string;

    --	RAM_STYLE instructs the Vivado synthesis tool on how to
    --	infer memory.
    --	By default, the tool selects which RAM to infer, based
    --	upon heuristics that give the best results for most designs.
    --	Place this attribute on the array declared for the RAM.
    --
    --	Values are:
    --	block:	Instructs the tool to infer RAMB type components
    --	distributed:	Instructs the tool to infer the LUT RAMs.


    attribute REGISTER_BALANCING : string;

    --  YES, NO, FORWARD, BACKWARD


    attribute REGISTER_DUPLICATION : string;

    --  YES, NO


    attribute RLOC: string;

    attribute RLOC_ORIGIN: string;


    attribute ROM_STYLE : string;

    --	ROM_STYLE instructs the Vivado synthesis tool on how to
    --	infer ROM memory.
    --	By default, the tool selects which ROM to infer, based
    --	upon heuristics that give the best results for most designs.
    --	Place this attribute on the array declared for the ROM.
    --
    --	Values are:
    --	block:	Instructs the tool to infer RAMB type components
    --	distributed:	Instructs the tool to infer the LUT ROMs.


    attribute RPM_GRID : string;


    attribute SHREG_EXTRACT : string;

    --  SHREG_EXTRACT instructs the synthesis tool on whether to infer 
    --  SRL structures.
    --
    --  Place SHREG_EXTRACT on the signal declared for SRL or the 
    --  module/entity with the SRL.
    --
    --  values are YES and NO.


    attribute SLEW : string;


    attribute SRL_STYLE : string;

    --  SRL_STYLE tells the synthesis tool how to infer SRLs that are 
    --  found in the design. Accepted values are:
    --
    --  "register" :	The tool does not infer an SRL, but instead 
    --			only uses registers.
    --  "srl" :		The tool infers an SRL without any registers 
    --			before or after.
    --  "srl_reg" :	The tool infers an SRL and leaves one register
    --			after the SRL.
    --  "reg_srl" :	The tool infers an SRL and leaves one register
    --			before the SRL.
    --  "reg_srl_reg" :	The tool infers an SRL and leaves one register
    --			before and one register after the SRL.
    --
    --  Place SRL_STYLE on the signal declared for SRL.


    attribute U_SET : string;

    attribute USE_DSP48 : string;

    --  USE_DSP48 instructs the synthesis tool how to deal with 
    --  synthesis arithmetic structures.
    --
    --  By default, mults, mult-add, mult-sub, mult-accumulate type 
    --  structures go into DSP48 blocks.
    --  Adders, subtractors, and accumulators can also go into these
    --  blocks but by default, are implemented with the fabric instead
    --  of with DSP48 blocks.
    --
    --  values are YES and NO.

end package;

package body vivado_pkg is

end package body;




package vivado_pull_pkg is

    attribute PULLDOWN : string;

    --  PULLDOWN applies a weak logic low level on a tri-stateable
    --  output or bidirectional port to prevent it from floating.
    --
    --  The PULLDOWN property guarantees a logic Low level to allow
    --  tri-stated nets to avoid floating when not being driven.
    --
    --  Values are FALSE, TRUE, YES and NO.


    attribute PULLUP : string;

    --  PULLUP applies a weak logic High on a tri-stateable output
    --  or bidirectional port to prevent it from floating.
    --
    --  The PULLUP property guarantees a logic High level to allow
    --  tri-stated nets to avoid floating when not being driven.
    --
    --  Values are FALSE, TRUE, YES and NO.

    attribute KEEPER : string;

    --  KEEPER applies a weak driver on a tri-stateable output or
    --  bidirectional port to preserve its value when not being driven.
    --
    --  The KEEPER property retains the value of the output net to
    --  which it is attached.
    --
    --  For example, if logic 1 is being driven onto a net, KEEPER
    --  drives a weak or resistive 1 onto the net. If the net driver
    --  is then tri-stated, KEEPER continues to drive a weak or 
    --  resistive 1 onto the net to preserve that value.
    --
    --  Values are FALSE, TRUE, YES and NO.

end package;

package body vivado_pull_pkg is

end package body;
