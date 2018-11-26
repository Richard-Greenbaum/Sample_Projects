
module type Sig = sig
  (** Type of a layer *)
  type t

  (** [create_layer i o] creates a new layer that takes in [i] inputs and 
      has [o] outputs. *)
  val create_layer : inputs:int -> outputs:int -> t

  (** [forward_propogate d m l] is a matrix representing the output of the layer 
      after being evaluated. The layer [l] is evaluated using data matrix [d] 
      with a dropout percentage of [d]. *)
  val forward_propagate : ?dp:float -> Matrix.t -> t -> Matrix.t

  (** [apply_delta d l] applies the changes, deltas [d], from back_propogation
      to the layer [l]. *)
  val apply_delta : t -> t -> t

  (** [add_derivatives d1 d2] is the derivative layer representing the sum of 
      the two derivatives *)
  val add_derivatives : t -> t -> t

  (** [average_derivative d n] is the average of the derivative [d] over [n] 
      entries.*)
  val average_derivative : t -> float -> t

  (** [backward_propogate a d l n_l act] is the new layer with deltas that is
      the result of applying the backward_propogation algorithm using learning
      rate [a], a delta [d] representing the differentiable function we are 
      using, the current layer [l], the next_layer [n_l] the was propogated 
      before [l], and the activation function [act]. *)
  val backward_propagate
    : learning_rate:float
    -> delta:Matrix.t
    -> layer:t
    -> next_layer:t option
    -> activation:Matrix.t
    -> (Matrix.t * t)

  (** [format fmt l] prints out [l] to [fmt]. *)
  val format : Format.formatter -> t -> unit

  (** [print l] prints layer [l] to std out *)
  val print : t -> unit

  (** [save s l] saves the layer [l] to a file [s] within a network archive 
      to be used again. *)
  val save : string -> t -> unit

  (** [load s] loads the selected file [s] from a network archive back into a 
      layer. *)
  val load : string -> t
end
