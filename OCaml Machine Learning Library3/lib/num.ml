(** [pow x y] is [x] raised to the [y]th power. Exponentiation for ints. *)
let rec pow x = function
  | 0 -> 1
  | 1 -> x
  | n -> (
      let x' = pow x (n / 2) in
      x' * x' * (if n mod 2 = 0 then 1 else x)
    )

(** [bin_pow x] is true if x is an int that is a power of 2, else false. *)
let bin_pow n = 
  let rec help x = 
    match x with 
    | 1. -> true
    | n when n < 1. -> false
    | n -> help (x /. 2.)
  in 
  help (float_of_int n)

(** [pad n] is the next closest larger binary power. If [bin_pow n] is [true]
    then just returns [n]. *)
let pad n = 
  if bin_pow n then n else 
    let rec help i = 
      let value = pow 2 i in 
      if value < n then help (i+1) else value
    in 
    help 0
