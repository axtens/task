include std/cmdline.e
include std/map.e  
include std/filesys.e
include std/convert.e
include std/text.e
include std/sequence.e
include std/search.e
include std/io.e
include euphoria/tokenize.e
include std/console.e 

ifdef WINDOWS then
--    include prompt_string_ed.e 
end ifdef 

without warning
with trace

map task = map:new()
sequence userprofile = {}
ifdef WINDOWS then
    userprofile = getenv("USERPROFILE")
elsedef
    userprofile = getenv("HOME")
end ifdef

sequence root = join_path({userprofile,".task"})
ifdef WINDOWS then
    root = trim_head(root, "\\")
end ifdef

create_directory(root)
sequence cl = command_line()
integer inCli = 0

procedure if_no_task_die(sequence msg)
    if not map:has(task, "id") then
        puts(1, msg & "\n")
        if not inCli then abort(1) end if
    end if
end procedure

function no_task() 
    return not map:has(task, "id")
end function

procedure save(sequence id)
    sequence taskname = id
    sequence taskpath = join_path({root, taskname & ".task"}) 
    ifdef WINDOWS then
        taskpath = trim_head(taskpath, "\\")
    end ifdef
    save_map(task, taskpath)
    --puts(1, taskname & "\n")
end procedure

function make_id(sequence arg) 
    --trace(1)
    sequence result = {}
    sequence words = split_any(arg," .,\t",0, 1)
    for i = 1 to length(words) do
        result  = append(result, head(words[i], 3))
    end for
    return upper(head(join(result,""),9))
end function

function info_of(sequence id) 
    map itask = map:new()
    sequence taskfile = id & ".task"
    sequence taskpath = join_path({root, taskfile})
    ifdef WINDOWS then
        taskpath = trim_head(taskpath, "\\")
    end ifdef
    object load = map:load_map(taskpath)
    if equal(load, -1) then
        printf(STDERR, "Not found %s\n", {taskpath})
        return ""
    else
        itask = load
        sequence name = map:get(itask,"name")
        sequence due = map:get(itask,"due")
        sequence done = map:get(itask,"done")
        return sprintf("%s '%s' (due:%s) (done:%s)\n", {id, name, due, done})
    end if
end function

procedure init(sequence arg)
    --puts(1, arg & "\n")    
    put(task, "name", arg)
    put(task, "tags", "")
    put(task, "due", "")
    put(task, "done", "")
    put(task, "notes", "")
    put(task, "links", "")
    put(task, "parent", "")
    put(task, "children", "")
    sequence id = make_id(arg)
    --sequence id = upper(filter(arg, STDFLTR_ALPHA))
    put(task, "id",id)
    save(id)
end procedure

procedure is(sequence arg)
    -- puts(1, arg)    
    arg = upper(arg)
    sequence taskfile = arg & ".task"
    sequence taskpath = join_path({root, taskfile})
    ifdef WINDOWS then
        taskpath = trim_head(taskpath, "\\")
    end ifdef
    object load = load_map(taskpath)
    if equal(load, -1) then 
        puts(STDERR, sprintf("%s not loaded\n", {taskpath}))
    else
        task = load    
        puts(STDERR, info_of(map:get(task,"id")))
    end if
end procedure

procedure tag(sequence arg)
    if_no_task_die("No task in focus")
    object tags = map:get(task, "tags", -1)
    if equal(tags, -1) then
        map:put(task,"tags",arg)
    else 
        sequence items = split(tags, ",")
        if length(items) = 0 then
            items = append(items, arg)
        else
            integer f = find(arg, items)
            if f = 0 then
                items = append(items, arg)
            else 
                items = remove(items, f)
                printf(1, "Removed %s\n", {arg})
            end if
        end if
        map:put(task,"tags",join(items,","))
    end if
    save(map:get(task,"id"))
end procedure

procedure link(sequence arg)
    if_no_task_die("No task in focus")
    object links = map:get(task, "links", -1)
    if equal(links, -1) then
        map:put(task,"links",arg)
    else 
        sequence items = split(links, ",")
        if length(items) = 0 then
            items = append(items, arg)
        else
            integer f = find(arg, items)
            if f = 0 then
                items = append(items, arg)
            else 
                items = remove(items, f)
            end if
        end if
        map:put(task,"links",join(items,","))
    end if
    save(map:get(task,"id"))
    
end procedure

procedure parent(sequence arg)
    if_no_task_die("No task in focus")
    arg = upper(arg)
    object links = map:get(task, "parent", -1)
    map:put(task,"parent",arg)
    save(map:get(task,"id"))    
end procedure

procedure child(sequence arg)
    if_no_task_die("No task in focus")
    arg = upper(arg)
    object children = map:get(task, "children", -1)
    if equal(children, -1) then
        map:put(task,"children",arg)
    else 
        sequence items = split(children, ",")
        if length(items) = 0 then
            items = append(items, arg)
        else
            integer f = find(arg, items)
            if f = 0 then
                items = append(items, arg)
            else 
                items = remove(items, f)
            end if
        end if
        map:put(task,"children",join(items,","))
    end if
    save(map:get(task,"id"))
    
end procedure

procedure note(sequence arg)
    if_no_task_die("No task in focus")
    object notes = map:get(task, "notes", -1)
    if equal(notes, -1) then
        map:put(task,"notes",arg)
    else 
        sequence items = split(notes, ",")
        items = append(items, arg)
        map:put(task,"notes",join(items,","))
    end if    
    save(map:get(task,"id"))
