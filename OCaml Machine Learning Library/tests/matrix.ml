open OUnit2
open Ann

let suite = "ANN test suite" >::: [
    "test test" >:: (fun _ ->
        assert_equal
          (Matrix.zeros ~m:10 ~n:10)
          (Matrix.zeros ~m:10 ~n:10)
      );

    "test test 1" >:: (fun _ ->
        assert_equal
          (Matrix.ones ~m:10 ~n:10)
          (Matrix.ones ~m:10 ~n:10)
      );

    "test set 1" >:: (fun _ -> 
        let nm = Matrix.zeros ~m:1 ~n:1 in
        let a = match (Matrix.set nm 1.0 ~i:0 ~j:0) with 
          | Some x -> x
          | None -> failwith "None" in
        assert_equal
          (Matrix.ones ~m:1 ~n:1)
          a 
      );

    "test height 1" >:: (fun _ -> 
        assert_equal
          (Matrix.height (Matrix.ones ~m:5 ~n:10))
          (Matrix.height (Matrix.zeros ~m:5 ~n:5)) 
      );

    "test width 1" >:: (fun _ -> 
        assert_equal
          (Matrix.width (Matrix.ones ~m:10 ~n:5))
          (Matrix.width (Matrix.zeros ~m:5 ~n:5)) 
      );

    "test size equals 1" >:: (fun _ ->
        let s1 = 
          (Matrix.size_equals (Matrix.ones ~m:5 ~n:5) (Matrix.zeros ~m:5 ~n:5)) in
        assert
          s1
      );

    "test add 1" >:: (fun _ -> 
        let m1 = 
          match (Matrix.add (Matrix.ones ~m:10 ~n:5)(Matrix.ones ~m:10 ~n:5)) with
          | Some x -> x
          | None -> failwith "Invalid"
        in
        assert_equal
          (Matrix.mat_values ~m:10 ~n:5 ~v:2.0)
          m1 
      );

    "test sub 1" >:: (fun _ -> 
        let m1 = 
          match (Matrix.sub (Matrix.mat_values ~m:10 ~n:5 ~v:2.0)(Matrix.ones ~m:10 ~n:5)) with
          | Some x -> x
          | None -> failwith "Invalid"
        in
        assert_equal
          (Matrix.mat_values ~m:10 ~n:5 ~v:1.0)
          m1 
      );

    "test mult 1" >:: (fun _ -> 
        let m1 = Matrix.mat_values ~m:1 ~n:2 ~v:2.0 in  
        let m2 = Matrix.mat_values ~m:2 ~n:1 ~v:1.0 in
        let res = Matrix.mat_values ~m:1 ~n:1 ~v:4.0 in
        assert_equal
          (Matrix.mult m1 m2)
          res
      );

    "test scalar_mult 1" >:: (fun _ -> 
        let m1 = Matrix.mat_values ~m:4 ~n:4 ~v:2.0 in  
        let res = Matrix.mat_values ~m:4 ~n:4 ~v:4.0 in
        assert_equal
          (Matrix.scalar_mult m1 2.0)
          res
      );






  ]

let () =
  run_test_tt_main suite
