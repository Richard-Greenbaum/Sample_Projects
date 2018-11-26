
module type Sig = sig
  type t
  val create_layer : inputs:int -> outputs:int -> t
  val forward_propagate : ?dp:float -> Matrix.t -> t -> Matrix.t
  val apply_delta : t -> t -> t
  val add_derivatives : t -> t -> t
  val average_derivative : t -> float -> t
  val backward_propagate
    : learning_rate:float
    -> delta:Matrix.t
    -> layer:t
    -> next_layer:t option
    -> activation:Matrix.t
    -> (Matrix.t * t)
  val format : Format.formatter -> t -> unit
  val print : t -> unit
  val save : string -> t -> unit
  val load : string -> t
end
