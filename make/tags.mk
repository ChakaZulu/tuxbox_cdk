TAGS: Makefile.am $(shell echo make/*.mk)
	etags --language=makefile $^

tags: Makefile.am $(shell echo make/*.mk)
	gnuctags --language=makefile $^
