open Ann
open OUnit2

module PLayer = Perceptron.Layer(Differentiable.Sigmoid)
module PNet = Network.Make (PLayer)

let ( @.@ ) = PNet.(@.@)

let suite = "Perceptron Test Suite" >::: [
    "test create" >:: (fun _ ->
        let l = 
          (PLayer.create_layer ~inputs:2 ~outputs:2) in
        assert_equal
          l l 
      );

    "test concat" >:: (fun _ ->
        let l1 = PLayer.create_layer ~inputs:2 ~outputs:2 in
        let l2 = PLayer.create_layer ~inputs:2 ~outputs:2 in 
        assert_equal
          (l1 @.@ PNet.of_layer @@ l2)
          (l1 @.@ PNet.of_layer @@ l2)
      );
  ]


let () =
  run_test_tt_main suite