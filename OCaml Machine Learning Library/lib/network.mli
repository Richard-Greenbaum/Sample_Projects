
module Make : functor (L : Layer.Sig) -> sig
  (** Type of a network *)
  type t

  (** Type of data *)
  type data = (Matrix.t * Matrix.t)

  (** Type of gradient descent data training technique *)
  type gradient_descent = Stochastic | Batch | MiniBatch of int

  (** [compose l n] combines layer [l] and network [n] *)
  val compose : L.t -> t -> t

  (** [l @.@ n] combines layer [l] and network [n] *)
  val ( @.@ ) : L.t -> t -> t

  (** [of_layer l] is the network with the single layer [l]. *)
  val of_layer : L.t -> t

  (** [train ~ep lr me gt dp of lf ld n d] is a trained model of [t] using [ep] 
      as the error threshold value for stopping training, the given data list, 
      and the given loss function. [train] [forward_propogate]'s and 
      [back_propogate]s [me] number of times or until the loss of the network
      drops below [ep]. Specifying [of] means that the network will be saved,
      [dp] is the dropout percentage necessary for forward propogation, with 
      [lf] and [ld] being the loss function and its derivative, [n] being the 
      network that is training, and [d] being the entire set of data that is
      being used for training. The parameter [gt] represents the type of 
      gradient descent batching technique that is being used. Normalization 
      techniques for batches are used. *)
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

  (** [eval_all eo n d] is the number of correct evaluations over the number of 
      total test cases equalling the accuracy of the model itself. [eval_all] 
      evaluates the network [n] using all supplied test data cases in [d]. *)
  val eval_all
    : ?expand_output:bool
    -> t -> data -> float

  (** [format fmt t] prints out [t] to [fmt]. *)
  val format : Format.formatter -> t -> unit

  (** [print t] prints out [t] to [stdout]. *)
  val print : t -> unit

  (** [save t name] creates a directory where each csv file is the representation of
      a layer of t *)
  val save : t -> string -> unit

  (** [load dir] creates the network represented by the directory dir based on 
      the layer conversion function f *)
  val load : string -> t

end
