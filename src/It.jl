module It

import Base.getindex



"""
    Partial for count(...)
    count( func::Function ) -> iter->count(func, iter)
    [1,2,3,4] |> count(x->x>1) # 3
"""
count(f::Function) = iter->Base.count(f,iter)

"""
    Partial for all(...)
    all(func) -> iter->all(func, iter) -> Bool
    [1,2,3,4] |> all(x->x>0) # true
"""
all(f::Function) = iter->Base.all(f,iter)


"""
    Partial for ismatch(...)
    \"asd\" |> ismatch(r::Regex) -> str->ismatch(r,str)
"""
ismatch(r::Regex) = s->Base.ismatch(r, s)


"""
    Partial function for replace(...) without first argument.

    replace(args...) -> x->replace(x,args...)
    
    f.e. \"file.txt\" |> replace(r\"\.txt\", \".csv\")
"""
replace( args... ) = x->Base.replace(x, args...)


"""
    Partial for match(...)
    \"asd\" |> match(r::Regex) -> str->match(r,str)
"""
match(r::Regex, args...) = s->Base.match(r, s, args...)

"""
    Partial for spl(...)
    \"asd*sdf\" |> split('*')
    \"asd sdf\" |> split() # - note what parenthes are present.
"""
split(splitter::Char, other...) = s->Base.split(s,splitter,other...)
split(splitter::Regex, other...) = s->Base.split(s,splitter,other...)
split() = s->Base.split(s)

"""
    Partial for take(...)
    [\"a\"] |> take(2) |> collect 
"""
take(n::Int) = itr->Base.take(itr,n)

"(3,4) |> getindex(1) # 3"
getindex(ind) = coll->Base.getindex(coll,ind)


"""[\"a\\n\",\"b\\n\",\"c\\n\"] |> Iter.print(STDOUT)"""
print(wio::IO; printfunc::Function=Base.print, closeio::Bool=false) =
    iter->print(wio::IO, iter, printfunc=printfunc, closeio=closeio)

"""[\"a\",\"b\",\"c\"] |> Iter.println(STDOUT)"""
println(wio::IO; closeio::Bool=false) = 
    print(wio, printfunc=Base.println, closeio=closeio)


"""[\"a\\n\",\"b\\n\",\"c\\n\"] |> Iter.print # print to STDOUT"""
print(iter)   = print(STDOUT,iter)


"""[\"a\",\"b\",\"c\"] |> Iter.println # println to STDOUT"""
println(iter) = print(STDOUT,iter,printfunc=Base.println)


"""
Iter.print(STDOUT, [\"a\\n\",\"b\\n\"])

Iter.print(STDOUT, 
    ([2,3,4],[4,5,6]), 
        printfunc=(wio,l)->println(wio, join(l,\"*\")))

"""
function print(wio::IO, iter; 
        printfunc::Function=Base.print, closeio::Bool=false) 
    for l in iter 
    printfunc(wio, l) 
    end
    if closeio
    close(wio)
    end 
end    
    

"""Iter.println(STDOUT, [\"a\",\"b\"])"""    
println(wio::IO, iter) = print(wio,iter,printfunc=Base.println)


"""
[\"a\\n\",\"b\\n\"] |> Iter.print(`bash -c 'gzip > \"aa.gz\"'`)

([2,3,4],[4,5,6]) |> 
    Iter.print(viatmp(\"cc.txt\"), 
    printfunc=(wio,l)->println(wio, join(l,\"*\")))
"""
print(wcmd::Cmd; printfunc::Function=Base.print) = 
    iter->print(wcmd, iter, printfunc=printfunc)


"""
    [\"a\",\"b\",\"c\"] |> Iter.println(`bash -c 'gzip > \"aa.gz\"'`)
"""    
println(wcmd::Cmd) = 
    print(wcmd, printfunc=Base.println)
    

"""
    Iter.print(`bash -c \"gzip > aa.gz\"`, [\"a\\n\",\"b\\n\"])
"""
function print(wcmd::Cmd, iter; 
        printfunc::Function=Base.print)
 (wio,wpr) = open(wcmd, "w")
 print(wio, iter, printfunc=printfunc)
 close(wio)
 wait(wpr)
 nothing
end


"""
    Iter.println(`bash -c \"gzip > aa.gz\"`, [\"a\",\"b\",\"c\"])
"""
println(wcmd::Cmd, iter) = 
    print(wcmd, iter, printfunc=Base.println)


"""Experimental!
[3,4,5]|>pager

Write iterator to tempname() and less() it
"""
function pager(itr)
    tmp = tempname()
    wio = open(tmp,"w")
    itr|>Iter.println(wio)
    close(wio)
    less(tmp)
    rm(tmp)
end


end # module
