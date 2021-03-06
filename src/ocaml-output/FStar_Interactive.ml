
open Prims

type ('env, 'modul) interactive_tc =
{pop : 'env  ->  Prims.string  ->  Prims.unit; push : 'env  ->  Prims.string  ->  'env; mark : 'env  ->  'env; reset_mark : 'env  ->  'env; commit_mark : 'env  ->  'env; check_frag : 'env  ->  'modul  ->  Prims.string  ->  ('modul * 'env * Prims.int) Prims.option; report_fail : Prims.unit  ->  Prims.unit}


let is_Mkinteractive_tc = (Obj.magic ((fun _ -> (FStar_All.failwith "Not yet implemented:is_Mkinteractive_tc"))))


type input_chunks =
| Push of Prims.string
| Pop of Prims.string
| Code of (Prims.string * (Prims.string * Prims.string))


let is_Push = (fun _discr_ -> (match (_discr_) with
| Push (_) -> begin
true
end
| _ -> begin
false
end))


let is_Pop = (fun _discr_ -> (match (_discr_) with
| Pop (_) -> begin
true
end
| _ -> begin
false
end))


let is_Code = (fun _discr_ -> (match (_discr_) with
| Code (_) -> begin
true
end
| _ -> begin
false
end))


let ___Push____0 = (fun projectee -> (match (projectee) with
| Push (_90_13) -> begin
_90_13
end))


let ___Pop____0 = (fun projectee -> (match (projectee) with
| Pop (_90_16) -> begin
_90_16
end))


let ___Code____0 = (fun projectee -> (match (projectee) with
| Code (_90_19) -> begin
_90_19
end))


type ('env, 'modul) stack =
('env * 'modul) Prims.list


type interactive_state =
{chunk : FStar_Util.string_builder; stdin : FStar_Util.stream_reader Prims.option FStar_ST.ref; buffer : input_chunks Prims.list FStar_ST.ref; log : FStar_Util.file_handle Prims.option FStar_ST.ref}


let is_Mkinteractive_state : interactive_state  ->  Prims.bool = (Obj.magic ((fun _ -> (FStar_All.failwith "Not yet implemented:is_Mkinteractive_state"))))


let the_interactive_state : interactive_state = (let _184_149 = (FStar_Util.new_string_builder ())
in (let _184_148 = (FStar_ST.alloc None)
in (let _184_147 = (FStar_ST.alloc [])
in (let _184_146 = (FStar_ST.alloc None)
in {chunk = _184_149; stdin = _184_148; buffer = _184_147; log = _184_146}))))


let rec read_chunk : Prims.unit  ->  input_chunks = (fun _90_27 -> (match (()) with
| () -> begin
(

let s = the_interactive_state
in (

let log = if (FStar_Options.debug_any ()) then begin
(

let transcript = (match ((FStar_ST.read s.log)) with
| Some (transcript) -> begin
transcript
end
| None -> begin
(

let transcript = (FStar_Util.open_file_for_writing "transcript")
in (

let _90_33 = (FStar_ST.op_Colon_Equals s.log (Some (transcript)))
in transcript))
end)
in (fun line -> (

let _90_37 = (FStar_Util.append_to_file transcript line)
in (FStar_Util.flush_file transcript))))
end else begin
(fun _90_39 -> ())
end
in (

let stdin = (match ((FStar_ST.read s.stdin)) with
| Some (i) -> begin
i
end
| None -> begin
(

let i = (FStar_Util.open_stdin ())
in (

let _90_46 = (FStar_ST.op_Colon_Equals s.stdin (Some (i)))
in i))
end)
in (

let line = (match ((FStar_Util.read_line stdin)) with
| None -> begin
(FStar_All.exit (Prims.parse_int "0"))
end
| Some (l) -> begin
l
end)
in (

let _90_53 = (log line)
in (

let l = (FStar_Util.trim_string line)
in if (FStar_Util.starts_with l "#end") then begin
(

let responses = (match ((FStar_Util.split l " ")) with
| (_90_59)::(ok)::(fail)::[] -> begin
((ok), (fail))
end
| _90_62 -> begin
(("ok"), ("fail"))
end)
in (

let str = (FStar_Util.string_of_string_builder s.chunk)
in (

let _90_65 = (FStar_Util.clear_string_builder s.chunk)
in Code (((str), (responses))))))
end else begin
if (FStar_Util.starts_with l "#pop") then begin
(

let _90_67 = (FStar_Util.clear_string_builder s.chunk)
in Pop (l))
end else begin
if (FStar_Util.starts_with l "#push") then begin
(

let _90_69 = (FStar_Util.clear_string_builder s.chunk)
in Push (l))
end else begin
if (l = "#finish") then begin
(FStar_All.exit (Prims.parse_int "0"))
end else begin
(

let _90_71 = (FStar_Util.string_builder_append s.chunk line)
in (

let _90_73 = (FStar_Util.string_builder_append s.chunk "\n")
in (read_chunk ())))
end
end
end
end))))))
end))


let shift_chunk : Prims.unit  ->  input_chunks = (fun _90_75 -> (match (()) with
| () -> begin
(

let s = the_interactive_state
in (match ((FStar_ST.read s.buffer)) with
| [] -> begin
(read_chunk ())
end
| (chunk)::chunks -> begin
(

let _90_81 = (FStar_ST.op_Colon_Equals s.buffer chunks)
in chunk)
end))
end))


let fill_buffer : Prims.unit  ->  Prims.unit = (fun _90_83 -> (match (()) with
| () -> begin
(

let s = the_interactive_state
in (let _184_164 = (let _184_163 = (FStar_ST.read s.buffer)
in (let _184_162 = (let _184_161 = (read_chunk ())
in (_184_161)::[])
in (FStar_List.append _184_163 _184_162)))
in (FStar_ST.op_Colon_Equals s.buffer _184_164)))
end))


exception Found of (Prims.string)


let is_Found = (fun _discr_ -> (match (_discr_) with
| Found (_) -> begin
true
end
| _ -> begin
false
end))


let ___Found____0 = (fun projectee -> (match (projectee) with
| Found (_90_86) -> begin
_90_86
end))


let find_initial_module_name : Prims.unit  ->  Prims.string Prims.option = (fun _90_87 -> (match (()) with
| () -> begin
(

let _90_88 = (fill_buffer ())
in (

let _90_90 = (fill_buffer ())
in try
(match (()) with
| () -> begin
(

let _90_114 = (match ((FStar_ST.read the_interactive_state.buffer)) with
| (Push (_90_105))::(Code (code, _90_101))::[] -> begin
(

let lines = (FStar_Util.split code "\n")
in (FStar_List.iter (fun line -> (

let line = (FStar_Util.trim_string line)
in if (((FStar_String.length line) > (Prims.parse_int "7")) && ((FStar_Util.substring line (Prims.parse_int "0") (Prims.parse_int "6")) = "module")) then begin
(

let module_name = (FStar_Util.substring line (Prims.parse_int "7") ((FStar_String.length line) - (Prims.parse_int "7")))
in (Prims.raise (Found (module_name))))
end else begin
()
end)) lines))
end
| _90_113 -> begin
()
end)
in None)
end)
with
| Found (n) -> begin
Some (n)
end))
end))


let detect_dependencies_with_first_interactive_chunk : Prims.unit  ->  (Prims.string * Prims.string Prims.list) = (fun _90_116 -> (match (()) with
| () -> begin
(

let failr = (fun msg r -> (

let _90_120 = if (FStar_Options.universes ()) then begin
(FStar_TypeChecker_Errors.warn r msg)
end else begin
(FStar_Tc_Errors.warn r msg)
end
in (FStar_All.exit (Prims.parse_int "1"))))
in (

let fail = (fun msg -> (failr msg FStar_Range.dummyRange))
in (

let parse_msg = "Dependency analysis may not be correct because the file failed to parse: "
in try
(match (()) with
| () -> begin
(match ((find_initial_module_name ())) with
| None -> begin
(fail "No initial module directive found\n")
end
| Some (module_name) -> begin
(

let file_of_module_name = (FStar_Parser_Dep.build_map [])
in (

let filename = (FStar_Util.smap_try_find file_of_module_name (FStar_String.lowercase module_name))
in (match (filename) with
| None -> begin
(let _184_184 = (FStar_Util.format2 "I found a \"module %s\" directive, but there is no %s.fst\n" module_name module_name)
in (fail _184_184))
end
| (Some (None, Some (filename))) | (Some (Some (filename), None)) -> begin
(

let _90_154 = (FStar_Options.add_verify_module module_name)
in (

let _90_161 = (FStar_Parser_Dep.collect FStar_Parser_Dep.VerifyUserList ((filename)::[]))
in (match (_90_161) with
| (_90_157, all_filenames, _90_160) -> begin
(let _184_186 = (let _184_185 = (FStar_List.tl all_filenames)
in (FStar_List.rev _184_185))
in ((filename), (_184_186)))
end)))
end
| Some (Some (_90_163), Some (_90_166)) -> begin
(let _184_187 = (FStar_Util.format1 "The combination of split interfaces and interactive verification is not supported for: %s\n" module_name)
in (fail _184_187))
end
| Some (None, None) -> begin
(FStar_All.failwith "impossible")
end)))
end)
end)
with
| (FStar_Syntax_Syntax.Error (msg, r)) | (FStar_Absyn_Syntax.Error (msg, r)) -> begin
(failr (Prims.strcat parse_msg msg) r)
end
| (FStar_Syntax_Syntax.Err (msg)) | (FStar_Absyn_Syntax.Err (msg)) -> begin
(fail (Prims.strcat parse_msg msg))
end)))
end))


let interactive_mode = (fun filename env initial_mod tc -> (

let _90_180 = if (let _184_193 = (FStar_Options.codegen ())
in (FStar_Option.isSome _184_193)) then begin
(FStar_Util.print_warning "code-generation is not supported in interactive mode, ignoring the codegen flag")
end else begin
()
end
in (

let rec go = (fun stack curmod env -> (match ((shift_chunk ())) with
| Pop (msg) -> begin
(

let _90_188 = (tc.pop env msg)
in (

let _90_200 = (match (stack) with
| [] -> begin
(

let _90_191 = (FStar_Util.print_error "too many pops")
in (FStar_All.exit (Prims.parse_int "1")))
end
| (hd)::tl -> begin
((hd), (tl))
end)
in (match (_90_200) with
| ((env, curmod), stack) -> begin
(go stack curmod env)
end)))
end
| Push (msg) -> begin
(

let stack = (((env), (curmod)))::stack
in (

let env = (tc.push env msg)
in (go stack curmod env)))
end
| Code (text, (ok, fail)) -> begin
(

let fail = (fun curmod env_mark -> (

let _90_214 = (tc.report_fail ())
in (

let _90_216 = (FStar_Util.print1 "%s\n" fail)
in (

let env = (tc.reset_mark env_mark)
in (go stack curmod env)))))
in (

let env_mark = (tc.mark env)
in (

let res = (tc.check_frag env_mark curmod text)
in (match (res) with
| Some (curmod, env, n_errs) -> begin
if (n_errs = (Prims.parse_int "0")) then begin
(

let _90_226 = (FStar_Util.print1 "\n%s\n" ok)
in (

let env = (tc.commit_mark env)
in (go stack curmod env)))
end else begin
(fail curmod env_mark)
end
end
| _90_230 -> begin
(fail curmod env_mark)
end))))
end))
in if (((FStar_Options.universes ()) && ((FStar_Options.record_hints ()) || (FStar_Options.use_hints ()))) && (FStar_Option.isSome filename)) then begin
(let _184_205 = (FStar_Option.get filename)
in (FStar_SMTEncoding_Solver.with_hints_db _184_205 (fun _90_231 -> (match (()) with
| () -> begin
(go [] initial_mod env)
end))))
end else begin
(go [] initial_mod env)
end)))




