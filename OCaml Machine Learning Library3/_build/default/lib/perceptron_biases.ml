
module Layer (D : Differentiable.Sig) : Layer.Sig = struct
  type t = {
    weights: Matrix.t;
    biases: Matrix.t
  }

  let create_layer ~inputs ~outputs =
    {
      weights = Matrix.random ~m:outputs ~n:inputs;
      biases = Matrix.random ~m:outputs ~n:1
    }

  let forward_propagate ?(dp=0.5) in_vect t =
    ignore @@ dp;
    Matrix.return
    @@ Matrix.add
         (Matrix.mult t.weights in_vect)
         t.biases
    |> D.apply

  let apply_delta deltas layer =
    {
      weights = Matrix.return @@ Matrix.add deltas.weights layer.weights;
      biases = Matrix.return @@ Matrix.add deltas.biases layer.biases
    }

  let add_derivatives d1 d2 =
    {
      weights = Matrix.return @@ Matrix.add d1.weights d2.weights;
      biases = Matrix.return @@ Matrix.add d1.biases d2.biases;
    }

  let average_derivative layer n =
    {
      weights = Matrix.scalar_mult layer.weights (1. /. n);
      biases = Matrix.scalar_mult layer.biases (1. /. n)
    }

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

  let format fmt t =
    Printf.printf "weights: "; Matrix.format fmt t.weights;
    Printf.printf "biases: "; Matrix.format fmt t.biases

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
