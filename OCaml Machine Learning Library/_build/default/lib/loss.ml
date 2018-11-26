(** Func: Signature of a Loss Function *)
module type Func = sig
  (** [loss a b] is the loss for the given evaluation given an evaluation
      output matrix and a truth matrix representing the actual expected outputs. *)
  val loss : Matrix.t -> Matrix.t -> float

  (** [loss_deriv a b] is the derivative of the loss function *)
  val loss_deriv : Matrix.t -> Matrix.t -> Matrix.t
end

module SquaredDifference : Func = struct
  (** [loss a b] is the loss for the given evaluation of the Squared Difference
      loss function given an evaluation output matrix and a truth matrix 
      representing the actual expected outputs. The squared difference loss
      function is characterized by the norm of the differences of the two given
      output and truth matrices. *)
  let loss actual expected =
    (1. /. 2.) *. (Matrix.norm @@ Matrix.return @@ Matrix.sub expected actual)

  (** [loss_deriv a b] is the derivative of the squared difference loss
      function. *)
  let loss_deriv actual expected =
    Matrix.return @@ Matrix.sub expected actual
end

module Hinge : Func = struct
  (** [loss a b] is the loss function for the hinge loss function, which is 
      characterized by { l(y) = max(0, 1- t . y) }, where "." is the dot 
      product. *)
  let loss actual expected =
    let ty = Matrix.dot actual expected in
    let gamma = float_of_int (Matrix.height expected) in
    10000. *. if ty >= 1. -. gamma then
      (1. /. (2. *. gamma)) *. (max 0. (1. -. ty) ** 2.)
    else
      1. -. (gamma /. 2.) -. ty

  (** [loss_deriv a b] is the derivative of the hinge loss function. *)
  let loss_deriv actual expected =
    Matrix.return @@ Matrix.sub expected actual

end

module CrossEntropy : Func = struct
  (** [loss a b] is the loss function for the cross entropy loss function, 
      characterized by { −∑ [c=1, M] (y_{o,c} * log(p_o,c) } *)
  let loss actual expected =
    let actual' = Differentiable.Softmax.apply actual in
    -. (Matrix.dot expected (Matrix.map log actual'))

  (** [loss_deriv a b] is the derivative of the cross entropy loss function. *)
  let loss_deriv actual expected =
    Matrix.sub actual expected
    |> Matrix.return
end
