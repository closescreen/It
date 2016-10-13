export ifsome
"""
    3|>ifsome(x->x+1) # 4
"""
ifsome(f1::Function) = _->ifsome(_,f1)

"nothing|>ifsome(x->x+1) # nothing"
ifsome(v::Void, f1::Function)=nothing

ifsome(sm, f::Function) = f(sm)

"3|>ifsome(x->x+1, ()->:no) # 4"
ifsome(f1::Function, f2::Function) = _->ifsome(_,f1,f2)

"nothing|>ifsome(x->x+1, ()->:no) # :no"
ifsome(v::Void, f1::Function, f2::Function) = f2()

ifsome(sm, f1::Function, f2::Function) = f1(sm)

"3|>ifsome(x->x+1, :no) # 4"
ifsome(f1::Function, v2::Any) = _->ifsome(_,f1,v2)

"nothing|>ifsome(x->x+1, :no) # :no"
ifsome(v::Void, f1::Function, v2)=v2

ifsome(sm, f1::Function, v2)=f1(sm)

