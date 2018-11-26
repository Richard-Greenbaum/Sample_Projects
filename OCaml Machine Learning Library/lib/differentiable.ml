
(** Signature of a Differentiable activation function *)
module type Sig = sig
  (** [apply m] applies the activation function over matrix [m]. *)
  val apply : Matrix.t -> Matrix.t

  (** [derivative m] applies the derivative of the activation function over 
      matrix [m]. *)
  val derivative : Matrix.t -> Matrix.t
end

module Sigmoid : Sig = struct
  (** [apply m] applies the Sigmoid A.F. over matrix [m]. *)
  let apply m =
    Matrix.map
      (fun n ->
         (1.) /.
         (1. +. exp (-. n)))
      m

  (** [derivative m] applies the derivative of the Sigmoid A.F. over 
      matrix [m]. *)
  let derivative m =
    let ones = Matrix.ones ~m:(Matrix.height m) ~n:(Matrix.width m) in
    let res = apply m in
    Matrix.return @@ Matrix.map2 ( *. )
      res
      (Matrix.return @@ Matrix.sub ones res)
end

module Softmax : Sig = struct
  (** [max m] is the maximum entry value in the matrix [m]. *)
  let max m =
    Matrix.fold_left
      (fun max_val v -> if v > max_val then v else max_val)
      0.
      m

  (** [apply m] applies the Softmax A.F. over matrix [m]. *)
  let apply m =
    let max_v = max m in
    let m' = Matrix.map (fun x -> x -. max_v) m in
    let exps = Matrix.map (fun v -> exp v) m' in
    let sum = Matrix.sum exps in
    let a = Matrix.map
        (fun x -> x /. sum)
        exps
    in
    a

  (** [derivative m] applies the derivative of the Softmax A.F. over matrix [m]. *)
  let derivative m =
    (* let sum = Matrix.sum @@ Matrix.map exp m in *)
    Matrix.map2 ( *. )
      m
      (Matrix.map (fun x -> 1. -. x) (apply m))
    |> Matrix.return
end