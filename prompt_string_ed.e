-- This is a replacement for the prompt_string() function
-- works with Phix 1.0 and later
-- Version 1.11, March 2024
-- Robert Schaechter, www.hypatia-rpn.net

-- does currently not work with Linux

-- *** Important ***
-- needs global object edstack (stack of editor input lines)

-- before prompt_string_ed is called the first time, edstack has to be set to ""
-- when prompt_string_ed is called, a line is added to edstack
-- on exit of prompt_string_ed, edstack[1] ist most recent input line,
-- same as the line that is returned by the function, unless input line is blank
-- edstack lines can be manipulated or provided by the calling program, but prompt_string_ed cuts them to max. length

-- No line wrap, max length of input string = screen width minus 1 minus length of promt string

-- Editing functions:
-- Cursor moved by left, right, home, and end keys
-- Backspace deletes character left of cursor
-- Delete deletes character at cursor position
-- Up and down keys at cursor position 1 scroll through past input lines
-- Esc key moves cursor to cursor position 1, and then to current input line
-- Always in insert mode, any character typed is inserted at cursor position
-- Enter returns input string regardless of cursor position


include graphics.e

global function prompt_string_ed(sequence prompt)

  object pos                       -- for calling get_position
  object in_string                 -- input string
  integer edl                      -- line in edstack
  integer s                        -- pressed key
  integer in_c                     -- cursor position in input string
  integer pl                       -- prompt length
  integer in_max                   -- input max length
  integer in_l                     -- current length of input string
  integer screen_li                -- screen cursor position line

  in_max = video_config()[10] - length(prompt) - 1

  for j = 1 to length(edstack) do          -- reduce lines in stack to max. length
    if length(edstack[j]) > in_max then
      edstack[j] = edstack[j][1..in_max]
    end if
  end for

  edl = 1
  edstack = prepend(edstack, "")

  puts(1, prompt)
  pl = length(prompt)
  in_string = ""
  in_l = 0
  in_c = 1

  pos = get_position()
  screen_li = pos[1]

  while 1 do                               -- loop exited when return key pressed
    s = wait_key()

    if s < 32 then                         -- ctrl characters
      if s = 13 then                       -- return
        exit
      elsif s = 8 then                     -- backspace
        if in_l > 0 then
          if in_l = in_c - 1 then
            in_string = in_string[1..in_l-1]
            in_l -= 1
            in_c -= 1
            position (screen_li, in_c + pl)
            puts(1, " ")
            position (screen_li, in_c + pl)
          elsif in_c > 1 then
            in_string = in_string[1..in_c-2] & in_string[in_c..$]
            in_l -= 1
            in_c -= 1
            position (screen_li, in_c + pl)
            puts(1, in_string[in_c..$] & " ")
            position (screen_li, in_c + pl)
          end if
        end if
      elsif s = 27 then                    -- ESC
        if in_c > 1 then
          in_c = 1
          position (screen_li, in_c + pl)
        elsif edl > 1 then
          edl = 1
          in_string = edstack[edl]
          in_l = length(in_string)
          puts(1, in_string)
          puts(1, repeat(' ', in_max - length(in_string)))
          position(screen_li, pl + 1)
        end if
      end if

    elsif s = 328 then                     -- up
      if in_c = 1 then
        if edl < length(edstack) then
          if edl = 1 then
            edstack[1] = in_string
          end if
          edl += 1
          in_string = edstack[edl]
          in_l = length(in_string)
          puts(1, in_string)
          puts(1, repeat(' ', in_max - length(in_string)))
          position(screen_li, pl + 1)
        end if
      end if

    elsif s = 336 then                     -- down
      if in_c = 1 then
        if edl > 1 then
          edl -= 1
          in_string = edstack[edl]
          in_l = length(in_string)
          puts(1, in_string)
          puts(1, repeat(' ', in_max - length(in_string)))
          position(screen_li, pl + 1)
        end if
      end if

    elsif s = 339 then                     -- delete
      if in_l > 0 then
        if in_c < in_l + 1 then
          in_string = in_string[1..in_c-1] & in_string[in_c+1..$]
          in_l -= 1
          position (screen_li, in_c + pl)
          puts(1, in_string[in_c..$] & " ")
          position (screen_li, in_c + pl)
        end if
      end if

    elsif s = 327 then                     -- home
      in_c = 1
      position (screen_li, in_c + pl)
    elsif s = 335 then                     -- end
      in_c = in_l + 1
      position (screen_li, in_c + pl)
    elsif s = 331 then                     -- arrow left
      if in_c > 1 then
        in_c -= 1
        position (screen_li, in_c + pl)
      end if
    elsif s = 333 then                     -- arrow right
      if in_c < in_l + 1 then
        in_c += 1
        position (screen_li, in_c + pl)
      end if

    elsif s < 128 then                     -- printable characters, change to 256 to allow 8-bit characters
      if in_l < in_max then                -- max length of input string not yet reached
        if in_l = in_c - 1 then            -- cursor at line end
          puts(1, s)
          in_string = in_string & s
        else
          in_string = in_string[1..in_c-1] & s & in_string[in_c..$]
          position (screen_li, in_c + pl)
          puts(1, in_string[in_c..$])
          position (screen_li, in_c + pl + 1)
        end if
        in_l += 1
        in_c += 1
      end if
    end if
  end while

  puts(1, "\n")
  if length(in_string) then                 -- empty input lines are returned, but not added to edstack
    edstack[1] = in_string
  else
    edstack = edstack[2..$]
  end if
  return in_string
end function