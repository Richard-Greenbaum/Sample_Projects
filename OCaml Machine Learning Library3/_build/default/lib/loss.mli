
module type Func = sig
  val loss : Matrix.t -> Matrix.t -> float
  val loss_deriv : Matrix.t -> Matrix.t -> Matrix.t
end

module SquaredDifference : Func
module Hinge : Func
module CrossEntropy : Func
