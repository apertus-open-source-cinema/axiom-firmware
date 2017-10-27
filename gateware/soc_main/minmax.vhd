library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

-- This package name is temporary.  I expect it to be added to the
-- numeric_std package.
package minmax is
-- Issues:
  -- There is an overloading problem with "min" as "min" is a unit of
  -- type "time".  Thus the "min" function is "minimum"
  -- Name:  Lots of people have "max" and "min" functions.  The rule in
  -- VHDL is that if two functions of the same name are visible, then
  -- neither are.  This could cause code not to work.  We could rename
  -- "minimum" and "max", but then the function name would not be logical.
  -- NOTE:  There already is a "max" and "min" function buried in the body
  -- of 1076.3
  -- I left out the mixing of types, I ran into problems like:
  -- If you do a min(signed, unsigned) with an
  -- unsigned result, what do you return if the signed number is negative?

  -- Returns the maximum (or minimum) of the two numbers provided.
  -- All types (both inputs and the output) must be the same.
  function maximum (
    left, right : integer)                     -- inputs
    return integer;

  function maximum (
    left, right : unsigned)                    -- inputs
    return unsigned;

  function maximum (
    left, right : signed)                      -- inputs
    return signed;

  function minimum (
    left, right : integer)                     -- inputs
    return integer;
  
  function minimum (
    left, right : unsigned)                    -- inputs
    return unsigned;

  function minimum (
    left, right : signed)                      -- inputs
    return signed;

  -- Finds the first "Y" in the input string. Returns an integer index
  -- into that string.  If "Y" does not exist in the string, then the
  -- "find_lsb" returns arg'low -1, and "find_msb" returns -1
  function find_lsb (
    arg : unsigned;                     -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;
  
  function find_lsb (
    arg : signed;                       -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;
  
  function find_msb (
    arg : unsigned;                     -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;
  
  function find_msb (
    arg : signed;                       -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;


-- For the numeric_unsigned package:
  function maximum (
    left, right : std_ulogic_vector)           -- inputs
    return std_ulogic_vector;

  function maximum (
    left, right : std_logic_vector)            -- inputs
    return std_logic_vector;
  
  function minimum (
    left, right : std_ulogic_vector)           -- inputs
    return std_ulogic_vector;
  
  function minimum (
    left, right : std_logic_vector)            -- inputs
    return std_logic_vector;

  function find_lsb (
    arg : std_ulogic_vector;            -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;
  
  function find_lsb (
    arg : std_logic_vector;             -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;
  
  function find_msb (
    arg : std_ulogic_vector;            -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;
  
  function find_msb (
    arg : std_logic_vector;             -- vector argument
    y   : std_ulogic)                   -- look for this bit
    return integer;
  
end package minmax;

package body minmax is

  -- THIS FUNCTION is already in the BODY of 1076.3 and called "MAX"
  function maximum (
    left, right : integer)                     -- inputs
    return integer is
  begin  -- function max
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function maximum;

  -- unsigned output
  function maximum (
    left, right : unsigned)                    -- inputs
    return unsigned is
  begin  -- function max
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function maximum;

  -- signed output
  function maximum (
    left, right : signed)                      -- inputs
    return signed is
  begin  -- function max
    if LEFT > RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function maximum;

  -- THIS FUNCTION is already in the BODY of 1076.3 and called "MIN"
  function minimum (
    left, right : integer)                     -- inputs
    return integer is
  begin  -- function minimum
    if LEFT < RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function minimum;

  -- unsigned output
  function minimum (
    left, right : unsigned)                    -- inputs
    return unsigned is
  begin  -- function minimum
    if LEFT < RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function minimum;

  -- signed output
  function minimum (
    left, right : signed)                      -- inputs
    return signed is
  begin  -- function minimum
    if LEFT < RIGHT then return LEFT;
    else return RIGHT;
    end if;
  end function minimum;

  function find_lsb (
    arg : unsigned;                         -- vector argument
    y   : std_ulogic)                       -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'reverse_range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_lsb;

  function find_lsb (
    arg : signed;                           -- vector argument
    y   : std_ulogic)                       -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'reverse_range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_lsb;

  function find_msb (
    arg : unsigned;                        -- vector argument
    y   : std_ulogic)                      -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_msb;

  function find_msb (
    arg : signed;                          -- vector argument
    y   : std_ulogic)                      -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_msb;


-- For the numeric_unsigned package:
  function maximum (
    left, right : std_ulogic_vector)           -- inputs
    return std_ulogic_vector is
  begin  -- function max
    if unsigned(LEFT) > unsigned(RIGHT) then return LEFT;
    else return RIGHT;
    end if;
  end function maximum;
  
  function maximum (
    left, right : std_logic_vector)            -- inputs
    return std_logic_vector is
  begin  -- function max
    if unsigned(LEFT) > unsigned(RIGHT) then return LEFT;
    else return RIGHT;
    end if;
  end function maximum;
  
  function minimum (
    left, right : std_ulogic_vector)           -- inputs
    return std_ulogic_vector is
  begin  -- function minimum
    if unsigned(LEFT) < unsigned(RIGHT) then return LEFT;
    else return RIGHT;
    end if;
  end function minimum;
  
  function minimum (
    left, right : std_logic_vector)            -- inputs
    return std_logic_vector is
  begin  -- function minimum
    if unsigned(LEFT) < unsigned(RIGHT) then return LEFT;
    else return RIGHT;
    end if;
  end function minimum;

  function find_lsb (
    arg : std_logic_vector;                 -- vector argument
    y   : std_ulogic)                       -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'reverse_range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_lsb;

  function find_lsb (
    arg : std_ulogic_vector;                -- vector argument
    y   : std_ulogic)                       -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'reverse_range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_lsb;

  function find_msb (
    arg : std_logic_vector;                -- vector argument
    y   : std_ulogic)                      -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_msb;

  function find_msb (
    arg : std_ulogic_vector;               -- vector argument
    y   : std_ulogic)                      -- look for this bit
    return integer is
  begin
    for_loop: for i in arg'range loop
      if arg(i) = y then
        return i;
      end if;
    end loop;
    return -1;
  end function find_msb;

end package body minmax;
