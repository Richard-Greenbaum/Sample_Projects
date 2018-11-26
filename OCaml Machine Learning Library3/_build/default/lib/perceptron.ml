
module Layer (D : Differentiable.Sig) : Layer.Sig = struct
  type t = Matrix.t

  let create_layer ~inputs ~outputs = Matrix.random ~m:outputs ~n:inputs

  let forward_propagate ?(dp=0.0) in_vect t =
    let output = Matrix.mult t in_vect
    |> D.apply in
    if dp = 0.0 then output
    else Matrix.map (fun a ->
      if (Random.float 1.0) < dp then 0.0 else a) output


  (* let backprop_output_layer ouput_l w delta =
   *   let error = Matrix.map2 ( *. )
   *       (Matrix.map (D.derivative ()) output_l)
   *       delta
   *   in *)

  let apply_delta deltas layer =
    Matrix.return @@ Matrix.add deltas layer

  let add_derivatives d1 d2 =
    Matrix.return @@ Matrix.add d1 d2

  let average_derivative layer n =
    Matrix.scalar_mult layer (1. /. n)

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


  let format fmt t =
    Matrix.format fmt t

  let print = format Format.std_formatter
        (* let delta' = Matrix.map2 ( *. )
     *     (Matrix.map (D.derivative ()) input)
     *     (Matrix.mult (Matrix.transpose w) (delta))
     * in
     * let gradient_dir = Matrix.mult w delta in
     * Matrix.format (Format.std_formatter) w;
     * Matrix.format (Format.std_formatter) gradient_dir;
     * Printf.printf "\n";
     * match Matrix.sub w (Matrix.scalar_mult gradient_dir ep) with
     * | None -> failwith "Back-prop fail"
     * | Some x -> (delta', x) *)

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

  let save name l =
    let save_list = (float_of_int (Matrix.width l)) :: (Matrix.to_flat_list l) in
    let new_list = List.map (fun a -> string_of_float a) save_list in
    let ch = open_out name in
    Printf.fprintf ch "%s" (String.concat "," new_list);
    close_out ch

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
