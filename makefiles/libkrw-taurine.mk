ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

ifeq (,$(findstring darwin,$(MEMO_TARGET)))
ifeq ($(shell [ "$(MEMO_CFVER)" -ge 1700 ] && [ "$(MEMO_CFVER)" -lt 1800 ] && echo 1),1)

SUBPROJECTS   += libkrw-taurine
LIBKRW_TAURINE_VERSION := 1.0
DEB_LIBKRW_TAURINE_V   ?= $(LIBKRW_TAURINE_VERSION)
LIBKRW_TAURINE_COMMIT  := 179a7bc2a05f4a03bf15ee1489ce1bc16cc1697f

libkrw-taurine-setup: setup
	$(call GITHUB_ARCHIVE,R00tFS,libkrw-taurine,$(LIBKRW_TAURINE_COMMIT),$(LIBKRW_TAURINE_COMMIT),libkrw-taurine)
	$(call EXTRACT_TAR,libkrw-taurine-$(LIBKRW_TAURINE_COMMIT).tar.gz,libkrw-taurine-$(LIBKRW_TAURINE_COMMIT),libkrw-taurine)

ifneq ($(wildcard $(BUILD_WORK)/libkrw-taurine/.build_complete),)
libkrw-taurine:
	@echo "Using previously built libkrw-taurine."
else
libkrw-taurine: libkrw-taurine-setup
	mkdir -p $(BUILD_STAGE)/libkrw-taurine/$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libkrw
	$(CC) $(CFLAGS) -fobjc-arc -dynamiclib \
		-I$(BUILD_WORK)/libkrw-taurine/include/ \
		-install_name "$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libkrw/libkrw-taurine.dylib" \
		-o $(BUILD_STAGE)/libkrw-taurine$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libkrw/libkrw$(LIBKRW_SOVERSION)-taurine.dylib \
		$(wildcard $(BUILD_WORK)/libkrw-taurine/src/*.c $(BUILD_WORK)/libkrw-taurine/src/libkernrw/*.c )\
		$(LDFLAGS) \
		-fvisibility=hidden
	$(call AFTER_BUILD)
endif

libkrw-taurine-package: libkrw-taurine-stage
	# libkrw-taurine.mk Package Structure@&
	rm -rf $(BUILD_DIST)libkrw$(LIBKRW_SOVERSION)-taurine
	mkdir -p $(BUILD_DIST)libkrw$(LIBKRW_SOVERSION)-taurine$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libkrw

	# libkrw-taurine.mk Prep libkrw-taurine
	cp -a $(BUILD_STAGE)/libkrw-taurine$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libkrw/libkrw$(LIBKRW_SOVERSION)-taurine.dylib $(BUILD_DIST)libkrw$(LIBKRW_SOVERSION)-taurine$(MEMO_PREFIX)$(MEMO_SUB_PREFIX)/lib/libkrw
	
	# libkrw-taurine.mk Sign
	$(call SIGN,libkrw$(LIBKRW_SOVERSION)-taurine,general.xml)

	# libkrw-taurine.mk Make .debs
	$(call PACK,libkrw$(LIBKRW_SOVERSION)-taurine,DEB_LIBKRW_TAURINE_V)

	# libkrw-taurine.mk Build cleanup
	rm -rf $(BUILD_DIST)libkrw$(LIBKRW_SOVERSION)-taurine

.PHONY: libkrw-taurine libkrw-taurine-package

endif
endif
