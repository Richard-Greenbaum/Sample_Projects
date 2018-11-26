open OUnit2
(* open Ann *)

let matrix = [1; 1]




let suite1 = "Propagation test suite" >::: [
    "test " >:: (fun _ ->
        assert_equal
          (true)
          (true)
      );


  ]

let () =
  run_test_tt_main suite1
