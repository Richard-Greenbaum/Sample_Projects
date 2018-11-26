
(** Func: Signature of a Loss Function *)
module type Func = sig
  (** [loss a b] is the loss for the given evaluation given an evaluation
        output matrix and a truth matrix representing the actual expected outputs. *)
  val loss : Matrix.t -> Matrix.t -> float

  (** [loss_deriv a b] is the derivative of the loss function *)
  val loss_deriv : Matrix.t -> Matrix.t -> Matrix.t
end

(** [SquaredDifference] Module *)
module SquaredDifference : Func

(** [Hinge] Module *)
module Hinge : Func

(** [CrossEntropy] Module *)
module CrossEntropy : Func
