module NonInterference

open FStar.Comp
open FStar.Relational

let a = alloc 0

let test () = a := 0; 
              a := 0; 
              a := 0; 
              a := 0; 
              a := 0; 
              a := 0; 
              a := 0; 
              a := 0; 
              a := 0; 
              a := 0; 
              a := 0

val test2 : double unit -> St2 (double unit)
let test2 x = compose2_self test x
