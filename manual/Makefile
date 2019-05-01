NULL :=
DEPS := \
    luatex-titlepage.tex \
    luatex-firstpage.tex \
    luatex-export-titlepage.tex \
    luatex-contents.tex \
    luatex-introduction.tex \
    luatex-preamble.tex \
    luatex-enhancements.tex \
    luatex-modifications.tex \
    luatex-lua.tex \
    luatex-languages.tex \
    luatex-fonts.tex \
    luatex-math.tex \
    luatex-nodes.tex \
    luatex-callbacks.tex \
    luatex-tex.tex \
    luatex-graphics.tex \
    luatex-fontloader.tex \
    luatex-backend.tex \
    luatex-registers.tex \
    luatex-statistics.tex \
    $(NULL)

luatex.pdf: luatex.tex $(DEPS)
	context $<
	mutool clean -a -d $@ $@
