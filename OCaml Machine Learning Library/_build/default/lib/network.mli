
module Make : functor (L : Layer.Sig) -> sig
  (** Type of a network *)
  type t

  type data = (Matrix.t * Matrix.t)

  type gradient_descent = Stochastic | Batch | MiniBatch of int

  (** [compose l n] combines layer [l] and network [n] *)
  val compose : L.t -> t -> t

  (** [l @.@ n] combines layer [l] and network [n] *)
  val ( @.@ ) : L.t -> t -> t

  (** [of_layer l] is the network with the single layer [l]. *)
  val of_layer : L.t -> t

  (** [train ~ep t data loss_func] is a trained model of [t]
      using [ep] as the error threshold value for stopping training, the given data
      list, and the given loss function. *)
  val train
    : ?epsilon:float
    -> ?learning:float
    -> ?max_epoch:int option
    -> ?gradient_type:gradient_descent
    -> ?dropout:float
    -> ?output_file:string option
    -> loss:(Matrix.t -> Matrix.t -> float)
    -> loss_deriv:(Matrix.t -> Matrix.t -> Matrix.t)
    -> t
    -> data
    -> t

  (** [evaluate m n] is the result of running [m] through the network [n]. *)
  val evaluate : Matrix.t -> t -> Matrix.t

  val eval_all
    : ?expand_output:bool
    -> t -> data -> float

  (** [format fmt t] prints out [t] to [fmt]. *)
  val format : Format.formatter -> t -> unit

  (** [print t] prints out [t] to [stdout]. *)
  val print : t -> unit

  (** [to_csv t name] creates a directory where each csv file is the representation of
  a layer of t *)
  val save : t -> string -> unit

  (** [from_csv dir f] creates the network represented by the directory dir based on the layer 
  conversion function f *)
  val load : string -> t

end
