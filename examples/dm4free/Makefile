FSTAR_HOME=../..
OTHERFLAGS=
include ../Makefile.include

all: uall
uall: Effects.Def.uver FStar.DM4F.IntST.uver-explicit FStar.DM4F.Exceptions.uver-explicit FStar.DM4F.ExnSt.uver FStar.DM4F.StExn.uver-explicit FStar.DM4F.ST.uver-explicit FStar.DM4F.Heap.uver FStar.DM4F.Heap.ST.uver #old
sall:

# we retain these "hand-written" versions just for reference
old: intST.uver Exceptions.uver-explicit ExceptionsWithState.uver StExn.uver-explicit StExn.Handle.uver-explicit

ulib-cmxa:
	$(MAKE) -C ../../ulib/ml

%.uver-explicit: %.fst
	$(FSTAR) $^ --explicit_deps

%.uver: %.fst
	$(FSTAR) $^

include $(FSTAR_HOME)/ulib/ml/Makefile.include

# This target is very concise and re-uses the variables defined in
# Makefile.include. You shouldn't need to call `cp` ever.
intST.exe: ulib-cmxa out intST.fst
	$(FSTAR) $(FSTAR_DEFAULT_ARGS) --odir out --codegen OCaml intST.fst
	$(OCAMLOPT) -I out out/IntST.ml -o out/IntST.exe
	./out/IntST.exe

ulib:
	$(MAKE) -C $(ULIB_ML)

clean:
	rm -rf out

out:
	mkdir -p out
