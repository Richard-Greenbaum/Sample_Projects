(* A layer module for layers that include both weights and biases. *)
module Layer (D : Differentiable.Sig) : Layer.Sig = struct

  (** Type of a fully connected layer.t with weights and biases as a record *)
  type t = {
    weights: Matrix.t;
    biases: Matrix.t
  }

  (** [create_layer i o] creates a new layer that takes in [i] inputs and 
      has [o] outputs. *)
  let create_layer ~inputs ~outputs =
    {
      weights = Matrix.random ~m:outputs ~n:inputs;
      biases = Matrix.random ~m:outputs ~n:1
    }

  (** [forward_propogate d m l] is a matrix representing the output of the layer 
      after being evaluated. The layer [l] is evaluated using data matrix [d] 
      with a dropout percentage of [d]. *)
  let forward_propagate ?(dp=0.5) in_vect t =
    ignore @@ dp;
    Matrix.return
    @@ Matrix.add
      (Matrix.mult t.weights in_vect)
      t.biases
    |> D.apply

  (** [apply_delta d l] applies the changes, deltas [d], from back_propogation
           to the layer [l]. *)
  let apply_delta deltas layer =
    {
      weights = Matrix.return @@ Matrix.add deltas.weights layer.weights;
      biases = Matrix.return @@ Matrix.add deltas.biases layer.biases
    }

  (** [add_derivatives d1 d2] is the derivative layer representing the sum of 
      the two derivatives *)
  let add_derivatives d1 d2 =
    {
      weights = Matrix.return @@ Matrix.add d1.weights d2.weights;
      biases = Matrix.return @@ Matrix.add d1.biases d2.biases;
    }

  (** [average_derivative d n] is the average of the derivative [d] over [n] 
      entries.*)
  let average_derivative layer n =
    {
      weights = Matrix.scalar_mult layer.weights (1. /. n);
      biases = Matrix.scalar_mult layer.biases (1. /. n)
    }

  (** [backward_propogate a d l n_l act] is the new layer with deltas that is
      the result of applying the backward_propogation algorithm using learning
      rate [a], a delta [d] representing the differentiable function we are 
      using, the current layer [l], the next_layer [n_l] the was propogated 
      before [l], and the activation function [act]. Biases are encompassed
      by treating them as layers. *)
  let backward_propagate ~learning_rate ~delta ~layer ~next_layer ~activation =
    let delta' =
      Matrix.return @@ match next_layer with
      | None ->
        Matrix.map2 ( *. )
          delta
          (D.derivative
             (Matrix.return
              @@ Matrix.add (Matrix.mult layer.weights activation) layer.biases))
      | Some next_layer ->
        Matrix.map2 ( *. )
          (Matrix.mult (Matrix.transpose next_layer.weights) delta)
          (D.derivative
             (Matrix.return
              @@ Matrix.add (Matrix.mult layer.weights activation) layer.biases))
    in
    let deriv_wrt_weights = Matrix.mult delta' (Matrix.transpose activation) in
    let deriv_wrt_weights = (Matrix.scalar_mult deriv_wrt_weights learning_rate) in
    let deriv_wrt_biases = Matrix.scalar_mult delta' learning_rate in
    let deriv = {weights=deriv_wrt_weights; biases=deriv_wrt_biases} in
    (delta', deriv)

  (** [format fmt l] prints out [l] to [fmt]. *)
  let format fmt t =
    Printf.printf "weights: "; Matrix.format fmt t.weights;
    Printf.printf "biases: "; Matrix.format fmt t.biases

  (** [print l] prints layer [l] to std out *)
  let print = format Format.std_formatter

  (** [chunk l s] a helper function for minibatching that creates a list of lists
      where the inner lists are of size [s] from a given list [l]. *)
  let chunk l size =
    let x = List.fold_left (fun (o,i) b ->
        if List.length i = size - 1 then
          let inner = List.rev (b::i) in
          (inner::o,[])
        else
          (o,b::i)
      )
        ([],[])
        l in
    x |> fst |> List.rev

  (** [save s l] saves the layer [l] to a file [s] within a network archive 
      to be used again. *)
  let save name l =
    let weight_list =
      List.map string_of_float
        ((float_of_int (Matrix.width l.weights)) :: (Matrix.to_flat_list l.weights))
    in
    let biases_list =
      List.map string_of_float
        ((float_of_int (Matrix.width l.biases)) :: (Matrix.to_flat_list l.biases))
    in
    let ch = open_out name in
    Printf.fprintf ch "%s\n" (String.concat "," weight_list);
    Printf.fprintf ch "%s\n" (String.concat "," biases_list);
    close_out ch

  (** [load s] loads the selected file [s] from a network archive back into a 
      layer. *)
  let load name =
    let matrices =
      Fstream.from_file name
      |> Fstream.map ~f:(Parse.split_line)
      |> Fstream.map ~f:(fun a ->
          List.map (fun b -> float_of_string b) a)
      |> Fstream.map ~f:(fun fl ->
          match fl with
          | [] -> failwith "Perceptron_biases.load called on empty file"
          | hd :: t ->
            Matrix.of_list (chunk t (int_of_float hd)))
      |> Fstream.fold_left ~f:(fun a b -> b :: a) ~init:[]
      |> List.rev
    in
    match matrices with
    | [weights; biases] -> {
        weights;
        biases
      }
    | _ -> failwith "Error with Perceptron_biases file format."
end
