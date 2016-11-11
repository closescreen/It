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
