
module Layer (D : Differentiable.Sig) : Layer.Sig = struct
  (** Type of a layer without biases *)
  type t = Matrix.t

  (** [create_layer i o] creates a new layer that takes in [i] inputs and 
      has [o] outputs. *)
  let create_layer ~inputs ~outputs = Matrix.random ~m:outputs ~n:inputs

  (** [forward_propogate d m l] is a matrix representing the output of the layer 
      after being evaluated. The layer [l] is evaluated using data matrix [d] 
      with a dropout percentage of [d]. *)
  let forward_propagate ?(dp=0.0) in_vect t =
    let output = Matrix.mult t in_vect
                 |> D.apply in
    if dp = 0.0 then output
    else Matrix.map (fun a ->
        if (Random.float 1.0) < dp then 0.0 else a) output

  (** [apply_delta d l] applies the changes, deltas [d], from back_propogation
      to the layer [l]. *)
  let apply_delta deltas layer =
    Matrix.return @@ Matrix.add deltas layer

  (** [add_derivatives d1 d2] is the derivative layer representing the sum of 
      the two derivatives *)
  let add_derivatives d1 d2 =
    Matrix.return @@ Matrix.add d1 d2

  (** [average_derivative d n] is the average of the derivative [d] over [n] 
      entries.*)
  let average_derivative layer n =
    Matrix.scalar_mult layer (1. /. n)

  (** [backward_propogate a d l n_l act] is the new layer with deltas that is
      the result of applying the backward_propogation algorithm using learning
      rate [a], a delta [d] representing the differentiable function we are 
      using, the current layer [l], the next_layer [n_l] the was propogated 
      before [l], and the activation function [act]. *)
  let backward_propagate ~learning_rate ~delta ~layer ~next_layer ~activation =
    let delta' =
      Matrix.return @@ match next_layer with
      | None ->
        Matrix.map2 ( *. )
          delta
          (D.derivative (Matrix.mult layer activation))
      | Some next_layer ->
        Matrix.map2 ( *. )
          (Matrix.mult (Matrix.transpose next_layer) delta)
          (D.derivative (Matrix.mult layer activation))
    in
    let partial_deriv = Matrix.mult delta' (Matrix.transpose activation) in
    let deriv' = (Matrix.scalar_mult partial_deriv learning_rate) in
    (delta', deriv')

  (** [format fmt l] prints out [l] to [fmt]. *)
  let format fmt t =
    Matrix.format fmt t

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
    let save_list = (float_of_int (Matrix.width l)) :: (Matrix.to_flat_list l) in
    let new_list = List.map (fun a -> string_of_float a) save_list in
    let ch = open_out name in
    Printf.fprintf ch "%s" (String.concat "," new_list);
    close_out ch

  (** [load s] loads the selected file [s] from a network archive back into a 
      layer. *)
  let load name =
    let float_list =
      Fstream.from_file name |>
      Fstream.map ~f:(fun s -> String.split_on_char ',' s) |>
      Fstream.map ~f:(fun a -> List.map (fun b -> float_of_string b) a) |>
      Fstream.fold_left ~f:(fun a b -> b) ~init:[] in
    match float_list with
    | [] -> failwith "Perceptron.load called on empty file"
    | h::t ->
      let chunked_list = chunk t (int_of_float h) in
      Matrix.of_list chunked_list

end
