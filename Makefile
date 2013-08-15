EBIN_DIR = ebin
EBIN_DIRS = $(EBIN_DIR) $(wildcard deps/*/ebin) $(wildcard apps/*/ebin)

EPA=-pa $(shell echo $(EBIN_DIRS) | sed 's/ / -pa /')

ERL=erl $(EPA) -boot start_sasl -sasl errlog_type error

REBAR=./rebar


all: compile

shell: compile
	$(ERL)

mmd: compile
	./scontrol -e dev debug

compile:
	$(REBAR) compile

.PHONY: deps test

deps:
	$(REBAR) get-deps
	$(REBAR) update-deps
	test -f scontrol || ln -s deps/p6core/priv/bin/scontrol

test: compile
	$(REBAR) eunit

xref: compile
	./rebar xref

doc: compile
	./rebar skip_deps=true doc

clean:
	./rebar clean
	rm -rf release
	find . -name '*~' -exec rm {} \;
	find . -name erl_crash.dump -exec rm {} \;