end procedure

procedure due(sequence arg)
    if_no_task_die("No task in focus")
    object links = map:get(task, "due", -1)
    map:put(task,"due",arg)
    save(map:get(task,"id"))    
end procedure

procedure name(sequence arg)
    if_no_task_die("No task in focus")
    object links = map:get(task, "name", -1)
    map:put(task,"name",arg)
    save(map:get(task,"id"))    
end procedure

procedure done(sequence arg)
    if_no_task_die("No task in focus")
    object links = map:get(task, "done", -1)
    map:put(task,"done",arg)
    save(map:get(task,"id"))    
end procedure

procedure show_parents() 
    object parents = map:get(task, "parents", -1)
    if equal(parents, -1) then
        puts(STDERR, "Task has no parents.\n")
        return
    end if
    parents = split(parents, ",")
    for i = 1 to length(parents) do
        puts(STDOUT, info_of(parents[i]) & "\n")
    end for
end procedure

procedure show_children()
    object children = map:get(task, "children", -1)
    if equal(children, -1) then
        puts(STDERR, "Task has no children.\n")
        return
    end if
    children = split(children, ",")
    for i = 1 to length(children) do
        puts(STDOUT, info_of(children[i]) & "\n")
    end for
end procedure

procedure show(sequence arg)
    if_no_task_die("No task in focus")
    if equal(arg, "parents") then
        show_parents()
    elsif equal(arg, "children") then
        --trace(1)
        show_children()
    elsif equal(arg, "all") then        
        sequence keys = map:keys(task)
        printf(2, "%s\n", {join(repeat("-",20),"")})
        for i = 1 to length(keys) do
            sequence got = map:get(task, keys[i])
            printf(2, "%s => '%s'\n", {keys[i], got})
        end for
        printf(2, "%s\n", {join(repeat("-",20),"")})
    else
        printf(2, "Don't know how to 'show %s'\n",{arg})
    end if
end procedure

procedure are(sequence arg, integer nxt_ptr)
    object tasks = dir(root)
    if equal(tasks,-1) then
        puts(1, "No tasks")
    else
        for i = 1 to length(tasks) do
            sequence name = tasks[i][1]
            if ends(".task",name) then
                sequence parts = split(name, ".")
                is(parts[1])
                parse_pairs_from(nxt_ptr)                
            end if
        end for
        if not inCli then abort(1) end if
    end if
end procedure 

procedure check(sequence arg)
    if_no_task_die("No task in focus")
    if equal(arg, "parent") then 
        
    elsif equal(arg, "child") then
        
    else
        printf(2, "I don't know how to 'check %s'\n", {arg})
    end if
    -- do I have parents? 
    --  look for each of them and add the current id to them as child
    -- do I have children?
    --  look for each of them and add the current id to them as parent
end procedure

procedure query(sequence arg)
    puts(1, arg)    
    
end procedure

--for i = 3 to length(cl) do
--    printf(1, "%d: %s\n", {i, cl[i]})
--end for

procedure list(sequence arg)
    object tasks = dir(root)
    if equal(tasks,-1) then
        puts(1, "No tasks")
    else
        for i = 1 to length(tasks) do
            sequence name = tasks[i][1]
            if ends(".task",name) then
                puts(1, name & "\n")
            end if
        end for
    end if 
end procedure 

if length(cl) < 3 then
    inCli = 1
    sequence parse = {}
    while 1 do
        cl = {}
        --ifdef WINDOWS then
        --    sequence cmd = prompt_string_ed(prompt())
        --elsedef
            sequence cmd = prompt_string(prompt())
        --end ifdef
        if equal("exit", cmd) then
            exit 
        end if
        puts(STDOUT, "\n")
        sequence tokens = tokenize_string(cmd)
        parse = tokens[1]
        for i = 1 to length(parse) do
            --printf(STDERR, "%d: %s\n", {i, parse[i][TDATA]})
            cl = append(cl, parse[i][TDATA])
        end for
        parse_pairs_from(1)
    end while
end if

function prompt() 
    if map:has(task, "id") then
        return map:get(task, "id") & "> "
    else
        return "> "
    end if
end function

procedure parse_pairs_from(integer ptr)
    while ptr < length(cl) do
        if equal(cl[ptr], "new") then 
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
        elsif equal(cl[ptr], "note") then
            note(cl[ptr+1])
        elsif equal(cl[ptr], "due") then
            due(cl[ptr+1])
        elsif equal(cl[ptr], "name") then
            name(cl[ptr+1])
        elsif equal(cl[ptr], "done") then
            done(cl[ptr+1])
        elsif equal(cl[ptr], "query") then
            query(cl[ptr+1])
        elsif equal(cl[ptr], "show") then
            show(cl[ptr+1])
        elsif equal(cl[ptr], "are") then
            are(cl[ptr+1], ptr+2)
        elsif equal(cl[ptr], "list") then
            list(cl[ptr+1])
        elsif equal(cl[ptr], "check") then
            check(cl[ptr+1])
        else 
            printf(1, "%s?\n", {cl[ptr]})
        end if
        ptr += 2
    end while
end procedure

parse_pairs_from(3)

puts(1, map:get(task,"id") & "\n")
