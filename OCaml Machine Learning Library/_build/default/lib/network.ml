
module Make (L : Layer.Sig) = struct
  (** Type of the network *)
  type t = L.t list

  (** Type of data, A list of matricies. Each matrix represents a layer and 
      each value in the matrix represents the input to that node in that layer *)
  type data = (Matrix.t * Matrix.t)

  (** Type of gradient descent data training technique *)
  type gradient_descent = Stochastic | Batch | MiniBatch of int

  (** [compose l n] combines layer [l] and network [n] *)
  let compose layer network = layer :: network

  (** [l @.@ n] combines layer [l] and network [n] *)
  let ( @.@ ) = compose

  (** [of_layer l] is the network with the single layer [l]. *)
  let of_layer layer = [layer]

  (** [forward_propogate dp iv n] propogates the input vector [iv] through the 
      network [n] whose perceptron layers have drop out percentage [dp]. *)
  let forward_propagate ?(dropout=0.0) input_vec network =
    List.fold_left
      (fun (in_vec, act) layer ->
         let output = L.forward_propagate ~dp:dropout in_vec layer in
         (output, in_vec::act))
      (input_vec,[])
      network

  (** [back_propogate lr n l act] backward_propogates the deltas of the loss
      function's loss vector [l] through the network [n] using activation 
      function [act] with learning rate [lr]. *)
  let back_propagate lr network loss_v act =
    let assoc_l = List.combine (List.rev network) act in
    let (_, deriv_lst, _) = List.fold_left
        (fun (delta, derivs, next_layer) (layer, activation) ->
           let (delta', deriv) =
             L.backward_propagate ~learning_rate:lr ~delta ~layer ~next_layer ~activation
           in
           (delta', deriv :: derivs, Some layer))
        (loss_v, [], None)
        assoc_l
    in
    deriv_lst

  (** [apply_derivs n dl] applies the list of derivatives [dl] to the network
      [n]. *)
  let apply_derivs network deriv_lst =
    List.map2 (fun layer d -> L.apply_delta layer d) network deriv_lst

  (** [classify m] classifies an output matrix either one or zero. *)
  let classify m =
    let (_, n, _) = Matrix.fold_left (fun (max, n, i) x ->
        if x > max then (x, i, i+1)
        else (max, n, i+1))
        (0., 0, 0)
        m
    in
    n

  (** [clear_line ()] clears a line as it prints to standard output. *)
  let clear_line () =
    Printf.printf "%c[2K" '\027'

  (** [evaluate m n] is the result of running [m] through the network [n]. *)
  let evaluate m network = fst @@ forward_propagate m network

  (** [eval_all eo n d] is the number of correct evaluations over the number of 
      total test cases equalling the accuracy of the model itself. [eval_all] 
      evaluates the network [n] using all supplied test data cases in [d]. *)
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

  (** [format fmt t] prints out [t] to [fmt]. *)
  let format fmt t =
    List.iter
      (fun x ->
         L.format fmt x;
         Format.fprintf fmt " -> ";)
      t;
    Format.fprintf fmt "DONE \n"

  (** [chunk l s] a helper function for minibatching that creates a list of lists
      where the inner lists are of size [s] from a given list [l]. *)
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

  (** [print t] prints out [t] to [stdout]. *)
  let print = format (Format.std_formatter)

  (** [shuffle n] shuffles a list [n] in random order. *)
  let shuffle n =
    let tagged_list = List.map(fun x -> (x, Random.bits ())) n in
    let sorted_tagged_list =
      List.sort (fun (_,a) (_,b) -> Pervasives.compare a b) tagged_list in
    List.map (fun (a,_) -> a) sorted_tagged_list

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
  let train 
      ?(epsilon=(0.0001)) 
      ?(learning=(0.01))
      ?(max_epoch=None) 
      ?(gradient_type=Stochastic)
      ?(dropout=0.0)
      ?(output_file=None)
      ~loss
      ~loss_deriv
      network 
      all_data 
    =
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

    (** [stochastic n d e] trains the given network [n] using stochastic 
        batches which uses the entirety of the data [d] set as a training set in 
        every epoch [e], consisting of one forward and one backward propogation 
        step. *)
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
    in

    (** [batch n d c e] trains the given network [n] using the batching 
        technique, where data [d] is split up into chunks of size [c] and every
        epoch [e] the network is trained using only the data in a specific chunk.
        These batches of size chunk_size are normalized to make sure each 
        batch is representative of the data set as best as possible. *)
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

  (** [save t name] creates a directory where each csv file is the representation of
      a layer of t *)
  let save net name =
    let files =
      List.mapi (fun i layer ->
          let file_name = "layer_" ^ (string_of_int i) in
          L.save file_name layer;
          file_name)
        net
    in
    Archive.create ~name:(name ^ ".ann") files

  (** [load dir] creates the network represented by the directory dir based on the layer 
      conversion function f *)
  let load dir =
    Archive.read dir ~f:(fun fn ->
        Printf.printf "f: %s\n" fn;
        L.load fn)
end

