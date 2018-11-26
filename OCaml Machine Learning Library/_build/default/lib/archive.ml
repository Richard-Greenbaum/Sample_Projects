
open Printf

type filename = string
exception File_not_found of string

let file_not_found fn =
  raise @@ File_not_found (sprintf "Cannot access '%s': No such file or directory." fn)

let create ~name ?(destructive=true) files =
  (* make sure all files exist *)
  List.iter (fun fn ->
      if not (Sys.file_exists fn) then file_not_found fn)
    files;

  ignore @@ Sys.command (sprintf "tar -czf %s %s" name (String.concat " " files));
  if destructive then
    List.iter Sys.remove files

let read name ~f =
  let tmp_fn = ".#ocaml_archive_log_tmp" in
  if not (Sys.file_exists name) then file_not_found name;
  ignore @@ Sys.command (sprintf "tar -xvf %s > %s" name tmp_fn);
  Fstream.from_file tmp_fn
  |> Fstream.fold_left
    ~f:(fun acc e -> e :: acc)
    ~init:[]
  |> List.rev
  |> List.map (fun fn ->
      let r = f fn in
      Sys.remove fn;
      r)
