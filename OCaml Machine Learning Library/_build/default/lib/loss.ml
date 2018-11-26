
module type Func = sig
  val loss : Matrix.t -> Matrix.t -> float
  val loss_deriv : Matrix.t -> Matrix.t -> Matrix.t
end

module SquaredDifference : Func = struct
  let loss actual expected =
    (1. /. 2.) *. (Matrix.norm @@ Matrix.return @@ Matrix.sub expected actual)

  let loss_deriv actual expected =
    Matrix.return @@ Matrix.sub expected actual
end

module Hinge : Func = struct
  let loss actual expected =
    (* Matrix.print actual; *)
    (* Matrix.print expected; *)
    let ty = Matrix.dot actual expected in
    let gamma = float_of_int (Matrix.height expected) in
    (* let gamma = 1. in *)
    10000. *. if ty >= 1. -. gamma then
      (1. /. (2. *. gamma)) *. (max 0. (1. -. ty) ** 2.)
    else
      1. -. (gamma /. 2.) -. ty
    (* Printf.printf "c: %f\n\n" (1. -. v); *)
    (* max 0. (1. -. v) *)

  let loss_deriv actual expected =
    Matrix.return @@ Matrix.sub expected actual
    (* if Matrix.dot expected actual <= 1. then
     *   let x = Matrix.map2 (fun a b -> (-. a) *. b)
     *     expected
     *     actual
     *   |> Matrix.return
     *   in
     *   (\* Printf.printf "deriv:\n"; *\)
     *   (\* Matrix.print x; *\)
     *   x
     * else
     *   Matrix.zeros ~m:(Matrix.height actual) ~n:1 *)

end

module CrossEntropy : Func = struct
  (* let loss actual expected =
   *   -. (Matrix.dot expected (Matrix.map log actual)) *)
  let loss actual expected =
    let actual' = Differentiable.Softmax.apply actual in
    -. (Matrix.dot expected (Matrix.map log actual'))

  let loss_deriv actual expected =
    Matrix.sub actual expected
    |> Matrix.return
end
