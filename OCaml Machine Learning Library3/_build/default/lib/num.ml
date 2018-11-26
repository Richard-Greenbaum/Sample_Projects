let rec pow x = function
  | 0 -> 1
  | 1 -> x
  | n -> (
      let x' = pow x (n / 2) in
      x' * x' * (if n mod 2 = 0 then 1 else x)
    )

let bin_pow n = 
  let rec help x = 
    match x with 
    | 1. -> true
    | n when n < 1. -> false
    | n -> help (x /. 2.)
  in 
  help (float_of_int n)
