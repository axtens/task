include std/cmdline.e

procedure init(sequence arg)
    puts(1, arg)    
end procedure

procedure is(sequence arg)
    puts(1, arg)    
    
end procedure

procedure tag(sequence arg)
    puts(1, arg)    
    
end procedure

procedure link(sequence arg)
    puts(1, arg)    
    
end procedure

procedure parent(sequence arg)
    puts(1, arg)    
    
end procedure

procedure child(sequence arg)
    puts(1, arg)    
    
end procedure

procedure detail(sequence arg)
    puts(1, arg)    
    
end procedure

procedure due(sequence arg)
    puts(1, arg)    
    
end procedure

procedure done(sequence arg)
    puts(1, arg)    
    
end procedure

procedure query(sequence arg)
    puts(1, arg)    
    
end procedure

sequence cl = command_line()
--for i = 3 to length(cl) do
--    printf(1, "%d: %s\n", {i, cl[i]})
--end for

if length(cl) < 3 then
    puts(1, "eui task.ex init|is|tag|link|parent|child|detail|due|done|query x")
    abort(1)
end if

integer ptr = 3
while ptr < length(cl) do
    if equal(cl[ptr], "init") then 
        init(cl[ptr + 1])
    elsif equal(cl[ptr], "is") then
        is(cl[ptr+1])
    elsif equal(cl[ptr], "tag") then
        tag(cl[ptr+1])
    elsif equal(cl[ptr], "link") then
        link(cl[ptr+1])
    elsif equal(cl[ptr], "parent") then
        parent(cl[ptr+1])
    elsif equal(cl[ptr], "child" ) then
        child(cl[ptr+1])
    elsif equal(cl[ptr], "detail") then
        detail(cl[ptr+1])
    elsif equal(cl[ptr], "due") then
        due(cl[ptr+1])
    elsif equal(cl[ptr], "done") then
        done(cl[ptr+1])
    elsif equal(cl[ptr], "query") then
        query(cl[ptr+1])
    end if
    ptr += 2
end while
