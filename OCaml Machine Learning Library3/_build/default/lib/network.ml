
module Make (L : Layer.Sig) = struct
  type t = L.t list

  (*A list of matricies. Each matrix represents a layer and each value in the matrix represents
    the input to that node in that layer*)

  type data = (Matrix.t * Matrix.t)

  type gradient_descent = Stochastic | Batch | MiniBatch of int

  let compose layer network = layer :: network

  let ( @.@ ) = compose

  let of_layer layer = [layer]

  let forward_propagate ?(dropout=0.0) input_vec network =
    List.fold_left
      (fun (in_vec, act) layer ->
         let output = L.forward_propagate ~dp:dropout in_vec layer in
         (output, in_vec::act))
      (input_vec,[])
      network

  (*Back propagates a loss vector through a network and returns the new network*)
  let back_propagate lr network loss_v act =
    let assoc_l = List.combine (List.rev network) act in
    (* List.iteri (fun i (a, b) -> (
     *       Printf.printf "\nLayer: %d\n" i;
     *       L.format (Format.std_formatter) a;
     *       Matrix.print b; Printf.printf "\n"))
     *   assoc_l; *)

    let (_, deriv_lst, _) = List.fold_left
        (fun (delta, derivs, next_layer) (layer, activation) ->
           let (delta', deriv) =
             L.backward_propagate ~learning_rate:lr ~delta ~layer ~next_layer ~activation
           in
           (delta', deriv :: derivs, Some layer))
           (* (delta', (L.apply_delta derivs' layer) :: net', Some layer)) *)
        (loss_v, [], None)
        assoc_l
    in
    deriv_lst

  let apply_derivs network deriv_lst =
    List.map2 (fun layer d -> L.apply_delta layer d) network deriv_lst

  let classify m =
    let (_, n, _) = Matrix.fold_left (fun (max, n, i) x ->
        if x > max then (x, i, i+1)
        else (max, n, i+1))
        (0., 0, 0)
        m
    in
    n

  let clear_line () =
    Printf.printf "%c[2K" '\027'

  let evaluate m network = fst @@ forward_propagate m network

  let eval_all ?(expand_output=false) network (features, labels) =
    let data = (List.combine (Matrix.to_row_list features) (Matrix.to_row_list labels)) in
    let total_count = List.length data in
    let rec help count data =
      match data with
      | [] -> count
      | (x, y) :: tl ->
        (let (guess, correct) = (classify @@ evaluate x network, classify y) in
         if guess = correct then
           (if expand_output then
              Printf.printf " [o] - %d/%d -> %d == %d\n" (count+1) total_count guess correct
            else
              (clear_line (); Printf.printf "\r [o] - %d/%d%!" (count+1) total_count);
            help (count+1) tl)
         else
           (if expand_output then
              Printf.printf " [x] - %d/%d -> %d != %d\n" count total_count guess correct
            else
              (clear_line (); Printf.printf "\r [x] - %d/%d%!" count total_count);
               help (count) tl))
    in
    let n_correct = help 0 data in
    Printf.printf "\n";
    (float_of_int n_correct) /. (float_of_int @@ List.length data)

  let format fmt t =
    List.iter
      (fun x ->
         L.format fmt x;
         Format.fprintf fmt " -> ";)
      t;
    Format.fprintf fmt "DONE \n"

  (* let sum (deltas: Matrix.t list) (network: t) : t =
   *   List.map2 (fun d l -> L.apply_delta d l) deltas network *)

  let chunk lst chunk_size =
    let (_, result) =
      List.fold_left
        (fun (c, acc) e ->
           if c < chunk_size then
             match acc with
             | [] -> (c+1, [[e]])
             | hd :: tl -> (c+1, (e :: hd) :: tl)
           else
             (0, [] :: acc))
        (0, [])
        lst
    in
    result

  let print = format (Format.std_formatter)

  let shuffle n =
    let tagged_list = List.map(fun x -> (x, Random.bits ())) n in
    let sorted_tagged_list =
      List.sort (fun (_,a) (_,b) -> Pervasives.compare a b) tagged_list in
    List.map (fun (a,_) -> a) sorted_tagged_list

  let train ?(epsilon=(0.0001)) ?(learning=(0.01))
      ?(max_epoch=None) ?(gradient_type=Stochastic)
      ?(dropout=0.0)
      ?(output_file=None)
      ~loss
      ~loss_deriv
      network all_data =
    let loss_func = loss in
    let loss_func_deriv = loss_deriv in
    Printf.printf "Starting training...\n%!";
    let (input_v, truth) = all_data in
    let all_data =
      List.combine
        (Matrix.to_row_list input_v)
        (Matrix.to_row_list truth)
    in
    let commit_data lst =
      match output_file with
      | None -> ()
      | Some fn -> Fstream.append_to_file fn ~f:(fun ch ->
          Printf.fprintf ch "%s\n" (String.concat "," lst))
    in
    ignore @@ (match output_file with
        | None -> ()
        | Some fn ->
          if Sys.file_exists fn then
            Sys.remove fn);

    let rec stocastic network data epoch =
      try (match max_epoch with
          | Some x when epoch >= x -> Printf.printf "\nReached max epoch\n"; network
          | _ ->
            let (network', tot_loss) =
              (List.fold_left
                 (fun (net, acc_loss) (feature, expected) ->
                    let (actual, acts) = forward_propagate ~dropout feature network in
                    let cost = loss_func actual expected in
                    let acc_loss = acc_loss +. cost in
                    let loss_v = (loss_func_deriv actual expected) in
                    let net' =
                      apply_derivs (back_propagate learning network loss_v acts) net
                    in
                    (net', acc_loss))
                 (network, 0.)
                 data)
            in
            let loss = tot_loss /. (float_of_int @@ List.length data) in
            (* let loss = tot_loss in *)
            clear_line (); Printf.printf "\rloss: %f epoch: %d%!" loss epoch;
            commit_data [(string_of_int epoch); (string_of_float loss)];
            (if loss > epsilon then
                stocastic network' (shuffle data) (epoch+1)
              else
                network'))
      with Sys.Break -> network
      (* try
       *   (match max_epoch with
       *    | Some x when epoch >= x -> Printf.printf "\nReached max epoch\n"; network
       *    | _ ->
       *      (match data with
       *       | [] ->
       *         let tot = (List.fold_left
       *                      (fun sum (input, truth) ->
       *                         let (actual, _) = forward_propagate input network in
       *                         sum +. Matrix.norm (loss_func actual truth))
       *                      0.
       *                      all_data)
       *         in
       *         let loss = tot /. (float_of_int @@ List.length all_data) in
       *         clear_line (); Printf.printf "\rloss: %f epoch: %d%!" loss epoch;
       *         commit_data [string_of_int epoch; string_of_float loss];
       *         if loss > epsilon then
       *           stocastic network all_data (epoch+1)
       *         else
       *           network
       *       | (feature, expected) :: tl ->
       *         (let (actual, acts) = forward_propagate feature network in
       *          let loss_v = loss_func actual expected in
       *          let net' = apply_derivs (back_propagate learning network loss_v acts) network in
       *          stocastic net' tl epoch)))
       * with Sys.Break -> network *)
    in

    let rec batch network data chunk_size epoch =
      try
        (match max_epoch with
         | Some x when epoch >= x -> Printf.printf "\nReached max epoch\n"; network
         | _ ->
           let help data =
             (List.fold_left
                (fun (acc_deriv, tot_loss) (feature, expected) ->
                   let (actual, acts) = forward_propagate ~dropout feature network in
                   let cost = loss_func actual expected in
                   let loss_v = loss_func_deriv actual expected in
                   let derivs = back_propagate learning network loss_v acts in
                   (* add this derivative to the acculated derivative *)
                   let tot_loss = tot_loss +. cost in
                   let acc_deriv = match acc_deriv with
                     | None -> derivs
                     | Some acc_deriv ->
                       (List.map2 L.add_derivatives acc_deriv derivs)
                   in
                   (Some acc_deriv, tot_loss))
                (None, 0.)
                data)
           in
           let (network, loss) = List.fold_left
               (fun (network, acc_loss) data_batch ->
                  match help data_batch with
                  | Some total_deriv, total_loss ->
                    (let deriv = List.map
                         (fun l -> L.average_derivative l (float_of_int chunk_size))
                         total_deriv
                     in
                     let network' = apply_derivs deriv network in
                     (network', acc_loss +. (total_loss /. (float_of_int chunk_size))))
                  | _ -> failwith "[batch] somehow dimensions where mismatched.")
               (network, 0.)
               (chunk (shuffle data) chunk_size)
           in
           let loss = loss  /. (float_of_int (List.length data / chunk_size)) in
           (clear_line (); Printf.printf "\rloss: %f epoch: %d%!" loss epoch;
            commit_data [string_of_int epoch; string_of_float loss];
            if loss > epsilon then
              (
                (* ignore @@ read_line (); *)
                batch network data chunk_size (epoch+1)
              )
            else
              network))
      with Sys.Break -> network
    in
    Sys.set_signal (Sys.sigint)
      (Sys.Signal_handle (fun _ -> raise Sys.Break));
    let net =
      match gradient_type with
      | Stochastic -> stocastic network all_data 0
      | Batch -> batch network all_data (List.length all_data) 0
      | MiniBatch n -> batch network all_data n 0
    in
    Printf.printf "\nDone\n";
    net

  let save net name =
    let files =
      List.mapi (fun i layer ->
          let file_name = "layer_" ^ (string_of_int i) in
          L.save file_name layer;
          file_name)
        net
    in
    Archive.create ~name:(name ^ ".ann") files

  let load dir =
    Archive.read dir ~f:(fun fn ->
        Printf.printf "f: %s\n" fn;
        L.load fn)
end

