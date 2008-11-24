SROOT ?= .
NITROGEN_SRC ?= ~/Devel/nitrogen/

%.beam : %.erl ; ${ERLC} $<
vpath %.beam ${SROOT}/ebin/
vpath %.erl  ${SROOT}/src/

FILES = $(shell echo ${SROOT}/src/*.erl)
MODULES = $(notdir $(basename ${FILES}))
ERLC = erlc \
	+debug_info \
        -o ${SROOT}/ebin \
        -I ${SROOT}/include \
        -I ${NITROGEN_SRC}/include

compile: $(notdir ${FILES:.erl=.beam})

clean:
	rm -rf ${SROOT}/ebin/*.*

