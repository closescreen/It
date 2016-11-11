module It

import Base.getindex

"""
[1,2,3] |> map(x->x+1)
"""
map(f::Function) = xs->Base.map(f,xs)
map(f1::Function,f2::Function) = map( x->f2(f1(x)) )
map(f1::Function,f2::Function,ff::Function...) = map(x->f2(f1(x)), ff...)



"""
    [1,2,3,4] |> filter(x->x<3) # [1,2]
    [1,2,3,4] |> filter(x->x>1, x->x<4) # [2,3] - logical 'and'
    
"""
filter(f::Function) = itr->Base.filter(f,itr)
filter(f1::Function, f2::Function) = itr->filter( x->f1(x)&&f2(x), itr )
filter(f1::Function, f2::Function, ff::Function...) = 
    filter(x->f1(x)&&f2(x), ff)


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



# ---------------------------- mapfilter -------------------
immutable EMapFil{F,I}
    f::F
    i::I
end


function Base.next(itr::EMapFil, s)
    (rv,si) = s
    si2=advance_itr(itr, si)
    (rv,si2)
end

function Base.start(itr::EMapFil)
    si = start(itr.i)
    advance_itr(itr, si)
end

function advance_itr(itr,si)
    while !done(itr.i,si)
    (v,si)=next(itr.i,si)
    rv=itr.f(v)
    if rv!=nothing
        return (rv,si)
    end
    end
    (nothing,)
end

Base.done(itr::EMapFil, s) = s[1]==nothing



"""
    mapfilter(func,iter)->iter

    mapfilter(func)->iter->iter
    
    mapfilter(func1,func2,other...)->mapfilter(comp(func2,func1),other...)

    Filter and map 2 in 1.
    Creates new collection iterator like map.
    But if func returns nothing, then current item of iter will be skipped.

"""
mapfilter(f::Function, itr) = EMapFil(f,itr)
mapfilter(f::Function) = itr->mapfilter(f,itr)
mapfilter(f1::Function,f2::Function,other...) = mapfilter(comp(f2,f1),other...)



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
